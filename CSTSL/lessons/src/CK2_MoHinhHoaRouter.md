# CK2 — Đề "một bài lớn": mô hình hoá mạng router → hàng đợi → định tuyến với chi phí tự tính → điều khiển luồng

Kiểu đề này (20211, 20241) cho **một sơ đồ mạng router thật**, rồi hỏi liên tiếp: mô hình hoá thành mạng hàng đợi, tính λ, μ, thời gian tại từng router, trễ từ nguồn tới đích, dựng đồ thị định tuyến với chi phí tự tính rồi chạy Dijkstra, cuối cùng là Stop-and-Wait trên một tuyến.
Nguồn: đề cuối kỳ 20211 (CK_20211.pdf), 20241 (trang 23–27 của CSTSL_20251_ALL_re.pdf); slide thầy Dũng tr. 66 (mô hình hoá nút chuyển mạch gói), tr. 97–101 (trễ đầu cuối).
Qua buổi khi: tự làm lại trọn đề 20211 trong ≤ 50 phút.

## 1. Khuôn mô hình hoá

1. **Mỗi giao diện đầu ra của router = một hàng đợi M/M/1** (router có hai đường ra thì vẽ hai server bên trong router đó, ví dụ C→D và C→E).
2. **μ của server = dung lượng liên kết ra / độ dài gói**: μ = C/L (gói/s). Đề cho dung lượng bằng pps thì μ = số đó luôn.
3. **λ của server = tổng các luồng đi ra cổng đó** (cộng các nguồn đổ vào, nhân xác suất rẽ nhánh). Lập như phương trình lưu lượng (GK3).
4. Vẽ sơ đồ hàng đợi: nguồn → server → server → … → đích, ghi λ, μ cạnh mỗi server, ghi tỉ lệ rẽ nhánh.
5. Thời gian tại router: Ti = 1/(μi − λi).
6. Trễ nguồn → đích: liệt kê các đường, trung bình có trọng số theo xác suất đường (GK4).

## 2. Khuôn dựng đồ thị định tuyến với chi phí tự tính

| Đề nói tiêu chí | Chi phí trên cạnh (u → v) |
|---|---|
| "tổng thời gian chờ tại các nút mạng ngắn nhất" | thời gian tại hàng đợi của cổng ra u→v: 1/(μ − λ) |
| "thời gian lan truyền" (bỏ qua xử lý) | d/v, với v = c/n (n = chiết suất) — tỉ lệ với khoảng cách, nên có thể dùng luôn km |
| băng thông + khoảng cách / mất gói (chuẩn hoá) | W = α·|d| + β·(1/|BW|) với |BW| = BW/BWmax, |d| = d/dmax, α + β = 1 |
| cạnh từ nguồn (máy tính) vào router đầu tiên | 0 (không có hàng đợi) nếu đề không cho gì |

Cạnh chỉ đi theo **chiều luồng dữ liệu** (đồ thị có hướng). Sau khi có đồ thị thì chạy Dijkstra như CK1.

## 3. Stop-and-Wait trên tuyến nhiều chặng (chỉ kiểm soát ở hai đầu)

- Store-and-forward: tổng thời gian phát = Σ L/Ci (mỗi chặng phát lại gói một lần).
- Trễ lan truyền một chiều = Σ di / v; v = c/n = 3·10⁸/n.
- ACK nhỏ, bỏ qua thời gian phát ACK: TΣ = Σ L/Ci + 2·Σ di/v.
- Hiệu suất tại nguồn: η = (L/C₁)/TΣ (thời gian nguồn bận phát chia cho cả chu kỳ).

## Bài mẫu 1 — đề cuối kỳ 20211 (trọn đề)

Đề (hình: CK_20211.pdf trang 1): 6 router A, B, C, D, E, F và 5 máy S1…S5 gửi về server Dest. S1, S2 → A; A → B; S3, S4 → B; B → C; S5 → C; C → D (60%), C → E (40%); D → Dest; E → F → Dest. γ1 = 100, γ2 = 50, γ3 = 80, γ4 = 70, γ5 = 50 pps. C_AB = 200 kbps, C_BC = 400 kbps, C_CE = C_CD = 250 kbps, C_EF = 200 kbps, C_D-Dest = 250 kbps, C_F-Dest = 200 kbps. L = 1000 bit. Không mất gói, bộ đệm đủ lớn.

