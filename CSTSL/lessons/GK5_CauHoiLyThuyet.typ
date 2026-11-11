// Biên dịch: typst compile GK5_CauHoiLyThuyet.typ
#let accent = rgb("#1f5fa8")
#let warn = rgb("#b5452b")
#let soft = rgb("#eef3fa")

#set document(title: "GK5 — Câu hỏi lý thuyết ngắn")
#set page(
  paper: "a4",
  margin: (left: 1.8cm, right: 2.6cm, top: 2cm, bottom: 1.8cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(9pt, fill: gray)
      CSTSL · GK5 — Câu hỏi lý thuyết #h(1fr) #counter(page).display()
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

// Thẻ hỏi – đáp: không cắt đôi qua trang
#let the(ma, hoi, dap) = block(
  breakable: false, width: 100%, above: 10pt, below: 10pt,
  inset: (left: 10pt, right: 9pt, y: 8pt), radius: 4pt,
  stroke: (left: 2.5pt + accent, rest: 0.5pt + luma(215)),
)[
  #text(accent, weight: "bold")[#ma. #hoi]
  #v(-3pt)
  #set par(spacing: 0.75em)
  #set list(spacing: 0.7em)
  #dap
]

// ================= TRANG BÌA =================
#align(center)[
  #v(1cm)
  #text(22pt, weight: "bold", fill: accent)[GK5 — Câu hỏi lý thuyết ngắn]
  #v(2pt)
  #text(10pt, fill: gray)[Cơ sở truyền số liệu · ET4070 · ôn giữa kỳ (theo slide thầy Nguyễn Xuân Dũng)]
]
#v(10pt)

Vì sao cần: slide thầy Dũng rải rất nhiều "Câu hỏi" và có mục "Câu hỏi cuối chương". Đề giữa kỳ hay có 1–2 câu hỏi ngắn kiểu này (mỗi câu trả lời 3–5 dòng). Tài liệu này cho sẵn *câu trả lời mẫu để chép*, không cần hiểu sâu.

#box-note("Cách học", accent)[
  + Đọc lướt cả bộ một lần (20 phút).
  + Che phần trả lời, tự nói lại ý chính (từ khoá in đậm) cho từng câu.
  + Chép phần "Từ khoá phải có" vào sổ tay.

  *Qua buổi khi:* nhìn câu hỏi nói được đủ từ khoá in đậm.
]

#box-note("Mẹo làm bài lý thuyết", warn)[
  Trả lời theo khung *định nghĩa → đặc điểm/công thức → ví dụ*. Đề giới hạn số dòng thì viết đúng từng ấy, thừa có thể bị trừ điểm.
]

// ================= PHẦN A =================
= Phần A — Chương 2: mô hình hoá và tiến trình ngẫu nhiên

#the("A1", [Mô hình hoá là gì? Vì sao phải mô hình hoá?])[
  - Mô hình hoá là quá trình *trừu tượng hoá và đơn giản hoá* hệ thống thực bằng cách *lược bỏ yếu tố không cần thiết*, mô tả hệ thống bằng các tham số và ràng buộc.
  - Cần mô hình hoá khi *không đo đạc trực tiếp được* hoặc muốn *dự đoán* hiệu năng khi hệ thống thay đổi (ví dụ: muốn biết xác suất rớt cuộc gọi $p_0 = f(n, lambda, t)$ để quyết định xây thêm bao nhiêu trạm, đặt ở đâu).
]

#the("A2", [Các phương pháp đánh giá hiệu năng?])[
  - *Đo đạc* (measurement): đo trên hệ thống thực đang chạy.
  - *Giả lập* (emulation): dựng hệ thống thử nghiệm (prototype) hoạt động giống hệ thống thực.
  - *Mô hình hoá mô phỏng* (simulation): mô hình phần mềm trên máy tính.
  - *Mô hình hoá phân tích* (analytical modeling): dùng công cụ toán học (ví dụ lý thuyết hàng đợi).
]

