#import "style.typ": *
// Biên dịch: typst compile GK2_HangDoiDon.typ




#set document(title: "GK2 — Các hàng đợi đơn")
#show: book






// Ô trống có lưới chấm để viết tay trên tablet


// ================= TRANG BÌA =================
#align(center)[
  #v(0.1cm)
  #text(16pt, weight: "bold", fill: accent)[GK2 — Các hàng đợi đơn]
]
#v(2pt)

#box-note("Cách học buổi này", accent)[
  + Đọc bảng *Đọc đề → chọn mô hình*.
  + Đọc từng mô hình (khuôn + bài mẫu).
  + Làm 10 bài ở phần *Bài tự luyện* ra giấy riêng.
  + Dò *Đáp án* ở trang cuối.
  + Chép trang *Sổ tay phòng thi — trang 2*.

  *Qua buổi khi:* đúng ≥ 8/10 bài, nhìn đề là gọi đúng tên mô hình.

]

#set text(10.5pt)
#set par(spacing: 1.3em)
== Ký hiệu Kendall

Ký hiệu *A/B/c/k*: A = tiến trình tới (M = Poisson/Markov, D = tất định, G = bất kỳ); B = tiến trình phục vụ (M = thời gian phục vụ phân bố mũ); $c$ = số server; $k$ = *dung lượng hệ thống* (số yêu cầu tối đa trong hệ thống = số chỗ trong hàng đợi + số server). Thiếu $k$ nghĩa là $k = infinity$.

Ký hiệu chung: $a = lambda\/mu$ (tải tính theo Erlang); $rho = lambda\/(c mu)$ (tải mỗi server); $N, N_q, N_s$; $T, T_q, T_s$; $P_B$ = xác suất yêu cầu bị từ chối.

== Đọc đề → chọn mô hình

#table(
  columns: (2.5fr, 1.35fr, 1.9fr),
  inset: 4.5pt,
  [Đề viết], [Mô hình], [Chú ý],
  [1 server, *không có chỗ chờ* (ATM 1 máy, kênh 1 cuộc)], [M/M/1/1], [đến lúc bận là bị từ chối],
  [1 server, chỗ chờ *vô hạn / đủ lớn*], [M/M/1 (= M/M/1/∞)], [GK1],
  [1 server, chỗ chờ *giới hạn Q chỗ*], [M/M/1/k với *$k = Q + 1$*], [bẫy: "đủ chỗ cho 10 người đợi" → $k = 11$],
  [$c$ server, chỗ chờ vô hạn (call center có nhạc chờ, CPU nhiều nhân)], [M/M/c (Erlang C)], [hỏi "xác suất phải đợi"],
  [$c$ server, *không có chỗ chờ* ($c$ đường trung kế, $c$ kênh)], [M/M/c/c (Erlang B)], [hỏi "xác suất nghẽn / từ chối"],
  [$c$ server, tổng sức chứa $k$], [M/M/c/k], [],
  [vô số server (ai đến cũng được phục vụ ngay)], [M/M/∞], [],
  [thời gian phục vụ *không phải mũ*, cho trung bình và phương sai], [M/G/1], [],
  [thời gian phục vụ *cố định* (gói dài bằng nhau)], [M/D/1], [],
)

#box-note("Hệ thống có từ chối (k hữu hạn)", warn)[
  Luôn dùng *$lambda$ thực tế $= lambda(1 - P_B)$* khi áp Little: $T = N \/ (lambda(1 - P_B))$.
]
#set text(11pt)
#set par(spacing: 1.3em)

// ================= M/M/1/1 + M/M/1/k =================
= 1–2. M/M/1/1 và M/M/1/k — một server, chỗ chờ hữu hạn

== 1. M/M/1/1 — một server, không có chỗ chờ

#khuon[
  $rho = lambda \/ mu$.
  - $p_0 = 1/(1 + rho)$; #h(0.5em) $p_1 = rho/(1 + rho)$.
  - Xác suất bị từ chối: $P_B = p_1 = bold(lambda/(lambda + mu))$.
  - $N = p_1 = lambda/(lambda + mu)$; #h(0.5em) $T = T_s = 1/mu$.
]

#mau("ATM một máy")[
  Điểm rút tiền có 1 máy ATM. Người đến 10 người/giờ (Poisson), mỗi người cần trung bình 3 phút. Xác suất một người đến mà không được phục vụ (giả thiết không ai đứng chờ)?

  - $lambda = 10$/giờ; $mu = 60\/3 = 20$/giờ.
  - $P_B = 10/(10 + 20) = bold(1\/3 approx 0","333)$.
]

== 2. M/M/1/k — một server, sức chứa k (hàng đợi Q = k − 1 chỗ)

#khuon[
  ($rho = lambda\/mu$, $rho != 1$)
  + $p_0 = (1 - rho)/(1 - rho^(k+1))$; #h(0.5em) $p_n = rho^n dot p_0$ ($n = 0 dots k$).
  + $P_B = p_k = (rho^k (1 - rho))/(1 - rho^(k+1))$.
  + $N = rho/(1 - rho) - ((k + 1) rho^(k+1))/(1 - rho^(k+1))$.
  + $N_q = N - (1 - p_0)$.
  + $lambda$ thực tế $= lambda(1 - P_B)$; #h(0.5em) $T = N/(lambda(1 - P_B))$; #h(0.5em) $T_q = N_q/(lambda(1 - P_B))$.

  *Trường hợp $rho = 1$* ($lambda = mu$): $p_0 = p_1 = dots = p_k = 1/(k + 1)$; #h(0.3em) $N = k\/2$; #h(0.3em) $N_q = N - (1 - p_0)$.
]

