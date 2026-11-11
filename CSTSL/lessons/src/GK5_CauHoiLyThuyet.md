# GK5 — Câu hỏi lý thuyết ngắn (theo "Câu hỏi" trong slide thầy Dũng chương 2–3)

Vì sao cần: slide thầy Dũng rải rất nhiều "Câu hỏi" và có mục "Câu hỏi cuối chương". Đề giữa kỳ hay có 1–2 câu hỏi ngắn kiểu này (mỗi câu trả lời 3–5 dòng). Tài liệu này cho sẵn **câu trả lời mẫu để chép**, không cần hiểu sâu.

Cách học: đọc lướt cả bộ một lần (20 phút); che phần trả lời, tự nói lại ý chính (từ khoá in đậm) cho từng câu; chép phần "Từ khoá phải có" vào sổ tay.
Qua buổi khi: nhìn câu hỏi nói được đủ từ khoá in đậm.

Mẹo làm bài lý thuyết: trả lời theo khung **định nghĩa → đặc điểm/công thức → ví dụ**. Đề giới hạn số dòng thì viết đúng từng ấy, thừa có thể bị trừ điểm.

## Phần A — Chương 2: mô hình hoá và tiến trình ngẫu nhiên

A1. Mô hình hoá là gì? Vì sao phải mô hình hoá?
- Mô hình hoá là quá trình **trừu tượng hoá và đơn giản hoá** hệ thống thực bằng cách **lược bỏ yếu tố không cần thiết**, mô tả hệ thống bằng các tham số và ràng buộc.
- Cần mô hình hoá khi **không đo đạc trực tiếp được** hoặc muốn **dự đoán** hiệu năng khi hệ thống thay đổi (ví dụ: muốn biết xác suất rớt cuộc gọi p0 = f(n, λ, t) để quyết định xây thêm bao nhiêu trạm, đặt ở đâu).

A2. Các phương pháp đánh giá hiệu năng?
- **Đo đạc** (measurement): đo trên hệ thống thực đang chạy.
- **Giả lập** (emulation): dựng hệ thống thử nghiệm (prototype) hoạt động giống hệ thống thực.
- **Mô hình hoá mô phỏng** (simulation): mô hình phần mềm trên máy tính.
- **Mô hình hoá phân tích** (analytical modeling): dùng công cụ toán học (ví dụ lý thuyết hàng đợi).

A3. Các bước mô hình hoá / quá trình đánh giá hiệu năng?
- Đo đạc, thu thập dữ liệu hệ thống thực (lưu lượng vào, thời gian phục vụ…) → mô hình hoá → **phân tích, so sánh** (độ chính xác, độ phức tạp) → **hiệu chỉnh** (validation) → **đánh giá kết quả** cho hệ thống thực.

A4. Các tham số đánh giá hiệu năng?
- **Thời gian**: thời gian thực hiện một yêu cầu, thời gian đáp ứng, thời gian lưu lại hệ thống.
- **Không gian**: độ lớn hàng đợi/bộ đệm, bộ nhớ cần cho chương trình.
- **Khác**: thông lượng, giá thành.

A5. Phân biệt sự kiện ngẫu nhiên và biến ngẫu nhiên.
- **Sự kiện ngẫu nhiên** là **kết quả** của một phép thử ngẫu nhiên, thuộc tập mẫu Ω (ví dụ: tung đồng xu được mặt ngửa).
- **Biến ngẫu nhiên** là **ánh xạ** từ sự kiện ngẫu nhiên sang **số thực**: X = f(e), X: Ω → ℝ (ví dụ: tung xúc xắc ra mặt 4 thì được 1000 điểm; X = số điểm).

A6. Có mấy loại biến ngẫu nhiên? Dùng tham số gì để mô tả?
- **Rời rạc**: tập giá trị hữu hạn hoặc vô hạn đếm được (số cuộc gọi đến tổng đài, điểm thi).
- **Liên tục**: giá trị lấp kín một khoảng (nhiệt độ, tuổi thọ bóng đèn).
- Tham số: **hàm mật độ xác suất** f(x), **hàm phân bố xác suất** F(x), **kỳ vọng** E(x) (giá trị trung bình), **phương sai** Var(x) và **độ lệch chuẩn** σ (độ phân tán quanh kỳ vọng; càng lớn càng bất định).

