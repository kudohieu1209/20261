// Biên dịch: typst compile CK4_CongBang_TacNghen.typ
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let accent = rgb("#1f5fa8")
#let warn = rgb("#b5452b")
#let soft = rgb("#eef3fa")
#let green = rgb("#2e7d4f")

#set document(title: "CK4 — Tính công bằng max-min và chống tắc nghẽn")
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
// Bài mẫu: không cho cắt giữa hình và lời giải
#let mau(title, body) = block(breakable: false, width: 100%,
  box-note("Bài mẫu " + title, green, body))

// Ô trống có lưới chấm để viết tay trên tablet
#let o-viet(h) = block(
  width: 100%, height: h, radius: 3pt, stroke: 0.5pt + luma(200),
  fill: tiling(size: (0.5cm, 0.5cm), place(dx: 0.25cm, dy: 0.25cm, circle(radius: 0.6pt, fill: luma(185)))),
)

#let hinh(path, w) = align(center, image(path, width: w))

// Thẻ khái niệm
#let the(title, color, body) = [#text(color, weight: "bold", title) #v(-3pt) #line(length: 100%, stroke: 0.5pt + color.lighten(50%)) #v(-4pt) #body]

// ---------- Sơ đồ chuỗi nút A–B–C–D với các kết nối ----------
#let mau-kn = (
  "1": rgb("#c0392b"), "2": rgb("#1e8449"), "3": rgb("#7d3c98"),
  "4": rgb("#d35400"), "5": rgb("#1f5fa8"),
)
// caps: dung lượng 3 liên kết; conns: (số, nút vào, nút ra, mức y) — nút: 0=A … 3=D
#let chuoi(caps, conns, sx: 2.15cm) = {
  set text(9pt)
  diagram(
    spacing: (sx, 0.42cm),
    node-stroke: 0.9pt,
    ..("A", "B", "C", "D").enumerate().map(((i, n)) =>
      node((i, 0), text(10.5pt, weight: "bold", n), shape: circle, radius: 0.36cm, fill: soft)),
    ..range(3).map(i => edge((i, 0), (i + 1, 0), "-", stroke: 2.6pt + luma(150),
      text(8.5pt, weight: "bold")[#caps.at(i) Mbps], label-side: center, label-fill: white)),
    ..conns.map(((k, a, b, lv)) => {
      let c = mau-kn.at(str(k))
      (
        edge((a - 0.33, lv), (b + 0.3, lv), "-|>", stroke: 1.4pt + c),
        node((a - 0.33, lv), text(8pt, fill: white, weight: "bold", str(k)), inset: 0pt,
          shape: circle, radius: 0.22cm, fill: c, stroke: none),
      )
    }).flatten(),
  )
}

// ---------- Giản đồ thời gian bài mẫu 5 ----------
#let gian-do = {
  let s = 0.33cm                // 1 ms
  let y0 = 0.95cm
  let xs = 2.55cm                // trục Nguồn
  let xd = 5.25cm                // trục Đích
  let xt = 6.25cm                // trục thời gian
  let tmax = 68
  let y(t) = y0 + t * s
  let red = rgb("#c62828")
  let blue = rgb("#1565c0")
  let frames = ((1, 0), (2, 0.8), (3, 1.6), (4, 10.8), (5, 11.6), (6, 12.4),
    (7, 21.6), (8, 23.2), (9, 32.4), (10, 34.0), (11, 43.2), (12, 44.8),
    (13, 45.6), (14, 46.4), (15, 54.0), (16, 55.6))
  let tac = (2, 3, 5, 7, 9, 12, 13)
  let arrow(x1, y1, x2, y2, c, w) = {
    place(top + left, line(start: (x1, y1), end: (x2, y2), stroke: w + c))
    let dx = (x2 - x1) / 1pt
    let dy = (y2 - y1) / 1pt
    let l = calc.sqrt(dx * dx + dy * dy)
    let ux = dx / l
    let uy = dy / l
    let hl = 4.2
    let hw = 1.9
    place(top + left, polygon(fill: c, stroke: none,
      (x2, y2),
      (x2 - (hl * ux - hw * uy) * 1pt, y2 - (hl * uy + hw * ux) * 1pt),
      (x2 - (hl * ux + hw * uy) * 1pt, y2 - (hl * uy - hw * ux) * 1pt),
    ))
  }
  block(width: 7.25cm, height: y(tmax) + 0.2cm, {
    // lưới thời gian
    for t in range(0, tmax + 1, step: 10) {
      place(top + left, line(start: (xs, y(t)), end: (xt, y(t)), stroke: (paint: luma(205), thickness: 0.4pt, dash: "dotted")))
      place(top + left, line(start: (xt, y(t)), end: (xt + 0.12cm, y(t)), stroke: 0.6pt))
      place(top + left, dx: xt + 0.17cm, dy: y(t) - 0.15cm, text(7pt, fill: luma(80))[#t ms])
    }
    place(top + left, line(start: (xt, y(0)), end: (xt, y(tmax)), stroke: 0.6pt + luma(80)))
    place(top + left, dx: xt - 0.35cm, dy: 0.2cm, text(7.5pt, fill: luma(80), style: "italic")[t ↓])
    // trục Nguồn – Đích
    place(top + left, line(start: (xs, y(0)), end: (xs, y(tmax)), stroke: 1.1pt))
    place(top + left, line(start: (xd, y(0)), end: (xd, y(tmax)), stroke: 1.1pt))
    place(top + left, dx: xs - 0.6cm, dy: 0.2cm, text(9pt, weight: "bold")[Nguồn])
    place(top + left, dx: xd - 0.4cm, dy: 0.2cm, text(9pt, weight: "bold")[Đích])
    for (k, ts) in frames {
      let c = if k in tac { red } else { blue }
      // khung: ô số khung trên trục Nguồn + đoạn xiên tới Đích
      place(top + left, dx: xs - 0.44cm, dy: y(ts),
        rect(width: 0.44cm, height: 0.8 * s, stroke: 0.5pt, fill: soft, inset: 0pt,
          align(center + horizon, text(6pt, weight: "bold", str(k)))))
      arrow(xs, y(ts + 0.8), xd, y(ts + 5.8), luma(40), 0.6pt)
      // ACK: đoạn xiên ngược từ Đích về Nguồn
      arrow(xd, y(ts + 5.8), xs, y(ts + 10.8), c, 0.85pt)
      place(top + left, dx: xd + 0.08cm, dy: y(ts + 5.8) - 0.13cm,
        text(6.5pt, fill: c, weight: "bold", str(k)))
    }
    // ghi chú cửa sổ
    let ghi(t, body) = {
      place(top + left, line(start: (0.05cm, y(t)), end: (xs - 0.47cm, y(t)), stroke: (paint: green, thickness: 0.5pt, dash: "dashed")))
      place(top + left, dx: 0.05cm, dy: y(t) + 0.2cm,
        block(width: xs - 0.55cm, text(7pt, fill: green, weight: "bold", body)))
    }
    ghi(22.4)[ACK5: W giảm 2,4 → dùng 2]
    ghi(44.8)[ACK10: W tăng 4,4 → dùng 4]
    ghi(64.8)[ACK15: W = 6,4 → dùng 6]
  })
}

// ---------- Băng diễn biến bài mẫu 6 ----------
#let chip(k, c: soft) = box(width: 0.56cm, height: 0.58cm, fill: c, stroke: 0.6pt + luma(90), radius: 2pt,
  align(center + horizon, text(9pt, weight: "bold", str(k))))
#let pha(w, chips, note) = block(inset: (x: 6pt, y: 5pt), radius: 4pt, stroke: 0.6pt + accent.lighten(40%), fill: white)[
  #align(center)[#text(10pt, fill: accent, weight: "bold")[#w] \ #v(-3pt) #chips \ #v(-3pt) #text(8pt)[#note]]
]

// ================= TRANG BÌA =================
#align(center)[
  #v(0.2cm)
  #text(19pt, weight: "bold", fill: accent)[CK4 — Tính công bằng max-min và chống tắc nghẽn]
]
#v(6pt)

