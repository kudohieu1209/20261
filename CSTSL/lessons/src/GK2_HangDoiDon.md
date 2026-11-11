# GK2 — Các hàng đợi đơn: M/M/1/1, M/M/1/k, M/M/c, M/M/c/c, M/M/c/k, M/M/∞, M/G/1, M/D/1

Nguồn: slide thầy Dũng chương 3 (03-HangDoi.pdf), trang 18–66. Toàn bộ bài mẫu là ví dụ trong slide của thầy.

Cách học: đọc bảng "Đọc đề → chọn mô hình", rồi từng mô hình (khuôn + bài mẫu), làm 10 bài tự luyện, dò đáp án, chép sổ tay.
Qua buổi khi: đúng ≥ 8/10 bài, nhìn đề là gọi đúng tên mô hình.

## 0. Ký hiệu Kendall theo thầy Dũng và cách chọn mô hình

Ký hiệu A/B/c/k: A = tiến trình tới (M = Poisson/Markov, D = tất định, G = bất kỳ); B = tiến trình phục vụ (M = thời gian phục vụ phân bố mũ); c = số server; k = **dung lượng hệ thống** (số yêu cầu tối đa trong hệ thống = số chỗ trong hàng đợi + số server). Thiếu k nghĩa là k = ∞.

Ký hiệu chung: a = λ/μ (tải tính theo Erlang); ρ = λ/(cμ) (tải mỗi server); N, Nq, Ns; T, Tq, Ts; P_B = xác suất yêu cầu bị từ chối.

| Đề viết | Mô hình | Chú ý |
|---|---|---|
| 1 server, **không có chỗ chờ** (ATM 1 máy, kênh 1 cuộc) | M/M/1/1 | đến lúc bận là bị từ chối |
| 1 server, chỗ chờ **vô hạn / đủ lớn** | M/M/1 (= M/M/1/∞) | GK1 |
| 1 server, chỗ chờ **giới hạn Q chỗ** | M/M/1/k với **k = Q + 1** | bẫy: "đủ chỗ cho 10 người đợi" → k = 11 |
| c server, chỗ chờ vô hạn (call center có nhạc chờ, CPU nhiều nhân) | M/M/c (Erlang C) | hỏi "xác suất phải đợi" |
| c server, **không có chỗ chờ** (c đường trung kế, c kênh) | M/M/c/c (Erlang B) | hỏi "xác suất nghẽn / từ chối" |
| c server, tổng sức chứa k | M/M/c/k | |
| vô số server (ai đến cũng được phục vụ ngay) | M/M/∞ | |
| thời gian phục vụ **không phải mũ**, cho trung bình và phương sai | M/G/1 | |
| thời gian phục vụ **cố định** (gói dài bằng nhau) | M/D/1 | |

Hệ thống có từ chối (k hữu hạn): luôn dùng **λ thực tế = λ(1 − P_B)** khi áp Little: T = N / (λ(1 − P_B)).

## 1. M/M/1/1 — một server, không có chỗ chờ

Khuôn giải: ρ = λ/μ.
- p0 = 1/(1 + ρ); p1 = ρ/(1 + ρ).
- Xác suất bị từ chối: P_B = p1 = **λ/(λ + μ)**.
- N = p1 = λ/(λ + μ); T = Ts = 1/μ.

Bài mẫu (slide tr. 29): Điểm rút tiền có 1 máy ATM. Người đến 10 người/giờ (Poisson), mỗi người cần trung bình 3 phút. Xác suất một người đến mà không được phục vụ (giả thiết không ai đứng chờ)?
- λ = 10/giờ; μ = 60/3 = 20/giờ.
- P_B = 10/(10 + 20) = **1/3 ≈ 0,333**.

## 2. M/M/1/k — một server, sức chứa k (hàng đợi Q = k − 1 chỗ)

Khuôn giải (ρ = λ/μ, ρ ≠ 1):
1. p0 = (1 − ρ)/(1 − ρ^(k+1)); p_n = ρ^n · p0 (n = 0 … k).
2. P_B = p_k = ρ^k (1 − ρ)/(1 − ρ^(k+1)).
3. N = ρ/(1 − ρ) − (k + 1)ρ^(k+1)/(1 − ρ^(k+1)).
4. Nq = N − (1 − p0).
5. λ thực tế = λ(1 − P_B); T = N/(λ(1 − P_B)); Tq = Nq/(λ(1 − P_B)).

