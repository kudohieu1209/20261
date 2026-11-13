# GK0 — Bản gộp ví dụ trên lớp và bảng công thức

Bản gộp cũ để đọc tổng quan. Để in mang vào thi, dùng `GK_InA4_DenTrang.pdf` (đủ 7 chủ đề); không cần in thêm bản tách mạng vì đã nằm trong tập chính. Xem [hướng dẫn in](../../mang-phong-thi/IN_GIUA_KY.md). Nội dung hiện hành dùng chung nằm trong các file `mang-phong-thi/content/gk-exam-*.typ`; phần dưới giữ làm ghi chú biên soạn cũ.

Thông tin thi (thầy Nguyễn Xuân Dũng báo): **100% tự luận, 60 phút, được dùng tài liệu giấy (photo hoặc ghi chép), thi đến hết phần hàng đợi; làm được các ví dụ trên lớp sẽ có lợi thế.**
→ Tập này để **in ra giấy** (không dùng được tablet trong phòng thi). Gồm: (A) cách trình bày bài tự luận; (B) 16 ví dụ/bài tập trong slide và trên lớp của thầy, giải đầy đủ; (C) bảng công thức gộp; (D) từ khoá lý thuyết.

## A. Cách trình bày một bài tự luận hàng đợi (5 dòng ăn điểm)

1. **Mô hình:** gọi tên theo Kendall và nói lý do (số server c, chỗ chờ → k). Ví dụ: "1 nhân viên, 10 chỗ chờ → M/M/1/11".
2. **Tham số:** viết λ, μ **cùng đơn vị**; tính a = λ/μ, ρ = λ/(cμ).
3. **Công thức:** ghi công thức dạng chữ (kèm số công thức trong slide nếu nhớ, ví dụ (3.54)).
4. **Thay số** và ra kết quả **có đơn vị**.
5. **Kết luận** một câu trả lời đúng câu hỏi (đạt/không đạt chỉ tiêu, chọn phương án nào…).
Đề ghi "không dùng công thức cho sẵn" → phải vẽ đồ hình sinh – tử và viết phương trình cân bằng (xem VD 7).

## B. Toàn bộ ví dụ trên lớp và bài tập trong slide thầy Dũng

### Chương 2 — Tiến trình Poisson

**VD 1 (ch.2 tr. 44) — Tổng đài 1080.** Trung bình 10 cuộc/phút, Poisson. Xác suất có 15 cuộc trong 2 phút?
- Định lý 1: số sự kiện trong khoảng t tuân theo phân bố Poisson tham số λt.
- λt = 10·2 = 20.
- P{N = 15} = (λt)^k e^(−λt)/k! = 20¹⁵·e^(−20)/15! ≈ **0,0516**.

**VD 2 (ch.2 tr. 46) — Xe buýt.** Tần suất 5 phút/chuyến, Poisson. Vừa lỡ một chuyến. Xác suất đợi chuyến sau ít hơn 3 phút?
- Định lý 2: thời gian giữa hai sự kiện liên tiếp phân bố mũ: P{T ≤ t} = 1 − e^(−λt).
- 5 phút/chuyến → λ = 1/5 chuyến/phút.
- P{T < 3} = 1 − e^(−3/5) = 1 − e^(−0,6) ≈ **0,451**.

**VD 3 (ch.2 tr. 48) — Ghép luồng.** Ô tô 6 xe/phút, xe máy 9 xe/phút, đều Poisson → phương tiện qua nút: Poisson với λ = 6 + 9 = **15 phương tiện/phút**.

**VD 4 (ch.2 tr. 49) — Tách luồng.** 12 bé/tuần, 55% trai, 45% gái → bé trai: Poisson 12·0,55 = **6,6 bé/tuần**; bé gái: 12·0,45 = **5,4 bé/tuần**.

### Chương 3 — Hàng đợi đơn

**VD 5 (ch.3 tr. 29) — ATM, M/M/1/1.** 1 máy ATM; 10 người/giờ (Poisson); mỗi người trung bình 3 phút. Xác suất một người đến nhưng không được phục vụ?
- Mô hình: 1 server, không có hàng đợi (Q = 0) → M/M/1/1.
- λ = 10 người/giờ; μ = 60/3 = 20 người/giờ.
- (3.25): P_B = p1 = λ/(λ + μ) = 10/30 = **1/3 ≈ 0,333**.
- Thêm: N = p1 = 1/3; T = 1/μ = 3 phút.