A7. Tiến trình ngẫu nhiên là gì? Khác biến ngẫu nhiên thế nào?
- Tiến trình ngẫu nhiên là **tập hợp các biến ngẫu nhiên {X(t)} thay đổi theo thời gian t** (một tập các hàm thời gian kèm luật xác suất).
- Khác biệt: biến ngẫu nhiên là **một giá trị** ngẫu nhiên; tiến trình ngẫu nhiên là **một hàm theo thời gian**, mỗi thời điểm là một biến ngẫu nhiên. Ví dụ: lưu lượng Internet thay đổi theo giờ trong ngày.
- Biến ngẫu nhiên **không đủ** mô tả mọi quá trình thực tế vì nhiều quá trình thay đổi theo thời gian → cần tiến trình ngẫu nhiên.

A8. Tiến trình đếm, tăng trưởng độc lập, tăng trưởng dừng?
- **Đếm**: N(0) = 0, N(t) ≥ 0, không giảm theo t; N(t) − N(s) = số sự kiện trong (s, t]. Ví dụ: số xe qua ngã tư.
- **Tăng trưởng độc lập**: số sự kiện trong các khoảng thời gian **không chồng nhau là độc lập** với nhau.
- **Tăng trưởng dừng**: số sự kiện chỉ phụ thuộc **độ dài** khoảng quan sát, không phụ thuộc thời điểm bắt đầu.

A9. Khái niệm tiến trình Poisson.
N(t) là tiến trình Poisson tham số λ > 0 nếu: (1) **tăng trưởng độc lập**; (2) **tăng trưởng dừng**; (3) P(có đúng 1 sự kiện trong khoảng h nhỏ) = **λh + o(h)**; (4) P(có từ 2 sự kiện trở lên trong h) = **o(h)**.
Hệ quả: số sự kiện trong khoảng t có **phân bố Poisson** tham số λt: P(k) = (λt)^k e^(−λt)/k! (Định lý 1); thời gian giữa hai sự kiện liên tiếp có **phân bố mũ**: P(T ≤ t) = 1 − e^(−λt) (Định lý 2).

A10. Các tính chất của tiến trình Poisson.
- **Kết hợp (ghép)**: tổng n tiến trình Poisson độc lập λ1…λn là tiến trình Poisson với λ = Σλi.
- **Phân tách**: tách tiến trình Poisson λ theo xác suất p1…pn được các tiến trình Poisson λp1…λpn.
- **Không nhớ** (của phân bố mũ): P(x ≤ u + t | x > u) = P(x ≤ t) — đã chờ bao lâu không ảnh hưởng thời gian chờ tiếp.

A11. Ứng dụng của phân bố mũ và phân bố Poisson?
- Phân bố **mũ**: mô tả **thời gian** trong hệ thống phục vụ (thời gian chiếm kênh cuộc gọi, thời gian phục vụ ở quầy thu ngân, thời gian giữa hai lần đến).
- Phân bố **Poisson**: mô tả **số sự kiện** trong một đơn vị thời gian (số cuộc gọi đến tổng đài, số khách vào rạp).

## Phần B — Chương 3: hệ thống phục vụ và hàng đợi

B1. Hệ thống phục vụ là gì? Ví dụ.
Hệ thống **tiếp nhận yêu cầu ngẫu nhiên** từ bên ngoài, **xử lý/phục vụ** rồi cho yêu cầu **đi ra**. Mô hình hoá bằng hàng đợi gồm tiến trình tới A(t), tiến trình phục vụ, tiến trình ra D(t). Ví dụ: hệ thống giao thông, xếp hàng ở siêu thị, router trong mạng viễn thông.

B2. Ký hiệu Kendall A/B/c/k/N/SD.
A: tiến trình tới (M = Markov/Poisson, D = tất định, G = bất kỳ); B: tiến trình phục vụ; c: số server; k: dung lượng/chiều dài hàng đợi (mặc định ∞); N: quy mô nguồn (mặc định ∞); SD: quy tắc phục vụ (FIFO, LIFO, Round Robin, SIRO, Priority; mặc định FIFO). Ví dụ M/M/c/∞: tới Poisson, phục vụ mũ, c server, hàng đợi vô hạn.