#box-note("Cách học buổi này", accent)[
  + Đọc mục 1 (khái niệm) và mục 2 (khuôn max-min).
  + Đọc bài mẫu 1–3 (phân chia băng thông), mục 3 và bài mẫu 4–6 (cửa sổ thích ứng).
  + Làm 4 bài ở phần *Bài tự luyện* ngay vào ô chấm — *chưa nhìn đáp án*; dò *Đáp án* ở trang cuối.
  + Chép trang *Sổ tay phòng thi — trang 9*.

  *Điểm trong đề:* khoảng 1 điểm (ý phân chia băng thông) + có thể 1 câu lý thuyết ngắn.

  *Qua buổi khi:* phân chia max-min đúng trong ≤ 5 phút; dựng được diễn biến cửa sổ theo bit tắc nghẽn.

]

== 1. Khái niệm cần nhớ (trả lời câu hỏi ngắn)
#set text(10.5pt)

#grid(columns: (1fr, 1fr), column-gutter: 10pt, row-gutter: 8pt, inset: 8pt,
  fill: (x, y) => (if y == 0 { accent } else { green }).lighten(93%),
  stroke: (x, y) => 0.8pt + (if y == 0 { accent } else { green }).lighten(35%),
  the("Điều khiển luồng", accent)[
    Đảm bảo phía phát *không phát vượt khả năng xử lý của phía thu*. \
    Hai kiểu: *end-to-end* (giữa hai đầu cuối) và *hop-by-hop* (giữa từng cặp nút kề nhau).
  ],
  the("Chống tắc nghẽn", accent)[
    Kiểm soát thông tin đi vào mạng để *tổng lưu lượng không vượt khả năng xử lý của toàn mạng*. \
    Hai kiểu: *điều khiển truy nhập mạng* và *điều khiển cấp phát bộ đệm*.
  ],
  the("Tính công bằng", green)[
    Các người dùng/ứng dụng được dùng tài nguyên mạng với *cơ hội như nhau* — công bằng về *băng truyền* và về *bộ đệm*.
  ],
  the("Max-min fairness (công bằng cực đại – cực tiểu)", green)[
    Đáp ứng công bằng cho người dùng có yêu cầu ít nhất trước, tài nguyên còn lại tiếp tục chia công bằng cho những người còn lại, lặp đến hết. \
    Kết quả: không thể tăng băng thông của ai mà không phải giảm của một người đang có ít hơn hoặc bằng.
  ],
)
#v(2pt)
#box-note("Lưu ý", warn)[
  Thông lượng tổng cực đại *không* đồng nghĩa công bằng (ví dụ cho kết nối dài nhất 0 Mbps để các kết nối ngắn dùng hết).
]
#set text(11.5pt)

