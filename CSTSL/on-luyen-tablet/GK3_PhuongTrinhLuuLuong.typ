// Biên dịch: typst compile GK3_PhuongTrinhLuuLuong.typ
// Sơ đồ bài tự luyện 2, 5, 6 vẽ bằng gói fletcher (Typst).
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let accent = rgb("#1f5fa8")
#let warn = rgb("#b5452b")
#let soft = rgb("#eef3fa")

#set document(title: "GK3 — Mạng hàng đợi (1): phương trình lưu lượng")
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
// Bài mẫu có hình: không cho tách hình khỏi lời giải
#let mau-hinh(n, title, body) = block(breakable: false, width: 100%,
  box-note("Bài mẫu " + n + " — " + title, rgb("#2e7d4f"), body))

// Ô trống có lưới chấm để viết tay trên tablet
#let o-viet(h) = block(
  width: 100%, height: h, radius: 3pt, stroke: 0.5pt + luma(200),
  fill: tiling(size: (0.5cm, 0.5cm), place(dx: 0.25cm, dy: 0.25cm, circle(radius: 0.6pt, fill: luma(185)))),
)

// Hình có viền mảnh
#let hinh(path, w, nguon) = align(center, block(spacing: 6pt)[
  #box(stroke: 0.5pt + luma(210), inset: 4pt, radius: 2pt, image(path, width: w))
])

// ---- công cụ vẽ sơ đồ khối (bài tự luyện) ----
#let C = rgb("#1f3f6e")
#let lb(t) = text(fill: warn, t)
#let q(pos, t, name) = node(pos, text(C, weight: "bold", t), name: name, stroke: 1pt + C,
  fill: rgb("#e6eef8"), corner-radius: 3pt, width: 18mm, height: 8.5mm)
#let o(pos, t, name) = node(pos, t, name: name, stroke: none)
#let so-do(..args) = align(center, block(spacing: 8pt, diagram(
  spacing: (15mm, 9mm), edge-stroke: 1pt + C, mark-scale: 80%, ..args)))

// ================= TRANG BÌA =================
#align(center)[
  #v(1cm)
  #text(22pt, weight: "bold", fill: accent)[GK3 — Mạng hàng đợi (1): \ phương trình lưu lượng]
  #v(2pt)
  #text(11pt, fill: gray)[phương trình lưu lượng · điều kiện ổn định · dạng "tìm x"]
]
#v(8pt)

#box-note("Cách học buổi này", accent)[
  + Đọc mục 0–3 (khuôn giải).
  + Xem 4 bài mẫu: nhìn hình, tự lập phương trình lưu lượng rồi mới so lời giải.
  + Làm 6 bài ở phần *Bài tự luyện* ngay vào ô chấm bên dưới mỗi bài — *chưa nhìn đáp án*.
  + Dò *Đáp án* ở trang cuối.
  + Chép trang *Sổ tay phòng thi — trang 3* vào sổ (hoặc giữ nguyên trang đó).

  *Qua buổi khi:* lập đúng phương trình lưu lượng ngay lần đầu cho cả 6 bài tự luyện, có bước kiểm tra "tổng vào = tổng ra".
]


== 0. Vì sao tách mạng thành từng nút được (1 câu để ghi vào bài)

- *Định lý Burke:* hàng đợi M/M/1 (hoặc M/M/c, M/M/∞) ổn định có đầu vào Poisson $lambda$ thì *đầu ra cũng là Poisson $lambda$*.
- *Định lý Jackson:* trong mạng hàng đợi mở, mỗi nút $i$ được coi như một hàng đợi *M/M/1 độc lập* với tốc độ đến $lambda_i$ (tính bằng phương trình lưu lượng) và $rho_i = lambda_i \/ mu_i$.

Ký hiệu thầy Dũng:

#table(
  columns: (auto, 1fr),
  [Ký hiệu], [Nghĩa],
  [$gamma_i$], [lưu lượng từ ngoài đi thẳng vào nút $i$],
  [$r_(j i)$], [xác suất yêu cầu rời nút $j$ đi tới nút $i$],
  [$r_(i 0)$], [xác suất rời nút $i$ đi ra khỏi mạng],
  [$lambda_i$], [tổng lưu lượng vào nút $i$],
)

