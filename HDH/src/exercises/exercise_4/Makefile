CC = gcc
CFLAGS = -Wall -Wextra -O2

TARGETS = sched_sim linux_sched_demo

all: $(TARGETS)

%: %.c
	$(CC) $(CFLAGS) $< -o $@

# Mô phỏng: make sim ALGO=srtf INPUT=sample.txt Q=2
ALGO ?= all
INPUT ?= sample.txt
Q ?= 2
sim: sched_sim
	./sched_sim $(ALGO) $(INPUT) $(Q)

# Linux thật: make demo NICE="0 5 10"
NICE ?= 0 5 10
demo: linux_sched_demo
	./linux_sched_demo nice $(NICE)

# Bản xv6 sạch để sửa scheduler (cần riscv64-linux-gnu-gcc + qemu-system-riscv64)
xv6:
	$(MAKE) -C xv6-riscv qemu

clean:
	rm -f $(TARGETS)
	$(MAKE) -C xv6-riscv clean

.PHONY: all sim demo xv6 clean