// ================= MỤC 2 + BÀI MẪU 1 =================
= Phân chia băng thông max-min

== 2. Khuôn phân chia băng thông max-min

#khuon[
  #set enum(spacing: 0.85em)
  + Liệt kê mỗi kết nối đi qua những liên kết nào (đọc kỹ hình: kết nối vào ở nút nào, ra ở nút nào).
  + Với mỗi liên kết còn kết nối chưa chốt: *phần chia đều = dung lượng còn lại / số kết nối chưa chốt đi qua liên kết đó*.
  + Liên kết có *phần chia đều nhỏ nhất* là nút cổ chai → *chốt* mọi kết nối chưa chốt đi qua nó bằng giá trị đó.
  + Trừ phần đã chốt khỏi dung lượng *mọi* liên kết mà các kết nối vừa chốt đi qua.
  + Lặp lại bước 2–4 với các kết nối còn lại đến khi chốt hết.
  + Kiểm tra: tổng trên mỗi liên kết ≤ dung lượng.
]

#v(4pt)
#mau("1 — Mạng A–B–C–D, 4 kết nối")[
  Kết nối 1: A→B; 2: B→C; 3: C→D; 4: A→D (đi qua cả 3 liên kết).

  *(a)* AB = BC = CD = 1 Mbps.
  #align(center, chuoi((1, 1, 1), ((1, 0, 1, -0.6), (3, 2, 3, -0.6), (2, 1, 2, 0.6), (4, 0, 3, 1.1)), sx: 2.3cm))
  - Cực đại thông lượng: C1 = C2 = C3 = 1, C4 = 0 → tổng 3 Mbps nhưng *không công bằng*.
  - Chia đều theo liên kết (max-min): mỗi liên kết có 2 kết nối → mỗi kết nối 0,5 Mbps → tổng 2 Mbps, công bằng.

  *(b)* AB = 1, BC = 2, CD = 3 Mbps (max-min):
  #align(center, chuoi((1, 2, 3), ((1, 0, 1, -0.6), (3, 2, 3, -0.6), (2, 1, 2, 0.6), (4, 0, 3, 1.1)), sx: 2.3cm))
  - Bước 1: AB: 1/2 = 0,5; BC: 2/2 = 1; CD: 3/2 = 1,5 → AB nhỏ nhất → chốt *C1 = C4 = 0,5*.
  - Bước 2: BC còn 2 − 0,5 = 1,5 cho C2; CD còn 3 − 0,5 = 2,5 cho C3 → *C2 = 1,5*; *C3 = 2,5* (Mbps).
]

