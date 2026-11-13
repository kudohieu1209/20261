// Sơ đồ tổng quan kiến thức giữa kỳ ET4070 — đen trắng, A4 ngang, để photo.
// Biên dịch: typst compile --root .. SoDo_TongQuan_GiuaKy.typ
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#set document(title: "Sơ đồ tổng quan kiến thức giữa kỳ — ET4070")
#set page(paper: "a4", flipped: true, margin: (x: 1cm, top: 0.9cm, bottom: 0.8cm),
  footer: context align(right, text(8pt)[Sơ đồ tổng quan giữa kỳ ET4070 · trang #counter(page).display() / 2]))
#set text(font: ("Palatino Linotype", "Libertinus Serif"), size: 8.6pt, lang: "vi", fill: black)
#show math.equation: set text(font: "New Computer Modern Math")
#set par(leading: 0.55em, spacing: 0.5em)

// ---- Mindmap đặt theo toạ độ tuyệt đối (mm) trong khung 277 × 152
#let W = 277
#let H = 152
#let lw = 66      // độ rộng ô lá
#let lh = 13.4    // chiều cao ô lá
#let hw = 40
#let hh = 15
#let box-at(x, y, w, h, body, ..args) = place(top + left, dx: (x - w / 2) * 1mm, dy: (y - h / 2) * 1mm,
  box(width: w * 1mm, height: h * 1mm, ..args, body))
#let ln(x1, y1, x2, y2) = place(top + left, line(start: (x1 * 1mm, y1 * 1mm), end: (x2 * 1mm, y2 * 1mm), stroke: 0.7pt))
#let leaf(x, y, body) = box-at(x, y, lw, lh, align(left + horizon, body), inset: 3pt, stroke: 0.5pt, radius: 2pt, fill: white)
#let head(x, y, num, title, sub) = box-at(x, y, hw, hh,
  align(center + horizon, text(white)[#text(10.5pt, weight: "bold")[#num #title] \ #text(7.8pt)[#sub]]),
  fill: black, stroke: black, radius: 4pt, inset: 3pt)

// nhánh: cx = tâm cột lá, hx = tâm ô đầu nhánh, side = -1 (trái) / +1 (phải), y0 = y lá đầu tiên, items = 5 nội dung
#let nhanh(cx, hx, side, y0, num, title, sub, items) = {
  let hy = y0 + 2 * 15
  for (i, it) in items.enumerate() {
    let y = y0 + 15 * i
    // đường nối từ mép ô đầu nhánh tới mép ô lá
    ln(hx + side * hw / 2, hy, cx - side * lw / 2, y)
  }
  head(hx, hy, num, title, sub)
  for (i, it) in items.enumerate() { leaf(cx, y0 + 15 * i, it) }
}

#let mindmap = block(width: W * 1mm, height: H * 1mm, {
  // đường nối trung tâm → 4 đầu nhánh (vẽ trước để nằm dưới)
  ln(138.5, 76, 96, 37.5); ln(138.5, 76, 96, 114.5); ln(138.5, 76, 181, 37.5); ln(138.5, 76, 181, 114.5)

  nhanh(33, 96, -1, 7.5, "①", "Xác suất & Poisson", "chương 2", (
    [*7 phân bố*: Bernoulli, nhị thức, đều, chuẩn, mũ, Poisson, Gamma — tra khi hỏi $E$, "Var"],
    [*Poisson đếm:* $P(k) = (lambda t)^k e^(-lambda t) \/ k!$ — _đúng k, ít nhất 1, không quá k_],
    [*Thời gian giữa 2 lần đến: phân bố mũ.* $P(T>t) = e^(-lambda t)$; "$x$ phút/chuyến" → $lambda = 1\/x$],
    [*Không nhớ:* đã chờ $s$ rồi, chờ thêm $t$ vẫn là $e^(-lambda t)$],
    [*Ghép:* $lambda = sum lambda_i$ #h(0.6em) *Tách:* $lambda dot p_i$ (vẫn Poisson)],
  ))
  nhanh(33, 96, -1, 84.5, "②", "Hệ thống phục vụ", "chương 3 — nền", (
    [*Kendall* $A\/B\/c\/k$: đến / phục vụ / số server / sức chứa. Chỗ chờ $Q$ → $k = Q + c$],
    [*Đổi đề:* $mu = 1\/t_"pv" = C\/L$ (byte → bit, ×8); $lambda$, $mu$ cùng đơn vị],
    [*Tải* $rho = lambda\/(c mu)$; *ổn định* $rho < 1$ (không thì ghi "không ổn định")],
    [*Little:* $N = lambda T$, $N_q = lambda T_q$; có mất gói: $lambda_"thực" = lambda(1 - P_B)$],
    [*Sinh–tử:* tốc độ ra = tốc độ vào mỗi trạng thái → $p_n$ → $sum p_n = 1$],
  ))
  nhanh(244, 181, 1, 7.5, "③", "Hàng đợi đơn", "chương 3 — chính", (
    [*M/M/1:* $p_0 = 1-rho$, $N = rho\/(1-rho)$, $T = 1\/(mu-lambda)$; $P(T<=t) = 1 - e^(-(mu-lambda)t)$],
    [*M/M/1/k:* $p_0 = (1-rho)\/(1-rho^(k+1))$; mất gói $P_B = p_k$; $T = N\/[lambda(1-P_B)]$],
    [*M/M/c* (Erlang C): xác suất *phải chờ* $C(c,a)$; $T = 1\/mu + C\/(c mu - lambda)$],
    [*M/M/c/c* (Erlang B): xác suất *tắc nghẽn* $B(c,a)$; tải $a = lambda\/mu$ (Erlang)],
    [*M/M/∞:* $p_n$ Poisson$(a)$, $N=a$ · *M/G/1, M/D/1:* Pollaczek–Khinchine],
  ))
  nhanh(244, 181, 1, 84.5, "④", "Mạng hàng đợi", "chương 3 — mạng", (
    [*Lưu lượng:* $lambda_i = gamma_i + sum_j r_(j i) lambda_j$ (nhánh không ghi = phần còn lại)],
    [*Ổn định / tìm x:* $rho_i = lambda_i\/mu_i < 1$ mọi nút; "$D_1 = D_2$" → giải $x$],
    [*Jackson:* $p(n_1,dots) = product (1-rho_i)rho_i^(n_i)$; $P("rỗng") = product (1-rho_i)$],
    [$N = sum N_i$; $T = N\/gamma$ ($gamma$ = luồng *từ ngoài vào*); trễ theo đường $= sum T_i$],
    [*KIA* nhiều luồng; *LAN gửi lại:* $lambda' = lambda\/(1-p_e)$, trễ $= (sum T_i)\/(1-p_e)$],
  ))

  // trung tâm (vẽ sau để đè lên đường nối)
  box-at(138.5, 76, 36, 26, align(center + horizon)[
    #text(11pt, weight: "bold")[MÔ HÌNH HOÁ \ & HÀNG ĐỢI] \ #text(7.8pt)[mọi bài quy về: \ *tìm λ, μ → ρ → công thức*]],
    fill: white, stroke: 2pt, radius: 7pt, inset: 3pt)
})

#align(center)[#text(15pt, weight: "bold")[ĐỀ THI GIỮA KỲ ET4070 — BẢN ĐỒ KIẾN THỨC]
  #h(1em) #text(9pt)[Tự luận · 60 phút · được dùng tài liệu giấy · thi đến hết phần hàng đợi]]
#v(2pt)
#align(center, mindmap)

#v(2pt)
#block(width: 100%, stroke: 1.2pt, inset: 5pt, radius: 4pt)[
  #text(10pt, weight: "bold")[⑤ QUY TRÌNH GIẢI MỘT BÀI] #h(0.8em)
  *Đọc đề* → *chọn mô hình* (trang 2) → *đổi* $lambda$, $mu$ *về cùng đơn vị* → *kiểm tra* $rho < 1$ → *áp công thức* → *kiểm tra bằng Little* → *ghi đơn vị, kết luận 1 câu*
  #h(1em) #text(8pt)[Bẫy: "5 phút/chuyến" ≠ $lambda=5$ · byte→bit · $T$ (hệ thống) ≠ $T_q$ (hàng đợi) · $Q$ chỗ chờ → $k=Q+c$]
]

// ================= TRANG 2: CHỌN MÔ HÌNH =================
#pagebreak()
#align(center)[#text(15pt, weight: "bold")[CHỌN MÔ HÌNH — NHÌN ĐỀ BIẾT DÙNG KHUÔN NÀO]]
#v(2pt)

#let cell(body) = align(left + horizon, body)
#table(
  columns: (22mm, 1fr, 1fr, 1fr),
  stroke: 0.7pt, inset: 6pt, align: left + horizon,
  table.header([], [*Chỗ chờ vô hạn* \ ("đủ chỗ", "không giới hạn")], [*Có k chỗ* \ ("tối đa k", "chỗ cho Q người")], [*Không có chỗ chờ* \ (gọi nghẽn = từ chối)]),
  [*1 server*],
    [*M/M/1* \ $p_0 = 1-rho$ \ $N = rho\/(1-rho)$, $T = 1\/(mu-lambda)$ \ _quầy tính tiền, 1 router_],
    [*M/M/1/k*, $k = Q + 1$ \ $p_0 = (1-rho)\/(1-rho^(k+1))$ \ $P_B = p_k$, $T = N\/[lambda(1-P_B)]$ \ _bãi gửi xe, bộ đệm giới hạn_],
    [*M/M/1/1* \ $P_B = p_1 = lambda\/(lambda+mu)$ \ $N = p_1$, $T = 1\/mu$ \ _máy ATM 1 máy, không chờ_],
  [*c server* \ ($c >= 2$)],
    [*M/M/c* — Erlang C \ $a = lambda\/mu$, $rho = a\/c$ \ $C(c,a) = (a^c\/(c!(1-rho))) p_0$ \ $T = 1\/mu + C\/(c mu - lambda)$ \ _call center, CPU nhiều nhân_],
    [*M/M/c/k*, $k = Q + c$ \ lập đồ hình sinh–tử: \ tử $= min(n,c)mu$ \ $P_B = p_k$ \ _CPU có bộ đệm giới hạn_],
    [*M/M/c/c* — Erlang B \ $B(c,a) = (a^c\/c!) \/ sum_(i=0)^c a^i\/i!$ \ _tổng đài, trung kế_],
  [*∞ server*],
    [*M/M/∞* \ $p_n = a^n e^(-a)\/n!$ \ $N = a$, $T = 1\/mu$],
    [—],
    [—],
)

