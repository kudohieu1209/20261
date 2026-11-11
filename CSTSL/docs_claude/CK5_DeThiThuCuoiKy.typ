// Biên dịch: typst compile CK5_DeThiThuCuoiKy.typ
// Nội dung: src/CK5_DeThiThuCuoiKy.md. Hình cắt từ đề gốc CK_20221Q.pdf, CK_20231Q.pdf (img/ck5_*.png);
// cây SPT trong lời giải vẽ bằng gói fletcher.
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#let accent = rgb("#1f5fa8")
#let warn = rgb("#b5452b")
#let soft = rgb("#eef3fa")
#let ok = rgb("#2e7d4f")

#set document(title: "CK5 — Hai đề thi thử cuối kỳ")
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

// Ô trống có lưới chấm để viết tay trên tablet
#let o-viet(h) = block(
  width: 100%, height: h, radius: 3pt, stroke: 0.5pt + luma(200),
  fill: tiling(size: (0.5cm, 0.5cm), place(dx: 0.25cm, dy: 0.25cm, circle(radius: 0.6pt, fill: luma(185)))),
)

// ================= HÀM RIÊNG CHO ĐỀ THI =================
#let cau(title, body) = block(
  width: 100%, breakable: false, stroke: 1pt + accent, radius: 4pt, inset: (x: 11pt, y: 10pt),
  fill: soft.lighten(40%),
  {
    show heading: it => block(below: 7pt, text(accent, size: 12.5pt, weight: "bold", it.body))
    set enum(numbering: "a)", indent: 0pt, body-indent: 0.5em, spacing: 0.7em)
    heading(level: 2, title)
    body
  },
)
#let lam-bai = {
  v(2pt)
  o-viet(1fr)
}
#let tiep(label) = {
  pagebreak()
  text(9.5pt, fill: gray)[#label — làm tiếp]
  v(-6pt)
  o-viet(1fr)
}
#let de-info = block(width: 100%, inset: (x: 2pt, y: 2pt), below: 10pt)[
  #set text(10pt)
  Thời gian làm bài: *90 phút* · Được dùng tài liệu #h(1fr)
  Bắt đầu: #box(width: 2cm, repeat[.]) #h(0.6em) Kết thúc: #box(width: 2cm, repeat[.])
]
#let d(s) = [#h(1fr)#box(inset: (x: 5pt, y: 2pt), radius: 3pt, fill: ok.lighten(85%),
  text(9.5pt, weight: "bold", fill: ok.darken(10%), s))]
// Hình gốc của đề
#let hinh(path, w, nguon) = align(center, block(spacing: 8pt)[
  #block(fill: white, inset: 4pt, radius: 3pt, image(path, width: w))
])

#let trang(lbl) = context counter(page).at(locate(lbl)).first()

// ---- vẽ cây SPT (cùng kiểu CK1) ----
#let C = rgb("#1f3f6e")
#let nd(pos, ten, nm, d: none) = node(pos,
  if d == none { text(C, weight: "bold", ten) } else {
    stack(spacing: 2.5pt, text(C, weight: "bold", ten), text(8pt, fill: warn, weight: "bold")[d = #d])
  },
  name: nm, stroke: 1pt + C, fill: rgb("#e6eef8"), corner-radius: 4pt,
  width: 13mm, height: if d == none { 8mm } else { 11mm })
#let w(t) = text(9.5pt, weight: "bold", fill: warn, t)
#let ed(a, b, t, ..args) = edge(a, b, "-|>", w(t), stroke: 1.6pt + C,
  label-side: center, label-fill: white, ..args)
#let do-thi(sp: (16mm, 12mm), ..args) = align(center, block(spacing: 8pt, diagram(
  spacing: sp, mark-scale: 90%, ..args)))

// ================= TRANG BÌA =================
#align(center)[
  #v(1cm)
  #text(22pt, weight: "bold", fill: accent)[CK5 — Hai đề thi thử cuối kỳ]
  #v(2pt)
  #text(11pt, fill: gray)[kèm lời giải]
]
#v(8pt)

