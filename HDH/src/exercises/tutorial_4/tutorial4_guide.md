# 🛠️ Tutorial 4: Làm việc với hệ điều hành Xv6

---

## 🎯 1. Mục Tiêu Bài Thực Hành

1. **Cài đặt** hệ điều hành mã nguồn mở Xv6.
2. **Triển khai (chạy)** Xv6 trên máy ảo QEMU.
3. **Lập trình** trong Xv6: viết một chương trình người dùng và chạy nó trong Xv6.

> **Xv6 là gì?** Xv6 là một hệ điều hành nhỏ kiểu Unix (Unix V6) do MIT viết lại để dạy môn Operating Systems (6.1810). Mã nguồn chỉ vài nghìn dòng C nên đọc hết được. Có hai phiên bản:
> * **xv6-riscv** – bản đang được duy trì, chạy trên kiến trúc RISC-V. **Bài này dùng bản này.**
> * **xv6-public** – bản cũ cho x86, đã ngừng phát triển và thường lỗi khi biên dịch bằng gcc đời mới.

---

## 💻 2. Môi Trường Đã Dùng

| Thành phần | Phiên bản |
| :--- | :--- |
| Hệ điều hành host | Ubuntu 26.04.1 LTS (x86_64) |
| Cross compiler | `riscv64-linux-gnu-gcc` 15.2.0 |
| Máy ảo | `qemu-system-riscv64` 10.2.1 |
| Mã nguồn Xv6 | `mit-pdos/xv6-riscv`, commit `06aad25` (2026-09-26) |

---

## 🛠️ 3. Từng Bước Thực Hiện Chi Tiết

```text
[Bước 1: Cài toolchain + QEMU] ──> [Bước 2: Tải mã nguồn] ──> [Bước 3: Sửa lỗi đường dẫn có dấu cách]
                                                                              │
[Bước 6: Viết chương trình] <── [Bước 5: Chạy Xv6 trong QEMU] <── [Bước 4: Biên dịch]
```

---

### Bước 1: Cài bộ biên dịch RISC-V và QEMU

Máy thật là x86_64 nên cần **cross compiler** để biên dịch ra mã RISC-V, và **QEMU** để giả lập một máy RISC-V.

```bash
sudo apt update
sudo apt install -y git build-essential gdb-multiarch \
    gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu \
    qemu-system-riscv
```

> ⚠️ **Lưu ý cho Ubuntu 26.04:** QEMU cho RISC-V nằm trong gói **`qemu-system-riscv`**. Nhiều hướng dẫn cũ (kể cả của MIT) bảo cài `qemu-system-misc`. Trên bản Ubuntu này, gói đó **không** có `qemu-system-riscv64`.

Kiểm tra:

```bash
riscv64-linux-gnu-gcc --version   # riscv64-linux-gnu-gcc (Ubuntu 15.2.0-...) 15.2.0
qemu-system-riscv64 --version     # QEMU emulator version 10.2.1
```

---

### Bước 2: Tải mã nguồn Xv6

```bash
cd src/exercises/tutorial_4
git clone https://github.com/mit-pdos/xv6-riscv.git
cd xv6-riscv
```

Cấu trúc chính:

| Thư mục / Tệp | Nội dung |
| :--- | :--- |
| `kernel/` | Mã nguồn nhân: tiến trình (`proc.c`), bộ nhớ ảo (`vm.c`), bẫy/ngắt (`trap.c`), system call (`syscall.c`, `sysproc.c`, `sysfile.c`), hệ thống tệp (`fs.c`)... |
| `user/` | Các chương trình người dùng (`sh`, `ls`, `cat`, `echo`...) và thư viện (`ulib.c`, `printf.c`, `user.h`) |
| `mkfs/` | Công cụ tạo ảnh đĩa `fs.img` |
| `Makefile` | Script biên dịch và chạy QEMU |

---

### Bước 3: Sửa lỗi khi đường dẫn có dấu cách

Repo này nằm trong thư mục `.../Vibe Coding/...` (có **dấu cách**). Khi `make` lần đầu sẽ gặp lỗi:

```text
cc1: error: invalid argument '/run/media/hieu_20223967/D/Vibe' to '-ffile-prefix-map'
```