Trường hợp ρ = 1 (λ = μ): p0 = p1 = … = p_k = 1/(k + 1); N = k/2; Nq = N − (1 − p0).

Ghi nhớ: M/M/1/k **luôn ổn định** kể cả khi ρ ≥ 1 (hàng đợi không thể dài vô hạn); P_B > 0 ngay cả khi ρ < 1 vì yêu cầu đến ngẫu nhiên có lúc dồn dập làm đầy bộ đệm.

Bài mẫu (slide tr. 43): Bãi gửi xe máy có 1 cổng, 1 nhân viên; chỗ cho 10 khách đợi. Khách đến 3 khách/phút (Poisson); nhân viên xử lý trung bình 15 giây/xe (mũ). Tính: xác suất khách được phục vụ ngay; thời gian trung bình phải đợi đến khi được phục vụ; xác suất bãi bị tắc do người tới quá đông.
- λ = 3/phút; μ = 60/15 = 4/phút; ρ = 0,75; chỗ đợi Q = 10 → **k = 11**.
- p0 = (1 − 0,75)/(1 − 0,75^12) ≈ **0,258** → xác suất được phục vụ ngay.
- P_B = p11 = 0,75^11 · p0 ≈ **0,0109** → xác suất bãi bị tắc (khách đến phải bỏ đi) ≈ 1,09%.
- N = 0,75/0,25 − 12·0,75^12/(1 − 0,75^12) ≈ 2,607; Nq = N − (1 − p0) ≈ 1,866.
- λ thực tế = 3 · (1 − 0,0109) ≈ 2,967/phút; Tq = 1,866/2,967 ≈ **0,629 phút ≈ 37,7 giây**.

## 2b. Tự lập phương trình cân bằng sinh – tử (thầy cho bài trên lớp, yêu cầu KHÔNG dùng công thức có sẵn)

Đề trên lớp: Cho hàng đợi M/M/1/3. Cuộc gọi đến 2 cuộc/phút; cuộc gọi rời khỏi hệ thống (được phục vụ xong) 4 cuộc/phút. (a) Biểu diễn quá trình sinh – tử. (b) Tự tìm mối quan hệ giữa các xác suất và tính xác suất các trạng thái (không dùng công thức cho sẵn). (c) Tính số cuộc gọi trung bình trong hệ thống. (d) Tính thời gian trung bình một cuộc gọi trong hệ thống.

Khuôn giải (dùng cho mọi hàng đợi Markov, kể cả M/M/c/k, M/M/c/c):
1. **Liệt kê trạng thái**: trạng thái n = số yêu cầu trong hệ thống, n = 0, 1, …, k.
2. **Vẽ đồ hình**: các vòng tròn 0, 1, …, k; mũi tên sang phải (sinh) ghi λ; mũi tên sang trái (tử) ghi tốc độ phục vụ khi có n yêu cầu (1 server: μ; c server: nμ nếu n ≤ c, cμ nếu n ≥ c). Trạng thái cuối k không có mũi tên sinh.
3. **Viết phương trình cân bằng cho từng trạng thái**: tốc độ đi ra khỏi trạng thái = tốc độ đi vào trạng thái.
4. **Rút gọn thành quan hệ liên tiếp** λ·p_(n−1) = μ_n·p_n → p_n theo p0.
5. **Chuẩn hoá**: Σ p_n = 1 → p0 → các p_n.
6. Tính N = Σ n·p_n; P_B = p_k; λ thực tế = λ(1 − P_B); T = N/(λ(1 − P_B)) (Little).

Lời giải:
- (a) Trạng thái 0, 1, 2, 3. Sinh: 0→1, 1→2, 2→3 tốc độ λ = 2. Tử: 1→0, 2→1, 3→2 tốc độ μ = 4. (Vẽ 4 vòng tròn, mũi tên trên ghi λ, mũi tên dưới ghi μ.)
- (b) Phương trình cân bằng:
  - Trạng thái 0: λp0 = μp1 → 2p0 = 4p1.
  - Trạng thái 1: (λ + μ)p1 = λp0 + μp2 → 6p1 = 2p0 + 4p2.
  - Trạng thái 2: (λ + μ)p2 = λp1 + μp3 → 6p2 = 2p1 + 4p3.
  - Trạng thái 3: μp3 = λp2 → 4p3 = 2p2.
  - Rút ra: p1 = p0/2; thay vào trạng thái 1: p2 = p1/2 = p0/4; từ trạng thái 3: p3 = p2/2 = p0/8.
  - Chuẩn hoá: p0(1 + 1/2 + 1/4 + 1/8) = 1 → p0 = 8/15 ≈ **0,533**; p1 = 4/15 ≈ **0,267**; p2 = 2/15 ≈ **0,133**; p3 = 1/15 ≈ **0,067**.
