// Biên dịch: typst compile GK4_HieuNangMang.typ
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let accent = rgb("#1f5fa8")
#let warn = rgb("#b5452b")
#let soft = rgb("#eef3fa")

#set document(title: "GK4 — Mạng hàng đợi (2): hiệu năng mạng")
#set page(
  paper: "a4",
  margin: (x: 1.8cm, top: 2cm, bottom: 1.8cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(9pt, fill: gray)
      CSTSL · GK4 — Hiệu năng mạng hàng đợi #h(1fr) #counter(page).display()
    ]
  },
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
// Bài mẫu: không cho cắt giữa hình và lời giải
#let mau(title, body) = block(breakable: false, width: 100%,
  box-note("Bài mẫu " + title, rgb("#2e7d4f"), body))

// Ô trống có lưới chấm để viết tay trên tablet
#let o-viet(h) = block(
  width: 100%, height: h, radius: 3pt, stroke: 0.5pt + luma(200),
  fill: tiling(size: (0.5cm, 0.5cm), place(dx: 0.25cm, dy: 0.25cm, circle(radius: 0.6pt, fill: luma(185)))),
)

#let hinh(path, w) = align(center, image(path, width: w))
#let q(p, name) = node(p, name, shape: rect, stroke: 0.8pt, fill: soft, width: 1.2cm, height: 0.75cm)

// ================= TRANG BÌA =================
#align(center)[
  #v(0.2cm)
  #text(10pt, fill: gray)[Cơ sở truyền số liệu · ET4070 · ôn giữa kỳ (theo slide thầy Nguyễn Xuân Dũng)]
  #v(2pt)
  #text(22pt, weight: "bold", fill: accent)[GK4 — Mạng hàng đợi (2): hiệu năng mạng]
]
#v(6pt)

#box-note("Cách học buổi này", accent)[
  *Điều kiện trước:* đã lập được phương trình lưu lượng (GK3).
  + Đọc khuôn mục 1 (trang này) và mục 2–3 (trang sau).
  + Đọc 6 bài mẫu — mỗi bài tiếp nối một bài của GK3, chỉ cần $lambda_i$ là tính tiếp.
  + Làm 5 bài ở phần *Bài tự luyện* ngay vào ô chấm — *chưa nhìn đáp án*.
  + Dò *Đáp án* ở trang cuối; chép trang *Sổ tay phòng thi — trang 4*.

  *Qua buổi khi:* làm trọn một câu mạng hàng đợi kiểu đề thi trong ≤ 25 phút.

  #text(9.5pt, fill: gray)[Nguồn: slide thầy Dũng chương 3 tr. 80–107 (định lý Jackson, KIA, áp dụng chuyển mạch gói, bài tập 3.3); đề 20202, 20221Q; bài tập cô Lan.]
]

== 1. Khuôn tính hiệu năng mạng (sau khi có mọi $lambda_i$)

