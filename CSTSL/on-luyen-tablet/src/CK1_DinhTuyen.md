# CK1 — Định tuyến: Dijkstra, Bellman-Ford, Prim, Kruskal (ôn cuối kỳ)

Điểm trong đề: 2–3 điểm, là câu dễ ăn trọn nhất nếu trình bày đủ bảng.
Qua buổi khi: mỗi bài Dijkstra ≤ 12 phút, Bellman-Ford ≤ 15 phút, đúng 100%.

## 0. Đọc đề → chọn thuật toán

| Đề hỏi | Thuật toán | Kết quả cần vẽ |
|---|---|---|
| "cây đường ngắn nhất SPT", "đường đi ngắn nhất từ nút nguồn", trọng số không âm | **Dijkstra** | cây SPT + nhãn d(nút), π(nút) |
| có **trọng số âm**, hoặc đề ghi rõ "Bellman-Ford" | **Bellman-Ford** | cây SPT |
| "cây khung nhỏ nhất MST", "cây bao trùm nhỏ nhất", nối mọi nút với tổng chi phí nhỏ nhất | **Prim** (mọc từ 1 đỉnh) hoặc **Kruskal** (chọn cạnh nhỏ dần) | cây MST + tổng trọng số |
| đường ngắn nhất giữa **mọi cặp** đỉnh | Floyd–Warshall | ma trận D |

Quy ước nhãn: d(v) = tổng chi phí ngắn nhất hiện biết từ nguồn đến v; π(v) = nút đứng ngay trước v trên đường đó. Ghi gọn trong bảng là "d, π" (ví dụ "4, B").
Cạnh có mũi tên chỉ đi được theo chiều mũi tên; cạnh không mũi tên đi được hai chiều.

## 1. Dijkstra — khuôn trình bày bảng

1. Khởi tạo: d(nguồn) = 0, π(nguồn) = nguồn; mọi nút khác d = ∞.
2. Mỗi bước: **chọn nút chưa chốt có d nhỏ nhất** → chốt (đánh dấu ×) → với mỗi hàng xóm v chưa chốt: nếu d(u) + w(u, v) < d(v) thì cập nhật d(v) = d(u) + w(u, v), π(v) = u.
3. Lặp đến khi chốt hết. Hai nút bằng d: chọn nút được tính trọng số **trước** (hoặc theo thứ tự chữ cái, ghi rõ quy ước đã dùng).
4. Vẽ cây SPT: nối mỗi nút v với π(v), tô đậm; ghi d cạnh mỗi nút.

Bảng: hàng = bước, cột = các nút; ô ghi "d, π", nút đã chốt ghi ×.

## Bài mẫu 1 — Dijkstra, đề 20232 câu 2 (nguồn C)

Hình (cắt từ docs/Đề CK/CK_20232.JPG, nửa dưới): cạnh vô hướng C–E 3, C–B 3, D–E 2, E–G 1, B–D 2, D–G 3, B–A 3, D–A 5, D–H 2, G–H 2, F–A 1; cạnh có hướng C→D 2, B→F 1, H→A 1.

| Bước | Chốt | A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|---|---|
| 0 | C | ∞ | 3, C | 0, C | 2, C | 3, C | ∞ | ∞ | ∞ |
| 1 | D | 7, D | 3, C | × | 2, C | 3, C | ∞ | 5, D | 4, D |
| 2 | B | 6, B | 3, C | × | × | 3, C | 4, B | 5, D | 4, D |
| 3 | E | 6, B | × | × | × | 3, C | 4, B | 4, E | 4, D |
| 4 | F | 5, F | × | × | × | × | 4, B | 4, E | 4, D |
| 5 | G | 5, F | × | × | × | × | × | 4, E | 4, D |
| 6 | H | 5, F | × | × | × | × | × | × | 4, D |
| 7 | A | 5, F | × | × | × | × | × | × | × |

(Bước 2–3: B và E cùng d = 3, chọn B trước theo thứ tự chữ cái; F, G, H cùng d = 4, chọn theo thứ tự chữ cái. Kết quả cây không đổi.)

Cây SPT (cạnh tô đậm): C–D, C–B, C–E, B→F, F–A, E–G, D–H.
Chi phí: A 5 (C→B→F→A); B 3; D 2; E 3; F 4; G 4 (C→E→G); H 4 (C→D→H).