#box-note("Ghi nhớ", warn)[
  M/M/1/k *luôn ổn định* kể cả khi $rho >= 1$ (hàng đợi không thể dài vô hạn); $P_B > 0$ ngay cả khi $rho < 1$ vì yêu cầu đến ngẫu nhiên có lúc dồn dập làm đầy bộ đệm.
]

#mau("Bãi gửi xe")[
  Bãi gửi xe máy có 1 cổng, 1 nhân viên; chỗ cho 10 khách đợi. Khách đến 3 khách/phút (Poisson); nhân viên xử lý trung bình 15 giây/xe (mũ). Tính: xác suất khách được phục vụ ngay; thời gian trung bình phải đợi đến khi được phục vụ; xác suất bãi bị tắc do người tới quá đông.

  - $lambda = 3$/phút; $mu = 60\/15 = 4$/phút; $rho = 0","75$; chỗ đợi $Q = 10$ → $bold(k = 11)$.
  - $p_0 = (1 - 0","75)/(1 - 0","75^12) approx bold(0","258)$ → xác suất được phục vụ ngay.
  - $P_B = p_11 = 0","75^11 dot p_0 approx bold(0","0109)$ → xác suất bãi bị tắc (khách đến phải bỏ đi) ≈ 1,09%.
  - $N = 0","75\/0","25 - (12 dot 0","75^12)/(1 - 0","75^12) approx 2","607$; #h(0.5em) $N_q = N - (1 - p_0) approx 1","866$.
  - $lambda$ thực tế $= 3 dot (1 - 0","0109) approx 2","967$/phút; #h(0.3em) $T_q = 1","866\/2","967 approx bold(0","629 "phút" approx 37","7 "giây")$.
]

// ================= 2b. SINH – TỬ =================
// Đồ hình sinh – tử: n trạng thái nối tiếp, cung trên (sang phải) ghi lam, cung dưới (sang trái) ghi mu
#let arrow-head(tip, from, color) = {
  let dx = (tip.at(0) - from.at(0)) / 1pt
  let dy = (tip.at(1) - from.at(1)) / 1pt
  let len = calc.sqrt(dx * dx + dy * dy)
  let (ux, uy) = (dx / len, dy / len)
  let (l, w) = (7.0, 3.2)
  let b = (tip.at(0) - l * ux * 1pt, tip.at(1) - l * uy * 1pt)
  place(polygon(fill: color, stroke: none,
    tip,
    (b.at(0) - w * uy * 1pt, b.at(1) + w * ux * 1pt),
    (b.at(0) + w * uy * 1pt, b.at(1) - w * ux * 1pt),
  ))
}
#let sinh-tu(n, lam, mu) = {
  let r = 0.55cm
  let gap = 2.9cm
  let x0 = 0.9cm
  let y0 = 1.4cm
  let xs = range(n).map(i => x0 + i * gap)
  let col = accent
  box(width: x0 * 2 + (n - 1) * gap, height: 2.8cm, {
    for i in range(n) {
      place(dx: xs.at(i) - r, dy: y0 - r,
        circle(radius: r, stroke: 1.2pt + col, fill: soft)[
          #set align(center + horizon)
          #text(13pt, weight: "bold")[#i]
        ])
    }
    for i in range(n - 1) {
      // cung trên: i → i+1, tốc độ lam
      let s = (xs.at(i) + 0.45 * r, y0 - 0.9 * r)
      let e = (xs.at(i + 1) - 0.45 * r, y0 - 0.9 * r)
      let c1 = (s.at(0) + 0.5cm, s.at(1) - 0.6cm)
      let c2 = (e.at(0) - 0.5cm, e.at(1) - 0.6cm)
      place(curve(stroke: 1pt + col, curve.move(s), curve.cubic(c1, c2, e)))
      arrow-head(e, c2, col)
      let mx = (xs.at(i) + xs.at(i + 1)) / 2
      place(dx: mx - 1cm, dy: y0 - r - 0.9cm, box(width: 2cm, align(center, lam)))
      // cung dưới: i+1 → i, tốc độ mu
      let s2 = (xs.at(i + 1) - 0.45 * r, y0 + 0.9 * r)
      let e2 = (xs.at(i) + 0.45 * r, y0 + 0.9 * r)
      let d1 = (s2.at(0) - 0.5cm, s2.at(1) + 0.6cm)
      let d2 = (e2.at(0) + 0.5cm, e2.at(1) + 0.6cm)
      place(curve(stroke: 1pt + col, curve.move(s2), curve.cubic(d1, d2, e2)))
      arrow-head(e2, d2, col)
      place(dx: mx - 1cm, dy: y0 + r + 0.5cm, box(width: 2cm, align(center, mu)))
    }
  })
}