B3. Hệ thống đóng là gì?
Hệ thống đóng (enclosed system) là hệ thống phục vụ mà **số yêu cầu đi vào = số yêu cầu đã đi ra + số đang nằm trong hệ thống**; hệ thống **không tự sinh ra** yêu cầu mới và **không huỷ bỏ** yêu cầu đang có. Hệ thống đóng có thể gồm một hay nhiều hàng đợi.

B4. Trong các hàng đợi M/M/1/1, M/M/1/∞, M/M/1/k, M/M/c/∞, M/M/c/c, M/M/c/k, M/G/1/∞, M/D/1/∞, hàng đợi nào là hệ thống đóng?
- **Là hệ thống đóng (khi ổn định ρ < 1)**: M/M/1/∞, M/M/c/∞, M/G/1/∞, M/D/1/∞ — hàng đợi vô hạn nên không yêu cầu nào bị huỷ.
- **Không phải hệ thống đóng**: M/M/1/1, M/M/1/k, M/M/c/c, M/M/c/k — dung lượng hữu hạn nên có yêu cầu **bị từ chối** (bị huỷ) với xác suất P_B.
- Ghi thêm: với các hệ có từ chối, phần yêu cầu **được chấp nhận** (tốc độ λ(1 − P_B)) tạo thành một hệ thống đóng → vẫn áp dụng Little với λ(1 − P_B).

B5. Định lý Little phát biểu thế nào, đúng cho hệ thống có tính chất gì, khi nào áp dụng được?
- **N = λT**: số yêu cầu trung bình trong hệ thống bằng tốc độ tới trung bình nhân thời gian lưu lại trung bình. Tương tự Nq = λTq, Ns = λTs.
- Đúng cho **hệ thống đóng ở chế độ ổn định** (các giới hạn trung bình tồn tại), **không phụ thuộc** phân bố của tiến trình tới và tiến trình phục vụ, không phụ thuộc quy tắc phục vụ.
- Little **chưa đủ** để đánh giá hiệu năng: biết λ vẫn còn hai ẩn N, T → cần thêm mô hình tiến trình tới và phục vụ.

B6. Điều kiện ổn định của hàng đợi? Mật độ lưu lượng (tải) là gì?
- Tải ρ = λ/(cμ). Hệ ổn định khi **0 < ρ < 1** hay **λ < cμ**; ngược lại hệ quá tải, hàng đợi tràn (N, T → ∞ khi ρ → 1).

B7. Tiến trình sinh – tử dùng để làm gì? Mô tả một hàng đợi bằng tiến trình sinh – tử.
- Là trường hợp đặc biệt của **chuỗi Markov**, dùng để mô tả chuyển trạng thái (trạng thái = số yêu cầu trong hệ), giúp **đơn giản hoá** việc tính xác suất trạng thái p_n mà không phải giải phương trình vi phân. Đúng khi tiến trình tới là Poisson và thời gian phục vụ phân bố mũ.
- Cách dùng: (1) xác định các trạng thái; (2) vẽ đồ hình trạng thái: từ n sang n+1 với tốc độ λn (sinh), từ n sang n−1 với tốc độ μn (tử); (3) viết **phương trình cân bằng**: tốc độ đi ra khỏi trạng thái = tốc độ đi vào trạng thái; (4) dùng Σp_n = 1.
- Ví dụ M/M/1: λp0 = μp1; (λ + μ)p_n = λp_(n−1) + μp_(n+1) → p_n = ρ^n(1 − ρ).

B8. Đồ hình trạng thái của M/M/c/∞ khác M/M/1/∞ thế nào?
- M/M/1: mọi mũi tên "tử" đều có tốc độ μ.
- M/M/c: tốc độ "tử" từ trạng thái n là **nμ khi n ≤ c** (chỉ n server bận) và **cμ khi n ≥ c** (cả c server bận). Mũi tên "sinh" vẫn là λ.

B9. Vì sao M/M/1/k có P_B > 0 dù ρ < 1?
Vì yêu cầu đến **ngẫu nhiên** (Poisson): dù trung bình λ < μ, vẫn có những lúc yêu cầu đến **dồn dập** làm bộ đệm hữu hạn bị đầy, yêu cầu đến lúc đó bị từ chối. Chỉ khi k → ∞ thì P_B → 0.

