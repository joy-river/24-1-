# Makefile for Redis-like Key-Value Store project

# 컴파일러 설정
CC = gcc
CFLAGS = -Wall -Wextra -O2

# 타겟 파일명
SERVER_TARGET = server
CLIENT_TARGET = client

# 소스 파일
SERVER_SRC = server.c
CLIENT_SRC = client.c

# 기본 타겟: 서버와 클라이언트 모두 컴파일
all: $(SERVER_TARGET) $(CLIENT_TARGET)

# 서버 타겟
$(SERVER_TARGET): $(SERVER_SRC)
	$(CC) $(CFLAGS) -o $(SERVER_TARGET) $(SERVER_SRC)

# 클라이언트 타겟
$(CLIENT_TARGET): $(CLIENT_SRC)
	$(CC) $(CFLAGS) -o $(CLIENT_TARGET) $(CLIENT_SRC)

# 클린 타겟: 컴파일된 바이너리 파일을 삭제
clean:
	rm -f $(SERVER_TARGET) $(CLIENT_TARGET)

# 실행 예제
run_server:
	./$(SERVER_TARGET) 8080

run_client:
	./$(CLIENT_TARGET) 127.0.0.1 8080

.PHONY: all clean run_server run_client
