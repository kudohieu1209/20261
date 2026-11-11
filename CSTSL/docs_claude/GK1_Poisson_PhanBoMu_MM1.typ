// Biên dịch: typst compile GK1_Poisson_PhanBoMu_MM1.typ
#let accent = rgb("#1f5fa8")
#let warn = rgb("#b5452b")
#let soft = rgb("#eef3fa")

#set document(title: "GK1 — Poisson, phân bố mũ, M/M/1")
#set page(
  paper: "a4",
  margin: (x: 1.8cm, top: 2cm, bottom: 1.8cm),
  header: none,
  footer: context align(right, text(9pt, fill: gray, counter(page).display())),
)
#set text(font: "Noto Sans", size: 11.5pt, lang: "vi")
#show math.equation: set text(font: "New Computer Modern Math")
#set par(leading: 0.75em, spacing: 1.1em)
#set table(stroke: 0.5pt + gray, inset: 6pt)
#show table.cell.where(y: 0): set text(weight: "bold")
#show table: it => block(breakable: false, it)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(width: 100%, fill: accent, inset: (x: 10pt, y: 8pt), radius: 4pt,
    text(white, size: 15pt, weight: "bold", it.body))
  v(4pt)
}
#show heading.where(level: 2): it => block(sticky: true, above: 14pt, below: 8pt,
  text(accent, size: 13pt, weight: "bold", it.body))

#let box-note(title, color, body) = block(
  width: 100%, inset: 9pt, radius: 4pt, stroke: (left: 3pt + color), fill: color.lighten(90%),
  [#text(color, weight: "bold", title) \ #body],
)
#let khuon(body) = box-note("Khuôn giải", accent, body)
#let bay(body) = box-note("Bẫy", warn, body)
#let mau(title, body) = box-note("Bài mẫu — " + title, rgb("#2e7d4f"), body)

// Ô trống có lưới chấm để viết tay trên tablet
#let o-viet(h) = block(
  width: 100%, height: h, radius: 3pt, stroke: 0.5pt + luma(200),
  fill: tiling(size: (0.5cm, 0.5cm), place(dx: 0.25cm, dy: 0.25cm, circle(radius: 0.6pt, fill: luma(185)))),
)

// ================= TRANG BÌA =================
#align(center)[
  #v(1cm)
  #text(22pt, weight: "bold", fill: accent)[GK1 — Poisson, phân bố mũ, M/M/1]
]
#v(8pt)

#box-note("Cách học buổi này (120–150 phút)", accent)[
  + Đọc trang 1–7 (mỗi dạng ~15 phút).
  + Làm 15 bài ở phần *Bài tự luyện* ngay vào ô chấm bên dưới mỗi bài — *chưa nhìn đáp án*.
  + Dò *Đáp án* ở trang cuối.
  + Chép trang *Sổ tay phòng thi* vào sổ (hoặc giữ nguyên trang đó).

  *Qua buổi khi:* đúng ≥ 12/15 bài, mỗi bài M/M/1 tính trọn trong ≤ 2 phút.
]

== Đọc đề → chọn dạng

#table(
  columns: (2.2fr, 1.1fr, 1.6fr),
  [Đề có từ khoá], [Dạng], [Công thức chính],
  ["tiến trình Poisson", "*xác suất có k* gói / cuộc gọi *trong khoảng t*"], [A — đếm số lần đến], [$P(k) = ((lambda t)^k e^(-lambda t)) / k!$],
  ["*thời gian* … phân bố mũ", "đợi *lâu hơn / ít nhất / không quá* t"], [B — thời gian chờ], [$P(T > t) = e^(-lambda t)$],
  ["M/M/1", "hàng đợi", "số gói / trễ trung bình", "xác suất hệ rỗng"], [C — một nút M/M/1], [$rho = lambda / mu$, $N = rho / (1 - rho)$, $T = 1 / (mu - lambda)$],
)

// ================= DẠNG A =================
= Dạng A — Poisson: xác suất có k lần đến trong khoảng t

#khuon[
  + Đưa $lambda$ và $t$ về *cùng đơn vị* thời gian.
  + Tính $m = lambda t$ (số lần đến trung bình trong khoảng $t$).
  + Áp công thức theo câu hỏi:
]

