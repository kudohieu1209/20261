# Tutorial 5B - Universal UEFI Bootloader trên máy thật
#
#   make                 build main.efi và fake_os.efi
#   make run             chạy thử trong QEMU: 3 ổ USB + NVMe + SATA, đủ 20 entry
#   make run-serial      như trên nhưng chạy ngay trong terminal (thoát: Ctrl-A rồi X)
#   make run TESTS=0     không tạo 15 thư mục test (chỉ còn 5 entry)
#   make run QEMU_EXTRA="-display none -monitor tcp:127.0.0.1:45454,server,nowait"
#                        chạy không cửa sổ, điều khiển + chụp màn hình qua QEMU monitor
#   make clean
#
#   Cài lên máy thật: xem README.md (ổ cứng trong máy: install-esp.sh, USB: bước 5 PDF)
#
# Khác Makefile trong PDF (cần sửa để chạy trên Ubuntu 26.04: binutils 2.46, gnu-efi 4.0):
#   - objcopy không còn target "efi-app-x86_64" -> dùng "-O pei-x86-64 --subsystem efi-app"
#   - gnu-efi 4.0 để chuỗi hằng trong .rodata -> phải thêm "-j .rodata",
#     nếu không bootloader chỉ hiện màn hình trống.

ARCH      = x86_64
EFIINC    = /usr/include/efi
EFILIB    = /usr/lib
EFI_CRT   = $(EFILIB)/crt0-efi-$(ARCH).o
EFI_LDS   = $(EFILIB)/elf_$(ARCH)_efi.lds
OVMF_CODE = /usr/share/OVMF/OVMF_CODE_4M.fd
OVMF_VARS = /usr/share/OVMF/OVMF_VARS_4M.fd

CFLAGS  = -I$(EFIINC) -I$(EFIINC)/$(ARCH) -I$(EFIINC)/protocol \
          -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -Wall
LDFLAGS = -nostdlib -znocombreloc -T $(EFI_LDS) -shared -Bsymbolic -L $(EFILIB) $(EFI_CRT)

# Số thư mục EFI/testNN giả trên USB (Exercise 2: thử menu có hơn 9 entry)
TESTS ?= 15
TEST_DIRS = $(shell seq -f 'test%02g' 1 $(TESTS) 2>/dev/null)

all: main.efi fake_os.efi

%.o: %.c
	gcc $(CFLAGS) -c $< -o $@

%.so: %.o
	ld $(LDFLAGS) $< -o $@ -lefi -lgnuefi

%.efi: %.so
	objcopy -j .text -j .sdata -j .data -j .rodata -j .dynamic -j .dynsym \
	        -j .rel -j .rela -j .reloc -O pei-x86-64 --subsystem efi-app $< $@

# Ổ USB (giống bước 4 PDF): bootloader + Windows, Ubuntu giả + testNN
usb.img: main.efi fake_os.efi
	rm -f $@
	truncate -s 64M $@
	mformat -i $@ -v MYBOOT -F ::
	mmd -i $@ ::/EFI ::/EFI/BOOT ::/EFI/Microsoft ::/EFI/Microsoft/Boot ::/EFI/ubuntu
	mcopy -i $@ main.efi ::/EFI/BOOT/BOOTX64.EFI
	mcopy -i $@ fake_os.efi ::/EFI/Microsoft/Boot/bootmgfw.efi
	mcopy -i $@ fake_os.efi ::/EFI/ubuntu/grubx64.efi
	for d in $(TEST_DIRS); do \
	    mmd -i $@ ::/EFI/$$d && mcopy -i $@ fake_os.efi ::/EFI/$$d/grubx64.efi || exit 1; \
	done

# Ổ NVMe: Fedora (shim + grub)
nvme.img: fake_os.efi
	rm -f $@
	truncate -s 64M $@
	mformat -i $@ -v NVME_SYS -F ::
	mmd -i $@ ::/EFI ::/EFI/fedora
	mcopy -i $@ fake_os.efi ::/EFI/fedora/shimx64.efi
	mcopy -i $@ fake_os.efi ::/EFI/fedora/grubx64.efi

# Ổ SATA: Debian (grub) + Arch (systemd-boot)
sata.img: fake_os.efi
	rm -f $@
	truncate -s 64M $@
	mformat -i $@ -v SATA_SYS -F ::
	mmd -i $@ ::/EFI ::/EFI/debian ::/EFI/arch
	mcopy -i $@ fake_os.efi ::/EFI/debian/grubx64.efi
	mcopy -i $@ fake_os.efi ::/EFI/arch/systemd-bootx64.efi

OVMF_VARS.fd:
	cp $(OVMF_VARS) $@

QEMU_FLAGS = -m 256M -net none \
	-drive if=pflash,format=raw,readonly=on,file=$(OVMF_CODE) \
	-drive if=pflash,format=raw,file=OVMF_VARS.fd \
	-device qemu-xhci \
	-drive if=none,id=usb,format=raw,file=usb.img \
	-device usb-storage,drive=usb,bootindex=0 \
	-drive if=none,id=nvme,format=raw,file=nvme.img \
	-device nvme,serial=HUST2026,drive=nvme \
	-device ahci,id=ahci \
	-drive if=none,id=sata,format=raw,file=sata.img \
	-device ide-hd,drive=sata,bus=ahci.0

run: usb.img nvme.img sata.img OVMF_VARS.fd
	qemu-system-x86_64 $(QEMU_FLAGS) $(QEMU_EXTRA)

run-serial: usb.img nvme.img sata.img OVMF_VARS.fd
	qemu-system-x86_64 $(QEMU_FLAGS) -nographic

clean:
	rm -f *.o *.so *.efi *.img OVMF_VARS.fd

# Ảnh đĩa luôn tạo lại để đổi TESTS=... có tác dụng ngay
.PHONY: all run run-serial clean usb.img nvme.img sata.img
.PRECIOUS: %.so %.o