Hai đề này cùng khuôn 3 câu (mạng hàng đợi 4đ + phân chia băng thông & ARQ 3đ + định tuyến 3đ) — đúng kiểu đề chương trình ET4070 gần đây. Làm sau khi đã học xong GK1–GK4 và CK1–CK4.

#box-note("Cách làm (90 phút mỗi đề)", accent)[
  + Bấm giờ *90 phút*, được mở tài liệu (dùng sổ tay phòng thi).
  + Làm thẳng vào ô trống dưới mỗi câu.
  + Xong cả hai đề mới lật lời giải; tự chấm.
  + Chép lỗi sai vào sổ tay.

  *Mục tiêu:* ≥ 9/10 mỗi đề, xong trước giờ 10 phút.
]

#box-note("Số liệu theo MSSV/STT: i = 7", warn)[
  Đề 20231Q dùng *i = 7* (hàng đơn vị số thứ tự trong danh sách thi; nếu số thứ tự của bạn khác thì thay i tương ứng).
]

#v(6pt)
#table(
  columns: (1fr, auto),
  align: (left, center),
  [Phần], [Trang],
  [Đề số 1 — Cuối kỳ 2022.1 (ET4070Q) — 3 câu, 10 điểm], [#trang(<de1>)],
  [Đề số 2 — Cuối kỳ 2023.1 (ET4070Q) — 3 câu, 10 điểm], [#trang(<de2>)],
  [Lời giải đề số 1 #text(fill: gray)[(chỉ lật khi đã làm xong cả hai đề)]], [#trang(<lg1>)],
  [Lời giải đề số 2], [#trang(<lg2>)],
  [Bảng tự chấm], [#trang(<cham>)],
)

// =====================================================================
// ================= ĐỀ SỐ 1 — CK 20221Q ===============================
// =====================================================================
= ĐỀ SỐ 1 — Cuối kỳ 2022.1 (ET4070Q) <de1>
#de-info

#cau[Câu 1 (4 điểm)][
  Mạng hàng đợi M/M/1. Tốc độ phục vụ S1, S2, S3: $mu_1 = 20 thin 000$; $mu_2 = 6 thin 250$; $mu_3 = 12 thin 500$ yêu cầu/s. Yêu cầu đến S1 theo Poisson $gamma = 2000$ yêu cầu/s. Ra khỏi S1: 50% → S2, 50% → S3. Ra khỏi S2: quay về S1. Ra khỏi S3: 40% ra ngoài, 60% quay về S1.

  #hinh("img/ck5_de1_cau1_S1_S3.png", 13cm)[Hình gốc: đề CK 20221Q, câu 1]

  + Xác suất để mỗi server có đúng 2 yêu cầu $p(2, 2, 2)$.
  + Số yêu cầu trung bình trong mạng.
  + Thời gian trễ trung bình của 1 yêu cầu khi đi qua hệ thống.
]
#lam-bai
#tiep[Đề 1 · Câu 1]

#pagebreak()
#cau[Câu 2 (3 điểm)][
  Sơ đồ 4 nút A, B, C, D và 4 kết nối 1, 2, 3, 4. A —8 Mbps— B —15 Mbps— C —10 Mbps— D. Kết nối 1: A → D; 2: A → C; 3: A → B; 4: B → D. Trễ truyền dẫn giữa hai nút $T_D = 0","05$ ms; khung $L = 500$ bit; ACK không đáng kể; không lỗi.

  #hinh("img/ck5_de1_cau2_ABCD.png", 13cm)[Hình gốc: đề CK 20221Q, câu 2]

  + Phân chia băng thông cho 4 kết nối theo max-min.
  + Hiệu suất truyền trên liên kết AB nếu dùng Stop-and-Wait.
  + Hiệu suất trên liên kết AB nếu dùng Go-Back-N với $W = 2$. Tìm điều kiện của $W$ để hiệu suất đạt 100%.
]
#lam-bai
#tiep[Đề 1 · Câu 2]

#pagebreak()
#cau[Câu 3 (3 điểm)][
  Đồ thị: A–B 2, A–E 2, B–C 1, B–G 4, B–E 2, C–G 3, C–D 1, G–E 1, G–D 1, E–D 3. Xây dựng cây SPT theo Bellman-Ford, tìm đường ngắn nhất từ G đến các nút còn lại.

  #hinh("img/ck5_de1_cau3_graph.png", 6.5cm)[Hình gốc: đề CK 20221Q, câu 3]
]
#lam-bai
#tiep[Đề 1 · Câu 3]

// =====================================================================
// ================= ĐỀ SỐ 2 — CK 20231Q ===============================
// =====================================================================
= ĐỀ SỐ 2 — Cuối kỳ 2023.1 (ET4070Q) <de2>
#de-info

#cau[Câu 1 (4 điểm)][
  #text(10pt, fill: gray)[(lấy $i = 7$)] \
  Mạng hàng đợi M/M/1. $mu_1 = 100 thin 000$; $mu_2 = 80 thin 000$; $mu_3 = 80 thin 000$; $mu_4 = 100 thin 000$ yêu cầu/s. Yêu cầu đến S1 theo Poisson $gamma = 4000(i + 1)$ yêu cầu/s. S1 → S2 (40%), S3 (60%); S2 → về đầu vào S1 (50%), S4 (50%); S3 → S4; S4 → ra ngoài (80%), về đầu vào S3 (20%).

  #hinh("img/ck5_de2_cau1_S1_S4.png", 13cm)[Hình gốc: đề CK 20231Q, câu 1]

  + Tổng số yêu cầu trung bình của mạng.
  + Thời gian trễ trung bình của 1 yêu cầu khi qua hệ thống.
  + Giả thiết $mu_1 = mu_2 = mu_3 = mu_4 = mu$. Tìm điều kiện của $mu$ để hệ thống ổn định.
  + Với $gamma = 40 thin 000$ yêu cầu/s, tính $p(0, 1, 2, i + 1)$.
]
#lam-bai
#tiep[Đề 2 · Câu 1]

