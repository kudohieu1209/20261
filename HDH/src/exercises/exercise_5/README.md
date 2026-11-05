# Exercise 5 – Memory Paging and Segmentation

## 🎯 Đề bài

> Viết một chương trình C liệt kê tất cả các đoạn được cấp phát cho một tiến trình cho trước số hiệu PID,
> các trang bộ nhớ thuộc các vùng (text, stack, data, heap) trên một máy Linux. Đồng thời báo dung lượng
> RAM thực tế được cấp phát cho các vùng này. Hãy nhận xét về độ chính xác của kết quả thống kê mà
> chương trình báo cáo.

## 📂 Cấu trúc

```text
exercise_5/
├── procmem.c        # Chương trình chính: ./procmem <pid> [-p]
├── target.c         # Tiến trình mẫu cấp phát lượng bộ nhớ BIẾT TRƯỚC để kiểm chứng procmem
├── Makefile
├── screenshots.sh   # Chạy lại toàn bộ lệnh và vẽ ảnh kết quả vào screenshots/
├── screenshots/     # Ảnh kết quả terminal (01 → 08)
├── output/          # Kết quả chạy thật dạng text
│   ├── target.txt
│   ├── procmem_target.txt         # bảng đoạn + bản đồ trang + thống kê RAM
│   └── procmem_target_pages.txt   # chế độ -p: từng trang một
└── extra/           # Công cụ ôn lý thuyết soạn trước khi có đề (dịch địa chỉ, thay trang...)
```

## ▶️ Cách chạy

```bash
make                       # build procmem + target
make demo                  # chạy target, đo bằng procmem, lưu vào output/

./procmem <PID>            # tiến trình bất kỳ của mình
./procmem <PID> -p         # in chi tiết TỪNG trang (địa chỉ ảo, RAM/SWAP/chưa cấp, PFN)
./procmem self             # tự đo chính nó
sudo ./procmem 1           # tiến trình của user khác (vd. systemd) cần root; root còn thấy PFN thật
```

## 🖼️ Ảnh kết quả

Ảnh được sinh bởi `./screenshots.sh`. Script chạy **lệnh thật** trên máy, lấy output thật, rồi dùng
[`../tools/term2png.py`](../tools/term2png.py) vẽ thành ảnh cửa sổ terminal.

| Ảnh | Nội dung |
| :--- | :--- |
| `01_build_va_chay_target.png` | Build, chạy `target` và các giá trị dự kiến |
| `02_cac_doan_VMA.png` | [1] Toàn bộ các đoạn (VMA) của `target` |
| `03_cac_trang.png` | [2] Bản đồ trang của text / data / bss / heap / stack |
| `04_RAM_theo_vung.png` | [3] RAM thực tế (RSS / PSS / USS) theo vùng |
| `05_doi_chieu_do_chinh_xac.png` | [4] Đối chiếu smaps / pagemap / status |
| `06_tung_trang_heap.png` | Chế độ `-p`: từng trang của heap (17 trang có frame, 16 trang chưa có) |
| `07_tien_trinh_lon.png` | Đo Teams: 1.5 TB ảo nhưng ~1 GB RAM, các nguồn lệch nhau |
| `08_self_va_loi.png` | Tự đo chính mình (số liệu lệch) và các trường hợp lỗi |

## ⚙️ Chương trình lấy số liệu từ đâu

Kernel không cho chương trình user đọc thẳng bảng trang. Nó công bố thông tin qua hệ thống file ảo `/proc`:

| Nguồn | Cho biết gì | Dùng ở phần |
| :--- | :--- | :--- |
| `/proc/PID/smaps` | Mọi **đoạn (VMA)**: địa chỉ đầu-cuối, quyền `rwxp`, file ánh xạ, cùng **Rss/Pss/Private/Swap** do kernel đếm sẵn | [1], [3] |
| `/proc/PID/pagemap` | Mỗi **trang ảo** một số 64 bit: bit 63 = có trong RAM, bit 62 = đang ở swap, bit 0–54 = **số frame vật lý (PFN)** | [2], [4] |
| `/proc/PID/stat` | Ranh giới kernel ghi trong `mm_struct`: `start_code`, `end_code`, `start_data`, `end_data`, `start_brk`, `start_stack` | phân loại `bss` |
| `/proc/PID/status` | Bộ đếm tổng `VmRSS`, `RssAnon`, `RssFile`, `VmPTE`... | [4] đối chiếu |
| `/proc/PID/exe` | Đường dẫn file thực thi, để biết đoạn nào thuộc chương trình chính | phân loại |

