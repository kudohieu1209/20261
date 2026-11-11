# GK6 — Ba đề thi thử giữa kỳ, đúng hình thức thầy báo: tự luận, 60 phút, được dùng tài liệu giấy

Thông tin thi (thầy Nguyễn Xuân Dũng): 100% tự luận; 60 phút; được dùng tài liệu giấy (photo hoặc ghi chép); thi đến hết phần hàng đợi; **làm được các ví dụ trên lớp sẽ có lợi thế**.
Vì vậy cả ba đề đều là **biến thể đổi số của các ví dụ trên lớp** (tổng đài 1080, xe buýt, M/M/1/3 tự lập phương trình, quầy siêu thị, bãi gửi xe, call center, tổng đài cơ quan, CPU nhiều nhân, mạng 4 nút).

Cách làm: bấm giờ **60 phút** mỗi đề; chỉ dùng tài liệu **giấy** (tập A4 đen trắng đủ 7 chủ đề); trình bày tự luận đủ 5 dòng: mô hình → tham số → công thức → thay số → kết luận. Làm xong cả đề mới lật lời giải; tự chấm theo thang điểm.
Thứ tự: Đề A và B chỉ gồm hàng đợi đơn (chắc chắn thi). Đề C có thêm mạng hàng đợi (làm nếu thầy dạy tới trước ngày thi).
Mục tiêu: ≥ 8/10 ở đề A, ≥ 9/10 ở đề B và C, xong trước giờ 5 phút.

---

## ĐỀ A (60 phút, được dùng tài liệu giấy)

**Câu 1 (3 điểm).** Cuộc gọi đến một tổng đài theo tiến trình Poisson, trung bình 6 cuộc/phút.
a) Tính xác suất có đúng 10 cuộc gọi đến trong 2 phút.
b) Tính xác suất khoảng thời gian giữa hai cuộc gọi liên tiếp nhỏ hơn 15 giây.
c) Biết 30% số cuộc gọi là cuộc gọi quốc tế. Tính xác suất trong 1 phút không có cuộc gọi quốc tế nào.

**Câu 2 (4 điểm).** Cho hàng đợi M/M/1/4. Số cuộc gọi đến hệ thống là 4 cuộc/phút; số cuộc gọi rời khỏi hệ thống là 5 cuộc/phút.
a) Biểu diễn quá trình sinh – tử của hệ thống.
b) Tự tìm mối quan hệ giữa các xác suất và tính xác suất các trạng thái (không dùng công thức cho sẵn).
c) Tính xác suất một cuộc gọi bị từ chối và số cuộc gọi trung bình trong hệ thống.
d) Tính thời gian trung bình một cuộc gọi trong hệ thống.

**Câu 3 (3 điểm).** Call center có 3 điện thoại viên. Trong 20 phút có trung bình 8 khách gọi đến (Poisson); thời gian trung bình một cuộc gọi là 4 phút (phân bố mũ). Khi các bàn đều bận, khách nghe nhạc chờ.
a) Tính xác suất một khách hàng được phục vụ ngay.
b) Chỉ tiêu chất lượng: không quá 10% khách phải đợi. Chỉ tiêu có đạt không? Nếu không, cần tối thiểu bao nhiêu điện thoại viên?

---

## ĐỀ B (60 phút, được dùng tài liệu giấy)

**Câu 1 (3 điểm).** Khách đi vào quầy tính tiền duy nhất của một cửa hàng theo tiến trình Poisson, trung bình 30 khách/giờ. Thời gian phục vụ một khách phân bố mũ, trung bình 1,5 phút. Cửa hàng đủ chỗ xếp hàng.
a) Tính thời gian chờ trung bình của một khách và số khách trung bình trong hệ thống.
b) Tính xác suất để một khách từ lúc vào xếp hàng đến lúc trả tiền xong không quá 3 phút.
c) Tốc độ khách đến tối đa là bao nhiêu để thời gian chờ trung bình không quá 3 phút?

**Câu 2 (3 điểm).** Tổng đài cơ quan có 4 đường trung kế nối với tổng đài công cộng. Cuộc gọi ra trung bình 10 cuộc/giờ, cuộc gọi vào 14 cuộc/giờ (đều Poisson). Thời gian chiếm kênh trung bình một cuộc là 2,5 phút (phân bố mũ).
a) Tính tải của tổng đài theo Erlang.
b) Tính xác suất một cuộc gọi bị từ chối do nghẽn mạch.
c) Cần tối thiểu bao nhiêu trung kế để xác suất nghẽn không quá 1%?

