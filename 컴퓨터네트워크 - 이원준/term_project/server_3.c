#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>
#include <sys/select.h>

#define BUFFER_SIZE 1024
#define MAX_KEYS 10

typedef struct {
    char key[BUFFER_SIZE];
    char value[BUFFER_SIZE];
} KeyValue;

KeyValue keys[MAX_KEYS];
int current_keys = 0;

void handle_client(int client_socket, char *req) {

    // Parse the received data
    char command[5];
    char key[BUFFER_SIZE];
    char value[BUFFER_SIZE];
    
    int received = sscanf(req, "%s %s %s", command, key, value);
    if (received < 0) {
        perror("request failed");
        close(client_socket);
        return;
    }

    // Process SET command
    if (strcmp(command, "set") == 0) {
        int key_found = 0;
        for (int i = 0; i < current_keys; i++) {
            if (strcmp(keys[i].key, key) == 0) {
                strcpy(keys[i].value, value);
                key_found = 1;
                break;
            }
        }
        if (!key_found) {
            strcpy(keys[current_keys].key, key);
            strcpy(keys[current_keys].value, value);
            current_keys++;
        }
        send(client_socket, "+OK\n", strlen("+OK\n"), 0);
    }
    // Process GET command
    else if (strcmp(command, "get") == 0) {
        int key_found = 0;
        for (int i = 0; i < current_keys; i++) {
            if (strcmp(keys[i].key, key) == 0) {
                char response[BUFFER_SIZE];
                snprintf(response, BUFFER_SIZE, "$%s\n", keys[i].value);
                send(client_socket, response, strlen(response), 0);
                key_found = 1;
                break;
            }
        }
        if (!key_found) {
            send(client_socket, "$-1\n", strlen("$-1\n"), 0);
        }
    }
    else if (strcmp(command, "EXIT") == 0){
        send(client_socket, "-ERR Server is closed.\n", strlen("-ERR Server is closed.\n"), 0);
        close(client_socket);
    }
    else {
        send(client_socket, "-ERR Wrong input. Please enter again.", strlen("-ERR Wrong input. Please enter again."), 0);
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <port>\n", argv[0]);
        return -1;
    }

    int port = atoi(argv[1]);
    int server_socket, client_socket, new_socket, max_sd, client_req;
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_len = sizeof(client_addr);
    int client_sockets[MAX_KEYS] = {-1};

    fd_set readfds;
    char buffer[BUFFER_SIZE];

    // Create server socket
    server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket < 0) {
        perror("socket creation failed");
        return -1;
    }

    // Bind server socket to port
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(port);

    if (bind(server_socket, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("bind failed");
        return -1;
    }

    // Listen for incoming connections
    if (listen(server_socket, 5) < 0) {
        perror("listen failed");
        return -1;
    }

    printf("Server listening on port %d...\n", port);

    // Accept incoming connections
    while (1) {
        FD_ZERO(&readfds);                  //readfds 초기화
        FD_SET(server_socket, &readfds);
        max_sd = server_socket;
        
        // 클라이언트 소켓을 파일 디스크립터 세트에 추가
        for (int i = 0; i < MAX_KEYS; i++) {
            client_socket = client_sockets[i];
            if (client_socket > 0) {
                FD_SET(client_socket, &readfds);
            }
            if (client_socket > max_sd) {
                max_sd = client_socket;
            }
        }

        struct timeval timeout;
        timeout.tv_sec = 3;
        timeout.tv_usec = 0;

        // 활동 대기
        int listening = select(max_sd + 1, &readfds, NULL, NULL, &timeout);
        if (listening < 0) {
            perror("select error");
            break;
        }
        else if (listening == 0){
            continue;
        }
        
        // 새로운 연결 수락
        if(FD_ISSET(server_socket, &readfds)){
            if ((new_socket = accept(server_socket, (struct sockaddr *)&client_addr, (socklen_t*)&client_len)) < 0) {
                perror("accept failed");
                return -1;
            }

            printf("New connection: socket fd : %d, ip : %s, port : %d\n",
                new_socket, inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));

            // 새로운 소켓을 배열에 추가
            for (int i = 0; i < MAX_KEYS; i++) {
                if (client_sockets[i] == -1) {
                    client_sockets[i] = new_socket;
                    printf("Adding to list of sockets as %d\n", i);
                    break;
                }
            }
        }
        

        // 기존 클라이언트의 활동 처리
        for (int i = 0; i < MAX_KEYS; i++) {
            client_socket = client_sockets[i];

            if (FD_ISSET(client_socket, &readfds)) {
                if ((client_req = read(client_socket, buffer, BUFFER_SIZE)) == 0) {
                    // 연결 종료
                    getpeername(client_socket, (struct sockaddr*)&client_addr, (socklen_t*)&client_len);
                    printf("Host disconnected from ip: %s, port: %d\n",
                           inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));
                    close(client_socket);
                    client_sockets[i] = -1;
                } else {
                    // 메시지 처리
                    printf("handling client %d request\n", i);
                    buffer[client_req] = '\0';
                    handle_client(client_socket, buffer);
                }
            }
        }
    }

    
    // Close server socket
    close(server_socket);
    printf("server has been closed.\n");

    return 0;
}