#pagebreak()
#cau[Câu 2 (3 điểm)][
  A —10 Mbps— B —5 Mbps— C —5 Mbps— D. Kết nối 1: A → D; 2: A → B; 3: B → C; 4: A → B. $T_D = 0","24$ ms; $L = 800$ bit; ACK không đáng kể; không lỗi.

  #hinh("img/ck5_de2_cau2_ABCD.png", 12.5cm)[Hình gốc: đề CK 20231Q, câu 2]

  + Phân chia băng thông theo max-min.
  + Hiệu suất trên liên kết CD nếu dùng Stop-and-Wait.
  + Hiệu suất trên liên kết CD nếu dùng Go-Back-N với $W = 3$. Tìm điều kiện của $W$ để hiệu suất đạt 100%.
]
#lam-bai
#tiep[Đề 2 · Câu 2]

#pagebreak()
#cau[Câu 3 (3 điểm)][
  Đồ thị: A–B 1, A–C 1, A–D 4, A–E 3, B–C 5, B–G 6, C–D 3, C–F 2, C–G 1, D–E 2, D–H 2, E–H 7, F–H 4, G–H 3. Xây dựng cây SPT theo Dijkstra từ nguồn A.

  #hinh("img/ck5_de2_cau3_graph.png", 8.5cm)[Hình gốc: đề CK 20231Q, câu 3]
]
#lam-bai
#tiep[Đề 2 · Câu 3]

// =====================================================================
// ================= LỜI GIẢI ĐỀ 1 =====================================
// =====================================================================
#set text(11pt)
#set par(leading: 0.68em, spacing: 0.95em)
#show heading.where(level: 2): it => block(sticky: true, above: 16pt, below: 8pt, width: 100%,
  stroke: (bottom: 0.6pt + accent.lighten(50%)), inset: (bottom: 4pt),
  text(accent, size: 12.5pt, weight: "bold", it.body))