= 2b. Tự lập phương trình cân bằng sinh – tử
#set text(11pt)
#set par(leading: 1em, spacing: 1.3em)

#box-note("Đề trên lớp — thầy yêu cầu KHÔNG dùng công thức có sẵn", accent)[
  Cho hàng đợi M/M/1/3. Cuộc gọi đến 2 cuộc/phút; cuộc gọi rời khỏi hệ thống (được phục vụ xong) 4 cuộc/phút. (a) Biểu diễn quá trình sinh – tử. (b) Tự tìm mối quan hệ giữa các xác suất và tính xác suất các trạng thái (không dùng công thức cho sẵn). (c) Tính số cuộc gọi trung bình trong hệ thống. (d) Tính thời gian trung bình một cuộc gọi trong hệ thống.
]

#khuon[
  (dùng cho mọi hàng đợi Markov, kể cả M/M/c/k, M/M/c/c)
  + *Liệt kê trạng thái*: trạng thái $n$ = số yêu cầu trong hệ thống, $n = 0, 1, dots, k$.
  + *Vẽ đồ hình*: các vòng tròn $0, 1, dots, k$; mũi tên sang phải (sinh) ghi $lambda$; mũi tên sang trái (tử) ghi tốc độ phục vụ khi có $n$ yêu cầu (1 server: $mu$; $c$ server: $n mu$ nếu $n <= c$, $c mu$ nếu $n >= c$). Trạng thái cuối $k$ không có mũi tên sinh.
  + *Viết phương trình cân bằng cho từng trạng thái*: tốc độ đi ra khỏi trạng thái = tốc độ đi vào trạng thái.
  + *Rút gọn thành quan hệ liên tiếp* $lambda dot p_(n-1) = mu_n dot p_n$ → $p_n$ theo $p_0$.
  + *Chuẩn hoá*: $sum p_n = 1$ → $p_0$ → các $p_n$.
  + Tính $N = sum n dot p_n$; #h(0.3em) $P_B = p_k$; #h(0.3em) $lambda$ thực tế $= lambda(1 - P_B)$; #h(0.3em) $T = N/(lambda(1 - P_B))$ (Little).
]

#mau("lời giải bài trên lớp")[
  *(a)* Trạng thái 0, 1, 2, 3. Sinh: 0→1, 1→2, 2→3 tốc độ $lambda = 2$. Tử: 1→0, 2→1, 3→2 tốc độ #box($mu = 4$).

  #align(center, sinh-tu(4, $lambda = 2$, $mu = 4$))

  *(b)* Phương trình cân bằng:
  #grid(columns: (1fr, 1fr), column-gutter: 1em, row-gutter: 0.7em,
    [• Trạng thái 0: $lambda p_0 = mu p_1$ → $2 p_0 = 4 p_1$.],
    [• Trạng thái 2: $(lambda + mu) p_2 = lambda p_1 + mu p_3$ \ #h(1.2em) → $6 p_2 = 2 p_1 + 4 p_3$.],
    [• Trạng thái 1: $(lambda + mu) p_1 = lambda p_0 + mu p_2$ \ #h(1.2em) → $6 p_1 = 2 p_0 + 4 p_2$.],
    [• Trạng thái 3: $mu p_3 = lambda p_2$ → $4 p_3 = 2 p_2$.],
  )
  - Rút ra: $p_1 = p_0\/2$; thay vào trạng thái 1: $p_2 = p_1\/2 = p_0\/4$; từ trạng thái 3: $p_3 = p_2\/2 = p_0\/8$.
  - Chuẩn hoá: $p_0 (1 + 1/2 + 1/4 + 1/8) = 1$ → $p_0 = 8\/15 approx bold(0","533)$; #h(0.3em) $p_1 = 4\/15 approx bold(0","267)$; #h(0.3em) $p_2 = 2\/15 approx bold(0","133)$; #h(0.3em) $p_3 = 1\/15 approx bold(0","067)$.

  *(c)* $N = 0 dot p_0 + 1 dot p_1 + 2 dot p_2 + 3 dot p_3 = (4 + 4 + 3)\/15 = 11\/15 approx bold(0","733)$ *cuộc gọi*.

  *(d)* $P_B = p_3 = 1\/15$; #h(0.3em) $lambda$ thực tế $= 2 dot (14\/15) approx 1","867$ cuộc/phút; \
  $T = N \/ lambda_"thực tế" = (11\/15)/(28\/15) = 11\/28 approx bold(0","393 "phút" approx 23","6 "giây")$.

  #text(fill: black)[(Thêm nếu hỏi: $N_q = N - (1 - p_0) = 11\/15 - 7\/15 = 4\/15 approx 0","267$; #h(0.3em) $T_q = 4\/28 approx 0","143$ phút.)]
]

#box-note("Lưu ý", warn)[
  Dùng công thức M/M/1/k ở mục 2 cũng ra đúng các số này — dùng để *tự kiểm tra*, nhưng khi đề ghi "không dùng công thức cho sẵn" thì phải trình bày đủ bước 1–5.
]

// ================= M/M/c =================
#set text(11pt)

= 3. M/M/c (M/M/c/∞) — c server, chỗ chờ vô hạn — Erlang C