#v(5pt)
#grid(columns: (1fr, 1fr), column-gutter: 8pt,
  block(width: 100%, stroke: 0.7pt, inset: 6pt, radius: 3pt)[
    #text(10pt, weight: "bold")[Thời gian phục vụ *không* phải mũ]
    - *M/D/1* (cố định): $N = rho(2-rho)\/(2(1-rho))$, $T = (2-rho)\/(2 mu (1-rho))$.
    - *M/G/1* (bất kỳ): Pollaczek–Khinchine — dùng khi đề cho $E[S]$ và phương sai.
    - Hỏi "xác suất trạng thái" thì phải dùng đồ hình sinh–tử.
  ],
  block(width: 100%, stroke: 0.7pt, inset: 6pt, radius: 3pt)[
    #text(10pt, weight: "bold")[Đề *không* cho công thức → tự lập sinh–tử]
    - Vẽ trạng thái $0, 1, dots, k$; mũi tên phải $lambda$, mũi tên trái $mu$ (hay $n mu$ với $n <= c$).
    - Viết cân bằng: _ra = vào_ cho mỗi trạng thái → $p_n$ theo $p_0$ → $sum p_n = 1$.
    - Từ $p_n$: $N = sum n p_n$, $P_B = p_k$, $T = N\/lambda_"thực"$.
  ],
)

