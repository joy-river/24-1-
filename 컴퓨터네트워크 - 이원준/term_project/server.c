#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/select.h>
#include <errno.h>
#include <signal.h>

#define STRING_SIZE 1024
#define MAX_KEY 10
#define MAX_CLIENT 10


typedef struct {
    char key[STRING_SIZE];
    char value[STRING_SIZE];
} Key_Value;

Key_Value store[MAX_KEY];
int len_store = 0;

volatile sig_atomic_t stop = 0;

void handle_sigint(int sig) {
    (void)sig;
    stop = 1;
}

void server_func(int client_socket, char *input) {
    char buffer[STRING_SIZE] = {0};
    char cmd[10], key[STRING_SIZE], value[STRING_SIZE];
    int parsed_items = sscanf(input, "%s %s %s", cmd, key, value);

    if (parsed_items < 1) {
        strcpy(buffer, "-ERR: 유효하지 않은 입력입니다.");
    } else if (strcmp(cmd, "get") == 0 || strcmp(cmd, "GET") == 0) {
        if (parsed_items < 2) {
            strcpy(buffer, "-ERR: GET 명령에 Key가 입력되지 않았습니다.");
        } else {
            int found = 0;
            for (int i = 0; i < len_store; i++) {
                if (strcmp(store[i].key, key) == 0) {
                    snprintf(buffer, sizeof(buffer), "$%s", store[i].value);
                    found = 1;
                    break;
                }
            }
            if (!found) {
                strcpy(buffer, "$-1");
            }
        }
    } 
    else if (strcmp(cmd, "set") == 0 || strcmp(cmd, "SET") == 0) {
        if (parsed_items < 3) {
            strcpy(buffer, "-ERR: SET 명령에 Key 혹은 Value가 입력되지 않았습니다.");
        } else {
            int found = 0;
            for (int i = 0; i < len_store; i++) {
                if (strcmp(store[i].key, key) == 0) {
                    strcpy(store[i].value, value);
                    found = 1;
                    break;
                }
            }
            if (!found) {
                strcpy(store[len_store].key, key);
                strcpy(store[len_store].value, value);
                len_store++;
            }
             strcpy(buffer, "+OK");
        }
    }
    else if (strcmp(cmd, "EXIT") == 0){
        strcpy(buffer, "-ERR: 서버가 종료되었습니다.");
    }
    else {
        strcpy(buffer, "-ERR: 유효하지 않은 입력입니다.");
    }

    send(client_socket, buffer, strlen(buffer), 0);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("./server <포트번호> 로 입력해주세요\n");
        return -1;
    }

    struct sigaction sa;
    sa.sa_handler = handle_sigint;
    sa.sa_flags = 0;
    sigemptyset(&sa.sa_mask);
    if (sigaction(SIGINT, &sa, NULL) == -1) {
        perror("sigaction 오류");
        return -1;
    }

    int port = atoi(argv[1]);
    int server_socket, client_socket, max_sd, sd, new_socket, addrlen;

    int client_sockets[MAX_CLIENT] = {0};
    struct sockaddr_in address;
    char buffer[STRING_SIZE];

    fd_set reads;
    struct timeval timeout;

    if ((server_socket = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        perror("소켓 생성 실패");
        return -1;
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(port);

    if (bind(server_socket, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("서버 바인드 실패");
        close(server_socket);
        return -1;
    }

    if (listen(server_socket, 3) < 0) {
        perror("Listen 실패");
        close(server_socket);
        return -1;
    }

    addrlen = sizeof(address);
    printf("포트번호 %d 에서 listen 중입니다...\n", port);
    
    while (!stop) {
        FD_ZERO(&reads);
        FD_SET(server_socket, &reads);
        max_sd = server_socket;

        for (int i = 0; i < MAX_CLIENT; i++) {
            client_socket = client_sockets[i];
            if (client_socket > 0) {
                FD_SET(client_socket, &reads);
            }
            if (client_socket > max_sd) {
                max_sd = client_socket;
            }
        }
        
        timeout.tv_sec = 1;
        timeout.tv_usec = 0;

        if (select(max_sd + 1, &reads, NULL, NULL, &timeout) < 0 && (errno != EINTR)){
            perror("Select 오류");
            break;
        }

        if (stop) {
            break;
        }

        if (FD_ISSET(server_socket, &reads)) {
            while ((new_socket = accept(server_socket, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
                if (errno == EINTR) {
                    if (stop) break;
                    continue;
                } else {
                    perror("accept 오류");
                    return -1;
                }
            }

            if (stop) {
                break;
            }

            printf("새로운 클라이언트가 연결되었습니다.\n socket_fd : %d\n ip : %s\n port : %d\n", new_socket, inet_ntoa(address.sin_addr), ntohs(address.sin_port));

            for (int i = 0; i < MAX_CLIENT; i++) {
                if (client_sockets[i] == 0) {
                    client_sockets[i] = new_socket;
                    printf("%d번 소켓에 클라이언트가 추가되었습니다.\n", i);
                    break;
                }
            }
        }

        for (int i = 0; i < MAX_CLIENT; i++) {
            client_socket = client_sockets[i];

            if (FD_ISSET(client_socket, &reads)) {
                int client_act;
                if ((client_act = read(client_socket, buffer, STRING_SIZE)) == 0) {
                    getpeername(client_socket, (struct sockaddr*)&address, (socklen_t*)&addrlen);
                    printf("%d번 소켓의 클라이언트가 연결 해제되었습니다.\n ip : %s\n port %d\n", i, inet_ntoa(address.sin_addr), ntohs(address.sin_port));
                    close(client_socket);
                    client_sockets[i] = 0;
                } else {
                    printf("%d번 소켓의 클라이언트의 요청을 처리합니다.\n", i);
                    buffer[client_act] = '\0';
                    server_func(client_socket, buffer);
                }
            }
        }
    }

    for (int i = 0; i < MAX_CLIENT; i++) {
        sd = client_sockets[i];
        if (sd > 0) {
            server_func(sd, "EXIT");
            close(sd);
        }
    }
    close(server_socket);
    printf("\n서버가 종료되었습니다.\n");

    return 0;
}