- (c) N = 0·p0 + 1·p1 + 2·p2 + 3·p3 = (4 + 4 + 3)/15 = 11/15 ≈ **0,733 cuộc gọi**.
- (d) P_B = p3 = 1/15; λ thực tế = 2·(14/15) ≈ 1,867 cuộc/phút; T = N/λ thực tế = (11/15)/(28/15) = 11/28 ≈ **0,393 phút ≈ 23,6 giây**.
  (Thêm nếu hỏi: Nq = N − (1 − p0) = 11/15 − 7/15 = 4/15 ≈ 0,267; Tq = 4/28 ≈ 0,143 phút.)

Lưu ý: dùng công thức M/M/1/k ở mục 2 cũng ra đúng các số này — dùng để **tự kiểm tra**, nhưng khi đề ghi "không dùng công thức cho sẵn" thì phải trình bày đủ bước 1–5.

## 3. M/M/c (M/M/c/∞) — c server, chỗ chờ vô hạn — công thức Erlang C

Khuôn giải: a = λ/μ; ρ = a/c; điều kiện ổn định ρ < 1 (λ < cμ).
1. p0 = 1 / [ Σ_{n=0}^{c−1} a^n/n! + a^c/(c!(1 − ρ)) ].
2. p_n = a^n/n! · p0 (n ≤ c); p_n = a^c/c! · ρ^(n−c) · p0 (n ≥ c).
3. **Xác suất phải đợi (Erlang C):** C(c, a) = a^c/(c!(1 − ρ)) · p0. Xác suất được phục vụ ngay = 1 − C(c, a).
4. Nq = C(c, a) · ρ/(1 − ρ); Ns = a; N = Nq + a.
5. Tq = Nq/λ = C(c, a)/(cμ − λ); T = Tq + 1/μ.
6. Thêm: P(Tq ≤ t) = 1 − C(c, a) · e^(−(cμ − λ)t).

Bài mẫu (slide tr. 51): Call center có 3 điện thoại viên. Trong 10 phút có trung bình 3 khách gọi đến (Poisson); mỗi cuộc gọi trung bình 3 phút (mũ). Khi bận, khách nghe nhạc chờ. Tính xác suất khách được phục vụ ngay. Chỉ tiêu "không quá 10% khách phải đợi" có đạt không? Nếu không, cần bao nhiêu điện thoại viên?
- λ = 0,3 cuộc/phút; μ = 1/3 cuộc/phút; a = 0,9; c = 3; ρ = 0,3.
- p0 = 1/(1 + 0,9 + 0,9²/2 + 0,9³/(3!·0,7)) ≈ 0,4035.
- C(3; 0,9) = 0,9³/(6·0,7) · 0,4035 ≈ **0,070** → xác suất được phục vụ ngay ≈ **0,930**.
- 7% ≤ 10% → **chỉ tiêu đạt** với 3 điện thoại viên, không cần thêm. (Nếu chưa đạt thì thử c = 4, 5, … đến khi C(c, a) ≤ 10%; với c = 4, C ≈ 0,014.)
- Thêm: Tq = 0,070/(3·(1/3) − 0,3) ≈ 0,100 phút; T ≈ 3,10 phút.

Bài mẫu (slide tr. 61, phần 1 — thầy đã chữa trên lớp, "TH1"): CPU máy chủ 4 nhân. Tác vụ đến trung bình 20 task/µs (Poisson); xử lý trung bình 0,08 µs/tác vụ (mũ); bộ nhớ đệm đủ lớn. Tính thời gian từ lúc nhận yêu cầu đến khi hoàn thành, và lượng bộ nhớ (số tác vụ) trung bình chiếm trong RAM.
- λ = 20 task/µs; μ = 1/0,08 = 12,5 task/µs; c = 4; a = λ/μ = 1,6; ρ = λ/(cμ) = 0,4 → mô hình M/M/c.
- p0 ≈ 0,1993; C(4; 1,6) ≈ 0,0907; Nq ≈ 0,0605; Tq ≈ 0,0030 µs.
- T = Tq + 1/μ ≈ 0,0030 + 0,08 = **0,083 µs** (công thức 3.86).
- Số tác vụ trong RAM = N = λT = Nq + a ≈ **1,66 tác vụ** (công thức 3.83; trên bảng ghi 1,67 do dùng C = 0,106).