#v(5pt)
#block(width: 100%, stroke: 1.2pt, inset: 6pt, radius: 4pt)[
  #text(10pt, weight: "bold")[Đề có *nhiều nút nối nhau* → MẠNG HÀNG ĐỢI]
  #v(2pt)
  #align(center, diagram(
    spacing: (12mm, 6mm), node-inset: 3pt, node-stroke: 0.7pt, edge-stroke: 0.8pt,
    node((0, 0), width: 31mm, corner-radius: 3pt, align(center)[① *Lập* \ $lambda_i = gamma_i + sum r_(j i)lambda_j$]),
    edge("->"),
    node((1, 0), width: 31mm, corner-radius: 3pt, align(center)[② *Mỗi nút* \ $rho_i = lambda_i\/mu_i < 1$]),
    edge("->"),
    node((2, 0), width: 31mm, corner-radius: 3pt, align(center)[③ *Mỗi nút M/M/1* \ $N_i = rho_i\/(1-rho_i)$, $T_i = 1\/(mu_i - lambda_i)$]),
    edge("->"),
    node((3, 0), width: 31mm, corner-radius: 3pt, align(center)[④ *Cả mạng* \ $N = sum N_i$ \ $T = N\/gamma$]),
    edge("->"),
    node((4, 0), width: 31mm, corner-radius: 3pt, align(center)[⑤ *Hỏi theo đề* \ $P("rỗng")$, trễ theo đường, tìm $x$, KIA]),
  ))
  #v(2pt)
  #text(8.3pt)[Nút nào ở cổng ra của router: $mu = C\/L$ (liên kết ÷ độ dài gói). Nút có nhiều server → dùng M/M/c cho nút đó. Nút có mất gói → $lambda_"thực" = lambda(1-P_B)$.]
]