#text(fill: gray)[Slide thầy Thanh và nhiều lời giải viết $theta_i$ thay cho $lambda_i$ — cùng một thứ.]

// ================= KHUÔN =================
= Khuôn giải — lưu lượng, ổn định, tìm x

== 1. Khuôn lập phương trình lưu lượng

#khuon[
  + *Đặt tên* $lambda_1, lambda_2, dots$ cho mọi nút (kể cả nút chỉ có một đường vào).
  + *Đọc từng mũi tên đi ra* của mỗi nút: nhánh nào ghi % thì dùng %, nhánh không ghi = phần còn lại (100% − tổng các nhánh có ghi). Một đường ra duy nhất = 100%.
  + Với mỗi nút $i$, viết:
    $ lambda_i = gamma_i + sum_j r_(j i) lambda_j $
    \= (lưu lượng từ nguồn đổ thẳng vào $i$) + (mỗi nút $j$ có nhánh trỏ vào $i$: tỉ lệ nhánh $times lambda_j$).
  + Giải hệ: bắt đầu từ nút chỉ phụ thuộc nguồn; nút có vòng hồi tiếp thì chuyển vế \
    ($lambda_1 = gamma + 0","5 lambda_1 arrow.r lambda_1 = 2 gamma$).
  + *Kiểm tra:* tổng lưu lượng ra khỏi mạng (các nhánh đi tới đích) = tổng lưu lượng nguồn. Sai là đọc nhầm nhánh.
]

#box-note("Mẹo đọc hình", accent)[
  - Đường nối từ đầu ra một nút quay về đầu vào một nút phía trước = *hồi tiếp*.
  - Điểm hai đường nhập = *cộng*.
  - Điểm một đường tách = *nhân xác suất*.
]

== 2. Điều kiện ổn định

- Mạng ổn định ⇔ *mọi nút* có $rho_i = lambda_i \/ mu_i < 1$ (nút có $c_i$ server: $lambda_i < c_i mu_i$).
- Đề hỏi "điều kiện của $mu$ (các nút giống nhau) để ổn định" → $bold(mu > max lambda_i)$.
- Đề hỏi "điều kiện của $x$ / $r$ để ổn định" → viết từng $rho_i < 1$ theo $x$, giải từng bất phương trình, lấy *giao* các khoảng (và $0 <= x <= 100%$).
- Đề hỏi "$gamma$ lớn nhất để ổn định" → $lambda_i$ tỉ lệ với $gamma$; mỗi nút cho một chặn trên; lấy chặn nhỏ nhất.

== 3. Dạng "tìm x để tốc độ đến D1 bằng (gấp k lần) tốc độ đến D2"

#khuon[
  + Lập phương trình lưu lượng, để $x$ là ẩn → mọi $lambda_i$ là biểu thức theo $x$.
  + Tốc độ đến đích D = tổng các nhánh đổ vào D:
    $ lambda_D = sum ("tỉ lệ nhánh đi tới D") times lambda_"nút đó" quad (+ "nguồn nào đi thẳng tới D") $
  + Giải phương trình $lambda_(D 1) = lambda_(D 2)$ (hoặc $lambda_(D 1) = k lambda_(D 2)$).
  + Kiểm tra: $lambda_(D 1) + lambda_(D 2) =$ tổng nguồn; và $0 <= x <= 100%$.
]

// ================= BÀI MẪU =================
= Bài mẫu 1, 2 — lập và giải phương trình lưu lượng

#mau-hinh("1", "mạng 2 nút có hồi tiếp")[
  #grid(columns: (6.4cm, 1fr), column-gutter: 12pt, align: horizon,
    hinh("img/gk3_mau1_thanh_vd1.png", 5.8cm, [Slide thầy Thanh, CSTSL4 — Ví dụ 1]),
    [*Đọc hình:* nguồn $lambda$ vào Q1; ra khỏi Q1: $1\/4$ quay lại chính Q1, $3\/4$ sang Q2; ra khỏi Q2: $1\/2$ quay về Q1, $1\/2$ ra ngoài.],
  )

  - $lambda_1 = lambda + 1/4 lambda_1 + 1/2 lambda_2$; #h(1em) $lambda_2 = 3/4 lambda_1$.
  - Thay: $lambda_1 = lambda + 1/4 lambda_1 + 3/8 lambda_1 arrow.r 3/8 lambda_1 = lambda arrow.r bold(lambda_1 = (8 lambda) / 3)$, #h(0.5em) $bold(lambda_2 = 2 lambda)$.
  - Kiểm tra: ra ngoài $= 1/2 lambda_2 = lambda$ ✔.
  - Với $lambda = 30$ gói/s, $mu_1 = mu_2 = 100$: $lambda_1 = 80$, $lambda_2 = 60$ → $rho_1 = 0","8$, $rho_2 = 0","6$ → ổn định.
]

