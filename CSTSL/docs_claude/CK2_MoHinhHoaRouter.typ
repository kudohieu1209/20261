// Biên dịch: typst compile CK2_MoHinhHoaRouter.typ
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let accent = rgb("#1f5fa8")
#let warn = rgb("#b5452b")
#let soft = rgb("#eef3fa")
#let green = rgb("#2e7d4f")

#set document(title: "CK2 — Đề một bài lớn: mô hình hoá mạng router")
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
#let mau(title, body) = block(breakable: false, width: 100%,
  box-note("Bài mẫu " + title, green, body))

// Ô trống có lưới chấm để viết tay trên tablet
#let o-viet(h) = block(
  width: 100%, height: h, radius: 3pt, stroke: 0.5pt + luma(200),
  fill: tiling(size: (0.5cm, 0.5cm), place(dx: 0.25cm, dy: 0.25cm, circle(radius: 0.6pt, fill: luma(185)))),
)

#let hinh(path, w) = align(center, image(path, width: w))
#let so-do(d) = align(center, block(inset: (y: 4pt), {
  set text(9.5pt)
  d
}))

// Nhãn một ý của bài mẫu 1, kèm điểm
#let yi(n, diem, title) = block(sticky: true, above: 14pt, below: 7pt)[
  #box(fill: green, inset: (x: 6pt, y: 3pt), radius: 3pt, text(white, weight: "bold")[Ý #n])
  #h(4pt) #box(stroke: 0.7pt + green, inset: (x: 5pt, y: 2.5pt), radius: 3pt, text(green, size: 9.5pt, weight: "bold")[#diem])
  #h(4pt) #text(weight: "bold")[#title]
]

// Server hàng đợi có ghi λ, μ
#let sv(p, name, lam-v, mu-v, w: 1.55cm) = node(p, align(center)[
  #text(weight: "bold", size: 10pt, name) \
  #text(8pt)[$lambda$ = #lam-v \ $mu$ = #mu-v]
], shape: rect, stroke: 0.8pt + accent, fill: soft, width: w, inset: 4pt, corner-radius: 2pt)
#let src(p, body) = node(p, body, shape: rect, stroke: 0.6pt + gray, fill: luma(245), inset: 4pt)
#let jn(p) = node(p, none, shape: circle, radius: 1.6pt, fill: black, stroke: none)
// Nút đồ thị định tuyến
#let rn(p, name) = node(p, text(9.5pt, weight: "bold", name), shape: circle, radius: 0.42cm, stroke: 0.8pt, fill: soft)
#let hl = 2.2pt + warn

// ================= TRANG BÌA =================
#align(center)[
  #v(0.2cm)
  #text(22pt, weight: "bold", fill: accent)[CK2 — Đề một bài lớn: mô hình hoá mạng router]
]
#v(6pt)

#box-note("Kiểu đề này (20211, 20241)", accent)[
  Cho *một sơ đồ mạng router thật*, rồi hỏi liên tiếp: mô hình hoá thành mạng hàng đợi, tính $lambda$, $mu$, thời gian tại từng router, trễ từ nguồn tới đích, dựng đồ thị định tuyến với chi phí tự tính rồi chạy Dijkstra, cuối cùng là Stop-and-Wait trên một tuyến.

  + Đọc khuôn mục 1–3 (trang này và trang sau).
  + Đọc 3 bài mẫu — bài mẫu 1 là trọn đề 20211, trình bày theo từng ý.
  + Làm phần *Bài tự luyện* ngay vào ô chấm — *chưa nhìn đáp án*; dò *Đáp án* ở trang cuối.
  + Chép trang *Sổ tay phòng thi — trang 7*.

  *Qua buổi khi:* tự làm lại trọn đề 20211 trong ≤ 50 phút.

]

== 1. Khuôn mô hình hoá

