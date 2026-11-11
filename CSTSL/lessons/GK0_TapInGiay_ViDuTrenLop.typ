// Biên dịch: typst compile GK0_TapInGiay_ViDuTrenLop.typ
// Tập IN GIẤY mang vào phòng thi giữa kỳ — không có ô viết tay, không có bài tự luyện.
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let accent = rgb("#1f5fa8")
#let warn = rgb("#b5452b")
#let soft = rgb("#eef3fa")

#set document(title: "GK0 — Tập in giấy: ví dụ trên lớp + bảng công thức")
#set page(
  paper: "a4",
  margin: (x: 1.5cm, top: 1.7cm, bottom: 1.5cm),
  header: context [
    #set text(8.5pt, fill: luma(90))
    CSTSL · GK0 — Tập in giấy: ví dụ trên lớp + bảng công thức #h(1fr)
    Trang #counter(page).display("1 / 1", both: true)
    #v(-6pt)
    #line(length: 100%, stroke: 0.4pt + luma(150))
  ],
)
#set text(font: "Noto Sans", size: 10.5pt, lang: "vi")
#show math.equation: set text(font: "New Computer Modern Math")
#set par(leading: 0.62em, spacing: 0.75em)
#set list(spacing: 0.5em, indent: 2pt, body-indent: 5pt)
#set enum(spacing: 0.5em, indent: 2pt, body-indent: 5pt)
#set table(stroke: 0.5pt + gray, inset: 5pt)

#show heading.where(level: 1): it => block(
  width: 100%, fill: accent, inset: (x: 8pt, y: 5pt), radius: 3pt,
  above: 12pt, below: 8pt, sticky: true,
  text(white, size: 12.5pt, weight: "bold", it.body))
#show heading.where(level: 2): it => block(sticky: true, above: 12pt, below: 6pt,
  text(accent, size: 11.5pt, weight: "bold", it.body))
#show heading.where(level: 3): it => block(above: 0pt, below: 4pt,
  text(accent, size: 10.5pt, weight: "bold", it.body))

// Hộp ghi chú (giống GK1–GK5) — dùng cho phần C, D
#let box-note(title, color, body) = block(
  width: 100%, inset: (x: 7pt, y: 5pt), radius: 3pt, stroke: (left: 3pt + color), fill: color.lighten(90%),
  breakable: false, above: 5pt, below: 5pt,
  [#text(color, weight: "bold", title) \ #body],
)

// Mục lục: mỗi mục đặt một metadata <toc>
#let toc-mark(label, level: 1) = [#metadata((label: label, level: level)) <toc>]

// Khối một ví dụ: khung đề bài + lời giải bên dưới
#let vd(id, title, short: none, breakable: false, de, body) = block(
  width: 100%, breakable: breakable, above: 10pt, below: 4pt,
)[
  #toc-mark(if short == none { id + " — " + title } else { id + " — " + short }, level: 2)
  #block(width: 100%, inset: (x: 7pt, y: 6pt), radius: 3pt, stroke: 0.9pt + accent, fill: soft,
    below: 6pt, sticky: true)[
    #heading(level: 3)[#id — #title]
    #de
  ]
  #pad(left: 4pt, body)
]

// ================= TRANG 1: BÌA + THÔNG TIN THI + MỤC LỤC =================
#align(center)[
  #text(9.5pt, fill: luma(80))[Cơ sở truyền số liệu · ET4070 · ôn giữa kỳ (theo slide thầy Nguyễn Xuân Dũng)]
  #v(-2pt)
  #text(18pt, weight: "bold", fill: accent)[GK0 — Tập IN GIẤY mang vào phòng thi giữa kỳ]
  #v(-4pt)
  #text(11pt)[Toàn bộ ví dụ trên lớp (lời giải tự luận) + bảng công thức]
]
#v(2pt)

