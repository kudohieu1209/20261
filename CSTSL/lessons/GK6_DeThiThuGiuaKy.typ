// Biên dịch: typst compile GK6_DeThiThuGiuaKy.typ
#let accent = rgb("#1f5fa8")
#let warn = rgb("#b5452b")
#let soft = rgb("#eef3fa")
#let ok = rgb("#2e7d4f")

#set document(title: "GK6 — Ba đề thi thử giữa kỳ")
#set page(
  paper: "a4",
  margin: (x: 1.8cm, top: 2cm, bottom: 1.8cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(9pt, fill: gray)
      CSTSL · GK6 — Đề thi thử giữa kỳ #h(1fr) #counter(page).display()
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
#let mau(title, body) = box-note("Bài mẫu — " + title, rgb("#2e7d4f"), body)

// Ô trống có lưới chấm để viết tay trên tablet
#let o-viet(h) = block(
  width: 100%, height: h, radius: 3pt, stroke: 0.5pt + luma(200),
  fill: tiling(size: (0.5cm, 0.5cm), place(dx: 0.25cm, dy: 0.25cm, circle(radius: 0.6pt, fill: luma(185)))),
)

#let bai(n, body, h: 4.2cm) = block(breakable: false, width: 100%)[
  *Bài #n.* #body
  #v(-2pt)
  #o-viet(h)
  #v(4pt)
]

// ================= HÀM RIÊNG CHO ĐỀ THI =================
// Khung đề bài một câu (hộp viền) — tiêu đề là heading cấp 2 để có bookmark PDF
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
// Ô làm bài lấp hết phần còn lại của trang
#let lam-bai = {
  v(2pt)
  o-viet(1fr)
}
// Trang làm bài tiếp nối (câu nhiều ý)
#let tiep(label) = {
  pagebreak()
  text(9.5pt, fill: gray)[#label — làm tiếp]
  v(-6pt)
  o-viet(1fr)
}
// Dòng thông tin dưới tên đề
#let de-info = block(width: 100%, inset: (x: 2pt, y: 2pt), below: 10pt)[
  #set text(10pt)
  Thời gian: *60 phút* · Tự luận · Tài liệu giấy #h(1fr)
  Bắt đầu: #box(width: 2cm, repeat[.]) #h(0.6em) Kết thúc: #box(width: 2cm, repeat[.])
]
// Điểm từng ý — căn phải
#let d(s) = [#h(1fr)#box(inset: (x: 5pt, y: 2pt), radius: 3pt, fill: ok.lighten(85%),
  text(9.5pt, weight: "bold", fill: ok.darken(10%), s))]

// Đồ hình sinh – tử (cùng cách vẽ với GK2)
// lam, mu: một nhãn chung, hoặc mảng nhãn cho từng cung (i → i+1, i+1 → i)
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
  let at(v, i) = if type(v) == array { v.at(i) } else { v }
  box(width: x0 * 2 + (n - 1) * gap, height: 2.8cm, {
    for i in range(n) {
      place(dx: xs.at(i) - r, dy: y0 - r,
        circle(radius: r, stroke: 1.2pt + col, fill: soft)[
          #set align(center + horizon)
          #text(13pt, weight: "bold")[#i]
        ])
    }
    for i in range(n - 1) {
      let s = (xs.at(i) + 0.45 * r, y0 - 0.9 * r)
      let e = (xs.at(i + 1) - 0.45 * r, y0 - 0.9 * r)
      let c1 = (s.at(0) + 0.5cm, s.at(1) - 0.6cm)
      let c2 = (e.at(0) - 0.5cm, e.at(1) - 0.6cm)
      place(curve(stroke: 1pt + col, curve.move(s), curve.cubic(c1, c2, e)))
      arrow-head(e, c2, col)
      let mx = (xs.at(i) + xs.at(i + 1)) / 2
      place(dx: mx - 1cm, dy: y0 - r - 0.9cm, box(width: 2cm, align(center, at(lam, i))))
      let s2 = (xs.at(i + 1) - 0.45 * r, y0 + 0.9 * r)
      let e2 = (xs.at(i) + 0.45 * r, y0 + 0.9 * r)
      let d1 = (s2.at(0) - 0.5cm, s2.at(1) + 0.6cm)
      let d2 = (e2.at(0) + 0.5cm, e2.at(1) + 0.6cm)
      place(curve(stroke: 1pt + col, curve.move(s2), curve.cubic(d1, d2, e2)))
      arrow-head(e2, d2, col)
      place(dx: mx - 1cm, dy: y0 + r + 0.5cm, box(width: 2cm, align(center, at(mu, i))))
    }
  })
}