#table(
  columns: (1fr, 2fr),
  [Câu hỏi], [Công thức],
  [đúng $k$ lần], [$P(k) = (m^k e^(-m)) / k!$],
  [không có lần nào], [$P(0) = e^(-m)$],
  [*ít nhất 1* lần], [$1 - e^(-m)$],
  [*không quá* $k$ lần], [$e^(-m) (1 + m + m^2 / 2! + dots + m^k / k!)$],
  [*nhiều hơn* $k$ lần], [$1 - [P(0) + dots + P(k)]$],
)

#mau("Số khách đến trong một khoảng thời gian")[
  Khách đến cửa hàng theo Poisson, $lambda = 10$ khách/giờ. Xác suất có 2 khách trong 10:00 – 10:20?

  - $t = 20$ phút $= 1/3$ giờ (đổi về giờ cho khớp $lambda$).
  - $m = 10 dot 1/3 = 10/3$.
  - $P(2) = ((10\/3)^2 e^(-10\/3)) / 2! approx bold(0","198)$.
]

// ================= DẠNG B =================
= Dạng B — Phân bố mũ: xác suất thời gian chờ

#khuon[
  + Tìm tham số $lambda$:
    - đề cho *tốc độ* (5 chuyến/giờ, 100 gói/s) → $lambda$ = tốc độ đó;
    - đề cho *thời gian trung bình* $tau$ (2 s, 5 ms) → $lambda = 1 / tau$.
  + Đưa $lambda$ và $t$ về cùng đơn vị.
  + Áp công thức:
]

#table(
  columns: (1.3fr, 1.7fr),
  [Câu hỏi], [Công thức],
  [lâu hơn $t$ / *ít nhất* $t$], [$P(T > t) = e^(-lambda t)$],
  [*không quá* $t$ / trong vòng $t$], [$P(T <= t) = 1 - e^(-lambda t)$],
  [trong khoảng $a$ đến $b$], [$e^(-lambda a) - e^(-lambda b)$],
  [thời gian trung bình], [$E[T] = 1 / lambda$],
  [đã chờ $s$, chờ thêm hơn $t$], [vẫn là $e^(-lambda t)$ — bỏ qua $s$ ("không nhớ")],
)

#bay[
  "Trung bình 2 s" thì $lambda = 1\/2$ mỗi giây, *KHÔNG* phải $lambda = 2$.
]

#mau("đề 30/12/2014, câu 1 (1 điểm)")[
  Thời gian gói đợi tại bộ đệm trung bình 2 s, phân bố mũ. Xác suất gói phải đợi hơn 3 s?

  - $lambda = 1\/2$ (1/s) → $P(T > 3) = e^(-3\/2) approx bold(0","223)$.

  #text(warn)[Lời giải viết tay trong `Ôn tập đề thi CSTSL.pdf` lấy $lambda = 2$ ra $e^(-6)$ — *sai*.]
]

#mau("Thời gian đợi xe buýt")[
  Xe bus đến theo Poisson, 5 chuyến/giờ. Một người vừa lỡ chuyến.

  - $lambda = 1\/12$ chuyến/phút, $t = 10$ phút → $lambda t = 5\/6$.
  - Đợi *không quá* 10 phút: $1 - e^(-5\/6) approx bold(0","565)$ (đáp số slide).
  - Đợi *ít nhất* 10 phút: $e^(-5\/6) approx bold(0","435)$.

  #text(warn)[Slide ghi đề "ít nhất 10 phút" nhưng giải "không quá". Đi thi đọc kỹ cụm này; đề mập mờ thì ghi rõ mình hiểu thế nào.]
]

// ================= DẠNG C =================
= Dạng C — Một nút M/M/1

#box-note("Vì sao quan trọng nhất", warn)[
  Mọi câu mạng hàng đợi (3,5–6 điểm) đều quy về tính từng nút M/M/1 như thế này.
]

== Bước 1 — Đổi đề ra λ và μ (yêu cầu/giây)

#table(
  columns: (2fr, 1.4fr),
  [Đề viết], [Lấy ra],
  ["tốc độ đến 70 yêu cầu/s", "phát Poisson 100 pps"], [$lambda = 70$, $lambda = 100$],
  ["*tốc độ* phục vụ 120 yêu cầu/s"], [$mu = 120$],
  ["*thời gian* phục vụ trung bình 5 ms"], [$mu = 1 \/ 0","005 = 200$],
  ["liên kết $C = 200$ kbps, gói $L = 1000$ bit"], [$mu = C\/L = 200$],
  ["$C = 10$ Mbps, gói trung bình 1500 *byte*"], [$mu = (10 dot 10^6) / (1500 dot 8) approx 833","3$],
  [nút nhận từ nhiều nguồn], [$lambda$ = cộng các luồng vào],
)