#v(6pt)

#mau-hinh("2", "mạng mở 4 nút")[
  #hinh("img/gk3_mau2_dung_4nut.png", 11cm, [Slide thầy Dũng, 03-HangDoi tr. 87])

  *Đọc hình:* $gamma_4 = 4$ yêu cầu/s đi vào nút 4; nút 4 → nút 1 ($r_41 = 1$); nút 1 → nút 2 ($r_12 = 0","5$) và nút 3 ($r_13 = 0","5$); nút 2 → nút 1 ($r_21 = 1$); nút 3 → nút 1 ($r_31 = 0","6$), ra ngoài ($r_30 = 0","4$). \
  $1\/mu_1 = 0","03$ s; $1\/mu_2 = 0","04$ s; $1\/mu_3 = 0","05$ s; $1\/mu_4 = 0","06$ s.

  *(a) Tính $lambda_1, lambda_2, lambda_3, lambda_4$.*
  - $lambda_4 = gamma_4 = 4$.
  - $lambda_1 = lambda_4 + lambda_2 + 0","6 lambda_3$; #h(0.6em) $lambda_2 = 0","5 lambda_1$; #h(0.6em) $lambda_3 = 0","5 lambda_1$.
  - $lambda_1 = 4 + 0","5 lambda_1 + 0","3 lambda_1 arrow.r 0","2 lambda_1 = 4 arrow.r bold(lambda_1 = 20)$, $bold(lambda_2 = lambda_3 = 10)$, $bold(lambda_4 = 4)$ (yêu cầu/s).
  - Kiểm tra: ra ngoài $= 0","4 dot lambda_3 = 4 = gamma_4$ ✔.
  - $rho_1 = 20 dot 0","03 = 0","6$; $rho_2 = 10 dot 0","04 = 0","4$; $rho_3 = 10 dot 0","05 = 0","5$; $rho_4 = 4 dot 0","06 = 0","24$ → ổn định.

  *(b) Giữ $r_30 = 0","4$, $r_31 = 0","6$; tìm điều kiện của $r_12$, $r_13$ ($r_12 + r_13 = 1$) để ổn định.*
  - $lambda_1 = 4 + r_12 lambda_1 + 0","6 r_13 lambda_1 = 4 + lambda_1 (1 - 0","4 r_13) arrow.r bold(lambda_1 = 10 \/ r_13)$; \
    $lambda_2 = r_12 lambda_1 = 10(1 - r_13) \/ r_13$; #h(0.6em) $lambda_3 = 10$; #h(0.6em) $lambda_4 = 4$.
  - $rho_1 = 0","03 dot 10 \/ r_13 < 1 arrow.r r_13 > 0","3$.
  - $rho_2 = 0","04 dot 10(1 - r_13) \/ r_13 < 1 arrow.r 0","4(1 - r_13) < r_13 arrow.r r_13 > 0","286$.
  - $rho_3 = 0","5 < 1$; $rho_4 = 0","24 < 1$ (luôn đúng).
  - Kết luận: $bold(r_13 > 0","3)$ *và* $bold(r_12 = 1 - r_13 < 0","7)$.
]

= Bài mẫu 3, 4 — mạng trong đề cuối kỳ