#let trang(lbl) = context counter(page).at(locate(lbl)).first()

// ================= TRANG BÌA =================
#align(center)[
  #v(0.6cm)
  #text(10pt, fill: gray)[Cơ sở truyền số liệu · ET4070 · theo slide thầy Nguyễn Xuân Dũng]
  #v(2pt)
  #text(22pt, weight: "bold", fill: accent)[GK6 — Ba đề thi thử giữa kỳ]
  #v(2pt)
  #text(11pt, fill: gray)[đúng hình thức thầy báo: tự luận · 60 phút · được dùng tài liệu giấy — kèm lời giải]
]
#v(6pt)

#box-note("Thông tin thi (thầy Nguyễn Xuân Dũng)", warn)[
  - *100% tự luận*; *60 phút*.
  - Được dùng *tài liệu giấy* (photo hoặc ghi chép).
  - Thi đến hết phần *hàng đợi*.
  - *Làm được các ví dụ trên lớp sẽ có lợi thế.*
]

Vì vậy cả ba đề đều là *biến thể đổi số của các ví dụ trên lớp* (tổng đài 1080, xe buýt, M/M/1/3 tự lập phương trình, quầy siêu thị, bãi gửi xe, call center, tổng đài cơ quan, CPU nhiều nhân, mạng 4 nút).

#box-note("Cách làm", accent)[
  + Bấm giờ *60 phút* mỗi đề.
  + Chỉ dùng tài liệu *giấy* (in tập GK0 và các trang sổ tay) — không tra tablet.
  + Trình bày tự luận đủ 5 dòng: *mô hình → tham số → công thức → thay số → kết luận*. Viết thẳng vào ô lưới dưới mỗi câu.
  + Làm xong cả đề mới lật lời giải; tự chấm theo thang điểm.

  *Thứ tự:* Đề A và B chỉ gồm hàng đợi đơn (chắc chắn thi). Đề C có thêm mạng hàng đợi (làm nếu thầy dạy tới trước ngày thi).

  *Mục tiêu:* ≥ 8/10 ở đề A, ≥ 9/10 ở đề B và C, xong trước giờ 5 phút.
]