#khuon[
  #set enum(spacing: 0.85em)
  + *Mỗi giao diện đầu ra của router = một hàng đợi M/M/1* (router có hai đường ra thì vẽ hai server bên trong router đó, ví dụ C→D và C→E).
  + *$mu$ của server = dung lượng liên kết ra / độ dài gói*: $mu = C\/L$ (gói/s). Đề cho dung lượng bằng pps thì $mu$ = số đó luôn.
  + *$lambda$ của server = tổng các luồng đi ra cổng đó* (cộng các nguồn đổ vào, nhân xác suất rẽ nhánh). Lập như phương trình lưu lượng (GK3).
  + Vẽ sơ đồ hàng đợi: nguồn → server → server → … → đích, ghi $lambda$, $mu$ cạnh mỗi server, ghi tỉ lệ rẽ nhánh.
  + Thời gian tại router: $T_i = 1\/(mu_i - lambda_i)$.
  + Trễ nguồn → đích: liệt kê các đường, trung bình có trọng số theo xác suất đường (GK4).
]

== 2. Khuôn dựng đồ thị định tuyến với chi phí tự tính

#table(
  columns: (1.3fr, 2fr),
  [Đề nói tiêu chí], [Chi phí trên cạnh (u → v)],
  ["tổng thời gian chờ tại các nút mạng ngắn nhất"], [thời gian tại hàng đợi của cổng ra u→v: $1\/(mu - lambda)$],
  ["thời gian lan truyền" (bỏ qua xử lý)], [$d\/v$, với $v = c\/n$ ($n$ = chiết suất) — tỉ lệ với khoảng cách, nên có thể dùng luôn km],
  [băng thông + khoảng cách / mất gói (chuẩn hoá)], [$W = alpha dot abs(d) + beta dot (1\/abs("BW"))$ với $abs("BW") = "BW"\/"BW"_max$, $abs(d) = d\/d_max$, $alpha + beta = 1$],
  [cạnh từ nguồn (máy tính) vào router đầu tiên], [0 (không có hàng đợi) nếu đề không cho gì],
)

Cạnh chỉ đi theo *chiều luồng dữ liệu* (đồ thị có hướng). Sau khi có đồ thị thì chạy Dijkstra như CK1.

== 3. Stop-and-Wait trên tuyến nhiều chặng (chỉ kiểm soát ở hai đầu)

#khuon[
  - Store-and-forward: tổng thời gian phát $= sum L\/C_i$ (mỗi chặng phát lại gói một lần).
  - Trễ lan truyền một chiều $= sum d_i \/ v$; #h(0.4em) $v = c\/n = 3 dot 10^8 \/ n$.
  - ACK nhỏ, bỏ qua thời gian phát ACK: $ T_Sigma = sum L\/C_i + 2 dot sum d_i \/ v $
  - Hiệu suất tại nguồn: $eta = (L\/C_1) \/ T_Sigma$ (thời gian nguồn bận phát chia cho cả chu kỳ).
]

// ================= BÀI MẪU 1 =================
= Bài mẫu 1 — đề cuối kỳ 20211 (trọn đề)

#hinh("img/ck2_m1_de20211.png", 12.5cm)
#align(center, text(9pt, fill: gray)[Hai máy bên trái ký hiệu là S1 và S2.])

6 router A, B, C, D, E, F và 5 máy S1…S5 gửi về server Dest. S1, S2 → A; A → B; S3, S4 → B; B → C; S5 → C; C → D (60%), C → E (40%); D → Dest; E → F → Dest. $gamma_1 = 100$, $gamma_2 = 50$, $gamma_3 = 80$, $gamma_4 = 70$, $gamma_5 = 50$ pps. $C_(A B) = 200$ kbps, $C_(B C) = 400$ kbps, $C_(C E) = C_(C D) = 250$ kbps, $C_(E F) = 200$ kbps, $C_(D"-Dest") = 250$ kbps, $C_(F"-Dest") = 200$ kbps. $L = 1000$ bit. Không mất gói, bộ đệm đủ lớn.

