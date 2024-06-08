#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define BUFFER_SIZE 1024

int send_command(int sock, const char *input) {
    char buffer[BUFFER_SIZE];
    send(sock, input, strlen(input), 0);
    int bytes_read = recv(sock, buffer, BUFFER_SIZE - 1, 0);
    buffer[bytes_read] = '\0';
    
    if (bytes_read <= 0) {
        printf("서버와의 연결이 끊겼습니다.\n");
        return -1;
    }

    if (strncmp(buffer, "-ERR", 4) == 0){
        printf("%s\n서버 에러 발생, 클라이언트를 종료합니다.\n", buffer);
        return -1;
    }

    printf("%s\n", buffer);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("./client <ip주소> <포트번호>로 입력해주세요. \n");
        return -1;
    }

    char *ip = argv[1];
    int port = atoi(argv[2]);

    int sock = 0;
    struct sockaddr_in serv_addr;

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        perror("소켓 설정 에러");
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);

    if (inet_pton(AF_INET, ip, &serv_addr.sin_addr) <= 0) {
        perror("유효하지 않은 주소");
        return -1;
    }

    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        perror("서버와 연결하지 못했습니다");
        return -1;
    }
    else
        printf("\n서버와 연결되었습니다.\n");

    char input[BUFFER_SIZE];


    while (1) {
        printf("입력 대기중...\n");
        if (fgets(input, BUFFER_SIZE, stdin) != NULL) {
            if (strncmp(input, "EXIT", 4) == 0){
                printf("Goodbye.");
                break;
            }
            if (send_command(sock, input) < 0)
                break;
        }
    }

    close(sock);
    return 0;
}