## 2. Bellman-Ford — khuôn trình bày bảng theo vòng lặp

1. Khởi tạo như Dijkstra.
2. Vòng h = 1, 2, …: với **mọi cạnh** (u, v): nếu d(u) + w(u, v) < d(v) thì cập nhật d(v), π(v). (Tính từ giá trị của vòng trước.)
3. Dừng khi một vòng **không có gì thay đổi** (tối đa |V| − 1 vòng). Nếu sau |V| − 1 vòng vẫn còn giảm được → có chu trình âm.
4. Bảng: hàng = vòng h (h = số cạnh tối đa của đường), cột = các nút, ô "d, π".

Cách trình bày khác (kiểu cô Lan, dùng hàng đợi Q): lấy nút ra khỏi Q, thử nới lỏng các cạnh đi ra, nút nào được cập nhật mà chưa có trong Q thì đưa vào Q; dừng khi Q rỗng. Kết quả giống hệt. Dùng kiểu nào cũng được, miễn trình bày đủ từng bước.

## Bài mẫu 2 — Bellman-Ford, đề 20221Q câu 3 (nguồn G)

Hình (cắt từ docs/Đề CK/CK_20221Q.pdf trang 2): A–B 2, A–E 2, B–C 1, B–G 4, B–E 2, C–G 3, C–D 1, G–E 1, G–D 1, E–D 3 (đều vô hướng).

| h | A | B | C | D | E | G |
|---|---|---|---|---|---|---|
| 0 | ∞ | ∞ | ∞ | ∞ | ∞ | 0, G |
| 1 | ∞ | 4, G | 3, G | 1, G | 1, G | 0, G |
| 2 | 3, E | 3, E | 2, D | 1, G | 1, G | 0, G |
| 3 | 3, E | 3, E | 2, D | 1, G | 1, G | 0, G |

Vòng 3 không đổi → dừng.
Cây SPT: G–D, G–E, D–C, E–A, E–B. Đường ngắn nhất: G→E (1); G→D (1); G→D→C (2); G→E→A (3); G→E→B (3).

> Lời giải trong tài liệu tổng hợp có sẵn ra B = 4 qua G; thực ra đi G→E→B chỉ tốn 1 + 2 = 3 nên B = 3, π(B) = E.

## Bài mẫu 3 — Bellman-Ford đồ thị có hướng, đề 20231 câu 2a (nguồn v1)

Cạnh có hướng: v1→v2 7, v1→v4 2, v4→v2 4, v2→v3 4, v2→v5 1, v5→v3 2, v3→v6 3, v6→v2 1. (Hình: trang 34 của docs/CSTSL_20251_ALL_re.pdf.)

| h | v1 | v2 | v3 | v4 | v5 | v6 |
|---|---|---|---|---|---|---|
| 0 | 0 | ∞ | ∞ | ∞ | ∞ | ∞ |
| 1 | 0 | 7, v1 | ∞ | 2, v1 | ∞ | ∞ |
| 2 | 0 | 6, v4 | 11, v2 | 2, v1 | 8, v2 | ∞ |
| 3 | 0 | 6, v4 | 10, v2 | 2, v1 | 7, v2 | 14, v3 |
| 4 | 0 | 6, v4 | 9, v5 | 2, v1 | 7, v2 | 13, v3 |
| 5 | 0 | 6, v4 | 9, v5 | 2, v1 | 7, v2 | 12, v3 |

Cây: v1→v4→v2→v5→v3→v6. Kết quả: v2 = 6, v3 = 9, v4 = 2, v5 = 7, v6 = 12.

Ba câu hỏi ngắn đi kèm (đề 20231, mỗi câu ≤ 5 dòng):
- **Bellman-Ford có tìm đúng đường ngắn nhất khi đồ thị có chu trình không?** Đúng nếu **không có chu trình âm**. Nếu có chu trình có tổng trọng số âm thì đường ngắn nhất không tồn tại (đi vòng mãi chi phí giảm tới −∞); Bellman-Ford phát hiện được điều này vì sau |V| − 1 vòng vẫn còn cập nhật được. (Đồ thị vô hướng có một cạnh âm đã tạo chu trình âm hai chiều.)
- **Khác biệt Bellman-Ford và Dijkstra:** Bellman-Ford xử lý được trọng số âm và phát hiện chu trình âm nhưng chậm hơn (lặp |V| − 1 vòng trên mọi cạnh, O(VE)); Dijkstra chỉ dùng cho trọng số không âm, nhanh hơn, mỗi đỉnh được chốt đúng một lần (chọn đỉnh d nhỏ nhất).
- **Hàm trọng số theo băng thông BW và tỉ lệ mất gói PDR với tỉ trọng α, β:** μ = α·(1/BW) + β·PDR (băng thông càng lớn càng tốt nên dùng nghịch đảo; mất gói càng nhỏ càng tốt nên dùng trực tiếp). Nếu đề chuẩn hoá: μ = α·(BWmax/BW) + β·(PDR/PDRmax).