#yi(1, "2 điểm", "Mô hình hoá")
Các server: A (cổng A→B), B (B→C), CD (C→D), CE (C→E), D (D→Dest), E (E→F), F (F→Dest). Vẽ: S1, S2 → [A] → (+S3, S4) → [B] → (+S5) → tách 0,6 → [CD] → [D] → Dest; 0,4 → [CE] → [E] → [F] → Dest.

#block(breakable: false, so-do(diagram(
  spacing: (0.5cm, 0.4cm), edge-stroke: 0.8pt, mark-scale: 80%,
  src((0,1), [S1 · 100]), src((0,3), [S2 · 50]),
  sv((1,2), [A], [150], [200]),
  src((1,0), [S3 · 80]), src((2,0), [S4 · 70]),
  sv((2,2), [B], [300], [400]),
  src((3,0), [S5 · 50]),
  jn((3,2)),
  sv((4,1), [CD], [210], [250]), sv((5,1), [D], [210], [250]),
  sv((4,3), [CE], [140], [250]), sv((5,3), [E], [140], [200]), sv((6,3), [F], [140], [200]),
  src((7,1), [Dest]),
  edge((0,1),(1,2),"-|>"), edge((0,3),(1,2),"-|>"),
  edge((1,2),(2,2),"-|>"),
  edge((1,0),(2,2),"-|>"), edge((2,0),(2,2),"-|>"),
  edge((2,2),(3,2),"-"),
  edge((3,0),(3,2),"-|>"),
  edge((3,2),(4,1),"-|>", [0,6], label-side: left),
  edge((3,2),(4,3),"-|>", [0,4], label-side: right),
  edge((4,1),(5,1),"-|>"), edge((5,1),(7,1),"-|>"),
  edge((4,3),(5,3),"-|>"), edge((5,3),(6,3),"-|>"),
  edge((6,3),(7,3),(7,1),"-|>"),
)))
#align(center, text(9pt, fill: gray)[Mạng hàng đợi kết quả ý 1; số $lambda$, $mu$ (pps) lấy từ ý 2, 3.])

#yi(2, "1 điểm", [Tốc độ tới $lambda$])
- $lambda_A = 100 + 50 = bold(150)$; #h(0.4em) $lambda_B = 150 + 80 + 70 = bold(300)$.
- $lambda_(C D) = 0","6 dot (300 + 50) = bold(210)$; #h(0.4em) $lambda_(C E) = 0","4 dot 350 = bold(140)$.
- $lambda_D = bold(210)$; #h(0.4em) $lambda_E = lambda_F = bold(140)$ (pps).

#yi(3, "1 điểm", [Tốc độ phục vụ $mu = C\/L$])
$mu_A = bold(200)$; $mu_B = bold(400)$; $mu_(C D) = mu_(C E) = bold(250)$; $mu_D = bold(250)$; $mu_E = bold(200)$; $mu_F = bold(200)$ (pps).

#yi(4, "1 điểm", "Thời gian tại từng server")
#box[$T_A = 1\/50 = bold(20 "ms")$]; #box[$T_B = 1\/100 = bold(10 "ms")$]; #box[$T_(C D) = 1\/40 = bold(25 "ms")$]; #box[$T_(C E) = 1\/110 approx bold(9","09 "ms")$]; #box[$T_D = 1\/40 = bold(25 "ms")$]; #box[$T_E = 1\/60 approx bold(16","67 "ms")$]; #box[$T_F = 1\/60 approx bold(16","67 "ms")$].

#yi(5, "1 điểm", "Trễ S1 → Dest (bỏ trễ lan truyền)")
- Đường 1: A → B → CD → D: $20 + 10 + 25 + 25 = 80$ ms, xác suất 0,6.
- Đường 2: A → B → CE → E → F: $20 + 10 + 9","09 + 16","67 + 16","67 = 72","42$ ms, xác suất 0,4.
- $T = 0","6 dot 80 + 0","4 dot 72","42 approx bold(76","97 "ms")$.