#the("A3", [Các bước mô hình hoá / quá trình đánh giá hiệu năng?])[
  - Đo đạc, thu thập dữ liệu hệ thống thực (lưu lượng vào, thời gian phục vụ…) → mô hình hoá → *phân tích, so sánh* (độ chính xác, độ phức tạp) → *hiệu chỉnh* (validation) → *đánh giá kết quả* cho hệ thống thực.
]

#the("A4", [Các tham số đánh giá hiệu năng?])[
  - *Thời gian*: thời gian thực hiện một yêu cầu, thời gian đáp ứng, thời gian lưu lại hệ thống.
  - *Không gian*: độ lớn hàng đợi/bộ đệm, bộ nhớ cần cho chương trình.
  - *Khác*: thông lượng, giá thành.
]

#the("A5", [Phân biệt sự kiện ngẫu nhiên và biến ngẫu nhiên.])[
  - *Sự kiện ngẫu nhiên* là *kết quả* của một phép thử ngẫu nhiên, thuộc tập mẫu $Omega$ (ví dụ: tung đồng xu được mặt ngửa).
  - *Biến ngẫu nhiên* là *ánh xạ* từ sự kiện ngẫu nhiên sang *số thực*: $X = f(e)$, $X: Omega -> RR$ (ví dụ: tung xúc xắc ra mặt 4 thì được 1000 điểm; $X$ = số điểm).
]

#the("A6", [Có mấy loại biến ngẫu nhiên? Dùng tham số gì để mô tả?])[
  - *Rời rạc*: tập giá trị hữu hạn hoặc vô hạn đếm được (số cuộc gọi đến tổng đài, điểm thi).
  - *Liên tục*: giá trị lấp kín một khoảng (nhiệt độ, tuổi thọ bóng đèn).
  - Tham số: *hàm mật độ xác suất* $f(x)$, *hàm phân bố xác suất* $F(x)$, *kỳ vọng* $E(x)$ (giá trị trung bình), *phương sai* $"Var"(x)$ và *độ lệch chuẩn* $sigma$ (độ phân tán quanh kỳ vọng; càng lớn càng bất định).
]

#the("A7", [Tiến trình ngẫu nhiên là gì? Khác biến ngẫu nhiên thế nào?])[
  - Tiến trình ngẫu nhiên là *tập hợp các biến ngẫu nhiên ${X(t)}$ thay đổi theo thời gian $t$* (một tập các hàm thời gian kèm luật xác suất).
  - Khác biệt: biến ngẫu nhiên là *một giá trị* ngẫu nhiên; tiến trình ngẫu nhiên là *một hàm theo thời gian*, mỗi thời điểm là một biến ngẫu nhiên. Ví dụ: lưu lượng Internet thay đổi theo giờ trong ngày.
  - Biến ngẫu nhiên *không đủ* mô tả mọi quá trình thực tế vì nhiều quá trình thay đổi theo thời gian → cần tiến trình ngẫu nhiên.
]

#the("A8", [Tiến trình đếm, tăng trưởng độc lập, tăng trưởng dừng?])[
  - *Đếm*: $N(0) = 0$, $N(t) >= 0$, không giảm theo $t$; $N(t) - N(s)$ = số sự kiện trong $(s, t]$. Ví dụ: số xe qua ngã tư.
  - *Tăng trưởng độc lập*: số sự kiện trong các khoảng thời gian *không chồng nhau là độc lập* với nhau.
  - *Tăng trưởng dừng*: số sự kiện chỉ phụ thuộc *độ dài* khoảng quan sát, không phụ thuộc thời điểm bắt đầu.
]

#the("A9", [Khái niệm tiến trình Poisson.])[
  $N(t)$ là tiến trình Poisson tham số $lambda > 0$ nếu:
  + *tăng trưởng độc lập*;
  + *tăng trưởng dừng*;
  + P(có đúng 1 sự kiện trong khoảng $h$ nhỏ) = $bold(lambda h + o(h))$;
  + P(có từ 2 sự kiện trở lên trong $h$) = $bold(o(h))$.

  Hệ quả: số sự kiện trong khoảng $t$ có *phân bố Poisson* tham số $lambda t$: $display(P(k) = ((lambda t)^k e^(-lambda t)) / k!)$ (Định lý 1); thời gian giữa hai sự kiện liên tiếp có *phân bố mũ*: $P(T <= t) = 1 - e^(-lambda t)$ (Định lý 2).
]

