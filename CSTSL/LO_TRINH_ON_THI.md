# Lộ trình ôn thi Cơ sở truyền số liệu (ET4070) — học theo dạng bài

Mục tiêu: **làm được bài trong đề, điểm cao nhất có thể**. Không học lý thuyết nền, chỉ học
*nhận dạng đề → áp khuôn lời giải → bấm máy đúng → trình bày đủ ý ăn điểm*.

Lộ trình này dựng từ 8 đề cuối kỳ thật (20202 → 20241) có trong `docs/Đề CK/` và
`docs/CSTSL_20251_ALL_re.pdf`, không dựng theo thứ tự slide.

Lớp: **173872 — ET4070 — thầy Nguyễn Xuân Dũng**, kỳ 20261.

## Thông tin thi giữa kỳ (thầy báo, ghi ngày 11/11/2026)

- **100% tự luận, 60 phút.**
- **Được dùng tài liệu giấy** (photo hoặc ghi chép) → không dùng được tablet trong phòng thi: phải **in** `lessons/GK0_TapInGiay_ViDuTrenLop.pdf`.
- **Thi đến hết phần hàng đợi** (chương 2–3 slide thầy Dũng).
- **Làm được các ví dụ trên lớp sẽ có lợi thế** → ưu tiên số 1 là tự làm lại được cả 16 ví dụ/bài tập trong GK0 mà không nhìn lời giải.

Thứ tự học khi thời gian gấp: GK0 (ví dụ trên lớp) → GK2 → GK1 → GK6 đề A, B → GK5 → GK3, GK4 và GK6 đề C (nếu thầy dạy tới mạng hàng đợi trước ngày thi).

## Bộ tài liệu PDF (thư mục `lessons/`, mở trên tablet và ghi chú trực tiếp)

Giữa kỳ — bám slide thầy Dũng chương 2–3 và bài thầy chữa trên lớp:

| File | Nội dung | Thay cho buổi |
|---|---|---|
| GK1_Poisson_PhanBoMu_MM1.pdf | Poisson, phân bố mũ, ghép/tách luồng, M/M/1, P(T ≤ t) | GK1 |
| GK2_HangDoiDon.pdf | M/M/1/1, M/M/1/k, tự lập phương trình sinh – tử, M/M/c, M/M/c/c, M/M/c/k, M/M/∞, M/G/1, M/D/1 | GK2 |
| GK3_PhuongTrinhLuuLuong.pdf | Phương trình lưu lượng, điều kiện ổn định, dạng tìm x | GK3 |
| GK4_HieuNangMang.pdf | N, T mạng, xác suất trạng thái, trễ theo đường, KIA, trễ đầu cuối | GK4 |
| GK5_CauHoiLyThuyet.pdf | Câu hỏi lý thuyết ngắn theo slide thầy Dũng | (mới) |
| GK6_DeThiThuGiuaKy.pdf | 3 đề thi thử 60 phút (biến thể ví dụ trên lớp) + lời giải | GK6 |
| GK0_TapInGiay_ViDuTrenLop.pdf | **Để in giấy mang vào phòng thi:** 16 ví dụ trên lớp giải tự luận + bảng công thức gộp + từ khoá lý thuyết | (mới) |

Cuối kỳ — theo slide thầy Thanh và đề cũ (cập nhật khi có slide thầy Dũng chương sau):

| File | Nội dung | Thay cho buổi |
|---|---|---|
| CK1_DinhTuyen.pdf | Dijkstra, Bellman-Ford, Prim, Kruskal | 6, 7, 8 |
| CK2_MoHinhHoaRouter.pdf | Đề một bài lớn: router → hàng đợi → định tuyến chi phí tự tính → S&W | 5, 8 |
| CK3_ARQ_DieuKhienLuong.pdf | S&W, GBN, SR, cửa sổ, có lỗi, giản đồ thời gian | 9–12 |
| CK4_CongBang_TacNghen.pdf | Max-min fairness, cửa sổ thích ứng | 13 |
| CK5_DeThiThuCuoiKy.pdf | 2 đề thật 20221Q, 20231Q + lời giải | 14–17 |

Thay đổi so với kế hoạch ban đầu: slide thầy Dũng chỉ có chương 2–3 nên giữa kỳ tập trung hàng đợi; định tuyến chuyển sang bộ cuối kỳ, GK5 thành bài câu hỏi lý thuyết.

---

## 0. Chạy nước rút giữa kỳ (ưu tiên số 1)

