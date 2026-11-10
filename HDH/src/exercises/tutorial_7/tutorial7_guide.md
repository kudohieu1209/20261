# 🛠️ Tutorial 7: Driver Development (chuẩn bị môi trường)

> **Trạng thái:** thầy mới demo "build a kernel module as driver for Wi-Fi interface", **chưa có đề chi tiết**.
> Thư mục này chỉ chuẩn bị sẵn môi trường + 2 module mẫu đã chạy được. Có đề thì bổ sung tiếp.

## 🎯 1. Kernel module là gì?

- Một đoạn code C được biên dịch thành file **`.ko`**, **nạp vào kernel đang chạy** mà không cần build lại kernel.
- Chạy ở **kernel space**: không có `printf`, `malloc`, `libc`. Dùng `pr_info()/printk()`, `kmalloc()`...
- Lỗi trong module có thể làm **treo cả máy** (không như lỗi chương trình thường chỉ crash tiến trình).
- **Driver** thường được viết dưới dạng module, ví dụ card Wi-Fi của máy này dùng module `mt7921e`.

Các lệnh cơ bản:

| Lệnh | Ý nghĩa |
| :--- | :--- |
| `sudo insmod x.ko [tham_so=gia_tri]` | Nạp module từ file |
| `sudo rmmod x` | Gỡ module |
| `lsmod` | Liệt kê module đang nạp |
| `modinfo x.ko` | Xem thông tin module (license, tham số, vermagic) |
| `sudo dmesg \| tail` | Xem log kernel (nơi `pr_info` in ra) |
| `sudo modprobe x` | Nạp module **có sẵn trong kernel** kèm các module phụ thuộc |

## 💻 2. Môi trường trên máy (đã kiểm tra 10/11/2026)