#khuon[
  $a = lambda\/mu$; #h(0.3em) $rho = a\/c$; #h(0.3em) điều kiện ổn định $rho < 1$ ($lambda < c mu$).
  + $p_0 = 1 \/ [ sum_(n=0)^(c-1) a^n/(n!) + a^c/(c! (1 - rho)) ]$.
  + $p_n = a^n/(n!) dot p_0$ ($n <= c$); #h(0.5em) $p_n = a^c/(c!) dot rho^(n-c) dot p_0$ ($n >= c$).
  + *Xác suất phải đợi (Erlang C):* $C(c, a) = a^c/(c! (1 - rho)) dot p_0$. Xác suất được phục vụ ngay #box($= 1 - C(c, a)$).
  + $N_q = C(c, a) dot rho/(1 - rho)$; #h(0.5em) $N_s = a$; #h(0.5em) $N = N_q + a$.
  + $T_q = N_q \/ lambda = C(c, a)/(c mu - lambda)$; #h(0.5em) $T = T_q + 1/mu$.
  + Thêm: $P(T_q <= t) = 1 - C(c, a) dot e^(-(c mu - lambda) t)$.
]

#mau("Call center")[
  Call center có 3 điện thoại viên. Trong 10 phút có trung bình 3 khách gọi đến (Poisson); mỗi cuộc gọi trung bình 3 phút (mũ). Khi bận, khách nghe nhạc chờ. Tính xác suất khách được phục vụ ngay. Chỉ tiêu "không quá 10% khách phải đợi" có đạt không? Nếu không, cần bao nhiêu điện thoại viên?

  - $lambda = 0","3$ cuộc/phút; $mu = 1\/3$ cuộc/phút; $a = 0","9$; $c = 3$; $rho = 0","3$.
  - $p_0 = 1 \/ (1 + 0","9 + (0","9^2)/2 + (0","9^3)/(3! dot 0","7)) approx 0","4035$.
  - $C(3; 0","9) = (0","9^3)/(6 dot 0","7) dot 0","4035 approx bold(0","070)$ → xác suất được phục vụ ngay $approx bold(0","930)$.
  - 7% ≤ 10% → *chỉ tiêu đạt* với 3 điện thoại viên, không cần thêm. (Nếu chưa đạt thì thử $c = 4, 5, dots$ đến khi $C(c, a) <= 10%$; với $c = 4$, $C approx 0","014$.)
  - Thêm: $T_q = 0","070 \/ (3 dot (1\/3) - 0","3) approx 0","100$ phút; #h(0.3em) $T approx 3","10$ phút.
]

#mau("CPU bốn nhân, bộ nhớ đủ lớn")[
  CPU máy chủ 4 nhân. Tác vụ đến trung bình 20 task/µs (Poisson); xử lý trung bình 0,08 µs/tác vụ (mũ); bộ nhớ đệm đủ lớn. Tính thời gian từ lúc nhận yêu cầu đến khi hoàn thành, và lượng bộ nhớ (số tác vụ) trung bình chiếm trong RAM.

  - $lambda = 20$ task/µs; $mu = 1\/0","08 = 12","5$ task/µs; $c = 4$; $a = lambda\/mu = 1","6$; $rho = lambda\/(c mu) = 0","4$ → mô hình M/M/c.
  - $p_0 approx 0","1993$; #h(0.3em) $C(4; 1","6) approx 0","0907$; #h(0.3em) $N_q approx 0","0605$; #h(0.3em) $T_q approx 0","0030$ µs.
  - $T = T_q + 1\/mu approx 0","0030 + 0","08 = bold(0","083)$ *µs* (công thức 3.86).
  - Số tác vụ trong RAM $= N = lambda T = N_q + a approx bold(1","66)$ *tác vụ* (công thức 3.83).
]

#box-note("So với số trên bảng lớp", warn)[
  Trên bảng lớp ghi $C(c, a) = 0","10602$. Bấm đúng công thức (3.79) của slide ra *0,0907* ($a^c\/(c!(1 - rho)) = 0","4551$; tổng mẫu $= 4","5627 + 0","4551 = 5","0178$; $0","4551\/5","0178 = 0","0907$). $T$ trên bảng (0,083 µs) khớp; trên bảng ghi $N = 1","67$, theo số đúng là $1","66$ — chênh nhỏ do dùng $C = 0","106$. Nên hỏi lại thầy hoặc bạn cùng lớp con số 0,106.
]

// ================= M/M/c/c + M/M/c/k =================
= 4. M/M/c/c — c server, không có chỗ chờ — Erlang B

#khuon[
  $a = lambda\/mu$ (đơn vị Erlang).
  + $p_n = (a^n\/n!) / (sum_(i=0)^c a^i\/i!)$, #h(0.3em) $n = 0 dots c$.
  + *Xác suất bị từ chối / nghẽn (Erlang B):* $B(c, a) = p_c = (a^c\/c!) / (sum_(i=0)^c a^i\/i!)$.
  + $N = a(1 - B(c, a))$; #h(0.5em) $T = 1\/mu$ (không có chờ).
  + Thiết kế "cần bao nhiêu kênh để $B <= x%$": tính $B$ với $c = 1, 2, 3, dots$ đến khi đạt. Mẹo tính nhanh: $B(0) = 1$; #h(0.3em) $bold(B(c) = (a dot B(c-1))/(c + a dot B(c-1)))$.
]