> **Cập nhật 11/11/2026:** thầy đã báo thi đến hết phần hàng đợi, tự luận 60 phút, tài liệu giấy →
> bỏ GK5 định tuyến khỏi giữa kỳ (chuyển sang CK1), GK5 thành câu hỏi lý thuyết, GK6 là 3 đề biến thể ví dụ trên lớp.
> Bảng dưới là kế hoạch gốc, giữ để tham khảo; thứ tự học thực tế xem mục "Thông tin thi giữa kỳ" ở đầu file.

Giữa kỳ rơi vào tuần **16–20/11** hoặc **23–27/11/2026**. Chưa có đề giữa kỳ nào của thầy Dũng,
nên phạm vi được lấy theo slide chương 1–6 (hàng đợi → mạng hàng đợi → đồ thị, định tuyến) và
đề giữa kỳ lớp cô Lan (1 câu SPT + 1 câu mạng hàng đợi). Lịch dưới đây tính cho trường hợp thi sớm.

| Buổi | Ngày | Làm được gì sau buổi này | Bài luyện |
|---|---|---|---|
| GK1 | T4 11/11 | Poisson và phân bố mũ: P(k yêu cầu trong thời gian t), P(chờ > t). Một nút M/M/1: đổi đề ra λ, μ rồi bấm ρ, N, T, N_Q, T_Q, p_n | Slide 2 ví dụ xe bus (tr. 23–24), đề 2014 câu 1, các ý tính từng nút của 20211 và 20241 |
| GK2 | T5 12/11 | Hàng đợi đơn loại khác: M/M/1/K (xác suất mất gói), M/M/c (xác suất phải chờ), M/M/c/c (xác suất tắc nghẽn) — bảng công thức + cách bấm máy | Slide 3, 20231 câu 1 (2 công ty chung server), nút Q3 của 20232, bài tập cô Lan bài 1 |
| GK3 | T6 13/11 | Phương trình lưu lượng cho mạng có rẽ nhánh và hồi tiếp; dạng "tìm x" (D1 = D2, D1 = 2·D2, mạng ổn định) | Slide 4 ví dụ 1–3, 20202 câu 1.1, 20232 câu 1.1, 20212 câu 1.1, đề 2015 câu 1 |
| GK4 | T7 14/11 | N mạng, T mạng, trễ theo đường nguồn → đích, xác suất trạng thái; mạng có nút M/M/c; trễ theo KIA | Slide 4 ví dụ 4 và ví dụ KIA, 20221Q câu 1, 20231Q câu 1, giữa kỳ cô Lan câu 2 |
| GK5 | CN 15/11 | Dijkstra, Bellman-Ford lập bảng; Prim, Kruskal (slide có nhiều ví dụ nên giữa kỳ có thể hỏi) | Slide 6 các ví dụ, 20202 câu 2 (a = 7), 20212 câu 2, giữa kỳ cô Lan câu 1 |
| GK6 | T2 16/11 | Thi thử giữa kỳ bấm giờ, chấm, chốt sổ tay | Đề giữa kỳ cô Lan + 1 câu hàng đợi đơn |

- **Nếu thi tuần 23–27/11:** thêm 2 buổi — làm lại toàn bộ bài đã sai, rồi thi thử lần 2
  (20221Q câu 1 + 20231Q câu 3). Nếu lúc đó lớp đã học sang ARQ thì thêm buổi 9.
- **Nếu lớp chưa học tới định tuyến:** bỏ GK5, dồn thời gian cho GK2–GK4.
- GK1 = buổi 1, GK3 = buổi 2 + 3, GK4 = buổi 4, GK5 = buổi 6 + 7 của lộ trình cuối kỳ bên dưới;
  sau giữa kỳ học tiếp buổi 5, 8, rồi 9–17.

**Cần xác nhận với thầy/lớp** (để cắt bớt phần thừa):

- [ ] Lớp đã học tới slide/chương nào? (đã biết: thi đến hết phần hàng đợi — còn cần biết có tới mạng hàng đợi không)
- [x] Thầy có công bố phạm vi, hình thức? → 100% tự luận, 60 phút, tài liệu giấy, đến hết phần hàng đợi
- [ ] Thầy có giao bài tập hoặc đề mẫu nào không? (nếu có, đó là tài liệu luyện quan trọng nhất)

---

## 1. Đề thi trông như thế nào

Đề 90 phút, **được dùng tài liệu**, số liệu thường gắn với MSSV (`a` = chữ số cuối, `ba` = 2 chữ số cuối).

