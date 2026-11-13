#import "style.typ": *
// Biên dịch: typst compile CK1_DinhTuyen.typ
// Hình đồ thị cắt từ đề cuối kỳ (img/ck1_*.png); đồ thị bài mẫu 3 và các cây kết quả vẽ bằng gói fletcher.
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge





#set document(title: "CK1 — Định tuyến: Dijkstra, Bellman-Ford, Prim, Kruskal")
#show: book
#set page(margin: (x: 2cm, top: 2cm, bottom: 2cm))
#set par(leading: 1em, spacing: 1.3em)






// Ô trống có lưới chấm để viết tay trên tablet


// Hình có viền mảnh
#let hinh(path, w, nguon) = align(center, block(spacing: 10pt, above: 8pt, below: 10pt)[
  #box(stroke: 0.5pt + black, inset: 2pt, radius: 0pt, image(path, width: w))
])

// ---- bảng từng bước ----
#let o-bang(s) = if s == "×" { text(fill: black)[×] } else if s == "∞" { text(fill: black)[∞] } else { s }

// Dijkstra: mỗi hàng = (bước, nút chốt, ô của từng nút); ô của nút vừa chốt được tô vàng
#let bang-dijk(nodes, rows) = {
  set text(10.5pt)
  table(
    columns: (auto, auto) + (1fr,) * nodes.len(),
    align: center + horizon, inset: (x: 4pt, y: 6pt),
    fill: (x, y) => if y == 0 { soft },
    [Bước], [Chốt], ..nodes.map(n => [#n]),
    ..rows.map(r => {
      let k = nodes.position(n => n == r.at(1))
      (table.cell[#r.at(0)], table.cell[*#r.at(1)*]) + r.slice(2).enumerate().map(((i, s)) =>
        if i == k { table.cell(fill: white)[*#o-bang(s)*] } else { table.cell[#o-bang(s)] })
    }).flatten(),
  )
}

// Bellman-Ford: mỗi hàng = (h, ô của từng nút)
#let bang-bf(nodes, rows) = {
  set text(10.5pt)
  table(
    columns: (auto,) + (1fr,) * nodes.len(),
    align: center + horizon, inset: (x: 4pt, y: 6pt),
    fill: (x, y) => if y == 0 { soft },
    [h], ..nodes,
    ..rows.map(r => (table.cell[*#r.at(0)*],) + r.slice(1).map(s => table.cell[#o-bang(s)])).flatten(),
  )
}

// ---- công cụ vẽ đồ thị / cây kết quả ----
#let C = black
#let nd(pos, ten, nm, d: none) = node(pos,
  if d == none { text(C, weight: "bold", ten) } else {
    stack(spacing: 2.5pt, text(C, weight: "bold", ten), text(8pt, fill: warn, weight: "bold")[d = #d])
  },
  name: nm, stroke: 1pt + C, fill: white, corner-radius: 4pt,
  width: 13mm, height: if d == none { 8mm } else { 12mm })
#let w(t) = text(9.5pt, weight: "bold", fill: warn, t)
#let ed(a, b, t, mark: "-", ..args) = edge(a, b, mark, w(t), stroke: 1.6pt + C,
  label-side: center, label-fill: white, ..args)
#let do-thi(sp: (16mm, 12mm), ..args) = align(center, block(spacing: 8pt, diagram(
  spacing: sp, mark-scale: 90%, ..args)))
#let chu(t) = align(center, text(8.5pt, fill: black, t))

// Thẻ hỏi – đáp


#let the(hoi, dap) = block(width: 100%, above: 7pt, below: 6pt)[
  #block(sticky: true, below: 4pt)[*Hỏi: #hoi*]
  *Đáp:* #dap
]

// ================= TRANG BÌA =================
#align(center)[
  #v(0.2cm)
  #text(16pt, weight: "bold", fill: accent)[CK1 — Định tuyến: \ Dijkstra, Bellman-Ford, Prim, Kruskal]
]
#v(6pt)

#box-note("Cách học buổi này", accent)[
  + Đọc mục 0–1, xem 4 bài mẫu: che bảng, tự lập bảng rồi mới so.
  + Làm 6 bài ở phần *Bài tự luyện* ra giấy riêng — *chưa nhìn đáp án*.
  + Dò *Đáp án* ở trang cuối; chép trang *Sổ tay phòng thi — trang 6*.

  *Điểm trong đề:* 2–3 điểm, là câu dễ ăn trọn nhất nếu trình bày đủ bảng. \
  *Qua buổi khi:* mỗi bài Dijkstra ≤ 12 phút, Bellman-Ford ≤ 15 phút, đúng 100%.
]


#set text(11pt)
#set par(spacing: 1.3em)

== 0. Đọc đề → chọn thuật toán

#text(10.5pt, table(
  columns: (2.3fr, 1.5fr, 1.2fr), inset: 4.5pt,
  [Đề hỏi], [Thuật toán], [Kết quả cần vẽ],
  ["cây đường ngắn nhất SPT", "đường đi ngắn nhất từ nút nguồn", trọng số không âm], [*Dijkstra*], [cây SPT + nhãn d(nút), π(nút)],
  [có *trọng số âm*, hoặc đề ghi rõ "Bellman-Ford"], [*Bellman-Ford*], [cây SPT],
  ["cây khung nhỏ nhất MST", "cây bao trùm nhỏ nhất", nối mọi nút với tổng chi phí nhỏ nhất], [*Prim* (mọc từ 1 đỉnh) hoặc *Kruskal* (chọn cạnh nhỏ dần)], [cây MST + tổng trọng số],
  [đường ngắn nhất giữa *mọi cặp* đỉnh], [Floyd–Warshall], [ma trận D],
))

