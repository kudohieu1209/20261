// Biên dịch: typst compile CK3_ARQ_DieuKhienLuong.typ
#import "@preview/cetz:0.3.4"

#let accent = rgb("#1f5fa8")
#let warn = rgb("#b5452b")
#let soft = rgb("#eef3fa")
#let ackc = rgb("#2e7d4f")

#set document(title: "CK3 — Điều khiển luồng và ARQ")
#set page(
  paper: "a4",
  margin: (x: 1.8cm, top: 2cm, bottom: 1.8cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(9pt, fill: gray)
      CSTSL · CK3 — ARQ và cửa sổ #h(1fr) #counter(page).display()
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

#let tieude(body) = block(width: 100%, fill: accent, inset: (x: 10pt, y: 8pt), radius: 4pt,
  above: 16pt, sticky: true, text(white, size: 15pt, weight: "bold", body))

#let hinh(path, w) = align(center, image(path, width: w))

// ================= CÔNG CỤ VẼ GIẢN ĐỒ THỜI GIAN (cetz) =================
// Trục x: vị trí trạm (cm). Thời gian t đi xuống: y = -t·ys.

// Trục các trạm
#let td-truc(names, xs, tmax, ys: 0.4) = {
  import cetz.draw: *
  for (i, n) in names.enumerate() {
    let x = xs.at(i)
    line((x, 0.15), (x, -tmax * ys), stroke: 1pt, mark: (end: ">", fill: black, scale: 0.7))
    content((x, 0.2), anchor: "south", text(9.5pt, weight: "bold", n))
  }
  content((xs.at(0) - 0.12, -tmax * ys + 0.1), anchor: "east", text(9pt, fill: luma(90))[$t$])
}

// Khung: dải xiên từ xa (bắt đầu phát tại t0, dài tf) tới xb (trễ tp)
#let td-khung(t0, so, xa: 0, xb: 3, tf: 1, tp: 2, ys: 0.4, lost: false, col: accent,
  nhan: none, nhan-col: black, gap: 0.07, so-f: 0.14) = {
  import cetz.draw: *
  let y(t) = -t * ys
  let a1 = t0 + gap
  let a2 = t0 + tf - gap
  let s = if xb > xa { 1 } else { -1 }
  if lost {
    let f = 0.5
    let xm = xa + (xb - xa) * f
    line((xa, y(a1)), (xm, y(a1 + tp * f)), (xm, y(a2 + tp * f)), (xa, y(a2)), close: true,
      fill: warn.lighten(85%), stroke: (paint: warn, thickness: 0.6pt, dash: "dashed"))
    content((xm + s * 0.17, y(t0 + tf / 2 + tp * f)), text(warn, 14pt, weight: "bold")[×])
  } else {
    line((xa, y(a1)), (xb, y(a1 + tp)), (xb, y(a2 + tp)), (xa, y(a2)), close: true,
      fill: col.lighten(78%), stroke: 0.6pt + col)
  }
  if so != none {
    content((xa + (xb - xa) * so-f, y(t0 + tf / 2 + tp * so-f)),
      text(7.5pt, weight: "bold", fill: if lost { warn } else { col.darken(25%) }, so))
  }
  if nhan != none {
    content((xb + s * 0.1, y(t0 + tf + tp)), anchor: if s > 0 { "west" } else { "east" },
      text(7.5pt, fill: nhan-col, nhan))
  }
}

// ACK / NAK: mũi tên mảnh từ xa (phát tại t) tới xb (trễ tp)
#let td-ack(t, lbl, xa: 3, xb: 0, tp: 2, ys: 0.4, lost: false, col: ackc, lbl-f: 0.5) = {
  import cetz.draw: *
  let y(t) = -t * ys
  let ang = if xa > xb { calc.atan2(xa - xb, tp * ys) } else { calc.atan2(xb - xa, -tp * ys) }
  if lost {
    let f = 0.5
    let pm = (xa + (xb - xa) * f, y(t + tp * f))
    line((xa, y(t)), pm, stroke: (paint: warn, thickness: 0.7pt, dash: "dashed"))
    content(pm, text(warn, 13pt, weight: "bold")[×])
  } else {
    line((xa, y(t)), (xb, y(t + tp)), stroke: 0.7pt + col, mark: (end: ">", fill: col, scale: 0.6))
  }
  let pl = (xa + (xb - xa) * lbl-f, y(t + tp * lbl-f))
  content(pl, angle: ang, anchor: "south", padding: 0.04,
    box(fill: white.transparentize(15%), inset: 0.5pt, radius: 1pt,
      text(7pt, fill: if lost { warn } else { col.darken(20%) }, weight: "bold", lbl)))
}