**VD 6 (ch.3 tr. 34) — Quầy tính tiền siêu thị, M/M/1/∞.** 40 khách/giờ (Poisson); phục vụ phân bố mũ trung bình 1 phút; 1 quầy; đủ chỗ xếp hàng. Tìm thời gian chờ trung bình; xác suất từ lúc vào xếp hàng đến lúc trả tiền xong không quá 1,5 phút.
- Mô hình: M/M/1/∞. λ = 40/60 = 2/3 khách/phút; μ = 1 khách/phút; ρ = 2/3 < 1 → ổn định.
- (3.42): Tq = (1/μ)·ρ/(1 − ρ) = 1·(2/3)/(1/3) = **2 phút**.
- (3.43): P{T ≤ t} = 1 − e^(−(μ−λ)t) → P{T ≤ 1,5} = 1 − e^(−(1/3)·1,5) = 1 − e^(−0,5) ≈ **0,393**.
- Thêm: T = 1/(μ − λ) = 3 phút; N = ρ/(1 − ρ) = 2; Nq = ρ²/(1 − ρ) = 4/3.

**VD 7 (bài thầy cho trên lớp) — M/M/1/3, tự lập phương trình.** Đến 2 cuộc/phút; rời hệ thống 4 cuộc/phút. Biểu diễn quá trình sinh – tử; tự tìm quan hệ giữa các xác suất và tính (không dùng công thức cho sẵn); số cuộc gọi trung bình; thời gian trung bình một cuộc gọi trong hệ thống.
- Trạng thái 0, 1, 2, 3 (số cuộc gọi trong hệ). Đồ hình: 0 ⇄ 1 ⇄ 2 ⇄ 3; mũi tên sang phải λ = 2, sang trái μ = 4.
- Phương trình cân bằng (tốc độ ra = tốc độ vào):
  - Trạng thái 0: λp0 = μp1 → 2p0 = 4p1.
  - Trạng thái 1: (λ + μ)p1 = λp0 + μp2 → 6p1 = 2p0 + 4p2.
  - Trạng thái 2: (λ + μ)p2 = λp1 + μp3 → 6p2 = 2p1 + 4p3.
  - Trạng thái 3: μp3 = λp2 → 4p3 = 2p2.
- Suy ra: p1 = p0/2; p2 = p0/4; p3 = p0/8.
- Chuẩn hoá: p0(1 + 1/2 + 1/4 + 1/8) = 1 → **p0 = 8/15 ≈ 0,533; p1 = 4/15 ≈ 0,267; p2 = 2/15 ≈ 0,133; p3 = 1/15 ≈ 0,067**.
- N = Σ n·pn = (1·4 + 2·2 + 3·1)/15 = 11/15 ≈ **0,733 cuộc gọi**.
- Xác suất từ chối P_B = p3 = 1/15; tốc độ vào thực tế λ(1 − P_B) = 2·14/15 = 28/15 cuộc/phút.
- Little (3.62): T = N/[λ(1 − P_B)] = (11/15)/(28/15) = 11/28 ≈ **0,393 phút ≈ 23,6 giây**.

**VD 8 (ch.3 tr. 43) — Bãi gửi xe máy, M/M/1/k.** 1 nhân viên; chỗ cho 10 khách đợi; 3 khách/phút (Poisson); xử lý trung bình 15 giây/xe (mũ). Hỏi: xác suất khách được phục vụ ngay; thời gian trung bình phải đợi đến khi được phục vụ; xác suất bãi bị tắc do người tới quá đông.
- Mô hình: 1 server, hàng đợi Q = 10 → k = Q + 1 = 11 → M/M/1/11.
- λ = 3 khách/phút; μ = 60/15 = 4 khách/phút; ρ = 0,75. ρ¹¹ ≈ 0,04224; ρ¹² ≈ 0,03168.
- (3.52): p0 = (1 − ρ)/(1 − ρ^(k+1)) = 0,25/(1 − 0,03168) ≈ **0,258** → xác suất được phục vụ ngay (hệ đang rỗng) ≈ 25,8%.
- (3.54): P_B = p11 = ρ¹¹·p0 = 0,04224·0,258 ≈ **0,0109** → xác suất bãi bị tắc ≈ 1,09%.
- (3.55): N = ρ/(1 − ρ) − (k + 1)ρ^(k+1)/(1 − ρ^(k+1)) = 3 − 12·0,03168/0,96832 ≈ 2,607.
- Nq = N − (1 − p0) = 2,607 − 0,742 ≈ 1,866.
- (3.63): Tq = Nq/[λ(1 − P_B)] = 1,866/(3·0,9891) ≈ **0,629 phút ≈ 37,7 giây**.