#box-note("Đơn vị Erlang", accent)[
  Tải = (số cuộc gọi trong 1 giờ) × (thời gian trung bình 1 cuộc, tính bằng giờ). Ví dụ slide: 60 cuộc/giờ, mỗi cuộc 5 phút → $60 times 5\/60 = bold(5 "Erlang")$.
]

#mau("Tổng đài ba đường trung kế")[
  Tổng đài cơ quan có 3 đường trung kế ra tổng đài công cộng. Cuộc gọi từ trong ra 6 cuộc/giờ, từ ngoài vào 9 cuộc/giờ (đều Poisson); mỗi cuộc chiếm kênh trung bình 3 phút. Tính tải theo Erlang và xác suất một cuộc gọi bị từ chối.

  - Ghép hai luồng Poisson: $lambda = 6 + 9 = 15$ cuộc/giờ.
  - Tải $a = 15 times 3\/60 = bold(0","75 "Erlang")$.
  - $B(3; 0","75) = (0","75^3\/6) / (1 + 0","75 + 0","75^2\/2 + 0","75^3\/6) approx bold(0","0335 thin (3","35%))$.
]

= 5. M/M/c/k — c server, sức chứa k

#khuon[
  ($a = lambda\/mu$, $rho = a\/c$)
  + Trọng số: $w_n = a^n/(n!)$ với $n <= c$; #h(0.5em) $w_n = a^c/(c!) dot rho^(n-c)$ với $c < n <= k$.
  + $p_0 = 1 \/ sum w_n$; #h(0.5em) $p_n = w_n dot p_0$.
  + $P_B = p_k$. Xác suất phải đợi $= p_c + p_(c+1) + dots + p_(k-1)$.
  + $N = sum n dot p_n$; #h(0.5em) $N_q = sum_(n=c)^k (n - c) dot p_n$ (tính trực tiếp bằng tổng, $k$ nhỏ nên nhanh).
  + $T = N/(lambda(1 - P_B))$; #h(0.5em) $T_q = N_q/(lambda(1 - P_B))$.
]

#bay[
  Công thức (3.97)–(3.100) trên slide là công thức của M/M/c vô hạn, chỉ đúng gần đúng khi $P_B$ rất nhỏ. Đi thi nên tính $N$, $N_q$ bằng tổng như trên (ra số chính xác); nếu thời gian gấp thì dùng công thức slide và ghi "xấp xỉ".
]

#mau("CPU bốn nhân, cache hữu hạn")[
  CPU 4 nhân như trên, nhưng bộ nhớ đệm (cache) chỉ chứa tối đa 10 tác vụ. Tính xác suất một tác vụ bị từ chối và xác suất một tác vụ phải đợi mà không được phục vụ ngay.

  - Cách hiểu của thầy: 10 chỗ chờ + 4 nhân → $bold(k = 10 + 4 = 14)$ → *M/M/4/14* (đúng quy tắc $k = Q + c$).
  - $c = 4$, $k = 14$, $a = 1","6$, $rho = 0","4$. #h(0.3em) $p_0 approx 0","1993$.
  - $P_B = p_14 = (a^c\/c!) dot rho^(k-c) dot p_0 = (1","6^4\/24) dot 0","4^10 dot 0","1993 approx bold(5","7 dot 10^(-6))$ (công thức 3.96).
  - Xác suất phải đợi: thầy tính $bold(p = 1 - (p_0 + p_1 + p_2 + p_3) approx 0","09)$ (bỏ qua $P_B$ vì quá nhỏ; chính xác là $p_4 + dots + p_13 approx 0","0907$).
]

#box-note("So với số trên bảng lớp", warn)[
  Trên bảng lớp ghi $P_B approx 8","8 dot 10^(-7)$. Thay số đúng công thức (3.96) mình ra $5","7 dot 10^(-6)$ (cả hai đều rất nhỏ, kết luận không đổi). Nên hỏi lại con số này.
]

// ================= M/M/∞ + M/G/1 + M/D/1 =================
= 6–7. M/M/∞, M/G/1 và M/D/1

== 6. M/M/∞ — vô số server (bài tập 3.1 của thầy)

#khuon[
  - $p_n = (a^n e^(-a))/(n!)$ (số yêu cầu trong hệ thống là phân bố Poisson với tham số $a = lambda\/mu$).
  - $N = a$; #h(0.5em) $T = 1\/mu$; #h(0.5em) $N_q = T_q = 0$ (không ai phải chờ). Luôn ổn định.
]

== 7. M/G/1 và M/D/1 — thời gian phục vụ không phải mũ