#khuon[
  #set enum(numbering: "1.a.", spacing: 0.75em)
  #set par(spacing: 0.8em)
  #show math.equation.where(block: true): set block(above: 0.5em, below: 0.5em)
  + *Mỗi nút:* $rho_i = lambda_i \/ mu_i$ (kiểm tra $< 1$).
  + *Mỗi nút M/M/1:*
    $ N_i = rho_i / (1 - rho_i), quad quad T_i = 1 / (mu_i - lambda_i) $
    $T_i$ = thời gian một yêu cầu ở tại nút $i$ trong *một lần* đi qua. \
    Nút có $c_i$ server (M/M/$c$) thì dùng công thức M/M/$c$ ở GK2 cho nút đó.
  + *Số yêu cầu trong mạng:* $N_"mạng" = sum N_i$.
  + *Thời gian trong mạng:* $T_"mạng" = N_"mạng" \/ gamma$, với $gamma$ = tổng lưu lượng từ ngoài đi vào mạng (Little cho cả mạng). *KHÔNG* chia cho $sum lambda_i$.
  + *Xác suất trạng thái* (Jackson):
    $ P(n_1, n_2, dots, n_k) = product_i (1 - rho_i) rho_i^(n_i) $
    - Mạng rỗng: $P(0, dots, 0) = product (1 - rho_i)$.
    - Có đúng 1 yêu cầu trong cả mạng: $P = product (1 - rho_i) times sum rho_i$.
  + *Trễ theo đường* (nguồn S → đích D):
    + Liệt kê mọi đường đi từ S tới D, tính xác suất mỗi đường = tích các tỉ lệ rẽ nhánh dọc đường (hoặc lưu lượng đường = $lambda_S times$ xác suất).
    + Trễ mỗi đường = tổng $T_i$ của các nút trên đường.
    + *Trễ S → D = trung bình có trọng số:*
      $ T_(S arrow.r D) = (sum ("lưu lượng đường" times "trễ đường")) / (sum "lưu lượng đường") $
    #text(fill: warn)[Đường có vòng hồi tiếp lặp vô hạn thì không liệt kê được — khi đó hỏi "trễ trung bình qua mạng" thì dùng $T = N \/ gamma$.]
]

// ================= MỤC 2–3 =================
= Mạng nhiều luồng (KIA) và trễ đầu cuối

#block(breakable: false)[
== 2. KIA — xấp xỉ độc lập Kleinrock

#text(fill: gray)[Mạng nhiều luồng, mỗi luồng đi đường cố định.]

#khuon[
  #set enum(spacing: 0.9em)
  + Tốc độ trên liên kết $(i, j)$: $lambda_(i j)$ = tổng tốc độ $x_s$ của các luồng đi qua liên kết đó.
  + $mu_(i j) = C_(i j) \/ L$ (dung lượng liên kết / độ dài gói).
  + $N_(i j) = lambda_(i j) \/ (mu_(i j) - lambda_(i j))$; #h(0.6em) $N = sum N_(i j)$.
  + $gamma = sum x_s$ (tổng tốc độ mọi luồng). #h(0.6em) *$T_"hệ thống" = N \/ gamma$*.
  + Có trễ lan truyền $d_(i j)$:
    $ T = 1 / gamma sum_((i,j)) [ lambda_(i j) / (mu_(i j) - lambda_(i j)) + lambda_(i j) d_(i j) ] $
  + Trễ của một luồng theo đường $p$:
    $ T_p = sum_((i,j) in p) [ 1 / (mu_(i j) - lambda_(i j)) + d_(i j) ] $
]
]

#block(breakable: false)[
== 3. Trễ đầu cuối trong chuyển mạch gói "store-and-forward"

#text(fill: gray)[Slide thầy Dũng tr. 97–101.]

#khuon[
  - Thời gian phát gói trên liên kết $i$: $t_(s i) = L \/ C_i$. #h(0.6em) Trễ lan truyền: $t_(p i) = d_i \/ v_p$.
  - Không có hàng đợi (mạng rỗi):
    $ d_"e2e" = sum (L / C_i + t_(p i)) $
  - Có hàng đợi:
    $ d_"e2e" = sum (L / C_i + t_(p i) + t_(q i)) $
    với $t_(q i)$ là thời gian chờ tại nút $i$ (lấy $T_q$ của M/M/1 nút đó).
]

#box-note("Câu hỏi hay gặp: \"vì sao chia bản tin thành nhiều gói?\"", accent)[
  → *Giảm trễ đầu cuối* (các gói đi gối đầu nhau trên các chặng) và *tăng độ tin cậy* (lỗi chỉ phải gửi lại một gói nhỏ).
]
]

// ================= BÀI MẪU =================
= Bài mẫu