#v(4pt)
#table(
  columns: (1fr, auto),
  align: (left, center),
  [Phần], [Trang],
  [Đề A — hàng đợi đơn · 3 câu, 10 điểm], [#trang(<de-a>)],
  [Đề B — hàng đợi đơn · 3 câu, 10 điểm], [#trang(<de-b>)],
  [Đề C — có mạng hàng đợi · 3 câu, 10 điểm], [#trang(<de-c>)],
  [Lời giải đề A #text(fill: gray)[(chỉ lật khi đã làm xong đề)]], [#trang(<lg-a>)],
  [Lời giải đề B], [#trang(<lg-b>)],
  [Lời giải đề C], [#trang(<lg-c>)],
  [Bảng tự chấm], [#trang(<cham>)],
)

// =====================================================================
// ================= ĐỀ A ===============================================
// =====================================================================
= ĐỀ THI THỬ A <de-a>
#de-info

#cau[Câu 1 (3 điểm)][
  Cuộc gọi đến một tổng đài theo tiến trình Poisson, trung bình 6 cuộc/phút.
  + Tính xác suất có đúng 10 cuộc gọi đến trong 2 phút.
  + Tính xác suất khoảng thời gian giữa hai cuộc gọi liên tiếp nhỏ hơn 15 giây.
  + Biết 30% số cuộc gọi là cuộc gọi quốc tế. Tính xác suất trong 1 phút không có cuộc gọi quốc tế nào.
]
#lam-bai

#pagebreak()
#cau[Câu 2 (4 điểm)][
  Cho hàng đợi M/M/1/4. Số cuộc gọi đến hệ thống là 4 cuộc/phút; số cuộc gọi rời khỏi hệ thống là 5 cuộc/phút.
  + Biểu diễn quá trình sinh – tử của hệ thống.
  + Tự tìm mối quan hệ giữa các xác suất và tính xác suất các trạng thái (không dùng công thức cho sẵn).
  + Tính xác suất một cuộc gọi bị từ chối và số cuộc gọi trung bình trong hệ thống.
  + Tính thời gian trung bình một cuộc gọi trong hệ thống.
]
#lam-bai
#tiep[Đề A · Câu 2]

#pagebreak()
#cau[Câu 3 (3 điểm)][
  Call center có 3 điện thoại viên. Trong 20 phút có trung bình 8 khách gọi đến (Poisson); thời gian trung bình một cuộc gọi là 4 phút (phân bố mũ). Khi các bàn đều bận, khách nghe nhạc chờ.
  + Tính xác suất một khách hàng được phục vụ ngay.
  + Chỉ tiêu chất lượng: không quá 10% khách phải đợi. Chỉ tiêu có đạt không? Nếu không, cần tối thiểu bao nhiêu điện thoại viên?
]
#lam-bai
#tiep[Đề A · Câu 3]

// =====================================================================
// ================= ĐỀ B ===============================================
// =====================================================================
= ĐỀ THI THỬ B <de-b>
#de-info

#cau[Câu 1 (3 điểm)][
  Khách đi vào quầy tính tiền duy nhất của một cửa hàng theo tiến trình Poisson, trung bình 30 khách/giờ. Thời gian phục vụ một khách phân bố mũ, trung bình 1,5 phút. Cửa hàng đủ chỗ xếp hàng.
  + Tính thời gian chờ trung bình của một khách và số khách trung bình trong hệ thống.
  + Tính xác suất để một khách từ lúc vào xếp hàng đến lúc trả tiền xong không quá 3 phút.
  + Tốc độ khách đến tối đa là bao nhiêu để thời gian chờ trung bình không quá 3 phút?
]
#lam-bai

#pagebreak()
#cau[Câu 2 (3 điểm)][
  Tổng đài cơ quan có 4 đường trung kế nối với tổng đài công cộng. Cuộc gọi ra trung bình 10 cuộc/giờ, cuộc gọi vào 14 cuộc/giờ (đều Poisson). Thời gian chiếm kênh trung bình một cuộc là 2,5 phút (phân bố mũ).
  + Tính tải của tổng đài theo Erlang.
  + Tính xác suất một cuộc gọi bị từ chối do nghẽn mạch.
  + Cần tối thiểu bao nhiêu trung kế để xác suất nghẽn không quá 1%?
]
#lam-bai

#pagebreak()
#cau[Câu 3 (4 điểm)][
  CPU máy chủ có 2 nhân. Số tác vụ cần xử lý trung bình 30 task/ms (Poisson); thời gian xử lý trung bình một tác vụ là 0,05 ms (phân bố mũ).
  + Giả thiết bộ nhớ đệm đủ lớn. Tính thời gian trung bình từ lúc nhận yêu cầu đến khi hoàn thành tác vụ và số tác vụ trung bình trong máy.
  + Giả thiết bộ nhớ đệm chỉ chứa tối đa 3 tác vụ. Vẽ đồ hình trạng thái; tính xác suất một tác vụ bị từ chối và xác suất một tác vụ phải đợi mà không được phục vụ ngay.
]
#lam-bai
#tiep[Đề B · Câu 3]

// =====================================================================
// ================= ĐỀ C ===============================================
// =====================================================================
= ĐỀ THI THỬ C — có mạng hàng đợi <de-c>
#de-info

#cau[Câu 1 (2 điểm)][
  + Hệ thống đóng là gì? Trong các hàng đợi M/M/1/∞, M/M/1/k, M/M/c/c, M/D/1/∞, hàng đợi nào là hệ thống đóng?
  + Một router có trung bình 12 gói nằm trong router, thông lượng 400 gói/s. Tính thời gian trung bình một gói lưu lại router. Dùng định lý nào, điều kiện áp dụng?
]
#lam-bai

#pagebreak()
#cau[Câu 2 (4 điểm)][
  Bãi gửi xe có một cổng với 01 nhân viên; có chỗ cho 5 khách đợi. Khách vào trung bình 2 khách/phút (Poisson); thời gian nhân viên xử lý một xe trung bình 20 giây (phân bố mũ).
  + Mô hình hoá hệ thống theo ký hiệu Kendall.
  + Tính xác suất khách được phục vụ ngay và xác suất bãi bị tắc do người tới quá đông.
  + Tính thời gian trung bình khách phải đợi cho đến khi được phục vụ.
]
#lam-bai
#tiep[Đề C · Câu 2]

