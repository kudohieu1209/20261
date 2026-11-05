# 🛠️ Tutorial 6: Memory Profiling với Valgrind

## 🎯 1. Mục tiêu

1. **Đo lượng bộ nhớ** mà tiến trình sử dụng (Valgrind Massif).
2. **Phát hiện lỗi bộ nhớ** bằng Valgrind Memcheck: ghi ngoài mảng, dùng giá trị chưa khởi tạo, rò rỉ bộ nhớ.
3. **TODO:** viết lại chương trình đã sửa và **giải thích các dòng code thêm/sửa**.

> **Valgrind là gì?** Một "máy ảo nhỏ" chạy chương trình của mình từng lệnh một. Mỗi lần chương trình đọc
> hoặc ghi bộ nhớ, Valgrind kiểm tra xem ô nhớ đó có được cấp phát và khởi tạo chưa. Vì vậy chương trình chạy chậm
> hơn khoảng 20–50 lần, nhưng bắt được lỗi mà chạy bình thường không thấy.

## 📂 Cấu trúc

```text
tutorial_6/
├── memory_error.c     # Chương trình gốc trong đề (3 lỗi), chép nguyên văn
├── memory_step1.c     # Bước trung gian: CHỈ sửa ptr2 để chương trình không crash -> thấy được rò rỉ
├── memory_fixed.c     # Bản đã sửa hoàn chỉnh (nộp bản này), có chú thích [SỬA 1..3]
├── Makefile
├── screenshots.sh     # Chạy lại toàn bộ lệnh, vẽ ảnh vào screenshots/ và lưu log vào output/
├── screenshots/       # 01 bản gốc · 02 bước 1 · 03 bản sửa · 04 massif
└── output/            # Log Valgrind dạng text của 3 chương trình
```

## ▶️ Cách chạy

```bash
make                               # build cả 3 chương trình với -g
make check P=memory_error          # Valgrind trên bản gốc
make check P=memory_step1          # Valgrind trên bản trung gian
make check P=memory_fixed          # Valgrind trên bản đã sửa
make massif                        # đo heap theo thời gian
./screenshots.sh                   # tạo lại ảnh + log
```

Lệnh Valgrind đầy đủ như đề: `valgrind --leak-check=full --track-origins=yes --show-leak-kinds=all ./memory_error`

| Tùy chọn | Ý nghĩa |
| :--- | :--- |
| `-g` (gcc) | Nhúng thông tin debug, để Valgrind báo được **tên file và số dòng** gây lỗi |
| `--leak-check=full` | Liệt kê chi tiết từng khối bị rò rỉ và nơi nó được `malloc` |
| `--track-origins=yes` | Chỉ ra giá trị chưa khởi tạo **được sinh ra ở đâu** |
| `--show-leak-kinds=all` | Hiện mọi loại rò rỉ: definitely / indirectly / possibly lost, still reachable |

## 🔍 2. Kết quả thật trên máy (khác với output mẫu trong PDF)

Máy: Ubuntu 26.04, gcc 15.2, **Valgrind 3.26.0**, x86-64.

### 2.1. Bản gốc `memory_error`: Valgrind báo 3 lỗi rồi chương trình **crash** (ảnh `01`)

| Valgrind báo | Dòng | Giải thích |
| :--- | :---: | :--- |
| `Invalid write of size 4` … `0 bytes after a block of size 20 alloc'd` | 13 | `ptr1[5] = 42`: khối 20 byte (5 × 4) chỉ có chỉ số 0..4, nên ghi ngay **sát sau** khối |
| `Use of uninitialised value of size 8` … `created by a stack allocation` | 17 | Đọc giá trị của **chính con trỏ** `ptr2` (8 byte trên máy 64 bit), mà nó chưa được gán |
| `Invalid read of size 4` … `Address 0x0` | 17 | Giá trị rác của `ptr2` tình cờ là 0, nên `*ptr2` đọc địa chỉ NULL |
| `Process terminating with … signal 11 (SIGSEGV)` | 17 | Đọc NULL nên bị **Segmentation fault**, chương trình chết tại chỗ |

**Vì sao khác PDF?**
- PDF ghi `size 4` và `1 bytes after`, còn máy thật ghi `size 8` và `0 bytes after`.
  - PDF là output minh họa trên hệ 32 bit, nơi con trỏ chỉ 4 byte.
  - Trên x86-64, con trỏ là 8 byte, và `ptr1[5]` nằm đúng 0 byte sau khối 20 byte.
- PDF báo rò rỉ 60 byte "definitely lost". Máy thật chỉ có **20 byte "still reachable"**, vì:
  - Chương trình crash ở dòng 17, nên **dòng 23 (`malloc` cho `ptr3`) không bao giờ chạy**.
  - Lúc crash, biến `ptr1` vẫn còn giữ địa chỉ khối 20 byte, nên khối đó "vẫn với tới được" (still reachable), chưa tính là mất.
- Hành vi khi dùng con trỏ chưa khởi tạo là **undefined behavior**: tùy compiler hoặc tùy lần chạy, chương trình có thể in ra số rác hoặc crash.

### 2.2. Bước trung gian `memory_step1`: chỉ sửa `ptr2` (ảnh `02`)

Khi hết crash, chương trình chạy đến `return 0` và Valgrind thấy đủ các lỗi còn lại, **khớp với PDF**:

```
Invalid write of size 4  at main (memory_step1.c:13)          <- vẫn còn lỗi ghi ngoài mảng
20 bytes in 1 blocks are definitely lost  ... (memory_step1.c:6)   <- ptr1
40 bytes in 1 blocks are definitely lost  ... (memory_step1.c:24)  <- ptr3
LEAK SUMMARY: definitely lost: 60 bytes in 2 blocks
```