**Cách phân loại một đoạn:**

| Vùng | Điều kiện |
| :--- | :--- |
| `text` | thuộc file thực thi, quyền có `x` |
| `rodata` | thuộc file thực thi, chỉ đọc (`r--`): ELF header, `.rodata`, RELRO |
| `data` | thuộc file thực thi, ghi được (`rw-`): `.data` |
| `bss` | đoạn ẩn danh nằm giữa `end_data` và `start_brk` |
| `heap` | `[heap]` (vùng do `brk()` quản lý) |
| `stack` | `[stack]` (stack của luồng chính) |
| `lib` / `anon` / `file` / `kernel` | thư viện `.so` / `mmap` ẩn danh / file khác / `[vdso]`, `[vvar]`, `[vsyscall]` |

**Ba chỉ số RAM:**
- **RSS** (Resident Set Size): số trang đang nằm trong RAM. Trang dùng chung với tiến trình khác vẫn tính đủ.
- **PSS** (Proportional): trang dùng chung bởi N tiến trình thì mỗi tiến trình chỉ tính 1/N.
- **USS** (Unique): chỉ tính trang riêng, tức phần RAM chắc chắn được trả lại khi tiến trình kết thúc.

## ✅ Kiểm chứng bằng `target` (đã biết trước đáp án)

| Vùng | `target.c` làm gì | Dự kiến | `procmem` báo | Đúng? |
| :--- | :--- | :--- | :--- | :--- |
| data | ghi hết mảng 64 KiB có khởi tạo | 64 KiB | 68 kB (17 trang) | ✅ (+1 trang: mảng không thẳng hàng trang, cộng biến khác của chương trình) |
| bss | mảng 4 MiB, chỉ ghi 1 MiB đầu | 4096 kB ảo / 1024 kB RAM | 4096 / **1024** kB | ✅ đúng tuyệt đối |
| heap | 64 × `malloc(1 KiB)`, `free` 32 khối | ~64 kB | 68 kB | ✅ (khối đã `free` vẫn tính) |
| anon | `malloc(8 MiB)`, ghi 2 MiB | 2048 kB, **không** nằm trong `[heap]` | 2052 kB, nhóm `anon` | ✅ |
| stack | đệ quy 32 × 16 KiB rồi trả về | ~512 kB | 540 kB | ✅ (stack không co lại) |
| — | ĐỌC thêm 1 MiB của vùng 8 MiB | pagemap ≠ smaps | lệch đúng 1020 kB | ✅ (zero page, xem mục 3 bên dưới) |

Ba nguồn tổng: `smaps` = `status` = **5636 kB**, còn `pagemap` = **6656 kB** (lệch đúng phần zero page).

## 🧐 Nhận xét về độ chính xác

**Kết luận chung:** số liệu `procmem` báo là **chính xác tại thời điểm đọc** (do chính kernel cung cấp), và
khớp với tính toán trên `target` tới từng trang. Nhưng "RAM thực tế của một vùng" **không có một con số duy
nhất đúng**: kết quả phụ thuộc vào định nghĩa (RSS/PSS/USS), vào thời điểm đo, và vào cách phân loại vùng.
Có các nguồn sai lệch sau:

1. **Không phải ảnh chụp tức thời (non-atomic snapshot).** `smaps`, `pagemap`, `status` được đọc lần lượt. Trong lúc đó tiến trình
   vẫn chạy và vẫn cấp phát bộ nhớ.
   - Với `target` (đang `pause()`), ba nguồn khớp tuyệt đối.
   - Với `./procmem self` (đo chính nó, vừa đo vừa `malloc`/`printf`), các nguồn **lệch tới ~188 kB**.
   - Với tiến trình lớn như Teams (~2700 đoạn), đọc `smaps` mất ~3 giây vì kernel phải duyệt toàn bộ bảng trang, nên số liệu cũ dần ngay trong lúc đọc.
     Thực đo: `smaps` lệch `status` tới **−13120 kB**, và 77 đoạn có RSS khác `pagemap` (ảnh `07`).
