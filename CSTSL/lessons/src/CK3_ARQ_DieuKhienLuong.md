# CK3 — Điều khiển luồng: Stop-and-Wait, Go-Back-N, Selective Repeat, cửa sổ, giản đồ thời gian

Nguồn: slide thầy Thanh CSTSL7–CSTSL9; đề cuối kỳ 20202, 20211, 20212, 20221Q, 20231Q, 20232; đề 2014, 2015. (Chưa có slide chương này của thầy Dũng — sẽ cập nhật.)
Điểm trong đề: 2–3,5 điểm. Câu dễ mất điểm vì đề hay đổi sơ đồ (ACK đi đường khác, nhiều chặng, có trạm chuyển tiếp).
Qua buổi khi: lập đúng TΣ cho mọi sơ đồ trong bài mẫu mà không nhìn lời giải; vẽ được giản đồ 3 cơ chế.

## 1. Bốn đại lượng gốc (luôn tính trước)

| Đại lượng | Công thức | Bẫy |
|---|---|---|
| Thời gian phát khung | **TF = L/R** | L phải tính bằng **bit** (byte × 8) |
| Trễ lan truyền | **TD = d/v**, v = c/n = 3·10⁸/n (hoặc đề cho v) | d bằng mét |
| Tỉ số | a = TD/TF | |
| Xác suất khung lỗi | p = 1 − (1 − BER)^L | L bằng bit |

## 2. Chu kỳ TΣ — bước quan trọng nhất

TΣ = thời gian từ lúc bắt đầu phát một khung đến lúc **nhận xong ACK** của nó (khi đó mới phát khung kế tiếp theo Stop-and-Wait).
- Trường hợp chuẩn (ACK nhỏ, bỏ qua xử lý): **TΣ = TF + 2TD**.
- Tổng quát: **TΣ = (phát khung trên từng chặng chiều đi) + (lan truyền chiều đi) + (trễ chuyển tiếp/xử lý ở trạm trung gian) + (phát ACK trên từng chặng chiều về) + (lan truyền chiều về)**.
- Store-and-forward: mỗi chặng phải phát lại toàn bộ khung → cộng L/Ci cho **mỗi** chặng.
- ACK đi đường khác (qua trạm R, B…): cộng thời gian phát ACK trên từng chặng của đường về theo **dung lượng chặng đó** + lan truyền + trễ chuyển tiếp.
Mẹo: vẽ giản đồ thời gian (cột S, R, D…) trước rồi đọc TΣ trên trục thời gian của nguồn.

## 3. Hiệu suất và tốc độ

| Cơ chế | Không lỗi | Có lỗi xác suất p (ACK không lỗi) |
|---|---|---|
| Stop-and-Wait | η = TF/TΣ = 1/(1 + 2a) | η = (1 − p)/(1 + 2a) |
| Go-Back-N, W ≥ 1 + 2a | η = 1 | η = (1 − p)/(1 + 2ap) |
| Go-Back-N, W < 1 + 2a | η = W·TF/TΣ = W/(1 + 2a) | η = W(1 − p)/[(1 + 2a)(1 − p + Wp)] |
| Selective Repeat, W ≥ 1 + 2a | η = 1 | η = 1 − p |
| Selective Repeat, W < 1 + 2a | η = W/(1 + 2a) | η = W(1 − p)/(1 + 2a) |

(Khi TΣ ≠ TF + 2TD thì thay 1 + 2a bằng TΣ/TF.)
- **Cửa sổ nhỏ nhất để hiệu suất 100% / tốc độ lớn nhất:** W·TF ≥ TΣ → **W ≥ TΣ/TF**, làm tròn lên.
- **Tốc độ truyền tin (thông lượng):** R_tt = η·R = L/(thời gian trung bình để truyền thành công một khung).
- **Stop-and-Wait có mất gói và timeout** (không có NAK): mỗi lần mất tốn thêm một khoảng T_out; số lần mất trung bình = p/(1 − p) → thời gian cho 1 khung thành công = **TΣ + [p/(1 − p)]·T_out** → tốc độ = L / thời gian đó.
- **Nhiều chặng có xác suất mất khác nhau:** xác suất khung tới đích = Π(1 − p_chặng đi); xác suất ACK về = Π(1 − p_chặng về); xác suất một khung được xác nhận = tích hai số đó.