#block(breakable: false)[
#yi(6, "2 điểm", "Dijkstra từ S3, chi phí = thời gian chờ tại nút (ms)")
S3→B 0; B→C 10; C→E 9,09; C→D 25; E→F 16,67; F→Dest 16,67; D→Dest 25.

#so-do(diagram(
  spacing: (1.9cm, 0.9cm), edge-stroke: 0.8pt, mark-scale: 80%,
  rn((0,0), [S3]), rn((1,0), [B]), rn((2,0), [C]),
  rn((3,-1), [E]), rn((4,-1), [F]), rn((3,1), [D]),
  node((5,0), text(9.5pt, weight: "bold")[Dest], shape: rect, stroke: 0.8pt, fill: soft, inset: 6pt),
  edge((0,0),(1,0),"-|>", [0], label-side: left, stroke: hl),
  edge((1,0),(2,0),"-|>", [10], label-side: left, stroke: hl),
  edge((2,0),(3,-1),"-|>", [9,09], label-side: left, stroke: hl),
  edge((3,-1),(4,-1),"-|>", [16,67], label-side: left, stroke: hl),
  edge((4,-1),(5,0),"-|>", [16,67], label-side: left, stroke: hl),
  edge((2,0),(3,1),"-|>", [25], label-side: right),
  edge((3,1),(5,0),"-|>", [25], label-side: right),
))

#table(
  columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  align: center + horizon,
  [Bước], [Chốt], [B], [C], [D], [E], [F], [Dest],
  [0], [S3], [0, S3], [∞], [∞], [∞], [∞], [∞],
  [1], [B], [×], [10, B], [∞], [∞], [∞], [∞],
  [2], [C], [×], [×], [35, C], [19,09, C], [∞], [∞],
  [3], [E], [×], [×], [35, C], [×], [35,76, E], [∞],
  [4], [D], [×], [×], [×], [×], [35,76, E], [60, D],
  [5], [F], [×], [×], [×], [×], [×], [52,42, F],
  [6], [Dest], [], [], [], [], [], [*52,42, F*],
)

Đường định tuyến (tô đậm): *S3 → B → C → E → F → Dest*, tổng $approx bold(52","42 "ms")$ (đi qua D là 60 ms).
]

#block(breakable: false)[
#yi(7, "2 điểm", "Stop-and-Wait S3 → B → C → D → Dest, có trễ lan truyền")
Mỗi chặng 6 km, $n = 1","1$ → $v = 3 dot 10^8 \/ 1","1 approx 2","727 dot 10^8$ m/s.
- Trễ lan truyền một chiều: $24 "km" \/ v = bold(88 mu"s")$.
- Thời gian phát: chặng B→C $1000\/400"k" = 2","5$ ms; C→D 4 ms; D→Dest 4 ms; chặng S3→B: *đề không cho dung lượng*. Tài liệu tổng hợp lấy 80 kbps ($= gamma_3 dot L$) → 12,5 ms. Dùng giả thiết này và *ghi rõ giả thiết* khi làm bài.
- $T_Sigma = 12","5 + 2","5 + 4 + 4 + 2 dot 0","088 = 23","176$ ms.
- $eta = 12","5 \/ 23","176 approx bold(53","9%)$.
]

// ================= BÀI MẪU 2 =================
= Bài mẫu 2 — đề cuối kỳ 20241 (câu 1–4)

#hinh("img/ck2_m2_de20241.png", 15.5cm)

S1 phát $gamma_1 = 1800$ pps: 70% → R1, 30% → R3. R1 → R2 (3000 pps, 30 km); R2 → R4 40% (1000 pps, 75 km), R2 → R5 60% (2000 pps, 150 km); R4 → D (1000 pps, 300 km); R5 → R6 (2000 pps, 30 km); S2 ($gamma_2 = 1000$ pps) → R6; R6 → D (4000 pps, 30 km); R3 → D (1000 pps, 450 km); S1–R1 15 km; S1–R3 10 km. Chiết suất 1,46. Dung lượng các chặng cho sẵn bằng pps nên $mu$ = số đó.