> Tài liệu tổng hợp ghi μ = α/BW + β/PDR — sai chiều với PDR (tỉ lệ mất gói lớn thì chi phí phải lớn).

## 3. Prim và Kruskal (cây khung nhỏ nhất MST)

Prim (mọc cây từ một đỉnh):
1. Bắt đầu từ một đỉnh (đề cho, hoặc tự chọn A).
2. Mỗi bước: trong các cạnh nối **một đỉnh đã thuộc cây** với **một đỉnh chưa thuộc cây**, chọn cạnh nhỏ nhất, thêm đỉnh đó vào cây.
3. Dừng khi đủ |V| đỉnh (|V| − 1 cạnh).
Kruskal (chọn cạnh):
1. Sắp xếp mọi cạnh tăng dần.
2. Lần lượt xét: cạnh nào **không tạo chu trình** với các cạnh đã chọn thì chọn, tạo chu trình thì bỏ.
3. Dừng khi có |V| − 1 cạnh.
Hai thuật toán cho cùng tổng trọng số (cây có thể khác nhau khi có cạnh bằng nhau).

## Bài mẫu 4 — Prim và Kruskal trên đồ thị đề 20231Q câu 3

Cạnh (hình: docs/Đề CK/CK_20231Q.pdf trang 2): A–B 1, A–C 1, A–D 4, A–E 3, B–C 5, B–G 6, C–D 3, C–F 2, C–G 1, D–E 2, D–H 2, E–H 7, F–H 4, G–H 3.

Prim từ A:
| Bước | Cây hiện có | Cạnh chọn |
|---|---|---|
| 1 | {A} | A–B (1) |
| 2 | {A, B} | A–C (1) |
| 3 | {A, B, C} | C–G (1) |
| 4 | {A, B, C, G} | C–F (2) |
| 5 | {A, B, C, G, F} | A–E (3) |
| 6 | {…, E} | E–D (2) |
| 7 | {…, D} | D–H (2) |
Tổng = 1 + 1 + 1 + 2 + 3 + 2 + 2 = **12**.

Kruskal: AB(1) chọn; AC(1) chọn; CG(1) chọn; CF(2) chọn; DE(2) chọn; DH(2) chọn; AE(3) chọn; CD(3) bỏ (tạo chu trình); GH(3) bỏ; AD(4) bỏ; FH(4) bỏ; BC(5) bỏ; BG(6) bỏ; EH(7) bỏ. Tổng = **12** (cùng cây với Prim).

## 4. Floyd–Warshall (ít gặp — chỉ cần nhớ khuôn)

D⁽⁰⁾ = ma trận trọng số (∞ nếu không nối, 0 trên đường chéo). Với k = 1 … n: D⁽ᵏ⁾(i, j) = min(D⁽ᵏ⁻¹⁾(i, j), D⁽ᵏ⁻¹⁾(i, k) + D⁽ᵏ⁻¹⁾(k, j)). Ghi thêm ma trận pred để lần lại đường.

## Bài tự luyện (có ô chấm; bài có hình thì chèn hình gốc)

