# CK4 — Tính công bằng (max-min) và chống tắc nghẽn bằng cửa sổ thích ứng

Điểm trong đề: khoảng 1 điểm (ý phân chia băng thông) + có thể 1 câu lý thuyết ngắn.
Qua buổi khi: phân chia max-min đúng trong ≤ 5 phút; dựng được diễn biến cửa sổ theo bit tắc nghẽn.

## 1. Khái niệm cần nhớ (trả lời câu hỏi ngắn)

- **Điều khiển luồng**: đảm bảo phía phát **không phát vượt khả năng xử lý của phía thu**. Hai kiểu: **end-to-end** (giữa hai đầu cuối) và **hop-by-hop** (giữa từng cặp nút kề nhau).
- **Chống tắc nghẽn**: kiểm soát thông tin đi vào mạng để **tổng lưu lượng không vượt khả năng xử lý của toàn mạng**. Hai kiểu: **điều khiển truy nhập mạng** và **điều khiển cấp phát bộ đệm**.
- **Tính công bằng**: các người dùng/ứng dụng được dùng tài nguyên mạng với **cơ hội như nhau** — công bằng về **băng truyền** và về **bộ đệm**.
- **Max-min fairness (công bằng cực đại – cực tiểu)**: đáp ứng công bằng cho người dùng có yêu cầu ít nhất trước, tài nguyên còn lại tiếp tục chia công bằng cho những người còn lại, lặp đến hết. Kết quả: không thể tăng băng thông của ai mà không phải giảm của một người đang có ít hơn hoặc bằng.
- Thông lượng tổng cực đại **không** đồng nghĩa công bằng (ví dụ cho kết nối dài nhất 0 Mbps để các kết nối ngắn dùng hết).

## 2. Khuôn phân chia băng thông max-min

1. Liệt kê mỗi kết nối đi qua những liên kết nào (đọc kỹ hình: kết nối vào ở nút nào, ra ở nút nào).
2. Với mỗi liên kết còn kết nối chưa chốt: **phần chia đều = dung lượng còn lại / số kết nối chưa chốt đi qua liên kết đó**.
3. Liên kết có **phần chia đều nhỏ nhất** là nút cổ chai → **chốt** mọi kết nối chưa chốt đi qua nó bằng giá trị đó.
4. Trừ phần đã chốt khỏi dung lượng **mọi** liên kết mà các kết nối vừa chốt đi qua.
5. Lặp lại bước 2–4 với các kết nối còn lại đến khi chốt hết.
6. Kiểm tra: tổng trên mỗi liên kết ≤ dung lượng.

## Bài mẫu 1 — slide/tài liệu tổng hợp (mạng A–B–C–D, 4 kết nối)

Kết nối 1: A→B; 2: B→C; 3: C→D; 4: A→D (đi qua cả 3 liên kết).
(a) AB = BC = CD = 1 Mbps.
- Cực đại thông lượng: C1 = C2 = C3 = 1, C4 = 0 → tổng 3 Mbps nhưng **không công bằng**.
- Chia đều theo liên kết (max-min): mỗi liên kết có 2 kết nối → mỗi kết nối 0,5 Mbps → tổng 2 Mbps, công bằng.
(b) AB = 1, BC = 2, CD = 3 Mbps (max-min):
- Bước 1: AB: 1/2 = 0,5; BC: 2/2 = 1; CD: 3/2 = 1,5 → AB nhỏ nhất → chốt **C1 = C4 = 0,5**.
- Bước 2: BC còn 2 − 0,5 = 1,5 cho C2; CD còn 3 − 0,5 = 2,5 cho C3 → **C2 = 1,5**; **C3 = 2,5** (Mbps).

## Bài mẫu 2 — đề cuối kỳ 20221Q câu 2a

Hình (docs/Đề CK/CK_20221Q.pdf trang 1, nửa dưới): A —8 Mbps— B —15 Mbps— C —10 Mbps— D. Kết nối 1: vào A, ra sau D (qua AB, BC, CD). Kết nối 2: vào A (phía trên), ra ở C (qua AB, BC). Kết nối 3: vào A (phía dưới), ra ở B (qua AB). Kết nối 4: vào ở B, ra sau D (qua BC, CD).
- Bước 1: AB: 8/3 ≈ 2,67 (1, 2, 3); BC: 15/3 = 5 (1, 2, 4); CD: 10/2 = 5 (1, 4) → AB nhỏ nhất → chốt **1, 2, 3 = 8/3 ≈ 2,67 Mbps**.
- Bước 2: còn kết nối 4. BC còn 15 − 2·8/3 = 29/3; CD còn 10 − 8/3 = 22/3 → nhỏ nhất CD → **4 = 22/3 ≈ 7,33 Mbps**.
- Kiểm tra: BC = 8/3 + 8/3 + 22/3 = 38/3 ≈ 12,67 ≤ 15 ✔; CD = 8/3 + 22/3 = 10 ✔.