#let y(body) = block(width: 100%, above: 0.9em, below: 0.9em, body)

= Lời giải đề số 1 <lg1>

#block(breakable: false)[
== Câu 1 #h(1fr) #text(10pt, fill: gray)[4 điểm]

#y[Phương trình lưu lượng: $lambda_1 = 2000 + lambda_2 + 0","6 lambda_3$; $lambda_2 = lambda_3 = 0","5 lambda_1$ → $0","2 lambda_1 = 2000$ → $bold(lambda_1 = 10 thin 000)$; $bold(lambda_2 = lambda_3 = 5000)$. \
  Kiểm tra: ra ngoài $0","4 dot 5000 = 2000$ ✔. #d[1đ]]
#y[$rho_1 = 0","5$; $rho_2 = 0","8$; $rho_3 = 0","4$ (ổn định). #d[0,5đ]]
#y[a) #d[1đ]]
$ p(2, 2, 2) &= (1 - 0","5) 0","5^2 times (1 - 0","8) 0","8^2 times (1 - 0","4) 0","4^2 \
  &= 0","125 times 0","128 times 0","096 approx bold(1","536 dot 10^(-3)) $
#y[b) $N = 0","5\/0","5 + 0","8\/0","2 + 0","4\/0","6 = 1 + 4 + 0","667 = bold(5","667)$ *yêu cầu*. #d[0,75đ]]
#y[c) $T = N\/gamma = 5","667\/2000 approx bold(2","83)$ *ms*. #d[0,75đ]]
]

#block(breakable: false)[
== Câu 2 #h(1fr) #text(10pt, fill: gray)[3 điểm]

#y[a) Max-min: #d[1đ]]
- AB: $8\/3$ (1, 2, 3); BC: $15\/3 = 5$ (1, 2, 4); CD: $10\/2 = 5$ (1, 4) → chốt *1 = 2 = 3 = 8/3 ≈ 2,67 Mbps*.
- Còn 4: BC dư $29\/3$, CD dư $22\/3$ → *4 = 22/3 ≈ 7,33 Mbps*.

#y[b) Stop-and-Wait trên AB: $T_F = 500\/(8 dot 10^6) = 62","5$ µs; $T_Sigma = T_F + 2 T_D = 62","5 + 100 = 162","5$ µs → $eta = 62","5\/162","5 approx bold(38","5%)$. #d[1đ]]
#y[c) Go-Back-N $W = 2$: $W dot T_F = 125$ µs $< T_Sigma$ → $eta = 125\/162","5 approx bold(76","9%)$. \
  Đạt 100% khi $W dot T_F >= T_Sigma$ → $W >= 2","6$ → $bold(W >= 3)$. #d[1đ]]
]

#box-note("Lưu ý", warn)[
  Tài liệu tổng hợp ghi kết nối 4 = 29/3 (sai, CD bị vượt dung lượng) và tính hiệu suất AB theo cả tuyến A → D chỉ với một chiều trễ ($T_Sigma = 1775\/6$ µs, $eta = 21","13%$). Đề hỏi "trên liên kết AB" nên dùng $T_Sigma = T_F + 2 T_D$ của riêng liên kết AB như trên.
]

#block(breakable: false)[
== Câu 3 #h(1fr) #text(10pt, fill: gray)[3 điểm]

Bellman-Ford từ G:

#align(center, table(
  columns: (auto,) + (1.6cm,) * 6,
  align: center + horizon, inset: (x: 4pt, y: 6pt),
  fill: (x, y) => if y == 0 { soft },
  [h], [A], [B], [C], [D], [E], [G],
  [*0*], [∞], [∞], [∞], [∞], [∞], [0],
  [*1*], [∞], [4, G], [3, G], [1, G], [1, G], [0],
  [*2*], [3, E], [3, E], [2, D], [1, G], [1, G], [0],
  [*3*], [3, E], [3, E], [2, D], [1, G], [1, G], [0],
))

