CC = gcc
CFLAGS = -Wall -Wextra -O2

TARGETS = procmem target

all: $(TARGETS)

procmem: procmem.c
	$(CC) $(CFLAGS) $< -o $@

# -O0 để compiler không bỏ bớt các vòng ghi/đọc bộ nhớ "vô dụng" trong target
target: target.c
	$(CC) -Wall -Wextra -O0 $< -o $@

# Chạy procmem cho một PID bất kỳ: make run PID=1234 (thêm ARGS=-p để in từng trang)
run: procmem
	./procmem $(PID) $(ARGS)

# Demo đầy đủ: chạy target, đo bằng procmem, lưu kết quả vào output/
demo: all
	@mkdir -p output
	@./target > output/target.txt & pid=$$!; \
	until grep -q procmem output/target.txt 2>/dev/null; do sleep 0.1; done; \
	./procmem $$pid > output/procmem_target.txt; \
	./procmem $$pid -p > output/procmem_target_pages.txt; \
	kill $$pid; \
	cat output/target.txt output/procmem_target.txt

clean:
	rm -f $(TARGETS)

.PHONY: all run demo clean