| Kỳ | Mạng hàng đợi | Định tuyến | ARQ / điều khiển luồng | Phần khác |
|---|---|---|---|---|
| 20202 | 3,5đ — tìm x để D1 = D2; N mạng, P(mạng rỗng), trễ S1→D1 | 3đ — Dijkstra | 3,5đ — Selective Repeat 2 chặng: vẽ lưu đồ + hiệu suất | |
| 20211 | 6đ — mô hình hoá router → hàng đợi, λ, μ, T từng nút, trễ S1→Dest | 2đ — Dijkstra, chi phí = trễ tự tính | 2đ — Stop&Wait nhiều chặng | |
| 20212 | 3,5đ — tìm x để mạng ổn định; chiều dài hàng đợi, trễ đến D | 3đ — Bellman-Ford | 3,5đ — Selective Repeat: W nhỏ nhất, độ sử dụng khi mất gói | |
| 20221 (Q) | 4đ — p(2,2,2), N mạng, T mạng (mạng có vòng hồi tiếp) | 3đ — Bellman-Ford | 2đ — Stop&Wait, Go-Back-N, điều kiện W | 1đ — max-min fairness |
| 20231 (Q) | 4đ — N, T, điều kiện μ để ổn định, p(0,1,2,i+1) | 3đ — Dijkstra | 2đ — Stop&Wait, Go-Back-N, điều kiện W | 1đ — max-min fairness |
| 20231 (đề khác) | M/M/1: 2 công ty chung 1 server, tìm k | Bellman-Ford đồ thị có hướng + 3 câu hỏi ngắn | | |
| 20232 | 3,5đ — tìm x để D1 = D2 (có nút M/M/1/0); N mạng, trễ đến D2 | 3đ — Dijkstra (có cạnh có hướng) | 3,5đ — Stop&Wait, ACK đi vòng qua R: vẽ biểu đồ, tìm d, tốc độ khi p = 0,2 | |
| 20241 | Mô hình hoá, λ/μ, T từng router, trễ S1→D | Dijkstra, chi phí tự tính | Stop&Wait có BER | |

**Kết luận:** 3 dạng lõi xuất hiện ở **100% số đề** và chiếm **9–10 điểm**:

1. **Mạng hàng đợi** (3,5–6đ) — luôn là câu nặng điểm nhất.
2. **Cây đường ngắn nhất**: Dijkstra hoặc Bellman-Ford (2–3đ) — câu dễ ăn trọn điểm nhất.
3. **ARQ**: Stop&Wait / Go-Back-N / Selective Repeat (2–3,5đ) — câu dễ mất điểm nhất vì đề hay biến tấu.

Phần phụ (≈1đ, không phải đề nào cũng có): max-min fairness, chống tắc nghẽn bằng cửa sổ.
Chưa đề nào trong 8 đề hỏi cây khung nhỏ nhất (Prim/Kruskal) → chỉ lướt 30 phút để dự phòng.

---

## 2. Cách học

- **Thi mở tài liệu ⇒ sản phẩm chính của cả lộ trình là một cuốn "Sổ tay phòng thi"**: mỗi dạng 1 trang gồm
  dấu hiệu nhận dạng, các bước giải đánh số, công thức, 1 bài mẫu đã giải, danh sách lỗi hay mắc.
  Vào phòng thi chỉ việc nhận dạng và chép khuôn.
- Mỗi buổi học (90–120 phút) đi đúng 4 bước:
  1. Nhận khuôn lời giải của dạng đó (các bước, công thức — không chứng minh).
  2. Xem 1 bài mẫu giải trên đề thật.
  3. **Tự làm 2–3 bài đề thật** bằng tay, thay số theo MSSV của mình (`a = 7`, `ba = 67`).
  4. Chấm, ghi lỗi vào sổ tay.
- Chỉ coi là xong một buổi khi đạt **tiêu chí qua** ghi ở cột cuối.

> Lưu ý về tài liệu giải có sẵn: `docs/CSTSL_20251_ALL_re.pdf` rất hữu ích nhưng **có lỗi**
> (ví dụ đề 20241 câu 5 gọi nhầm xác suất gói *lỗi* 0,148 là xác suất *đúng* rồi đem chia;
> đề 20232 câu 3 ghi 239,33 bps thay vì kbps). Dùng nó để tham khảo cách trình bày,
> còn đáp số sẽ được giải lại và kiểm tra ở từng buổi.

---

## 3. Lộ trình 17 buổi

### Chặng 1 — Mạng hàng đợi (5 buổi, 3,5–6đ)