> Trên bảng lớp ghi C(c, a) = 0,10602. Bấm đúng công thức (3.79) của slide ra **0,0907** (a^c/(c!(1 − ρ)) = 0,4551; tổng mẫu = 4,5627 + 0,4551 = 5,0178; 0,4551/5,0178 = 0,0907). T trên bảng (0,083 µs) vẫn khớp; N trên bảng 1,67 lệch nhẹ so với 1,66. Nên hỏi lại thầy hoặc bạn cùng lớp con số 0,106.

## 4. M/M/c/c — c server, không có chỗ chờ — công thức Erlang B

Khuôn giải: a = λ/μ (đơn vị Erlang).
1. p_n = (a^n/n!) / Σ_{i=0}^{c} a^i/i!, n = 0 … c.
2. **Xác suất bị từ chối / nghẽn (Erlang B):** B(c, a) = p_c = (a^c/c!) / Σ_{i=0}^{c} a^i/i!.
3. N = a(1 − B(c, a)); T = 1/μ (không có chờ).
4. Thiết kế "cần bao nhiêu kênh để B ≤ x%": tính B với c = 1, 2, 3, … đến khi đạt. Mẹo tính nhanh: B(0) = 1; **B(c) = a·B(c−1)/(c + a·B(c−1))**.

Đơn vị Erlang: tải = (số cuộc gọi trong 1 giờ) × (thời gian trung bình 1 cuộc, tính bằng giờ). Ví dụ slide: 60 cuộc/giờ, mỗi cuộc 5 phút → 60 × 5/60 = **5 Erlang**.

Bài mẫu (slide tr. 57): Tổng đài cơ quan có 3 đường trung kế ra tổng đài công cộng. Cuộc gọi từ trong ra 6 cuộc/giờ, từ ngoài vào 9 cuộc/giờ (đều Poisson); mỗi cuộc chiếm kênh trung bình 3 phút. Tính tải theo Erlang và xác suất một cuộc gọi bị từ chối.
- Ghép hai luồng Poisson: λ = 6 + 9 = 15 cuộc/giờ.
- Tải a = 15 × 3/60 = **0,75 Erlang**.
- B(3; 0,75) = (0,75³/6) / (1 + 0,75 + 0,75²/2 + 0,75³/6) ≈ **0,0335 (3,35%)**.

## 5. M/M/c/k — c server, sức chứa k

Khuôn giải (a = λ/μ, ρ = a/c):
1. Trọng số: w_n = a^n/n! với n ≤ c; w_n = (a^c/c!)·ρ^(n−c) với c < n ≤ k.
2. p0 = 1/Σ w_n; p_n = w_n · p0.
3. P_B = p_k. Xác suất phải đợi = p_c + p_(c+1) + … + p_(k−1).
4. N = Σ n·p_n; Nq = Σ_{n=c}^{k} (n − c)·p_n (tính trực tiếp bằng tổng, k nhỏ nên nhanh).
5. T = N/(λ(1 − P_B)); Tq = Nq/(λ(1 − P_B)).

> Lưu ý: công thức (3.97)–(3.100) trên slide là công thức của M/M/c vô hạn, chỉ đúng gần đúng khi P_B rất nhỏ. Đi thi nên tính N, Nq bằng tổng như trên (ra số chính xác); nếu thời gian gấp thì dùng công thức slide và ghi "xấp xỉ".

Bài mẫu (slide tr. 61, phần 2 — thầy chữa trên lớp, "TH2"): CPU 4 nhân như trên, nhưng bộ nhớ đệm (cache) chỉ chứa tối đa 10 tác vụ. Tính xác suất một tác vụ bị từ chối và xác suất một tác vụ phải đợi mà không được phục vụ ngay.
- Cách hiểu của thầy: 10 chỗ chờ + 4 nhân → **k = 10 + 4 = 14 → M/M/4/14** (đúng quy tắc k = Q + c).
- c = 4, k = 14, a = 1,6, ρ = 0,4. p0 ≈ 0,1993.
- P_B = p14 = (a^c/c!)·ρ^(k−c)·p0 = (1,6⁴/24)·0,4¹⁰·0,1993 ≈ **5,7·10⁻⁶** (công thức 3.96).
- Xác suất phải đợi: thầy tính **p = 1 − (p0 + p1 + p2 + p3) ≈ 0,09** (bỏ qua P_B vì quá nhỏ; chính xác là p4 + … + p13 ≈ 0,0907).