// Ngoặc time-out trên trục phát (bên trái)
#let td-timeout(t1, t2, x: -0.45, ys: 0.4, lbl: [time-out]) = {
  import cetz.draw: *
  let y(t) = -t * ys
  line((x + 0.12, y(t1)), (x, y(t1)), (x, y(t2)), (x + 0.12, y(t2)), stroke: 0.7pt + warn)
  content((x - 0.04, y((t1 + t2) / 2)), angle: 90deg, anchor: "south", text(7.5pt, fill: warn, lbl))
}

// Ghi chú cạnh một trục
#let td-note(t, body, x: 0, side: "left", ys: 0.4, col: luma(60)) = {
  import cetz.draw: *
  let dx = if side == "left" { -0.1 } else { 0.1 }
  content((x + dx, -t * ys), anchor: if side == "left" { "east" } else { "west" },
    text(7pt, fill: col, body))
}

#let chu-thich(body) = align(center, text(9.5pt, body))

// ================= TRANG BÌA =================
#align(center)[
  #v(0.2cm)
  #text(10pt, fill: gray)[Cơ sở truyền số liệu · ET4070 · ôn cuối kỳ (slide thầy Thanh + đề cũ; sẽ cập nhật theo slide thầy Dũng)]
  #v(2pt)
  #text(22pt, weight: "bold", fill: accent)[CK3 — Điều khiển luồng và ARQ]
  #v(-4pt)
  #text(11pt, fill: gray)[Stop-and-Wait, Go-Back-N, Selective Repeat, cửa sổ, giản đồ thời gian]
]
#v(4pt)

#box-note("Cách học buổi này", accent)[
  #set text(10.5pt)
  #set par(spacing: 0.8em)
  + Đọc mục 1–3 (trang này và trang sau) và mục 4 (giản đồ thời gian).
  + Đọc 4 bài mẫu — lập $T_Sigma$ trước khi nhìn lời giải.
  + Làm 6 bài ở phần *Bài tự luyện* ngay vào ô chấm — *chưa nhìn đáp án*.
  + Dò *Đáp án* ở trang cuối; chép trang *Sổ tay phòng thi — trang 8*.

  *Điểm trong đề:* 2–3,5 điểm. Câu dễ mất điểm vì đề hay đổi sơ đồ (ACK đi đường khác, nhiều chặng, có trạm chuyển tiếp).

  *Qua buổi khi:* lập đúng $T_Sigma$ cho mọi sơ đồ trong bài mẫu mà không nhìn lời giải; vẽ được giản đồ 3 cơ chế.

  #text(9.5pt, fill: gray)[Nguồn: slide thầy Thanh CSTSL7–CSTSL9; đề cuối kỳ 20202, 20211, 20212, 20221Q, 20231Q, 20232; đề 2014, 2015. (Chưa có slide chương này của thầy Dũng — sẽ cập nhật.)]
]

== 1. Bốn đại lượng gốc (luôn tính trước)

#{
  set text(12pt)
  table(
    columns: (1.5fr, 2.4fr, 1.6fr),
    align: left + horizon,
    inset: 6pt,
    [Đại lượng], [Công thức], [Bẫy],
    [Thời gian phát khung], [$display(bold(T_F = L / R))$], [$L$ phải tính bằng *bit* (byte × 8)],
    [Trễ lan truyền], [$display(bold(T_D = d / v))$, #h(0.3em) $v = c\/n = 3 dot 10^8 \/ n$ \ (hoặc đề cho $v$)], [$d$ bằng mét],
    [Tỉ số], [$display(a = T_D / T_F)$], [],
    [Xác suất khung lỗi], [$p = 1 - (1 - "BER")^L$], [$L$ bằng bit],
  )
}

== 2. Chu kỳ $T_Sigma$ — bước quan trọng nhất

$T_Sigma$ = thời gian từ lúc bắt đầu phát một khung đến lúc *nhận xong ACK* của nó (khi đó mới phát khung kế tiếp theo Stop-and-Wait).

#khuon[
  - Trường hợp chuẩn (ACK nhỏ, bỏ qua xử lý): #h(0.4em) *$T_Sigma = T_F + 2 T_D$*.
  - Tổng quát: \
    *$T_Sigma$ = (phát khung trên từng chặng chiều đi) + (lan truyền chiều đi) + (trễ chuyển tiếp/xử lý ở trạm trung gian) + (phát ACK trên từng chặng chiều về) + (lan truyền chiều về)*.
  - Store-and-forward: mỗi chặng phải phát lại toàn bộ khung → cộng $L\/C_i$ cho *mỗi* chặng.
  - ACK đi đường khác (qua trạm R, B…): cộng thời gian phát ACK trên từng chặng của đường về theo *dung lượng chặng đó* + lan truyền + trễ chuyển tiếp.

  *Mẹo:* vẽ giản đồ thời gian (cột S, R, D…) trước rồi đọc $T_Sigma$ trên trục thời gian của nguồn.
]

// ================= MỤC 3 =================
#pagebreak()
== 3. Hiệu suất và tốc độ