#pagebreak()
#cau[Câu 3 (4 điểm)][
  Cho mạng hàng đợi mở 4 nút có sơ đồ như ví dụ trên lớp (slide tr. 87): yêu cầu từ ngoài vào nút 4 với #box[$gamma_4 = 5$ yêu cầu/s;] nút 4 → nút 1; nút 1 → nút 2 #box[($r_12 = 0","4$)] và nút 3 #box[($r_13 = 0","6$);] nút 2 → nút 1 #box[($r_21 = 1$);] nút 3 → nút 1 #box[($r_31 = 0","5$)], ra ngoài #box[($r_30 = 0","5$)]. #box[$1\/mu_1 = 0","02$ s;] #box[$1\/mu_2 = 0","03$ s;] #box[$1\/mu_3 = 0","04$ s;] #box[$1\/mu_4 = 0","05$ s].

  #align(center, block(fill: white, inset: 4pt, radius: 3pt, below: 4pt,
    image("img/gk3_mau2_dung_4nut.png", width: 75%)))
  #align(center, text(9pt, fill: gray)[Sơ đồ mạng (slide thầy Dũng, ch.3 tr. 87)])

  + Tính $lambda_1, lambda_2, lambda_3, lambda_4$.
  + Tính $N_1, N_2, N_3, N_4$ và số yêu cầu trung bình $N$ trong hệ thống.
  + Tính xác suất để hệ thống không có yêu cầu nào.
  + Tính thời gian lưu lại trung bình $T$ của một yêu cầu trong hệ thống.
  + Giữ $r_30$, $r_31$ không đổi, tìm điều kiện của $r_12$, $r_13$ để hệ thống ổn định.
]
#lam-bai
#tiep[Đề C · Câu 3]

// =====================================================================
// ================= LỜI GIẢI ĐỀ A =====================================
// =====================================================================
#set text(11pt)
#set par(leading: 0.68em, spacing: 0.95em)
#show heading.where(level: 2): it => block(sticky: true, above: 16pt, below: 8pt, width: 100%,
  stroke: (bottom: 0.6pt + accent.lighten(50%)), inset: (bottom: 4pt),
  text(accent, size: 12.5pt, weight: "bold", it.body))
#let y(body) = block(width: 100%, above: 0.9em, below: 0.9em, body)

= Lời giải đề A <lg-a>

#block(breakable: false)[
== Câu 1 #h(1fr) #text(10pt, fill: gray)[3 điểm]

#y[a) $lambda t = 6 dot 2 = 12$ → $P\{N = 10\} = (12^10 dot e^(-12)) \/ 10! approx bold(0","105)$. #d[1đ]]
#y[b) $lambda = 6$ cuộc/phút, $t = 15$ s $= 0","25$ phút → $P\{T < 0","25\} = 1 - e^(-6 dot 0","25) = 1 - e^(-1","5) approx bold(0","777)$. #d[1đ]]
#y[c) Tách luồng: cuộc quốc tế là Poisson với $lambda_q = 6 dot 0","3 = 1","8$ cuộc/phút → $P\{0 "cuộc trong 1 phút"\} = e^(-1","8) approx bold(0","165)$. #d[1đ]]
]

== Câu 2 #h(1fr) #text(10pt, fill: gray)[4 điểm]

$lambda = 4$, $mu = 5$ (cuộc/phút); trạng thái 0, 1, 2, 3, 4.

#block(breakable: false)[
#y[a) Đồ hình: 5 vòng tròn 0–4; mũi tên sang phải ghi $lambda = 4$; mũi tên sang trái ghi $mu = 5$. #d[0,75đ]]
#align(center, sinh-tu(5, $lambda = 4$, $mu = 5$))
]