#mau-hinh("3", "đề cuối kỳ 20221Q, câu 1 (mạng có vòng hồi tiếp về đầu)")[
  #hinh("img/gk3_mau3_ck20221.png", 10.5cm, [Đề cuối kỳ 20221Q, câu 1])

  *Đọc hình:* $gamma = 2000$ yêu cầu/s vào S1; S1 → S2 (50%), S3 (50%); S2 → quay về S1 (100%); S3 → ra ngoài 40%, quay về S1 60%. \
  $mu_1 = 20000$, $mu_2 = 6250$, $mu_3 = 12500$ yêu cầu/s.

  - $lambda_1 = 2000 + lambda_2 + 0","6 lambda_3$; #h(0.6em) $lambda_2 = lambda_3 = 0","5 lambda_1$.
  - $lambda_1 = 2000 + 0","5 lambda_1 + 0","3 lambda_1 arrow.r bold(lambda_1 = 10000)$, $bold(lambda_2 = lambda_3 = 5000)$.
  - Kiểm tra: ra ngoài $= 0","4 dot 5000 = 2000$ ✔.
  - $rho_1 = 0","5$; $rho_2 = 0","8$; $rho_3 = 0","4$ → ổn định. #text(fill: gray)[(Phần tính $N$, $T$, $p(2,2,2)$ làm ở GK4.)]
]

#v(6pt)

#mau-hinh("4", "đề cuối kỳ 20202, câu 1.1 (dạng tìm x, số liệu theo MSSV …67)")[
  #hinh("img/gk3_mau4_ck20202.png", 13cm, [Đề cuối kỳ 20202, câu 1])

  *Đọc hình:* S1 = 50 yêu cầu/s tách: $x$ → Q2, $(1 - x)$ → Q1. Q2: 20% quay về đầu vào Q1, 80% → Q4. Đầu ra Q1 tách: $y$ → Q4 (nhánh y% tách ra trên đường nối Q1 → Q3, trước khi vào Q3), $(1 - y)$ → Q3. Q3 → Q5. S2 = 20 yêu cầu/s tách: 25% đi thẳng tới D2, 75% → Q5. Q5 → D1. Q4 → Q6 → D2.

  $y = 10 dot (1 + overline(b a) mod 6)%$; $overline(b a) = 67 arrow.r 67 mod 6 = 1 arrow.r bold(y = 20%)$.

  - $lambda_2 = 50 x$; #h(0.6em) $lambda_1 = 50(1 - x) + 0","2 dot lambda_2 = 50 - 40 x$; #h(0.6em) $lambda_3 = (1 - y) lambda_1 = 0","8(50 - 40 x)$.
  - $lambda_4 = 0","8 lambda_2 + y dot lambda_1 = 40 x + 10 - 8 x = 10 + 32 x$; #h(0.6em) $lambda_6 = lambda_4$.
  - $lambda_5 = lambda_3 + 0","75 dot 20 = 40 - 32 x + 15 = 55 - 32 x$.
  - $lambda_(D 1) = lambda_5 = 55 - 32 x$; #h(0.6em) $lambda_(D 2) = lambda_6 + 0","25 dot 20 = 15 + 32 x$.
  - $lambda_(D 1) = lambda_(D 2) arrow.r 64 x = 40 arrow.r bold(x = 62","5%)$; tốc độ đến D1 $= 55 - 20 = bold(35)$ *yêu cầu/s* \
    (D2 cũng 35; tổng $70 = 50 + 20$ ✔).
]

// ================= SỔ TAY =================
= Sổ tay phòng thi — trang 3

#set text(12pt)
#box-note("PHƯƠNG TRÌNH LƯU LƯỢNG", accent)[
  $ lambda_i = gamma_i + sum_j r_(j i) lambda_j $
  - nhánh không ghi % = phần còn lại; #h(1em) 1 đường ra = 100%
  - hồi tiếp: chuyển vế #h(0.5em) ($lambda = gamma + a lambda arrow.r lambda = gamma \/ (1 - a)$)
  - *KIỂM TRA:* tổng ra khỏi mạng = tổng nguồn
]
#box-note("ỔN ĐỊNH", accent)[
  - mọi $rho_i = lambda_i \/ mu_i < 1$ #h(1em) ($c_i$ server: $lambda_i < c_i mu_i$)
  - $mu$ chung: $mu > max lambda_i$; #h(1em) theo $x$: giải từng $rho_i < 1$, lấy *giao*
]
#box-note("TÌM x", accent)[
  $lambda_D = sum ("tỉ lệ nhánh tới D") dot lambda_"nút"$ (+ nguồn đi thẳng) #h(0.5em) → #h(0.5em) giải $lambda_(D 1) = k lambda_(D 2)$
]
#box-note("BURKE · JACKSON", accent)[
  - Burke: M/M/1 ổn định, vào Poisson $lambda$ → ra Poisson $lambda$
  - Jackson: mỗi nút coi như M/M/1 độc lập với $lambda_i$
]
#box-note("Lỗi hay mắc", warn)[
  - Quên nhánh "phần còn lại" (chỉ cộng các nhánh có ghi %).
  - Cộng nhầm lưu lượng của nguồn vào nút mà nguồn không đi qua.
  - Quên rằng nguồn có thể đi thẳng tới đích (S2 → D2 25% ở đề 20202).
  - Không kiểm tra tổng vào = tổng ra.
]
#set text(11.5pt)