#{
  set text(13.5pt)
  table(
    columns: (1.55fr, 1.45fr, 2fr),
    align: left + horizon,
    inset: (x: 8pt, y: 11pt),
    [Cơ chế], [Không lỗi], [Có lỗi xác suất $p$ (ACK không lỗi)],
    [Stop-and-Wait], [$display(eta = T_F / T_Sigma = 1 / (1 + 2a))$], [$display(eta = (1 - p) / (1 + 2a))$],
    [Go-Back-N, \ $W >= 1 + 2a$], [$eta = 1$], [$display(eta = (1 - p) / (1 + 2 a p))$],
    [Go-Back-N, \ $W < 1 + 2a$], [$display(eta = (W T_F) / T_Sigma = W / (1 + 2a))$], [$display(eta = (W(1 - p)) / ((1 + 2a)(1 - p + W p)))$],
    [Selective Repeat, \ $W >= 1 + 2a$], [$eta = 1$], [$eta = 1 - p$],
    [Selective Repeat, \ $W < 1 + 2a$], [$display(eta = W / (1 + 2a))$], [$display(eta = (W(1 - p)) / (1 + 2a))$],
  )
}

#text(fill: warn)[(Khi $T_Sigma != T_F + 2 T_D$ thì thay $1 + 2a$ bằng $T_Sigma \/ T_F$.)]

#khuon[
  #set text(12pt)
  #set par(spacing: 1em)
  - *Cửa sổ nhỏ nhất để hiệu suất 100% / tốc độ lớn nhất:* #h(0.3em) #box[$W dot T_F >= T_Sigma$ → *$W >= T_Sigma \/ T_F$*], làm tròn lên.
  - *Tốc độ truyền tin (thông lượng):* \
    $R_"tt" = eta dot R = L \/ ("thời gian trung bình để truyền thành công một khung")$.
  - *Stop-and-Wait có mất gói và timeout* (không có NAK): mỗi lần mất tốn thêm một khoảng $T_"out"$; số lần mất trung bình $= p \/ (1 - p)$ → thời gian cho 1 khung thành công
    $ bold(T_Sigma + p / (1 - p) dot T_"out") $
    → tốc độ = $L$ / thời gian đó.
  - *Nhiều chặng có xác suất mất khác nhau:* xác suất khung tới đích #box[$= product (1 - p_"chặng đi")$]\; xác suất ACK về #box[$= product (1 - p_"chặng về")$]\; xác suất một khung được xác nhận = tích hai số đó.
]

// ================= MỤC 4 =================
= 4. Giản đồ thời gian — cách vẽ để ăn điểm

#text(fill: gray)[1,5 điểm ở đề 20202, 20232.]

#khuon[
  *Quy ước:* mỗi trạm một trục thẳng đứng (thời gian đi xuống). Khung = dải xiên từ trục phát sang trục thu, độ dày bằng $T_F$; ACK = mũi tên xiên mảnh chiều ngược lại; khung mất = mũi tên dừng giữa đường có dấu #text(warn)[*×*]\; ghi tên khung (số thứ tự SN) và ACK (RN = số khung tiếp theo muốn nhận).
]

- *Stop-and-Wait:* phát khung 0 → đợi ACK1 → phát khung 1 … Khung mất: không có ACK → hết *time-out* (vẽ đoạn ngoặc ghi "time-out" trên trục nguồn) → phát lại cùng khung. ACK mất: bên thu đã nhận đúng nhưng bên phát hết time-out phát lại → bên thu nhận trùng, bỏ đi và gửi lại ACK.
- *Go-Back-N (cửa sổ $W$):* phát liên tục $W$ khung. Khung $i$ lỗi/mất → bên thu *huỷ (cancel) mọi khung sau $i$*, gửi NAK $i$ (hoặc không gửi gì → time-out) → bên phát *phát lại từ khung $i$ trở đi*. ACK $i+n$ đến trước time-out của khung $i$ thì coi như khung $i$ đã nhận đúng (ACK tích luỹ).
- *Selective Repeat (cửa sổ $W$):* chỉ khung lỗi/mất được phát lại; bên thu *lưu đệm* các khung đến sau, khi khung bị thiếu tới thì giao lên theo đúng thứ tự.
- Đề có trạm trung gian R: vẽ 3 trục S, R, D; tại R vẽ thêm đoạn trễ chuyển tiếp trước khi R phát tiếp; nếu ARQ trên từng liên kết thì mỗi liên kết có ACK riêng.

#v(2pt)
#block(breakable: false)[
#text(fill: accent, weight: "bold")[Giản đồ mẫu] #text(9.5pt, fill: gray)[(vẽ với $T_D = 2 T_F$; dải xanh = khung, mũi tên xanh lá = ACK/NAK)]

