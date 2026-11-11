# GK3 — Mạng hàng đợi (1): phương trình lưu lượng, điều kiện ổn định, dạng "tìm x"

Qua buổi khi: lập đúng phương trình lưu lượng ngay lần đầu cho cả 6 bài tự luyện, có bước kiểm tra "tổng vào = tổng ra".

## 0. Vì sao tách mạng thành từng nút được (1 câu để ghi vào bài)

Định lý Burke: hàng đợi M/M/1 (hoặc M/M/c, M/M/∞) ổn định có đầu vào Poisson λ thì **đầu ra cũng là Poisson λ**. Định lý Jackson: trong mạng hàng đợi mở, mỗi nút i được coi như một hàng đợi **M/M/1 độc lập** với tốc độ đến λi (tính bằng phương trình lưu lượng) và ρi = λi/μi.

Ký hiệu thầy Dũng: γi = lưu lượng từ ngoài đi thẳng vào nút i; rji = xác suất yêu cầu rời nút j đi tới nút i; ri0 = xác suất rời nút i đi ra khỏi mạng; λi = tổng lưu lượng vào nút i. (Slide thầy Thanh và nhiều lời giải viết θi thay cho λi — cùng một thứ.)

## 1. Khuôn lập phương trình lưu lượng

1. **Đặt tên** λ1, λ2, … cho mọi nút (kể cả nút chỉ có một đường vào).
2. **Đọc từng mũi tên đi ra** của mỗi nút: nhánh nào ghi % thì dùng %, nhánh không ghi = phần còn lại (100% − tổng các nhánh có ghi). Một đường ra duy nhất = 100%.
3. Với mỗi nút i, viết:
   **λi = γi + Σj rji·λj** = (lưu lượng từ nguồn đổ thẳng vào i) + (mỗi nút j có nhánh trỏ vào i: tỉ lệ nhánh × λj).
4. Giải hệ: bắt đầu từ nút chỉ phụ thuộc nguồn; nút có vòng hồi tiếp thì chuyển vế (λ1 = γ + 0,5λ1 → λ1 = 2γ).
5. **Kiểm tra:** tổng lưu lượng ra khỏi mạng (các nhánh đi tới đích) = tổng lưu lượng nguồn. Sai là đọc nhầm nhánh.

Mẹo đọc hình: đường nối từ đầu ra một nút quay về đầu vào một nút phía trước = hồi tiếp; điểm hai đường nhập = cộng; điểm một đường tách = nhân xác suất.

## 2. Điều kiện ổn định

- Mạng ổn định ⇔ **mọi nút** có ρi = λi/μi < 1 (nút có ci server: λi < ci·μi).
- Đề hỏi "điều kiện của μ (các nút giống nhau) để ổn định" → **μ > max λi**.
- Đề hỏi "điều kiện của x / r để ổn định" → viết từng ρi < 1 theo x, giải từng bất phương trình, lấy **giao** các khoảng (và 0 ≤ x ≤ 100%).
- Đề hỏi "γ lớn nhất để ổn định" → λi tỉ lệ với γ; mỗi nút cho một chặn trên; lấy chặn nhỏ nhất.

## 3. Dạng "tìm x để tốc độ đến D1 bằng (gấp k lần) tốc độ đến D2"

1. Lập phương trình lưu lượng, để x là ẩn → mọi λi là biểu thức theo x.
2. Tốc độ đến đích D = tổng các nhánh đổ vào D: λD = Σ (tỉ lệ nhánh đi tới D) × λ(nút đó) (+ nguồn nào đi thẳng tới D).
3. Giải phương trình λD1 = λD2 (hoặc λD1 = k·λD2).
4. Kiểm tra: λD1 + λD2 = tổng nguồn; và 0 ≤ x ≤ 100%.

## Bài mẫu 1 — slide thầy Thanh, mạng 2 nút có hồi tiếp