B10. Công thức Erlang B và Erlang C dùng để làm gì? Erlang là gì?
- **Erlang C** (M/M/c, có chỗ chờ): xác suất một yêu cầu **phải đợi** — dùng cho **call center**.
- **Erlang B** (M/M/c/c, không có chỗ chờ): xác suất một yêu cầu **bị từ chối** (nghẽn mạch) — dùng cho **tổng đài, nhóm kênh/trung kế**.
- **Erlang**: đơn vị đo tải/lưu lượng trong một giờ = số cuộc gọi trong giờ × thời gian trung bình mỗi cuộc (giờ). Ví dụ 60 cuộc/giờ × 5 phút = 5 Erlang.

B11. Với cùng tải ρ, hệ M/G/1 nào có hiệu năng tốt nhất? Với cùng tải, nút mạng hoạt động tốt nhất khi nào?
Hệ có **phương sai thời gian phục vụ nhỏ nhất**, tức **M/D/1** (phục vụ cố định, σs² = 0): Nq của M/D/1 chỉ bằng **một nửa** M/M/1. Với nút chuyển mạch gói: tốt nhất khi các gói có **độ dài bằng nhau** (thời gian phục vụ L/C cố định).

B12. Định lý Burke. Tiến trình ra của hàng đợi đơn ổn định với tới Poisson λ là gì?
Với hàng đợi M/M/1, M/M/c, M/M/∞ ổn định, tới Poisson λ: (1) **tiến trình ra cũng là Poisson với tốc độ λ** (thời gian giữa hai lần ra phân bố mũ tham số λ); (2) số yêu cầu trong hệ tại t **độc lập** với tiến trình ra trước t. Ý nghĩa: cho phép **tách mạng hàng đợi thành các hàng đợi đơn** để tính từng nút.

B13. Mạng hàng đợi là gì? Phân loại?
- Tập hợp k nút, mỗi nút là một hàng đợi đơn (ci server); yêu cầu vào/ra mạng tại một số nút. Rời nút i, yêu cầu có thể sang nút j (xác suất rij), quay lại i, hoặc ra ngoài (ri0).
- **Jackson đóng**: không có yêu cầu vào/ra (γi = 0, ri0 = 0 với mọi i), yêu cầu chỉ lưu thông trong mạng.
- **Jackson mở**: có yêu cầu đi vào và đi ra.
- **Nối tiếp**: trường hợp riêng của mạng mở, yêu cầu chỉ vào ở nút 1, đi lần lượt 1 → 2 → … → k rồi ra.

B14. Định lý Jackson (mạng mở).
λi = γi + Σj rji λj; ρi = λi/μi; xác suất trạng thái **p(n1, …, nk) = Π (1 − ρi)ρi^ni** — tức mỗi nút hoạt động như một hàng đợi **M/M/1 độc lập**. Từ đó N = Σ ρi/(1 − ρi), T = N/γ.

B15. KIA là gì?
Xấp xỉ độc lập Kleinrock: khi **ghép nhiều luồng Poisson** trên một đường truyền thì vẫn giữ được **tính độc lập** giữa các lần đến và thời gian phục vụ → coi mỗi liên kết như một hàng đợi M/M/1 độc lập. Dùng để tính trễ trung bình trong mạng nhiều luồng gói: T = (1/γ)Σ λij/(μij − λij).

B16. Trễ đầu cuối trong chuyển mạch gói gồm những thành phần nào? Trễ hàng đợi phụ thuộc vào gì?
- de2e = Σ (thời gian phát L/Ci + trễ lan truyền tpi = di/vp + trễ hàng đợi tqi) trên các chặng ("store-and-forward": nút trung gian nhận hết gói rồi mới gửi tiếp).
- Với một kết nối cố định, L/C và tp không đổi → trễ đầu cuối thay đổi chủ yếu do **trễ hàng đợi**, phụ thuộc **tải** của nút (lưu lượng nền — background traffic — gây tắc nghẽn), dung lượng kênh, độ dài và phân bố gói.