#grid(columns: (1fr, 1.25fr), column-gutter: 8pt, align: top,
[
  #align(center, cetz.canvas(length: 1cm, {
    import cetz.draw: *
    let ys = 0.4
    let k = td-khung.with(ys: ys, xb: 3.8)
    let a = td-ack.with(ys: ys, xa: 3.8)
    td-truc(("TX", "RX"), (0, 3.8), 21, ys: ys)
    k(0, [0], nhan: [nhận 0])
    a(3, [ACK1])
    k(5, [1], lost: true)
    td-timeout(6, 12, ys: ys)
    k(12, [1], nhan: [nhận 1])
    td-note(12.5, [phát lại 1], ys: ys, col: warn)
    a(15, [ACK2])
    k(17, [2])
  }))
  #chu-thich[*(a) Stop-and-Wait:* khung 1 mất → \ hết time-out → phát lại khung 1]
],
[
  #align(center, cetz.canvas(length: 1cm, {
    import cetz.draw: *
    let ys = 0.45
    let k = td-khung.with(ys: ys, xb: 3.8)
    let a = td-ack.with(ys: ys, xa: 3.8)
    td-truc(("TX", "RX"), (0, 3.8), 15, ys: ys)
    k(0, [1], nhan: [đúng 1])
    k(1, [2], lost: true)
    k(2, [3], nhan: text(warn)[huỷ 3 (sai thứ tự)])
    a(3, [ACK2])
    a(5, [NAK2], col: warn)
    k(5, [4], nhan: text(warn)[huỷ 4])
    td-note(5.5, [ACK2 → phát 4], ys: ys)
    td-note(7.5, text(warn)[NAK2 → lùi về 2], ys: ys)
    k(7, [2], nhan: [đúng 2])
    k(8, [3], nhan: [đúng 3])
    k(9, [4], nhan: [đúng 4])
    a(10, [ACK3], lbl-f: 0.3)
    a(11, [ACK4], lbl-f: 0.3)
    a(12, [ACK5], lbl-f: 0.3)
  }))
  #chu-thich[*(b) Go-Back-N, $W = 3$:* khung 2 mất → khung 3 \ (và 4 đã phát) bị huỷ → phát lại từ 2: *2, 3, 4*]
],
)
]

#block(breakable: false)[
#grid(columns: (1.25fr, 1fr), column-gutter: 8pt, align: horizon,
[
  #align(center, cetz.canvas(length: 1cm, {
    import cetz.draw: *
    let ys = 0.45
    let k = td-khung.with(ys: ys, xb: 3.8)
    let a = td-ack.with(ys: ys, xa: 3.8)
    td-truc(("TX", "RX"), (0, 3.8), 16, ys: ys)
    k(0, [1], nhan: [đúng 1])
    k(1, [2], lost: true)
    k(2, [3], nhan: text(accent)[lưu đệm 3])
    a(3, [ACK2])
    a(5, [NAK2], col: warn)
    k(5, [4], nhan: text(accent)[lưu đệm 4])
    td-note(5.5, [ACK2 → phát 4], ys: ys)
    td-note(7.5, text(warn)[NAK2 → chỉ phát lại 2], ys: ys)
    k(7, [2], nhan: [đúng 2 → giao 2, 3, 4])
    a(10, [ACK5])
    td-note(12.5, [ACK5 → phát 5], ys: ys)
    k(12, [5], nhan: [đúng 5])
  }))
  #chu-thich[*(c) Selective Repeat, $W = 3$:* khung 2 mất → khung 3 \ (và 4) được lưu đệm → *chỉ phát lại khung 2*]
],
[
  #box-note("So sánh nhanh", accent)[
    #set text(10pt)
    - *S&W:* 1 khung một lần; mất → chờ hết time-out rồi phát lại khung đó.
    - *GBN:* bên thu chỉ nhận đúng thứ tự → *huỷ* mọi khung sau khung mất; bên phát *lùi về* khung mất và phát lại *tất cả* từ đó.
    - *SR:* bên thu *lưu đệm* khung đến sau; bên phát *chỉ* phát lại khung mất; khi khung thiếu tới thì giao cả chuỗi và gửi ACK tích luỹ (RN = khung kế tiếp cần).
    - Nhãn ACK luôn là *RN* = số khung tiếp theo muốn nhận (nhận đúng 1 → ACK2).
  ]
],
)
]

// ================= BÀI MẪU =================
#tieude[Bài mẫu]

#mau("1 — slide thầy Thanh (Stop-and-Wait cơ bản)")[
  $d = 100$ m; #h(0.3em) $v = 2 dot 10^8$ m/s; #h(0.3em) $R = 10$ Mbps; #h(0.3em) $L = 500$ bit.
  - $T_F = 500 \/ 10^7 = 50 thin mu"s"$; #h(0.4em) $T_D = 100 \/ (2 dot 10^8) = 0","5 thin mu"s"$; #h(0.4em) $a = 0","01$.
  - $eta = 1 \/ (1 + 2 dot 0","01) approx bold(98%)$.
]