// ================= BÀI MẪU 2, 3 =================
= Bài mẫu từ đề cuối kỳ

#mau("2 — đề cuối kỳ 20221Q câu 2a")[
  #hinh("img/ck4_m2_de20221Q.png", 13cm)
  A —8 Mbps— B —15 Mbps— C —10 Mbps— D. Kết nối 1: vào A, ra sau D (qua AB, BC, CD). Kết nối 2: vào A (phía trên), ra ở C (qua AB, BC). Kết nối 3: vào A (phía dưới), ra ở B (qua AB). Kết nối 4: vào ở B, ra sau D (qua BC, CD).
  - Bước 1: AB: 8/3 ≈ 2,67 (1, 2, 3); BC: 15/3 = 5 (1, 2, 4); CD: 10/2 = 5 (1, 4) → AB nhỏ nhất → chốt *1, 2, 3 = 8/3 ≈ 2,67 Mbps*.
  - Bước 2: còn kết nối 4. BC còn 15 − 2·8/3 = 29/3; CD còn 10 − 8/3 = 22/3 → nhỏ nhất CD → *4 = 22/3 ≈ 7,33 Mbps*.
  - Kiểm tra: BC = 8/3 + 8/3 + 22/3 = 38/3 ≈ 12,67 ≤ 15 ✔; CD = 8/3 + 22/3 = 10 ✔.

  #bay[Tài liệu tổng hợp ghi kết nối 4 = 29/3 ≈ 9,67 Mbps — *sai*, vì khi đó liên kết CD phải mang 8/3 + 29/3 = 37/3 > 10 Mbps.]
]

#mau("3 — đề cuối kỳ 20231Q câu 2a")[
  #hinh("img/ck4_m3_de20231Q.png", 11cm)
  A —10 Mbps— B —5 Mbps— C —5 Mbps— D. Kết nối 1: A → qua D (AB, BC, CD). Kết nối 2: vào A (trên), ra ở B (AB). Kết nối 3: vào B (trên), ra ở C (BC). Kết nối 4: vào A (dưới), ra ở B (AB).
  - Bước 1: AB: 10/3 ≈ 3,33 (1, 2, 4); BC: 5/2 = 2,5 (1, 3); CD: 5/1 = 5 (1) → BC nhỏ nhất → chốt *1 = 3 = 2,5 Mbps*.
  - Bước 2: AB còn 10 − 2,5 = 7,5 cho kết nối 2, 4 → *2 = 4 = 3,75 Mbps*.
  - Kiểm tra: AB = 2,5 + 3,75 + 3,75 = 10 ✔; BC = 5 ✔; CD = 2,5 ≤ 5 ✔.
]

// ================= MỤC 3 =================
= 3. Chống tắc nghẽn bằng cửa sổ thích ứng

#box-note("Thiết bị mạng thông minh (phát hiện tắc nghẽn và báo cho nguồn)", accent)[
  - Cách báo: gói cảnh báo độc lập (nhanh nhưng tốn băng thông) hoặc *bit chỉ thị tắc nghẽn* trong báo nhận (0 = không tắc, 1 = tắc).
  - Nguồn *không* quyết định theo từng ACK mà theo *nhóm n báo nhận*:
    - số ACK có bit tắc ≥ ngưỡng → coi là tắc nghẽn → *giảm W bằng phép nhân* #box[$W_"mới" = W_"cũ" times alpha$ ($alpha < 1$)];
    - ngược lại → *tăng W bằng phép cộng* #box[$W_"mới" = W_"cũ" + I$].
  - W không nguyên thì *dùng số nguyên gần nhất* (W vẫn lưu giá trị thực để tính tiếp).
]