#block(width: 100%, inset: 8pt, radius: 3pt, stroke: 1.2pt + accent, breakable: false)[
  #text(accent, weight: "bold")[Thông tin thi] (thầy Nguyễn Xuân Dũng báo):
  *100% tự luận, 60 phút, được dùng tài liệu giấy (photo hoặc ghi chép), thi đến hết phần hàng đợi; làm được các ví dụ trên lớp sẽ có lợi thế.* \
  → Tập này để *in ra giấy* (không dùng được tablet trong phòng thi). Gồm: (A) cách trình bày bài tự luận; (B) 16 ví dụ/bài tập trong slide và trên lớp của thầy, giải đầy đủ; (C) bảng công thức gộp; (D) từ khoá lý thuyết.
]

#block(width: 100%, above: 10pt, below: 6pt, text(accent, size: 11.5pt, weight: "bold")[Mục lục nhanh])
#context {
  let items = query(<toc>)
  set text(9.5pt)
  set par(leading: 0.5em, spacing: 0.42em)
  columns(2, gutter: 16pt, for it in items {
    let v = it.value
    let p = it.location().page()
    let lbl = if v.level == 1 { strong(v.label) } else { h(8pt) + v.label }
    block(width: 100%, above: if v.level == 1 { 7pt } else { 3pt }, below: 0pt,
      grid(columns: (1fr, auto), column-gutter: 3pt,
        [#lbl #box(width: 1fr, repeat(text(luma(140))[.#h(2pt)]))],
        if v.level == 1 { strong(str(p)) } else { str(p) }))
  })
}

// ================= A =================
= A. Cách trình bày một bài tự luận hàng đợi (5 dòng ăn điểm)
#toc-mark("A. Cách trình bày bài tự luận (5 dòng)")

+ *Mô hình:* gọi tên theo Kendall và nói lý do (số server $c$, chỗ chờ → $k$). Ví dụ: "1 nhân viên, 10 chỗ chờ → M/M/1/11".
+ *Tham số:* viết $lambda$, $mu$ *cùng đơn vị*; tính $a = lambda\/mu$, $rho = lambda\/(c mu)$.
+ *Công thức:* ghi công thức dạng chữ (kèm số công thức trong slide nếu nhớ, ví dụ (3.54)).
+ *Thay số* và ra kết quả *có đơn vị*.
+ *Kết luận* một câu trả lời đúng câu hỏi (đạt/không đạt chỉ tiêu, chọn phương án nào…).

Đề ghi "không dùng công thức cho sẵn" → phải vẽ đồ hình sinh – tử và viết phương trình cân bằng (xem VD 7).

// ================= B =================
= B. Toàn bộ ví dụ trên lớp và bài tập trong slide thầy Dũng
#toc-mark("B. Ví dụ trên lớp + bài tập slide")

== Chương 2 — Tiến trình Poisson

#vd("VD 1", "(ch.2 tr. 44) — Tổng đài 1080", short: "Tổng đài 1080 (Poisson)")[
  Trung bình 10 cuộc/phút, Poisson. Xác suất có 15 cuộc trong 2 phút?
][
  - Định lý 1: số sự kiện trong khoảng $t$ tuân theo phân bố Poisson tham số $lambda t$.
  - $lambda t = 10 dot 2 = 20$.
  - $P\{N = 15\} = ((lambda t)^k e^(-lambda t)) / k! = (20^15 dot e^(-20)) / (15!) approx$ *0,0516*.
]

#vd("VD 2", "(ch.2 tr. 46) — Xe buýt", short: "Xe buýt (phân bố mũ)")[
  Tần suất 5 phút/chuyến, Poisson. Vừa lỡ một chuyến. Xác suất đợi chuyến sau ít hơn 3 phút?
][
  - Định lý 2: thời gian giữa hai sự kiện liên tiếp phân bố mũ: $P\{T <= t\} = 1 - e^(-lambda t)$.
  - 5 phút/chuyến → $lambda = 1\/5$ chuyến/phút.
  - $P\{T < 3\} = 1 - e^(-3\/5) = 1 - e^(-"0,6") approx$ *0,451*.
]

