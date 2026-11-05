# 🛠️ Tutorial 3: Lập trình Linux Kernel Module (GPU Information)

---

## 🎯 1. Mục Tiêu Bài Thực Hành

1. **Hiểu cơ chế hoạt động của Kernel Module:** Cách thức một module cấp nhân (Built-in Module) được nhúng trực tiếp vào Linux Kernel và tự động nạp khi hệ điều hành khởi động.
2. **Làm việc với PCI Subsystem trong Linux:** Sử dụng thư viện `<linux/pci.h>` để quét bus PCI, nhận diện phần cứng GPU/Display Controller.
3. **Truy xuất thông số phần cứng thiết bị:**
   * **Vendor ID & Device ID:** Nhận diện nhà sản xuất và mã chip đồ họa.
   * **Base Address Registers (BARs - DMA Base & IO Base):** Địa chỉ vùng nhớ ánh xạ và cổng I/O của thiết bị.
   * **IRQ (Interrupt Request):** Số hiệu ngắt phần cứng được gán cho thiết bị.
4. **Tích hợp vào Kernel Build System:** Cấu hình `Kconfig`, `Makefile`, biên dịch lại Linux Kernel và kiểm tra kết quả qua `dmesg`.

---

## 🛠️ 2. Từng Bước Thực Hiện Chi Tiết

```text
[Bước 1: Chuẩn bị mã nguồn C] ──> [Bước 2: Sửa Kconfig & Makefile] ──> [Bước 3: Biên dịch & Cài đặt Kernel]
                                                                                │
[Bước 5: Kiểm tra dmesg]      <── [Bước 4: Khởi động lại hệ thống] <────────────┘
```

---

### Bước 1: Chuẩn bị mã nguồn Kernel Module

Mã nguồn module hoàn chỉnh được lưu tại tệp [`gpu_info.c`](gpu_info.c). Bạn sao chép file này vào thư mục driver GPU trong cây mã nguồn Linux Kernel:

```bash
cp gpu_info.c ~/linux_lab/linux-7.2.6/drivers/gpu/
```

#### 🔑 Các API Kernel cốt lõi được sử dụng trong [`gpu_info.c`](gpu_info.c):
| Hàm / Macro | Thư viện | Mục đích sử dụng |
| :--- | :--- | :--- |
| `for_each_pci_dev(pdev)` | `<linux/pci.h>` | Duyệt qua tất cả các thiết bị kết nối trên bus PCI |
| `pci_read_config_word(...)` | `<linux/pci.h>` | Đọc Vendor ID và Device ID từ PCI Configuration Space |
| `pci_resource_start(pdev, bar)` | `<linux/pci.h>` | Lấy địa chỉ cơ sở DMA (BAR 0) và I/O Port (BAR 1) |
| `pdev->irq` | `<linux/pci.h>` | Lấy số hiệu ngắt phần cứng (IRQ) được gán cho GPU |
| `pr_info(...)` | `<linux/printk.h>` | Ghi thông tin thiết bị vào Kernel Log Buffer (`dmesg`) |

---

### Bước 2: Tích hợp vào Kernel Build System (`Kconfig` & `Makefile`)

Để kernel nhận diện và biên dịch module thành dạng **Built-in (`obj-y`)**, cần chỉnh sửa 2 file cấu hình:

1. **Chỉnh sửa file `drivers/gpu/Makefile`:**
   Thêm dòng sau vào cuối file:
   ```makefile
   obj-y += gpu_info.o
   ```

2. **Chỉnh sửa file `drivers/gpu/Kconfig`:**
   Thêm khối cấu hình menu cho module:
   ```kconfig
   config GPU_INFO
       bool "GPU Information module"
       default y
       help
         A simple kernel module to retrieve and report GPU PCI details.
   ```

---

### Bước 3: Cấu hình và Biên dịch Kernel

Mở terminal trong thư mục nguồn kernel (`~/linux_lab/linux-7.2.6`):

1. **Kiểm tra/Bật cấu hình:**
   ```bash
   make menuconfig
   ```
   *Đảm bảo tùy chọn `GPU Information module` đã được chọn dạng `[*] Built-in` (tương ứng với dòng `CONFIG_GPU_INFO=y` trong file `.config`).*