**VD 9 (ch.3 tr. 51) — Call center, M/M/c/∞ (Erlang C).** 3 điện thoại viên; trong 10 phút trung bình 3 khách gọi (Poisson); mỗi cuộc trung bình 3 phút (mũ); bận thì khách nghe nhạc chờ. Xác suất khách được phục vụ ngay? Chỉ tiêu "không quá 10% khách phải đợi" có đạt không; nếu không cần bao nhiêu bàn?
- Mô hình: c = 3, hàng đợi vô hạn → M/M/3/∞.
- λ = 3/10 = 0,3 cuộc/phút; μ = 1/3 cuộc/phút; a = λ/μ = 0,9; ρ = a/c = 0,3 < 1.
- (3.76): p0 = 1/[Σ_{n=0}^{2} aⁿ/n! + a³/(3!(1 − ρ))] = 1/[(1 + 0,9 + 0,405) + 0,729/(6·0,7)] = 1/(2,305 + 0,1736) ≈ 0,4035.
- (3.79) Erlang C: C(c, a) = [a^c/(c!(1 − ρ))]·p0 = 0,1736·0,4035 ≈ **0,070** (7% khách phải đợi).
- (3.80): xác suất được phục vụ ngay = 1 − C = **0,930**.
- 7% ≤ 10% → **chỉ tiêu đạt**, không cần tăng số bàn. (Nếu không đạt: thử c = 4, 5… đến khi C ≤ 10%; c = 4 cho C ≈ 0,014.)

**VD 10 (ch.3 tr. 55) — Đơn vị Erlang.** Tổng đài 1 giờ có 60 cuộc, mỗi cuộc trung bình 5 phút → tải E = 60·5/60 = **5 Erlang**.

**VD 11 (ch.3 tr. 57) — Tổng đài cơ quan, M/M/c/c (Erlang B).** 3 đường trung kế; gọi ra 6 cuộc/giờ, gọi vào 9 cuộc/giờ (đều Poisson); chiếm kênh trung bình 3 phút (mũ). Tính tải theo Erlang; xác suất một cuộc gọi bị từ chối do nghẽn mạch.
- Mô hình: c = 3, không có hàng đợi → M/M/3/3.
- Ghép hai luồng Poisson: λ = 6 + 9 = 15 cuộc/giờ; μ = 60/3 = 20 cuộc/giờ.
- Tải: a = λ/μ = 15·3/60 = **0,75 Erlang**.
- (3.91) Erlang B: B(c, a) = (a^c/c!)/Σ_{i=0}^{c} aⁱ/i! = (0,75³/6)/(1 + 0,75 + 0,28125 + 0,07031) = 0,07031/2,10156 ≈ **0,0335 (3,35%)**.

**VD 12 (ch.3 tr. 61, thầy chữa trên lớp) — CPU 4 nhân, M/M/c và M/M/c/k.** 20 task/µs (Poisson); xử lý trung bình 0,08 µs (mũ).
TH1 — bộ nhớ đệm đủ lớn. Tính thời gian từ lúc nhận yêu cầu đến khi hoàn thành; lượng bộ nhớ trung bình các tác vụ chiếm trong RAM.
- Mô hình: M/M/4/∞. λ = 20; μ = 1/0,08 = 12,5 task/µs; a = λ/μ = 1,6; ρ = λ/(cμ) = 0,4.
- p0 = 1/[(1 + 1,6 + 1,28 + 0,6827) + 1,6⁴/(4!·0,6)] = 1/(4,5627 + 0,4551) ≈ **0,1993**.
- C(c, a) = 0,4551·0,1993 ≈ 0,0907. (Trên bảng lớp ghi 0,10602 — nên hỏi lại; bấm theo (3.79) ra 0,0907.)
- Nq = C·ρ/(1 − ρ) = 0,0907·0,6667 ≈ 0,0605.
- (3.86): T = 1/μ + C/(cμ − λ) = 0,08 + 0,0907/30 ≈ **0,083 µs**.
- (3.83): N = a + Nq = 1,6 + 0,0605 ≈ **1,66 tác vụ** (bảng lớp ghi 1,67).
TH2 — bộ nhớ đệm chỉ chứa tối đa 10 tác vụ. Tính xác suất một tác vụ bị từ chối; xác suất một tác vụ phải đợi mà không được phục vụ ngay.
- Mô hình (theo thầy): k = 10 + 4 = 14 → **M/M/4/14**.
- (3.96): P_B = p14 = [a^c/c!]·ρ^(k−c)·p0 = (1,6⁴/24)·0,4¹⁰·0,1993 ≈ **5,7·10⁻⁶** (bảng lớp ghi ≈ 8,8·10⁻⁷ — nên hỏi lại; cả hai đều rất nhỏ).
- Xác suất phải đợi (cách thầy): p = 1 − (p0 + p1 + p2 + p3) với p1 = a·p0 = 0,3189; p2 = a²/2·p0 = 0,2551; p3 = a³/6·p0 = 0,1361 → p = 1 − 0,9093 ≈ **0,09**.

