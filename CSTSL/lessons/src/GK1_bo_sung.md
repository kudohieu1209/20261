# GK1 — PHẦN BỔ SUNG THEO SLIDE THẦY DŨNG (chương 2 + đầu chương 3)

> Ghép vào GK1 hiện có thành một mục mới tên "Bổ sung theo slide thầy Dũng", đặt NGAY TRƯỚC trang "Sổ tay phòng thi".
> Thêm các dòng sổ tay ở cuối file này vào trang sổ tay; thêm bài 11–15 vào phần bài tự luyện và đáp án tương ứng.

## B1. Tính chất ghép và tách luồng Poisson (slide ch.2, tr. 47–49)

Khuôn giải:
- **Ghép:** nhiều luồng Poisson λ1, λ2, …, λn đi chung một chỗ → vẫn là Poisson với λ = λ1 + λ2 + … + λn.
- **Tách:** một luồng Poisson λ, mỗi yêu cầu đi nhánh i với xác suất p_i → nhánh i là Poisson với tốc độ λ·p_i.
- Sau khi ghép hoặc tách xong thì dùng lại dạng A hoặc dạng B như bình thường.

Bài mẫu (slide): Ô tô qua nút giao 6 xe/phút, xe máy 9 xe/phút, đều Poisson.
- Tổng phương tiện: λ = 6 + 9 = **15 xe/phút**, vẫn là Poisson.
- Thêm (tự đặt): xác suất trong 10 giây không có xe nào → λt = 15 · (10/60) = 2,5 → e^(−2,5) ≈ **0,082**.

Bài mẫu (slide): Nhà hộ sinh có 12 bé/tuần, 55% trai, 45% gái.
- Bé trai: 12 · 0,55 = **6,6 bé/tuần**; bé gái: 12 · 0,45 = **5,4 bé/tuần**, đều là Poisson.
- Thêm: xác suất một tuần không có bé trai nào = e^(−6,6) ≈ **0,00136**.

## B2. Hai ví dụ Poisson trong slide thầy Dũng

Bài mẫu (slide ch.2 tr. 44): Tổng đài 1080 nhận trung bình 10 cuộc/phút, Poisson. Xác suất có 15 cuộc trong 2 phút?
- m = λt = 10 · 2 = 20.
- P(15) = 20^15 · e^(−20) / 15! ≈ **0,0516**.

Bài mẫu (slide ch.2 tr. 46): Xe buýt có tần suất 5 phút/chuyến (Poisson). Một người vừa lỡ chuyến. Xác suất đợi chuyến sau ít hơn 3 phút?
- "5 phút/chuyến" là thời gian trung bình giữa hai chuyến → λ = 1/5 chuyến/phút.
- P(T < 3) = 1 − e^(−3/5) = 1 − e^(−0,6) ≈ **0,451**.
- Bẫy: "5 phút/chuyến" KHÔNG phải λ = 5.

## B3. Bảng các phân bố (slide ch.2 tr. 23–31) — chỉ cần tra khi đề hỏi E, Var

| Phân bố | Loại biến | Công thức | E(x) | Var(x) |
|---|---|---|---|---|
| Bernoulli | rời rạc (0/1) | P(1) = p, P(0) = 1 − p | p | p(1 − p) |
| Nhị thức (n, p) | rời rạc | P(k) = C(n,k) p^k (1 − p)^(n−k) | np | np(1 − p) |
| Đều [a, b] | liên tục | f(x) = 1/(b − a) | (a + b)/2 | (b − a)²/12 |
| Chuẩn (μ, σ) | liên tục | f(x) = e^(−(x−μ)²/(2σ²)) / (σ√(2π)) | μ | σ² |
| Mũ (λ) | liên tục | f(x) = λe^(−λx) | 1/λ | 1/λ² |
| Poisson (α) | rời rạc | P(k) = α^k e^(−α)/k! | α | α |
| Gamma (n, λ) | liên tục | f(x) = λ^n x^(n−1) e^(−λx)/(n−1)! | n/λ | n/λ² |

Ghi nhớ thêm:
- Tổng của n biến mũ độc lập cùng tham số λ là biến Gamma(n, λ) (Định lý 2.1).
- Nhị thức = tổng của n lần thử Bernoulli.