#mau("1 — slide thầy Thanh (tiếp bài mẫu 1 của GK3)")[
  #grid(columns: (1fr, 4.6cm), column-gutter: 12pt, align: horizon,
  [
  $lambda = 30$, $mu_1 = mu_2 = 100$ → $lambda_1 = 80$, $lambda_2 = 60$, $rho_1 = 0","8$, $rho_2 = 0","6$.
  - $N_1 = 0","8 \/ 0","2 = 4$; #h(0.4em) $N_2 = 0","6 \/ 0","4 = 1","5$ → *$N_"mạng" = 5","5$ gói*.
  - *$T_"mạng" = 5","5 \/ 30 approx 0","183$ s* (chia cho $lambda = 30$ nguồn, không chia cho $80 + 60$).
  ],
  image("img/gk4_m1_haiut.png", width: 100%),
  )
]

#mau("2 — slide thầy Dũng tr. 87 (tiếp bài mẫu 2 GK3)")[
  #hinh("img/gk4_m2_mang4nut.png", 9.5cm)
  $lambda_1 = 20$, $lambda_2 = lambda_3 = 10$, $lambda_4 = 4$; #h(0.4em) $rho = 0","6$; $0","4$; $0","5$; $0","24$.
  - $N_1 = 1","5$; $N_2 approx 0","667$; $N_3 = 1$; $N_4 approx 0","316$ → *$N = 3","482$ yêu cầu*.
  - Xác suất mạng không có yêu cầu nào: $P_0 = 0","4 dot 0","6 dot 0","5 dot 0","76 = bold(0","0912)$.
  - Xác suất cả mạng có đúng 1 yêu cầu: $0","0912 times (0","6 + 0","4 + 0","5 + 0","24) = 0","0912 times 1","74 approx bold(0","159)$.
  - *$T = N \/ gamma_4 = 3","482 \/ 4 approx 0","871$ s*.
]

#mau("3 — đề cuối kỳ 20221Q câu 1 (tiếp bài mẫu 3 GK3)")[
  #hinh("img/gk4_m3_S123.png", 7.5cm)
  $rho_1 = 0","5$; $rho_2 = 0","8$; $rho_3 = 0","4$; $gamma = 2000$.
  - Xác suất mỗi server có đúng 2 yêu cầu:
    $ p(2,2,2) = (1 - 0","5) dot 0","5^2 times (1 - 0","8) dot 0","8^2 times (1 - 0","4) dot 0","4^2 $
    $ = 0","125 times 0","128 times 0","096 approx bold(0","00154) $
  - $N = 1 + 4 + 0","667 = bold(5","667 "yêu cầu")$.
  - $T = 5","667 \/ 2000 approx bold(2","83 "ms")$.
]

#mau("4 — đề cuối kỳ 20202 câu 1.2 (tiếp bài mẫu 4 GK3; x = 50%, y = 20%)")[
  #hinh("img/gk4_m4_Q1_Q6.png", 12cm)
  $mu$: Q1 $= 200$, Q2 $= 250$, Q3 $= 1 \/ 0","006 approx 166","7$, Q4 $= 1 \/ 0","007 approx 142","9$, Q5 $= 200$, Q6 $approx 166","7$ (yêu cầu/s).
  - $lambda_2 = 25$; $lambda_1 = 30$; $lambda_3 = 0","8 dot 30 = 24$; $lambda_4 = lambda_6 = 26$; $lambda_5 = 24 + 15 = 39$.
  - $rho_1 = 0","15$; $rho_2 = 0","1$; $rho_3 = 0","144$; $rho_4 = 0","182$; $rho_5 = 0","195$; $rho_6 = 0","156$.
  - *$N_"mạng" = sum rho_i \/ (1 - rho_i) approx 1","105$ yêu cầu.*
  - *Xác suất mạng rỗng $= product (1 - rho_i) approx 0","364$.*
  - $T_i$ (ms): $T_1 approx 5","882$; $T_2 approx 4","444$; $T_3 approx 7","009$; $T_5 approx 6","211$.
  - Đường S1 → D1:
    - S1 → Q1 → Q3 → Q5: xác suất $0","5 dot 0","8 = 0","4$ (20 yêu cầu/s), trễ $T_1 + T_3 + T_5 approx 19","10$ ms.
    - S1 → Q2 → Q1 → Q3 → Q5: xác suất $0","5 dot 0","2 dot 0","8 = 0","08$ (4 yêu cầu/s), trễ $T_2 + T_1 + T_3 + T_5 approx 23","55$ ms.
    - *Trễ S1 → D1* $= (20 dot 19","10 + 4 dot 23","55) \/ 24 approx bold(19","84 "ms")$.
]