#grid(columns: (1fr, auto), column-gutter: 12pt, align: horizon,
[
Vòng 3 không đổi → dừng.

Cây SPT: G–D, G–E, D–C, E–A, E–B.

Đường ngắn nhất: G→D (1); G→E (1); G→D→C (2); G→E→A (3); G→E→B (3).
],
[
#do-thi(sp: (13mm, 10mm),
  nd((1, 0), "G", <g>, d: 0),
  nd((0, 1), "D", <d>, d: 1),
  nd((2, 1), "E", <e>, d: 1),
  nd((0, 2), "C", <c>, d: 2),
  nd((1.5, 2), "A", <a>, d: 3),
  nd((2.5, 2), "B", <b>, d: 3),
  ed(<g>, <d>, "1"),
  ed(<g>, <e>, "1"),
  ed(<d>, <c>, "1"),
  ed(<e>, <a>, "2"),
  ed(<e>, <b>, "2"),
)
#align(center, text(8.5pt, fill: gray)[Cây SPT gốc G (d = khoảng cách từ G)])
])
]

// =====================================================================
// ================= LỜI GIẢI ĐỀ 2 =====================================
// =====================================================================
= Lời giải đề số 2 #text(weight: "regular")[($i = 7$ → $gamma = 32 thin 000$)] <lg2>

#block(breakable: false)[
== Câu 1 #h(1fr) #text(10pt, fill: gray)[4 điểm]

#y[Phương trình lưu lượng: #d[1đ]]
- $lambda_1 = gamma + 0","5 lambda_2$, $lambda_2 = 0","4 lambda_1$ → $bold(lambda_1 = 1","25 gamma = 40 thin 000)$; $bold(lambda_2 = 0","5 gamma = 16 thin 000)$.
- $lambda_3 = 0","6 lambda_1 + 0","2 lambda_4$; $lambda_4 = 0","5 lambda_2 + lambda_3$ → $bold(lambda_4 = 1","25 gamma = 40 thin 000)$; $bold(lambda_3 = gamma = 32 thin 000)$.
- Kiểm tra: $0","8 lambda_4 = gamma$ ✔.

#y[a) $rho_1 = 0","4$; $rho_2 = 0","2$; $rho_3 = 0","4$; $rho_4 = 0","4$ → $N = 3 dot (0","4\/0","6) + 0","2\/0","8 = bold(2","25)$ *yêu cầu*. #d[1đ]]
#y[b) $T = 2","25\/32 thin 000 approx bold(70","3)$ *µs*. #d[0,5đ]]
#y[c) Ổn định: $mu > max lambda_i = bold(1","25 gamma)$ ($= 40 thin 000$ yêu cầu/s với $i = 7$). #d[0,75đ]]
#y[d) $gamma = 40 thin 000$: $rho_1 = 0","5$; $rho_2 = 0","25$; $rho_3 = 0","5$; $rho_4 = 0","5$ → #d[0,75đ]]
$ p(0, 1, 2, 8) = 0","5 times (0","75 dot 0","25) times (0","5 dot 0","25) times (0","5 dot 0","5^8) approx bold(2","29 dot 10^(-5)) $
]

#block(breakable: false)[
== Câu 2 #h(1fr) #text(10pt, fill: gray)[3 điểm]

#y[a) Max-min: AB: $10\/3$ (1, 2, 4); BC: $5\/2$ (1, 3); CD: $5\/1$ (1) → BC nhỏ nhất → *1 = 3 = 2,5 Mbps*. \
  AB còn 7,5 cho 2 và 4 → *2 = 4 = 3,75 Mbps*. #d[1đ]]