== Bước 2 — Tính ρ, kiểm tra ổn định

- $rho = lambda \/ mu$. Nếu $rho < 1$ → ổn định, làm tiếp.
- Nếu $rho >= 1$ → ghi "hàng đợi không ổn định, độ dài tăng vô hạn" và dừng.
- Hỏi "điều kiện ổn định" → trả lời $lambda < mu$.

== Bước 3 — Bảng công thức

#table(
  columns: (2.2fr, 0.8fr, 1.6fr),
  [Đại lượng], [Ký hiệu], [Công thức],
  [Xác suất hệ rỗng (server rỗi)], [$p_0$], [$1 - rho$],
  [Xác suất có đúng $n$ yêu cầu], [$p_n$], [$(1 - rho) rho^n$],
  [Xác suất có *ít nhất* $n$ yêu cầu], [$P(N >= n)$], [$rho^n$],
  [Xác suất server bận / phải chờ], [], [$rho$],
  [Số yêu cầu TB *trong hệ thống*], [$N$], [$rho / (1 - rho)$],
  [Số yêu cầu TB *trong hàng đợi*], [$N_q$], [$rho^2 / (1 - rho)$],
  [Thời gian TB *trong hệ thống* (trễ)], [$T$], [$1 / (mu - lambda)$],
  [Thời gian chờ TB *trong hàng đợi*], [$T_q$], [$rho / (mu - lambda) = T - 1/mu$],
  [Thời gian phục vụ TB], [$T_s$], [$1 / mu$],
)

#box-note("Kiểm tra bằng định lý Little", accent)[
  $N = lambda T$ và $N_q = lambda T_q$. Không khớp là bấm sai.

  "Thời gian gói nằm tại router/nút" → dùng $T$. "Thời gian chờ trong bộ đệm" → dùng $T_q$.
]

== Bước 4 — Dạng hỏi ngược

#table(
  columns: (1.3fr, 2fr),
  [Đề yêu cầu], [Giải],
  [trễ $T <= T_0$], [$1/(mu - lambda) <= T_0 arrow.r lambda <= mu - 1/T_0$],
  [$N <= N_0$], [$rho <= N_0 / (1 + N_0)$],
  [$N_q <= N_0$], [giải $rho^2 + N_0 rho - N_0 <= 0$, lấy nghiệm dương],
  [xác suất rỗi $>= p$], [$rho <= 1 - p$],
)

#mau("đề 20211, router A (ý 2, 3, 4)")[
  S1, S2 phát Poisson 100 và 50 pps vào A. Liên kết ra $C_(A B) = 200$ kbps, $L = 1000$ bit.

  - $lambda_A = 100 + 50 = 150$ pps; $mu_A = 200000 \/ 1000 = 200$ pps.
  - $rho = 0","75 < 1$ → ổn định.
  - $T_A = 1 \/ (200 - 150) = 1\/50 "s" = bold(20 "ms")$ ← đáp số đề hỏi.
  - Nếu hỏi thêm: $N = 3$; $N_q = 2","25$; $T_q = 15$ ms; $p_0 = 0","25$.
  - Little: $150 dot 0","02 = 3 = N$ ✔
]

#mau("đề 20241, router R1")[
  $lambda_1 = 1260$, $mu_1 = 3000$ → $rho = 0","42$; $T_1 = 1\/1740 "s" approx bold(0","575 "ms")$; $N_1 approx bold(0","724)$.
]

#mau("dạng ngược, kiểu đề 2014 câu 2")[
  $mu = 100$ gói/s. Tìm $lambda$ lớn nhất để trễ TB không quá 200 ms.

  $1\/(100 - lambda) <= 0","2 arrow.r 100 - lambda >= 5 arrow.r bold(lambda <= 95)$ gói/s.
]

// ================= BỔ SUNG THẦY DŨNG =================
= Bổ sung: Poisson, phân bố và M/M/1

#text(fill: gray)[Chương 2 + đầu chương 3.]

== B1. Tính chất ghép và tách luồng Poisson