#block(breakable: false)[
#mau("2 — đề cuối kỳ 20232, câu 3 (ACK đi vòng qua R)")[
  #grid(columns: (1fr, 6.2cm), column-gutter: 10pt, align: horizon,
  [
    *Đề:* S gửi tới D bằng Stop-and-Wait, khung 512 byte, ACK 128 byte. Khung đi thẳng S → D (trễ lan truyền $d$ ms, 10 Mbps). ACK đi D → R (3 ms, 5 Mbps) rồi R → S (2 ms, 10 Mbps); R gây trễ chuyển tiếp 1 ms.
  ],
  image("img/ck3_m2_SRD_de20232.png", width: 100%),
  )
  + Vẽ biểu đồ truyền tin; tìm $d$ để tốc độ truyền tin đạt 500 kbps khi không lỗi.
  + Xác suất mất khung $p = 0","2$; $d = 3$ ms; ACK không lỗi; time-out 30 ms. Tính tốc độ truyền tin.

  *Lời giải:*
  - $T_F$ khung $= 512 dot 8 \/ 10^7 = bold(0","4096 "ms")$.
  - ACK trên D → R (5 Mbps): $128 dot 8 \/ (5 dot 10^6) = bold(0","2048 "ms")$; #h(0.3em) trên R → S (10 Mbps): $bold(0","1024 "ms")$.
  - $T_Sigma = 0","4096 + d + 0","2048 + 3 + 1 + 0","1024 + 2 = bold(d + 6","7168 "ms")$.
  - (1) Giản đồ: 3 trục S, R, D; khung xiên S → D (độ dày 0,4096 ms, lan truyền $d$); tại D phát ACK sang R (0,2048 ms + 3 ms); tại R chờ 1 ms rồi phát ACK sang S (0,1024 ms + 2 ms); S nhận xong ACK mới phát khung tiếp.

  #align(center, cetz.canvas(length: 1cm, {
    import cetz.draw: *
    let ys = 0.6
    let y(t) = -t * ys
    let (xs, xr, xd) = (0, 2.8, 5.6)
    let d = 3
    let t1 = 0.4096
    let t2 = t1 + d            // D nhận xong khung, bắt đầu phát ACK
    let t3 = t2 + 0.2048 + 3   // R nhận xong ACK
    let t4 = t3 + 1            // R bắt đầu phát ACK sang S
    let t5 = t4 + 0.1024 + 2   // S nhận xong ACK = T_Sigma
    td-truc(("S", "R", "D"), (xs, xr, xd), t5 + 1.5, ys: ys)
    // khung S -> D
    td-khung(0, none, xa: xs, xb: xd, tf: t1, tp: d, ys: ys, gap: 0)
    content((xs + (xd - xs) * 0.5, y(t1 / 2 + d * 0.5) + 0.14), anchor: "south", angle: calc.atan2(xd - xs, -d * ys),
      text(7.5pt, fill: accent.darken(25%), weight: "bold")[khung 512 B, 10 Mbps])
    // ACK D -> R
    td-khung(t2, none, xa: xd, xb: xr, tf: 0.2048, tp: 3, ys: ys, gap: 0, col: ackc)
    content((xr + (xd - xr) * 0.5, y(t2 + 1.5)), anchor: "south", angle: calc.atan2(xd - xr, 3 * ys), padding: 0.06,
      text(7.5pt, fill: ackc.darken(20%), weight: "bold")[ACK, 5 Mbps])
    // chờ tại R
    line((xr - 0.12, y(t3)), (xr - 0.12, y(t4)), stroke: 2.2pt + warn)
    content((xr - 0.2, y((t3 + t4) / 2)), anchor: "east", text(7.5pt, fill: warn)[chờ 1 ms])
    // ACK R -> S
    td-khung(t4, none, xa: xr, xb: xs, tf: 0.1024, tp: 2, ys: ys, gap: 0, col: ackc)
    content((xs + (xr - xs) * 0.5, y(t4 + 1)), anchor: "south", angle: calc.atan2(xr - xs, 2 * ys), padding: 0.06,
      text(7.5pt, fill: ackc.darken(20%), weight: "bold")[ACK, 10 Mbps])
    // khung kế tiếp
    td-khung(t5, none, xa: xs, xb: xs + (xd - xs) * 0.3, tf: t1, tp: d * 0.3, ys: ys, gap: 0)
    content((xs + 2.0, y(t5 + 0.95)), anchor: "west", text(7.5pt, fill: accent)[khung kế tiếp])
    // các mốc + ngoặc bên phải
    let xb = xd + 0.55
    let moc = ((0, xs), (t1, xs), (t2, xd), (t3, xr), (t4, xr), (t5, xs))
    for (t, x) in moc {
      line((x, y(t)), (xb, y(t)), stroke: (paint: luma(150), thickness: 0.4pt, dash: "dotted"))
    }
    let ngoac(ta, tb, lbl) = {
      line((xb, y(ta)), (xb + 0.12, y(ta)), (xb + 0.12, y(tb)), (xb, y(tb)), stroke: 0.7pt)
      content((xb + 0.22, y((ta + tb) / 2)), anchor: "west", text(8pt, lbl))
    }
    ngoac(0, t1, [*0,4096 ms* (phát khung)])
    ngoac(t1, t2, [*$d$* (lan truyền S → D)])
    ngoac(t2, t3, [*0,2048 + 3 ms* (ACK D → R)])
    ngoac(t3, t4, [*1 ms* (chờ tại R)])
    ngoac(t4, t5, [*0,1024 + 2 ms* (ACK R → S)])
    // T_Sigma bên trái S
    let xl = xs - 0.45
    line((xl + 0.12, y(0)), (xl, y(0)), (xl, y(t5)), (xl + 0.12, y(t5)), stroke: 0.8pt + accent)
    content((xl - 0.05, y(t5 / 2)), angle: 90deg, anchor: "south",
      text(8.5pt, fill: accent, weight: "bold")[$T_Sigma = d + 6","7168$ ms])
  }))
  #align(center, text(9pt, fill: gray)[(giản đồ vẽ với $d = 3$ ms; khung đi thẳng S → D, không qua R)])

  - Tốc độ 500 kbps: $T_Sigma = 4096 "bit" \/ 500 "kbps" = 8","192 "ms"$ → $d = 8","192 - 6","7168 = bold(1","4752 "ms")$.
  - (2) $d = 3$ → $T_Sigma = 9","7168$ ms. Mỗi khung thành công cần trung bình $p \/ (1 - p) = 0","25$ lần mất, mỗi lần mất tốn 30 ms time-out. \
    Thời gian/khung $= 9","7168 + 0","25 dot 30 = 17","2168$ ms → tốc độ $= 4096 \/ 17","2168 "ms" approx bold(237","9 "kbps")$.
]
#bay[
  Tài liệu tổng hợp tính phát ACK trên D → R theo 10 Mbps (đúng là 5 Mbps) nên ra $d = 1","5776$ ms, và ghi đơn vị kết quả là "bps" (đúng là kbps). Nếu thầy hiểu time-out tính từ lúc phát xong khung thì mỗi lần mất tốn $30 + 0","4096$ ms → $approx 236","5$ kbps — ghi rõ giả thiết khi làm.
]
]