B17. Tại sao phải chia bản tin lớp trên thành nhiều gói trước khi truyền?
**Giảm trễ đầu cuối** (các gói đi gối đầu nhau trên các chặng thay vì chờ cả bản tin tới mới gửi tiếp) và **tăng độ tin cậy** (lỗi chỉ phải gửi lại gói nhỏ bị lỗi).

## Phần C — Câu hỏi tính nhẩm hay đi kèm (có đáp số)

C1. Router có trung bình 12 gói trong hệ, thông lượng 400 gói/s. Thời gian trung bình gói ở router? → T = N/λ = 12/400 = **30 ms** (Little).
C2. Một hàng đợi có λ = 50/s, μ = 40/s. Hệ có ổn định không? → ρ = 1,25 > 1 → **không ổn định** (với hàng đợi vô hạn).
C3. Một M/M/1/k có λ = 50/s, μ = 40/s có ổn định không? → **Có** — dung lượng hữu hạn nên luôn có trạng thái dừng; phần vượt quá bị từ chối.
C4. Đầu ra của một M/M/1 ổn định có λ = 30/s là gì? → **Poisson 30/s** (Burke).

## Trang sổ tay (trang 5) — từ khoá phải có

```
Mô hình hoá: trừu tượng + đơn giản hoá, lược bỏ yếu tố không cần
4 phương pháp: đo đạc, giả lập, mô phỏng, phân tích
Sự kiện NN = kết quả phép thử;  biến NN = ánh xạ kết quả → số thực
Biến rời rạc / liên tục; tham số: mật độ f(x), hàm phân bố F(x), E, Var, σ
Tiến trình NN = tập biến NN theo thời gian
Poisson: tăng trưởng độc lập + dừng + P(1 trong h) = λh + o(h) + P(≥2) = o(h)
  → số sự kiện: Poisson(λt); khoảng cách: mũ(λ); ghép Σλ; tách λp; không nhớ
Hệ thống đóng: vào = ra + đang ở; không sinh, không huỷ
  ĐÓNG: /∞ (M/M/1, M/M/c, M/G/1, M/D/1) khi ρ<1;  KHÔNG: /1/1, /1/k, /c/c, /c/k
Little N = λT: hệ đóng, ổn định, mọi phân bố
Sinh–tử: chuỗi Markov, cân bằng ra = vào; M/M/c: tử nμ (n≤c), cμ (n≥c)
Erlang B = từ chối (tổng đài); Erlang C = phải đợi (call center)
M/D/1 tốt nhất cùng ρ (σ² = 0)
Burke: ra = Poisson λ → tách mạng; Jackson: p = Π(1−ρi)ρi^ni
Jackson đóng / mở / nối tiếp;  KIA: ghép Poisson giữ độc lập
de2e = Σ(L/C + tp + tq); chia gói: giảm trễ, tăng tin cậy
```

## Bài tự luyện (viết câu trả lời vào ô chấm, mỗi câu tối đa 5 dòng)

1. Phân biệt sự kiện ngẫu nhiên và biến ngẫu nhiên. Cho ví dụ.
2. Nêu khái niệm tiến trình Poisson và hai tính chất ghép/tách.
3. Hệ thống đóng là gì? M/M/1/k có phải hệ thống đóng không? Khi đó áp dụng định lý Little thế nào?
4. Định lý Little đúng cho hệ thống nào? Phát biểu và cho ví dụ ý nghĩa.
5. Tiến trình sinh – tử dùng để làm gì? Viết phương trình cân bằng cho hàng đợi M/M/1/3.
6. Phân biệt công thức Erlang B và Erlang C (mô hình, ý nghĩa, ứng dụng).
7. Phát biểu định lý Burke và nêu ý nghĩa với mạng hàng đợi.
8. Vì sao cùng tải ρ thì M/D/1 cho trễ nhỏ hơn M/M/1?

## Đáp án gợi ý

1–4, 6–8: xem câu A5, A9–A10, B3–B4, B5, B10, B12, B11 ở trên.
5. Dùng để tính xác suất trạng thái (xem B7). M/M/1/3 (trạng thái 0, 1, 2, 3): λp0 = μp1; (λ + μ)p1 = λp0 + μp2; (λ + μ)p2 = λp1 + μp3; λp2 = μp3; và p0 + p1 + p2 + p3 = 1.