// ================= BÀI TẬP =================
= Bài tự luyện — viết thẳng vào ô chấm

#text(fill: gray)[Bài nào cũng: đặt tên $lambda_i$ → lập hệ → giải → kiểm tra tổng ra = tổng nguồn. Làm hết rồi mới lật trang đáp án.]

#let bai(n, body, fig: none, h: 5.5cm) = block(breakable: false, width: 100%)[
  *Bài #n.* #body
  #if fig != none { fig }
  #v(-2pt)
  #o-viet(h)
  #v(6pt)
]

#bai(1, fig: hinh("img/gk3_mau1_thanh_vd1.png", 5cm, [hình bài mẫu 1]))[
  (Bài mẫu 1 đổi số) $lambda = 40$ gói/s; $mu_1 = 120$, $mu_2 = 100$. Tính $lambda_1$, $lambda_2$, $rho_1$, $rho_2$ và kết luận ổn định.
]

#bai(2, fig: so-do(
  o((0, 0), [50 gói/s], <s>),
  q((1, 0), [Nút 1], <n1>),
  q((2, 0), [Nút 2], <n2>),
  o((3.2, 0), [ra ngoài], <out>),
  edge(<s>, <n1>, "-|>"),
  edge(<n1>, <n2>, "-|>"),
  edge(<n2>, <out>, "-|>", lb[$1 - p$]),
  edge(<n2>, (2, 1), (1, 1), <n1>, "-|>", lb[$p$ (quay lại nút 1)], label-side: left),
))[
  Hai nút nối tiếp: nguồn 50 gói/s vào nút 1; nút 1 → nút 2; ra khỏi nút 2: $p$ quay lại nút 1, $(1 - p)$ ra ngoài. $mu_1 = 100$, $mu_2 = 80$. Tìm điều kiện của $p$ để mạng ổn định. Với $p = 0","2$ tính $rho_1$, $rho_2$.
]

#bai(3, h: 6cm, fig: hinh("img/gk3_mau4_ck20202.png", 10cm, [hình bài mẫu 4 (đề 20202)]))[
  Với mạng đề 20202 ở bài mẫu 4 ($y = 20%$), tìm $x$ để tốc độ đến D1 *gấp đôi* tốc độ đến D2, và tính hai tốc độ đó.
]

#bai(4, fig: hinh("img/gk3_mau2_dung_4nut.png", 8.5cm, [hình bài mẫu 2 (thầy Dũng tr. 87)]))[
  Mạng 4 nút của thầy Dũng (bài mẫu 2) nhưng $gamma_4$ thay đổi. Tìm $gamma_4$ lớn nhất để mạng còn ổn định.
]

#bai(5, h: 6cm, fig: so-do(
  o((0, 0), [100 yêu cầu/s], <s>),
  q((1, 0), [Q1], <q1>),
  q((2.2, -0.8), [Q2], <q2>),
  q((2.2, 0.8), [Q3], <q3>),
  o((3.6, -0.8), [ra ngoài], <o2>),
  o((3.6, 0.8), [ra ngoài], <o3>),
  edge(<s>, <q1>, "-|>"),
  edge(<q1>, <q2>, "-|>", lb[70%], label-side: left),
  edge(<q1>, <q3>, "-|>", lb[30%], label-side: right),
  edge(<q2>, <o2>, "-|>", lb[50%]),
  edge(<q3>, <o3>, "-|>"),
  edge(<q2>, (2.2, -1.7), (1, -1.7), <q1>, "-|>", lb[50% quay về Q1], label-side: right),
))[
  Nguồn 100 yêu cầu/s vào Q1. Q1 → Q2 (70%), Q3 (30%). Q2 → ra ngoài 50%, quay về Q1 50%. Q3 → ra ngoài. Ba nút có cùng $mu$. Tính $lambda_1$, $lambda_2$, $lambda_3$ và điều kiện của $mu$.
]