#block(breakable: false)[
#mau("3 — đề cuối kỳ 20212, câu 3 (Selective Repeat, ACK qua B)")[
  #grid(columns: (1fr, 6.4cm), column-gutter: 10pt, align: horizon,
  [
    *Đề:* S → R → D, khung 512 byte; ACK 256 byte đi D → B → S. Lan truyền (S,R) 5 ms, (R,D) 7 ms, (D,B) 4 ms, (B,S) 2 ms; mọi liên kết 5 Mbps.
  ],
  image("img/ck3_m3_SRDB_de20212.png", width: 100%),
  )
  + Kích thước cửa sổ nhỏ nhất để tốc độ đạt lớn nhất (không lỗi).
  + Xác suất mất gói (S,R) 20%, (R,D) 10%, (D,B) 0%, (B,S) 15%; $W = 5$; time-out 50 ms. Tính độ sử dụng đường truyền.

  *Lời giải:*
  - $T_F$ khung $= 4096 \/ (5 dot 10^6) = bold(0","8192 "ms")$; #h(0.3em) $T_F$ ACK $= 2048 \/ (5 dot 10^6) = bold(0","4096 "ms")$.
  - Store-and-forward: khung phát 2 lần (S→R, R→D), ACK phát 2 lần (D→B, B→S): \
    $T_Sigma = 2 dot 0","8192 + 5 + 7 + 2 dot 0","4096 + 4 + 2 = bold(20","4576 "ms")$.
  - (1) $W >= T_Sigma \/ T_F = 20","4576 \/ 0","8192 approx 24","97$ → *$W_min = 25$*.
  - (2) Xác suất khung tới D: $0","8 dot 0","9 = 0","72$; ACK về S: $1 dot 0","85 = 0","85$; một khung được xác nhận: $p_s = 0","612$. \
    $W dot T_F = 4","096$ ms $< T_Sigma$ → cửa sổ giới hạn. Mô hình đơn giản: mỗi chu kỳ $T_Sigma$ phát $W$ khung, trung bình $p_s$ phần thành công:
    $ eta approx (W dot T_F dot p_s) / T_Sigma = (5 dot 0","8192 dot 0","612) / (20","4576) approx bold(12","3%) $
]
#bay[
  Tài liệu tổng hợp chỉ cộng thời gian phát khung và ACK một lần (bỏ qua việc R và B phát lại) nên ra $T_Sigma = 19","23$ ms, $W = 24$, $eta = 13","0%$. Cách cộng theo từng chặng ở trên khớp công thức trễ đầu cuối $sum (L\/C_i + t_(p i))$ trong slide.
]
]

