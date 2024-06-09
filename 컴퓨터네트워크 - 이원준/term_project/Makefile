CC = gcc
CFLAGS = -Wall -Wextra -O2

# 타겟
SERVER_TARGET = server
CLIENT_TARGET = client

# 소스 파일
SERVER_SRC = server.c
CLIENT_SRC = client.c

# 기본
all: $(SERVER_TARGET) $(CLIENT_TARGET)

# 서버
$(SERVER_TARGET): $(SERVER_SRC)
	$(CC) $(CFLAGS) -o $(SERVER_TARGET) $(SERVER_SRC)

# 클라이언트
$(CLIENT_TARGET): $(CLIENT_SRC)
	$(CC) $(CFLAGS) -o $(CLIENT_TARGET) $(CLIENT_SRC)

# 클린
clean:
	rm -f $(SERVER_TARGET) $(CLIENT_TARGET)