#box-note("Quy ước", accent)[
  - d(v) = tổng chi phí ngắn nhất hiện biết từ nguồn đến v; π(v) = nút đứng ngay trước v trên đường đó. Ghi gọn trong bảng là "d, π" (ví dụ "4, B").
  - Cạnh có mũi tên chỉ đi được theo chiều mũi tên; cạnh không mũi tên đi được hai chiều.
]

== 1. Dijkstra — khuôn trình bày bảng

#khuon[
  + Khởi tạo: d(nguồn) = 0, π(nguồn) = nguồn; mọi nút khác d = ∞.
  + Mỗi bước: *chọn nút chưa chốt có d nhỏ nhất* → chốt (đánh dấu ×) → với mỗi hàng xóm v chưa chốt: nếu d(u) + w(u, v) < d(v) thì cập nhật d(v) = d(u) + w(u, v), π(v) = u.
  + Lặp đến khi chốt hết. Hai nút bằng d: chọn nút được tính trọng số *trước* (hoặc theo thứ tự chữ cái, ghi rõ quy ước đã dùng).
  + Vẽ cây SPT: nối mỗi nút v với π(v), tô đậm; ghi d cạnh mỗi nút.

  *Bảng:* hàng = bước, cột = các nút; ô ghi "d, π", nút đã chốt ghi ×.
]

// ================= BÀI MẪU 1 =================
#set text(11pt)
#set par(spacing: 1.3em)

= Bài mẫu 1 — Dijkstra, đề 20232 câu 2 (nguồn C)

#flow-grid(columns: (8.2cm, 1fr), column-gutter: 12pt, align: horizon,
  hinh("img/ck1_m1_de20232.png", 7.6cm, [Đề cuối kỳ 20232, câu 2]),
  [
    #set text(10.5pt)
    *Đọc hình:*
    - Cạnh vô hướng: C–E 3, C–B 3, D–E 2, E–G 1, B–D 2, D–G 3, B–A 3, D–A 5, D–H 2, G–H 2, F–A 1.
    - Cạnh có hướng: *C→D 2*, *B→F 1*, *H→A 1*.
  ],
)

