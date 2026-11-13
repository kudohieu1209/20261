#import "style.typ": *
// Biên dịch trong thư mục này: typst compile --root .. GK0_TapInGiay_ViDuTrenLop.typ
// Bản gộp để học. Hai bản *_InA4_DenTrang.typ là đầu vào in phòng thi.
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "content/gk-exam-examples.typ": exam-examples
#import "content/gk-exam-formulas.typ": core-formulas, network-formulas





#set document(title: "GK0 — Bản gộp ví dụ và công thức")
#show: book

// Hộp ghi chú (giống GK1–GK5) — dùng cho phần C, D


// Mục lục: mỗi mục đặt một metadata <toc>
#let toc-mark(label, level: 1) = [#metadata((label: label, level: level)) <toc>]

// Khối một ví dụ: khung đề bài + lời giải bên dưới
#let vd(id, title, short: none, breakable: true, de, body) = block(
  width: 100%, breakable: true, above: 14pt, below: 6pt,
)[
  #toc-mark(if short == none { id + " — " + title } else { id + " — " + short }, level: 2)
  #block(width: 100%, inset: 0pt,
    below: 6pt, sticky: true)[
    #heading(level: 3)[#id — #title]
    #de
  ]
  #block(sticky: true)[*Giải.*]
  #body
]

#let shared-examples = exam-examples(accent: accent)
#let render-vd(id) = {
  let ex = shared-examples.find(x => x.id == id)
  vd(ex.id, ex.title, short: ex.short, breakable: true, ex.prompt, ex.answer)
}

// ================= TRANG 1: BÌA + THÔNG TIN THI + MỤC LỤC =================
#align(center)[
  #text(16pt, weight: "bold", fill: accent)[GK0 — Bản gộp ví dụ và công thức]
  #v(-4pt)
  #text(11pt)[Toàn bộ ví dụ trên lớp (lời giải tự luận) + bảng công thức]
]
#v(2pt)

#block(width: 100%, inset: 8pt,  breakable: true)[
  #text(accent, weight: "bold")[Thông tin thi] (thầy Nguyễn Xuân Dũng báo):
  *100% tự luận, 60 phút, được dùng tài liệu giấy (photo hoặc ghi chép), thi đến hết phần hàng đợi; làm được các ví dụ trên lớp sẽ có lợi thế.* \
  *Bản học tổng hợp.* Khi in mang vào thi, dùng *GK_InA4_DenTrang.pdf*; in thêm *GK_PhuLuc_Mang_InA4_DenTrang.pdf* nếu phạm vi có mạng hàng đợi. Hai tập mới đã có đủ 16 ví dụ/bài tập và công thức của bản này.
]

#block(width: 100%, above: 10pt, below: 6pt, text(accent, size: 11.5pt, weight: "bold")[Mục lục nhanh])
#context {
  let items = query(<toc>)
  set text(9.5pt)
  set par(leading: 1em, spacing: 1.3em)
  columns(2, gutter: 16pt, for it in items {
    let v = it.value
    let p = it.location().page()
    let lbl = if v.level == 1 { strong(v.label) } else { h(8pt) + v.label }
    block(width: 100%, above: if v.level == 1 { 7pt } else { 3pt }, below: 0pt,
      grid(columns: (1fr, auto), column-gutter: 3pt,
        [#lbl #box(width: 1fr, repeat(text(black)[.#h(2pt)]))],
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

#render-vd("VD 1")

#render-vd("VD 2")

#render-vd("VD 3")

#render-vd("VD 4")

== Chương 3 — Hàng đợi đơn

#render-vd("VD 5")

#render-vd("VD 6")

#render-vd("VD 7")

#render-vd("VD 8")

#render-vd("VD 9")

#render-vd("VD 10")

#render-vd("VD 11")

#render-vd("VD 12")

#render-vd("BT 3.1")

#render-vd("BT 3.2")

== Chương 3 — Mạng hàng đợi

#render-vd("VD 13")

#render-vd("BT 3.3")

// ================= C =================
= C. Bảng công thức dùng chung
#toc-mark("C. Bảng công thức")

== C1. Poisson, mũ và hàng đợi đơn
#for card in core-formulas {
  box-note(card.id + " · " + card.title, accent, card.body)
}

== C2. Mạng hàng đợi
#for card in network-formulas {
  box-note(card.id + " · " + card.title, accent, card.body)
}

// ================= D =================
= D. Từ khoá lý thuyết (nguyên trang sổ tay 5 của GK5)
#toc-mark("D. Từ khoá lý thuyết (sổ tay 5)")

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