"Definitely lost" nghĩa là khối nhớ vẫn đang được cấp, nhưng **không còn con trỏ nào trỏ tới**, nên không cách nào `free` được nữa.

### 2.3. Bản đã sửa `memory_fixed`: sạch hoàn toàn (ảnh `03`)

```
total heap usage: 4 allocs, 4 frees, 4,160 bytes allocated
All heap blocks were freed -- no leaks are possible
ERROR SUMMARY: 0 errors from 0 contexts
```

Code chỉ gọi `malloc` 3 lần nhưng Valgrind đếm 4. Lần thứ 4 là **4096 byte bộ đệm stdout** mà `printf` tự xin khi
in lần đầu; glibc tự giải phóng nó lúc thoát. 4160 = 20 + 4 + 40 + 4096.

## ✏️ 3. Giải thích code đã thêm / sửa (TODO của đề)

| # | Lỗi | Code gốc | Code đã sửa | Giải thích |
| :---: | :--- | :--- | :--- | :--- |
| 1 | Ghi ngoài mảng | `ptr1[5] = 42;` | `for (i = 0; i < N1; i++) ptr1[i] = 0;`<br>`ptr1[N1 - 1] = 42;` | Mảng 5 phần tử có chỉ số **0..4**, nên phần tử cuối là `ptr1[4]`. Dùng hằng `N1` thay cho số 5 viết tay, để kích thước và chỉ số luôn khớp nhau. Khởi tạo cả mảng để về sau không đọc phải giá trị rác |
| 2 | Con trỏ chưa khởi tạo | `int *ptr2;`<br>`printf(..., *ptr2);` | `int *ptr2 = malloc(sizeof(int));`<br>`if (ptr2 == NULL) {...}`<br>`*ptr2 = 0;` | Con trỏ phải **trỏ tới vùng nhớ hợp lệ** trước khi dùng `*ptr2`. Cấp phát 1 `int`, **kiểm tra malloc thành công**, rồi **gán giá trị** trước khi đọc. Có hai bước khởi tạo: con trỏ và ô nhớ nó trỏ tới |
| 3 | Rò rỉ bộ nhớ | không có `free` | `free(ptr1); ptr1 = NULL;`<br>`free(ptr2); ptr2 = NULL;`<br>`free(ptr3); ptr3 = NULL;` | **Mỗi `malloc` phải có đúng một `free`.** Gán `NULL` sau `free` để tránh *dangling pointer*: nếu lỡ dùng lại thì lỗi lộ ra ngay, không âm thầm đọc vùng nhớ đã trả |
| + | Thoát sớm vẫn rò rỉ | — | Trong các nhánh `if (... == NULL)`, `free` các khối đã cấp **trước** `return 1` | Bản sửa trong PDF chưa xử lý trường hợp này: nếu `malloc` thứ hai thất bại thì khối thứ nhất bị rò rỉ |
| + | Kiểm tra lúc biên dịch | `gcc -g` | `gcc -g -Wall -Wextra` | Với bản gốc, gcc đã cảnh báo trước: `‘ptr2’ may be used uninitialized` và `unused variable ‘ptr3’`. Cảnh báo của compiler là lớp phát hiện lỗi **trước** cả Valgrind |

**So với bản sửa trong PDF:** bản PDF đúng ý chính, nhưng **không kiểm tra `malloc` của `ptr2` và `ptr3`**,
và không giải phóng khi thoát sớm. Bản `memory_fixed.c` bổ sung hai điểm này.

## 📏 4. Đo bộ nhớ bằng Massif (ảnh `04`)

```bash
valgrind --tool=massif --massif-out-file=massif.out ./memory_fixed
ms_print massif.out
```

Massif chụp lượng heap tại nhiều thời điểm rồi vẽ biểu đồ. Với `memory_fixed`, đỉnh heap là **≈ 4.1 KB**, gồm:
- 4 KB bộ đệm stdout của `printf`.
- 20 + 4 + 40 byte của ba khối `malloc` trong code.

Cột `extra-heap(B)` là phần **overhead** do allocator dùng để quản lý mỗi khối (header, căn lề).
Với chương trình lớn, Massif chỉ ra **hàm nào** cấp phát nhiều bộ nhớ nhất.

> Liên hệ Exercise 5 (`procmem`): `procmem` nhìn từ **ngoài** (kernel) và thấy trang nào nằm trong RAM. Massif
> nhìn từ **trong** (thư viện malloc) và thấy từng khối heap, kể cả khối nhỏ hơn 1 trang.

## ❓ 5. Câu hỏi hay gặp khi bảo vệ

- **Vì sao phải biên dịch với `-g`?** Không có `-g` thì Valgrind chỉ in địa chỉ như `0x40011C8`, không biết lỗi ở dòng nào.
- **Definitely lost và still reachable khác nhau thế nào?**
  - Definitely lost: không còn con trỏ nào trỏ tới khối, nên chắc chắn là rò rỉ.
  - Still reachable: vẫn còn con trỏ trỏ tới nhưng chưa `free`. Thường là biến toàn cục, hoặc như ở đây là do chương trình crash giữa chừng.
- **Hết chương trình thì OS cũng thu hồi bộ nhớ, sao phải `free`?** Với chương trình chạy lâu (server, daemon), rò rỉ
  cộng dồn theo thời gian cho đến khi hết RAM. Ngoài ra, thói quen này giúp Valgrind sạch lỗi, nên lỗi thật không bị lẫn.
- **Valgrind có bắt được mọi lỗi không?** Không. Nó chỉ thấy những đoạn code **thực sự chạy** trong lần chạy đó: ở bản gốc,
  dòng 23 không chạy nên rò rỉ của `ptr3` không bị phát hiện. Nó cũng không bắt tốt lỗi tràn mảng **trên stack**.