#block(breakable: false)[
#mau("4 — đề 2015 đề 2, câu 2 (vệ tinh địa tĩnh, Go-Back-N)")[
  *Đề:* liên kết qua vệ tinh địa tĩnh, khoảng cách 36 000 km, tốc độ 1 Mbps, khung 1500 byte.
  - $T_F = 12 thin 000 \/ 10^6 = bold(12 "ms")$; #h(0.4em) $T_D = 36 dot 10^6 \/ (3 dot 10^8) = bold(120 "ms")$; #h(0.4em) $a = 10$.
  - (2.1) Cửa sổ để hiệu suất 100% khi không lỗi: $W >= 1 + 2a = bold(21)$.
  - (2.2) BER $= 10^(-9)$: $p = 1 - (1 - 10^(-9))^(12000) approx 1","2 dot 10^(-5)$. Với $W >= 21$: $eta = (1 - p) \/ (1 + 2 a p) approx bold(99","97%)$ (gần như 100%).
]
#bay[
  Lời giải viết tay trong "Ôn tập đề thi CSTSL.pdf" lấy $T_F = 1500 \/ 10^6$ (quên nhân 8) nên ra $W >= 161$ — sai.
]
]

// ================= SỔ TAY =================
= Sổ tay phòng thi — trang 8

#set text(13pt)
#set par(leading: 0.8em)
#box-note("BỐN ĐẠI LƯỢNG GỐC", accent)[
  $T_F = L\/R$ ($L$ bằng *BIT*) #h(1.5em) $T_D = d\/v$, #h(0.3em) $v = 3 dot 10^8 \/ n$ #h(1.5em) $a = T_D \/ T_F$ \
  $p = 1 - (1 - "BER")^L$
]
#box-note("CHU KỲ TΣ", accent)[
  $T_Sigma$ = phát khung từng chặng đi + lan truyền đi + trễ chuyển tiếp \
  #h(2.2em) + phát ACK từng chặng về + lan truyền về \
  chuẩn: $T_Sigma = T_F + 2 T_D$
]
#box-note("HIỆU SUẤT", accent)[
  #grid(columns: (auto, auto, auto), column-gutter: 1em, row-gutter: 0.7em,
    [*S&W:*], grid.cell(colspan: 2)[$eta = T_F \/ T_Sigma = 1\/(1 + 2a)$; #h(0.5em) có lỗi $times (1 - p)$],
    [*GBN:*], [$W >= 1 + 2a$:], [$(1 - p)\/(1 + 2 a p)$;],
    [], [$W < 1 + 2a$:], [$W(1 - p)\/[(1 + 2a)(1 - p + W p)]$],
    [*SR:*], [$W >= 1 + 2a$:], [$1 - p$;],
    [], [$W < 1 + 2a$:], [$W(1 - p)\/(1 + 2a)$],
  )
]
#box-note("CỬA SỔ · TỐC ĐỘ · MẤT GÓI", accent)[
  $W_min (100%) = ceil(T_Sigma \/ T_F)$; \
  tốc độ $= eta dot R = L \/ ("thời gian TB cho 1 khung thành công")$ \
  Mất gói + time-out: thời gian/khung $= T_Sigma + [p\/(1 - p)] dot T_"out"$ \
  Nhiều chặng: $p_s = product (1 - p_"đi") dot product (1 - p_"về")$
]
#box-note("GIẢN ĐỒ", accent)[
  S&W phát lại sau time-out \
  GBN phát lại từ khung lỗi trở đi \
  SR chỉ phát lại khung lỗi
]
#box-note("Lỗi hay mắc", warn)[
  - $L$ bằng byte mà không nhân 8.
  - Tính phát ACK theo dung lượng của chặng khác.
  - Chỉ cộng thời gian phát một lần cho đường nhiều chặng (store-and-forward phải cộng mỗi chặng).
  - Quên trễ chuyển tiếp ở trạm trung gian.
  - Nhầm "tốc độ truyền tin" (kbps) với "hiệu suất" (%).
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

#bai(1)[Cáp quang dài 2000 km, chiết suất 1,5, tốc độ 1 Mbps, khung 1000 bit. Tính $a$, hiệu suất Stop-and-Wait, và cửa sổ nhỏ nhất để hiệu suất 100%.]
#bai(2)[Cùng liên kết bài 1, xác suất khung lỗi $p = 0","1$. Tính hiệu suất của Stop-and-Wait; Go-Back-N với $W = 7$; Selective Repeat với $W = 7$; và hai cơ chế cửa sổ khi $W >= 21$.]
#bai(3, h: 5.5cm)[BER $= 10^(-4)$, khung 1000 bit, $a = 0","5$. Tính xác suất khung lỗi và hiệu suất Stop-and-Wait.]
#bai(4, h: 5.5cm)[Stop-and-Wait có $T_Sigma = 10$ ms, khung 4000 bit, xác suất mất khung 0,3, time-out 20 ms. Tính tốc độ truyền tin.]
#bai(5, h: 10cm)[Vẽ giản đồ Go-Back-N với $W = 4$ khi khung 3 bị mất (khung 1–6 cần gửi).]
#bai(6, h: 10cm)[Vẽ giản đồ Selective Repeat với $W = 4$ khi khung 2 bị lỗi và báo nhận của khung 4 (ACK5) bị mất.]