#the("A10", [Các tính chất của tiến trình Poisson.])[
  - *Kết hợp (ghép)*: tổng $n$ tiến trình Poisson độc lập $lambda_1 dots lambda_n$ là tiến trình Poisson với $lambda = sum lambda_i$.
  - *Phân tách*: tách tiến trình Poisson $lambda$ theo xác suất $p_1 dots p_n$ được các tiến trình Poisson $lambda p_1 dots lambda p_n$.
  - *Không nhớ* (của phân bố mũ): $P(x <= u + t | x > u) = P(x <= t)$ — đã chờ bao lâu không ảnh hưởng thời gian chờ tiếp.
]

#the("A11", [Ứng dụng của phân bố mũ và phân bố Poisson?])[
  - Phân bố *mũ*: mô tả *thời gian* trong hệ thống phục vụ (thời gian chiếm kênh cuộc gọi, thời gian phục vụ ở quầy thu ngân, thời gian giữa hai lần đến).
  - Phân bố *Poisson*: mô tả *số sự kiện* trong một đơn vị thời gian (số cuộc gọi đến tổng đài, số khách vào rạp).
]

// ================= PHẦN B =================
= Phần B — Chương 3: hệ thống phục vụ và hàng đợi

#the("B1", [Hệ thống phục vụ là gì? Ví dụ.])[
  Hệ thống *tiếp nhận yêu cầu ngẫu nhiên* từ bên ngoài, *xử lý/phục vụ* rồi cho yêu cầu *đi ra*. Mô hình hoá bằng hàng đợi gồm tiến trình tới $A(t)$, tiến trình phục vụ, tiến trình ra $D(t)$. Ví dụ: hệ thống giao thông, xếp hàng ở siêu thị, router trong mạng viễn thông.
]

#the("B2", [Ký hiệu Kendall A/B/c/k/N/SD.])[
  - A: tiến trình tới (M = Markov/Poisson, D = tất định, G = bất kỳ);
  - B: tiến trình phục vụ;
  - c: số server;
  - k: dung lượng/chiều dài hàng đợi (mặc định ∞);
  - N: quy mô nguồn (mặc định ∞);
  - SD: quy tắc phục vụ (FIFO, LIFO, Round Robin, SIRO, Priority; mặc định FIFO).

  Ví dụ M/M/c/∞: tới Poisson, phục vụ mũ, c server, hàng đợi vô hạn.
]

#the("B3", [Hệ thống đóng là gì?])[
  Hệ thống đóng (enclosed system) là hệ thống phục vụ mà *số yêu cầu đi vào = số yêu cầu đã đi ra + số đang nằm trong hệ thống*; hệ thống *không tự sinh ra* yêu cầu mới và *không huỷ bỏ* yêu cầu đang có. Hệ thống đóng có thể gồm một hay nhiều hàng đợi.
]

#the("B4", [Trong các hàng đợi M/M/1/1, M/M/1/∞, M/M/1/k, M/M/c/∞, M/M/c/c, M/M/c/k, M/G/1/∞, M/D/1/∞, hàng đợi nào là hệ thống đóng?])[
  - *Là hệ thống đóng (khi ổn định $bold(rho < 1)$)*: M/M/1/∞, M/M/c/∞, M/G/1/∞, M/D/1/∞ — hàng đợi vô hạn nên không yêu cầu nào bị huỷ.
  - *Không phải hệ thống đóng*: M/M/1/1, M/M/1/k, M/M/c/c, M/M/c/k — dung lượng hữu hạn nên có yêu cầu *bị từ chối* (bị huỷ) với xác suất $P_B$.
  - Ghi thêm: với các hệ có từ chối, phần yêu cầu *được chấp nhận* (tốc độ $lambda(1 - P_B)$) tạo thành một hệ thống đóng → vẫn áp dụng Little với $lambda(1 - P_B)$.
]