**BT 3.1 — M/M/∞.** Mọi yêu cầu được phục vụ ngay. Trạng thái n: sinh λ, tử nμ → pn = (aⁿ/n!)·p0; Σpn = 1 → p0 = e^(−a) → **pn = aⁿe^(−a)/n!** (phân bố Poisson tham số a = λ/μ). **N = a; T = 1/μ; Nq = 0; Tq = 0; P_B = 0**; luôn ổn định.

**BT 3.2 — Chọn công ty sửa máy.** Trung bình 3 máy hỏng/ngày 8 h (Poisson); thiệt hại 500.000đ cho mỗi máy hỏng; sửa lần lượt, thời gian sửa phân bố mũ. Công ty 1: 2 h/máy, phí 600.000đ/ngày. Công ty 2: 80 phút/máy, phí 800.000đ/ngày.
- Mỗi phương án là một hàng đợi M/M/1; λ = 3/8 = 0,375 máy/giờ.
- Công ty 1: μ = 0,5; ρ = 0,75; N = ρ/(1 − ρ) = 3 máy → chi phí = 600.000 + 3·500.000 = **2.100.000đ/ngày**.
- Công ty 2: μ = 0,75; ρ = 0,5; N = 1 máy → chi phí = 800.000 + 1·500.000 = **1.300.000đ/ngày**.
- Kết luận: **chọn công ty 2**. (Ghi rõ cách hiểu: 500.000đ là thiệt hại cho mỗi máy đang nằm hỏng.)

### Chương 3 — Mạng hàng đợi

**VD 13 (ch.3 tr. 87) — Mạng mở 4 nút.** γ4 = 4 yêu cầu/s vào nút 4; 1/μ1 = 0,03; 1/μ2 = 0,04; 1/μ3 = 0,05; 1/μ4 = 0,06 (s); r41 = 1; r12 = r13 = 0,5; r21 = 1; r31 = 0,6; r30 = 0,4.
- Phương trình lưu lượng λi = γi + Σ rji·λj: λ4 = 4; λ1 = λ4 + λ2 + 0,6λ3; λ2 = λ3 = 0,5λ1 → 0,2λ1 = 4 → **λ1 = 20; λ2 = λ3 = 10; λ4 = 4** (yêu cầu/s).
- ρi = λi/μi: ρ1 = 0,6; ρ2 = 0,4; ρ3 = 0,5; ρ4 = 0,24 (đều < 1).
- Ni = ρi/(1 − ρi): **N1 = 1,5; N2 = 0,667; N3 = 1; N4 = 0,316**.
- Xác suất hệ thống không có yêu cầu nào: Π(1 − ρi) = 0,4·0,6·0,5·0,76 = **0,0912**.
- Xác suất cả hệ có đúng 1 yêu cầu: 0,0912·(0,6 + 0,4 + 0,5 + 0,24) ≈ **0,159**.
- N = ΣNi ≈ **3,48**; T = N/γ4 = 3,48/4 ≈ **0,871 s**.
- Giữ r30, r31; điều kiện r12, r13 để ổn định: λ1 = 10/r13; λ2 = 10(1 − r13)/r13; ρ1 = 0,3/r13 < 1 → r13 > 0,3; ρ2 = 0,4(1 − r13)/r13 < 1 → r13 > 0,286 → **r13 > 0,3; r12 < 0,7**.

**BT 3.3 — Mạng LAN có ARQ.** S1 → R1 → R2 → D; S2 → R2. λ1 = 240 gói/phút = 4 gói/s; λ2 = 120 gói/phút = 2 gói/s; 1/μ1 = 0,2 s; 1/μ2 = 0,1 s; liên kết R2 → D lỗi gói pe = 10%; ARQ giữa D và S1, S2.
- Gói lỗi phải gửi lại từ nguồn → lưu lượng thực qua các nút tăng 1/(1 − pe): λR1 = 4/0,9 ≈ 4,444; λR2 = 6/0,9 ≈ 6,667 gói/s.
- μ1 = 5; μ2 = 10 → ρ1 ≈ 0,889; ρ2 ≈ 0,667.
- Số gói trung bình: N1 = **8**; N2 = **2** (tổng 10 gói).
- Trễ tại nút: T1 = 1/(5 − 4,444) = **1,8 s**; T2 = 1/(10 − 6,667) = **0,3 s**.
- S1 → D: (T1 + T2)/(1 − pe) = 2,1/0,9 ≈ **2,33 s**; S2 → D: 0,3/0,9 ≈ **0,33 s**.

## C. Bảng công thức gộp (lấy nguyên các trang "Sổ tay phòng thi" 1–4 của GK1–GK4)

> Người dàn trang: chép lại nội dung các trang sổ tay 1, 2, 3, 4 từ GK1…GK4 (.typ), dồn gọn cho in giấy.

## D. Từ khoá lý thuyết (lấy nguyên trang sổ tay 5 của GK5)

> Người dàn trang: chép lại trang sổ tay 5 từ GK5 (.typ).