#block(breakable: false)[
== Câu 1 — mô hình hoá ($lambda$, $mu$)
- R1 (cổng R1→R2): $lambda = 0","7 dot 1800 = bold(1260)$, $mu = 3000$.
- R2→R4: $lambda = 0","4 dot 1260 = bold(504)$, $mu = 1000$. #h(0.4em) R2→R5: $lambda = 0","6 dot 1260 = bold(756)$, $mu = 2000$.
- R4 (→D): $lambda = bold(504)$, $mu = 1000$. #h(0.4em) R5 (→R6): $lambda = bold(756)$, $mu = 2000$.
- R6 (→D): $lambda = 756 + 1000 = bold(1756)$, $mu = 4000$. #h(0.4em) R3 (→D): $lambda = 0","3 dot 1800 = bold(540)$, $mu = 1000$.

#so-do(diagram(
  spacing: (0.75cm, 0.4cm), edge-stroke: 0.8pt, mark-scale: 80%,
  src((0,1), [S1 · 1800]),
  jn((1,1)),
  sv((2,1), [R1], [1260], [3000]),
  jn((3,1)),
  sv((4,0), [R2→R4], [504], [1000], w: 1.75cm), sv((5,0), [R4], [504], [1000]),
  sv((4,1), [R2→R5], [756], [2000], w: 1.75cm), sv((5,1), [R5], [756], [2000]),
  sv((6,1), [R6], [1756], [4000]),
  src((6,2), [S2 · 1000]),
  sv((4,3), [R3], [540], [1000]),
  src((7,1), [D]),
  edge((0,1),(1,1),"-"),
  edge((1,1),(2,1),"-|>", [0,7], label-side: left),
  edge((1,1),(1,3),(4,3),"-|>", [0,3], label-side: right, label-pos: 0.3),
  edge((2,1),(3,1),"-"),
  edge((3,1),(3,0),(4,0),"-|>", [0,4], label-side: left, label-pos: 0.3),
  edge((3,1),(4,1),"-|>", [0,6], label-side: left),
  edge((4,0),(5,0),"-|>"), edge((5,0),(7,0),(7,1),"-|>"),
  edge((4,1),(5,1),"-|>"), edge((5,1),(6,1),"-|>"),
  edge((6,2),(6,1),"-|>"),
  edge((6,1),(7,1),"-|>"),
  edge((4,3),(7,3),(7,1),"-|>"),
))
#align(center, text(9pt, fill: gray)[Mạng hàng đợi kết quả câu 1 ($lambda$, $mu$ tính bằng pps).])
]

#bay[Nút đích D (hình ghi $mu_D = 1000$ pps): tổng lưu lượng tới D $= 1800 + 1000 = 2800$ pps $> mu_D$ → nếu đưa D vào thì hàng đợi tại D *không ổn định*. Vì vậy (giống lời giải tham khảo) coi D là đích hấp thụ, không tính vào mạng hàng đợi; khi làm bài nên ghi một dòng nhận xét này.]

== Câu 2 — thời gian tại từng router (s)
$T_1 = 1\/1740$; $T_(R 2 arrow.r R 4) = 1\/496$; $T_(R 2 arrow.r R 5) = 1\/1244$; $T_4 = 1\/496$; $T_5 = 1\/1244$; $T_6 = 1\/2244$; $T_3 = 1\/460$.

#block(breakable: false)[
== Câu 3 — trễ trung bình S1 → D
- p1: R1 → R2→R4 → R4: lưu lượng 504, trễ $1\/1740 + 1\/496 + 1\/496 approx 4","607$ ms.
- p2: R1 → R2→R5 → R5 → R6: lưu lượng 756, trễ $1\/1740 + 1\/1244 + 1\/1244 + 1\/2244 approx 2","628$ ms.
- p3: R3: lưu lượng 540, trễ $1\/460 approx 2","174$ ms.
- $T = (504 dot 4","607 + 756 dot 2","628 + 540 dot 2","174) \/ 1800 approx bold(3","05 "ms")$.