## B4. Xác suất theo thời gian trong M/M/1 (slide ch.3 tr. 30–33)

Hai công thức thêm cho hàng đợi M/M/1 (thầy Dũng viết M/M/1/∞):

| Đề hỏi | Công thức |
|---|---|
| xác suất thời gian **trong hệ thống** (từ lúc vào đến lúc phục vụ xong) không quá t | P(T ≤ t) = 1 − e^(−(μ−λ)t) |
| xác suất thời gian **chờ trong hàng đợi** không quá t | P(Tq ≤ t) = 1 − ρ·e^(−(μ−λ)t) |

Bài mẫu (slide ch.3 tr. 34): Khách vào quầy tính tiền siêu thị mini theo Poisson 40 người/giờ, thời gian phục vụ phân bố mũ trung bình 1 phút, một quầy, chỗ xếp hàng không giới hạn.
- Đổi về phút: λ = 40/60 = 2/3 người/phút; μ = 1 người/phút; ρ = 2/3.
- (a) Thời gian chờ trung bình (trong hàng đợi): Tq = ρ/(μ − λ) = (2/3)/(1/3) = **2 phút**.
  (Thời gian ở lại tổng cộng T = 1/(μ − λ) = 3 phút.)
- (b) Từ lúc xếp hàng đến lúc trả tiền xong không quá 1,5 phút: đó là T ≤ 1,5 →
  P = 1 − e^(−(1/3)·1,5) = 1 − e^(−0,5) ≈ **0,393**.

Ký hiệu theo thầy Dũng (dùng thống nhất từ đây): N, Nq, Ns (số yêu cầu trong hệ thống / hàng đợi / đang phục vụ); T, Tq, Ts (thời gian tương ứng); ρ = λ/(cμ) là tải; với 1 server thì ρ = λ/μ.

## Thêm vào trang Sổ tay phòng thi

```
GHÉP/TÁCH POISSON: ghép → λ = Σλi (vẫn Poisson); tách theo xác suất pi → λ·pi (vẫn Poisson)
"x phút/chuyến" = thời gian TB  →  λ = 1/x
M/M/1: P(T ≤ t) = 1 − e^(−(μ−λ)t)      P(Tq ≤ t) = 1 − ρ·e^(−(μ−λ)t)
Phân bố mũ: E = 1/λ, Var = 1/λ²;  Poisson: E = Var = α;  Nhị thức: E = np, Var = np(1−p)
```

## Bài tự luyện thêm (đánh số tiếp 11–15, có ô chấm như các bài khác)

11. Router nhận ba luồng Poisson 120, 200 và 80 gói/s. Tính xác suất trong 5 ms không có gói nào đến router.
12. Một luồng Poisson 50 gói/s đi vào router; 30% số gói đi cổng 1, còn lại đi cổng 2. Xác suất trong 100 ms cổng 1 nhận đúng 2 gói?
13. Taxi đến một điểm đón với tần suất trung bình 4 phút/xe (Poisson). Xác suất phải đợi lâu hơn 6 phút?
14. Một server M/M/1 có λ = 30 yêu cầu/s, μ = 50 yêu cầu/s. Tính xác suất một yêu cầu ở lại hệ thống không quá 100 ms, và xác suất phải chờ trong hàng đợi lâu hơn 100 ms.
15. Biến X phân bố mũ có E(X) = 0,2 s. Tính Var(X) và P(X > 0,5 s).

## Đáp án thêm

11. λ = 120 + 200 + 80 = 400 gói/s; λt = 400 · 0,005 = 2 → e^(−2) ≈ **0,135**.
12. Cổng 1: λ1 = 50 · 0,3 = 15 gói/s; m = 15 · 0,1 = 1,5 → P(2) = 1,5² · e^(−1,5)/2 ≈ **0,251**.
13. λ = 1/4 xe/phút → P(T > 6) = e^(−6/4) = e^(−1,5) ≈ **0,223**.
14. μ − λ = 20/s. P(T ≤ 0,1) = 1 − e^(−2) ≈ **0,865**. P(Tq > 0,1) = ρ·e^(−2) = 0,6 · 0,1353 ≈ **0,081**.
15. λ = 5/s; Var = 1/λ² = **0,04 s²**; P(X > 0,5) = e^(−2,5) ≈ **0,082**.