**Ý 1 (2đ) — mô hình hoá.** Các server: A (cổng A→B), B (B→C), CD (C→D), CE (C→E), D (D→Dest), E (E→F), F (F→Dest). Vẽ: S1, S2 → [A] → (+S3, S4) → [B] → (+S5) → tách 0,6 → [CD] → [D] → Dest; 0,4 → [CE] → [E] → [F] → Dest.

**Ý 2 (1đ) — tốc độ tới λ:**
- λA = 100 + 50 = **150**; λB = 150 + 80 + 70 = **300**.
- λCD = 0,6·(300 + 50) = **210**; λCE = 0,4·350 = **140**.
- λD = **210**; λE = λF = **140** (pps).

**Ý 3 (1đ) — tốc độ phục vụ μ = C/L:** μA = **200**; μB = **400**; μCD = μCE = **250**; μD = **250**; μE = **200**; μF = **200** (pps).

**Ý 4 (1đ) — thời gian tại từng server:** TA = 1/50 = **20 ms**; TB = 1/100 = **10 ms**; TCD = 1/40 = **25 ms**; TCE = 1/110 ≈ **9,09 ms**; TD = 1/40 = **25 ms**; TE = 1/60 ≈ **16,67 ms**; TF = 1/60 ≈ **16,67 ms**.

**Ý 5 (1đ) — trễ S1 → Dest (bỏ trễ lan truyền):**
- Đường 1: A → B → CD → D: 20 + 10 + 25 + 25 = 80 ms, xác suất 0,6.
- Đường 2: A → B → CE → E → F: 20 + 10 + 9,09 + 16,67 + 16,67 = 72,42 ms, xác suất 0,4.
- T = 0,6·80 + 0,4·72,42 ≈ **76,97 ms**.

**Ý 6 (2đ) — Dijkstra từ S3, chi phí = thời gian chờ tại nút (ms):** S3→B 0; B→C 10; C→E 9,09; C→D 25; E→F 16,67; F→Dest 16,67; D→Dest 25.

| Bước | Chốt | B | C | D | E | F | Dest |
|---|---|---|---|---|---|---|---|
| 0 | S3 | 0, S3 | ∞ | ∞ | ∞ | ∞ | ∞ |
| 1 | B | × | 10, B | ∞ | ∞ | ∞ | ∞ |
| 2 | C | × | × | 35, C | 19,09, C | ∞ | ∞ |
| 3 | E | × | × | 35, C | × | 35,76, E | ∞ |
| 4 | D | × | × | × | × | 35,76, E | 60, D |
| 5 | F | × | × | × | × | × | 52,42, F |
| 6 | Dest | | | | | | 52,42, F |

Đường định tuyến (tô đậm): **S3 → B → C → E → F → Dest**, tổng ≈ **52,42 ms** (đi qua D là 60 ms).

**Ý 7 (2đ) — Stop-and-Wait S3 → B → C → D → Dest, có trễ lan truyền:** mỗi chặng 6 km, n = 1,1 → v = 3·10⁸/1,1 ≈ 2,727·10⁸ m/s.
- Trễ lan truyền một chiều: 24 km / v = **88 µs**.
- Thời gian phát: chặng B→C 1000/400k = 2,5 ms; C→D 4 ms; D→Dest 4 ms; chặng S3→B: **đề không cho dung lượng**. Tài liệu tổng hợp lấy 80 kbps (= γ3·L) → 12,5 ms. Dùng giả thiết này và **ghi rõ giả thiết** khi làm bài.
- TΣ = 12,5 + 2,5 + 4 + 4 + 2·0,088 = 23,176 ms.
- η = 12,5/23,176 ≈ **53,9%**.

## Bài mẫu 2 — đề cuối kỳ 20241 (câu 1–4)