1. Dijkstra trên đồ thị đề 20231Q câu 3 (cạnh ở bài mẫu 4), nguồn A.
2. Dijkstra đề 20202 câu 2, nguồn S, với a = 7 (chữ số cuối MSSV). Cạnh vô hướng: S–B 10 − a, S–A 5, S–C a + 1, B–E 4, B–F 3, A–E a + 3, A–G 12 − a, E–G 4, E–D 1, C–G 2, F–D 3; cạnh có hướng: B→A 1, F→E 2, C→A 1, C→D 3, D→G 1. (Hình: docs/Đề CK/CK_20202.pdf trang 1, nửa dưới.)
3. Bellman-Ford đề 20212 câu 2, nguồn B. Cạnh vô hướng: C–B 1, C–E 3, D–E 2, E–G 1, B–D 4, D–G 3, G–F 3, B–A 1, D–A 1, D–H 2, G–H 2, H–F 4; có hướng: C→D 2, E→F 1, H→A 1. (Hình: docs/Đề CK/CK_20212.pdf trang 1.)
4. Kruskal trên đồ thị đề 20221Q (cạnh ở bài mẫu 2). Tổng trọng số MST?
5. Prim bắt đầu từ C trên đồ thị đề 20232 (bài mẫu 1), coi mọi cạnh là vô hướng. Tổng trọng số MST?
6. Trả lời ngắn (≤ 5 dòng): vì sao Dijkstra không dùng được khi có trọng số âm?

## Đáp án

1. Thứ tự chốt: A, B, C, G, E, F, D, H. Kết quả: B 1 (A); C 1 (A); G 2 (C); E 3 (A); F 3 (C); D 4 (A); H 5 (G). Cây: A–B, A–C, C–G, A–E, C–F, A–D, G–H.
2. a = 7: S–B 3, S–C 8, A–E 10, A–G 5. Thứ tự chốt: S, B, A, F, E, C, D, G. Kết quả: B 3 (S); A 4 (B); F 6 (B); E 7 (B); C 8 (S); D 8 (E); G 9 (A) (G cũng = 9 qua D→G; lấy A vì được tính trước). Cây: S–B, B→A, B–F, B–E, S–C, E–D, A–G.
3. Bảng: h1: A 1,B; C 1,B; D 4,B. h2: D 2,A; E 4,C; G 7,D; H 6,D. h3: F 5,E; G 5,D; H 4,D. h4 không đổi. Kết quả: A 1; C 1; D 2 (B→A→D); E 4 (B→C→E); F 5 (…E→F); G 5 (B→A→D→G, hoặc qua E cũng 5); H 4 (B→A→D→H).
4. BC(1), CD(1), GD(1), GE(1) chọn; AB(2) chọn; AE(2), BE(2) bỏ; CG(3), ED(3) bỏ; BG(4) bỏ. Tổng = **6**.
5. C–D 2, D–B 2, B–F 1, F–A 1, A–H 1, D–E 2, E–G 1. Tổng = **10**.
6. Dijkstra chốt vĩnh viễn nút có d nhỏ nhất, giả định mọi đường đi tiếp chỉ làm tổng tăng. Có cạnh âm thì một đường đi vòng qua cạnh âm có thể rẻ hơn sau khi nút đã bị chốt → kết quả sai.

## Trang sổ tay phòng thi (trang 6)

```
DIJKSTRA: chốt nút d nhỏ nhất → nới lỏng hàng xóm: d(u)+w < d(v) → d(v), π(v)=u
  bảng: hàng = bước, ô "d, π", nút đã chốt ghi ×; bằng nhau: chọn nút tính trước
BELLMAN-FORD: mỗi vòng nới lỏng MỌI cạnh; dừng khi 1 vòng không đổi (≤ |V|−1)
  còn giảm sau |V|−1 vòng → chu trình âm
PRIM: mọc từ 1 đỉnh, mỗi bước cạnh nhỏ nhất nối cây với ngoài cây
KRUSKAL: sắp cạnh tăng dần, chọn nếu không tạo chu trình; đủ |V|−1 cạnh
Cạnh có mũi tên: chỉ đi theo chiều mũi tên
Câu hỏi ngắn: BF xử lý cạnh âm, phát hiện chu trình âm, chậm O(VE);
  Dijkstra không âm, nhanh, mỗi đỉnh chốt 1 lần
Hàm trọng số: μ = α/BW + β·PDR  (chuẩn hoá: α·BWmax/BW + β·PDR/PDRmax)
```

Lỗi hay mắc:
- Đi ngược chiều mũi tên.
- Quên cập nhật π khi d giảm → vẽ sai cây.
- Bellman-Ford dùng ngay giá trị mới trong cùng vòng nhưng ghi bảng như theo vòng (không sai kết quả, nhưng phải trình bày nhất quán).
- Kruskal quên kiểm tra chu trình.
- Thay số MSSV sai (a = chữ số cuối, ba = hai chữ số cuối).