#khuon[
  - *Ghép:* nhiều luồng Poisson $lambda_1, lambda_2, dots, lambda_n$ đi chung một chỗ → vẫn là Poisson với $lambda = lambda_1 + lambda_2 + dots + lambda_n$.
  - *Tách:* một luồng Poisson $lambda$, mỗi yêu cầu đi nhánh $i$ với xác suất $p_i$ → nhánh $i$ là Poisson với tốc độ $lambda dot p_i$.
  - Sau khi ghép hoặc tách xong thì dùng lại dạng A hoặc dạng B như bình thường.
]

#mau("Ghép luồng")[
  Ô tô qua nút giao 6 xe/phút, xe máy 9 xe/phút, đều Poisson.

  - Tổng phương tiện: $lambda = 6 + 9 = bold(15)$ *xe/phút*, vẫn là Poisson.
  - Thêm (tự đặt): xác suất trong 10 giây không có xe nào → $lambda t = 15 dot (10\/60) = 2","5$ → $e^(-2","5) approx bold(0","082)$.
]

#mau("Tách luồng")[
  Nhà hộ sinh có 12 bé/tuần, 55% trai, 45% gái.

  - Bé trai: $12 dot 0","55 = bold(6","6)$ *bé/tuần*; bé gái: $12 dot 0","45 = bold(5","4)$ *bé/tuần*, đều là Poisson.
  - Thêm: xác suất một tuần không có bé trai nào $= e^(-6","6) approx bold(0","00136)$.
]

== B2. Hai ví dụ Poisson

#mau("Tổng đài 1080")[
  Tổng đài 1080 nhận trung bình 10 cuộc/phút, Poisson. Xác suất có 15 cuộc trong 2 phút?

  - $m = lambda t = 10 dot 2 = 20$.
  - $P(15) = (20^15 dot e^(-20)) / 15! approx bold(0","0516)$.
]

#mau("Xe buýt")[
  Xe buýt có tần suất 5 phút/chuyến (Poisson). Một người vừa lỡ chuyến. Xác suất đợi chuyến sau ít hơn 3 phút?

  - "5 phút/chuyến" là thời gian trung bình giữa hai chuyến → $lambda = 1\/5$ chuyến/phút.
  - $P(T < 3) = 1 - e^(-3\/5) = 1 - e^(-0","6) approx bold(0","451)$.
]

#bay[
  "5 phút/chuyến" *KHÔNG* phải $lambda = 5$.
]

== B3. Bảng các phân bố — chỉ cần tra khi đề hỏi E, Var

#table(
  columns: (1.25fr, 1fr, 2.5fr, 0.8fr, 1fr),
  align: left + horizon,
  [Phân bố], [Loại biến], [Công thức], [$E(x)$], [$"Var"(x)$],
  [Bernoulli], [rời rạc (0/1)], [$P(1) = p$, $P(0) = 1 - p$], [$display(p)$], [$display(p(1 - p))$],
  [Nhị thức $(n, p)$], [rời rạc], [$display(P(k) = C(n,k) p^k (1 - p)^(n-k))$], [$display(n p)$], [$display(n p(1 - p))$],
  [Đều $[a, b]$], [liên tục], [$display(f(x) = 1/(b - a))$], [$display((a + b)/2)$], [$display((b - a)^2/12)$],
  [Chuẩn $(mu, sigma)$], [liên tục], [$display(f(x) = e^(-(x-mu)^2 \/ (2 sigma^2)) / (sigma sqrt(2 pi)))$], [$display(mu)$], [$display(sigma^2)$],
  [Mũ $(lambda)$], [liên tục], [$display(f(x) = lambda e^(-lambda x))$], [$display(1/lambda)$], [$display(1/lambda^2)$],
  [Poisson $(alpha)$], [rời rạc], [$display(P(k) = (alpha^k e^(-alpha))/k!)$], [$display(alpha)$], [$display(alpha)$],
  [Gamma $(n, lambda)$], [liên tục], [$display(f(x) = (lambda^n x^(n-1) e^(-lambda x))/((n-1)!))$], [$display(n/lambda)$], [$display(n/lambda^2)$],
)

#box-note("Ghi nhớ thêm", accent)[
  - Tổng của $n$ biến mũ độc lập cùng tham số $lambda$ là biến Gamma$(n, lambda)$ (Định lý 2.1).
  - Nhị thức = tổng của $n$ lần thử Bernoulli.
]

== B4. Xác suất theo thời gian trong M/M/1