#grid(columns: (1fr, 1fr), column-gutter: 10pt,
  vd("VD 3", "(ch.2 tr. 48) — Ghép luồng", short: "Ghép luồng Poisson")[
    Ô tô 6 xe/phút, xe máy 9 xe/phút, đều Poisson.
  ][
    → phương tiện qua nút: Poisson với $lambda = 6 + 9 =$ *15 phương tiện/phút*.
  ],
  vd("VD 4", "(ch.2 tr. 49) — Tách luồng", short: "Tách luồng Poisson")[
    12 bé/tuần, 55% trai, 45% gái.
  ][
    → bé trai: Poisson $12 dot "0,55" =$ *6,6 bé/tuần*; bé gái: $12 dot "0,45" =$ *5,4 bé/tuần*.
  ],
)

== Chương 3 — Hàng đợi đơn

#vd("VD 5", "(ch.3 tr. 29) — ATM, M/M/1/1", short: "ATM, M/M/1/1")[
  1 máy ATM; 10 người/giờ (Poisson); mỗi người trung bình 3 phút. Xác suất một người đến nhưng không được phục vụ?
][
  - Mô hình: 1 server, không có hàng đợi ($Q = 0$) → M/M/1/1.
  - $lambda = 10$ người/giờ; $mu = 60\/3 = 20$ người/giờ.
  - (3.25): $P_B = p_1 = lambda / (lambda + mu) = 10 / 30 =$ *1/3 ≈ 0,333*.
  - Thêm: $N = p_1 = 1\/3$; $T = 1\/mu = 3$ phút.
]

#vd("VD 6", "(ch.3 tr. 34) — Quầy tính tiền siêu thị, M/M/1/∞", short: "Siêu thị, M/M/1/∞")[
  40 khách/giờ (Poisson); phục vụ phân bố mũ trung bình 1 phút; 1 quầy; đủ chỗ xếp hàng. Tìm thời gian chờ trung bình; xác suất từ lúc vào xếp hàng đến lúc trả tiền xong không quá 1,5 phút.
][
  - Mô hình: M/M/1/∞. $lambda = 40\/60 = 2\/3$ khách/phút; $mu = 1$ khách/phút; $rho = 2\/3 < 1$ → ổn định.
  - (3.42): $T_q = (1\/mu) dot rho / (1 - rho) = 1 dot (2\/3) / (1\/3) =$ *2 phút*.
  - (3.43): $P\{T <= t\} = 1 - e^(-(mu - lambda) t)$ → $P\{T <= "1,5"\} = 1 - e^(-(1\/3) dot "1,5") = 1 - e^(-"0,5") approx$ *0,393*.
  - Thêm: $T = 1\/(mu - lambda) = 3$ phút; $N = rho\/(1 - rho) = 2$; $N_q = rho^2\/(1 - rho) = 4\/3$.
]

