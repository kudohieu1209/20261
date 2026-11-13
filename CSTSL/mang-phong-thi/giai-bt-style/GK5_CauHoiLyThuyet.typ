#import "style.typ": *
// Biên dịch trong thư mục này: typst compile --root .. GK5_CauHoiLyThuyet.typ
#import "content/gk-exam-theory.typ": exam-questions





#set document(title: "GK5 — Câu hỏi lý thuyết ngắn")
#show: book






// Ô trống có lưới chấm để viết tay trên tablet




// Thẻ hỏi – đáp: không cắt đôi qua trang


#let the(ma, hoi, dap) = block(width: 100%, above: 8pt, below: 6pt)[
  #block(sticky: true, below: 4pt)[*#ma. #hoi*]
  #dap
]

#let render-the(id) = {
  let q = exam-questions.find(x => x.id == id)
  the(q.id, q.question, q.answer)
}

// ================= TRANG BÌA =================
#align(center)[
  #v(3pt)
  #text(16pt, weight: "bold", fill: accent)[GK5 — Câu hỏi lý thuyết ngắn]
  #v(2pt)
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

#render-the("A1")

#render-the("A2")

#render-the("A3")

#render-the("A4")

#render-the("A5")

#render-the("A6")

#render-the("A7")

#render-the("A8")

#render-the("A9")

#render-the("A10")

#render-the("A11")

// ================= PHẦN B =================
= Phần B — Chương 3: hệ thống phục vụ và hàng đợi

#render-the("B1")

#render-the("B2")

#render-the("B3")

#render-the("B4")

#render-the("B5")

#render-the("B6")

#render-the("B7")

#render-the("B8")

#render-the("B9")

#render-the("B10")

#render-the("B11")

#render-the("B12")

#render-the("B13")

#render-the("B14")

#render-the("B15")

#render-the("B16")

#render-the("B17")

// ================= PHẦN C =================
= Phần C — Câu hỏi tính nhẩm hay đi kèm (có đáp số)

#render-the("C1")

#render-the("C2")

#render-the("C3")

#render-the("C4")

// ================= SỔ TAY =================
= Sổ tay phòng thi — trang 5

#text(fill: black)[Từ khoá phải có — chép nguyên vào sổ tay.]

#set text(11pt)
#set par(leading: 1em, spacing: 1.3em)
#box-note("CHƯƠNG 2 — MÔ HÌNH HOÁ, BIẾN NGẪU NHIÊN", accent)[
  Mô hình hoá: trừu tượng + đơn giản hoá, lược bỏ yếu tố không cần \
  4 phương pháp: đo đạc, giả lập, mô phỏng, phân tích \
  Sự kiện NN = tập kết quả phép thử; #h(0.6em) biến NN = ánh xạ kết quả → số thực \
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
  M/D/1 có thời gian chờ nhỏ nhất khi cùng $lambda$, $E[S]$ ($sigma^2 = 0$)
]
#box-note("MẠNG HÀNG ĐỢI · TRỄ", accent)[
  Burke: ra = Poisson $lambda$ → tách mạng; #h(0.6em) Jackson: $p = product (1 - rho_i) rho_i^(n_i)$ \
  Jackson đóng / mở / nối tiếp; #h(0.6em) KIA: ghép Poisson giữ độc lập \
  $d_(e 2 e) = sum (L\/C + t_p + t_q)$; #h(0.6em) chia gói: giảm trễ, tăng tin cậy
]
#box-note("Mẹo làm bài", warn)[
  Khung: *định nghĩa → đặc điểm/công thức → ví dụ*. Đề giới hạn số dòng thì viết đúng từng ấy.
]
#set text(11pt)


// ================= BÀI TẬP =================
= Bài tự luyện

#text(fill: black)[Viết câu trả lời ra giấy riêng, mỗi câu tối đa 5 dòng. Làm hết rồi mới lật trang đáp án.]

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

#answer-table(
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