#y[b) Stop-and-Wait trên CD: $T_F = 800\/(5 dot 10^6) = 160$ µs; $T_Sigma = 160 + 2 dot 240 = 640$ µs → $eta = bold(25%)$. #d[1đ]]
#y[c) Go-Back-N $W = 3$: $3 dot 160\/640 = bold(75%)$; đạt 100% khi $W >= 640\/160$ → $bold(W >= 4)$. #d[1đ]]
]

#block(breakable: false)[
== Câu 3 #h(1fr) #text(10pt, fill: gray)[3 điểm]

Dijkstra từ A:

#align(center, table(
  columns: (auto, auto) + (1.45cm,) * 7,
  align: center + horizon, inset: (x: 4pt, y: 5pt),
  fill: (x, y) => if y == 0 { soft },
  [Bước], [Chốt], [B], [C], [D], [E], [F], [G], [H],
  [0], [*A*], [1, A], [1, A], [4, A], [3, A], [∞], [∞], [∞],
  [1], [*B*], [×], [1, A], [4, A], [3, A], [∞], [7, B], [∞],
  [2], [*C*], [×], [×], [4, A], [3, A], [3, C], [2, C], [∞],
  [3], [*G*], [×], [×], [4, A], [3, A], [3, C], [×], [5, G],
  [4], [*E*], [×], [×], [4, A], [×], [3, C], [×], [5, G],
  [5], [*F*], [×], [×], [4, A], [×], [×], [×], [5, G],
  [6], [*D*], [×], [×], [×], [×], [×], [×], [5, G],
  [7], [*H*], [], [], [], [], [], [], [5, G],
))

#grid(columns: (1fr, auto), column-gutter: 12pt, align: horizon,
[
Cây SPT: A–B, A–C, C–G, A–E, C–F, A–D, G–H.

Chi phí: B 1, C 1, G 2, E 3, F 3, D 4, H 5.
],
[
#do-thi(sp: (11mm, 9mm),
  nd((2, 0), "A", <a>, d: 0),
  nd((0, 1), "B", <b>, d: 1),
  nd((1.5, 1), "C", <c>, d: 1),
  nd((3, 1), "D", <d>, d: 4),
  nd((4, 1), "E", <e>, d: 3),
  nd((1, 2), "G", <g>, d: 2),
  nd((2, 2), "F", <f>, d: 3),
  nd((0, 2), "H", <h>, d: 5),
  ed(<a>, <b>, "1"),
  ed(<a>, <c>, "1"),
  ed(<a>, <d>, "4"),
  ed(<a>, <e>, "3"),
  ed(<c>, <g>, "1"),
  ed(<c>, <f>, "2"),
  ed(<g>, <h>, "3"),
)
#align(center, text(8.5pt, fill: gray)[Cây SPT gốc A (d = khoảng cách từ A)])
])
]

// =====================================================================
// ================= BẢNG TỰ CHẤM ======================================
// =====================================================================
#set text(11.5pt)
= Bảng tự chấm <cham>

#text(fill: gray)[Điền điểm từng câu theo thang điểm trong lời giải; ghi lại thời gian làm thực tế.]

#v(4pt)
#let ocham(s) = align(right + bottom, text(13pt, fill: luma(110), s))
#table(
  columns: (1.2fr, 2fr, 2fr),
  rows: (auto, 1.6cm),
  inset: 9pt,
  align: (left + horizon, right + bottom, right + bottom),
  table.header([], align(center)[Đề 1], align(center)[Đề 2]),
  [Câu 1], ocham[/4], ocham[/4],
  [Câu 2], ocham[/3], ocham[/3],
  [Câu 3], ocham[/3], ocham[/3],
  table.cell(fill: soft)[*Tổng*], table.cell(fill: soft, ocham(strong[/10])), table.cell(fill: soft, ocham(strong[/10])),
  [Thời gian làm], ocham[phút], ocham[phút],
)

#v(6pt)
#text(weight: "bold", fill: warn)[Lỗi sai cần chép vào sổ tay]
#v(-6pt)
#o-viet(1fr)