#khuon[
  *M/G/1* (cho $T_s = 1\/mu$ và phương sai $sigma_s^2$), $rho = lambda\/mu < 1$:
  - $N = rho + (rho^2 + lambda^2 sigma_s^2)/(2(1 - rho))$; #h(0.5em) $N_q = (rho^2 + lambda^2 sigma_s^2)/(2(1 - rho))$.
  - $T = N\/lambda$; #h(0.5em) $T_q = T - 1\/mu$.

  *M/D/1* ($sigma_s = 0$, phục vụ cố định):
  - $N = (rho(2 - rho))/(2(1 - rho))$; #h(0.5em) $N_q = rho^2/(2(1 - rho))$.
  - $T = (2 - rho)/(2 mu (1 - rho))$; #h(0.5em) $T_q = rho/(2 mu (1 - rho))$.
]

#box-note("Câu hỏi hay gặp", warn)[
  "Cùng tải $rho$, hệ thống M/G/1 nào hiệu năng tốt nhất?" → *M/D/1* (phục vụ cố định, $sigma_s^2 = 0$), $N_q$ chỉ bằng một nửa M/M/1.
]

#mau("tự đặt")[
  Liên kết nhận $lambda = 200$ gói/s, $mu = 250$ gói/s.

  - Gói dài ngẫu nhiên (M/M/1): $T = 1\/50 = 20$ ms.
  - Gói dài bằng nhau (M/D/1): $T = (2 - 0","8)/(2 dot 250 dot 0","2) = bold(12 "ms")$ → nhanh hơn.
]

// ================= BÀI ỨNG DỤNG =================
= 8. Bài toán chọn phương án (bài tập 3.2 của thầy)

#box-note("Đề", accent)[
  Trung tâm có nhiều PC; trung bình mỗi ngày làm việc 8 h có 3 máy hỏng (Poisson). Chi phí 500.000đ cho một máy hỏng (hiểu là thiệt hại cho mỗi máy nằm hỏng trong ngày). Thời gian sửa phân bố mũ, sửa lần lượt.
  - Công ty 1: sửa trung bình 2 h/máy, phí 600.000đ/ngày.
  - Công ty 2: sửa trung bình 80 phút/máy, phí 800.000đ/ngày.
  Nên chọn công ty nào?
]

#khuon[
  Mỗi phương án là một hàng đợi M/M/1 → tính $N$ (số máy hỏng trung bình đang nằm chờ/sửa) → chi phí/ngày = phí dịch vụ + $N times$ 500.000đ → chọn phương án rẻ hơn.
]

#mau("bài tập 3.2")[
  - $lambda = 3\/8 = 0","375$ máy/giờ.
  - Công ty 1: $mu = 0","5$/h; $rho = 0","75$; $N = 3$ máy; $T = 8$ h. Chi phí = 600.000 + 3 × 500.000 = *2.100.000đ/ngày*.
  - Công ty 2: $mu = 0","75$/h; $rho = 0","5$; $N = 1$ máy; $T approx 2","67$ h. Chi phí = 800.000 + 1 × 500.000 = *1.300.000đ/ngày*.
  - Kết luận: *chọn công ty 2* (phí cao hơn nhưng máy nằm hỏng ít hơn).
]

#bay[
  Đề viết "giá thành để sửa 1 máy" khá mập mờ. Khi đi thi, ghi rõ cách hiểu ("500.000đ là thiệt hại cho mỗi máy hỏng trong ngày") rồi tính. Nếu hiểu là tiền sửa trả theo mỗi máy thì hai công ty sửa cùng số máy, chi phí sửa như nhau, khi đó chọn công ty 1 vì phí rẻ hơn — nhưng bài sẽ không dùng tới hàng đợi nên cách hiểu thứ nhất mới đúng ý đề.
]

= 9. Bài đề thi cũ dùng M/G/1 (đề cuối kỳ 20231, câu 1)

#box-note("Đề", accent)[
  Công ty A thuê chung 1 server với công ty B, chung một hàng đợi. Nhiệm vụ của A: Poisson $lambda_A = 0","9$/s, thời gian phục vụ mũ trung bình 0,05 s. Của B: $lambda_B = 0","1$/s, trung bình 6 s.
  + Trễ kỳ vọng (chờ + phục vụ) của nhiệm vụ công ty A?
  + Trung tâm Y cho thuê server riêng nhưng chậm hơn $k$ lần. $k$ lớn nhất bằng bao nhiêu thì A đồng ý chuyển?
]

#mau("Thời gian phục vụ hỗn hợp — M/G/1")[
  M/G/1, vì thời gian phục vụ là hỗn hợp của hai phân bố mũ.

  - $lambda = 0","9 + 0","1 = 1$/s. Thời gian phục vụ trung bình: $E[S] = 0","9 dot 0","05 + 0","1 dot 6 = 0","645$ s → $mu = 1\/0","645$; $rho = 0","645$.
  - $E[S^2] = 0","9 dot 2 dot 0","05^2 + 0","1 dot 2 dot 6^2 = 7","2045$ → $sigma_s^2 = 7","2045 - 0","645^2 approx 6","788$.
  - $T_q = (rho + lambda mu sigma_s^2)/(2 mu (1 - rho)) approx bold(10","15 "s")$ (cùng một hàng đợi nên A và B chờ như nhau).
  - (a) Trễ của A: $T_A = T_q + 0","05 approx bold(10","20 "s")$.
  - (b) Ở Y, A dùng riêng M/M/1 với $mu_Y = 20\/k$: $T_Y = 1/(20\/k - 0","9) <= 10","20$ → $20\/k >= 0","998$ → $k <= 20","04$ → $bold(k_max = 20)$.
]

