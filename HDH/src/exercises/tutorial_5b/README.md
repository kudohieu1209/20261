# 🛠️ Tutorial 5B: Boot Loader Chạy Trên Máy Thật (UEFI)

**Sinh viên:** Mai Duy Hiếu - 20223967

---

## 🎯 1. Mục Tiêu

1. Đưa bootloader UEFI của PDF lên **máy thật** (trên máy này là ổ NVMe trong máy, thay cho USB).
2. **Exercise 1:** header có tên + MSSV, căn giữa, có mặt trên mọi màn hình.
3. **Exercise 2:** menu chọn bằng phím mũi tên, dòng đang chọn đảo màu, hiện device path của ổ.

---

## 📂 2. Cấu Trúc Thư Mục

```text
tutorial_5b/
├── main.c             # Bootloader (code PDF + sửa lỗi + Exercise 1, 2)
├── fake_os.c          # "OS giả": in đường dẫn của chính nó rồi quay lại menu
├── Makefile           # Build + QEMU có 3 ổ USB / NVMe / SATA (20 entry)
├── install-esp.sh     # Cài lên ổ cứng trong máy (không cần USB)
├── uninstall-esp.sh   # Gỡ sạch những gì install-esp.sh đã cài
└── screenshots/       # Ảnh chụp trong QEMU
```

---

## 🚀 3. Chạy Thử Trong QEMU

```bash
make          # build main.efi, fake_os.efi
make run      # máy ảo: USB (17 entry) + NVMe (fedora) + SATA (debian, arch) = 20 entry
```

| Phím | Tác dụng |
| :--- | :--- |
| `↑` `↓` | Di chuyển, **vòng quanh** (mục đầu ↔ mục cuối) |
| `Home` `End` | Nhảy về mục đầu / mục cuối |
| `Enter` | Boot mục đang chọn |
| `1`..`9`, `10`..`20` | Boot theo số. Có từ 10 mục trở lên thì sau chữ số đầu chờ 1 giây để gõ chữ số thứ hai (`1` `7` = mục 17) |
| `R` | Quét lại các ổ (vd vừa cắm USB) |
| `M` | Đổi text mode (80x25, 100x31, 128x40, 160x42…) để thử header căn giữa |
| `Esc` | Trả quyền về firmware |

---

## 💽 4. Cài Lên Ổ Cứng Trong Máy (Không Có USB)

Máy: Lenovo, UEFI, **Secure Boot đã tắt**, Windows + Ubuntu chung ổ NVMe, ESP = `/dev/nvme0n1p1` (`/boot/efi`).

```bash
make
sudo ./install-esp.sh --tests --next   # chép vào \EFI\HUST\ + 15 thư mục test, boot 1 lần
reboot                                 # hoặc: reboot rồi bấm F12 ở logo Lenovo, chọn "HUST 5B Bootloader"
sudo ./uninstall-esp.sh                # quay video xong thì gỡ
```

Script **không format gì**, chỉ ghi vào thư mục mới `\EFI\HUST` và `\EFI\testNN`. Boot entry được tạo bằng `efibootmgr --create-only`, **không đổi BootOrder**, nên máy vẫn boot Ubuntu như cũ. `--next` (BootNext) chỉ có tác dụng ở đúng lần khởi động kế tiếp.

> ⚠️ Không làm theo bước `mkfs.vfat` của PDF trên ổ cứng: ESP chứa file boot của cả Windows lẫn Ubuntu.
> Nếu sau này bật Secure Boot thì bootloader sẽ bị chặn (`LoadImage: Security Violation`) vì file chưa được ký.

---

## ✅ 5. Exercise 1: Header Định Danh

* Mọi lần xoá màn hình đều đi qua `NewScreen()` = `ClearScreen` + `DrawHeader()`, nên header có ở màn hình quét ổ, đếm ngược, menu, boot, báo lỗi.
* `DrawHeader()` gọi `QueryMode(ConOut, ConOut->Mode->Mode, &Cols, &Rows)` **mỗi lần vẽ**, không hard-code 80 cột. Lý do: phím `M`, hoặc chương trình vừa được boot rồi thoát ra, có thể đã đổi text mode.
* Căn giữa: tô cả dòng bằng `SetAttribute(EFI_YELLOW | EFI_BACKGROUND_BLUE)`, rồi `SetCursorPosition((Cols - Len) / 2, Row)` để in chữ. Xong thì `SetAttribute` trả lại màu thường.
* Dòng 2 của header in luôn `text mode CxR`, nên ảnh chụp màn hình thật cho biết luôn Cols × Rows.

| Máy | Cols × Rows |
| :--- | :--- |
| QEMU/OVMF (mặc định, cửa sổ 1280x800) | 160 × 42 (phím M: 80×25, 100×31, 128×40) |
| Laptop Lenovo (máy thật) | **320 × 75** |
| Máy thứ hai (nếu có) | *điền theo ảnh chụp* |

---

## ✅ 6. Exercise 2: Menu Phím Mũi Tên