> Trên bảng lớp ghi P_B ≈ 8,8·10⁻⁷. Thay số đúng công thức (3.96) mình ra 5,7·10⁻⁶ (cả hai đều rất nhỏ, kết luận không đổi). Nên hỏi lại con số này.

## 6. M/M/∞ — vô số server (bài tập 3.1 của thầy)

- p_n = a^n e^(−a)/n! (số yêu cầu trong hệ thống là phân bố Poisson với tham số a = λ/μ).
- N = a; T = 1/μ; Nq = Tq = 0 (không ai phải chờ). Luôn ổn định.

## 7. M/G/1 và M/D/1 — thời gian phục vụ không phải mũ

M/G/1 (cho Ts = 1/μ và phương sai σs²), ρ = λ/μ < 1:
- N = ρ + (ρ² + λ²σs²)/(2(1 − ρ)); Nq = (ρ² + λ²σs²)/(2(1 − ρ)).
- T = N/λ; Tq = T − 1/μ.

M/D/1 (σs = 0, phục vụ cố định):
- N = ρ(2 − ρ)/(2(1 − ρ)); Nq = ρ²/(2(1 − ρ)); T = (2 − ρ)/(2μ(1 − ρ)); Tq = ρ/(2μ(1 − ρ)).

Câu hỏi hay gặp: "Cùng tải ρ, hệ thống M/G/1 nào hiệu năng tốt nhất?" → **M/D/1** (phục vụ cố định, σs² = 0), Nq chỉ bằng một nửa M/M/1.

Bài mẫu (tự đặt): Liên kết nhận λ = 200 gói/s, μ = 250 gói/s.
- Gói dài ngẫu nhiên (M/M/1): T = 1/50 = 20 ms.
- Gói dài bằng nhau (M/D/1): T = (2 − 0,8)/(2·250·0,2) = **12 ms** → nhanh hơn.

## 8. Bài toán chọn phương án (bài tập 3.2 của thầy)

Đề: Trung tâm có nhiều PC; trung bình mỗi ngày làm việc 8 h có 3 máy hỏng (Poisson). Chi phí 500.000đ cho một máy hỏng (hiểu là thiệt hại cho mỗi máy nằm hỏng trong ngày). Thời gian sửa phân bố mũ, sửa lần lượt.
- Công ty 1: sửa trung bình 2 h/máy, phí 600.000đ/ngày.
- Công ty 2: sửa trung bình 80 phút/máy, phí 800.000đ/ngày.
Nên chọn công ty nào?

Khuôn giải: mỗi phương án là một hàng đợi M/M/1 → tính N (số máy hỏng trung bình đang nằm chờ/sửa) → chi phí/ngày = phí dịch vụ + N × 500.000đ → chọn phương án rẻ hơn.
- λ = 3/8 = 0,375 máy/giờ.
- Công ty 1: μ = 0,5/h; ρ = 0,75; N = 3 máy; T = 8 h. Chi phí = 600.000 + 3 × 500.000 = **2.100.000đ/ngày**.
- Công ty 2: μ = 0,75/h; ρ = 0,5; N = 1 máy; T ≈ 2,67 h. Chi phí = 800.000 + 1 × 500.000 = **1.300.000đ/ngày**.
- Kết luận: **chọn công ty 2** (phí cao hơn nhưng máy nằm hỏng ít hơn).

> Đề viết "giá thành để sửa 1 máy" khá mập mờ. Khi đi thi, ghi rõ cách hiểu ("500.000đ là thiệt hại cho mỗi máy hỏng trong ngày") rồi tính. Nếu hiểu là tiền sửa trả theo mỗi máy thì hai công ty sửa cùng số máy, chi phí sửa như nhau, khi đó chọn công ty 1 vì phí rẻ hơn — nhưng bài sẽ không dùng tới hàng đợi nên cách hiểu thứ nhất mới đúng ý đề.

## 9. Bài đề thi cũ dùng M/G/1 (đề cuối kỳ 20231, câu 1)