#box-note("Lưu ý về tài liệu giải có sẵn", warn)[
  Tài liệu giải có sẵn (CSTSL_20251_ALL_re.pdf) coi cả hệ là M/M/1 với $mu = 1\/0","645$ nên ra $T_A approx 1","82$ s và $k = 13$. Cách đó bỏ qua việc thời gian phục vụ không phải mũ nên không chính xác; với slide thầy Dũng có M/G/1 thì dùng cách trên. Nếu gặp đề kiểu này mà đề ghi rõ "coi là M/M/1" thì làm theo đề.
]

// ================= SỔ TAY =================
= Sổ tay phòng thi — trang 2

#set text(11pt)
#set par(leading: 1em, spacing: 1.3em)
#box-note("CHỌN MÔ HÌNH", accent)[
  không chỗ chờ → /1/1 hoặc /c/c; #h(0.8em) chỗ chờ $Q$ → $k = Q + c$; #h(0.8em) vô hạn → bỏ $k$ \
  $a = lambda\/mu$ (Erlang) #h(1.5em) $rho = lambda\/(c mu)$ #h(1.5em) hệ có từ chối: Little dùng $lambda(1 - P_B)$
]
#box-note("M/M/1/1", accent)[
  $P_B = lambda/(lambda + mu)$ #h(2em) $N = P_B$ #h(2em) $T = 1\/mu$
]
#box-note("M/M/1/k", accent)[
  $p_0 = (1 - rho)/(1 - rho^(k+1))$ #h(1.5em) $p_n = rho^n p_0$ #h(1.5em) $P_B = p_k$ \
  $N = rho/(1 - rho) - ((k+1) rho^(k+1))/(1 - rho^(k+1))$ #h(1.2em) $N_q = N - (1 - p_0)$ #h(1.2em) $T = N/(lambda(1 - P_B))$ \
  $rho = 1$: mọi $p_n = 1\/(k+1)$, #h(0.3em) $N = k\/2$
]
#box-note("M/M/c (Erlang C)", accent)[
  $p_0 = 1 \/ [ sum_(n<c) a^n/(n!) + a^c/(c!(1 - rho)) ]$ #h(1.5em)
  $C(c, a) = a^c/(c!(1 - rho)) dot p_0$ (phải đợi) \
  $N_q = C dot rho/(1 - rho)$ #h(1.5em) $N = N_q + a$ #h(1.5em) $T_q = C/(c mu - lambda)$ #h(1.5em) $T = T_q + 1\/mu$
]
#box-note("M/M/c/c (Erlang B)", accent)[
  $B(c, a) = (a^c\/c!) / (sum_(i<=c) a^i\/i!)$ #h(1.5em) $B(c) = (a B(c-1))/(c + a B(c-1))$, #h(0.3em) $B(0) = 1$ \
  $N = a(1 - B)$ #h(1.5em) $T = 1\/mu$ #h(1.5em) Erlang = cuộc/giờ × giờ/cuộc
]
#box-note("M/M/c/k", accent)[
  $w_n = a^n/(n!)$ ($n <= c$), #h(0.3em) $a^c/(c!) rho^(n-c)$ ($n > c$); #h(1em) $p_n = w_n \/ sum w$; #h(1em) $P_B = p_k$; #h(1em) $N = sum n dot p_n$
]
#box-note("M/M/∞ · M/G/1 · M/D/1", accent)[
  M/M/∞: #h(0.5em) $p_n = (a^n e^(-a))/(n!)$ #h(1.5em) $N = a$ #h(1.5em) $T = 1\/mu$ \
  M/G/1: #h(0.5em) $N = rho + (rho^2 + lambda^2 sigma^2)/(2(1 - rho))$ #h(1.5em) $T = N\/lambda$ \
  M/D/1: #h(0.5em) $N = (rho(2 - rho))/(2(1 - rho))$ #h(1.5em) $T = (2 - rho)/(2 mu (1 - rho))$ #h(1em) (tốt nhất khi cùng $rho$)
]
#box-note("Lỗi hay mắc", warn)[
  - "Chỗ cho 10 người đợi" mà lấy $k = 10$ → đúng là $k = 11$ (cộng 1 server).
  - Hệ có từ chối mà dùng $T = N\/lambda$ → phải chia cho $lambda(1 - P_B)$.
  - M/M/c lấy $rho = lambda\/mu$ → đúng là $rho = lambda\/(c mu)$; $a$ mới là $lambda\/mu$.
  - Quên ghép luồng Poisson trước khi tính tải (tổng đài cơ quan: 6 + 9).
  - Đổi đơn vị thời gian lệch giữa $lambda$ và $mu$ (giờ / phút / giây).
]
#set text(11pt)


// ================= BÀI TẬP =================
= Bài tự luyện

#text(fill: black)[Làm hết rồi mới lật trang đáp án.]