**Nguyên nhân:** dòng 64 của `Makefile` đưa đường dẫn thư mục hiện tại vào cờ `-ffile-prefix-map` mà không đặt trong dấu nháy, nên shell tách nó ra ở chỗ dấu cách.

**Cách sửa:** đặt cả cờ trong dấu nháy đơn:

```makefile
# Trước
DETFLAGS = -ffile-prefix-map=$(CURDIR)=.
# Sau
DETFLAGS = '-ffile-prefix-map=$(CURDIR)=.'
```

Hoặc dùng một lệnh:

```bash
sed -i "s|^DETFLAGS = .*|DETFLAGS = '-ffile-prefix-map=\$(CURDIR)=.'|" Makefile
```

> Nếu clone Xv6 vào thư mục **không** có dấu cách (ví dụ `~/xv6-riscv`) thì bỏ qua bước này.

---

### Bước 4: Biên dịch

```bash
make
```

Kết quả gồm hai tệp chính:
* `kernel/kernel` – file nhân Xv6 (ELF, RISC-V).
* `fs.img` – ảnh đĩa chứa hệ thống tệp và các chương trình người dùng.

---

### Bước 5: Chạy Xv6 trong QEMU

```bash
make qemu
```

Kết quả khởi động:

```text
xv6 kernel is booting

hart 2 starting
hart 1 starting
init: starting sh
$
```

Thử vài lệnh trong shell của Xv6:

```text
$ ls
.              1 1 1024
..             1 1 1024
README         2 2 2441
cat            2 3 36728
echo           2 4 35592
...
console        3 23 0
$ echo hello xv6
hello xv6
$ cat README | wc
48 336 2441
```

**Thoát QEMU:** nhấn `Ctrl + A`, thả ra, rồi nhấn `X`.

> Các phím tắt hữu ích khác trong Xv6: `Ctrl + P` in danh sách tiến trình (giống `ps`).

---

### Bước 6: Lập trình trong Xv6 – thêm chương trình `hello`

**6.1. Tạo tệp** `user/hello.c`:

```c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  printf("Hello from xv6! My pid is %d\n", getpid());
  exit(0);
}
```

> ⚠️ Chương trình Xv6 **không** dùng thư viện C chuẩn (`stdio.h`, `stdlib.h`). Các hàm có sẵn được khai báo trong `user/user.h` và phải kết thúc bằng `exit(0)`, không `return` từ `main`.

**6.2. Khai báo trong `Makefile`:** thêm `$U/_hello\` vào cuối danh sách `UPROGS`:

```makefile
UPROGS=\
	$U/_cat\
	...
	$U/_sync\
	$U/_hello\
```

**6.3. Biên dịch và chạy lại:**

```bash
make qemu
```

```text
$ hello
Hello from xv6! My pid is 3
```

---

## 🧯 4. Lỗi Thường Gặp

| Lỗi | Nguyên nhân | Cách khắc phục |
| :--- | :--- | :--- |
| `invalid argument '.../Vibe' to '-ffile-prefix-map'` | Đường dẫn có dấu cách | Làm theo **Bước 3** |
| `qemu-system-riscv64: command not found` | Cài nhầm `qemu-system-misc` | `sudo apt install qemu-system-riscv` |
| `riscv64-...-gcc: not found` / `Couldn't find a riscv64 version of GCC` | Chưa cài cross compiler | `sudo apt install gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu` |
| `hello: exec failed` trong Xv6 | Chưa thêm `$U/_hello\` vào `UPROGS` | Làm lại **Bước 6.2**, rồi `make qemu` |
| Muốn làm sạch để build lại | – | `make clean` |

---

## 📚 5. Tài Liệu Tham Khảo

* Mã nguồn: <https://github.com/mit-pdos/xv6-riscv>
* Sách *xv6: a simple, Unix-like teaching operating system* (MIT): <https://pdos.csail.mit.edu/6.1810/2025/xv6/book-riscv-rev5.pdf>
* Hướng dẫn cài công cụ của MIT 6.1810: <https://pdos.csail.mit.edu/6.1810/2025/tools.html>