#block(breakable: false)[
#y[b) Phương trình cân bằng (ra = vào): #d[1,5đ]]
- Trạng thái 0: $4 p_0 = 5 p_1$.
- Trạng thái 1: $9 p_1 = 4 p_0 + 5 p_2$.
- Trạng thái 2: $9 p_2 = 4 p_1 + 5 p_3$.
- Trạng thái 3: $9 p_3 = 4 p_2 + 5 p_4$.
- Trạng thái 4: $5 p_4 = 4 p_3$.
- Suy ra liên tiếp: $p_1 = 0","8 p_0$; $p_2 = 0","64 p_0$; $p_3 = 0","512 p_0$; $p_4 = 0","4096 p_0$.
- Chuẩn hoá: $p_0 (1 + 0","8 + 0","64 + 0","512 + 0","4096) = 3","3616 p_0 = 1$ → \
  $bold(p_0 approx 0","2975)$; $bold(p_1 approx 0","2380)$; $bold(p_2 approx 0","1904)$; $bold(p_3 approx 0","1523)$; $bold(p_4 approx 0","1218)$.
]

#y[c) $P_B = p_4 approx bold(0","122)$; $N = 1 dot 0","2380 + 2 dot 0","1904 + 3 dot 0","1523 + 4 dot 0","1218 approx bold(1","563)$ *cuộc gọi*. #d[1đ]]
#y[d) Tốc độ vào thực tế: $lambda (1 - P_B) = 4 dot 0","8782 approx 3","513$ cuộc/phút → \
  $T = N \/ [lambda (1 - P_B)] = 1","563 \/ 3","513 approx bold(0","445)$ *phút* $approx$ *26,7 giây*. #d[0,75đ]]

#block(breakable: false)[
== Câu 3 #h(1fr) #text(10pt, fill: gray)[3 điểm]

Mô hình M/M/c/∞. $lambda = 8\/20 = 0","4$ cuộc/phút; $mu = 1\/4 = 0","25$ cuộc/phút; $a = lambda \/ mu = 1","6$.

#y[a) $c = 3$: $rho = 1","6\/3 approx 0","533$. #d[1,75đ] \
  $p_0 = 1 \/ [(1 + 1","6 + 1","28) + 1","6^3 \/ (3! dot 0","4667)] = 1 \/ (3","88 + 1","4629) approx 0","1872$. \
  $C(3; 1","6) = 1","4629 dot 0","1872 approx 0","274$ → xác suất được phục vụ ngay $= 1 - 0","274 = bold(0","726)$.]
#y[b) $27","4% > 10%$ → *không đạt*. #d[1,25đ] \
  Thử $c = 4$: $rho = 0","4$; $p_0 = 1 \/ (4","5627 + 0","4551) approx 0","1993$; $C(4; 1","6) = 0","4551 dot 0","1993 approx bold(0","091) <= 10%$ \
  → cần tối thiểu *4 điện thoại viên*.]
]

// =====================================================================
// ================= LỜI GIẢI ĐỀ B =====================================
// =====================================================================
= Lời giải đề B <lg-b>

#block(breakable: false)[
== Câu 1 #h(1fr) #text(10pt, fill: gray)[3 điểm]

Mô hình M/M/1/∞. $lambda = 30\/60 = 0","5$ khách/phút; $mu = 1\/1","5 = 0","6667$ khách/phút; $rho = 0","75 < 1$.

#y[a) $T_q = (1\/mu) dot rho \/ (1 - rho) = 1","5 dot 3 = bold(4","5)$ *phút*; $N = rho \/ (1 - rho) = bold(3)$ *khách*. #d[1đ]]
#y[b) $P\{T <= 3\} = 1 - e^(-(mu - lambda) dot 3) = 1 - e^(-0","1667 dot 3) = 1 - e^(-0","5) approx bold(0","393)$. #d[1đ]]
#y[c) $T_q = lambda \/ [mu (mu - lambda)] <= 3$ → $lambda <= 3 mu^2 - 3 mu lambda$ → $lambda (1 + 3 mu) <= 3 mu^2$ → \
  $lambda <= 3 dot 0","4444 \/ 3 = 0","4444$ khách/phút $approx$ *26,7 khách/giờ*. #d[1đ]]
]

#block(breakable: false)[
== Câu 2 #h(1fr) #text(10pt, fill: gray)[3 điểm]

Mô hình M/M/c/c (không có chỗ chờ).

#y[a) Ghép luồng: $lambda = 10 + 14 = 24$ cuộc/giờ; $a = 24 dot 2","5 \/ 60 = bold(1)$ *Erlang*. #d[0,75đ]]
#y[b) $c = 4$: $B(4; 1) = (1^4 \/ 4!) \/ (1 + 1 + 1\/2 + 1\/6 + 1\/24) = 0","04167 \/ 2","7083 approx bold(0","0154 thick (1","54%))$. #d[1,25đ]]
#y[c) $1","54% > 1%$ → thử $c = 5$: $B(5; 1) = (1\/120) \/ 2","7167 approx 0","0031 <= 1%$ #d[1đ] \
  → cần tối thiểu *5 trung kế*.]
]