#bang-dijk(("A", "B", "C", "D", "E", "F", "G", "H"), (
  ("0", "C", "∞", "3, C", "0, C", "2, C", "3, C", "∞", "∞", "∞"),
  ("1", "D", "7, D", "3, C", "×", "2, C", "3, C", "∞", "5, D", "4, D"),
  ("2", "B", "6, B", "3, C", "×", "×", "3, C", "4, B", "5, D", "4, D"),
  ("3", "E", "6, B", "×", "×", "×", "3, C", "4, B", "4, E", "4, D"),
  ("4", "F", "5, F", "×", "×", "×", "×", "4, B", "4, E", "4, D"),
  ("5", "G", "5, F", "×", "×", "×", "×", "×", "4, E", "4, D"),
  ("6", "H", "5, F", "×", "×", "×", "×", "×", "×", "4, D"),
  ("7", "A", "5, F", "×", "×", "×", "×", "×", "×", "×"),
))

#text(10pt, fill: black)[(Bước 2–3: B và E cùng d = 3, chọn B trước theo thứ tự chữ cái; F, G, H cùng d = 4, chọn theo thứ tự chữ cái. Kết quả cây không đổi.) Chữ đậm = nút được chốt ở bước đó.]

#flow-grid(columns: (1.4fr, 1fr), column-gutter: 10pt, align: horizon,
  [
    #do-thi(sp: (20mm, 11mm),
      nd((1, 0), "C", <c>, d: 0),
      nd((2, 0), "E", <e>, d: 3),
      nd((0, 1), "B", <b>, d: 3),
      nd((1, 1), "D", <d>, d: 2),
      nd((2, 1), "G", <g>, d: 4),
      nd((0, 2), "F", <f>, d: 4),
      nd((1, 2), "A", <a>, d: 5),
      nd((2, 2), "H", <h>, d: 4),
      ed(<c>, <d>, "2", mark: "-|>"),
      ed(<c>, <b>, "3"),
      ed(<c>, <e>, "3"),
      ed(<b>, <f>, "1", mark: "-|>"),
      ed(<f>, <a>, "1"),
      ed(<e>, <g>, "1"),
      ed(<d>, <h>, "2"),
    )
    #chu[Cây SPT nguồn C]
  ],
  box-note("Kết quả", black)[
    *Cây SPT* (cạnh tô đậm): C–D, C–B, C–E, B→F, F–A, E–G, D–H.

    *Chi phí:* A 5 (C→B→F→A); B 3; D 2; E 3; F 4; G 4 (C→E→G); H 4 (C→D→H).
  ],
)

// ================= BELLMAN-FORD + BÀI MẪU 2 =================
= Bellman-Ford — khuôn và bài mẫu 2

== 2. Bellman-Ford — khuôn trình bày bảng theo vòng lặp

#khuon[
  + Khởi tạo như Dijkstra.
  + Vòng h = 1, 2, …: với *mọi cạnh* (u, v): nếu d(u) + w(u, v) < d(v) thì cập nhật d(v), π(v). (Tính từ giá trị của vòng trước.)
  + Dừng khi một vòng *không có gì thay đổi* (tối đa |V| − 1 vòng). Nếu sau |V| − 1 vòng vẫn còn giảm được → có chu trình âm.
  + Bảng: hàng = vòng h (h = số cạnh tối đa của đường), cột = các nút, ô "d, π".
]

#text(10.5pt)[*Cách trình bày khác* (kiểu cô Lan, dùng hàng đợi Q): lấy nút ra khỏi Q, thử nới lỏng các cạnh đi ra, nút nào được cập nhật mà chưa có trong Q thì đưa vào Q; dừng khi Q rỗng. Kết quả giống hệt. Dùng kiểu nào cũng được, miễn trình bày đủ từng bước.]

== Bài mẫu 2 — Bellman-Ford, đề 20221Q câu 3 (nguồn G)

