# GK4 — Mạng hàng đợi (2): N, T của mạng, xác suất trạng thái, trễ theo đường, KIA, trễ đầu cuối

Nguồn: slide thầy Dũng chương 3 tr. 80–107 (định lý Jackson, KIA, áp dụng chuyển mạch gói, bài tập 3.3); đề 20202, 20221Q; bài tập cô Lan.
Điều kiện trước: đã lập được phương trình lưu lượng (GK3).
Qua buổi khi: làm trọn một câu mạng hàng đợi kiểu đề thi trong ≤ 25 phút.

## 1. Khuôn tính hiệu năng mạng (sau khi có mọi λi)

1. Mỗi nút: ρi = λi/μi (kiểm tra < 1).
2. Mỗi nút M/M/1: **Ni = ρi/(1 − ρi)**; **Ti = 1/(μi − λi)** (thời gian một yêu cầu ở tại nút i trong **một lần** đi qua).
   Nút có ci server (M/M/c) thì dùng công thức M/M/c ở GK2 cho nút đó.
3. **N mạng = Σ Ni.**
4. **T mạng = N mạng / γ**, với γ = tổng lưu lượng từ ngoài đi vào mạng (Little cho cả mạng). KHÔNG chia cho Σλi.
5. **Xác suất trạng thái** (Jackson): P(n1, n2, …, nk) = Π (1 − ρi)·ρi^ni.
   - Mạng rỗng: P(0, …, 0) = Π (1 − ρi).
   - Có đúng 1 yêu cầu trong cả mạng: P = Π(1 − ρi) × Σ ρi.
6. **Trễ theo đường (nguồn S → đích D):**
   a. Liệt kê mọi đường đi từ S tới D, tính xác suất mỗi đường = tích các tỉ lệ rẽ nhánh dọc đường (hoặc lưu lượng đường = λS × xác suất).
   b. Trễ mỗi đường = tổng Ti của các nút trên đường.
   c. **Trễ S → D = trung bình có trọng số** = Σ (lưu lượng đường × trễ đường) / Σ lưu lượng đường.
   (Đường có vòng hồi tiếp lặp vô hạn thì không liệt kê được — khi đó hỏi "trễ trung bình qua mạng" thì dùng T = N/γ.)

## 2. KIA — xấp xỉ độc lập Kleinrock (mạng nhiều luồng, mỗi luồng đi đường cố định)

Khuôn giải:
1. Tốc độ trên liên kết (i, j): λij = tổng tốc độ xs của các luồng đi qua liên kết đó.
2. μij = Cij/L (dung lượng liên kết / độ dài gói).
3. Nij = λij/(μij − λij); N = Σ Nij.
4. γ = Σ xs (tổng tốc độ mọi luồng). **T hệ thống = N/γ**.
5. Có trễ lan truyền dij: T = (1/γ)·Σ [λij/(μij − λij) + λij·dij].
6. Trễ của một luồng theo đường p: Tp = Σ_{(i,j)∈p} [1/(μij − λij) + dij].

## 3. Trễ đầu cuối trong chuyển mạch gói "store-and-forward" (slide tr. 97–101)

- Thời gian phát gói trên liên kết i: tsi = L/Ci. Trễ lan truyền: tpi = di/vp.
- Không có hàng đợi (mạng rỗi): **de2e = Σ (L/Ci + tpi)**.
- Có hàng đợi: de2e = Σ (L/Ci + tpi + tqi), với tqi là thời gian chờ tại nút i (lấy Tq của M/M/1 nút đó).
- Câu hỏi hay gặp "vì sao chia bản tin thành nhiều gói?" → giảm trễ đầu cuối (các gói đi gối đầu nhau trên các chặng) và tăng độ tin cậy (lỗi chỉ phải gửi lại một gói nhỏ).

## Bài mẫu 1 — slide thầy Thanh (tiếp bài mẫu 1 của GK3)

λ = 30, μ1 = μ2 = 100 → λ1 = 80, λ2 = 60, ρ1 = 0,8, ρ2 = 0,6.
- N1 = 0,8/0,2 = 4; N2 = 0,6/0,4 = 1,5 → **N mạng = 5,5 gói**.
- **T mạng = 5,5/30 ≈ 0,183 s** (chia cho λ = 30 nguồn, không chia cho 80 + 60).

## Bài mẫu 2 — slide thầy Dũng tr. 87 (tiếp bài mẫu 2 GK3)

λ1 = 20, λ2 = λ3 = 10, λ4 = 4; ρ = 0,6; 0,4; 0,5; 0,24.
- N1 = 1,5; N2 ≈ 0,667; N3 = 1; N4 ≈ 0,316 → **N = 3,482 yêu cầu**.
- Xác suất mạng không có yêu cầu nào: P0 = 0,4·0,6·0,5·0,76 = **0,0912**.
- Xác suất cả mạng có đúng 1 yêu cầu: 0,0912 × (0,6 + 0,4 + 0,5 + 0,24) = 0,0912 × 1,74 ≈ **0,159**.
- **T = N/γ4 = 3,482/4 ≈ 0,871 s**.