== Câu 3 #h(1fr) #text(10pt, fill: gray)[4 điểm]

$lambda = 30$ task/ms; $mu = 1\/0","05 = 20$ task/ms; $c = 2$; $a = 1","5$; $rho = 0","75$.

#block(breakable: false)[
#y[a) Mô hình M/M/2/∞. $p_0 = 1 \/ [(1 + 1","5) + 1","5^2 \/ (2! dot 0","25)] = 1 \/ (2","5 + 4","5) = 1\/7 approx 0","1429$. $C(2; 1","5) = 4","5\/7 approx 0","643$. #d[2đ]]
- $N_q = C dot rho \/ (1 - rho) = 0","643 dot 3 approx 1","929$; $N = N_q + a approx bold(3","43)$ *tác vụ*.
- $T = 1\/mu + C \/ (c mu - lambda) = 0","05 + 0","643 \/ 10 approx bold(0","114)$ *ms*.
]

#block(breakable: false)[
#y[b) 3 chỗ trong bộ đệm + 2 nhân → $k = 5$ → mô hình *M/M/2/5*. #d[2đ]]
- Đồ hình: trạng thái 0…5; sinh $lambda = 30$ ở mọi mũi tên sang phải; tử: 1→0 là $mu = 20$; 2→1, 3→2, 4→3, 5→4 là $2 mu = 40$.
#align(center, sinh-tu(6, $lambda = 30$,
  ($mu = 20$, $2 mu = 40$, $2 mu = 40$, $2 mu = 40$, $2 mu = 40$)))
]
- Quan hệ: $p_1 = 1","5 p_0$; $p_2 = 1","125 p_0$; $p_3 = 0","84375 p_0$; $p_4 = 0","63281 p_0$; $p_5 = 0","47461 p_0$. Tổng hệ số $= 5","57617$ → $p_0 approx 0","1793$.
- $p_1 approx 0","2690$; $p_2 approx 0","2018$; $p_3 approx 0","1513$; $p_4 approx 0","1135$; $bold(P_B = p_5 approx 0","0851)$.
- Xác suất phải đợi (cách thầy chữa trên lớp): $1 - (p_0 + p_1) approx bold(0","552)$ (trong đó 0,085 là bị từ chối; phần phải đợi rồi được phục vụ là $p_2 + p_3 + p_4 approx 0","467$). Ghi cả hai con số và nói rõ cách hiểu.

// =====================================================================
// ================= LỜI GIẢI ĐỀ C =====================================
// =====================================================================
= Lời giải đề C <lg-c>

#block(breakable: false)[
== Câu 1 #h(1fr) #text(10pt, fill: gray)[2 điểm]

#y[a) Hệ thống đóng: số yêu cầu đi vào = số đã đi ra + số đang nằm trong hệ; hệ không tự sinh ra cũng không huỷ yêu cầu. #d[0,5đ] \
  Là hệ thống đóng (khi $rho < 1$): *M/M/1/∞, M/D/1/∞*. Không phải: *M/M/1/k, M/M/c/c* vì có yêu cầu bị từ chối. #d[0,5đ]]
#y[b) Định lý Little: $T = N \/ lambda = 12 \/ 400 = bold(0","03)$ *s* $=$ *30 ms*. #d[0,5đ] \
  Áp dụng cho hệ thống đóng ở chế độ ổn định, không phụ thuộc phân bố của tiến trình tới và phục vụ. #d[0,5đ]]
]

#block(breakable: false)[
== Câu 2 #h(1fr) #text(10pt, fill: gray)[4 điểm]

$lambda = 2$ khách/phút; $mu = 60\/20 = 3$ khách/phút; $rho = 2\/3$.

#y[a) 1 server, 5 chỗ chờ → $k = 6$ → *M/M/1/6*. #d[0,75đ]]
#y[b) $p_0 = (1 - rho) \/ (1 - rho^7) = 0","3333 \/ (1 - 0","05853) approx bold(0","354)$ (xác suất được phục vụ ngay). #d[1,75đ] \
  $P_B = p_6 = rho^6 dot p_0 = 0","08779 dot 0","354 approx bold(0","031)$ (3,1%).]