## 4. Giản đồ thời gian — cách vẽ để ăn điểm (1,5 điểm ở đề 20202, 20232)

Quy ước: mỗi trạm một trục thẳng đứng (thời gian đi xuống). Khung = dải xiên từ trục phát sang trục thu, độ dày bằng TF; ACK = mũi tên xiên mảnh chiều ngược lại; khung mất = mũi tên dừng giữa đường có dấu ×; ghi tên khung (số thứ tự SN) và ACK (RN = số khung tiếp theo muốn nhận).

- **Stop-and-Wait:** phát khung 0 → đợi ACK1 → phát khung 1 … Khung mất: không có ACK → hết **time-out** (vẽ đoạn ngoặc ghi "time-out" trên trục nguồn) → phát lại cùng khung. ACK mất: bên thu đã nhận đúng nhưng bên phát hết time-out phát lại → bên thu nhận trùng, bỏ đi và gửi lại ACK.
- **Go-Back-N (cửa sổ W):** phát liên tục W khung. Khung i lỗi/mất → bên thu **huỷ (cancel) mọi khung sau i**, gửi NAK i (hoặc không gửi gì → time-out) → bên phát **phát lại từ khung i trở đi**. ACK i+n đến trước time-out của khung i thì coi như khung i đã nhận đúng (ACK tích luỹ).
- **Selective Repeat (cửa sổ W):** chỉ khung lỗi/mất được phát lại; bên thu **lưu đệm** các khung đến sau, khi khung bị thiếu tới thì giao lên theo đúng thứ tự.
- Đề có trạm trung gian R: vẽ 3 trục S, R, D; tại R vẽ thêm đoạn trễ chuyển tiếp trước khi R phát tiếp; nếu ARQ trên từng liên kết thì mỗi liên kết có ACK riêng.

## Bài mẫu 1 — slide thầy Thanh (Stop-and-Wait cơ bản)

d = 100 m; v = 2·10⁸ m/s; R = 10 Mbps; L = 500 bit.
- TF = 500/10⁷ = 50 µs; TD = 100/(2·10⁸) = 0,5 µs; a = 0,01.
- η = 1/(1 + 2·0,01) ≈ **98%**.

## Bài mẫu 2 — đề cuối kỳ 20232, câu 3 (ACK đi vòng qua R)

Đề: S gửi tới D bằng Stop-and-Wait, khung 512 byte, ACK 128 byte. Khung đi thẳng S → D (trễ lan truyền d ms, 10 Mbps). ACK đi D → R (3 ms, 5 Mbps) rồi R → S (2 ms, 10 Mbps); R gây trễ chuyển tiếp 1 ms. (Hình: docs/Đề CK/CK_20232.JPG, góc dưới.)
1. Vẽ biểu đồ truyền tin; tìm d để tốc độ truyền tin đạt 500 kbps khi không lỗi.
2. Xác suất mất khung p = 0,2; d = 3 ms; ACK không lỗi; time-out 30 ms. Tính tốc độ truyền tin.

Lời giải:
- TF khung = 512·8/10⁷ = **0,4096 ms**.
- ACK trên D → R (5 Mbps): 128·8/(5·10⁶) = **0,2048 ms**; trên R → S (10 Mbps): **0,1024 ms**.
- TΣ = 0,4096 + d + 0,2048 + 3 + 1 + 0,1024 + 2 = **d + 6,7168 ms**.
- (1) Giản đồ: 3 trục S, R, D; khung xiên S → D (độ dày 0,4096 ms, lan truyền d); tại D phát ACK sang R (0,2048 ms + 3 ms); tại R chờ 1 ms rồi phát ACK sang S (0,1024 ms + 2 ms); S nhận xong ACK mới phát khung tiếp.
  Tốc độ 500 kbps: TΣ = 4096 bit / 500 kbps = 8,192 ms → d = 8,192 − 6,7168 = **1,4752 ms**.