#mau("5 — bài tập cô Lan, mạng có nút M/M/c")[
  #grid(columns: (1fr, 5.6cm), column-gutter: 10pt, align: horizon,
    [
      Chương trình đến $lambda = 5$/s vào khối quản lý bộ nhớ (M/M/1, $mu_m = 6","25$); sau đó vào khối CPU gồm 2 CPU (M/M/2, $mu_"CPU" = 8$ mỗi CPU); ra khỏi CPU: $0","5$ hoàn thành ra ngoài, $0","5$ sang khối I/O (M/M/1, $mu_"IO" = 8$); I/O xong quay về CPU.
      - Phương trình lưu lượng: $lambda_"CPU" = 5 + lambda_"IO"$; $lambda_"IO" = 0","5 lambda_"CPU"$ → *$lambda_"CPU" = 10$, $lambda_"IO" = 5$*; $lambda_m = 5$.
      - Bộ nhớ: $rho_m = 0","8$ → $N_m = 4$.
      - I/O: $rho_"IO" = 0","625$ → $N_"IO" approx 1","667$.
    ],
    image("img/gk4_m5_cpu_io.png", width: 100%),
  )
  - CPU (M/M/2): $a = 10 \/ 8 = 1","25$; $rho = 0","625$;
    $ p_(0,"CPU") = 1 / (1 + 1","25 + 1","25^2 \/ (2 dot 0","375)) approx 0","2308 $
    $C approx 0","481$; $N_q approx 0","801$; $N_"CPU" = 0","801 + 1","25 approx 2","051$.
  - Xác suất cả hệ rỗi: $(1 - 0","8) times 0","2308 times (1 - 0","625) approx bold(0","0173)$.
  - Xác suất 1 task ở bộ nhớ, 0 ở CPU, 2 ở I/O: $(0","2 dot 0","8) times 0","2308 times (0","375 dot 0","625^2) approx bold(0","0054)$.
]

#mau("6 — bài tập 3.3 của thầy Dũng (mạng LAN có ARQ)")[
  #hinh("img/gk4_m6_lan_arq.png", 13cm)
  S1 —L1→ R1 —L2→ R2 —L3→ D; S2 —L4→ R2. $lambda_1 = 240$ gói/phút $= 4$ gói/s; $lambda_2 = 120$ gói/phút $= 2$ gói/s. $1 \/ mu_1 = 0","2$ s → $mu_1 = 5$; $1 \/ mu_2 = 0","1$ s → $mu_2 = 10$. Trên L3 gói lỗi với $p_e = 10%$. Giữa D và S1, S2 dùng ARQ (gói lỗi phải gửi lại từ nguồn).

  #text(fill: accent)[*Khuôn:* ARQ đầu cuối → mỗi gói phải đi trung bình $1 \/ (1 - p_e)$ lần → lưu lượng thực qua các nút tăng $1 \/ (1 - p_e)$ lần.]
  - $lambda_(R 1) = 4 \/ 0","9 approx 4","444$; #h(0.4em) $lambda_(R 2) = (4 + 2) \/ 0","9 approx 6","667$.
  - $rho_1 approx 0","889$ → $N_1 = bold(8 "gói")$; #h(0.4em) $rho_2 approx 0","667$ → $N_2 = bold(2 "gói")$; #h(0.4em) số gói trong mạng $= bold(10)$.
  - $T_1 = 1 \/ (5 - 4","444) = bold(1","8 "s")$; #h(0.4em) $T_2 = 1 \/ (10 - 6","667) = bold(0","3 "s")$.
  - S1 → D: mỗi lần thử đi qua R1 và R2, trung bình $1 \/ 0","9$ lần: $(1","8 + 0","3) \/ 0","9 approx bold(2","33 "s")$.
  - S2 → D: $0","3 \/ 0","9 approx bold(0","33 "s")$.

  #text(fill: warn)[Nếu đề hiểu ARQ chỉ giữa R2 và D (gửi lại từ R2) thì chỉ R2 có lưu lượng tăng; R1 có $lambda = 4$, $N_1 = 4$, $T_1 = 1$ s. Ghi rõ cách hiểu khi làm bài.]
]