#vd("VD 7", "(bài thầy cho trên lớp) — M/M/1/3, tự lập phương trình", short: "M/M/1/3 tự lập phương trình")[
  Đến 2 cuộc/phút; rời hệ thống 4 cuộc/phút. Biểu diễn quá trình sinh – tử; tự tìm quan hệ giữa các xác suất và tính (không dùng công thức cho sẵn); số cuộc gọi trung bình; thời gian trung bình một cuộc gọi trong hệ thống.
][
  - Trạng thái 0, 1, 2, 3 (số cuộc gọi trong hệ). Đồ hình: 0 ⇄ 1 ⇄ 2 ⇄ 3; mũi tên sang phải $lambda = 2$, sang trái $mu = 4$.
  #align(center, block(above: 4pt, below: 6pt, diagram(
    spacing: (22mm, 10mm), node-stroke: 1pt + accent, node-fill: white,
    edge-stroke: 0.9pt, mark-scale: 90%,
    node((0, 0), $0$, shape: circle, inset: 7pt),
    node((1, 0), $1$, shape: circle, inset: 7pt),
    node((2, 0), $2$, shape: circle, inset: 7pt),
    node((3, 0), $3$, shape: circle, inset: 7pt),
    ..range(3).map(i => (
      edge((i, 0), (i + 1, 0), "-|>", $lambda = 2$, bend: 35deg, label-side: left),
      edge((i + 1, 0), (i, 0), "-|>", $mu = 4$, bend: 35deg, label-side: left),
    )).flatten(),
  )))
  - Phương trình cân bằng (tốc độ ra = tốc độ vào):
    - Trạng thái 0: $lambda p_0 = mu p_1 arrow.r 2 p_0 = 4 p_1$.
    - Trạng thái 1: $(lambda + mu) p_1 = lambda p_0 + mu p_2 arrow.r 6 p_1 = 2 p_0 + 4 p_2$.
    - Trạng thái 2: $(lambda + mu) p_2 = lambda p_1 + mu p_3 arrow.r 6 p_2 = 2 p_1 + 4 p_3$.
    - Trạng thái 3: $mu p_3 = lambda p_2 arrow.r 4 p_3 = 2 p_2$.
  - Suy ra: $p_1 = p_0\/2$; $p_2 = p_0\/4$; $p_3 = p_0\/8$.
  - Chuẩn hoá: $p_0 (1 + 1\/2 + 1\/4 + 1\/8) = 1$ → *p#sub[0] = 8/15 ≈ 0,533; p#sub[1] = 4/15 ≈ 0,267; p#sub[2] = 2/15 ≈ 0,133; p#sub[3] = 1/15 ≈ 0,067*.
  - $N = sum n dot p_n = (1 dot 4 + 2 dot 2 + 3 dot 1)\/15 = 11\/15 approx$ *0,733 cuộc gọi*.
  - Xác suất từ chối $P_B = p_3 = 1\/15$; tốc độ vào thực tế $lambda(1 - P_B) = 2 dot 14\/15 = 28\/15$ cuộc/phút.
  - Little (3.62): $T = N\/[lambda(1 - P_B)] = (11\/15)\/(28\/15) = 11\/28 approx$ *0,393 phút ≈ 23,6 giây*.
]

#vd("VD 8", "(ch.3 tr. 43) — Bãi gửi xe máy, M/M/1/k", short: "Bãi gửi xe, M/M/1/k")[
  1 nhân viên; chỗ cho 10 khách đợi; 3 khách/phút (Poisson); xử lý trung bình 15 giây/xe (mũ). Hỏi: xác suất khách được phục vụ ngay; thời gian trung bình phải đợi đến khi được phục vụ; xác suất bãi bị tắc do người tới quá đông.
][
  - Mô hình: 1 server, hàng đợi $Q = 10$ → $k = Q + 1 = 11$ → M/M/1/11.
  - $lambda = 3$ khách/phút; $mu = 60\/15 = 4$ khách/phút; $rho = "0,75"$. $rho^11 approx "0,04224"$; $rho^12 approx "0,03168"$.
  - (3.52): $p_0 = (1 - rho) / (1 - rho^(k+1)) = "0,25" / (1 - "0,03168") approx$ *0,258* → xác suất được phục vụ ngay (hệ đang rỗng) ≈ 25,8%.
  - (3.54): $P_B = p_11 = rho^11 dot p_0 = "0,04224" dot "0,258" approx$ *0,0109* → xác suất bãi bị tắc ≈ 1,09%.
  - (3.55): $N = rho / (1 - rho) - ((k + 1) rho^(k+1)) / (1 - rho^(k+1)) = 3 - 12 dot "0,03168"\/"0,96832" approx "2,607"$.
  - $N_q = N - (1 - p_0) = "2,607" - "0,742" approx "1,866"$.
  - (3.63): $T_q = N_q\/[lambda(1 - P_B)] = "1,866"\/(3 dot "0,9891") approx$ *0,629 phút ≈ 37,7 giây*.
]