#flow-grid(columns: (6.2cm, 1fr), column-gutter: 12pt, align: horizon,
  hinh("img/ck1_m2_de20221Q.png", 5.4cm, [Đề cuối kỳ 20221Q, câu 3]),
  [
    #set text(10.5pt)
    *Đọc hình:* A–B 2, A–E 2, B–C 1, B–G 4, B–E 2, C–G 3, C–D 1, G–E 1, G–D 1, E–D 3 (đều vô hướng).
  ],
)

#bang-bf(("A", "B", "C", "D", "E", "G"), (
  ("0", "∞", "∞", "∞", "∞", "∞", "0, G"),
  ("1", "∞", "4, G", "3, G", "1, G", "1, G", "0, G"),
  ("2", "3, E", "3, E", "2, D", "1, G", "1, G", "0, G"),
  ("3", "3, E", "3, E", "2, D", "1, G", "1, G", "0, G"),
))
#text(10.5pt)[Vòng 3 không đổi → dừng.]

#flow-grid(columns: (1fr, 1.15fr), column-gutter: 10pt, align: horizon,
  [
    #do-thi(sp: (12mm, 5mm),
      nd((1, 0), "B", <b>, d: 3),
      nd((3, 0), "C", <c>, d: 2),
      nd((0, 1), "A", <a>, d: 3),
      nd((2, 1), "G", <g>, d: 0),
      nd((1, 2), "E", <e>, d: 1),
      nd((3, 2), "D", <d>, d: 1),
      ed(<g>, <d>, "1"),
      ed(<g>, <e>, "1"),
      ed(<d>, <c>, "1"),
      ed(<e>, <a>, "2"),
      ed(<e>, <b>, "2"),
    )
    #chu[Cây SPT nguồn G]
  ],
  [
    #box-note("Kết quả", black)[
      *Cây SPT:* G–D, G–E, D–C, E–A, E–B. \
      *Đường ngắn nhất:* G→E (1); G→D (1); G→D→C (2); G→E→A (3); G→E→B (3).
    ]
    #box-note("Lưu ý", warn)[Lời giải trong tài liệu tổng hợp có sẵn ra B = 4 qua G; thực ra đi G→E→B chỉ tốn 1 + 2 = 3 nên B = 3, π(B) = E.]
  ],
)

// ================= BÀI MẪU 3 =================
= Bài mẫu 3 — Bellman-Ford đồ thị có hướng, đề 20231 câu 2a (nguồn v1)

