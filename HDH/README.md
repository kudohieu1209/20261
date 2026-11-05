# Hệ Điều Hành (Operating Systems)

Kho lưu trữ tài liệu, ghi chú lý thuyết và mã nguồn thực hành môn **Hệ điều hành** tại **Đại học Bách khoa Hà Nội (HUST)** - Học kỳ **2026.1**.

* **Sinh viên:** Mai Duy Hiếu
* **MSSV:** 20223967
* **Môi trường thực hành:** Ubuntu Linux (Kernel 7.2.6 Custom Build)

---

## 📂 Cấu trúc Repository

```text
.
├── README.md                                # Tài liệu tổng quan và hướng dẫn repo
├── ref/                                     # Tài liệu học tập và tham khảo
│   ├── book/                                # Sách chuyên khảo
│   │   └── Zhao Jiong - Linux Kernel source code - Heavily Commented.pdf
│   ├── note/                                # Ghi chép cá nhân
│   │   └── note.md                          # Ghi chú chi tiết các chương
│   ├── slides/                              # Slide bài giảng môn học
│   │   ├── chapter0.pdf                     # Giới thiệu chung
│   │   └── Chapter1_Introduction.pdf        # Chương 1: Tổng quan Hệ điều hành
│   └── teams/                               # Ảnh chụp / Hướng dẫn từ lớp học
│       ├── install_linux.png                # Hướng dẫn cài đặt môi trường Linux
│       ├── install_kernel.png               # Hướng dẫn biên dịch & cài đặt Linux Kernel
│       └── tutorial_3.png                   # Yêu cầu thực hành Tutorial 3
└── src/                                     # Mã nguồn và bài tập lập trình
    ├── exercises/                           # Bài tập thực hành theo tuần
    │   ├── tutorial_3/                      # Tutorial 3: Kernel Programming (GPU Information)
    │   ├── tutorial_4/                      # Tutorial 4: Xv6 Operating System trên QEMU RISC-V
    │   ├── tutorial_5/                      # Tutorial 5A: UEFI Boot Loader (gnu-efi + QEMU/OVMF)
    │   ├── tutorial_5b/                     # Tutorial 5B: Boot Loader trên máy thật (header + menu mũi tên)
    │   ├── tutorial_6/                      # Tutorial 6: Memory profiling với Valgrind (Memcheck + Massif)
    │   ├── exercise_4/                      # Exercise 4: Process & Tasks – Scheduling (mô phỏng + Linux + xv6)
    │   ├── exercise_5/                      # Exercise 5: procmem – liệt kê đoạn/trang/RAM của tiến trình theo PID
    │   └── process_music/                   # Bài tập Quản lý tiến trình (fork - exec - wait)
    │       ├── process_music.c              # C: Tiến trình con phát nhạc, cha phát bảng tin
    │       ├── process_music.py             # Python: os.fork, os.execvp, os.waitpid
    │       ├── Makefile                     # Script biên dịch
    │       └── README.md                    # Hướng dẫn chi tiết
    └── subproject/                          # Dự án bài tập lớn / Mở rộng
```

---

## 📚 Danh mục Tài liệu & Bài giảng

| Danh mục | Tệp / Đường dẫn | Mô tả nội dung |
| :--- | :--- | :--- |
| **Ghi chú** | [`ref/note/note.md`](ref/note/note.md) | Tổng hợp kiến thức, định nghĩa và câu hỏi ôn tập |
| **Slide** | [`ref/slides/chapter0.pdf`](ref/slides/chapter0.pdf) | Slide mở đầu: Nội dung môn học, cách đánh giá |
| **Slide** | [`ref/slides/Chapter1_Introduction.pdf`](ref/slides/Chapter1_Introduction.pdf) | Slide Chương 1: Kiến trúc OS, System Calls, Interrupts |
| **Sách** | `ref/book/Zhao Jiong - ...pdf` | Linux Kernel 0.12 source code kèm chú giải chi tiết |
| **Hướng dẫn** | [`ref/teams/install_linux.png`](ref/teams/install_linux.png) | Ghi chú các bước cài đặt hệ điều hành Linux |
| **Hướng dẫn** | [`ref/teams/install_kernel.png`](ref/teams/install_kernel.png) | Các bước cấu hình, build và cài đặt Custom Kernel |

---

## 🧠 Tóm tắt Kiến thức Cốt lõi

### 1. Kiến trúc phân quyền (Dual-Mode Operation)
* **User Mode (Chế độ người dùng):** Ứng dụng chạy với quyền hạn chế, không được thực thi các lệnh đặc quyền (privileged instructions) và không được can thiệp trực tiếp vào phần cứng hoặc vùng nhớ hệ thống.
* **Kernel Mode (Chế độ nhân / Supervisor Mode):** Có toàn quyền truy cập tài nguyên phần cứng, quản lý bộ nhớ và thực thi tất cả các tập lệnh của CPU.