// ================= SỔ TAY =================
= Sổ tay phòng thi — trang 4

#set text(13pt)
#set par(leading: 0.9em)
#box-note("HIỆU NĂNG MẠNG (sau khi có mọi λᵢ)", accent)[
  $N_i = rho_i \/ (1 - rho_i)$ #h(2em) $T_i = 1 \/ (mu_i - lambda_i)$ #h(1em) (nút M/M/$c$: dùng công thức M/M/$c$) \
  $N_"mạng" = sum N_i$ #h(2em) $T_"mạng" = N_"mạng" \/ gamma$ #h(1em) ($gamma$ = tổng nguồn, *KHÔNG* phải $sum lambda_i$) \
  $P(n_1, dots, n_k) = product (1 - rho_i) rho_i^(n_i)$ \
  rỗng: $product (1 - rho_i)$ #h(2em) đúng 1 yêu cầu: $product (1 - rho_i) dot sum rho_i$
]
#box-note("TRỄ S → D", accent)[
  Liệt kê đường; xác suất đường = tích tỉ lệ; trễ đường = $sum T_i$ \
  $T(S arrow.r D) = sum ("lưu lượng đường" times "trễ đường") \/ sum "lưu lượng đường"$
]
#box-note("KIA", accent)[
  $lambda_(i j) = sum$ luồng qua $(i, j)$ #h(1.5em) $N = sum lambda_(i j) \/ (mu_(i j) - lambda_(i j))$ #h(1.5em) $T = N \/ gamma$ $(+ sum lambda_(i j) d_(i j) \/ gamma)$ \
  trễ luồng $p = sum [1 \/ (mu_(i j) - lambda_(i j)) + d_(i j)]$
]
#box-note("STORE-AND-FORWARD · ARQ", accent)[
  $d_"e2e" = sum (L \/ C_i + t_(p i) + t_(q i))$ \
  ARQ đầu cuối lỗi $p_e$: lưu lượng qua nút $times 1 \/ (1 - p_e)$ \
  trễ S → D $= (sum T_i) \/ (1 - p_e)$
]
#box-note("Lỗi hay mắc", warn)[
  - $T_"mạng" = N \/ sum lambda_i$ (sai) → phải chia cho tổng lưu lượng nguồn $gamma$.
  - Trễ S → D lấy trung bình cộng các đường mà không nhân trọng số lưu lượng.
  - Quên rằng $T_i$ là thời gian ở nút cho mỗi lần đi qua; đường đi qua nút 2 lần thì cộng 2 lần.
  - Nút có nhiều server mà vẫn dùng công thức M/M/1.
]
#set text(11.5pt)
#set par(leading: 0.75em)

// ================= BÀI TẬP =================
= Bài tự luyện — viết thẳng vào ô chấm

#text(fill: gray)[Làm hết rồi mới lật trang đáp án.]

#let bai(n, body, h: 5.5cm) = block(breakable: false, width: 100%)[
  *Bài #n.* #body
  #v(-2pt)
  #o-viet(h)
  #v(4pt)
]

#let so-do(d) = align(center, block(inset: (y: 4pt), {
  set text(10pt)
  d
}))