## Bài mẫu 3 — đề cuối kỳ 20221Q câu 1 (tiếp bài mẫu 3 GK3)

ρ1 = 0,5; ρ2 = 0,8; ρ3 = 0,4; γ = 2000.
- Xác suất mỗi server có đúng 2 yêu cầu: p(2,2,2) = (1 − 0,5)·0,5² × (1 − 0,8)·0,8² × (1 − 0,4)·0,4² = 0,125 × 0,128 × 0,096 ≈ **0,00154**.
- N = 1 + 4 + 0,667 = **5,667 yêu cầu**.
- T = 5,667/2000 ≈ **2,83 ms**.

## Bài mẫu 4 — đề cuối kỳ 20202 câu 1.2 (tiếp bài mẫu 4 GK3; x = 50%, y = 20%)

μ: Q1 = 200, Q2 = 250, Q3 = 1/0,006 ≈ 166,7, Q4 = 1/0,007 ≈ 142,9, Q5 = 200, Q6 ≈ 166,7 (yêu cầu/s).
- λ2 = 25; λ1 = 30; λ3 = 0,8·30 = 24; λ4 = λ6 = 26; λ5 = 24 + 15 = 39.
- ρ1 = 0,15; ρ2 = 0,1; ρ3 = 0,144; ρ4 = 0,182; ρ5 = 0,195; ρ6 = 0,156.
- **N mạng = Σ ρi/(1 − ρi) ≈ 1,105 yêu cầu.**
- **Xác suất mạng rỗng = Π(1 − ρi) ≈ 0,364.**
- Ti (ms): T1 ≈ 5,882; T2 ≈ 4,444; T3 ≈ 7,009; T5 ≈ 6,211.
- Đường S1 → D1:
  - S1 → Q1 → Q3 → Q5: xác suất 0,5·0,8 = 0,4 (20 yêu cầu/s), trễ T1 + T3 + T5 ≈ 19,10 ms.
  - S1 → Q2 → Q1 → Q3 → Q5: xác suất 0,5·0,2·0,8 = 0,08 (4 yêu cầu/s), trễ T2 + T1 + T3 + T5 ≈ 23,55 ms.
  - **Trễ S1 → D1 = (20·19,10 + 4·23,55)/24 ≈ 19,84 ms.**

## Bài mẫu 5 — bài tập cô Lan, mạng có nút M/M/c

Hình: chương trình đến λ = 5/s vào khối quản lý bộ nhớ (M/M/1, μm = 6,25); sau đó vào khối CPU gồm 2 CPU (M/M/2, μCPU = 8 mỗi CPU); ra khỏi CPU: 0,5 hoàn thành ra ngoài, 0,5 sang khối I/O (M/M/1, μIO = 8); I/O xong quay về CPU.
- Phương trình lưu lượng: λCPU = 5 + λIO; λIO = 0,5λCPU → **λCPU = 10, λIO = 5**; λm = 5.
- Bộ nhớ: ρm = 0,8 → Nm = 4.
- I/O: ρIO = 0,625 → NIO ≈ 1,667.
- CPU (M/M/2): a = 10/8 = 1,25; ρ = 0,625; p0CPU = 1/(1 + 1,25 + 1,25²/(2·0,375)) ≈ 0,2308; C ≈ 0,481; Nq ≈ 0,801; NCPU = 0,801 + 1,25 ≈ 2,051.
- Xác suất cả hệ rỗi: (1 − 0,8) × 0,2308 × (1 − 0,625) ≈ **0,0173**.
- Xác suất 1 task ở bộ nhớ, 0 ở CPU, 2 ở I/O: (0,2·0,8) × 0,2308 × (0,375·0,625²) ≈ **0,0054**.

## Bài mẫu 6 — bài tập 3.3 của thầy Dũng (mạng LAN có ARQ)

Hình (cắt từ 03-HangDoi.pdf trang 107): S1 —L1→ R1 —L2→ R2 —L3→ D; S2 —L4→ R2. λ1 = 240 gói/phút = 4 gói/s; λ2 = 120 gói/phút = 2 gói/s. 1/μ1 = 0,2 s → μ1 = 5; 1/μ2 = 0,1 s → μ2 = 10. Trên L3 gói lỗi với pe = 10%. Giữa D và S1, S2 dùng ARQ (gói lỗi phải gửi lại từ nguồn).

Khuôn: ARQ đầu cuối → mỗi gói phải đi trung bình 1/(1 − pe) lần → lưu lượng thực qua các nút tăng 1/(1 − pe) lần.
- λR1 = 4/0,9 ≈ 4,444; λR2 = (4 + 2)/0,9 ≈ 6,667.
- ρ1 ≈ 0,889 → N1 = **8 gói**; ρ2 ≈ 0,667 → N2 = **2 gói**; số gói trong mạng = **10**.
- T1 = 1/(5 − 4,444) = **1,8 s**; T2 = 1/(10 − 6,667) = **0,3 s**.
- S1 → D: mỗi lần thử đi qua R1 và R2, trung bình 1/0,9 lần: (1,8 + 0,3)/0,9 ≈ **2,33 s**.
- S2 → D: 0,3/0,9 ≈ **0,33 s**.