#bai(1)[Một kênh vô tuyến chỉ phục vụ 1 phiên một lúc, không cho chờ. Yêu cầu đến 30 phiên/giờ (Poisson), mỗi phiên trung bình 4 phút (mũ). Tính xác suất yêu cầu bị từ chối, $N$ và $T$.]
#bai(2)[Router có 1 cổng ra, bộ đệm chứa được 2 gói chờ, $mu = 1000$ gói/s, $lambda = 900$ gói/s. Tính $p_0$, $P_B$, $N$, $T$.]
#bai(3)[Hàng đợi M/M/1/4 có $lambda = mu = 50$ yêu cầu/s. Tính các $p_n$, $P_B$, $N$, $N_q$, $T$.]
#bai(4)[Ngân hàng có 2 quầy, khách đến 20 người/giờ, mỗi khách trung bình 4 phút (mũ), chỗ chờ đủ rộng. Tính xác suất khách phải đợi, $T_q$ (phút), $N$.]
#bai(5, h: 3.5cm)[Một tổng đài: 90 cuộc gọi/giờ, mỗi cuộc trung bình 4 phút. Tải bao nhiêu Erlang?]
#bai(6, h: 5cm)[Lưu lượng 4 Erlang đi vào nhóm kênh không cho chờ. Cần tối thiểu bao nhiêu kênh để xác suất nghẽn không quá 2%? Nghẽn bao nhiêu nếu chỉ có 8 kênh?]
#bai(7)[Bãi đỗ xe rất lớn (coi như M/M/∞): xe đến 2 xe/phút, mỗi xe đỗ trung bình 1,5 phút. Tính số xe trung bình trong bãi, xác suất bãi trống và xác suất có đúng 3 xe.]
#bai(8, h: 5.5cm)[Liên kết nhận $lambda = 60$ gói/s, $mu = 100$ gói/s, gói có độ dài cố định. Tính $N$ và $T$ theo M/D/1 và so sánh $T$ với trường hợp M/M/1.]
#bai(9, h: 6cm)[Hệ thống M/M/2/4 có $lambda = mu = 10$ yêu cầu/s. Tính các $p_n$, $P_B$, xác suất phải đợi, $N$, $T$.]
#bai(10, h: 5.5cm)[Server có $lambda = 4$ yêu cầu/s, thời gian phục vụ trung bình 0,2 s, độ lệch chuẩn 0,1 s (M/G/1). Tính $N$ và $T$.]

// ================= ĐÁP ÁN =================
= Đáp án

#answer-table(
  columns: (auto, 1fr),
  [Bài], [Đáp án],
  [1], [$lambda = 0","5$/phút, $mu = 0","25$/phút, $rho = 2$. $P_B = 0","5\/(0","5 + 0","25) = bold(2\/3 approx 0","667)$; $N = bold(2\/3)$; $T = 1\/mu = bold(4 "phút")$.],
  [2], [$Q = 2$ → $k = 3$; $rho = 0","9$. $p_0 approx bold(0","291)$; $P_B = p_3 approx bold(0","212)$; $N approx bold(1","369)$; $lambda$ thực tế $approx 709","2$/s; $T approx bold(1","93 "ms")$.],
  [3], [$rho = 1$ → $p_0 = dots = p_4 = bold(0","2)$; $P_B = bold(0","2)$; $N = 4\/2 = bold(2)$; $N_q = 2 - 0","8 = bold(1","2)$; $T = 2\/(50 dot 0","8) = bold(0","05 "s")$.],
  [4], [$mu = 15$/giờ, $a = 4\/3$, $rho = 2\/3$. $p_0 = bold(0","2)$; $C(2; 4\/3) approx bold(0","533)$; $N_q approx 1","067$; $T_q = N_q\/lambda approx 0","0533 "h" approx bold(3","2 "phút")$; $N = N_q + a approx bold(2","4)$.],
  [5], [$90 times 4\/60 = bold(6 "Erlang")$.],
  [6], [$B(c; 4)$: $c = 8$ → $bold(0","0304)$; $c = 9$ → $bold(0","0133)$. Cần tối thiểu *9 kênh*.],
  [7], [$a = 3$. $N = bold(3)$ *xe*; $P(0) = e^(-3) approx bold(0","050)$; $P(3) = (3^3 e^(-3))\/3! approx bold(0","224)$.],
  [8], [$rho = 0","6$. M/D/1: $N = (0","6 dot 1","4)\/(2 dot 0","4) = bold(1","05)$; $T = 1","4\/(2 dot 100 dot 0","4) = bold(17","5 "ms")$. M/M/1: $T = 1\/40 = bold(25 "ms")$ → M/D/1 nhanh hơn.],
  [9], [$a = 1$, $rho = 0","5$. $p_0 = p_1 approx bold(0","348)$, $p_2 approx bold(0","174)$, $p_3 approx bold(0","087)$, $p_4 approx bold(0","043)$. $P_B approx bold(0","0435)$; xác suất phải đợi $= p_2 + p_3 approx bold(0","261)$; $N approx bold(1","130)$; $T = N\/(10 dot (1 - 0","0435)) approx bold(0","118 "s")$.],
  [10], [$rho = 0","8$; $sigma_s^2 = 0","01$. $N = 0","8 + (0","64 + 16 dot 0","01)\/(2 dot 0","2) = bold(2","8)$; $T = 2","8\/4 = bold(0","7 "s")$.],
)