Đề (hình: trang 23–24 của CSTSL_20251_ALL_re.pdf): S1 phát γ1 = 1800 pps: 70% → R1, 30% → R3. R1 → R2 (3000 pps, 30 km); R2 → R4 40% (1000 pps, 75 km), R2 → R5 60% (2000 pps, 150 km); R4 → D (1000 pps, 300 km); R5 → R6 (2000 pps, 30 km); S2 (γ2 = 1000 pps) → R6; R6 → D (4000 pps, 30 km); R3 → D (1000 pps, 450 km); S1–R1 15 km; S1–R3 10 km. Chiết suất 1,46. Dung lượng các chặng cho sẵn bằng pps nên μ = số đó.

**Câu 1 — mô hình hoá (λ, μ):**
- R1 (cổng R1→R2): λ = 0,7·1800 = **1260**, μ = 3000.
- R2→R4: λ = 0,4·1260 = **504**, μ = 1000. R2→R5: λ = 0,6·1260 = **756**, μ = 2000.
- R4 (→D): λ = **504**, μ = 1000. R5 (→R6): λ = **756**, μ = 2000.
- R6 (→D): λ = 756 + 1000 = **1756**, μ = 4000. R3 (→D): λ = 0,3·1800 = **540**, μ = 1000.
- Nút đích D (hình ghi μD = 1000 pps): tổng lưu lượng tới D = 1800 + 1000 = 2800 pps > μD → nếu đưa D vào thì hàng đợi tại D **không ổn định**. Vì vậy (giống lời giải tham khảo) coi D là đích hấp thụ, không tính vào mạng hàng đợi; khi làm bài nên ghi một dòng nhận xét này.

**Câu 2 — thời gian tại từng router (s):** T1 = 1/1740; T(R2→R4) = 1/496; T(R2→R5) = 1/1244; T4 = 1/496; T5 = 1/1244; T6 = 1/2244; T3 = 1/460.

**Câu 3 — trễ trung bình S1 → D:**
- p1: R1 → R2→R4 → R4: lưu lượng 504, trễ 1/1740 + 1/496 + 1/496 ≈ 4,607 ms.
- p2: R1 → R2→R5 → R5 → R6: lưu lượng 756, trễ 1/1740 + 1/1244 + 1/1244 + 1/2244 ≈ 2,628 ms.
- p3: R3: lưu lượng 540, trễ 1/460 ≈ 2,174 ms.
- T = (504·4,607 + 756·2,628 + 540·2,174)/1800 ≈ **3,05 ms**.

> Lời giải trong tài liệu tổng hợp quên cộng T6 ở đường p2 (đường này có đi qua R6) nên ra ≈ 2,86 ms.

**Câu 4 — Dijkstra từ S1, chi phí = thời gian lan truyền** (bỏ xử lý). Vì v = c/1,46 như nhau trên mọi chặng, chi phí tỉ lệ khoảng cách → tính bằng km rồi đổi sang thời gian ở cuối:

| Bước | Chốt | R1 | R2 | R3 | R4 | R5 | R6 | D |
|---|---|---|---|---|---|---|---|---|
| 0 | S1 | 15, S1 | ∞ | 10, S1 | ∞ | ∞ | ∞ | ∞ |
| 1 | R3 | 15, S1 | ∞ | × | ∞ | ∞ | ∞ | 460, R3 |
| 2 | R1 | × | 45, R1 | × | ∞ | ∞ | ∞ | 460, R3 |
| 3 | R2 | × | × | × | 120, R2 | 195, R2 | ∞ | 460, R3 |
| 4 | R4 | × | × | × | × | 195, R2 | ∞ | 420, R4 |
| 5 | R5 | × | × | × | × | × | 225, R5 | 420, R4 |
| 6 | R6 | × | × | × | × | × | × | 255, R6 |
| 7 | D | | | | | | | 255, R6 |

Đường chọn: **S1 → R1 → R2 → R5 → R6 → D**, 255 km → 255·10³/(3·10⁸/1,46) ≈ **1,241 ms**.

> Tài liệu tổng hợp dùng thời gian chờ 1/(μ − λ) làm chi phí — sai tiêu chí đề ("thời gian lan truyền").

## Bài mẫu 3 — chi phí chuẩn hoá (đề 26/12/2015, câu 3)