#bay[Lời giải trong tài liệu tổng hợp quên cộng $T_6$ ở đường p2 (đường này có đi qua R6) nên ra ≈ 2,86 ms.]
]

#block(breakable: false)[
== Câu 4 — Dijkstra từ S1, chi phí = thời gian lan truyền
(bỏ xử lý). Vì $v = c\/1","46$ như nhau trên mọi chặng, chi phí tỉ lệ khoảng cách → tính bằng km rồi đổi sang thời gian ở cuối:

#so-do(diagram(
  spacing: (1.75cm, 0.65cm), edge-stroke: 0.8pt, mark-scale: 80%,
  node((0,1), text(9.5pt, weight: "bold")[S1], shape: rect, stroke: 0.8pt, fill: soft, inset: 6pt),
  rn((1,1), [R1]), rn((2,1), [R2]),
  rn((3,0), [R4]), rn((3,2), [R5]), rn((4,2), [R6]),
  rn((1.5,3), [R3]),
  node((5,1), text(9.5pt, weight: "bold")[D], shape: rect, stroke: 0.8pt, fill: soft, inset: 6pt),
  edge((0,1),(1,1),"-|>", [15], label-side: left, stroke: hl),
  edge((1,1),(2,1),"-|>", [30], label-side: left, stroke: hl),
  edge((2,1),(3,0),"-|>", [75], label-side: left),
  edge((2,1),(3,2),"-|>", [150], label-side: right, stroke: hl),
  edge((3,0),(5,1),"-|>", [300], label-side: left),
  edge((3,2),(4,2),"-|>", [30], label-side: right, stroke: hl),
  edge((4,2),(5,1),"-|>", [30], label-side: right, stroke: hl),
  edge((0,1),(0,3),(1.5,3),"-|>", [10], label-side: right, label-pos: 0.7),
  edge((1.5,3),(5,3),(5,1),"-|>", [450], label-side: right, label-pos: 0.3),
))

#table(
  columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  align: center + horizon, inset: 4.5pt,
  [Bước], [Chốt], [R1], [R2], [R3], [R4], [R5], [R6], [D],
  [0], [S1], [15, S1], [∞], [10, S1], [∞], [∞], [∞], [∞],
  [1], [R3], [15, S1], [∞], [×], [∞], [∞], [∞], [460, R3],
  [2], [R1], [×], [45, R1], [×], [∞], [∞], [∞], [460, R3],
  [3], [R2], [×], [×], [×], [120, R2], [195, R2], [∞], [460, R3],
  [4], [R4], [×], [×], [×], [×], [195, R2], [∞], [420, R4],
  [5], [R5], [×], [×], [×], [×], [×], [225, R5], [420, R4],
  [6], [R6], [×], [×], [×], [×], [×], [×], [255, R6],
  [7], [D], [], [], [], [], [], [], [*255, R6*],
)

Đường chọn: *S1 → R1 → R2 → R5 → R6 → D*, 255 km → $255 dot 10^3 \/ (3 dot 10^8 \/ 1","46) approx bold(1","241 "ms")$.
]

#bay[Tài liệu tổng hợp dùng thời gian chờ $1\/(mu - lambda)$ làm chi phí — sai tiêu chí đề ("thời gian lan truyền").]

// ================= BÀI MẪU 3 =================
= Bài mẫu 3 — chi phí chuẩn hoá (đề 26/12/2015, câu 3)

Đồ thị A, B, C, D, E, F. Hai tiêu chí: băng thông và quãng đường, vai trò như nhau.
- Chuẩn hoá: $abs("BW") = "BW"\/"BW"_max$; $abs(d) = d\/d_max$.
- Hàm giá: *$W = alpha dot abs(d) + beta dot (1\/abs("BW"))$*, $alpha + beta = 1$; vai trò như nhau → $alpha = beta = 0","5$. (Băng thông càng lớn càng tốt → dùng nghịch đảo; quãng đường càng nhỏ càng tốt → dùng trực tiếp.)
- Với trọng số cho sẵn ở ý 3.2: $mu$(AB) = 0,45; $mu$(AD) = 0,43; $mu$(AE) = 2,16; $mu$(BE) = 1,92; $mu$(BC) = 1,4; $mu$(ED) = 2,3; $mu$(EC) = 1,31; $mu$(DF) = 10,6; $mu$(CF) = 1,35. Bellman-Ford từ A:

#let g3(tree: none, sp: (1.55cm, 1.05cm)) = {
  let all = (
    ("A","B",0.45), ("A","D",0.43), ("A","E",2.16), ("B","E",1.92), ("B","C",1.4),
    ("E","D",2.3), ("E","C",1.31), ("D","F",10.6), ("C","F",1.35),
  )
  let pos = (A: (0,1), B: (1.2,0), E: (1.2,1), D: (1.2,2), C: (2.6,0.5), F: (3.6,1.5))
  let lbl = (
    "AB": [0,45], "AD": [0,43], "AE": [2,16], "BE": [1,92], "BC": [1,4],
    "ED": [2,3], "EC": [1,31], "DF": [10,6], "CF": [1,35],
  )
  let side = (
    "AB": left, "AD": right, "AE": left, "BE": left, "BC": left,
    "ED": left, "EC": right, "DF": right, "CF": right,
  )
  diagram(
    spacing: sp, edge-stroke: 0.8pt,
    ..pos.pairs().map(((k, p)) => rn(p, k)),
    ..all.map(((u, v, w)) => {
      let key = u + v
      let on = tree != none and key in tree
      let off = tree != none and not on
      edge(pos.at(u), pos.at(v), "-", lbl.at(key), label-side: side.at(key),
        label-size: 9pt,
        stroke: if on { hl } else if off { 0.5pt + luma(190) } else { 0.8pt },
        label-fill: white)
    }),
  )
}

#grid(columns: (auto, 1fr), column-gutter: 14pt, align: center + horizon,
  [#so-do(g3(sp: (1.2cm, 0.95cm))) #text(9pt, fill: gray)[Đồ thị với trọng số ý 3.2]],
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon, inset: 4pt,
    [h], [B], [C], [D], [E], [F],
    [1], [0,45, A], [∞], [0,43, A], [2,16, A], [∞],
    [2], [0,45, A], [1,85, B], [0,43, A], [2,16, A], [11,03, D],
    [3], [0,45, A], [1,85, B], [0,43, A], [2,16, A], [3,2, C],
    [4], table.cell(colspan: 5)[không đổi],
  ),
)

Cây: A–B, A–D, A–E, B–C, C–F.
- Ý 3.3: liên kết BC đứt → chạy lại: C = 3,47 (qua E), F = 4,82 (qua C). Cây mới: A–B, A–D, A–E, E–C, C–F.

#grid(columns: (1fr, 1fr), column-gutter: 10pt, align: center,
  [#so-do(g3(tree: ("AB", "AD", "AE", "BC", "CF"))) #text(9pt, fill: gray)[Cây kết quả (ý 3.2): A–B, A–D, A–E, B–C, C–F]],
  [#so-do(g3(tree: ("AB", "AD", "AE", "EC", "CF"))) #text(9pt, fill: gray)[Cây mới khi BC đứt (ý 3.3): A–B, A–D, A–E, E–C, C–F]],
)

// ================= SỔ TAY =================
= Sổ tay phòng thi — trang 7

#set text(13pt)
#set par(leading: 0.9em)
#box-note("MÔ HÌNH HOÁ", accent)[
  mỗi cổng ra router = 1 M/M/1; #h(1em) $mu = C\/L$ (bit/s ÷ bit = gói/s) \
  $lambda$ cổng = tổng luồng đi ra cổng đó (cộng nguồn, nhân tỉ lệ rẽ) \
  $T_i = 1\/(mu_i - lambda_i)$; #h(1em) trễ S→D = Σ (lưu lượng đường × trễ đường) / Σ lưu lượng
]
#box-note("CHI PHÍ ĐỊNH TUYẾN", accent)[
  thời gian chờ → $1\/(mu - lambda)$ của cổng ra; #h(1em) lan truyền → $d\/v$ (dùng km) \
  chuẩn hoá: $W = alpha dot abs(d) + beta \/ abs("BW")$, $alpha + beta = 1$; #h(1em) cạnh nguồn→router đầu: 0
]
#box-note("STOP & WAIT nhiều chặng", accent)[
  $T_Sigma = sum L\/C_i + 2 dot sum d_i \/ v$; #h(1em) $v = 3 dot 10^8 \/ n$; #h(1em) $eta = (L\/C_1) \/ T_Sigma$
]
#box-note("Thiếu dữ liệu", warn)[
  GHI RÕ GIẢ THIẾT rồi mới tính
]
#set text(11.5pt)
#set par(leading: 0.75em)
#v(6pt)
#text(9.5pt, fill: gray)[Ghi thêm:]
#o-viet(12.5cm)