Hai công thức thêm cho hàng đợi M/M/1 (thầy Dũng viết M/M/1/∞):

#table(
  columns: (2fr, 1.3fr),
  [Đề hỏi], [Công thức],
  [xác suất thời gian *trong hệ thống* (từ lúc vào đến lúc phục vụ xong) không quá $t$], [$P(T <= t) = 1 - e^(-(mu - lambda) t)$],
  [xác suất thời gian *chờ trong hàng đợi* không quá $t$], [$P(T_q <= t) = 1 - rho dot e^(-(mu - lambda) t)$],
)

#mau("Quầy tính tiền siêu thị mini")[
  Khách vào quầy tính tiền siêu thị mini theo Poisson 40 người/giờ, thời gian phục vụ phân bố mũ trung bình 1 phút, một quầy, chỗ xếp hàng không giới hạn.

  - Đổi về phút: $lambda = 40\/60 = 2\/3$ người/phút; $mu = 1$ người/phút; $rho = 2\/3$.
  - (a) Thời gian chờ trung bình (trong hàng đợi): $T_q = rho\/(mu - lambda) = (2\/3)\/(1\/3) = bold(2)$ *phút*. \
    (Thời gian ở lại tổng cộng $T = 1\/(mu - lambda) = 3$ phút.)
  - (b) Từ lúc xếp hàng đến lúc trả tiền xong không quá 1,5 phút: đó là $T <= 1","5$ → \
    $P = 1 - e^(-(1\/3) dot 1","5) = 1 - e^(-0","5) approx bold(0","393)$.
]

#box-note("Ký hiệu dùng thống nhất từ đây", accent)[
  $N$, $N_q$, $N_s$ (số yêu cầu trong hệ thống / hàng đợi / đang phục vụ); $T$, $T_q$, $T_s$ (thời gian tương ứng); $rho = lambda\/(c mu)$ là tải; với 1 server thì $rho = lambda\/mu$.
]

// ================= SỔ TAY =================
= Sổ tay phòng thi — trang 1

#set text(12pt)
#box-note("POISSON — \"xác suất có k lần đến trong khoảng t\"", accent)[
  $m = lambda t$ ($lambda$, $t$ cùng đơn vị) #h(1em)
  $P(k) = (m^k e^(-m)) / k!$ #h(1em) ít nhất 1: $1 - e^(-m)$ \
  không quá $k$: $e^(-m)(1 + m + m^2/2! + dots + m^k/k!)$
]
#box-note("PHÂN BỐ MŨ — \"thời gian chờ / phục vụ\"", accent)[
  trung bình $tau$ → $lambda = 1\/tau$ #h(1em) (*KHÔNG* phải $lambda = tau$) \
  $P(T > t) = e^(-lambda t)$ #h(1.5em) $P(T <= t) = 1 - e^(-lambda t)$ #h(1.5em) khoảng $[a, b]$: $e^(-lambda a) - e^(-lambda b)$ \
  không nhớ: đã chờ bao lâu cũng bỏ qua
]
#box-note("M/M/1", accent)[
  $lambda$ = cộng các luồng vào #h(1em) $mu = 1\/t_"phục vụ" = C\/L$ (byte → bit: ×8) \
  $rho = lambda\/mu < 1$ (không thì: KHÔNG ỔN ĐỊNH) \
  $p_0 = 1 - rho$ #h(1.5em) $p_n = (1 - rho) rho^n$ #h(1.5em) $P(N >= n) = rho^n$ \
  $N = rho/(1 - rho)$ #h(2em) $T = 1/(mu - lambda)$ ← "thời gian tại nút" \
  $N_q = rho^2/(1 - rho)$ #h(1.3em) $T_q = rho/(mu - lambda) = T - 1/mu$ \
  Kiểm tra: $N = lambda T$, $N_q = lambda T_q$ #h(1.5em) Ngược: $T <= T_0 arrow.r lambda <= mu - 1/T_0$
]
#box-note("Lỗi hay mắc", warn)[
  - Thời gian TB 5 ms mà lấy $mu = 5$ → phải là $mu = 200$/s.
  - Quên đổi *byte → bit* (×8) khi tính $mu = C\/L$.
  - $lambda$ theo giờ, $t$ theo phút → lệch đơn vị.
  - Nhầm $T$ (hệ thống) với $T_q$ (hàng đợi).
  - Nhầm "ít nhất $t$" ($e^(-lambda t)$) với "không quá $t$" ($1 - e^(-lambda t)$).
  - Quên kiểm tra $rho < 1$. Quên ghi đơn vị (s / ms).
]
#set text(11pt)
#box-note("BỔ SUNG", accent)[
  GHÉP/TÁCH POISSON: ghép → $lambda = sum lambda_i$ (vẫn Poisson); \
  #h(1em) tách theo xác suất $p_i$ → $lambda dot p_i$ (vẫn Poisson) \
  "$x$ phút/chuyến" = thời gian TB → $lambda = 1\/x$ \
  M/M/1: $P(T <= t) = 1 - e^(-(mu - lambda) t)$ #h(1.5em) $P(T_q <= t) = 1 - rho dot e^(-(mu - lambda) t)$ \
  Phân bố mũ: $E = 1\/lambda$, $"Var" = 1\/lambda^2$; #h(0.5em) Poisson: $E = "Var" = alpha$; #h(0.5em) Nhị thức: $E = n p$, $"Var" = n p(1 - p)$
]
#set text(11.5pt)