#vd("VD 9", "(ch.3 tr. 51) — Call center, M/M/c/∞ (Erlang C)", short: "Call center, Erlang C")[
  3 điện thoại viên; trong 10 phút trung bình 3 khách gọi (Poisson); mỗi cuộc trung bình 3 phút (mũ); bận thì khách nghe nhạc chờ. Xác suất khách được phục vụ ngay? Chỉ tiêu "không quá 10% khách phải đợi" có đạt không; nếu không cần bao nhiêu bàn?
][
  - Mô hình: $c = 3$, hàng đợi vô hạn → M/M/3/∞.
  - $lambda = 3\/10 = "0,3"$ cuộc/phút; $mu = 1\/3$ cuộc/phút; $a = lambda\/mu = "0,9"$; $rho = a\/c = "0,3" < 1$.
  - (3.76): $p_0 = 1\/[sum_(n=0)^2 a^n\/n! + a^3\/(3!(1 - rho))] = 1\/[(1 + "0,9" + "0,405") + "0,729"\/(6 dot "0,7")] = 1\/("2,305" + "0,1736") approx "0,4035"$.
  - (3.79) Erlang C: $C(c, a) = [a^c\/(c!(1 - rho))] dot p_0 = "0,1736" dot "0,4035" approx$ *0,070* (7% khách phải đợi).
  - (3.80): xác suất được phục vụ ngay $= 1 - C =$ *0,930*.
  - 7% ≤ 10% → *chỉ tiêu đạt*, không cần tăng số bàn. (Nếu không đạt: thử $c = 4, 5…$ đến khi $C <= 10%$; $c = 4$ cho $C approx "0,014"$.)
]

#vd("VD 10", "(ch.3 tr. 55) — Đơn vị Erlang", short: "Đơn vị Erlang")[
  Tổng đài 1 giờ có 60 cuộc, mỗi cuộc trung bình 5 phút.
][
  → tải $E = 60 dot 5\/60 =$ *5 Erlang*.
]

#vd("VD 11", "(ch.3 tr. 57) — Tổng đài cơ quan, M/M/c/c (Erlang B)", short: "Tổng đài cơ quan, Erlang B")[
  3 đường trung kế; gọi ra 6 cuộc/giờ, gọi vào 9 cuộc/giờ (đều Poisson); chiếm kênh trung bình 3 phút (mũ). Tính tải theo Erlang; xác suất một cuộc gọi bị từ chối do nghẽn mạch.
][
  - Mô hình: $c = 3$, không có hàng đợi → M/M/3/3.
  - Ghép hai luồng Poisson: $lambda = 6 + 9 = 15$ cuộc/giờ; $mu = 60\/3 = 20$ cuộc/giờ.
  - Tải: $a = lambda\/mu = 15 dot 3\/60 =$ *0,75 Erlang*.
  - (3.91) Erlang B: $B(c, a) = (a^c\/c!)\/sum_(i=0)^c a^i\/i! = ("0,75"^3\/6)\/(1 + "0,75" + "0,28125" + "0,07031") = "0,07031"\/"2,10156" approx$ *0,0335 (3,35%)*.
]

