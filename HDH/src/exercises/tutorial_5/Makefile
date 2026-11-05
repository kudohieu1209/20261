# Tutorial 5A - Universal UEFI Bootloader
#
#   make                         build main.efi, original.efi, fake_os.efi
#   make run                     chạy bản nâng cấp trong QEMU (cửa sổ đồ hoạ)
#   make run BOOTLOADER=original.efi   chạy code gốc trong PDF
#   make run-serial              chạy trong terminal (không cần cửa sổ)
#   make reset-vars              xoá NVRAM của máy ảo (mất các entry đã lưu)
#   make clean
#
# Khác với Makefile trong PDF (cần sửa để chạy trên Ubuntu 26.04: binutils 2.46, gnu-efi 4.0):
#   - objcopy không còn target "efi-app-x86_64" -> dùng "-O pei-x86-64 --subsystem efi-app"
#   - gnu-efi 4.0 tách chuỗi hằng ra section .rodata -> phải thêm "-j .rodata",
#     nếu không bootloader chỉ hiện màn hình xanh trống.

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

BOOTLOADER ?= main.efi

all: main.efi original.efi fake_os.efi

original.o: original/main.c
	gcc $(CFLAGS) -c $< -o $@

%.o: %.c
	gcc $(CFLAGS) -c $< -o $@

%.so: %.o
	ld $(LDFLAGS) $< -o $@ -lefi -lgnuefi

%.efi: %.so
	objcopy -j .text -j .sdata -j .data -j .rodata -j .dynamic -j .dynsym \
	        -j .rel -j .rela -j .reloc -O pei-x86-64 --subsystem efi-app $< $@

# Ổ 1 - USB boot: bootloader + Windows & Ubuntu giả (giống bước 4 trong PDF)
disk.img: $(BOOTLOADER) fake_os.efi
	rm -f $@
	truncate -s 64M $@
	mformat -i $@ -v USB_BOOT -F ::
	mmd -i $@ ::/EFI ::/EFI/BOOT ::/EFI/Microsoft ::/EFI/Microsoft/Boot ::/EFI/ubuntu
	mcopy -i $@ $(BOOTLOADER) ::/EFI/BOOT/BOOTX64.EFI
	mcopy -i $@ fake_os.efi ::/EFI/Microsoft/Boot/bootmgfw.efi
	mcopy -i $@ fake_os.efi ::/EFI/ubuntu/grubx64.efi

# Ổ 2 - NVMe: Fedora (dùng shim) + vài file .efi chỉ tìm được bằng chức năng Search
disk2.img: fake_os.efi
	rm -f $@
	truncate -s 64M $@
	mformat -i $@ -v NVME_DATA -F ::
	mmd -i $@ ::/EFI ::/EFI/fedora ::/tools ::/tools/memtest86 ::/boot
	mcopy -i $@ fake_os.efi ::/EFI/fedora/shimx64.efi
	mcopy -i $@ fake_os.efi ::/EFI/fedora/grubx64.efi
	mcopy -i $@ fake_os.efi ::/tools/memtest86/memtest64.efi
	mcopy -i $@ fake_os.efi ::/boot/vmlinuz-6.8.efi

OVMF_VARS.fd:
	cp $(OVMF_VARS) $@

QEMU_FLAGS = -m 256M -net none \
	-drive if=pflash,format=raw,readonly=on,file=$(OVMF_CODE) \
	-drive if=pflash,format=raw,file=OVMF_VARS.fd \
	-drive if=none,id=usbdisk,format=raw,file=disk.img \
	-device qemu-xhci -device usb-storage,drive=usbdisk,bootindex=0 \
	-drive if=none,id=nvmedisk,format=raw,file=disk2.img \
	-device nvme,serial=HUST2026,drive=nvmedisk

run: disk.img disk2.img OVMF_VARS.fd
	qemu-system-x86_64 $(QEMU_FLAGS)

run-serial: disk.img disk2.img OVMF_VARS.fd
	qemu-system-x86_64 $(QEMU_FLAGS) -nographic

reset-vars:
	rm -f OVMF_VARS.fd

clean:
	rm -f *.o *.so *.efi disk.img disk2.img

# disk.img luôn build lại để đổi BOOTLOADER=... có tác dụng ngay
.PHONY: all run run-serial reset-vars clean disk.img disk2.img
.PRECIOUS: %.so %.o