#box-note("Thiết bị mạng không thông minh (nguồn tự suy đoán qua time-out)", accent)[
  - Ban đầu W = Wmax.
  - Mỗi khi *time-out* phải phát lại → đặt *W = 1*.
  - Mỗi khi nhận được *n báo nhận* → W tăng thêm 1, nhưng không vượt Wmax.
]

#v(4pt)
#mau("4 — Thiết bị thông minh")[
  W ban đầu = 4; xét theo nhóm 7 báo nhận; ≥ 4 ACK có bit tắc → giảm với α = 0,7; ngược lại tăng với I = 1.
  - Nhóm 1 tắc: W = 4·0,7 = 2,8 → *dùng W = 3*.
  - Nhóm 2 tắc: W = 2,8·0,7 = 1,96 → *dùng W = 2*.
  - Nhóm 3 không tắc: W = 1,96 + 1 = 2,96 → *dùng W = 3*.

  #let cot(w, nhan, chu, c) = stack(spacing: 4pt,
    align(center, text(9pt, weight: "bold", fill: c, nhan)),
    align(center, rect(width: 1.3cm, height: w * 0.62cm, fill: c.lighten(75%), stroke: 0.8pt + c)),
    align(center, text(8.5pt, chu)))
  #let mui = text(14pt, fill: luma(110))[→]
  #align(center, grid(columns: 7, column-gutter: 14pt, align: bottom + center,
    cot(4, [W = 4], [ban đầu], accent), mui,
    cot(2.8, [2,8 → dùng 3], [nhóm 1: tắc, ×0,7], warn), mui,
    cot(1.96, [1,96 → dùng 2], [nhóm 2: tắc, ×0,7], warn), mui,
    cot(2.96, [2,96 → dùng 3], [nhóm 3: không tắc, +1], green),
  ))
  #align(center, text(8.5pt, fill: gray)[Chiều cao cột = W thực (giữ để tính tiếp); số "dùng" = số nguyên gần nhất.])
]

#v(6pt)
#text(9.5pt, fill: gray)[Ghi thêm:]
#o-viet(1fr)

// ================= BÀI MẪU 5 =================
#pagebreak(weak: true)
#mau("5 — bài tập cô Lan bài 4 (có tính hiệu suất)")[
  #set text(10.5pt)
  #grid(columns: (1fr, 7.25cm), column-gutter: 10pt,
    [
      W ban đầu = 3; xét theo nhóm 5 báo nhận; ≥ 3 ACK có bit tắc → giảm với α = 0,8; ngược lại tăng với I = 2. ACK có bit tắc: 2, 3, 5, 7, 9, 12, 13. L = 1000 byte; R = 10 Mbps; TD = 5 ms. Tính hiệu suất.

      *Diễn biến cửa sổ:*
      #set text(9pt)
      #table(
        columns: (1.2fr, 1.5fr, 0.95fr, 2.2fr, 2.1fr, 0.95fr),
        inset: 3.5pt, align: center + horizon,
        text(8.5pt)[Nhóm ACK], text(8.5pt)[ACK có bit tắc], text(8.5pt)[Số tắc], text(8.5pt)[Kết luận], text(8.5pt)[W mới], text(8.5pt)[W dùng],
        [1–5], [2, 3, 5], [3], [tắc → ×0,8], [3·0,8 = 2,4], [*2*],
        [6–10], [7, 9], [2], [không → +2], [2,4 + 2 = 4,4], [*4*],
        [11–15], [12, 13], [2], [không → +2], [6,4], [*6*],
      )
      #set text(10.5pt)

      *Thời gian:* TF = 8000/10⁷ = 0,8 ms; mỗi khung nhận ACK sau TF + 2TD = 10,8 ms kể từ lúc bắt đầu phát.

      *Mô phỏng* (cửa sổ trượt: được phát khung k khi k ≤ khung đã được ACK cuối cùng + W dùng; kênh phát nối tiếp):
      #set text(9.5pt)
      #table(
        columns: (1.15fr, 1fr, 1fr),
        inset: 4pt, align: left + horizon,
        text(8.5pt)[Khung], text(8.5pt)[Bắt đầu phát (ms)], text(8.5pt)[Nhận ACK (ms)],
        [1, 2, 3], [0; 0,8; 1,6], [10,8; 11,6; 12,4],
        [4, 5, 6], [10,8; 11,6; 12,4], [21,6; 22,4; 23,2],
        [7, 8 #text(9pt)[(W = 2 từ ACK5)]], [21,6; 23,2], [32,4; 34,0],
        [9, 10], [32,4; 34,0], [43,2; 44,8],
        [11, 12, 13, 14 #text(9pt)[(W = 4 từ ACK10)]], [43,2; 44,8; 45,6; 46,4], [54,0; 55,6; 56,4; 57,2],
        [15, 16 #text(9pt)[(vẫn W = 4, phát khi nhận ACK11, ACK12)]], [54,0; 55,6], [64,8; 66,4],
      )
      #set text(10.5pt)

      Hiệu suất khi truyền 16 khung = 16·0,8 / 66,4 ≈ *19,3%* (thời gian phát hữu ích / tổng thời gian đến khi nhận ACK khung cuối).

      #box-note("Ghi chú", warn)[
        #set text(9.5pt)
        Tài liệu tổng hợp chỉ vẽ diễn biến, không ra số hiệu suất. Cách tính trên là cách hợp lý theo định nghĩa η = thời gian phát / tổng thời gian; nếu đề quy định số khung khác thì làm tương tự. Ghi rõ cách tính khi đi thi.
      ]

      #text(8.5pt)[
        *Đọc giản đồ:* ô số trên trục Nguồn = khung đang phát (dài TF = 0,8 ms); đoạn xiên đen = khung đi tới Đích; đoạn xiên ngược = ACK, số bên phải trục Đích là số ACK. \
        #text(fill: rgb("#c62828"), weight: "bold")[— đỏ: ACK có bit tắc] #h(6pt) #text(fill: rgb("#1565c0"), weight: "bold")[— xanh: không tắc]
      ]
    ],
    gian-do,
  )
]