2. **Biên dịch kernel (tận dụng toàn bộ nhân CPU):**
   ```bash
   make -j$(nproc)
   ```
   *Sau khi build xong, file object `drivers/gpu/gpu_info.o` sẽ được tạo ra và liên kết trực tiếp vào ảnh `vmlinux`.*

3. **Cài đặt Kernel và các Module:**
   ```bash
   sudo make modules_install install
   ```

---

### Bước 4: Khởi động lại hệ thống

Khởi động lại máy để nạp kernel mới:
```bash
sudo reboot
```

Sau khi máy khởi động lại, kiểm tra xem máy đã chạy đúng phiên bản kernel mới hay chưa:
```bash
uname -r
# Kết quả mong muốn: 7.2.6
```

---

### Bước 5: Kiểm tra kết quả trong Kernel Log (`dmesg`)

Do module được biên dịch dưới dạng **Built-in**, hàm `gpu_info_init()` sẽ tự động thực thi ngay trong quá trình boot của Kernel.

#### 📌 Lệnh kiểm tra tối ưu nhất:
```bash
sudo dmesg | grep -A 15 "Loading GPU Info"
```

* **Giải thích cờ `-A 15`:** Lấy thêm **15 dòng tiếp theo** phía sau dòng tìm thấy (`Loading GPU Info...`) để hiển thị toàn bộ thông tin của cả 2 GPU mà không bị lẫn với các log khác của hệ điều hành.

---

## 📊 3. Kết Quả Thực Nghiệm & Phân Tích

### Output thực tế trên Terminal:

```text
[    0.870145] Loading GPU Info Module...
[    0.870157] GPU Found:
[    0.870158] Vendor ID: 0x10de
[    0.870159] Device ID: 0x28e0
[    0.870161] DMA Base: 0xc0000000
[    0.870162] IO Base: 0x7a00000000
[    0.870163] IRQ: 255
[    0.870175] GPU Found:
[    0.870176] Vendor ID: 0x1002
[    0.870177] Device ID: 0x1681
[    0.870178] DMA Base: 0x7c10000000
[    0.870179] IO Base: 0x0
[    0.870180] IRQ: 255
[    0.875163] loop: module loaded
[    0.875527] tun: Universal TUN/TAP device driver, 1.6
[    0.875586] PPP generic driver version 2.4.2
```

---

### 🔍 Bảng Phân Tích Chi Tiết Thông Số Phần Cứng

Hệ thống laptop Lenovo Legion 5 sở hữu kiến trúc **Dual-GPU** (Hybrid Graphics) và module đã quét được chính xác 2 thiết bị:

| Thông số | GPU 1 (Card đồ họa rời dGPU) | GPU 2 (Card tích hợp iGPU) | Ý nghĩa kỹ thuật |
| :--- | :--- | :--- | :--- |
| **Tên thiết bị** | **NVIDIA GeForce RTX 4060 Mobile** | **AMD Radeon 680M** | Card đồ họa thực tế trên máy |
| **Vendor ID** | `0x10de` | `0x1002` | `0x10de`: NVIDIA Corp.<br>`0x1002`: AMD/ATI |
| **Device ID** | `0x28e0` | `0x1681` | Mã định danh model chip xử lý đồ họa (AD107M & Rembrandt) |
| **DMA Base (BAR 0)** | `0xc0000000` | `0x7c10000000` | Địa chỉ vùng nhớ MMIO cơ sở phục vụ truyền dữ liệu Direct Memory Access |
| **IO Base (BAR 1)** | `0x7a00000000` | `0x0` | Không gian cổng vào/ra (I/O Port Address) |
| **IRQ** | `255` | `255` | Mã ngắt tạm thời tại thời điểm Kernel init trước khi MSI/MSI-X kích hoạt |

---

## 🏆 4. Kết Luận

* Hoàn thành trọn vẹn yêu cầu của bài **Tutorial 3 – Kernel Programming**.
* Module đã được cấu hình và liên kết dạng Built-in thành công vào nhân Linux 7.2.6.
* Nhận diện và truy xuất chính xác thông tin phần cứng của cả 2 GPU (NVIDIA & AMD) trên máy Lenovo Legion 5.