#bai(1, h: 5cm)[Mạng bài tự luyện 5 của GK3 ($lambda_1 approx 153","8$; $lambda_2 approx 107","7$; $lambda_3 approx 46","2$) với $mu = 200$ cho cả ba nút. Tính $N_"mạng"$, $T_"mạng"$, xác suất mạng rỗng, xác suất trạng thái $(1, 0, 2)$.

  #grid(columns: (1fr, auto), column-gutter: 12pt, align: horizon,
  text(9.5pt, fill: gray)[Sơ đồ (xem bài tự luyện 5 của GK3): nguồn 100 yêu cầu/s vào Q1; Q1 → Q2 (70%), Q3 (30%); Q2 → ra ngoài 50%, về Q1 50%; Q3 → ra ngoài.],
  so-do(diagram(
    spacing: (1.6cm, 0.85cm), edge-stroke: 0.8pt, mark-scale: 80%,
    node((0,0), [100 yêu cầu/s], stroke: none),
    q((1,0), [Q1]), q((2,0), [Q2]), q((2,1), [Q3]),
    node((3.2,0), [ra], stroke: none), node((3.2,1), [ra], stroke: none),
    edge((0,0),(1,0),"-|>"),
    edge((1,0),(2,0),"-|>", [70%], label-side: left),
    edge((1,0),(1,1),(2,1),"-|>", [30%], label-pos: 0.75, label-side: right),
    edge((2,0),(3.2,0),"-|>", [50%], label-side: left, label-pos: 0.7),
    edge((2,0),(2.5,0),(2.5,-0.8),(0.6,-0.8),(0.6,0),(1,0),"-|>", [50% về Q1], label-pos: 0.55, label-side: right),
    edge((2,1),(3.2,1),"-|>"),
  )))
]

#bai(2, h: 5cm)[Mạng bài tự luyện 6 của GK3 với $x = 50%$ ($mu_1 = 50$, $mu_2 = 40$, $mu_3 = 80$). Tính $N_"mạng"$ và $T_"mạng"$.

  #grid(columns: (1fr, auto), column-gutter: 12pt, align: horizon,
  text(9.5pt, fill: gray)[Sơ đồ (xem bài tự luyện 6 của GK3): nguồn 60 yêu cầu/s tách $x$ → Q1, phần còn lại → Q2; Q1 → Q3; Q2 → Q3; Q3 → ra ngoài 80%, về Q1 20%.],
  so-do(diagram(
    spacing: (1.6cm, 0.85cm), edge-stroke: 0.8pt, mark-scale: 80%,
    node((0,0.5), [60 yêu cầu/s], stroke: none),
    q((1,0), [Q1]), q((1,1), [Q2]), q((2,0.5), [Q3]),
    node((3.2,0.5), [ra], stroke: none),
    edge((0,0.5),(0.5,0.5),"-"),
    edge((0.5,0.5),(0.5,0),(1,0),"-|>", [$x$], label-side: left, label-pos: 0.7),
    edge((0.5,0.5),(0.5,1),(1,1),"-|>", [$1 - x$], label-side: right, label-pos: 0.7),
    edge((1,0),(1.5,0),(1.5,0.5),(2,0.5),"-|>"),
    edge((1,1),(1.5,1),(1.5,0.5),"-"),
    edge((2,0.5),(3.2,0.5),"-|>", [80%], label-side: left, label-pos: 0.7),
    edge((2,0.5),(2.5,0.5),(2.5,-0.6),(0.75,-0.6),(0.75,0),"-|>", [20% về Q1], label-side: right, label-pos: 0.55),
  )))
]