#flow-grid(columns: (8cm, 1fr), column-gutter: 12pt, align: horizon,
  [
    #do-thi(sp: (17mm, 10mm),
      nd((0, 1), [v#sub[1]], <v1>),
      nd((1, 0), [v#sub[2]], <v2>),
      nd((3, 0), [v#sub[3]], <v3>),
      nd((1, 2), [v#sub[4]], <v4>),
      nd((2, 1), [v#sub[5]], <v5>),
      nd((2, -1), [v#sub[6]], <v6>),
      ed(<v1>, <v2>, "7", mark: "-|>"),
      ed(<v1>, <v4>, "2", mark: "-|>"),
      ed(<v4>, <v2>, "4", mark: "-|>"),
      ed(<v2>, <v3>, "4", mark: "-|>"),
      ed(<v2>, <v5>, "1", mark: "-|>"),
      ed(<v5>, <v3>, "2", mark: "-|>"),
      ed(<v3>, <v6>, "3", mark: "-|>"),
      ed(<v6>, <v2>, "1", mark: "-|>"),
    )
    #chu[Đồ thị theo danh sách cạnh]
  ],
  [
    #set text(10.5pt)
    *Cạnh có hướng:* v1→v2 7, v1→v4 2, v4→v2 4, v2→v3 4, v2→v5 1, v5→v3 2, v3→v6 3, v6→v2 1.
  ],
)

#bang-bf(([v#sub[1]], [v#sub[2]], [v#sub[3]], [v#sub[4]], [v#sub[5]], [v#sub[6]]), (
  ("0", "0", "∞", "∞", "∞", "∞", "∞"),
  ("1", "0", "7, v1", "∞", "2, v1", "∞", "∞"),
  ("2", "0", "6, v4", "11, v2", "2, v1", "8, v2", "∞"),
  ("3", "0", "6, v4", "10, v2", "2, v1", "7, v2", "14, v3"),
  ("4", "0", "6, v4", "9, v5", "2, v1", "7, v2", "13, v3"),
  ("5", "0", "6, v4", "9, v5", "2, v1", "7, v2", "12, v3"),
))

#flow-grid(columns: (1.75fr, 1fr), column-gutter: 10pt, align: horizon,
  [
    #do-thi(sp: (16mm, 9mm),
      nd((0, 1), [v#sub[1]], <v1>, d: 0),
      nd((1, 0), [v#sub[2]], <v2>, d: 6),
      nd((3, 0), [v#sub[3]], <v3>, d: 9),
      nd((1, 2), [v#sub[4]], <v4>, d: 2),
      nd((2, 1), [v#sub[5]], <v5>, d: 7),
      nd((2, -1), [v#sub[6]], <v6>, d: 12),
      ed(<v1>, <v4>, "2", mark: "-|>"),
      ed(<v4>, <v2>, "4", mark: "-|>"),
      ed(<v2>, <v5>, "1", mark: "-|>"),
      ed(<v5>, <v3>, "2", mark: "-|>"),
      ed(<v3>, <v6>, "3", mark: "-|>"),
    )
    #chu[Cây SPT nguồn v1]
  ],
  box-note("Kết quả", black)[
    *Cây:* v1→v4→v2→v5→v3→v6. \
    *Kết quả:* v2 = 6, v3 = 9, v4 = 2, v5 = 7, v6 = 12.
  ],
)

== Ba câu hỏi ngắn đi kèm (đề 20231, mỗi câu ≤ 5 dòng)

#set text(10.5pt)
#the[Bellman-Ford có tìm đúng đường ngắn nhất khi đồ thị có chu trình không?][
  Đúng nếu *không có chu trình âm*. Nếu có chu trình có tổng trọng số âm thì đường ngắn nhất không tồn tại (đi vòng mãi chi phí giảm tới −∞); Bellman-Ford phát hiện được điều này vì sau |V| − 1 vòng vẫn còn cập nhật được. (Đồ thị vô hướng có một cạnh âm đã tạo chu trình âm hai chiều.)
]
#the[Khác biệt Bellman-Ford và Dijkstra?][
  Bellman-Ford xử lý được trọng số âm và phát hiện chu trình âm nhưng chậm hơn (lặp |V| − 1 vòng trên mọi cạnh, O(VE)); Dijkstra chỉ dùng cho trọng số không âm, nhanh hơn, mỗi đỉnh được chốt đúng một lần (chọn đỉnh d nhỏ nhất).
]
#the[Hàm trọng số theo băng thông BW và tỉ lệ mất gói PDR với tỉ trọng α, β?][
  μ = α·(1/BW) + β·PDR (băng thông càng lớn càng tốt nên dùng nghịch đảo; mất gói càng nhỏ càng tốt nên dùng trực tiếp). Nếu đề chuẩn hoá: μ = α·(BWmax/BW) + β·(PDR/PDRmax).
]
#set text(11pt)

#box-note("Lưu ý", warn)[Tài liệu tổng hợp ghi μ = α/BW + β/PDR — sai chiều với PDR (tỉ lệ mất gói lớn thì chi phí phải lớn).]

// ================= PRIM, KRUSKAL + BÀI MẪU 4 =================
== 3. Prim và Kruskal (cây khung nhỏ nhất MST) — khuôn

#flow-grid(columns: (1fr, 1fr), column-gutter: 10pt,
  khuon[
    *Prim* (mọc cây từ một đỉnh):
    + Bắt đầu từ một đỉnh (đề cho, hoặc tự chọn A).
    + Mỗi bước: trong các cạnh nối *một đỉnh đã thuộc cây* với *một đỉnh chưa thuộc cây*, chọn cạnh nhỏ nhất, thêm đỉnh đó vào cây.
    + Dừng khi đủ |V| đỉnh (|V| − 1 cạnh).
  ],
  khuon[
    *Kruskal* (chọn cạnh):
    + Sắp xếp mọi cạnh tăng dần.
    + Lần lượt xét: cạnh nào *không tạo chu trình* với các cạnh đã chọn thì chọn, tạo chu trình thì bỏ.
    + Dừng khi có |V| − 1 cạnh.
  ],
)
#text(10.5pt)[Hai thuật toán cho cùng tổng trọng số (cây có thể khác nhau khi có cạnh bằng nhau).]

= Bài mẫu 4 — Prim và Kruskal trên đồ thị đề 20231Q câu 3

#flow-grid(columns: (7.4cm, 1fr), column-gutter: 12pt, align: horizon,
  hinh("img/ck1_m4_de20231Q.png", 6.8cm, [Đề cuối kỳ 20231Q, câu 3]),
  [
    #set text(10.5pt)
    *Cạnh:* A–B 1, A–C 1, A–D 4, A–E 3, B–C 5, B–G 6, C–D 3, C–F 2, C–G 1, D–E 2, D–H 2, E–H 7, F–H 4, G–H 3.
  ],
)

#flow-grid(columns: (1fr, 1fr), column-gutter: 12pt,
  [
    *Prim từ A:*
    #set text(10.5pt)
    #table(
      columns: (auto, 1fr, auto),
      align: (center, left, left), inset: (x: 5pt, y: 4pt),
      fill: (x, y) => if y == 0 { soft },
      [Bước], [Cây hiện có], [Cạnh chọn],
      [1], [{A}], [A–B (1)],
      [2], [{A, B}], [A–C (1)],
      [3], [{A, B, C}], [C–G (1)],
      [4], [{A, B, C, G}], [C–F (2)],
      [5], [{A, B, C, G, F}], [A–E (3)],
      [6], [{…, E}], [E–D (2)],
      [7], [{…, D}], [D–H (2)],
    )
    Tổng = 1 + 1 + 1 + 2 + 3 + 2 + 2 = *12*.
  ],
  [
    *Kruskal:*
    #set text(10.5pt)
    
AB(1) chọn; AC(1) chọn; CG(1) chọn; CF(2) chọn; DE(2) chọn; DH(2) chọn; AE(3) chọn; CD(3) bỏ (tạo chu trình); GH(3) bỏ; AD(4) bỏ; FH(4) bỏ; BC(5) bỏ; BG(6) bỏ; EH(7) bỏ.

    Tổng = *12* (cùng cây với Prim).
  ],
)

#flow-grid(columns: (2fr, 1fr), column-gutter: 10pt, align: horizon,
  [
    #do-thi(sp: (10mm, 10mm),
      nd((2, 0), "A", <a>),
      nd((0, 1), "B", <b>),
      nd((1, 1), "C", <c>),
      nd((2.6, 1), "D", <d>),
      nd((3.8, 1), "E", <e>),
      nd((1.8, 2), "F", <f>),
      nd((0.6, 2.6), "G", <g>),
      nd((3, 2.6), "H", <h>),
      ed(<a>, <b>, "1"),
      ed(<a>, <c>, "1"),
      ed(<c>, <g>, "1"),
      ed(<c>, <f>, "2"),
      ed(<a>, <e>, "3"),
      ed(<e>, <d>, "2"),
      ed(<d>, <h>, "2"),
    )
    #chu[Cây MST (Prim từ A = Kruskal)]
  ],
  box-note("Kết quả", black)[
    *Cạnh MST:* A–B 1, A–C 1, C–G 1, C–F 2, A–E 3, E–D 2, D–H 2. \
    *Tổng trọng số = 12.*
  ],
)

== 4. Floyd–Warshall (ít gặp — chỉ cần nhớ khuôn)

#khuon[
  $D^((0))$ = ma trận trọng số (∞ nếu không nối, 0 trên đường chéo). Với $k = 1 … n$:
  $ D^((k))(i, j) = min(D^((k-1))(i, j), space D^((k-1))(i, k) + D^((k-1))(k, j)) $
  Ghi thêm ma trận pred để lần lại đường.
]

// ================= SỔ TAY =================
= Sổ tay phòng thi — trang 6

#set text(11pt)
#box-note("DIJKSTRA", accent)[
  chốt nút d nhỏ nhất → nới lỏng hàng xóm: $d(u) + w < d(v)$ → $d(v)$, $π(v) = u$ \
  bảng: hàng = bước, ô "d, π", nút đã chốt ghi ×; bằng nhau: chọn nút tính trước
]
#box-note("BELLMAN-FORD", accent)[
  mỗi vòng nới lỏng *MỌI* cạnh; dừng khi 1 vòng không đổi (≤ |V| − 1) \
  còn giảm sau |V| − 1 vòng → chu trình âm
]
#box-note("PRIM · KRUSKAL", accent)[
  PRIM: mọc từ 1 đỉnh, mỗi bước cạnh nhỏ nhất nối cây với ngoài cây \
  KRUSKAL: sắp cạnh tăng dần, chọn nếu không tạo chu trình; đủ |V| − 1 cạnh
]
#box-note("CHIỀU CẠNH", accent)[
  Cạnh có mũi tên: chỉ đi theo chiều mũi tên
]
#box-note("CÂU HỎI NGẮN", accent)[
  BF xử lý cạnh âm, phát hiện chu trình âm, chậm O(VE); \
  Dijkstra không âm, nhanh, mỗi đỉnh chốt 1 lần \
  Hàm trọng số: μ = α/BW + β·PDR #h(1em) (chuẩn hoá: α·BWmax/BW + β·PDR/PDRmax)
]
#box-note("Lỗi hay mắc", warn)[
  - Đi ngược chiều mũi tên.
  - Quên cập nhật π khi d giảm → vẽ sai cây.
  - Bellman-Ford dùng ngay giá trị mới trong cùng vòng nhưng ghi bảng như theo vòng (không sai kết quả, nhưng phải trình bày nhất quán).
  - Kruskal quên kiểm tra chu trình.
  - Thay số MSSV sai (a = chữ số cuối, ba = hai chữ số cuối).
]
#set text(11pt)

// ================= BÀI TẬP =================
= Bài tự luyện — kẻ bảng, vẽ cây ra giấy riêng




#bai(1, fw: 4.2cm, fig: hinh("img/ck1_m4_de20231Q.png", 3.8cm, [hình bài mẫu 4 (đề 20231Q)]))[
  Dijkstra trên đồ thị đề 20231Q câu 3 (cạnh ở bài mẫu 4), nguồn A.
]

#bai(2, fw: 7.2cm, fig: hinh("img/ck1_tl2_de20202.png", 6.9cm, [Đề cuối kỳ 20202, câu 2]))[
  Dijkstra đề 20202 câu 2, nguồn S, với a = 7 (chữ số cuối MSSV).
  #set text(9.5pt)
  #set par(spacing: 1.3em)

  Cạnh vô hướng: S–B 10 − a, S–A 5, S–C a + 1, B–E 4, B–F 3, A–E a + 3, A–G 12 − a, E–G 4, E–D 1, C–G 2, F–D 3; cạnh có hướng: B→A 1, F→E 2, C→A 1, C→D 3, D→G 1.

  *Đã thay a = 7:* S–B 3, S–A 5, S–C 8, B–E 4, B–F 3, A–E 10, A–G 5, E–G 4, E–D 1, C–G 2, F–D 3; có hướng B→A 1, F→E 2, C→A 1, C→D 3, D→G 1.
]