> Tài liệu tổng hợp ghi kết nối 4 = 29/3 ≈ 9,67 Mbps — sai, vì khi đó liên kết CD phải mang 8/3 + 29/3 = 37/3 > 10 Mbps.

## Bài mẫu 3 — đề cuối kỳ 20231Q câu 2a

Hình (docs/Đề CK/CK_20231Q.pdf trang 2): A —10 Mbps— B —5 Mbps— C —5 Mbps— D. Kết nối 1: A → qua D (AB, BC, CD). Kết nối 2: vào A (trên), ra ở B (AB). Kết nối 3: vào B (trên), ra ở C (BC). Kết nối 4: vào A (dưới), ra ở B (AB).
- Bước 1: AB: 10/3 ≈ 3,33 (1, 2, 4); BC: 5/2 = 2,5 (1, 3); CD: 5/1 = 5 (1) → BC nhỏ nhất → chốt **1 = 3 = 2,5 Mbps**.
- Bước 2: AB còn 10 − 2,5 = 7,5 cho kết nối 2, 4 → **2 = 4 = 3,75 Mbps**.
- Kiểm tra: AB = 2,5 + 3,75 + 3,75 = 10 ✔; BC = 5 ✔; CD = 2,5 ≤ 5 ✔.

## 3. Chống tắc nghẽn bằng cửa sổ thích ứng

**Thiết bị mạng thông minh** (phát hiện tắc nghẽn và báo cho nguồn):
- Cách báo: gói cảnh báo độc lập (nhanh nhưng tốn băng thông) hoặc **bit chỉ thị tắc nghẽn** trong báo nhận (0 = không tắc, 1 = tắc).
- Nguồn **không** quyết định theo từng ACK mà theo **nhóm n báo nhận**: nếu số ACK có bit tắc ≥ ngưỡng → coi là tắc nghẽn → **giảm W bằng phép nhân** W_mới = W_cũ × α (α < 1); ngược lại → **tăng W bằng phép cộng** W_mới = W_cũ + I.
- W không nguyên thì **dùng số nguyên gần nhất** (W vẫn lưu giá trị thực để tính tiếp).

**Thiết bị mạng không thông minh** (nguồn tự suy đoán qua time-out):
- Ban đầu W = Wmax.
- Mỗi khi **time-out** phải phát lại → đặt **W = 1**.
- Mỗi khi nhận được **n báo nhận** → W tăng thêm 1, nhưng không vượt Wmax.

## Bài mẫu 4 — ví dụ trong slide (thiết bị thông minh)

W ban đầu = 4; xét theo nhóm 7 báo nhận; ≥ 4 ACK có bit tắc → giảm với α = 0,7; ngược lại tăng với I = 1.
- Nhóm 1 tắc: W = 4·0,7 = 2,8 → **dùng W = 3**.
- Nhóm 2 tắc: W = 2,8·0,7 = 1,96 → **dùng W = 2**.
- Nhóm 3 không tắc: W = 1,96 + 1 = 2,96 → **dùng W = 3**.

## Bài mẫu 5 — bài tập cô Lan bài 4 (có tính hiệu suất)

W ban đầu = 3; xét theo nhóm 5 báo nhận; ≥ 3 ACK có bit tắc → giảm với α = 0,8; ngược lại tăng với I = 2. ACK có bit tắc: 2, 3, 5, 7, 9, 12, 13. L = 1000 byte; R = 10 Mbps; TD = 5 ms. Tính hiệu suất.

Diễn biến cửa sổ:
| Nhóm ACK | ACK có bit tắc | Số tắc | Kết luận | W mới | W dùng |
|---|---|---|---|---|---|
| 1–5 | 2, 3, 5 | 3 | tắc → ×0,8 | 3·0,8 = 2,4 | 2 |
| 6–10 | 7, 9 | 2 | không → +2 | 2,4 + 2 = 4,4 | 4 |
| 11–15 | 12, 13 | 2 | không → +2 | 6,4 | 6 |

Thời gian: TF = 8000/10⁷ = 0,8 ms; mỗi khung nhận ACK sau TF + 2TD = 10,8 ms kể từ lúc bắt đầu phát.
Mô phỏng (cửa sổ trượt: được phát khung k khi k ≤ khung đã được ACK cuối cùng + W dùng; kênh phát nối tiếp):
| Khung | Bắt đầu phát (ms) | Nhận ACK (ms) |
|---|---|---|
| 1, 2, 3 | 0; 0,8; 1,6 | 10,8; 11,6; 12,4 |
| 4, 5, 6 | 10,8; 11,6; 12,4 | 21,6; 22,4; 23,2 |
| 7, 8 (W = 2 từ ACK5) | 21,6; 23,2 | 32,4; 34,0 |
| 9, 10 | 32,4; 34,0 | 43,2; 44,8 |
| 11, 12, 13, 14 (W = 4 từ ACK10) | 43,2; 44,8; 45,6; 46,4 | 54,0; 55,6; 56,4; 57,2 |
| 15, 16 (vẫn W = 4, phát khi nhận ACK11, ACK12) | 54,0; 55,6 | 64,8; 66,4 |