| Buổi | Làm được gì sau buổi này | Bài luyện (đề thật) | Tiêu chí qua |
|---|---|---|---|
| 1 | Một nút M/M/1: đổi đề bài ra λ, μ (thời gian phục vụ 5 ms → μ = 200; μ = C/L), bấm ρ, N, T, N_Q, T_Q, p_n | Các ý tính từng nút của 20211 (ý 3–4), 20241 (câu 2) | Tính 1 nút < 2 phút, không sai đơn vị |
| 2 | Lập và giải **phương trình lưu lượng** cho mạng có rẽ nhánh và vòng hồi tiếp | 20221Q câu 1, 20231Q câu 1, 20241-LUH câu 2 | Ra đúng mọi θ_i ngay lần đầu, có bước thử lại tổng vào = tổng ra |
| 3 | Dạng "tìm x": (a) để tốc độ đến D1 = D2; (b) để mạng ổn định (mọi ρ_i < 1) | 20202 câu 1.1, 20232 câu 1.1, 20212 câu 1.1, giữa kỳ cô Lan câu 2a | 3/4 bài đúng đáp số |
| 4 | N mạng, T mạng, **trễ theo đường nguồn → đích** (liệt kê đường, lấy trọng số), xác suất trạng thái p(n1,n2,…), P(mạng rỗng) | 20202 câu 1.2, 20212 câu 1.2, 20232 câu 1.2, làm trọn 20221Q + 20231Q câu 1 | Làm trọn 1 câu hàng đợi ≤ 25 phút |
| 5 | Đề kiểu "cho sơ đồ router": tự vẽ mạng hàng đợi theo cổng ra. Biến thể: nút M/M/1/0, M/M/1/K, M/M/c, 2 luồng chung 1 server | 20211 ý 1–5, 20241 câu 1–3, 20232 (nút Q3), bài tập cô Lan bài 1, 20231 câu 1 | Nhìn đề biết ngay dùng khuôn nào |

### Chặng 2 — Định tuyến (3 buổi, 2–3đ)

| Buổi | Làm được gì sau buổi này | Bài luyện (đề thật) | Tiêu chí qua |
|---|---|---|---|
| 6 | **Dijkstra** lập bảng từng bước + vẽ cây SPT, xử lý cạnh có hướng và trường hợp bằng nhau | 20202 câu 2 (a = 7), 20231Q câu 3, 20232 câu 2 | 1 bài ≤ 12 phút, đúng 100% |
| 7 | **Bellman-Ford** theo cả 2 kiểu trình bày (bảng theo vòng lặp, và kiểu hàng đợi của cô Lan), có trọng số âm | 20212 câu 2, 20221Q câu 3, 20231 câu 2a, giữa kỳ cô Lan câu 1 | 1 bài ≤ 15 phút, đúng 100% |
| 8 | Định tuyến khi **phải tự tính chi phí cạnh** (trễ 1/(μ−λ), trễ truyền lan, hàm chuẩn hoá băng thông/khoảng cách/tỉ lệ mất gói); 3 câu hỏi ngắn hay gặp; lướt Prim/Kruskal | 20211 ý 6, 20241 câu 4, 20231 câu 2b–d, đề 2015 câu 3 | Thuộc sẵn câu trả lời ngắn trong sổ tay |

### Chặng 3 — ARQ và điều khiển luồng (4 buổi, 2–3,5đ)

| Buổi | Làm được gì sau buổi này | Bài luyện (đề thật) | Tiêu chí qua |
|---|---|---|---|
| 9 | Tính T_F = L/R (đổi byte → bit), T_D = d/v với v = c/n; **Stop&Wait không lỗi**: η = T_F / T_Σ, kể cả đường nhiều chặng và ACK đi đường khác | 20211 ý 7, 20221Q câu 2b, 20231Q câu 2b, 20232 câu 3.1 | Lập đúng T_Σ cho mọi sơ đồ |
| 10 | **Cửa sổ W** (Go-Back-N / sliding window) không lỗi: η = W·T_F / T_Σ, tìm W nhỏ nhất để đạt 100% | 20221Q câu 2c, 20231Q câu 2c, 20212 câu 3.1, đề 2014 câu 4, đề 2015 câu 2 | 4/5 bài đúng |
| 11 | **Có lỗi / mất gói**: số lần phát trung bình 1/(1−p), có timeout, đổi BER → xác suất lỗi gói, nhân xác suất qua nhiều chặng, Selective Repeat với W | 20232 câu 3.2, 20241 câu 5, 20212 câu 3.2, 20202 câu 3.2 (ba = 67 → P1 = 33%) | Tự giải lại được 20241 câu 5 đúng (tài liệu giải sẵn sai) |
| 12 | **Vẽ giản đồ thời gian** (1,5đ ở 20202 và 20232): Stop&Wait, Go-Back-N, Selective Repeat khi mất gói / mất ACK / timeout | 20202 câu 3.1, 20232 câu 3.1, 4 trường hợp trong tài liệu tổng hợp | Vẽ đúng 3 cơ chế không nhìn mẫu |