- (2) d = 3 → TΣ = 9,7168 ms. Mỗi khung thành công cần trung bình p/(1 − p) = 0,25 lần mất, mỗi lần mất tốn 30 ms time-out.
  Thời gian/khung = 9,7168 + 0,25·30 = 17,2168 ms → tốc độ = 4096/17,2168 ms ≈ **237,9 kbps**.

> Tài liệu tổng hợp tính phát ACK trên D → R theo 10 Mbps (đúng là 5 Mbps) nên ra d = 1,5776 ms, và ghi đơn vị kết quả là "bps" (đúng là kbps). Nếu thầy hiểu time-out tính từ lúc phát xong khung thì mỗi lần mất tốn 30 + 0,4096 ms → ≈ 236,5 kbps — ghi rõ giả thiết khi làm.

## Bài mẫu 3 — đề cuối kỳ 20212, câu 3 (Selective Repeat, ACK qua B)

Đề: S → R → D, khung 512 byte; ACK 256 byte đi D → B → S. Lan truyền (S,R) 5 ms, (R,D) 7 ms, (D,B) 4 ms, (B,S) 2 ms; mọi liên kết 5 Mbps.
1. Kích thước cửa sổ nhỏ nhất để tốc độ đạt lớn nhất (không lỗi).
2. Xác suất mất gói (S,R) 20%, (R,D) 10%, (D,B) 0%, (B,S) 15%; W = 5; time-out 50 ms. Tính độ sử dụng đường truyền.

Lời giải:
- TF khung = 4096/(5·10⁶) = **0,8192 ms**; TF ACK = 2048/(5·10⁶) = **0,4096 ms**.
- Store-and-forward: khung phát 2 lần (S→R, R→D), ACK phát 2 lần (D→B, B→S):
  TΣ = 2·0,8192 + 5 + 7 + 2·0,4096 + 4 + 2 = **20,4576 ms**.
- (1) W ≥ TΣ/TF = 20,4576/0,8192 ≈ 24,97 → **W_min = 25**.
- (2) Xác suất khung tới D: 0,8·0,9 = 0,72; ACK về S: 1·0,85 = 0,85; một khung được xác nhận: ps = 0,612.
  W·TF = 4,096 ms < TΣ → cửa sổ giới hạn. Mô hình đơn giản: mỗi chu kỳ TΣ phát W khung, trung bình ps phần thành công:
  η ≈ W·TF·ps/TΣ = 5·0,8192·0,612/20,4576 ≈ **12,3%**.

> Tài liệu tổng hợp chỉ cộng thời gian phát khung và ACK một lần (bỏ qua việc R và B phát lại) nên ra TΣ = 19,23 ms, W = 24, η = 13,0%. Cách cộng theo từng chặng ở trên khớp công thức trễ đầu cuối Σ(L/Ci + tpi) trong slide.

## Bài mẫu 4 — đề 2015 đề 2, câu 2 (vệ tinh địa tĩnh, Go-Back-N)

Đề: liên kết qua vệ tinh địa tĩnh, khoảng cách 36 000 km, tốc độ 1 Mbps, khung 1500 byte.
- TF = 12 000/10⁶ = **12 ms**; TD = 36·10⁶/(3·10⁸) = **120 ms**; a = 10.
- (2.1) Cửa sổ để hiệu suất 100% khi không lỗi: W ≥ 1 + 2a = **21**.
- (2.2) BER = 10⁻⁹: p = 1 − (1 − 10⁻⁹)^12000 ≈ 1,2·10⁻⁵. Với W ≥ 21: η = (1 − p)/(1 + 2ap) ≈ **99,97%** (gần như 100%).

> Lời giải viết tay trong "Ôn tập đề thi CSTSL.pdf" lấy TF = 1500/10⁶ (quên nhân 8) nên ra W ≥ 161 — sai.

## Bài tự luyện (có ô chấm)