#the("B5", [Định lý Little phát biểu thế nào, đúng cho hệ thống có tính chất gì, khi nào áp dụng được?])[
  - $bold(N = lambda T)$: số yêu cầu trung bình trong hệ thống bằng tốc độ tới trung bình nhân thời gian lưu lại trung bình. Tương tự $N_q = lambda T_q$, $N_s = lambda T_s$.
  - Đúng cho *hệ thống đóng ở chế độ ổn định* (các giới hạn trung bình tồn tại), *không phụ thuộc* phân bố của tiến trình tới và tiến trình phục vụ, không phụ thuộc quy tắc phục vụ.
  - Little *chưa đủ* để đánh giá hiệu năng: biết $lambda$ vẫn còn hai ẩn $N$, $T$ → cần thêm mô hình tiến trình tới và phục vụ.
]

#the("B6", [Điều kiện ổn định của hàng đợi? Mật độ lưu lượng (tải) là gì?])[
  - Tải $rho = lambda \/ (c mu)$. Hệ ổn định khi $bold(0 < rho < 1)$ hay $bold(lambda < c mu)$; ngược lại hệ quá tải, hàng đợi tràn ($N, T -> infinity$ khi $rho -> 1$).
]

#the("B7", [Tiến trình sinh – tử dùng để làm gì? Mô tả một hàng đợi bằng tiến trình sinh – tử.])[
  - Là trường hợp đặc biệt của *chuỗi Markov*, dùng để mô tả chuyển trạng thái (trạng thái = số yêu cầu trong hệ), giúp *đơn giản hoá* việc tính xác suất trạng thái $p_n$ mà không phải giải phương trình vi phân. Đúng khi tiến trình tới là Poisson và thời gian phục vụ phân bố mũ.
  - Cách dùng:
    + xác định các trạng thái;
    + vẽ đồ hình trạng thái: từ $n$ sang $n+1$ với tốc độ $lambda_n$ (sinh), từ $n$ sang $n-1$ với tốc độ $mu_n$ (tử);
    + viết *phương trình cân bằng*: tốc độ đi ra khỏi trạng thái = tốc độ đi vào trạng thái;
    + dùng $sum p_n = 1$.
  - Ví dụ M/M/1: $lambda p_0 = mu p_1$; $(lambda + mu) p_n = lambda p_(n-1) + mu p_(n+1)$ → $p_n = rho^n (1 - rho)$.
]

#the("B8", [Đồ hình trạng thái của M/M/c/∞ khác M/M/1/∞ thế nào?])[
  - M/M/1: mọi mũi tên "tử" đều có tốc độ $mu$.
  - M/M/c: tốc độ "tử" từ trạng thái $n$ là $bold(n mu)$ *khi* #box[$bold(n <= c)$] (chỉ $n$ server bận) và $bold(c mu)$ *khi* #box[$bold(n >= c)$] (cả $c$ server bận). Mũi tên "sinh" vẫn là $lambda$.
]

#the("B9", [Vì sao M/M/1/k có $P_B > 0$ dù $rho < 1$?])[
  Vì yêu cầu đến *ngẫu nhiên* (Poisson): dù trung bình $lambda < mu$, vẫn có những lúc yêu cầu đến *dồn dập* làm bộ đệm hữu hạn bị đầy, yêu cầu đến lúc đó bị từ chối. Chỉ khi $k -> infinity$ thì $P_B -> 0$.
]

#the("B10", [Công thức Erlang B và Erlang C dùng để làm gì? Erlang là gì?])[
  - *Erlang C* (M/M/c, có chỗ chờ): xác suất một yêu cầu *phải đợi* — dùng cho *call center*.
  - *Erlang B* (M/M/c/c, không có chỗ chờ): xác suất một yêu cầu *bị từ chối* (nghẽn mạch) — dùng cho *tổng đài, nhóm kênh/trung kế*.
  - *Erlang*: đơn vị đo tải/lưu lượng trong một giờ = số cuộc gọi trong giờ × thời gian trung bình mỗi cuộc (giờ). Ví dụ 60 cuộc/giờ × 5 phút = 5 Erlang.
]