// ================= BÀI TẬP =================
= Bài tự luyện — viết thẳng vào ô chấm

#text(fill: gray)[Làm hết rồi mới lật trang đáp án.]

#let bai(n, body, h: 7cm) = block(breakable: false, width: 100%)[
  *Bài #n.* #body
  #v(-2pt)
  #o-viet(h)
  #v(4pt)
]

*Bài 1.* Làm lại trọn đề 20211 (ý 1–6) mà không nhìn bài mẫu, bấm giờ 40 phút.
#v(-2pt)
#o-viet(21.3cm)
#pagebreak()
#text(9.5pt, fill: gray)[Bài 1 (tiếp)]
#v(-4pt)
#o-viet(24.4cm)
#pagebreak()

#bai(2, h: 7cm)[Đề 20211: nếu $C_(B C)$ giảm còn 320 kbps thì $T_B$ và trễ S1 → Dest bằng bao nhiêu? Đường định tuyến từ S3 có đổi không?]
#bai(3, h: 6cm)[Đề 20241: tính trễ trung bình từ S2 tới D.]
#bai(4, h: 8cm)[Đề 20241: nếu tiêu chí định tuyến là tổng thời gian chờ tại các router (cạnh u→v có chi phí $1\/(mu - lambda)$ của cổng u→v), đường từ S1 tới D là gì?]

// ================= ĐÁP ÁN =================
= Đáp án

#table(
  columns: (auto, 1fr),
  [Bài], [Đáp án],
  [1], [Xem bài mẫu 1 (ý 1–6).],
  [2], [$mu_B = 320$ → $T_B = 1\/(320 - 300) = bold(50 "ms")$. \
    Đường 1: $20 + 50 + 25 + 25 = 120$ ms; đường 2: $20 + 50 + 9","09 + 16","67 + 16","67 = 112","42$ ms; \
    $T = 0","6 dot 120 + 0","4 dot 112","42 approx bold(116","97 "ms")$. \
    Định tuyến từ S3: cả hai đường đều thêm 40 ms ở B nên *không đổi* (S3→B→C→E→F→Dest).],
  [3], [S2 chỉ đi qua R6: $T = 1\/2244$ s $approx bold(0","446 "ms")$.],
  [4], [Chi phí (ms): S1→R1 0, S1→R3 0, R1→R2 $1\/1740 approx 0","575$; R2→R4 $1\/496 approx 2","016$; R2→R5 $1\/1244 approx 0","804$; R4→D 2,016; R5→R6 0,804; R6→D $1\/2244 approx 0","446$; R3→D $1\/460 approx 2","174$. \
    Ba đường: qua R4 $approx 0","575 + 2","016 + 2","016 = 4","607$ ms; qua R5, R6 $approx 0","575 + 0","804 + 0","804 + 0","446 = 2","628$ ms; qua R3 $= bold(2","174 "ms")$ → nhỏ nhất, chọn *S1 → R3 → D*.],
)