### Chặng 4 — Phần phụ (1 buổi, ≈1đ)

| Buổi | Làm được gì sau buổi này | Bài luyện (đề thật) | Tiêu chí qua |
|---|---|---|---|
| 13 | **Max-min fairness** (chia băng thông từng bước); **chống tắc nghẽn bằng cửa sổ** (w giảm theo α, tăng cộng I, vẽ diễn biến) | 20221Q câu 2a, 20231Q câu 2a, bài tập cô Lan bài 2–4 | Mỗi dạng 1 bài đúng |

### Chặng 5 — Luyện đề (4 buổi)

| Buổi | Đề thi thử (bấm giờ 90 phút, số liệu theo MSSV) |
|---|---|
| 14 | Đề 20212 (kiểu cô Lan: hàng đợi + Bellman-Ford + Selective Repeat) |
| 15 | Đề 20232 (kiểu cô Lan: hàng đợi có M/M/1/0 + Dijkstra + Stop&Wait) |
| 16 | Đề 20231Q (hàng đợi hồi tiếp + max-min + Go-Back-N + Dijkstra) |
| 17 | Đề 20241 hoặc 20211 (kiểu một bài lớn xuyên suốt) |

Sau mỗi đề: chấm theo thang điểm, mọi lỗi sai đều ghi thành 1 dòng trong mục "lỗi hay mắc" của sổ tay.
Mục tiêu: **≥ 9/10 ở 2 đề cuối, xong trước giờ ít nhất 10 phút**.

---

## 4. Lịch gợi ý

- **Nhịp bình thường:** 2 buổi/tuần → xong chặng 1–4 trong ~6,5 tuần, còn lại luyện đề.
  Bắt đầu từ tuần 10/11/2026 thì xong toàn bộ khoảng giữa tháng 1/2027.
- **Giữa kỳ:** theo lịch chạy nước rút ở mục 0, làm trước mọi thứ khác.
- **Nếu chỉ còn 2 tuần:** buổi 2, 3, 4 → 6, 7 → 9, 10, 11 → thi thử 2 đề (14, 15). Bỏ buổi 5, 8, 12, 13 xuống ưu tiên sau.
- **Nếu chỉ còn 3 ngày:** buổi 2+4, 6+7, 9+10, rồi 1 đề thi thử; mang đủ sổ tay và tài liệu giải.

---

## 5. Tiến độ

Giữa kỳ:

- [ ] GK0 — In tập ví dụ trên lớp, tự làm lại cả 16 ví dụ không nhìn lời giải
- [ ] GK1 — Poisson, phân bố mũ, M/M/1 một nút
- [ ] GK2 — M/M/1/K, M/M/c, M/M/c/c
- [ ] GK3 — Phương trình lưu lượng, dạng tìm x
- [ ] GK4 — N, T, trễ theo đường, xác suất trạng thái
- [ ] GK5 — Câu hỏi lý thuyết ngắn
- [ ] GK6 — Thi thử giữa kỳ: đề A, đề B, đề C

Cuối kỳ:

- [ ] Buổi 1 — M/M/1 một nút
- [ ] Buổi 2 — Phương trình lưu lượng
- [ ] Buổi 3 — Dạng tìm x
- [ ] Buổi 4 — N, T, trễ theo đường, xác suất trạng thái
- [ ] Buổi 5 — Mô hình hoá router + biến thể
- [ ] Buổi 6 — Dijkstra
- [ ] Buổi 7 — Bellman-Ford
- [ ] Buổi 8 — Chi phí tự tính + câu hỏi ngắn
- [ ] Buổi 9 — Stop&Wait không lỗi
- [ ] Buổi 10 — Cửa sổ W
- [ ] Buổi 11 — ARQ có lỗi
- [ ] Buổi 12 — Giản đồ thời gian
- [ ] Buổi 13 — Max-min, chống tắc nghẽn
- [ ] Buổi 14 — Thi thử 20212
- [ ] Buổi 15 — Thi thử 20232
- [ ] Buổi 16 — Thi thử 20231Q
- [ ] Buổi 17 — Thi thử 20241 / 20211