> Nếu đề hiểu ARQ chỉ giữa R2 và D (gửi lại từ R2) thì chỉ R2 có lưu lượng tăng; R1 có λ = 4, N1 = 4, T1 = 1 s. Ghi rõ cách hiểu khi làm bài.

## Bài tự luyện (có ô chấm)

1. Mạng bài tự luyện 5 của GK3 (λ1 ≈ 153,8; λ2 ≈ 107,7; λ3 ≈ 46,2) với μ = 200 cho cả ba nút. Tính N mạng, T mạng, xác suất mạng rỗng, xác suất trạng thái (1, 0, 2).
2. Mạng bài tự luyện 6 của GK3 với x = 50%. Tính N mạng và T mạng.
3. Ba luồng đi đường cố định: luồng 1 A→B→C 50 gói/s; luồng 2 A→B→D 30 gói/s; luồng 3 B→C 40 gói/s. μAB = 100, μBC = 150, μBD = 80 gói/s. Dùng KIA tính N, T của hệ thống và trễ của từng luồng. Nếu mỗi liên kết có thêm trễ lan truyền 1 ms thì T hệ thống bằng bao nhiêu?
4. Gói 12000 bit đi qua 3 liên kết 10 Mbps, mỗi liên kết trễ lan truyền 2 ms, mạng rỗi. Tính trễ đầu cuối.
5. Bản tin 120000 bit đi qua 3 liên kết như bài 4. So sánh trễ đầu cuối khi gửi nguyên bản tin và khi chia thành 10 gói bằng nhau (bỏ qua phần đầu gói).

## Đáp án

1. ρ ≈ 0,769; 0,538; 0,231. N ≈ 3,333 + 1,167 + 0,300 = **4,80**; T = 4,8/100 = **48 ms**; P0 = 0,231·0,462·0,769 ≈ **0,0819**; P(1,0,2) = (0,231·0,769)·0,462·(0,769·0,231²) ≈ **0,0034**.
2. λ1 = 45, λ2 = 30, λ3 = 75; ρ = 0,9; 0,75; 0,9375 → N = 9 + 3 + 15 = **27**; T = 27/60 = **0,45 s**.
3. λAB = 80, λBC = 90, λBD = 30. N = 80/20 + 90/60 + 30/50 = **6,1**; γ = 120; T = 6,1/120 ≈ **50,8 ms**. Luồng 1: 1/20 + 1/60 ≈ **66,7 ms**; luồng 2: 1/20 + 1/50 = **70 ms**; luồng 3: 1/60 ≈ **16,7 ms**. Thêm lan truyền: T = (6,1 + 200·0,001)/120 = **52,5 ms**.
4. 3 × (12000/10⁷ + 0,002) = 3 × 3,2 ms = **9,6 ms**.
5. Nguyên bản tin: 3 × (12 ms + 2 ms) = **42 ms**. Chia 10 gói (mỗi gói 1,2 ms trên mỗi liên kết): gói cuối tới sau 3·2 ms + (3 + 10 − 1)·1,2 ms = **20,4 ms** → chia gói nhanh hơn gấp đôi.

## Trang sổ tay phòng thi (trang 4)

```
HIỆU NĂNG MẠNG (sau khi có λi):
  Ni = ρi/(1−ρi)     Ti = 1/(μi−λi)   (nút M/M/c: dùng công thức M/M/c)
  N mạng = Σ Ni      T mạng = N mạng / γ   (γ = tổng nguồn, KHÔNG phải Σλi)
  P(n1,…,nk) = Π (1−ρi)ρi^ni      rỗng: Π(1−ρi)     đúng 1 yêu cầu: Π(1−ρi)·Σρi
  TRỄ S→D: liệt kê đường, xác suất đường = tích tỉ lệ; trễ đường = Σ Ti
           T(S→D) = Σ(lưu lượng đường × trễ đường) / Σ lưu lượng đường
KIA: λij = Σ luồng qua (i,j)   N = Σ λij/(μij−λij)   T = N/γ (+ Σλij·dij/γ)
     trễ luồng p = Σ [1/(μij−λij) + dij]
STORE-AND-FORWARD: de2e = Σ (L/Ci + tpi + tqi)
ARQ đầu cuối lỗi pe: lưu lượng qua nút ×1/(1−pe), trễ S→D = (Σ Ti)/(1−pe)
```

Lỗi hay mắc:
- T mạng = N/Σλi (sai) → phải chia cho tổng lưu lượng nguồn γ.
- Trễ S→D lấy trung bình cộng các đường mà không nhân trọng số lưu lượng.
- Quên rằng Ti là thời gian ở nút cho mỗi lần đi qua; đường đi qua nút 2 lần thì cộng 2 lần.
- Nút có nhiều server mà vẫn dùng công thức M/M/1.