#bai(3, h: 6cm)[Ba luồng đi đường cố định: luồng 1 A→B→C 50 gói/s; luồng 2 A→B→D 30 gói/s; luồng 3 B→C 40 gói/s. $mu_(A B) = 100$, $mu_(B C) = 150$, $mu_(B D) = 80$ gói/s. Dùng KIA tính $N$, $T$ của hệ thống và trễ của từng luồng. Nếu mỗi liên kết có thêm trễ lan truyền 1 ms thì $T$ hệ thống bằng bao nhiêu?
  #grid(columns: (1fr, 1fr), align: horizon,
    so-do(diagram(
      spacing: (2.8cm, 1.1cm), edge-stroke: 0.8pt, mark-scale: 80%,
      node-stroke: 0.8pt, node-fill: soft,
      node((0,0.5), [A], shape: circle, radius: 0.38cm),
      node((1,0.5), [B], shape: circle, radius: 0.38cm),
      node((2,0), [C], shape: circle, radius: 0.38cm),
      node((2,1), [D], shape: circle, radius: 0.38cm),
      edge((0,0.5),(1,0.5),"-|>", [$mu_(A B) = 100$], label-side: left),
      edge((1,0.5),(2,0),"-|>", [$mu_(B C) = 150$], label-side: left),
      edge((1,0.5),(2,1),"-|>", [$mu_(B D) = 80$], label-side: right),
    )),
    text(10pt)[
      - luồng 1: A → B → C, 50 gói/s
      - luồng 2: A → B → D, 30 gói/s
      - luồng 3: B → C, 40 gói/s
    ],
  )
]

#bai(4, h: 5cm)[Gói 12000 bit đi qua 3 liên kết 10 Mbps, mỗi liên kết trễ lan truyền 2 ms, mạng rỗi. Tính trễ đầu cuối.]

#bai(5, h: 5cm)[Bản tin 120000 bit đi qua 3 liên kết như bài 4. So sánh trễ đầu cuối khi gửi nguyên bản tin và khi chia thành 10 gói bằng nhau (bỏ qua phần đầu gói).]

// ================= ĐÁP ÁN =================
= Đáp án

#table(
  columns: (auto, 1fr),
  [Bài], [Đáp án],
  [1], [$rho approx 0","769$; $0","538$; $0","231$. \
    $N approx 3","333 + 1","167 + 0","300 = bold(4","80)$; #h(0.4em) $T = 4","8 \/ 100 = bold(48 "ms")$; \
    $P_0 = 0","231 dot 0","462 dot 0","769 approx bold(0","0819)$; \
    $P(1,0,2) = (0","231 dot 0","769) dot 0","462 dot (0","769 dot 0","231^2) approx bold(0","0034)$.],
  [2], [$lambda_1 = 45$, $lambda_2 = 30$, $lambda_3 = 75$; $rho = 0","9$; $0","75$; $0","9375$ → $N = 9 + 3 + 15 = bold(27)$; \ $T = 27 \/ 60 = bold(0","45 "s")$.],
  [3], [$lambda_(A B) = 80$, $lambda_(B C) = 90$, $lambda_(B D) = 30$. \
    $N = 80 \/ 20 + 90 \/ 60 + 30 \/ 50 = bold(6","1)$; #h(0.4em) $gamma = 120$; #h(0.4em) $T = 6","1 \/ 120 approx bold(50","8 "ms")$. \
    Luồng 1: $1 \/ 20 + 1 \/ 60 approx bold(66","7 "ms")$; luồng 2: $1 \/ 20 + 1 \/ 50 = bold(70 "ms")$; \ luồng 3: $1 \/ 60 approx bold(16","7 "ms")$. \
    Thêm lan truyền: $T = (6","1 + 200 dot 0","001) \/ 120 = bold(52","5 "ms")$.],
  [4], [$3 times (12000 \/ 10^7 + 0","002) = 3 times 3","2 "ms" = bold(9","6 "ms")$.],
  [5], [Nguyên bản tin: $3 times (12 "ms" + 2 "ms") = bold(42 "ms")$. \
    Chia 10 gói (mỗi gói $1","2$ ms trên mỗi liên kết): \ gói cuối tới sau $3 dot 2 "ms" + (3 + 10 - 1) dot 1","2 "ms" = bold(20","4 "ms")$ → chia gói nhanh hơn gấp đôi.],
)
