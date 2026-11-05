CC = gcc
CFLAGS = -Wall -Wextra -O2

TARGET = pipe_ipc
SRC = pipe_ipc.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET)

.PHONY: all run clean