#the("B11", [Với cùng tải $rho$, hệ M/G/1 nào có hiệu năng tốt nhất? Với cùng tải, nút mạng hoạt động tốt nhất khi nào?])[
  Hệ có *phương sai thời gian phục vụ nhỏ nhất*, tức *M/D/1* (phục vụ cố định, #box[$sigma_s^2 = 0$]): $N_q$ của M/D/1 chỉ bằng *một nửa* M/M/1. Với nút chuyển mạch gói: tốt nhất khi các gói có *độ dài bằng nhau* (thời gian phục vụ $L\/C$ cố định).
]

#the("B12", [Định lý Burke. Tiến trình ra của hàng đợi đơn ổn định với tới Poisson $lambda$ là gì?])[
  Với hàng đợi M/M/1, M/M/c, M/M/∞ ổn định, tới Poisson $lambda$:
  + *tiến trình ra cũng là Poisson với tốc độ $lambda$* (thời gian giữa hai lần ra phân bố mũ tham số $lambda$);
  + số yêu cầu trong hệ tại $t$ *độc lập* với tiến trình ra trước $t$.

  Ý nghĩa: cho phép *tách mạng hàng đợi thành các hàng đợi đơn* để tính từng nút.
]

#the("B13", [Mạng hàng đợi là gì? Phân loại?])[
  - Tập hợp $k$ nút, mỗi nút là một hàng đợi đơn ($c_i$ server); yêu cầu vào/ra mạng tại một số nút. Rời nút $i$, yêu cầu có thể sang nút $j$ (xác suất $r_(i j)$), quay lại $i$, hoặc ra ngoài ($r_(i 0)$).
  - *Jackson đóng*: không có yêu cầu vào/ra ($gamma_i = 0$, $r_(i 0) = 0$ với mọi $i$), yêu cầu chỉ lưu thông trong mạng.
  - *Jackson mở*: có yêu cầu đi vào và đi ra.
  - *Nối tiếp*: trường hợp riêng của mạng mở, yêu cầu chỉ vào ở nút 1, đi lần lượt 1 → 2 → … → k rồi ra.
]

#the("B14", [Định lý Jackson (mạng mở).])[
  $lambda_i = gamma_i + sum_j r_(j i) lambda_j$; #h(0.6em) $rho_i = lambda_i \/ mu_i$; #h(0.6em) xác suất trạng thái $bold(p(n_1, dots, n_k) = product (1 - rho_i) rho_i^(n_i))$ — tức mỗi nút hoạt động như một hàng đợi *M/M/1 độc lập*. Từ đó $N = sum rho_i \/ (1 - rho_i)$, $T = N \/ gamma$.
]

#the("B15", [KIA là gì?])[
  Xấp xỉ độc lập Kleinrock: khi *ghép nhiều luồng Poisson* trên một đường truyền thì vẫn giữ được *tính độc lập* giữa các lần đến và thời gian phục vụ → coi mỗi liên kết như một hàng đợi M/M/1 độc lập. Dùng để tính trễ trung bình trong mạng nhiều luồng gói: $T = (1\/gamma) sum lambda_(i j) \/ (mu_(i j) - lambda_(i j))$.
]

#the("B16", [Trễ đầu cuối trong chuyển mạch gói gồm những thành phần nào? Trễ hàng đợi phụ thuộc vào gì?])[
  - $d_(e 2 e) = sum$ (thời gian phát $L\/C_i$ + trễ lan truyền $t_(p i) = d_i \/ v_p$ + trễ hàng đợi $t_(q i)$) trên các chặng ("store-and-forward": nút trung gian nhận hết gói rồi mới gửi tiếp).
  - Với một kết nối cố định, $L\/C$ và $t_p$ không đổi → trễ đầu cuối thay đổi chủ yếu do *trễ hàng đợi*, phụ thuộc *tải* của nút (lưu lượng nền — background traffic — gây tắc nghẽn), dung lượng kênh, độ dài và phân bố gói.
]