Hình: nguồn λ vào Q1; ra khỏi Q1: 1/4 quay lại chính Q1, 3/4 sang Q2; ra khỏi Q2: 1/2 quay về Q1, 1/2 ra ngoài. (Cắt hình từ docs/slide's thầy Thanh/CSTSL4.pdf trang 4, sơ đồ "Ví dụ 1".)
- λ1 = λ + (1/4)λ1 + (1/2)λ2; λ2 = (3/4)λ1.
- Thay: λ1 = λ + (1/4)λ1 + (3/8)λ1 → (3/8)λ1 = λ → **λ1 = 8λ/3**, **λ2 = 2λ**.
- Kiểm tra: ra ngoài = (1/2)λ2 = λ ✔.
- Với λ = 30 gói/s, μ1 = μ2 = 100: λ1 = 80, λ2 = 60 → ρ1 = 0,8, ρ2 = 0,6 → ổn định.

## Bài mẫu 2 — slide thầy Dũng tr. 87, mạng mở 4 nút

Hình (cắt từ 03-HangDoi.pdf trang 87): γ4 = 4 yêu cầu/s đi vào nút 4; nút 4 → nút 1 (r41 = 1); nút 1 → nút 2 (r12 = 0,5) và nút 3 (r13 = 0,5); nút 2 → nút 1 (r21 = 1); nút 3 → nút 1 (r31 = 0,6), ra ngoài (r30 = 0,4).
1/μ1 = 0,03 s; 1/μ2 = 0,04 s; 1/μ3 = 0,05 s; 1/μ4 = 0,06 s.

(a) Tính λ1, λ2, λ3, λ4.
- λ4 = γ4 = 4.
- λ1 = λ4 + λ2 + 0,6λ3; λ2 = 0,5λ1; λ3 = 0,5λ1.
- λ1 = 4 + 0,5λ1 + 0,3λ1 → 0,2λ1 = 4 → **λ1 = 20**, **λ2 = λ3 = 10**, **λ4 = 4** (yêu cầu/s).
- Kiểm tra: ra ngoài = 0,4·λ3 = 4 = γ4 ✔.
- ρ1 = 20·0,03 = 0,6; ρ2 = 10·0,04 = 0,4; ρ3 = 10·0,05 = 0,5; ρ4 = 4·0,06 = 0,24 → ổn định.

(b) Giữ r30 = 0,4, r31 = 0,6; tìm điều kiện của r12, r13 (r12 + r13 = 1) để ổn định.
- λ1 = 4 + r12λ1 + 0,6r13λ1 = 4 + λ1(1 − 0,4r13) → **λ1 = 10/r13**; λ2 = r12·λ1 = 10(1 − r13)/r13; λ3 = 10; λ4 = 4.
- ρ1 = 0,03·10/r13 < 1 → r13 > 0,3.
- ρ2 = 0,04·10(1 − r13)/r13 < 1 → 0,4(1 − r13) < r13 → r13 > 0,286.
- ρ3 = 0,5 < 1; ρ4 = 0,24 < 1 (luôn đúng).
- Kết luận: **r13 > 0,3 và r12 = 1 − r13 < 0,7**.

## Bài mẫu 3 — đề cuối kỳ 20221Q, câu 1 (mạng có vòng hồi tiếp về đầu)

Hình (cắt từ CK_20221Q.pdf trang 1): γ = 2000 yêu cầu/s vào S1; S1 → S2 (50%), S3 (50%); S2 → quay về S1 (100%); S3 → ra ngoài 40%, quay về S1 60%. μ1 = 20000, μ2 = 6250, μ3 = 12500 yêu cầu/s.
- λ1 = 2000 + λ2 + 0,6λ3; λ2 = λ3 = 0,5λ1.
- λ1 = 2000 + 0,5λ1 + 0,3λ1 → **λ1 = 10000**, **λ2 = λ3 = 5000**.
- Kiểm tra: ra ngoài = 0,4·5000 = 2000 ✔.
- ρ1 = 0,5; ρ2 = 0,8; ρ3 = 0,4 → ổn định. (Phần tính N, T, p(2,2,2) làm ở GK4.)

## Bài mẫu 4 — đề cuối kỳ 20202, câu 1.1 (dạng tìm x, số liệu theo MSSV ...67)

Hình (cắt từ CK_20202.pdf trang 1): S1 = 50 yêu cầu/s tách: x → Q2, (1 − x) → Q1. Q2: 20% quay về đầu vào Q1, 80% → Q4. Đầu ra Q1 tách: y → Q4 (nhánh y% tách ra trên đường nối Q1 → Q3, trước khi vào Q3), (1 − y) → Q3. Q3 → Q5. S2 = 20 yêu cầu/s tách: 25% đi thẳng tới D2, 75% → Q5. Q5 → D1. Q4 → Q6 → D2.
y = 10·(1 + ba mod 6)%; ba = 67 → 67 mod 6 = 1 → **y = 20%**.
- λ2 = 50x; λ1 = 50(1 − x) + 0,2·λ2 = 50 − 40x; λ3 = (1 − y)λ1 = 0,8(50 − 40x).
- λ4 = 0,8λ2 + y·λ1 = 40x + 10 − 8x = 10 + 32x; λ6 = λ4.
- λ5 = λ3 + 0,75·20 = 40 − 32x + 15 = 55 − 32x.
- λD1 = λ5 = 55 − 32x; λD2 = λ6 + 0,25·20 = 15 + 32x.
- λD1 = λD2 → 64x = 40 → **x = 62,5%**; tốc độ đến D1 = 55 − 20 = **35 yêu cầu/s** (D2 cũng 35; tổng 70 = 50 + 20 ✔).

## Bài tự luyện (6 bài, có ô chấm; bài nào có hình thì vẽ sơ đồ khối đơn giản theo mô tả)

1. (Bài mẫu 1 đổi số) λ = 40 gói/s; μ1 = 120, μ2 = 100. Tính λ1, λ2, ρ1, ρ2 và kết luận ổn định.
2. Hai nút nối tiếp: nguồn 50 gói/s vào nút 1; nút 1 → nút 2; ra khỏi nút 2: p quay lại nút 1, (1 − p) ra ngoài. μ1 = 100, μ2 = 80. Tìm điều kiện của p để mạng ổn định. Với p = 0,2 tính ρ1, ρ2.
3. Với mạng đề 20202 ở bài mẫu 4 (y = 20%), tìm x để tốc độ đến D1 gấp đôi tốc độ đến D2, và tính hai tốc độ đó.
4. Mạng 4 nút của thầy Dũng (bài mẫu 2) nhưng γ4 thay đổi. Tìm γ4 lớn nhất để mạng còn ổn định.
5. Nguồn 100 yêu cầu/s vào Q1. Q1 → Q2 (70%), Q3 (30%). Q2 → ra ngoài 50%, quay về Q1 50%. Q3 → ra ngoài. Ba nút có cùng μ. Tính λ1, λ2, λ3 và điều kiện của μ.
6. Nguồn 60 yêu cầu/s tách: x → Q1, phần còn lại → Q2. Q1 → Q3; Q2 → Q3. Q3 → ra ngoài 80%, quay về Q1 20%. μ1 = 50, μ2 = 40, μ3 = 80. Tìm điều kiện của x để mạng ổn định.

## Đáp án

1. λ1 = 8·40/3 ≈ **106,7**; λ2 = **80**. ρ1 ≈ **0,889**; ρ2 = **0,8** → **ổn định**.
2. λ1 = λ2 = 50/(1 − p). ρ1 < 1 → p < 0,5; ρ2 < 1 → p < 0,375 → **p < 0,375**. Với p = 0,2: λ = 62,5 → ρ1 = **0,625**, ρ2 ≈ **0,781**.
3. 55 − 32x = 2(15 + 32x) → 96x = 25 → **x ≈ 26,04%**; λD1 ≈ **46,67**, λD2 ≈ **23,33** yêu cầu/s (tổng 70 ✔).
4. λ1 = 5γ4, λ2 = λ3 = 2,5γ4, λ4 = γ4. ρ1 = 0,15γ4 < 1 → γ4 < 6,67; ρ2 = 0,1γ4 → γ4 < 10; ρ3 = 0,125γ4 → γ4 < 8; ρ4 = 0,06γ4 → γ4 < 16,7. → **γ4 < 6,67 yêu cầu/s**.
5. λ1 = 100 + 0,5λ2, λ2 = 0,7λ1 → λ1 = 100/0,65 ≈ **153,8**; λ2 ≈ **107,7**; λ3 ≈ **46,2**. Kiểm tra ra ngoài: 0,5·107,7 + 46,2 = 100 ✔. Điều kiện: **μ > 153,8**.
6. λ3 = 60/0,8 = 75; λ1 = 60x + 15; λ2 = 60(1 − x). ρ1 < 1 → x < 0,583; ρ2 < 1 → x > 0,333; ρ3 = 0,9375 < 1. → **33,3% < x < 58,3%**.

## Trang sổ tay phòng thi (trang 3)

```
PHƯƠNG TRÌNH LƯU LƯỢNG:  λi = γi + Σj rji·λj
  nhánh không ghi % = phần còn lại;  1 đường ra = 100%
  hồi tiếp: chuyển vế (λ = γ + aλ → λ = γ/(1−a))
  KIỂM TRA: tổng ra khỏi mạng = tổng nguồn
ỔN ĐỊNH: mọi ρi = λi/μi < 1  (ci server: λi < ci·μi)
  μ chung: μ > max λi ;  theo x: giải từng ρi < 1, lấy giao
TÌM x: λD = Σ (tỉ lệ nhánh tới D)·λnút (+ nguồn đi thẳng) → giải λD1 = k·λD2
Burke: M/M/1 ổn định, vào Poisson λ → ra Poisson λ
Jackson: mỗi nút coi như M/M/1 độc lập với λi
```

Lỗi hay mắc:
- Quên nhánh "phần còn lại" (chỉ cộng các nhánh có ghi %).
- Cộng nhầm lưu lượng của nguồn vào nút mà nguồn không đi qua.
- Quên rằng nguồn có thể đi thẳng tới đích (S2 → D2 25% ở đề 20202).
- Không kiểm tra tổng vào = tổng ra.