#bai(6, h: 6cm, fig: so-do(
  o((0, 0), [60 yêu cầu/s], <s>),
  q((1.2, -0.8), [Q1], <q1>),
  q((1.2, 0.8), [Q2], <q2>),
  q((2.4, 0), [Q3], <q3>),
  o((3.7, 0), [ra ngoài], <out>),
  edge(<s>, <q1>, "-|>", lb[$x$], label-side: left),
  edge(<s>, <q2>, "-|>", lb[$1 - x$], label-side: right),
  edge(<q1>, <q3>, "-|>"),
  edge(<q2>, <q3>, "-|>"),
  edge(<q3>, <out>, "-|>", lb[80%]),
  edge(<q3>, (2.4, -1.7), (1.2, -1.7), <q1>, "-|>", lb[20% quay về Q1], label-side: right),
))[
  Nguồn 60 yêu cầu/s tách: $x$ → Q1, phần còn lại → Q2. Q1 → Q3; Q2 → Q3. Q3 → ra ngoài 80%, quay về Q1 20%. $mu_1 = 50$, $mu_2 = 40$, $mu_3 = 80$. Tìm điều kiện của $x$ để mạng ổn định.
]

// ================= ĐÁP ÁN =================
= Đáp án

#table(
  columns: (auto, 1fr),
  [Bài], [Đáp án],
  [1], [$lambda_1 = 8 dot 40 \/ 3 approx bold(106","7)$; $lambda_2 = bold(80)$. $rho_1 approx bold(0","889)$; $rho_2 = bold(0","8)$ → *ổn định*.],
  [2], [$lambda_1 = lambda_2 = 50 \/ (1 - p)$. $rho_1 < 1 arrow.r p < 0","5$; $rho_2 < 1 arrow.r p < 0","375$ → $bold(p < 0","375)$. \
    Với $p = 0","2$: $lambda = 62","5$ → $rho_1 = bold(0","625)$, $rho_2 approx bold(0","781)$.],
  [3], [$55 - 32 x = 2(15 + 32 x) arrow.r 96 x = 25 arrow.r bold(x approx 26","04%)$; $lambda_(D 1) approx bold(46","67)$, $lambda_(D 2) approx bold(23","33)$ yêu cầu/s (tổng 70 ✔).],
  [4], [$lambda_1 = 5 gamma_4$, $lambda_2 = lambda_3 = 2","5 gamma_4$, $lambda_4 = gamma_4$. \
    $rho_1 = 0","15 gamma_4 < 1 arrow.r gamma_4 < 6","67$; $rho_2 = 0","1 gamma_4 arrow.r gamma_4 < 10$; \
    $rho_3 = 0","125 gamma_4 arrow.r gamma_4 < 8$; $rho_4 = 0","06 gamma_4 arrow.r gamma_4 < 16","7$. \
    → $bold(gamma_4 < 6","67)$ *yêu cầu/s*.],
  [5], [$lambda_1 = 100 + 0","5 lambda_2$, $lambda_2 = 0","7 lambda_1$ → $lambda_1 = 100 \/ 0","65 approx bold(153","8)$; $lambda_2 approx bold(107","7)$; $lambda_3 approx bold(46","2)$. \
    Kiểm tra ra ngoài: $0","5 dot 107","7 + 46","2 = 100$ ✔. Điều kiện: $bold(mu > 153","8)$.],
  [6], [$lambda_3 = 60 \/ 0","8 = 75$; $lambda_1 = 60 x + 15$; $lambda_2 = 60(1 - x)$. \
    $rho_1 < 1 arrow.r x < 0","583$; $rho_2 < 1 arrow.r x > 0","333$; $rho_3 = 0","9375 < 1$. \
    → $bold(33","3% < x < 58","3%)$.],
)

#v(10pt)
#box-note("Buổi sau — GK4", accent)[
  Mạng hàng đợi (2): $N$, $T$ của mạng, xác suất trạng thái, trễ theo đường, KIA, trễ đầu cuối.
]
