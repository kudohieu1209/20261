#!/bin/bash
# Gỡ những gì install-esp.sh đã cài: \EFI\HUST, \EFI\testNN (chỉ thư mục có file đánh dấu)
# và boot entry "HUST 5B Bootloader" trong NVRAM.
#   sudo ./uninstall-esp.sh
set -euo pipefail

ESP=/boot/efi
LABEL="HUST 5B Bootloader"
MARKER=HUST5B.TXT

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo."; exit 1; }

for d in "$ESP"/EFI/HUST "$ESP"/EFI/test[0-9][0-9]; do
    [ -f "$d/$MARKER" ] || continue
    rm -r -- "$d"
    echo "Removed $d"
done

for NUM in $(efibootmgr | awk -v l="$LABEL" '/^Boot[0-9A-Fa-f]{4}/ && index($0, l) {print substr($1, 5, 4)}'); do
    efibootmgr --bootnum "$NUM" --delete-bootnum >/dev/null
    echo "Deleted NVRAM entry Boot$NUM"
done
efibootmgr | grep -E '^(BootNext|BootOrder)' || true