| Thành phần | Trạng thái |
| :--- | :--- |
| OS | Ubuntu 26.04.1 LTS |
| Kernel đang chạy | **7.2.6 tự build** (`~/linux_lab/linux-7.2.6`, bản #3, build 22/09) |
| Headers / cây build | `/lib/modules/7.2.6/build` → `~/linux_lab/linux-7.2.6` ✅ (có `.config`, `Module.symvers`) |
| Compiler | gcc 15.2.0, **cùng bản** gcc đã build kernel ✅ |
| Secure Boot | **Tắt** ✅, nên nạp được module không ký |
| Ký module | `CONFIG_MODULE_SIG=y` nhưng **không** `MODULE_SIG_FORCE`, nên module không ký vẫn nạp được (kernel chỉ đánh dấu "tainted") |
| Card Wi-Fi | MediaTek **MT7921** (`wlp2s0`), driver `mt7921e`, dùng stack `mac80211` + `cfg80211` |
| Wi-Fi ảo có sẵn | `mac80211_hwsim`, `virt_wifi` đều là module (`=m`) ✅ |
| Công cụ | `make`, `iw`, `ip`, `rfkill`, `nmcli`, `qemu-system-x86_64` ✅ |

> ⚠️ Kernel tự build nên **phải build module bằng đúng cây `~/linux_lab/linux-7.2.6`**. Không cài gói
> `linux-headers-...` của Ubuntu vì nó không khớp kernel đang chạy. Nếu sau này boot lại kernel gốc của Ubuntu thì
> cần `sudo apt install linux-headers-$(uname -r)`.

## 📂 3. Cấu trúc

```text
tutorial_7/
├── hello.c           # Module đơn giản nhất: in log khi nạp/gỡ, có tham số name=
├── wifi_info.c       # Module chỉ đọc: liệt kê network interface, đánh dấu interface Wi-Fi
├── Makefile          # Build out-of-tree bằng Kbuild + target test
└── tutorial7_guide.md
```

## ▶️ 4. Cách chạy

```bash
make                              # build hello.ko và wifi_info.ko
make test M_NAME=hello            # nạp -> lsmod -> gỡ -> in log
make test M_NAME=wifi_info
sudo insmod hello.ko name=Hieu    # truyền tham số
cat /sys/module/hello/parameters/name
sudo rmmod hello
make clean
```

Makefile chỉ có 1 dòng quan trọng là `obj-m += hello.o`, còn lại là gọi Makefile của kernel:
`make -C <cây kernel> M=<thư mục này> modules`.

### Kết quả thật

```
hello: xin chao Hieu, module da duoc nap
hello: tam biet Hieu, module da duoc go

wifi_info: === danh sach network interface ===
wifi_info: lo           other driver=(ao / khong co) mac=00:00:00:00:00:00 mtu=65536
wifi_info: eno1         other driver=r8169 mac=74:5d:22:a0:4c:94 mtu=1500
wifi_info: wlp2s0       WIFI  driver=mt7921e wiphy=phy0 mac=14:ac:60:86:fd:0d mtu=1500
wifi_info: tailscale0   other driver=(ao / khong co) mac=00:00:00:00:00:00 mtu=1280
```

`wifi_info` nhận ra interface Wi-Fi nhờ trường `dev->ieee80211_ptr`: trường này chỉ khác `NULL` khi interface được
`cfg80211` (tầng cấu hình Wi-Fi của Linux) quản lý.

## 📡 5. Driver Wi-Fi trong Linux gồm những tầng nào?

```text
  user space :  iw / nmcli / wpa_supplicant
                     │  (nl80211 qua netlink)
  kernel     :  cfg80211      ← cấu hình Wi-Fi chung (scan, connect, wiphy)
                     │
                mac80211      ← xử lý frame 802.11 bằng phần mềm (SoftMAC)
                     │
                driver        ← mt7921e, mac80211_hwsim (ảo), virt_wifi (ảo)...
                     │
  phần cứng  :  card Wi-Fi
```

- `struct net_device`: interface mạng mà `ip link` nhìn thấy (ví dụ `wlp2s0`).
- `struct wiphy`: đại diện cho **thiết bị radio vật lý** (`phy0`), xem bằng `iw phy`.
- `struct wireless_dev`: nối `net_device` với `wiphy`.
- Driver "FullMAC" chỉ cần nói chuyện với `cfg80211`. Driver "SoftMAC" (như MT7921) đi qua `mac80211`.

## 📚 6. Mã nguồn tham khảo có sẵn trên máy

Bài lab có thể sẽ yêu cầu làm một **interface Wi-Fi ảo**, vì không ai viết driver phần cứng thật từ đầu trong 1 buổi.
Hai driver ảo dưới đây là mẫu tốt nhất:

| File | Ghi chú |
| :--- | :--- |
| `~/linux_lab/linux-7.2.6/drivers/net/wireless/virtual/virt_wifi.c` | ~590 dòng, chỉ dùng `cfg80211`. Tạo interface Wi-Fi giả bọc lên 1 interface có dây. **Dễ đọc nhất.** |
| `~/linux_lab/linux-7.2.6/drivers/net/wireless/virtual/mac80211_hwsim_main.c` | Giả lập nhiều radio qua `mac80211`, dùng để test hostapd / wpa_supplicant. Lớn và phức tạp. |

Thử nhanh driver ảo có sẵn (chưa chạy trên máy, NetworkManager có thể tự nhận các interface mới):

```bash
sudo modprobe mac80211_hwsim radios=2   # tạo 2 radio ảo, ví dụ wlan0, wlan1
iw dev
sudo modprobe -r mac80211_hwsim         # gỡ
```

## 🧯 7. Lưu ý an toàn

- Thử module tự viết (nhất là module **đăng ký thiết bị**) thì nên chạy trong **máy ảo QEMU** trước. Lỗi `NULL` trong
  kernel có thể làm treo máy thật.
- Luôn lưu bài trước khi `insmod` module mới.
- Gỡ không được (`rmmod: ERROR: Module x is in use`) thì xem `lsmod`, cột "Used by".
- `cat /proc/sys/kernel/tainted` khác 0 sau khi nạp module tự viết là bình thường (flag `O` = out-of-tree, `E` = chưa ký).

## ✅ 8. Việc còn lại khi có đề chi tiết

- [ ] Đọc đề / slide demo của thầy, ghi yêu cầu cụ thể vào đây.
- [ ] Viết driver theo đề (dựa trên `virt_wifi.c` nếu là interface ảo).
- [ ] Chụp ảnh kết quả, viết báo cáo như Tutorial 6.