#vd("VD 12", "(ch.3 tr. 61, thầy chữa trên lớp) — CPU 4 nhân, M/M/c và M/M/c/k", short: "CPU 4 nhân, M/M/4 và M/M/4/14", breakable: true)[
  20 task/µs (Poisson); xử lý trung bình 0,08 µs (mũ). \
  *TH1* — bộ nhớ đệm đủ lớn. Tính thời gian từ lúc nhận yêu cầu đến khi hoàn thành; lượng bộ nhớ trung bình các tác vụ chiếm trong RAM. \
  *TH2* — bộ nhớ đệm chỉ chứa tối đa 10 tác vụ. Tính xác suất một tác vụ bị từ chối; xác suất một tác vụ phải đợi mà không được phục vụ ngay.
][
  #block(breakable: false, below: 6pt)[
  #text(accent, weight: "bold")[TH1 — bộ nhớ đệm đủ lớn]
  - Mô hình: M/M/4/∞. $lambda = 20$; $mu = 1\/"0,08" = "12,5"$ task/µs; $a = lambda\/mu = "1,6"$; $rho = lambda\/(c mu) = "0,4"$.
  - $p_0 = 1\/[(1 + "1,6" + "1,28" + "0,6827") + "1,6"^4\/(4! dot "0,6")] = 1\/("4,5627" + "0,4551") approx$ *0,1993*.
  - $C(c, a) = "0,4551" dot "0,1993" approx "0,0907"$. (Trên bảng lớp ghi 0,10602 — nên hỏi lại; bấm theo (3.79) ra 0,0907.)
  - $N_q = C dot rho\/(1 - rho) = "0,0907" dot "0,6667" approx "0,0605"$.
  - (3.86): $T = 1\/mu + C\/(c mu - lambda) = "0,08" + "0,0907"\/30 approx$ *0,083 µs*.
  - (3.83): $N = a + N_q = "1,6" + "0,0605" approx$ *1,66 tác vụ* (bảng lớp ghi 1,67).
  ]
  #block(breakable: false)[
  #text(accent, weight: "bold")[TH2 — bộ nhớ đệm chỉ chứa tối đa 10 tác vụ]
  - Mô hình (theo thầy): $k = 10 + 4 = 14$ → *M/M/4/14*.
  - (3.96): $P_B = p_14 = [a^c\/c!] dot rho^(k-c) dot p_0 = ("1,6"^4\/24) dot "0,4"^10 dot "0,1993" approx$ *5,7·10⁻⁶* (bảng lớp ghi ≈ 8,8·10⁻⁷ — nên hỏi lại; cả hai đều rất nhỏ).
  - Xác suất phải đợi (cách thầy): $p = 1 - (p_0 + p_1 + p_2 + p_3)$ với $p_1 = a dot p_0 = "0,3189"$; $p_2 = a^2\/2 dot p_0 = "0,2551"$; $p_3 = a^3\/6 dot p_0 = "0,1361"$ → $p = 1 - "0,9093" approx$ *0,09*.
  ]
]

#vd("BT 3.1", "M/M/∞", short: "M/M/∞")[
  Mọi yêu cầu được phục vụ ngay.
][
  Trạng thái $n$: sinh $lambda$, tử $n mu$ → $p_n = (a^n\/n!) dot p_0$; $sum p_n = 1$ → $p_0 = e^(-a)$ → *p#sub[n] = a#super[n]e#super[−a]/n!* (phân bố Poisson tham số $a = lambda\/mu$). *N = a; T = 1/μ; N#sub[q] = 0; T#sub[q] = 0; P#sub[B] = 0*; luôn ổn định.
]

#vd("BT 3.2", "Chọn công ty sửa máy", short: "Chọn công ty sửa máy")[
  Trung bình 3 máy hỏng/ngày 8 h (Poisson); thiệt hại 500.000đ cho mỗi máy hỏng; sửa lần lượt, thời gian sửa phân bố mũ. Công ty 1: 2 h/máy, phí 600.000đ/ngày. Công ty 2: 80 phút/máy, phí 800.000đ/ngày.
][
  - Mỗi phương án là một hàng đợi M/M/1; $lambda = 3\/8 = "0,375"$ máy/giờ.
  - Công ty 1: $mu = "0,5"$; $rho = "0,75"$; $N = rho\/(1 - rho) = 3$ máy → chi phí = 600.000 + 3·500.000 = *2.100.000đ/ngày*.
  - Công ty 2: $mu = "0,75"$; $rho = "0,5"$; $N = 1$ máy → chi phí = 800.000 + 1·500.000 = *1.300.000đ/ngày*.
  - Kết luận: *chọn công ty 2*. (Ghi rõ cách hiểu: 500.000đ là thiệt hại cho mỗi máy đang nằm hỏng.)
]

== Chương 3 — Mạng hàng đợi