#the("B17", [Tại sao phải chia bản tin lớp trên thành nhiều gói trước khi truyền?])[
  *Giảm trễ đầu cuối* (các gói đi gối đầu nhau trên các chặng thay vì chờ cả bản tin tới mới gửi tiếp) và *tăng độ tin cậy* (lỗi chỉ phải gửi lại gói nhỏ bị lỗi).
]

// ================= PHẦN C =================
= Phần C — Câu hỏi tính nhẩm hay đi kèm (có đáp số)

#the("C1", [Router có trung bình 12 gói trong hệ, thông lượng 400 gói/s. Thời gian trung bình gói ở router?])[
  → $T = N \/ lambda = 12 \/ 400 = bold(30 "ms")$ (Little).
]

#the("C2", [Một hàng đợi có $lambda = 50$/s, $mu = 40$/s. Hệ có ổn định không?])[
  → $rho = 1","25 > 1$ → *không ổn định* (với hàng đợi vô hạn).
]

#the("C3", [Một M/M/1/k có $lambda = 50$/s, $mu = 40$/s có ổn định không?])[
  → *Có* — dung lượng hữu hạn nên luôn có trạng thái dừng; phần vượt quá bị từ chối.
]

#the("C4", [Đầu ra của một M/M/1 ổn định có $lambda = 30$/s là gì?])[
  → *Poisson 30/s* (Burke).
]

// ================= SỔ TAY =================
= Sổ tay phòng thi — trang 5

#text(fill: gray)[Từ khoá phải có — chép nguyên vào sổ tay.]

#set text(12.5pt)
#set par(leading: 0.8em, spacing: 1.2em)
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
#set text(11.5pt)
#set par(leading: 0.75em, spacing: 1.1em)

// ================= BÀI TẬP =================
= Bài tự luyện — viết thẳng vào ô chấm

#text(fill: gray)[Viết câu trả lời vào ô chấm, mỗi câu tối đa 5 dòng. Làm hết rồi mới lật trang đáp án.]

#bai(1, h: 4.5cm)[Phân biệt sự kiện ngẫu nhiên và biến ngẫu nhiên. Cho ví dụ.]
#bai(2, h: 4.5cm)[Nêu khái niệm tiến trình Poisson và hai tính chất ghép/tách.]
#bai(3, h: 4.5cm)[Hệ thống đóng là gì? M/M/1/k có phải hệ thống đóng không? Khi đó áp dụng định lý Little thế nào?]
#bai(4, h: 4.5cm)[Định lý Little đúng cho hệ thống nào? Phát biểu và cho ví dụ ý nghĩa.]
#bai(5, h: 4.5cm)[Tiến trình sinh – tử dùng để làm gì? Viết phương trình cân bằng cho hàng đợi M/M/1/3.]
#bai(6, h: 4.5cm)[Phân biệt công thức Erlang B và Erlang C (mô hình, ý nghĩa, ứng dụng).]
#bai(7, h: 4.5cm)[Phát biểu định lý Burke và nêu ý nghĩa với mạng hàng đợi.]
#bai(8, h: 4.5cm)[Vì sao cùng tải $rho$ thì M/D/1 cho trễ nhỏ hơn M/M/1?]

// ================= ĐÁP ÁN =================
= Đáp án gợi ý

#table(
  columns: (auto, 1fr),
  [Bài], [Đáp án],
  [1–4, 6–8], [Xem câu A5, A9–A10, B3–B4, B5, B10, B12, B11 ở trên.],
  [5], [Dùng để tính xác suất trạng thái (xem B7). M/M/1/3 (trạng thái 0, 1, 2, 3): \
    $lambda p_0 = mu p_1$; \
    $(lambda + mu) p_1 = lambda p_0 + mu p_2$; \
    $(lambda + mu) p_2 = lambda p_1 + mu p_3$; \
    $lambda p_2 = mu p_3$; \
    và $p_0 + p_1 + p_2 + p_3 = 1$.],
)