**Câu 3 (4 điểm).** CPU máy chủ có 2 nhân. Số tác vụ cần xử lý trung bình 30 task/ms (Poisson); thời gian xử lý trung bình một tác vụ là 0,05 ms (phân bố mũ).
a) Giả thiết bộ nhớ đệm đủ lớn. Tính thời gian trung bình từ lúc nhận yêu cầu đến khi hoàn thành tác vụ và số tác vụ trung bình trong máy.
b) Giả thiết bộ nhớ đệm chỉ chứa tối đa 3 tác vụ. Vẽ đồ hình trạng thái; tính xác suất một tác vụ bị từ chối và xác suất một tác vụ phải đợi mà không được phục vụ ngay.

---

## ĐỀ C (60 phút, được dùng tài liệu giấy) — có mạng hàng đợi

**Câu 1 (2 điểm).**
a) Hệ thống đóng là gì? Trong các hàng đợi M/M/1/∞, M/M/1/k, M/M/c/c, M/D/1/∞, hàng đợi nào là hệ thống đóng?
b) Một router có trung bình 12 gói nằm trong router, thông lượng 400 gói/s. Tính thời gian trung bình một gói lưu lại router. Dùng định lý nào, điều kiện áp dụng?

**Câu 2 (4 điểm).** Bãi gửi xe có một cổng với 01 nhân viên; có chỗ cho 5 khách đợi. Khách vào trung bình 2 khách/phút (Poisson); thời gian nhân viên xử lý một xe trung bình 20 giây (phân bố mũ).
a) Mô hình hoá hệ thống theo ký hiệu Kendall.
b) Tính xác suất khách được phục vụ ngay và xác suất bãi bị tắc do người tới quá đông.
c) Tính thời gian trung bình khách phải đợi cho đến khi được phục vụ.

**Câu 3 (4 điểm).** Cho mạng hàng đợi mở 4 nút có sơ đồ như ví dụ trên lớp (slide tr. 87): yêu cầu từ ngoài vào nút 4 với γ4 = 5 yêu cầu/s; nút 4 → nút 1; nút 1 → nút 2 (r12 = 0,4) và nút 3 (r13 = 0,6); nút 2 → nút 1 (r21 = 1); nút 3 → nút 1 (r31 = 0,5), ra ngoài (r30 = 0,5). 1/μ1 = 0,02 s; 1/μ2 = 0,03 s; 1/μ3 = 0,04 s; 1/μ4 = 0,05 s. (Hình: cắt từ docs/slide's thầy Dũng/03-HangDoi.pdf trang 87, nửa phải.)
a) Tính λ1, λ2, λ3, λ4.
b) Tính N1, N2, N3, N4 và số yêu cầu trung bình N trong hệ thống.
c) Tính xác suất để hệ thống không có yêu cầu nào.
d) Tính thời gian lưu lại trung bình T của một yêu cầu trong hệ thống.
e) Giữ r30, r31 không đổi, tìm điều kiện của r12, r13 để hệ thống ổn định.

---

## LỜI GIẢI ĐỀ A

**Câu 1.**
a) λt = 6·2 = 12 → P{N = 10} = 12¹⁰·e^(−12)/10! ≈ **0,105**. (1đ)
b) λ = 6 cuộc/phút, t = 15 s = 0,25 phút → P{T < 0,25} = 1 − e^(−6·0,25) = 1 − e^(−1,5) ≈ **0,777**. (1đ)
c) Tách luồng: cuộc quốc tế là Poisson với λq = 6·0,3 = 1,8 cuộc/phút → P{0 cuộc trong 1 phút} = e^(−1,8) ≈ **0,165**. (1đ)

