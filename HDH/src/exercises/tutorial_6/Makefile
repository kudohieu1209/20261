CC = gcc
CFLAGS = -g -Wall -Wextra   # -g: thêm thông tin debug để Valgrind báo đúng số dòng

TARGETS = memory_error memory_step1 memory_fixed
VALGRIND = valgrind --leak-check=full --track-origins=yes --show-leak-kinds=all

all: $(TARGETS)

%: %.c
	$(CC) $(CFLAGS) $< -o $@

# make check P=memory_error | memory_step1 | memory_fixed
P ?= memory_fixed
check: $(P)
	$(VALGRIND) ./$(P)

# Đo bộ nhớ heap theo thời gian bằng Massif
massif: memory_fixed
	valgrind --tool=massif --massif-out-file=massif.out ./memory_fixed
	ms_print massif.out | head -40

clean:
	rm -f $(TARGETS) massif.out*

.PHONY: all check massif clean
