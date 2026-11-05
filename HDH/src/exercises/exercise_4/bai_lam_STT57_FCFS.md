# Exercise 4 – Process Scheduling (bài mẫu để CHÉP TAY)

> Thầy chỉ nhận **bản scan bài viết tay**, nên không in file này ra nộp.
> Đầu bài nhớ ghi: **Họ tên, MSSV 20223967, Ngày sinh, STT 57**.

## 1. Dữ liệu

- MSSV 20223967 → 4 chữ số cuối **3967** = b₃ b₂ b₁ b₀ → b₃ = 3, b₂ = 9, b₁ = 6, b₀ = 7
- Thuật toán: **FCFS** (STT 57)

| Task | Arrival time | Execution time |
| :---: | :---: | :---: |
| T1 | 3 (b₃) | 3 |
| T2 | 9 (b₂) | 9 |
| T3 | 6 (b₁) | 2 |
| T4 | 7 (b₀) | 4 |

## 2. Lập lịch FCFS (First Come First Served, không chiếm quyền)

Xếp theo thời điểm đến: **T1 (3) → T3 (6) → T4 (7) → T2 (9)**

- t = 0 → 3: chưa có tác vụ nào → CPU rảnh (idle)
- t = 3: T1 đến, chạy 3 → xong lúc 6
- t = 6: T3 vừa đến, chạy 2 → xong lúc 8
- t = 8: T4 (đến lúc 7, đã chờ 1) chạy 4 → xong lúc 12
- t = 12: T2 (đến lúc 9, đã chờ 3) chạy 9 → xong lúc 21

## 3. Gantt chart

```
| idle | T1 | T3 | T4 |      T2      |
0      3    6    8    12             21
```

## 4. Bảng kết quả

- Response time  = Start − Arrival (thời điểm được chạy lần đầu − thời điểm đến)
- Waiting time   = Finish − Arrival − Execution
- (FCFS không chiếm quyền → Response time = Waiting time)

| Task | Arrival | Exec | Start | Finish | Response | Waiting | Turnaround |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| T1 | 3 | 3 | 3 | 6 | 3 − 3 = **0** | 6 − 3 − 3 = **0** | 3 |
| T2 | 9 | 9 | 12 | 21 | 12 − 9 = **3** | 21 − 9 − 9 = **3** | 12 |
| T3 | 6 | 2 | 6 | 8 | 6 − 6 = **0** | 8 − 6 − 2 = **0** | 2 |
| T4 | 7 | 4 | 8 | 12 | 8 − 7 = **1** | 12 − 7 − 4 = **1** | 5 |

- **Average response time** = (0 + 3 + 0 + 1) / 4 = **1.0**
- **Average waiting time**  = (0 + 3 + 0 + 1) / 4 = **1.0**
- (Average turnaround time = (3 + 12 + 2 + 5) / 4 = 5.5)

Kiểm tra bằng máy: `./sched_sim fcfs stt57.txt` → Avg WT = 1.00, Avg RT = 1.00.