**Câu 2.** λ = 4, μ = 5 (cuộc/phút); trạng thái 0, 1, 2, 3, 4.
a) Đồ hình: 5 vòng tròn 0–4; mũi tên sang phải ghi λ = 4; mũi tên sang trái ghi μ = 5. (0,75đ)
b) Phương trình cân bằng (ra = vào): (1,5đ)
- Trạng thái 0: 4p0 = 5p1.
- Trạng thái 1: 9p1 = 4p0 + 5p2.
- Trạng thái 2: 9p2 = 4p1 + 5p3.
- Trạng thái 3: 9p3 = 4p2 + 5p4.
- Trạng thái 4: 5p4 = 4p3.
- Suy ra liên tiếp: p1 = 0,8p0; p2 = 0,64p0; p3 = 0,512p0; p4 = 0,4096p0.
- Chuẩn hoá: p0(1 + 0,8 + 0,64 + 0,512 + 0,4096) = 3,3616p0 = 1 → **p0 ≈ 0,2975; p1 ≈ 0,2380; p2 ≈ 0,1904; p3 ≈ 0,1523; p4 ≈ 0,1218**.
c) P_B = p4 ≈ **0,122**; N = 1·0,2380 + 2·0,1904 + 3·0,1523 + 4·0,1218 ≈ **1,563 cuộc gọi**. (1đ)
d) Tốc độ vào thực tế: λ(1 − P_B) = 4·0,8782 ≈ 3,513 cuộc/phút → T = N/[λ(1 − P_B)] = 1,563/3,513 ≈ **0,445 phút ≈ 26,7 giây**. (0,75đ)

**Câu 3.** Mô hình M/M/c/∞. λ = 8/20 = 0,4 cuộc/phút; μ = 1/4 = 0,25 cuộc/phút; a = λ/μ = 1,6.
a) c = 3: ρ = 1,6/3 ≈ 0,533. p0 = 1/[(1 + 1,6 + 1,28) + 1,6³/(3!·0,4667)] = 1/(3,88 + 1,4629) ≈ 0,1872. C(3; 1,6) = 1,4629·0,1872 ≈ 0,274 → xác suất được phục vụ ngay = 1 − 0,274 = **0,726**. (1,75đ)
b) 27,4% > 10% → **không đạt**. Thử c = 4: ρ = 0,4; p0 = 1/(4,5627 + 0,4551) ≈ 0,1993; C(4; 1,6) = 0,4551·0,1993 ≈ **0,091** ≤ 10% → cần tối thiểu **4 điện thoại viên**. (1,25đ)

---

## LỜI GIẢI ĐỀ B

**Câu 1.** Mô hình M/M/1/∞. λ = 30/60 = 0,5 khách/phút; μ = 1/1,5 = 0,6667 khách/phút; ρ = 0,75 < 1.
a) Tq = (1/μ)·ρ/(1 − ρ) = 1,5·3 = **4,5 phút**; N = ρ/(1 − ρ) = **3 khách**. (1đ)
b) P{T ≤ 3} = 1 − e^(−(μ−λ)·3) = 1 − e^(−0,1667·3) = 1 − e^(−0,5) ≈ **0,393**. (1đ)
c) Tq = λ/[μ(μ − λ)] ≤ 3 → λ ≤ 3μ² − 3μλ → λ(1 + 3μ) ≤ 3μ² → λ ≤ 3·0,4444/3 = 0,4444 khách/phút ≈ **26,7 khách/giờ**. (1đ)

**Câu 2.** Mô hình M/M/c/c (không có chỗ chờ).
a) Ghép luồng: λ = 10 + 14 = 24 cuộc/giờ; a = 24·2,5/60 = **1 Erlang**. (0,75đ)
b) c = 4: B(4; 1) = (1⁴/4!)/(1 + 1 + 1/2 + 1/6 + 1/24) = 0,04167/2,7083 ≈ **0,0154 (1,54%)**. (1,25đ)
c) 1,54% > 1% → thử c = 5: B(5; 1) = (1/120)/2,7167 ≈ 0,0031 ≤ 1% → cần tối thiểu **5 trung kế**. (1đ)

**Câu 3.** λ = 30 task/ms; μ = 1/0,05 = 20 task/ms; c = 2; a = 1,5; ρ = 0,75.
a) Mô hình M/M/2/∞. p0 = 1/[(1 + 1,5) + 1,5²/(2!·0,25)] = 1/(2,5 + 4,5) = 1/7 ≈ 0,1429. C(2; 1,5) = 4,5/7 ≈ 0,643. (2đ)
- Nq = C·ρ/(1 − ρ) = 0,643·3 ≈ 1,929; N = Nq + a ≈ **3,43 tác vụ**.
- T = 1/μ + C/(cμ − λ) = 0,05 + 0,643/10 ≈ **0,114 ms**.
b) 3 chỗ trong bộ đệm + 2 nhân → k = 5 → mô hình **M/M/2/5**. (2đ)
- Đồ hình: trạng thái 0…5; sinh λ = 30 ở mọi mũi tên sang phải; tử: 1→0 là μ = 20; 2→1, 3→2, 4→3, 5→4 là 2μ = 40.
- Quan hệ: p1 = 1,5p0; p2 = 1,125p0; p3 = 0,84375p0; p4 = 0,63281p0; p5 = 0,47461p0. Tổng hệ số = 5,57617 → p0 ≈ 0,1793.
- p1 ≈ 0,2690; p2 ≈ 0,2018; p3 ≈ 0,1513; p4 ≈ 0,1135; **P_B = p5 ≈ 0,0851**.
- Xác suất phải đợi (cách thầy chữa trên lớp): 1 − (p0 + p1) ≈ **0,552** (trong đó 0,085 là bị từ chối; phần phải đợi rồi được phục vụ là p2 + p3 + p4 ≈ 0,467). Ghi cả hai con số và nói rõ cách hiểu.

