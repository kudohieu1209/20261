# CK5 — Hai đề thi thử cuối kỳ (đề thật 20221Q và 20231Q, lời giải đã kiểm tra lại)

Hai đề này cùng khuôn 3 câu (mạng hàng đợi 4đ + phân chia băng thông & ARQ 3đ + định tuyến 3đ) — đúng kiểu đề chương trình ET4070 gần đây. Làm sau khi đã học xong GK1–GK4 và CK1–CK4.
Cách làm: bấm giờ 90 phút, được mở tài liệu (dùng sổ tay phòng thi), làm thẳng vào ô trống. Xong cả hai đề mới lật lời giải; tự chấm; chép lỗi sai vào sổ tay.
Mục tiêu: ≥ 9/10 mỗi đề, xong trước giờ 10 phút.
Số liệu theo MSSV/STT: đề 20231Q dùng i = 7 (hàng đơn vị số thứ tự trong danh sách thi; nếu số thứ tự của bạn khác thì thay i tương ứng).

---

## ĐỀ SỐ 1 — Cuối kỳ 2022.1 (ET4070Q), 90 phút, được dùng tài liệu

**Câu 1 (4 điểm).** Mạng hàng đợi M/M/1. Tốc độ phục vụ S1, S2, S3: μ1 = 20 000; μ2 = 6 250; μ3 = 12 500 yêu cầu/s. Yêu cầu đến S1 theo Poisson γ = 2000 yêu cầu/s. Ra khỏi S1: 50% → S2, 50% → S3. Ra khỏi S2: quay về S1. Ra khỏi S3: 40% ra ngoài, 60% quay về S1. (Hình: CK_20221Q.pdf trang 1.)
- Xác suất để mỗi server có đúng 2 yêu cầu p(2,2,2).
- Số yêu cầu trung bình trong mạng.
- Thời gian trễ trung bình của 1 yêu cầu khi đi qua hệ thống.

**Câu 2 (3 điểm).** Sơ đồ 4 nút A, B, C, D và 4 kết nối 1, 2, 3, 4. A —8 Mbps— B —15 Mbps— C —10 Mbps— D. Kết nối 1: A → D; 2: A → C; 3: A → B; 4: B → D. Trễ truyền dẫn giữa hai nút TD = 0,05 ms; khung L = 500 bit; ACK không đáng kể; không lỗi. (Hình: CK_20221Q.pdf trang 1, nửa dưới.)
- Phân chia băng thông cho 4 kết nối theo max-min.
- Hiệu suất truyền trên liên kết AB nếu dùng Stop-and-Wait.
- Hiệu suất trên liên kết AB nếu dùng Go-Back-N với W = 2. Tìm điều kiện của W để hiệu suất đạt 100%.

**Câu 3 (3 điểm).** Đồ thị: A–B 2, A–E 2, B–C 1, B–G 4, B–E 2, C–G 3, C–D 1, G–E 1, G–D 1, E–D 3. Xây dựng cây SPT theo Bellman-Ford, tìm đường ngắn nhất từ G đến các nút còn lại. (Hình: CK_20221Q.pdf trang 2.)

---

## ĐỀ SỐ 2 — Cuối kỳ 2023.1 (ET4070Q), 90 phút, được dùng tài liệu

**Câu 1 (4 điểm).** Mạng hàng đợi M/M/1. μ1 = 100 000; μ2 = 80 000; μ3 = 80 000; μ4 = 100 000 yêu cầu/s. Yêu cầu đến S1 theo Poisson γ = 4000(i + 1) yêu cầu/s. S1 → S2 (40%), S3 (60%); S2 → về đầu vào S1 (50%), S4 (50%); S3 → S4; S4 → ra ngoài (80%), về đầu vào S3 (20%). (Hình: CK_20231Q.pdf trang 1.)
- Tổng số yêu cầu trung bình của mạng.
- Thời gian trễ trung bình của 1 yêu cầu khi qua hệ thống.
- Giả thiết μ1 = μ2 = μ3 = μ4 = μ. Tìm điều kiện của μ để hệ thống ổn định.
- Với γ = 40 000 yêu cầu/s, tính p(0, 1, 2, i + 1).

**Câu 2 (3 điểm).** A —10 Mbps— B —5 Mbps— C —5 Mbps— D. Kết nối 1: A → D; 2: A → B; 3: B → C; 4: A → B. TD = 0,24 ms; L = 800 bit; ACK không đáng kể; không lỗi. (Hình: CK_20231Q.pdf trang 2.)
- Phân chia băng thông theo max-min.
- Hiệu suất trên liên kết CD nếu dùng Stop-and-Wait.
- Hiệu suất trên liên kết CD nếu dùng Go-Back-N với W = 3. Tìm điều kiện của W để hiệu suất đạt 100%.

**Câu 3 (3 điểm).** Đồ thị: A–B 1, A–C 1, A–D 4, A–E 3, B–C 5, B–G 6, C–D 3, C–F 2, C–G 1, D–E 2, D–H 2, E–H 7, F–H 4, G–H 3. Xây dựng cây SPT theo Dijkstra từ nguồn A. (Hình: CK_20231Q.pdf trang 2.)

---

## LỜI GIẢI ĐỀ SỐ 1

**Câu 1 (4đ).**
- Phương trình lưu lượng (1đ): λ1 = 2000 + λ2 + 0,6λ3; λ2 = λ3 = 0,5λ1 → 0,2λ1 = 2000 → **λ1 = 10 000; λ2 = λ3 = 5000**. Kiểm tra: ra ngoài 0,4·5000 = 2000 ✔.
- ρ1 = 0,5; ρ2 = 0,8; ρ3 = 0,4 (ổn định). (0,5đ)
- p(2,2,2) = (1 − 0,5)0,5² × (1 − 0,8)0,8² × (1 − 0,4)0,4² = 0,125 × 0,128 × 0,096 ≈ **1,536·10⁻³**. (1đ)
- N = 0,5/0,5 + 0,8/0,2 + 0,4/0,6 = 1 + 4 + 0,667 = **5,667 yêu cầu**. (0,75đ)
- T = N/γ = 5,667/2000 ≈ **2,83 ms**. (0,75đ)