Đề: Công ty A thuê chung 1 server với công ty B, chung một hàng đợi. Nhiệm vụ của A: Poisson λA = 0,9/s, thời gian phục vụ mũ trung bình 0,05 s. Của B: λB = 0,1/s, trung bình 6 s.
(a) Trễ kỳ vọng (chờ + phục vụ) của nhiệm vụ công ty A?
(b) Trung tâm Y cho thuê server riêng nhưng chậm hơn k lần. k lớn nhất bằng bao nhiêu thì A đồng ý chuyển?

Giải theo slide thầy Dũng (M/G/1, vì thời gian phục vụ là hỗn hợp của hai phân bố mũ):
- λ = 0,9 + 0,1 = 1/s. Thời gian phục vụ trung bình: E[S] = 0,9·0,05 + 0,1·6 = 0,645 s → μ = 1/0,645; ρ = 0,645.
- E[S²] = 0,9·2·0,05² + 0,1·2·6² = 7,2045 → σs² = 7,2045 − 0,645² ≈ 6,788.
- Tq = (ρ + λμσs²)/(2μ(1 − ρ)) ≈ **10,15 s** (cùng một hàng đợi nên A và B chờ như nhau).
- (a) Trễ của A: TA = Tq + 0,05 ≈ **10,20 s**.
- (b) Ở Y, A dùng riêng M/M/1 với μY = 20/k: TY = 1/(20/k − 0,9) ≤ 10,20 → 20/k ≥ 0,998 → **k ≤ 20,04 → kmax = 20**.

> Tài liệu giải có sẵn (CSTSL_20251_ALL_re.pdf) coi cả hệ là M/M/1 với μ = 1/0,645 nên ra TA ≈ 1,82 s và k = 13. Cách đó bỏ qua việc thời gian phục vụ không phải mũ nên không chính xác; với slide thầy Dũng có M/G/1 thì dùng cách trên. Nếu gặp đề kiểu này mà đề ghi rõ "coi là M/M/1" thì làm theo đề.

## Bài tự luyện (10 bài, có ô chấm)

1. Một kênh vô tuyến chỉ phục vụ 1 phiên một lúc, không cho chờ. Yêu cầu đến 30 phiên/giờ (Poisson), mỗi phiên trung bình 4 phút (mũ). Tính xác suất yêu cầu bị từ chối, N và T.
2. Router có 1 cổng ra, bộ đệm chứa được 2 gói chờ, μ = 1000 gói/s, λ = 900 gói/s. Tính p0, P_B, N, T.
3. Hàng đợi M/M/1/4 có λ = μ = 50 yêu cầu/s. Tính các p_n, P_B, N, Nq, T.
4. Ngân hàng có 2 quầy, khách đến 20 người/giờ, mỗi khách trung bình 4 phút (mũ), chỗ chờ đủ rộng. Tính xác suất khách phải đợi, Tq (phút), N.
5. Một tổng đài: 90 cuộc gọi/giờ, mỗi cuộc trung bình 4 phút. Tải bao nhiêu Erlang?
6. Lưu lượng 4 Erlang đi vào nhóm kênh không cho chờ. Cần tối thiểu bao nhiêu kênh để xác suất nghẽn không quá 2%? Nghẽn bao nhiêu nếu chỉ có 8 kênh?
7. Bãi đỗ xe rất lớn (coi như M/M/∞): xe đến 2 xe/phút, mỗi xe đỗ trung bình 1,5 phút. Tính số xe trung bình trong bãi, xác suất bãi trống và xác suất có đúng 3 xe.
8. Liên kết nhận λ = 60 gói/s, μ = 100 gói/s, gói có độ dài cố định. Tính N và T theo M/D/1 và so sánh T với trường hợp M/M/1.
9. Hệ thống M/M/2/4 có λ = μ = 10 yêu cầu/s. Tính các p_n, P_B, xác suất phải đợi, N, T.
10. Server có λ = 4 yêu cầu/s, thời gian phục vụ trung bình 0,2 s, độ lệch chuẩn 0,1 s (M/G/1). Tính N và T.

## Đáp án

