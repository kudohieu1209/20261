# Exercise 4 – Process and Tasks (Scheduling)

> **Trạng thái:** thầy mới đăng tiêu đề ("Scheduling is the topic..."), **chưa có đề chi tiết**.
> Thư mục này là môi trường chuẩn bị sẵn để khi có đề chỉ cần viết phần chính.

## 📂 Cấu trúc

```text
exercise_4/
├── Makefile
├── sched_sim.c          # Mô phỏng FCFS, SJF, SRTF, Priority (2 kiểu), Round Robin
├── sample.txt           # Ví dụ sách Silberschatz (SRTF -> Avg WT = 6.5)
├── sample_rr.txt        # Ví dụ RR trong sách (q = 4 -> Avg WT = 5.67)
├── linux_sched_demo.c   # Quan sát scheduler THẬT của Linux: nice / SCHED_FIFO / SCHED_RR
└── xv6-riscv/           # Bản xv6 sạch (commit 06aad25, nhánh exercise4) để sửa scheduler
```

## ▶️ Cách chạy

```bash
make                                   # build sched_sim + linux_sched_demo

./sched_sim srtf sample.txt            # Gantt + bảng Start/Finish/TAT/WT/RT
./sched_sim rr sample_rr.txt 4         # Round Robin, quantum = 4
./sched_sim all sample.txt 3           # so sánh mọi thuật toán

./linux_sched_demo nice 0 5 10         # 3 tiến trình cùng tranh CPU 0 với nice 0/5/10
sudo ./linux_sched_demo rr 10 10       # SCHED_RR (real-time, cần root)
sudo ./linux_sched_demo fifo 10 20     # SCHED_FIFO: priority 20 chiếm trọn CPU
DURATION=5 CPU=3 ./linux_sched_demo nice 0 0   # đổi thời gian đo / CPU ghim

make xv6                               # boot xv6 trong QEMU (thoát: Ctrl-A rồi x)
```

File input của `sched_sim`: mỗi dòng `Tên Arrival Burst [Priority]`, `#` là chú thích.
Priority: **số nhỏ = ưu tiên cao**.

## ✅ Đã kiểm tra

| Lệnh | Kết quả | Đối chiếu |
| :--- | :--- | :--- |
| `sched_sim srtf sample.txt` | Avg WT = 6.50 | Đúng sách Silberschatz |
| `sched_sim rr sample_rr.txt 4` | Avg WT = 5.67 | Đúng sách (17/3) |
| `linux_sched_demo nice 0 5 10` | 69.8% / 22.6% / 7.5% CPU | Trọng số nice 1024 : 335 : 110 → 69.6 / 22.8 / 7.5 |
| `xv6-riscv`: `make qemu` → `ls` | boot OK | |

## 🧠 Kiến thức nền (nhắc nhanh)

| Chỉ số | Công thức |
| :--- | :--- |
| Turnaround time (TAT) | Finish − Arrival |
| Waiting time (WT) | TAT − Burst |
| Response time (RT) | Lần chạy đầu − Arrival |

* **Non-preemptive** (FCFS, SJF, PRIO): đã chạy thì chạy đến hết burst.
* **Preemptive** (SRTF, PPRIO, RR): có thể bị giành CPU khi có tiến trình "tốt hơn" đến, hoặc khi hết lượng tử.
* **RR**: tiến trình mới đến được xếp vào hàng đợi **trước** tiến trình vừa hết lượng tử (quy ước của sách).
* **Linux**: `SCHED_OTHER` (EEVDF, trước 6.6 là CFS) chia CPU theo trọng số của nice, mỗi mức nice chênh nhau khoảng 1.25 lần.
  `SCHED_FIFO`/`SCHED_RR` là real-time, luôn được chạy trước mọi tiến trình `SCHED_OTHER`.

## 🔧 Nếu đề yêu cầu sửa scheduler của xv6

| Việc | Ở đâu |
| :--- | :--- |
| Vòng lặp chọn tiến trình (hiện là RR đơn giản) | `kernel/proc.c` → `scheduler()` |
| Nhường CPU khi có ngắt timer (preemption) | `kernel/trap.c` → `yield()` trong `usertrap`/`kerneltrap` |
| Thêm trường cho PCB (priority, tickets, runtime...) | `kernel/proc.h` → `struct proc` |
| Khởi tạo trường mới | `kernel/proc.c` → `allocproc()`, `fork()` |
| Thêm syscall (vd. `setpriority`) | giống Tutorial 4: `syscall.h`, `syscall.c`, `sysproc.c`, `user/usys.pl`, `user/user.h` |

Kernel xv6 bản này in log bằng `printk(...)`, không phải `printf`.