#vd("VD 13", "(ch.3 tr. 87) — Mạng mở 4 nút", short: "Mạng mở 4 nút (Jackson)")[
  $gamma_4 = 4$ yêu cầu/s vào nút 4; $1\/mu_1 = "0,03"$; $1\/mu_2 = "0,04"$; $1\/mu_3 = "0,05"$; $1\/mu_4 = "0,06"$ (s); $r_41 = 1$; $r_12 = r_13 = "0,5"$; $r_21 = 1$; $r_31 = "0,6"$; $r_30 = "0,4"$.
  #align(center, block(above: 5pt, below: 2pt, image("img/gk3_mau2_dung_4nut.png", width: 70%)))
][
  - Phương trình lưu lượng $lambda_i = gamma_i + sum r_(j i) lambda_j$: $lambda_4 = 4$; $lambda_1 = lambda_4 + lambda_2 + "0,6" lambda_3$; $lambda_2 = lambda_3 = "0,5" lambda_1$ → $"0,2" lambda_1 = 4$ → *λ#sub[1] = 20; λ#sub[2] = λ#sub[3] = 10; λ#sub[4] = 4* (yêu cầu/s).
  - $rho_i = lambda_i\/mu_i$: $rho_1 = "0,6"$; $rho_2 = "0,4"$; $rho_3 = "0,5"$; $rho_4 = "0,24"$ (đều $< 1$).
  - $N_i = rho_i\/(1 - rho_i)$: *N#sub[1] = 1,5; N#sub[2] = 0,667; N#sub[3] = 1; N#sub[4] = 0,316*.
  - Xác suất hệ thống không có yêu cầu nào: $product (1 - rho_i) = "0,4" dot "0,6" dot "0,5" dot "0,76" =$ *0,0912*.
  - Xác suất cả hệ có đúng 1 yêu cầu: $"0,0912" dot ("0,6" + "0,4" + "0,5" + "0,24") approx$ *0,159*.
  - $N = sum N_i approx$ *3,48*; $T = N\/gamma_4 = "3,48"\/4 approx$ *0,871 s*.
  - Giữ $r_30$, $r_31$; điều kiện $r_12$, $r_13$ để ổn định: $lambda_1 = 10\/r_13$; $lambda_2 = 10(1 - r_13)\/r_13$; $rho_1 = "0,3"\/r_13 < 1 arrow.r r_13 > "0,3"$; $rho_2 = "0,4"(1 - r_13)\/r_13 < 1 arrow.r r_13 > "0,286"$ → *r#sub[13] > 0,3; r#sub[12] < 0,7*.
]

#vd("BT 3.3", "Mạng LAN có ARQ", short: "Mạng LAN có ARQ")[
  S1 → R1 → R2 → D; S2 → R2. $lambda_1 = 240$ gói/phút = 4 gói/s; $lambda_2 = 120$ gói/phút = 2 gói/s; $1\/mu_1 = "0,2"$ s; $1\/mu_2 = "0,1"$ s; liên kết R2 → D lỗi gói $p_e =$ 10%; ARQ giữa D và S1, S2.
][
  - Gói lỗi phải gửi lại từ nguồn → lưu lượng thực qua các nút tăng $1\/(1 - p_e)$: $lambda_(R 1) = 4\/"0,9" approx "4,444"$; $lambda_(R 2) = 6\/"0,9" approx "6,667"$ gói/s.
  - $mu_1 = 5$; $mu_2 = 10$ → $rho_1 approx "0,889"$; $rho_2 approx "0,667"$.
  - Số gói trung bình: $N_1 =$ *8*; $N_2 =$ *2* (tổng 10 gói).
  - Trễ tại nút: $T_1 = 1\/(5 - "4,444") =$ *1,8 s*; $T_2 = 1\/(10 - "6,667") =$ *0,3 s*.
  - S1 → D: $(T_1 + T_2)\/(1 - p_e) = "2,1"\/"0,9" approx$ *2,33 s*; S2 → D: $"0,3"\/"0,9" approx$ *0,33 s*.
]

// ================= C =================
= C. Bảng công thức gộp (nguyên các trang "Sổ tay phòng thi" 1–4 của GK1–GK4)
#toc-mark("C. Bảng công thức gộp (sổ tay 1–4)")

#set text(10pt)
#set par(leading: 0.6em)