2. **RSS đếm trùng trang dùng chung.** `libc.so.6` có RSS 1824 kB nhưng PSS chỉ 42 kB, vì hàng trăm tiến trình
   cùng dùng một bản libc trong RAM. Cộng RSS của mọi tiến trình sẽ ra con số **lớn hơn RAM thật**. Muốn
   biết "tiến trình này thực sự chiếm bao nhiêu" thì nên dùng PSS. Muốn biết "giết nó thì được trả lại bao
   nhiêu" thì dùng USS.
3. **Hai nguồn của kernel không cùng định nghĩa "có trong RAM".** Khi chỉ *đọc* vùng nhớ chưa ghi, Linux
   trỏ mọi trang vào **một trang toàn số 0 dùng chung (zero page)**.
   - `pagemap` báo các trang này là *present*.
   - `smaps`/`status` không tính chúng vào RSS, vì chúng không tốn thêm RAM.
   - Thực nghiệm: lệch đúng 255 trang = 1020 kB.
4. **Kích thước ảo ≠ RAM thật (demand paging).**
   - `bss` 4096 kB ảo nhưng chỉ 1024 kB RAM: trang chưa ghi thì chưa được cấp frame.
   - Teams **giữ chỗ 1.5 TB** địa chỉ ảo (V8 sandbox) nhưng chỉ dùng khoảng 0.6–1 GB RAM.
   - Các số `VmData`, `VmStk`, `VmExe` trong `status` là kích thước **ảo**, không phải RAM.
5. **Bộ nhớ "đã cấp" chưa chắc đang được dùng.**
   - `free()` trả bộ nhớ cho allocator của glibc, không trả cho kernel, nên heap vẫn 68 kB.
   - Stack đã lên 540 kB thì không tự co lại sau khi hàm trả về.
   - Ngược lại, `malloc` lớn mà chưa ghi thì chưa hề tốn RAM.
6. **Phân loại vùng chỉ là quy ước (heuristic).**
   - `malloc` ≥ 128 KiB được glibc cấp bằng `mmap` nên **không nằm trong `[heap]`**: vùng 8 MiB bị xếp vào `anon`.
   - Teams/Chromium hoàn toàn không dùng `brk`, nên heap = 0.
   - Stack của các luồng phụ là `mmap` ẩn danh, không có tên `[stack]`.
   - Đuôi của `.bss` có thể nằm chung trang cuối với `.data`.
   - Trang RELRO tuy chỉ đọc nhưng lại là `anon`, vì đã bị copy-on-write khi dynamic linker sửa địa chỉ.
7. **Độ phân giải là 1 trang (4 KiB).** `malloc(1 KiB)` vẫn tính tròn thành trang. Nếu bật Transparent Huge Page,
   một lần chạm có thể làm RSS tăng 2 MiB.
8. **Có phần RAM không được tính.**
   - Bộ nhớ kernel dùng *cho* tiến trình: bảng trang (`VmPTE`: 60 kB với `target`, ~5 MB với Teams), kernel stack, `task_struct`.
   - Page cache của file đã đọc nhưng không `mmap`.
   - Swap không phải RAM, nên được báo riêng.
9. **`VmRSS` trong `status` là bộ đếm nhanh.** `man 5 proc` ghi rõ: vì tối ưu hiệu năng (bộ đếm theo từng CPU),
   số này có thể không chính xác, nên muốn chính xác phải dùng `smaps`/`smaps_rollup`. `procmem` lấy số chính
   từ `smaps` và chỉ dùng `status` để đối chiếu.
10. **Quyền truy cập.** Không phải root thì `pagemap` trả PFN = 0, nên không biết trang nằm ở frame vật lý nào.
    Muốn đọc tiến trình của user khác thì phải dùng `sudo`.

## 🔗 Liên hệ lý thuyết (Chương 3)

- **Segmentation:** mỗi VMA giống một *đoạn* có base (`start`), limit (`end − start`) và quyền bảo vệ
  (`rwx`). Trên x86-64, segmentation phần cứng gần như bị tắt (flat model); Linux mô phỏng "đoạn" bằng VMA.
- **Paging:** bên trong mỗi đoạn là các trang 4 KiB. `pagemap` cho thấy trực tiếp bảng trang: trang nào
  đã có frame (present), trang nào đang ở swap, trang nào chưa được cấp.
- **Demand paging, copy-on-write, zero page, phân mảnh trong:** đều quan sát được trong kết quả ở trên.
