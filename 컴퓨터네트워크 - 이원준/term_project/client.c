#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define BUFFER_SIZE 1024

void send_command(int sock, const char *input) {
    char buffer[BUFFER_SIZE];
    send(sock, input, strlen(input), 0);
    int bytes_read = recv(sock, buffer, BUFFER_SIZE - 1, 0);
    buffer[bytes_read] = '\0';
    printf("%s\n", buffer);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <ip> <port>\n", argv[0]);
        return -1;
    }

    char *ip = argv[1];
    int port = atoi(argv[2]);

    int sock = 0;
    struct sockaddr_in serv_addr;

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("\n Socket creation error \n");
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);

    if (inet_pton(AF_INET, ip, &serv_addr.sin_addr) <= 0) {
        printf("\nInvalid address/ Address not supported \n");
        return -1;
    }

    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        printf("\nConnection Failed \n");
        return -1;
    }

    char input[BUFFER_SIZE];

    while (1) {
        if (fgets(input, BUFFER_SIZE, stdin) != NULL) {
            printf("%s", input);
            if (strcmp(input, "EXIT") == 0){
                printf("Goodbye!");
                break;
            }
            send_command(sock, input);
        } else {
            printf("Error reading input.\n");
        }
    }

    close(sock);
    return 0;
}