**Câu 2 (3đ).**
- Max-min (1đ): AB: 8/3 (1, 2, 3); BC: 15/3 = 5 (1, 2, 4); CD: 10/2 = 5 (1, 4) → chốt **1 = 2 = 3 = 8/3 ≈ 2,67 Mbps**. Còn 4: BC dư 29/3, CD dư 22/3 → **4 = 22/3 ≈ 7,33 Mbps**.
- Stop-and-Wait trên AB (1đ): TF = 500/(8·10⁶) = 62,5 µs; TΣ = TF + 2TD = 62,5 + 100 = 162,5 µs → η = 62,5/162,5 ≈ **38,5%**.
- Go-Back-N W = 2 (1đ): W·TF = 125 µs < TΣ → η = 125/162,5 ≈ **76,9%**. Đạt 100% khi W·TF ≥ TΣ → W ≥ 2,6 → **W ≥ 3**.

> Tài liệu tổng hợp ghi kết nối 4 = 29/3 (sai, CD bị vượt dung lượng) và tính hiệu suất AB theo cả tuyến A → D chỉ với một chiều trễ (TΣ = 1775/6 µs, η = 21,13%). Đề hỏi "trên liên kết AB" nên dùng TΣ = TF + 2TD của riêng liên kết AB như trên.

**Câu 3 (3đ).** Bellman-Ford từ G:
| h | A | B | C | D | E | G |
|---|---|---|---|---|---|---|
| 0 | ∞ | ∞ | ∞ | ∞ | ∞ | 0 |
| 1 | ∞ | 4, G | 3, G | 1, G | 1, G | 0 |
| 2 | 3, E | 3, E | 2, D | 1, G | 1, G | 0 |
| 3 | 3, E | 3, E | 2, D | 1, G | 1, G | 0 |
Vòng 3 không đổi → dừng. Cây SPT: G–D, G–E, D–C, E–A, E–B.
Đường ngắn nhất: G→D (1); G→E (1); G→D→C (2); G→E→A (3); G→E→B (3).

---

## LỜI GIẢI ĐỀ SỐ 2 (i = 7 → γ = 32 000)

**Câu 1 (4đ).**
- Phương trình lưu lượng (1đ): λ1 = γ + 0,5λ2, λ2 = 0,4λ1 → **λ1 = 1,25γ = 40 000; λ2 = 0,5γ = 16 000**. λ3 = 0,6λ1 + 0,2λ4; λ4 = 0,5λ2 + λ3 → **λ4 = 1,25γ = 40 000; λ3 = γ = 32 000**. Kiểm tra: 0,8λ4 = γ ✔.
- ρ1 = 0,4; ρ2 = 0,2; ρ3 = 0,4; ρ4 = 0,4 → N = 3·(0,4/0,6) + 0,2/0,8 = **2,25 yêu cầu**. (1đ)
- T = 2,25/32 000 ≈ **70,3 µs**. (0,5đ)
- Ổn định: μ > max λi = **1,25γ** (= 40 000 yêu cầu/s với i = 7). (0,75đ)
- γ = 40 000: ρ1 = 0,5; ρ2 = 0,25; ρ3 = 0,5; ρ4 = 0,5 → p(0,1,2,8) = 0,5 × (0,75·0,25) × (0,5·0,25) × (0,5·0,5⁸) ≈ **2,29·10⁻⁵**. (0,75đ)

**Câu 2 (3đ).**
- Max-min (1đ): AB: 10/3 (1, 2, 4); BC: 5/2 (1, 3); CD: 5/1 (1) → BC nhỏ nhất → **1 = 3 = 2,5 Mbps**. AB còn 7,5 cho 2 và 4 → **2 = 4 = 3,75 Mbps**.
- Stop-and-Wait trên CD (1đ): TF = 800/(5·10⁶) = 160 µs; TΣ = 160 + 2·240 = 640 µs → η = **25%**.
- Go-Back-N W = 3 (1đ): 3·160/640 = **75%**; đạt 100% khi W ≥ 640/160 → **W ≥ 4**.

**Câu 3 (3đ).** Dijkstra từ A:
| Bước | Chốt | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|---|
| 0 | A | 1, A | 1, A | 4, A | 3, A | ∞ | ∞ | ∞ |
| 1 | B | × | 1, A | 4, A | 3, A | ∞ | 7, B | ∞ |
| 2 | C | × | × | 4, A | 3, A | 3, C | 2, C | ∞ |
| 3 | G | × | × | 4, A | 3, A | 3, C | × | 5, G |
| 4 | E | × | × | 4, A | × | 3, C | × | 5, G |
| 5 | F | × | × | 4, A | × | × | × | 5, G |
| 6 | D | × | × | × | × | × | × | 5, G |
| 7 | H | | | | | | | 5, G |
Cây SPT: A–B, A–C, C–G, A–E, C–F, A–D, G–H. Chi phí: B 1, C 1, G 2, E 3, F 3, D 4, H 5.

---

## Bảng tự chấm

| | Đề 1 | Đề 2 |
|---|---|---|
| Câu 1 | /4 | /4 |
| Câu 2 | /3 | /3 |
| Câu 3 | /3 | /3 |
| Tổng | /10 | /10 |
| Thời gian làm | phút | phút |