### 2. Cơ chế Ngắt (Interrupt) & Bẫy lỗi (Trap)
* **Interrupt (Ngắt cứng):** Tín hiệu bất đồng bộ sinh ra từ các thiết bị ngoại vi (bàn phím, chuột, card mạng, đĩa cứng) gửi đến CPU để yêu cầu phục vụ.
* **Trap / Exception (Bẫy / Ngắt mềm):** Sự kiện đồng bộ phát sinh ngay trong luồng thực thi của tiến trình (ví dụ: chia cho 0, truy cập bộ nhớ bất hợp pháp - Segfault) hoặc do gọi hàm hệ thống (**System Call** qua `syscall` / `int 0x80`).

### 3. Tiến trình & Không gian Bộ nhớ (Process & Memory Layout)
Tiến trình là một chương trình đang trong trạng thái thực thi trong bộ nhớ, bao gồm:
* **Mã nhị phân thực thi (`.text`):** Chứa các lệnh máy.
* **Dữ liệu (`.data`, `.bss`):** Các biến toàn cục và tĩnh (đã/chưa khởi tạo).
* **Vùng nhớ Heap:** Cấp phát động trong runtime (`malloc()`, `new`).
* **Vùng nhớ Stack:** Lưu biến cục bộ, địa chỉ trả về của hàm và ngữ cảnh gọi hàm.
* **PCB (Process Control Block) & Context:** Ngữ cảnh thanh ghi CPU, trạng thái tiến trình (Ready, Running, Blocked...), PID, bảng định danh tài nguyên.

---

## 💻 Thực hành & Lập trình Kernel

### 🛠️ Tutorial 3: Lập trình Linux Kernel Module (GPU Information)

Module cho phép nhân Linux quét hệ thống bus PCI khi khởi động và in ra thông tin chi tiết về các GPU/Display Controllers có trên máy tính.

* **Source code:** [`src/exercises/tutorial_3/gpu_info.c`](src/exercises/tutorial_3/gpu_info.c)
* **Tài liệu hướng dẫn:** [`src/exercises/tutorial_3/tutorial3_guide.md`](src/exercises/tutorial_3/tutorial3_guide.md)

#### Quy trình biên dịch dạng Built-in Module:
1. Đặt `gpu_info.c` vào thư mục `drivers/gpu/` của cây mã nguồn kernel.
2. Thêm vào `drivers/gpu/Makefile`:
   ```makefile
   obj-y += gpu_info.o
   ```
3. Khai báo trong `drivers/gpu/Kconfig`:
   ```kconfig
   config GPU_INFO
       bool "GPU Information module"
       default y
   ```
4. Biên dịch và cài đặt Kernel:
   ```bash
   make menuconfig
   make -j$(nproc)
   sudo make modules_install install
   sudo reboot
   ```
5. Kiểm tra thông tin GPU sau khi khởi động:
   ```bash
   sudo dmesg | grep -A 15 "Loading GPU Info Module"
   ```

#### Kết quả thực nghiệm trên máy Lenovo Legion 5:
Nhận diện chính xác 2 GPU trên hệ thống:
1. **dGPU (NVIDIA GeForce RTX 4060 Mobile):**
   * Vendor ID: `0x10de` | Device ID: `0x28e0`
   * DMA Base: `0xc0000000` | IO Base: `0x7a00000000` | IRQ: `255`
2. **iGPU (AMD Radeon 680M):**
   * Vendor ID: `0x1002` | Device ID: `0x1681`
   * DMA Base: `0x7c10000000` | IO Base: `0x0` | IRQ: `255`

### 🛠️ Tutorial 5A: Xây dựng UEFI Boot Loader

Bootloader UEFI viết bằng C (gnu-efi), quét các ổ USB/NVMe/SATA để tìm Windows/Linux và hiện menu chọn OS. Phần TODO cho phép tìm kiếm file `.efi` trên mọi ổ và thêm boot entry, lưu vào NVRAM. Chạy thử trong QEMU + OVMF.

* **Source code:** [`src/exercises/tutorial_5/main.c`](src/exercises/tutorial_5/main.c) (code gốc trong PDF: [`original/main.c`](src/exercises/tutorial_5/original/main.c))
* **Tài liệu hướng dẫn:** [`src/exercises/tutorial_5/tutorial5_guide.md`](src/exercises/tutorial_5/tutorial5_guide.md)
* **Chạy:** `cd src/exercises/tutorial_5 && make run`

---

## 🎯 Mục tiêu & Kế hoạch học tập

* [x] Cài đặt môi trường Linux và biên dịch Custom Kernel thành công.
* [x] Hoàn thành Tutorial 3 - Lập trình Kernel Module quét phần cứng GPU.
* [x] Hoàn thành Tutorial 5A - Xây dựng UEFI Boot Loader (kèm phần TODO tìm/thêm boot entry).
* [ ] Nắm vững cơ chế quản lý tiến trình, IPC (Inter-Process Communication) và điều độ CPU.
* [ ] Nắm vững cơ chế quản lý bộ nhớ ảo (Paging, Segmentation, Page Replacement).
* [ ] Hoàn thành các bài tập lớn và dự án môn học.