1. Cáp quang dài 2000 km, chiết suất 1,5, tốc độ 1 Mbps, khung 1000 bit. Tính a, hiệu suất Stop-and-Wait, và cửa sổ nhỏ nhất để hiệu suất 100%.
2. Cùng liên kết bài 1, xác suất khung lỗi p = 0,1. Tính hiệu suất của Stop-and-Wait; Go-Back-N với W = 7; Selective Repeat với W = 7; và hai cơ chế cửa sổ khi W ≥ 21.
3. BER = 10⁻⁴, khung 1000 bit, a = 0,5. Tính xác suất khung lỗi và hiệu suất Stop-and-Wait.
4. Stop-and-Wait có TΣ = 10 ms, khung 4000 bit, xác suất mất khung 0,3, time-out 20 ms. Tính tốc độ truyền tin.
5. Vẽ giản đồ Go-Back-N với W = 4 khi khung 3 bị mất (khung 1–6 cần gửi).
6. Vẽ giản đồ Selective Repeat với W = 4 khi khung 2 bị lỗi và báo nhận của khung 4 (ACK5) bị mất.

## Đáp án

1. v = 2·10⁸ m/s; TD = 10 ms; TF = 1 ms; **a = 10**; η = 1/21 ≈ **4,76%**; **W ≥ 21**.
2. Stop-and-Wait: 0,9/21 ≈ **4,29%**. GBN W = 7: 7·0,9/(21·(0,9 + 0,7)) = **18,75%**. SR W = 7: 7·0,9/21 = **30%**. Khi W ≥ 21: GBN = 0,9/(1 + 2) = **30%**; SR = **90%**.
3. p = 1 − 0,9999¹⁰⁰⁰ ≈ **0,0952**; η = 0,9048/2 ≈ **45,2%**.
4. 10 + (0,3/0,7)·20 ≈ 18,57 ms/khung → 4000/18,57 ms ≈ **215,4 kbps**.
5. Phát 1, 2, 3, 4; khung 3 mất → bên thu nhận 4 thấy sai thứ tự, huỷ 4, gửi NAK3 (hoặc bên phát chờ time-out của 3); bên phát nhận ACK2, ACK3 cho khung 1, 2 → trượt cửa sổ phát 5, 6 (bị huỷ) → khi nhận NAK3/time-out phát lại **3, 4, 5, 6**.
6. Phát 1–4; khung 2 lỗi → bên thu lưu 3, 4, gửi NAK2; báo nhận của khung 4 (ACK5) bị mất; bên phát chỉ phát lại **khung 2**; khi khung 2 tới, bên thu gửi ACK tích luỹ ACK5 (RN = 5) → bên phát biết 3, 4 đã tới, không cần phát lại 4 (chỉ khi không nhận được ACK5 nào trước time-out của khung 4 mới phát lại 4).

## Trang sổ tay phòng thi (trang 8)

```
TF = L/R (L bằng BIT)   TD = d/v, v = 3·10⁸/n   a = TD/TF   p = 1 − (1 − BER)^L
TΣ = phát khung từng chặng đi + lan truyền đi + trễ chuyển tiếp + phát ACK từng chặng về + lan truyền về
     chuẩn: TΣ = TF + 2TD
S&W:  η = TF/TΣ = 1/(1+2a);  có lỗi ×(1−p)
GBN:  W ≥ 1+2a: (1−p)/(1+2ap);   W < 1+2a: W(1−p)/[(1+2a)(1−p+Wp)]
SR:   W ≥ 1+2a: 1−p;              W < 1+2a: W(1−p)/(1+2a)
W_min (100%) = ⌈TΣ/TF⌉;   tốc độ = η·R = L / (thời gian TB cho 1 khung thành công)
Mất gói + time-out: thời gian/khung = TΣ + [p/(1−p)]·T_out
Nhiều chặng: ps = Π(1−p_đi)·Π(1−p_về)
Giản đồ: S&W phát lại sau time-out; GBN phát lại từ khung lỗi trở đi; SR chỉ phát lại khung lỗi
```

Lỗi hay mắc:
- L bằng byte mà không nhân 8.
- Tính phát ACK theo dung lượng của chặng khác.
- Chỉ cộng thời gian phát một lần cho đường nhiều chặng (store-and-forward phải cộng mỗi chặng).
- Quên trễ chuyển tiếp ở trạm trung gian.
- Nhầm "tốc độ truyền tin" (kbps) với "hiệu suất" (%).