---

## LỜI GIẢI ĐỀ C

**Câu 1.**
a) Hệ thống đóng: số yêu cầu đi vào = số đã đi ra + số đang nằm trong hệ; hệ không tự sinh ra cũng không huỷ yêu cầu. (0,5đ) Là hệ thống đóng (khi ρ < 1): **M/M/1/∞, M/D/1/∞**. Không phải: **M/M/1/k, M/M/c/c** vì có yêu cầu bị từ chối. (0,5đ)
b) Định lý Little: T = N/λ = 12/400 = **0,03 s = 30 ms**. (0,5đ) Áp dụng cho hệ thống đóng ở chế độ ổn định, không phụ thuộc phân bố của tiến trình tới và phục vụ. (0,5đ)

**Câu 2.** λ = 2 khách/phút; μ = 60/20 = 3 khách/phút; ρ = 2/3.
a) 1 server, 5 chỗ chờ → k = 6 → **M/M/1/6**. (0,75đ)
b) p0 = (1 − ρ)/(1 − ρ⁷) = 0,3333/(1 − 0,05853) ≈ **0,354** (xác suất được phục vụ ngay). P_B = p6 = ρ⁶·p0 = 0,08779·0,354 ≈ **0,031** (3,1%). (1,75đ)
c) N = ρ/(1 − ρ) − 7ρ⁷/(1 − ρ⁷) = 2 − 7·0,05853/0,94147 ≈ 1,565; Nq = N − (1 − p0) ≈ 0,919; λ thực tế = 2·(1 − 0,031) ≈ 1,938 → Tq = 0,919/1,938 ≈ **0,474 phút ≈ 28,5 giây**. (1,5đ)

**Câu 3.**
a) λ4 = 5; λ1 = λ4 + λ2 + 0,5λ3; λ2 = 0,4λ1; λ3 = 0,6λ1 → λ1 = 5 + 0,4λ1 + 0,3λ1 → 0,3λ1 = 5 → **λ1 ≈ 16,67; λ2 ≈ 6,67; λ3 = 10; λ4 = 5** (yêu cầu/s). Kiểm tra: ra ngoài = 0,5·10 = 5 = γ4 ✔. (1đ)
b) ρ1 = 0,333; ρ2 = 0,2; ρ3 = 0,4; ρ4 = 0,25 → **N1 = 0,5; N2 = 0,25; N3 = 0,667; N4 = 0,333**; N = **1,75 yêu cầu**. (1đ)
c) P0 = (1 − 0,333)(1 − 0,2)(1 − 0,4)(1 − 0,25) = **0,24**. (0,5đ)
d) T = N/γ4 = 1,75/5 = **0,35 s**. (0,5đ)
e) λ1 = 5 + (1 − r13)λ1 + 0,5r13λ1 → λ1 = 10/r13; λ2 = 10(1 − r13)/r13; λ3 = 10; λ4 = 5. ρ1 = 0,2/r13 < 1 → r13 > 0,2; ρ2 = 0,3(1 − r13)/r13 < 1 → r13 > 0,231; ρ3 = 0,4; ρ4 = 0,25 → **r13 > 0,231 và r12 = 1 − r13 < 0,769**. (1đ)

---

## Bảng tự chấm

| | Đề A | Đề B | Đề C |
|---|---|---|---|
| Câu 1 | /3 | /3 | /2 |
| Câu 2 | /4 | /3 | /4 |
| Câu 3 | /3 | /4 | /4 |
| Tổng | /10 | /10 | /10 |
| Thời gian làm | phút | phút | phút |
