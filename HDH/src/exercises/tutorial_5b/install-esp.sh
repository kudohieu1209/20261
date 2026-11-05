#!/bin/bash
# Cài bootloader Tutorial 5B lên ổ cứng trong máy (thay cho USB ở bước 5 của PDF).
#
#   sudo ./install-esp.sh            chép main.efi vào \EFI\HUST\ + tạo boot entry "HUST 5B"
#   sudo ./install-esp.sh --tests    thêm 15 thư mục \EFI\test01..test15 (Exercise 2)
#   sudo ./install-esp.sh --next     ... và boot vào bootloader ở LẦN KHỞI ĐỘNG TỚI (BootNext)
#
# An toàn:
#   - KHÔNG format gì cả. Chỉ ghi vào thư mục mới \EFI\HUST và \EFI\testNN trên ESP.
#   - Boot entry được tạo bằng "efibootmgr --create-only": KHÔNG đổi BootOrder,
#     nên máy vẫn boot Ubuntu/Windows như cũ. BootNext chỉ có tác dụng đúng 1 lần.
#   - Gỡ: sudo ./uninstall-esp.sh
set -euo pipefail

ESP=/boot/efi
LABEL="HUST 5B Bootloader"
LOADER='\EFI\HUST\hustboot.efi'
MARKER=HUST5B.TXT   # đánh dấu thư mục do script này tạo, uninstall chỉ xoá thư mục có file này
cd "$(dirname "$0")"

TESTS=0; NEXT=0
for a in "$@"; do
    case "$a" in
        --tests) TESTS=1 ;;
        --next)  NEXT=1 ;;
        *) echo "Unknown option: $a"; exit 1 ;;
    esac
done

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo."; exit 1; }
[ -d /sys/firmware/efi ] || { echo "This machine did not boot in UEFI mode."; exit 1; }
[ "$(findmnt -no FSTYPE "$ESP")" = vfat ] || { echo "$ESP is not a mounted FAT (ESP) partition."; exit 1; }
[ -f main.efi ] && [ -f fake_os.efi ] || { echo "Run 'make' first."; exit 1; }

PART=$(findmnt -no SOURCE "$ESP")          # vd /dev/nvme0n1p1
DISK=/dev/$(lsblk -no PKNAME "$PART")      # vd /dev/nvme0n1
PARTN=$(lsblk -no PARTN "$PART")           # vd 1
echo "ESP: $PART (disk $DISK, partition $PARTN), free: $(df -h --output=avail "$ESP" | tail -1)"

if [ "$(od -An -t u1 /sys/firmware/efi/efivars/SecureBoot-8be4df61-93ca-11d0-aa6b-00a0c90c032c 2>/dev/null | awk '{print $NF}')" = 1 ]; then
    echo "WARNING: Secure Boot is ON - the firmware will refuse to run this unsigned bootloader."
fi

mkdir -p "$ESP/EFI/HUST"
cp main.efi "$ESP/EFI/HUST/hustboot.efi"
echo "Tutorial 5B - Mai Duy Hieu 20223967. Remove with uninstall-esp.sh" > "$ESP/EFI/HUST/$MARKER"
echo "Copied main.efi -> $LOADER"

if [ $TESTS = 1 ]; then
    for i in $(seq -w 1 15); do
        d="$ESP/EFI/test$i"
        if [ -e "$d" ] && [ ! -e "$d/$MARKER" ]; then
            echo "Skip $d: exists and was not created by this script"; continue
        fi
        mkdir -p "$d"
        cp fake_os.efi "$d/grubx64.efi"
        echo "Tutorial 5B test entry" > "$d/$MARKER"
    done
    echo "Created \\EFI\\test01 .. \\EFI\\test15 (fake OS)"
fi

find_entry() {   # số hex của boot entry có tên $LABEL, rỗng nếu chưa có
    efibootmgr | awk -v l="$LABEL" '/^Boot[0-9A-Fa-f]{4}/ && index($0, l) {print substr($1, 5, 4); exit}'
}
NUM=$(find_entry)
if [ -z "$NUM" ]; then
    efibootmgr --create-only --disk "$DISK" --part "$PARTN" --label "$LABEL" --loader "$LOADER" >/dev/null
    NUM=$(find_entry)
    echo "Created NVRAM entry Boot$NUM \"$LABEL\" (BootOrder unchanged)"
else
    echo "NVRAM entry Boot$NUM \"$LABEL\" already exists"
fi

if [ $NEXT = 1 ]; then
    efibootmgr --bootnext "$NUM" >/dev/null
    echo "BootNext = $NUM: the next reboot (only that one) starts the bootloader."
fi

cat <<EOF

Done. To start the bootloader:
  - sudo efibootmgr --bootnext $NUM && reboot      (one time only), or
  - reboot and press F12 at the Lenovo logo, then choose "$LABEL".
EOF