== C1. Sổ tay phòng thi — trang 1 (GK1: Poisson, phân bố mũ, M/M/1)
#toc-mark("C1. Poisson · mũ · M/M/1", level: 2)

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
#box-note("BỔ SUNG (slide thầy Dũng)", accent)[
  GHÉP/TÁCH POISSON: ghép → $lambda = sum lambda_i$ (vẫn Poisson); \
  #h(1em) tách theo xác suất $p_i$ → $lambda dot p_i$ (vẫn Poisson) \
  "$x$ phút/chuyến" = thời gian TB → $lambda = 1\/x$ \
  M/M/1: $P(T <= t) = 1 - e^(-(mu - lambda) t)$ #h(1.5em) $P(T_q <= t) = 1 - rho dot e^(-(mu - lambda) t)$ \
  Phân bố mũ: $E = 1\/lambda$, $"Var" = 1\/lambda^2$; #h(0.5em) Poisson: $E = "Var" = alpha$; #h(0.5em) Nhị thức: $E = n p$, $"Var" = n p(1 - p)$
]

== C2. Sổ tay phòng thi — trang 2 (GK2: hàng đợi đơn)
#toc-mark("C2. Hàng đợi đơn (M/M/1/k, Erlang B/C…)", level: 2)

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

== C3. Sổ tay phòng thi — trang 3 (GK3: phương trình lưu lượng)
#toc-mark("C3. Phương trình lưu lượng · ổn định", level: 2)

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

== C4. Sổ tay phòng thi — trang 4 (GK4: hiệu năng mạng)
#toc-mark("C4. Hiệu năng mạng · KIA · ARQ", level: 2)

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

// ================= D =================
= D. Từ khoá lý thuyết (nguyên trang sổ tay 5 của GK5)
#toc-mark("D. Từ khoá lý thuyết (sổ tay 5)")

#box-note("CHƯƠNG 2 — MÔ HÌNH HOÁ, BIẾN NGẪU NHIÊN", accent)[
  Mô hình hoá: trừu tượng + đơn giản hoá, lược bỏ yếu tố không cần \
  4 phương pháp: đo đạc, giả lập, mô phỏng, phân tích \
  Sự kiện NN = kết quả phép thử; #h(0.6em) biến NN = ánh xạ kết quả → số thực \
  Biến rời rạc / liên tục; tham số: mật độ $f(x)$, hàm phân bố $F(x)$, $E$, $"Var"$, $sigma$ \
  Tiến trình NN = tập biến NN theo thời gian
]
#box-note("POISSON", accent)[
  tăng trưởng độc lập + dừng + $P(1 "trong" h) = lambda h + o(h)$ + $P(>= 2) = o(h)$ \
  → số sự kiện: Poisson($lambda t$); khoảng cách: mũ($lambda$); ghép $sum lambda$; tách $lambda p$; không nhớ
]
#box-note("HỆ THỐNG ĐÓNG · LITTLE", accent)[
  Hệ thống đóng: vào = ra + đang ở; không sinh, không huỷ \
  ĐÓNG: /∞ (M/M/1, M/M/c, M/G/1, M/D/1) khi $rho < 1$; \
  KHÔNG: /1/1, /1/k, /c/c, /c/k \
  Little $N = lambda T$: hệ đóng, ổn định, mọi phân bố
]
#box-note("HÀNG ĐỢI ĐƠN", accent)[
  Sinh–tử: chuỗi Markov, cân bằng ra = vào; #h(0.6em) M/M/c: tử $n mu$ ($n <= c$), $c mu$ ($n >= c$) \
  Erlang B = từ chối (tổng đài); #h(0.6em) Erlang C = phải đợi (call center) \
  M/D/1 tốt nhất cùng $rho$ ($sigma^2 = 0$)
]
#box-note("MẠNG HÀNG ĐỢI · TRỄ", accent)[
  Burke: ra = Poisson $lambda$ → tách mạng; #h(0.6em) Jackson: $p = product (1 - rho_i) rho_i^(n_i)$ \
  Jackson đóng / mở / nối tiếp; #h(0.6em) KIA: ghép Poisson giữ độc lập \
  $d_(e 2 e) = sum (L\/C + t_p + t_q)$; #h(0.6em) chia gói: giảm trễ, tăng tin cậy
]
#box-note("Mẹo làm bài", warn)[
  Khung: *định nghĩa → đặc điểm/công thức → ví dụ*. Đề giới hạn số dòng thì viết đúng từng ấy.
]
