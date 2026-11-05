#!/bin/bash
# screenshots.sh - Chạy các lệnh THẬT của Exercise 5 rồi vẽ output thành ảnh trong screenshots/
# (đồng thời lưu output dạng text vào output/). Cách dùng: ./screenshots.sh
set -e
cd "$(dirname "$0")"
DIR=$(pwd)
RENDER="python3 -I $DIR/../tools/term2png.py"
TMP=$(mktemp -d)
mkdir -p screenshots output

# shot <tên ảnh> <transcript>: vẽ một transcript đã có thành ảnh
shot() {
  $RENDER "$2" "screenshots/$1.png" "$DIR"
  echo "  screenshots/$1.png"
}

# run <file transcript> <lệnh...>: ghi "$ lệnh" + output thật của lệnh vào transcript
run() {
  local t=$1; shift
  for c in "$@"; do
    echo "\$ $c" >> "$t"
    bash -c "$c" >> "$t" 2>&1 || true
  done
}

# 1. Build và chạy tiến trình mẫu
make clean > /dev/null
T=$TMP/01.txt
run "$T" "make"
./target > "$TMP/target.out" &
PID=$!
until grep -q procmem "$TMP/target.out" 2>/dev/null; do sleep 0.1; done
{ echo "\$ ./target &"; echo "[1] $PID"; cat "$TMP/target.out"; } >> "$T"
cp "$TMP/target.out" output/target.txt
shot 01_build_va_chay_target "$T"

# 2-5. Từng phần trong báo cáo của procmem
./procmem $PID > output/procmem_target.txt
./procmem $PID -p > output/procmem_target_pages.txt
T=$TMP/02.txt; run "$T" "./procmem $PID | awk '/^\\[2\\]/{exit} 1'"
shot 02_cac_doan_VMA "$T"
T=$TMP/03.txt; run "$T" "./procmem $PID | awk '/^\\[2\\]/{f=1} /^\\[3\\]/{exit} f'"
shot 03_cac_trang "$T"
T=$TMP/04.txt; run "$T" "./procmem $PID | awk '/^\\[3\\]/{f=1} /^\\[4\\]/{exit} f'"
shot 04_RAM_theo_vung "$T"
T=$TMP/05.txt; run "$T" "./procmem $PID | awk '/^\\[4\\]/{f=1} f'"
shot 05_doi_chieu_do_chinh_xac "$T"

# 6. Chế độ -p: từng trang của vùng heap (có cả trang chưa được cấp frame)
T=$TMP/06.txt; run "$T" "./procmem $PID -p | awk '/^  heap +[0-9a-f]+-/{f=1} /^  stack +[0-9a-f]+-/{exit} f'"
shot 06_tung_trang_heap "$T"
kill $PID

# 7. Một tiến trình lớn thật trên máy (lấy tiến trình chiếm nhiều RAM nhất của user)
BIG=$(ps -u "$USER" -o pid=,rss= --sort=-rss | awk 'NR==1{print $1}')
T=$TMP/07.txt
run "$T" "ps -o pid,rss,comm -p $BIG" "./procmem $BIG | awk '/^\\[1\\]/{print} /^\\[3\\]/{f=1} f'"
shot 07_tien_trinh_lon "$T"

# 8. Tự đo chính mình + các trường hợp lỗi
T=$TMP/08.txt
run "$T" "./procmem self | awk '/^\\[4\\]/{f=1} f'" "./procmem 1" "./procmem 999999"
shot 08_self_va_loi "$T"

rm -rf "$TMP"
