#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/select.h>
#include <errno.h>

#define BUFFER_SIZE 1024
#define MAX_CLIENTS 30

typedef struct {
    char key[1024];
    char value[1024];
} KeyValue;

KeyValue store[MAX_CLIENTS];
int store_size = 0;

void process_command(int client_socket, char *command) {
    char response[BUFFER_SIZE] = {0};
    char cmd[10], key[256], value[256];
    sscanf(command, "%s %s %s", cmd, key, value);

    if (strcmp(cmd, "GET") == 0) {
        int found = 0;
        for (int i = 0; i < store_size; i++) {
            if (strcmp(store[i].key, key) == 0) {
                strcpy(response, store[i].value);
                found = 1;
                break;
            }
        }
        if (!found) {
            strcpy(response, "NULL");
        }
    } else if (strcmp(cmd, "SET") == 0) {
        int found = 0;
        for (int i = 0; i < store_size; i++) {
            if (strcmp(store[i].key, key) == 0) {
                strcpy(store[i].value, value);
                found = 1;
                break;
            }
        }
        if (!found && store_size < MAX_CLIENTS) {
            strcpy(store[store_size].key, key);
            strcpy(store[store_size].value, value);
            store_size++;
        }
        strcpy(response, "OK");
    } else if (strcmp(cmd, "DELETE") == 0) {
        int found = 0;
        for (int i = 0; i < store_size; i++) {
            if (strcmp(store[i].key, key) == 0) {
                for (int j = i; j < store_size - 1; j++) {
                    store[j] = store[j + 1];
                }
                store_size--;
                found = 1;
                break;
            }
        }
        if (found) {
            strcpy(response, "OK");
        } else {
            strcpy(response, "ERROR: Key not found");
        }
    } else {
        strcpy(response, "ERROR: Invalid command");
    }

    send(client_socket, response, strlen(response), 0);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <port>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    int port = atoi(argv[1]);
    int server_fd, client_socket, max_sd, activity, new_socket, addrlen;
    int client_sockets[MAX_CLIENTS] = {0};
    struct sockaddr_in address;
    char buffer[BUFFER_SIZE];

    fd_set readfds;

    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(port);

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    if (listen(server_fd, 3) < 0) {
        perror("listen failed");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    addrlen = sizeof(address);
    printf("Listening on port %d\n", port);

    while (1) {
        FD_ZERO(&readfds);
        FD_SET(server_fd, &readfds);
        max_sd = server_fd;

        for (int i = 0; i < MAX_CLIENTS; i++) {
            client_socket = client_sockets[i];
            if (client_socket > 0) {
                FD_SET(client_socket, &readfds);
            }
            if (client_socket > max_sd) {
                max_sd = client_socket;
            }
        }

        activity = select(max_sd + 1, &readfds, NULL, NULL, NULL);

        if ((activity < 0) && (errno != EINTR)) {
            perror("select error");
        }

        if (FD_ISSET(server_fd, &readfds)) {
            if ((new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
                perror("accept error");
                exit(EXIT_FAILURE);
            }

            printf("New connection, socket fd is %d, ip is : %s, port : %d\n", new_socket, inet_ntoa(address.sin_addr), ntohs(address.sin_port));

            for (int i = 0; i < MAX_CLIENTS; i++) {
                if (client_sockets[i] == 0) {
                    client_sockets[i] = new_socket;
                    printf("Adding to list of sockets as %d\n", i);
                    break;
                }
            }
        }

        for (int i = 0; i < MAX_CLIENTS; i++) {
            client_socket = client_sockets[i];

            if (FD_ISSET(client_socket, &readfds)) {
                int valread;
                if ((valread = read(client_socket, buffer, BUFFER_SIZE)) == 0) {
                    getpeername(client_socket, (struct sockaddr*)&address, (socklen_t*)&addrlen);
                    printf("Host disconnected, ip %s, port %d\n", inet_ntoa(address.sin_addr), ntohs(address.sin_port));
                    close(client_socket);
                    client_sockets[i] = 0;
                } else {
                    buffer[valread] = '\0';
                    process_command(client_socket, buffer);
                }
            }
        }
    }

    return 0;
}