// ================= ĐÁP ÁN =================
= Đáp án

#table(
  columns: (auto, 1fr),
  [Bài], [Đáp án],
  [1], [$v = 2 dot 10^8$ m/s; $T_D = 10$ ms; $T_F = 1$ ms; *$a = 10$*; $eta = 1\/21 approx bold(4","76%)$; *$W >= 21$*.],
  [2], [Stop-and-Wait: $0","9 \/ 21 approx bold(4","29%)$. GBN $W = 7$: $7 dot 0","9 \/ (21 dot (0","9 + 0","7)) = bold(18","75%)$. SR $W = 7$: $7 dot 0","9 \/ 21 = bold(30%)$. \ Khi $W >= 21$: GBN $= 0","9 \/ (1 + 2) = bold(30%)$; SR $= bold(90%)$.],
  [3], [$p = 1 - 0","9999^(1000) approx bold(0","0952)$; #h(0.4em) $eta = 0","9048 \/ 2 approx bold(45","2%)$.],
  [4], [$10 + (0","3 \/ 0","7) dot 20 approx 18","57$ ms/khung → $4000 \/ 18","57 "ms" approx bold(215","4 "kbps")$.],
  [5], [Phát 1, 2, 3, 4; khung 3 mất → bên thu nhận 4 thấy sai thứ tự, huỷ 4, gửi NAK3 (hoặc bên phát chờ time-out của 3); bên phát nhận ACK2, ACK3 cho khung 1, 2 → trượt cửa sổ phát 5, 6 (bị huỷ) → khi nhận NAK3/time-out phát lại *3, 4, 5, 6*.],
  [6], [Phát 1–4; khung 2 lỗi → bên thu lưu 3, 4, gửi NAK2; báo nhận của khung 4 (ACK5) bị mất; bên phát chỉ phát lại *khung 2*; khi khung 2 tới, bên thu gửi ACK tích luỹ ACK5 (RN = 5) → bên phát biết 3, 4 đã tới, không cần phát lại 4 (chỉ khi không nhận được ACK5 nào trước time-out của khung 4 mới phát lại 4).],
)

#v(4pt)
#block(breakable: false)[
#grid(columns: (1fr, 1fr), column-gutter: 10pt, align: top,
[
  #align(center, cetz.canvas(length: 1cm, {
    import cetz.draw: *
    let ys = 0.42
    let k = td-khung.with(ys: ys, xb: 3.2)
    let a = td-ack.with(ys: ys, xa: 3.2)
    td-truc(("TX", "RX"), (0, 3.2), 15, ys: ys)
    k(0, [1], nhan: [đúng 1])
    k(1, [2], nhan: [đúng 2])
    k(2, [3], lost: true)
    k(3, [4], nhan: text(warn)[huỷ 4])
    a(3, [ACK2], lbl-f: 0.7)
    a(4, [ACK3], lbl-f: 0.7)
    a(6, [NAK3], col: warn, lbl-f: 0.7)
    k(5, [5], nhan: text(warn)[huỷ 5])
    k(6, [6], nhan: text(warn)[huỷ 6])
    td-note(8.5, text(warn)[NAK3 → lùi về 3], ys: ys)
    k(8, [3], nhan: [đúng 3])
    k(9, [4], nhan: [đúng 4])
    k(10, [5], nhan: [đúng 5])
    k(11, [6], nhan: [đúng 6])
  }))
  #chu-thich[*Bài 5* — GBN, $W = 4$: phát lại 3, 4, 5, 6]
],
[
  #align(center, cetz.canvas(length: 1cm, {
    import cetz.draw: *
    let ys = 0.42
    let k = td-khung.with(ys: ys, xb: 3.2)
    let a = td-ack.with(ys: ys, xa: 3.2)
    td-truc(("TX", "RX"), (0, 3.2), 15, ys: ys)
    k(0, [1], nhan: [đúng 1])
    k(1, [2], col: warn, nhan: text(warn)[2 lỗi])
    k(2, [3], nhan: text(accent)[lưu 3])
    k(3, [4], nhan: text(accent)[lưu 4])
    a(3, [ACK2], lbl-f: 0.7)
    a(4, [NAK2], col: warn, lbl-f: 0.7)
    a(6, [ACK5], lost: true, lbl-f: 0.25)
    td-note(6.5, text(warn)[NAK2 → chỉ phát lại 2], ys: ys)
    k(6, [2], nhan: [đúng 2 → giao 2, 3, 4])
    a(9, [ACK5 (RN = 5)])
    td-note(11.5, [biết 3, 4 đã tới], ys: ys)
  }))
  #chu-thich[*Bài 6* — SR, $W = 4$: chỉ phát lại khung 2]
],
)
]