#y[c) $N = rho \/ (1 - rho) - 7 rho^7 \/ (1 - rho^7) = 2 - 7 dot 0","05853 \/ 0","94147 approx 1","565$; $N_q = N - (1 - p_0) approx 0","919$; #d[1,5đ] \
  $lambda_"thực tế" = 2 dot (1 - 0","031) approx 1","938$ → $T_q = 0","919 \/ 1","938 approx bold(0","474)$ *phút* $approx$ *28,5 giây*.]
]

== Câu 3 #h(1fr) #text(10pt, fill: gray)[4 điểm]

#y[a) $lambda_4 = 5$; $lambda_1 = lambda_4 + lambda_2 + 0","5 lambda_3$; $lambda_2 = 0","4 lambda_1$; $lambda_3 = 0","6 lambda_1$ #d[1đ] \
  → $lambda_1 = 5 + 0","4 lambda_1 + 0","3 lambda_1$ → $0","3 lambda_1 = 5$ → $bold(lambda_1 approx 16","67)$; $bold(lambda_2 approx 6","67)$; $bold(lambda_3 = 10)$; $bold(lambda_4 = 5)$ (yêu cầu/s). Kiểm tra: ra ngoài $= 0","5 dot 10 = 5 = gamma_4$ ✔.]
#y[b) $rho_1 = 0","333$; $rho_2 = 0","2$; $rho_3 = 0","4$; $rho_4 = 0","25$ → #d[1đ] \
  $bold(N_1 = 0","5)$; $bold(N_2 = 0","25)$; $bold(N_3 = 0","667)$; $bold(N_4 = 0","333)$; $N = bold(1","75)$ *yêu cầu*.]
#y[c) $P_0 = (1 - 0","333)(1 - 0","2)(1 - 0","4)(1 - 0","25) = bold(0","24)$. #d[0,5đ]]
#y[d) $T = N \/ gamma_4 = 1","75 \/ 5 = bold(0","35)$ *s*. #d[0,5đ]]
#block(breakable: false)[
#y[e) $lambda_1 = 5 + (1 - r_13) lambda_1 + 0","5 r_13 lambda_1$ → $lambda_1 = 10 \/ r_13$; $lambda_2 = 10(1 - r_13) \/ r_13$; $lambda_3 = 10$; $lambda_4 = 5$. #d[1đ]]
- $rho_1 = 0","2 \/ r_13 < 1$ → $r_13 > 0","2$;
- $rho_2 = 0","3(1 - r_13) \/ r_13 < 1$ → $r_13 > 0","231$;
- $rho_3 = 0","4$; $rho_4 = 0","25$
- → $bold(r_13 > 0","231 "và" r_12 = 1 - r_13 < 0","769)$.
]

// =====================================================================
// ================= BẢNG TỰ CHẤM ======================================
// =====================================================================
#set text(11.5pt)
= Bảng tự chấm <cham>

#text(fill: gray)[Điền điểm từng câu theo thang điểm trong lời giải; ghi lại thời gian làm thực tế (giới hạn 60 phút).]

#v(4pt)
#let ocham(s) = align(right + bottom, text(13pt, fill: luma(110), s))
#table(
  columns: (1.2fr, 1.5fr, 1.5fr, 1.5fr),
  rows: (auto, 1.5cm),
  inset: 9pt,
  align: (left + horizon, right + bottom, right + bottom, right + bottom),
  table.header([], align(center)[Đề A], align(center)[Đề B], align(center)[Đề C]),
  [Câu 1], ocham[/3], ocham[/3], ocham[/2],
  [Câu 2], ocham[/4], ocham[/3], ocham[/4],
  [Câu 3], ocham[/3], ocham[/4], ocham[/4],
  table.cell(fill: soft)[*Tổng*], table.cell(fill: soft, ocham(strong[/10])),
  table.cell(fill: soft, ocham(strong[/10])), table.cell(fill: soft, ocham(strong[/10])),
  [Thời gian làm], ocham[phút], ocham[phút], ocham[phút],
)

#v(6pt)
#text(weight: "bold", fill: warn)[Lỗi sai cần chép vào mục "Lỗi hay mắc" của sổ tay]
#v(-6pt)
#o-viet(1fr)