* **Chỉ vẽ lại 2 dòng:** `Select(New)` gọi `DrawItem(Old)` (về màu thường) và `DrawItem(New)` (màu đảo `EFI_BLACK | EFI_BACKGROUND_LIGHTGRAY`). Mỗi dòng được định vị bằng `SetCursorPosition(0, LIST_TOP + i - Top)`. Dòng device path ở dưới cũng được cập nhật. Chỉ khi phải cuộn trang (vd màn 80x25 hiện được 19/20 mục) mới vẽ lại cả danh sách.
* **Đủ 20 mục:** dùng mũi tên, cuộn trang, và phím số 2 chữ số.
* **Device path:** mỗi entry lưu `DevicePathToStr(DevicePathFromHandle(Handle))` lúc quét. Chuỗi này do gnu-efi cấp phát nên `FreePool` khi quét lại. Còn device path trả về từ `DevicePathFromHandle` thuộc về firmware nên không được free.

### Nhận biết NVMe / SATA / USB từ device path

Loại ổ nằm ở **node Messaging** (type 3) đứng sau node `Pci(...)` của bộ điều khiển. Code đọc `DevicePathSubType` của node này trong `DiskKind()`.

| Loại | Ví dụ (QEMU, đọc từ màn hình) | Node quyết định |
| :--- | :--- | :--- |
| USB | `PciRoot(0)/Pci(0x3,0x0)/Usb(0x0,0x0)` | `Usb(port, interface)`, subtype 5 |
| SATA | `PciRoot(0)/Pci(0x5,0x0)/Sata(0x0,0xFFFF,0x0)` | `Sata(port, multiplier, LUN)`, subtype 18 |
| NVMe | `PciRoot(0)/Pci(0x4,0x0)/Path(131,23,0x01000000...)` | `NVMe(namespace, EUI-64)`, subtype **0x17 = 23** |

Trên laptop Lenovo (máy thật), Windows Boot Manager nằm trên ESP của ổ NVMe:

```text
PciRoot(0)/Pci(0x2,0x4)/Pci(0x0,0x0)/Path(131,23,0x01000000ACE42E003A7DA16084012C00)/HD(1,GPT,7DF0568A-B3D1-4DED-AA45-A8E0755195D1)
```

`Pci(0x2,0x4)` là cổng PCIe của CPU, `Pci(0x0,0x0)` là bộ điều khiển NVMe, `Path(131,23,...)` là node NVMe: namespace 1 cùng EUI-64 của ổ. `HD(1,GPT,7DF0568A-...)` là phân vùng 1 (ESP), GUID khớp với `efibootmgr -v`.

gnu-efi 4.0 không biết tên node NVMe, nên in dạng chung `Path(type,subtype,dữ liệu)`: 131 = 0x83 là type Messaging (3), 23 = 0x17 là NVMe Namespace. Ổ ảo trong QEMU không chia phân vùng nên không có node `HD`.

---

## 🐞 7. Lỗi Của Code PDF Đã Sửa

| Lỗi | Sửa |
| :--- | :--- |
| `WaitForEvent(..., NULL)`: Index không được NULL theo spec | truyền `&Index` |
| Vòng đọc thư mục `\EFI` chỉ dừng khi `EFI_NOT_FOUND` | dừng khi gặp mọi lỗi |
| Thêm mục Windows không kiểm tra `MAX_ENTRIES` | kiểm tra trong `AddEntry()` |
| Watchdog 5 phút của firmware tự reset máy khi ngồi ở menu | `SetWatchdogTimer(0, ...)` |
| Firmware "fast boot" chỉ kết nối ổ boot nên không thấy ổ khác | `ConnectController` cho mọi handle |
| Makefile PDF: `objcopy` không có target `efi-app-x86_64`; thiếu `.rodata` nên màn hình trống | `-O pei-x86-64 --subsystem efi-app` + `-j .rodata` |

---

## 🖼️ 8. Ảnh Chụp (`screenshots/`, QEMU)

| File | Nội dung |
| :--- | :--- |
| `01_countdown.png` | Đếm ngược, có header |
| `02_menu_20_entries.png` | Menu 20 entry trên 3 loại ổ |
| `03`, `04` | `↑` ở mục 1 vòng xuống mục 20, `↓` vòng lại mục 1 |
| `05_key_1_7_boot_fake_os.png` | Gõ `1` `7` boot mục 17 (`\EFI\test15\grubx64.efi`) |
| `06_returned.png` | OS giả thoát, quay lại bootloader |
| `07_mode_80x25_scroll.png` | 80x25: danh sách cuộn `[1-19 of 20]` |
| `08`, `09` | 100x31 và 160x42: header vẫn căn giữa |
| `real_01_countdown_lenovo_320x75.jpg` | **Máy thật** (Lenovo): header tên + MSSV, text mode 320x75, tìm được 17 entry |

**Cần tự làm trên máy thật:** ảnh chụp màn hình có tên + MSSV (Exercise 1), và video điều hướng menu rồi boot vào Ubuntu/Windows thật (Exercise 2).