1. λ = 0,5/phút, μ = 0,25/phút, ρ = 2. P_B = 0,5/(0,5 + 0,25) = **2/3 ≈ 0,667**; N = **2/3**; T = 1/μ = **4 phút**.
2. Q = 2 → k = 3; ρ = 0,9. p0 ≈ **0,291**; P_B = p3 ≈ **0,212**; N ≈ **1,369**; λ thực tế ≈ 709,2/s; T ≈ **1,93 ms**.
3. ρ = 1 → p0 = … = p4 = **0,2**; P_B = **0,2**; N = 4/2 = **2**; Nq = 2 − 0,8 = **1,2**; T = 2/(50·0,8) = **0,05 s**.
4. μ = 15/giờ, a = 4/3, ρ = 2/3. p0 = **0,2**; C(2; 4/3) ≈ **0,533**; Nq ≈ 1,067; Tq = Nq/λ ≈ 0,0533 h ≈ **3,2 phút**; N = Nq + a ≈ **2,4**.
5. 90 × 4/60 = **6 Erlang**.
6. B(c; 4): c = 8 → **0,0304**; c = 9 → **0,0133**. Cần tối thiểu **9 kênh**.
7. a = 3. N = **3 xe**; P(0) = e^(−3) ≈ **0,050**; P(3) = 3³e^(−3)/3! ≈ **0,224**.
8. ρ = 0,6. M/D/1: N = 0,6·1,4/(2·0,4) = **1,05**; T = 1,4/(2·100·0,4) = **17,5 ms**. M/M/1: T = 1/40 = **25 ms** → M/D/1 nhanh hơn.
9. a = 1, ρ = 0,5. p0 = p1 ≈ **0,348**, p2 ≈ **0,174**, p3 ≈ **0,087**, p4 ≈ **0,043**. P_B ≈ **0,0435**; xác suất phải đợi = p2 + p3 ≈ **0,261**; N ≈ **1,130**; T = N/(10·(1 − 0,0435)) ≈ **0,118 s**.
10. ρ = 0,8; σs² = 0,01. N = 0,8 + (0,64 + 16·0,01)/(2·0,2) = **2,8**; T = 2,8/4 = **0,7 s**.

## Trang sổ tay phòng thi (trang 2)

```
CHỌN MÔ HÌNH: không chỗ chờ → /1/1 hoặc /c/c;  chỗ chờ Q → k = Q + c;  vô hạn → bỏ k
a = λ/μ (Erlang)   ρ = λ/(cμ)   hệ có từ chối: Little dùng λ(1 − P_B)

M/M/1/1:  P_B = λ/(λ+μ)    N = P_B    T = 1/μ
M/M/1/k:  p0 = (1−ρ)/(1−ρ^(k+1))   pn = ρ^n p0   P_B = pk
          N = ρ/(1−ρ) − (k+1)ρ^(k+1)/(1−ρ^(k+1))   Nq = N − (1−p0)   T = N/(λ(1−P_B))
          ρ = 1: mọi pn = 1/(k+1), N = k/2
M/M/c:    p0 = 1/[Σ_{n<c} a^n/n! + a^c/(c!(1−ρ))]
          C(c,a) = a^c/(c!(1−ρ))·p0 (phải đợi)   Nq = C·ρ/(1−ρ)   N = Nq + a
          Tq = C/(cμ−λ)   T = Tq + 1/μ
M/M/c/c:  B(c,a) = (a^c/c!)/Σ_{i≤c} a^i/i!   B(c) = aB(c−1)/(c + aB(c−1)), B(0)=1
          N = a(1−B)   T = 1/μ    Erlang = cuộc/giờ × giờ/cuộc
M/M/c/k:  w_n = a^n/n! (n≤c), (a^c/c!)ρ^(n−c) (n>c); pn = w_n/Σw; P_B = pk; N = Σ n·pn
M/M/∞:    pn = a^n e^(−a)/n!   N = a   T = 1/μ
M/G/1:    N = ρ + (ρ² + λ²σ²)/(2(1−ρ))    T = N/λ
M/D/1:    N = ρ(2−ρ)/(2(1−ρ))   T = (2−ρ)/(2μ(1−ρ))   (tốt nhất khi cùng ρ)
```

Lỗi hay mắc:
- "Chỗ cho 10 người đợi" mà lấy k = 10 → đúng là k = 11 (cộng 1 server).
- Hệ có từ chối mà dùng T = N/λ → phải chia cho λ(1 − P_B).
- M/M/c lấy ρ = λ/μ → đúng là ρ = λ/(cμ); a mới là λ/μ.
- Quên ghép luồng Poisson trước khi tính tải (tổng đài cơ quan: 6 + 9).
- Đổi đơn vị thời gian lệch giữa λ và μ (giờ / phút / giây).