// ================= BÀI TẬP =================
= Bài tự luyện — viết thẳng vào ô chấm

#text(fill: gray)[Bài 8 lấy số theo MSSV (a = 7). Làm hết rồi mới lật trang đáp án.]

#let bai(n, body, h: 4.2cm) = block(breakable: false, width: 100%)[
  *Bài #n.* #body
  #v(-2pt)
  #o-viet(h)
  #v(4pt)
]

#bai(1)[Gói đến router theo Poisson, 600 gói/phút. Trong khoảng 50 ms, tính xác suất (a) không có gói nào; (b) có ít nhất 2 gói.]
#bai(2)[Cuộc gọi đến tổng đài theo Poisson, 3 cuộc/phút. Xác suất trong 2 phút có không quá 3 cuộc gọi?]
#bai(3)[Thời gian phục vụ một gói phân bố mũ, trung bình 4 ms. Xác suất thời gian phục vụ (a) lớn hơn 10 ms; (b) trong khoảng 2 – 6 ms?]
#bai(4)[Hàng đợi M/M/1: gói đến 50 yêu cầu/s, thời gian phục vụ trung bình 5 ms. Tính $rho$, $N$, $T$, $N_q$, $T_q$.]
#bai(5, h: 5cm)[Liên kết 2 Mbps, gói phân bố mũ trung bình 1000 byte, gói đến Poisson 200 gói/s. (a) Tính $rho$, $N$, $T$, $T_q$, $N_q$, $p_0$. (b) Xác suất trong hệ có hơn 3 gói?]
#bai(6)[M/M/1 có $mu = 100$ gói/s. Tìm $lambda$ lớn nhất để (a) trễ TB không quá 50 ms; (b) số gói TB *trong hàng đợi* không quá 1.]
#bai(7)[Router có hai cổng vào 300 pps và 450 pps, cùng ra liên kết 1 Mbps, gói 1000 bit. Router có ổn định không? Nâng liên kết lên 2 Mbps thì trễ TB tại router bằng bao nhiêu?]
#bai(8, h: 5cm)[(Theo MSSV) M/M/1 có $lambda = 10(a + 1)$ yêu cầu/s, $mu = 120$ yêu cầu/s. Tính $rho$, $N$, $T$, $T_q$, $N_q$ và xác suất trong hệ có đúng 2 yêu cầu.]
#bai(9)[Thời gian giữa hai gói đến liên tiếp phân bố mũ, trung bình 20 ms. Đã 30 ms chưa có gói nào. Xác suất phải đợi thêm hơn 20 ms nữa?]
#bai(10)[M/M/1 có $lambda = 40$ gói/s. Tìm $mu$ nhỏ nhất để xác suất server rỗi ít nhất 0,2 *và* trễ TB không quá 25 ms.]
#bai(11)[Router nhận ba luồng Poisson 120, 200 và 80 gói/s. Tính xác suất trong 5 ms không có gói nào đến router.]
#bai(12)[Một luồng Poisson 50 gói/s đi vào router; 30% số gói đi cổng 1, còn lại đi cổng 2. Xác suất trong 100 ms cổng 1 nhận đúng 2 gói?]
#bai(13)[Taxi đến một điểm đón với tần suất trung bình 4 phút/xe (Poisson). Xác suất phải đợi lâu hơn 6 phút?]
#bai(14, h: 5cm)[Một server M/M/1 có $lambda = 30$ yêu cầu/s, $mu = 50$ yêu cầu/s. Tính xác suất một yêu cầu ở lại hệ thống không quá 100 ms, và xác suất phải chờ trong hàng đợi lâu hơn 100 ms.]
#bai(15)[Biến $X$ phân bố mũ có $E(X) = 0","2$ s. Tính $"Var"(X)$ và $P(X > 0","5 "s")$.]

