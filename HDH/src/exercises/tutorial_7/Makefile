# Makefile cho kernel module (out-of-tree): nhờ hệ thống build của kernel (Kbuild) biên dịch
obj-m += hello.o wifi_info.o

# Cây mã nguồn/headers của kernel ĐANG CHẠY (máy này: ~/linux_lab/linux-7.2.6 tự build)
KDIR ?= /lib/modules/$(shell uname -r)/build
PWD  := $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

# make test M_NAME=hello  -> nạp, xem log, gỡ (chỉ in log của module này, không xóa dmesg)
M_NAME ?= hello
test: all
	sudo insmod $(M_NAME).ko
	lsmod | grep $(M_NAME)
	sudo rmmod $(M_NAME)
	sudo dmesg | grep "$(M_NAME):" | tail -20

.PHONY: all clean test