#bai(3, fw: 7.6cm, fig: hinh("img/ck1_tl3_de20212.png", 7.2cm, [Đề cuối kỳ 20212, câu 2]))[
  Bellman-Ford đề 20212 câu 2, nguồn B.

  #set text(10pt)
  Cạnh vô hướng: C–B 1, C–E 3, D–E 2, E–G 1, B–D 4, D–G 3, G–F 3, B–A 1, D–A 1, D–H 2, G–H 2, H–F 4; có hướng: C→D 2, E→F 1, H→A 1.
]

#bai(4, h: 7cm, fig: hinh("img/ck1_m2_de20221Q.png", 4.6cm, [hình bài mẫu 2 (đề 20221Q)]), fw: 5cm)[
  Kruskal trên đồ thị đề 20221Q (cạnh ở bài mẫu 2). Tổng trọng số MST?
]

#bai(5, h: 7cm, fig: hinh("img/ck1_m1_de20232.png", 5.4cm, [hình bài mẫu 1 (đề 20232)]), fw: 5.8cm)[
  Prim bắt đầu từ C trên đồ thị đề 20232 (bài mẫu 1), coi mọi cạnh là vô hướng. Tổng trọng số MST?
]

#bai(6, h: 4cm)[
  Trả lời ngắn (≤ 5 dòng): vì sao Dijkstra không dùng được khi có trọng số âm?
]