// ================= ĐÁP ÁN =================
= Đáp án

#table(
  columns: (auto, 1fr),
  [Bài], [Đáp án],
  [1], [$lambda = 10$/s, $t = 0","05$ s → $m = 0","5$. (a) $e^(-0","5) approx bold(0","607)$. (b) $1 - e^(-0","5)(1 + 0","5) approx bold(0","090)$.],
  [2], [$m = 6$. $e^(-6)(1 + 6 + 18 + 36) = 61 e^(-6) approx bold(0","151)$.],
  [3], [$lambda = 1\/4$ mỗi ms. (a) $e^(-2","5) approx bold(0","082)$. (b) $e^(-0","5) - e^(-1","5) approx bold(0","383)$.],
  [4], [$mu = 200$; $rho = bold(0","25)$; $N = bold(1\/3)$; $T = 1\/150 "s" approx bold(6","67 "ms")$; $N_q = bold(1\/12)$; $T_q approx bold(1","67 "ms")$.],
  [5], [$mu = 2 dot 10^6 \/ 8000 = 250$. (a) $rho = bold(0","8)$, $N = bold(4)$, $T = bold(20 "ms")$, $T_q = bold(16 "ms")$, $N_q = bold(3","2)$, $p_0 = bold(0","2)$. (b) $P(N >= 4) = 0","8^4 approx bold(0","410)$.],
  [6], [(a) $1\/(100 - lambda) <= 0","05 arrow.r bold(lambda <= 80)$. (b) $rho^2 + rho - 1 <= 0 arrow.r rho <= 0","618 arrow.r bold(lambda <= 61","8)$.],
  [7], [$lambda = 750$, $mu = 1000$ → $rho = 0","75$ → *ổn định*. Với 2 Mbps: $mu = 2000$, $T = 1\/1250 "s" = bold(0","8 "ms")$.],
  [8], [$lambda = 80$. $rho = bold(2\/3)$, $N = bold(2)$, $T = bold(25 "ms")$, $T_q approx bold(16","7 "ms")$, $N_q = bold(4\/3)$, $p_2 = (1\/3)(2\/3)^2 = bold(4\/27) approx 0","148$.],
  [9], [Không nhớ → bỏ qua 30 ms. $e^(-20\/20) = e^(-1) approx bold(0","368)$.],
  [10], [$1 - 40\/mu >= 0","2 arrow.r mu >= 50$; $1\/(mu - 40) <= 0","025 arrow.r mu >= 80$. Lấy điều kiện chặt hơn: $bold(mu >= 80)$ gói/s.],
  [11], [$lambda = 120 + 200 + 80 = 400$ gói/s; $lambda t = 400 dot 0","005 = 2$ → $e^(-2) approx bold(0","135)$.],
  [12], [Cổng 1: $lambda_1 = 50 dot 0","3 = 15$ gói/s; $m = 15 dot 0","1 = 1","5$ → $P(2) = 1","5^2 dot e^(-1","5) \/ 2 approx bold(0","251)$.],
  [13], [$lambda = 1\/4$ xe/phút → $P(T > 6) = e^(-6\/4) = e^(-1","5) approx bold(0","223)$.],
  [14], [$mu - lambda = 20$/s. $P(T <= 0","1) = 1 - e^(-2) approx bold(0","865)$. $P(T_q > 0","1) = rho dot e^(-2) = 0","6 dot 0","1353 approx bold(0","081)$.],
  [15], [$lambda = 5$/s; $"Var" = 1\/lambda^2 = bold(0","04 " s"^2)$; $P(X > 0","5) = e^(-2","5) approx bold(0","082)$.],
)

#v(10pt)
#box-note("Buổi sau — GK2", accent)[
  M/M/1/K (xác suất mất gói), M/M/c (xác suất phải chờ), M/M/c/c (xác suất tắc nghẽn).
]