Hiệu suất khi truyền 16 khung = 16·0,8 / 66,4 ≈ **19,3%** (thời gian phát hữu ích / tổng thời gian đến khi nhận ACK khung cuối).

> Tài liệu tổng hợp chỉ vẽ diễn biến, không ra số hiệu suất. Cách tính trên là cách hợp lý theo định nghĩa η = thời gian phát / tổng thời gian; nếu đề quy định số khung khác thì làm tương tự. Ghi rõ cách tính khi đi thi.

## Bài mẫu 6 — thiết bị không thông minh (dựa trên bài tập cô Lan bài 2)

Wmax = 4, n = 2. Diễn biến mẫu:
- Đầu tiên W = 4: phát 1–4, nhận ACK đủ (W đã bằng Wmax nên giữ 4); phát 5–8.
- Khung 7 bị time-out → **W = 1** → phát lại 7.
- Nhận ACK của 7 (1 báo nhận, chưa đủ n = 2) → phát 8 (W = 1); nhận ACK của 8 (đủ 2 báo nhận) → **W = 2** → phát 9, 10.
- Nhận 2 ACK (9, 10) → **W = 3** → phát 11, 12, 13 → nhận đủ 2 ACK → **W = 4** (= Wmax, không tăng nữa) …

## Bài tự luyện

1. Ba liên kết A —6 Mbps— B —9 Mbps— C —4 Mbps— D. Kết nối 1: A→D; 2: A→B; 3: B→D; 4: C→D; 5: B→C. Phân chia băng thông theo max-min.
2. Thiết bị thông minh: W ban đầu = 6; nhóm 4 ACK; ≥ 2 ACK tắc → ×0,7; ngược lại +1. Bốn nhóm liên tiếp có số ACK tắc lần lượt 3, 1, 0, 2. Tìm W (thực và dùng) sau mỗi nhóm.
3. Thiết bị không thông minh Wmax = 6, n = 3. Đang ở W = 6 thì có time-out. Sau đó cần nhận bao nhiêu báo nhận để W trở lại 6?
4. (Lý thuyết, ≤ 5 dòng) Phân biệt điều khiển luồng và chống tắc nghẽn. Nêu hai cơ chế thiết bị mạng thông minh báo tắc nghẽn cho nguồn.

## Đáp án

1. Bước 1: AB 6/2 = 3 (1, 2); BC 9/3 = 3 (1, 3, 5); CD 4/3 ≈ 1,33 (1, 3, 4) → chốt **1 = 3 = 4 = 4/3 ≈ 1,33 Mbps**. Bước 2: AB còn 6 − 4/3 = 14/3 cho 2; BC còn 9 − 8/3 = 19/3 cho 5 → **2 = 14/3 ≈ 4,67**; **5 = 19/3 ≈ 6,33 Mbps**.
2. Nhóm 1 (3 ≥ 2, tắc): 6·0,7 = 4,2 → dùng **4**. Nhóm 2 (1 < 2, không tắc): 4,2 + 1 = 5,2 → dùng **5**. Nhóm 3 (0): 6,2 → dùng **6**. Nhóm 4 (2, tắc): 6,2·0,7 = 4,34 → dùng **4**.
3. Sau time-out W = 1; mỗi 3 báo nhận tăng 1: lên 6 cần 5 lần tăng → **15 báo nhận**.
4. Xem mục 1 (điều khiển luồng: phát ≤ khả năng thu, end-to-end/hop-by-hop; chống tắc nghẽn: lưu lượng vào ≤ khả năng mạng, truy nhập mạng/cấp phát bộ đệm). Hai cơ chế: gói cảnh báo độc lập; bit chỉ thị tắc nghẽn trong báo nhận.

## Trang sổ tay phòng thi (trang 9)

```
MAX-MIN: mỗi liên kết: dung lượng còn / số kết nối chưa chốt → liên kết nhỏ nhất = cổ chai
  → chốt các kết nối qua nó → trừ khỏi mọi liên kết chúng đi qua → lặp
  KIỂM TRA: tổng trên mỗi liên kết ≤ dung lượng
CỬA SỔ THÍCH ỨNG — thông minh: theo nhóm n ACK; ≥ ngưỡng bit tắc → W×α; ngược lại W+I
  W lẻ → dùng số nguyên gần nhất (vẫn giữ W thực để tính tiếp)
  không thông minh: bắt đầu Wmax; time-out → W = 1; mỗi n ACK → W+1 (≤ Wmax)
Hiệu suất: η = (số khung × TF) / thời điểm nhận ACK khung cuối
ĐK luồng: phát ≤ khả năng thu (end-to-end, hop-by-hop)
Chống tắc nghẽn: vào ≤ khả năng mạng (truy nhập mạng, cấp phát bộ đệm)
```
