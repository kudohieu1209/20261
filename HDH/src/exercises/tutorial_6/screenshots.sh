#!/bin/bash
# screenshots.sh - Chạy các lệnh THẬT của Tutorial 6, lưu log vào output/ và vẽ ảnh vào screenshots/
cd "$(dirname "$0")"
DIR=$(pwd)
RENDER="python3 -I $DIR/../tools/term2png.py"
VG="valgrind --leak-check=full --track-origins=yes --show-leak-kinds=all"
TMP=$(mktemp -d)
mkdir -p screenshots output
make clean > /dev/null && make > /dev/null 2>&1

# shot <tên> <lệnh...>: chạy lệnh, ghi transcript, vẽ ảnh
shot() {
  local name=$1; shift
  : > "$TMP/t.txt"
  for c in "$@"; do
    echo "\$ $c" >> "$TMP/t.txt"
    { bash -c "$c" >> "$TMP/t.txt" 2>&1; } 2> /dev/null
    [ $? -eq 139 ] && echo "Segmentation fault (core dumped)" >> "$TMP/t.txt"
  done
  $RENDER "$TMP/t.txt" "screenshots/$name.png" "$DIR"
  echo "  screenshots/$name.png"
}

shot 01_ban_goc_crash \
  "gcc -g -o memory_error memory_error.c" "$VG ./memory_error"
shot 02_buoc1_thay_leak "$VG ./memory_step1"
shot 03_ban_sua_sach \
  "gcc -g -Wall -Wextra -o memory_fixed memory_fixed.c" "$VG ./memory_fixed"
shot 04_massif \
  "valgrind --tool=massif --massif-out-file=massif.out ./memory_fixed" "ms_print massif.out | sed -n '7,30p'"

for p in memory_error memory_step1 memory_fixed; do
  { $VG ./$p > output/valgrind_$p.txt 2>&1; } 2> /dev/null
done
rm -rf "$TMP"