// ================= ĐÁP ÁN =================
= Đáp án

#answer-table(
  columns: (auto, 1fr),
  [Bài], [Đáp án],
  [1], [Thứ tự chốt: A, B, C, G, E, F, D, H. \
    Kết quả: B 1 (A); C 1 (A); G 2 (C); E 3 (A); F 3 (C); D 4 (A); H 5 (G). \
    Cây: A–B, A–C, C–G, A–E, C–F, A–D, G–H.],
  [2], [a = 7: S–B 3, S–C 8, A–E 10, A–G 5. Thứ tự chốt: S, B, A, F, E, C, D, G. \
    Kết quả: B 3 (S); A 4 (B); F 6 (B); E 7 (B); C 8 (S); D 8 (E); G 9 (A) (G cũng = 9 qua D→G; lấy A vì được tính trước). \
    Cây: S–B, B→A, B–F, B–E, S–C, E–D, A–G.],
  [3], [Bảng: \
    h1: A 1,B; C 1,B; D 4,B. \
    h2: D 2,A; E 4,C; G 7,D; H 6,D. \
    h3: F 5,E; G 5,D; H 4,D. \
    h4 không đổi. \
    Kết quả: A 1; C 1; D 2 (B→A→D); E 4 (B→C→E); F 5 (…E→F); G 5 (B→A→D→G, hoặc qua E cũng 5); H 4 (B→A→D→H).],
  [4], [BC(1), CD(1), GD(1), GE(1) chọn; AB(2) chọn; AE(2), BE(2) bỏ; CG(3), ED(3) bỏ; BG(4) bỏ. Tổng = *6*.],
  [5], [C–D 2, D–B 2, B–F 1, F–A 1, A–H 1, D–E 2, E–G 1. Tổng = *10*.],
  [6], [Dijkstra chốt vĩnh viễn nút có d nhỏ nhất, giả định mọi đường đi tiếp chỉ làm tổng tăng. Có cạnh âm thì một đường đi vòng qua cạnh âm có thể rẻ hơn sau khi nút đã bị chốt → kết quả sai.],
)

#v(10pt)
#box-note("Buổi sau — CK2", accent)[
  Đề "một bài lớn": mô hình hoá mạng router → hàng đợi → định tuyến với chi phí tự tính → điều khiển luồng.
]