// ================= BÀI MẪU 6 =================
#mau("6 — thiết bị không thông minh (dựa trên bài tập cô Lan bài 2)")[
  Wmax = 4, n = 2. Diễn biến mẫu:
  - Đầu tiên W = 4: phát 1–4, nhận ACK đủ (W đã bằng Wmax nên giữ 4); phát 5–8.
  - Khung 7 bị time-out → *W = 1* → phát lại 7.
  - Nhận ACK của 7 (1 báo nhận, chưa đủ n = 2) → phát 8 (W = 1); nhận ACK của 8 (đủ 2 báo nhận) → *W = 2* → phát 9, 10.
  - Nhận 2 ACK (9, 10) → *W = 3* → phát 11, 12, 13 → nhận đủ 2 ACK → *W = 4* (= Wmax, không tăng nữa) …

  #v(2pt)
  #let mui = align(center + horizon, text(11pt, fill: accent)[→])
  #let do7 = rgb("#f6c9c4")
  #align(center, grid(columns: 11, column-gutter: 2pt, align: horizon,
    pha([W = 4], [#chip(1)#chip(2)#chip(3)#chip(4)], [ACK đủ, giữ 4]),
    mui,
    pha([W = 4], [#chip(5)#chip(6)#chip(7, c: do7)#chip(8)], [7 time-out]),
    mui,
    pha([W = 1], [#chip(7)], [ACK7: 1/2]),
    mui,
    pha([W = 1], [#chip(8)], [ACK8: đủ 2]),
    mui,
    pha([W = 2], [#chip(9)#chip(10)], [2 ACK]),
    mui,
    pha([W = 3], [#chip(11)#chip(12)#chip(13)], [đủ 2 ACK → W = 4]),
  ))
]

#v(6pt)
#text(9.5pt, fill: gray)[Ghi thêm:]
#o-viet(1fr)

// ================= SỔ TAY =================
= Sổ tay phòng thi — trang 9

#set text(13pt)
#set par(leading: 0.9em)
#box-note("MAX-MIN", accent)[
  mỗi liên kết: dung lượng còn / số kết nối chưa chốt → liên kết nhỏ nhất = cổ chai \
  → chốt các kết nối qua nó → trừ khỏi mọi liên kết chúng đi qua → lặp \
  *KIỂM TRA:* tổng trên mỗi liên kết ≤ dung lượng
]
#box-note("CỬA SỔ THÍCH ỨNG", accent)[
  *thông minh:* theo nhóm n ACK; ≥ ngưỡng bit tắc → W×α; ngược lại W+I \
  #h(1em) W lẻ → dùng số nguyên gần nhất (vẫn giữ W thực để tính tiếp) \
  *không thông minh:* bắt đầu Wmax; time-out → W = 1; mỗi n ACK → W+1 (≤ Wmax)
]
#box-note("HIỆU SUẤT", accent)[
  η = (số khung × TF) / thời điểm nhận ACK khung cuối
]
#box-note("LÝ THUYẾT", accent)[
  *ĐK luồng:* phát ≤ khả năng thu (end-to-end, hop-by-hop) \
  *Chống tắc nghẽn:* vào ≤ khả năng mạng (truy nhập mạng, cấp phát bộ đệm)
]
#set text(11.5pt)
#set par(leading: 0.75em)
#v(6pt)
#text(9.5pt, fill: gray)[Ghi thêm:]
#o-viet(1fr)

// ================= BÀI TẬP =================
= Bài tự luyện — viết thẳng vào ô chấm

#text(fill: gray)[Làm hết rồi mới lật trang đáp án.]

#let bai(n, body, h: 6cm) = block(breakable: false, width: 100%)[
  *Bài #n.* #body
  #v(-2pt)
  #o-viet(h)
  #v(4pt)
]

#bai(1, h: 7cm)[Ba liên kết A —6 Mbps— B —9 Mbps— C —4 Mbps— D. Kết nối 1: A→D; 2: A→B; 3: B→D; 4: C→D; 5: B→C. Phân chia băng thông theo max-min.
  #align(center, chuoi((6, 9, 4), ((2, 0, 1, -0.6), (4, 2, 3, -0.6), (5, 1, 2, -1.1), (1, 0, 3, 0.6), (3, 1, 3, 1.1))))
]
#bai(2, h: 6cm)[Thiết bị thông minh: W ban đầu = 6; nhóm 4 ACK; ≥ 2 ACK tắc → ×0,7; ngược lại +1. Bốn nhóm liên tiếp có số ACK tắc lần lượt 3, 1, 0, 2. Tìm W (thực và dùng) sau mỗi nhóm.]
#bai(3, h: 5cm)[Thiết bị không thông minh Wmax = 6, n = 3. Đang ở W = 6 thì có time-out. Sau đó cần nhận bao nhiêu báo nhận để W trở lại 6?]
#bai(4, h: 6cm)[(Lý thuyết, ≤ 5 dòng) Phân biệt điều khiển luồng và chống tắc nghẽn. Nêu hai cơ chế thiết bị mạng thông minh báo tắc nghẽn cho nguồn.]

// ================= ĐÁP ÁN =================
= Đáp án

#table(
  columns: (auto, 1fr),
  [Bài], [Đáp án],
  [1], [Bước 1: AB 6/2 = 3 (1, 2); BC 9/3 = 3 (1, 3, 5); CD 4/3 ≈ 1,33 (1, 3, 4) → chốt *1 = 3 = 4 = 4/3 ≈ 1,33 Mbps*. \
    Bước 2: AB còn 6 − 4/3 = 14/3 cho 2; BC còn 9 − 8/3 = 19/3 cho 5 → *2 = 14/3 ≈ 4,67*; *5 = 19/3 ≈ 6,33 Mbps*.],
  [2], [Nhóm 1 (3 ≥ 2, tắc): 6·0,7 = 4,2 → dùng *4*. \
    Nhóm 2 (1 < 2, không tắc): 4,2 + 1 = 5,2 → dùng *5*. \
    Nhóm 3 (0): 6,2 → dùng *6*. \
    Nhóm 4 (2, tắc): 6,2·0,7 = 4,34 → dùng *4*.],
  [3], [Sau time-out W = 1; mỗi 3 báo nhận tăng 1: lên 6 cần 5 lần tăng → *15 báo nhận*.],
  [4], [Xem mục 1 (điều khiển luồng: phát ≤ khả năng thu, end-to-end/hop-by-hop; chống tắc nghẽn: lưu lượng vào ≤ khả năng mạng, truy nhập mạng/cấp phát bộ đệm). \
    Hai cơ chế: gói cảnh báo độc lập; bit chỉ thị tắc nghẽn trong báo nhận.],
)