Đồ thị A, B, C, D, E, F. Hai tiêu chí: băng thông và quãng đường, vai trò như nhau.
- Chuẩn hoá: |BW| = BW/BWmax; |d| = d/dmax.
- Hàm giá: **W = α·|d| + β·(1/|BW|)**, α + β = 1; vai trò như nhau → α = β = 0,5. (Băng thông càng lớn càng tốt → dùng nghịch đảo; quãng đường càng nhỏ càng tốt → dùng trực tiếp.)
- Với trọng số cho sẵn ở ý 3.2: μ(AB) = 0,45; μ(AD) = 0,43; μ(AE) = 2,16; μ(BE) = 1,92; μ(BC) = 1,4; μ(ED) = 2,3; μ(EC) = 1,31; μ(DF) = 10,6; μ(CF) = 1,35. Bellman-Ford từ A:

| h | B | C | D | E | F |
|---|---|---|---|---|---|
| 1 | 0,45, A | ∞ | 0,43, A | 2,16, A | ∞ |
| 2 | 0,45, A | 1,85, B | 0,43, A | 2,16, A | 11,03, D |
| 3 | 0,45, A | 1,85, B | 0,43, A | 2,16, A | 3,2, C |
| 4 | không đổi | | | | |

Cây: A–B, A–D, A–E, B–C, C–F.
- Ý 3.3: liên kết BC đứt → chạy lại: C = 3,47 (qua E), F = 4,82 (qua C). Cây mới: A–B, A–D, A–E, E–C, C–F.

## Bài tự luyện

1. Làm lại trọn đề 20211 (ý 1–6) mà không nhìn bài mẫu, bấm giờ 40 phút.
2. Đề 20211: nếu C_BC giảm còn 320 kbps thì T_B và trễ S1 → Dest bằng bao nhiêu? Đường định tuyến từ S3 có đổi không?
3. Đề 20241: tính trễ trung bình từ S2 tới D.
4. Đề 20241: nếu tiêu chí định tuyến là tổng thời gian chờ tại các router (cạnh u→v có chi phí 1/(μ − λ) của cổng u→v), đường từ S1 tới D là gì?

## Đáp án

2. μB = 320 → TB = 1/(320 − 300) = **50 ms**. Đường 1: 20 + 50 + 25 + 25 = 120 ms; đường 2: 20 + 50 + 9,09 + 16,67 + 16,67 = 112,42 ms; T = 0,6·120 + 0,4·112,42 ≈ **116,97 ms**. Định tuyến từ S3: cả hai đường đều thêm 40 ms ở B nên **không đổi** (S3→B→C→E→F→Dest).
3. S2 chỉ đi qua R6: T = 1/2244 s ≈ **0,446 ms**.
4. Chi phí (ms): S1→R1 0, S1→R3 0, R1→R2 1/1740 ≈ 0,575; R2→R4 1/496 ≈ 2,016; R2→R5 1/1244 ≈ 0,804; R4→D 2,016; R5→R6 0,804; R6→D 1/2244 ≈ 0,446; R3→D 1/460 ≈ 2,174. Ba đường: qua R4 ≈ 0,575 + 2,016 + 2,016 = 4,607 ms; qua R5, R6 ≈ 0,575 + 0,804 + 0,804 + 0,446 = 2,628 ms; qua R3 = **2,174 ms** → nhỏ nhất, chọn **S1 → R3 → D**.

## Trang sổ tay phòng thi (trang 7)

```
MÔ HÌNH HOÁ: mỗi cổng ra router = 1 M/M/1;  μ = C/L (bit/s ÷ bit = gói/s)
  λ cổng = tổng luồng đi ra cổng đó (cộng nguồn, nhân tỉ lệ rẽ)
  Ti = 1/(μi − λi);  trễ S→D = Σ (lưu lượng đường × trễ đường)/Σ lưu lượng
CHI PHÍ ĐỊNH TUYẾN: thời gian chờ → 1/(μ−λ) của cổng ra;  lan truyền → d/v (dùng km)
  chuẩn hoá: W = α·|d| + β/|BW|, α+β=1;  cạnh nguồn→router đầu: 0
STOP&WAIT nhiều chặng: TΣ = Σ L/Ci + 2·Σ di/v;  v = 3·10⁸/n;  η = (L/C₁)/TΣ
Thiếu dữ liệu: GHI RÕ GIẢ THIẾT rồi mới tính
```
