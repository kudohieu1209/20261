// Questions and answers shared by the tablet lesson and printed reference.
#let exam-questions = (
  (id: "A1", question: [Mô hình hoá là gì? Vì sao phải mô hình hoá?], answer: [
  - Mô hình hoá là quá trình *trừu tượng hoá và đơn giản hoá* hệ thống thực bằng cách *lược bỏ yếu tố không cần thiết*, mô tả hệ thống bằng các tham số và ràng buộc.
  - Cần mô hình hoá khi *không đo đạc trực tiếp được* hoặc muốn *dự đoán* hiệu năng khi hệ thống thay đổi (ví dụ: muốn biết xác suất rớt cuộc gọi $p_0 = f(n, lambda, t)$ để quyết định xây thêm bao nhiêu trạm, đặt ở đâu).
], network: false),
  (id: "A2", question: [Các phương pháp đánh giá hiệu năng?], answer: [
  - *Đo đạc* (measurement): đo trên hệ thống thực đang chạy.
  - *Giả lập* (emulation): dựng hệ thống thử nghiệm (prototype) hoạt động giống hệ thống thực.
  - *Mô hình hoá mô phỏng* (simulation): mô hình phần mềm trên máy tính.
  - *Mô hình hoá phân tích* (analytical modeling): dùng công cụ toán học (ví dụ lý thuyết hàng đợi).
], network: false),
  (id: "A3", question: [Các bước mô hình hoá / quá trình đánh giá hiệu năng?], answer: [
  - Đo đạc, thu thập dữ liệu hệ thống thực (lưu lượng vào, thời gian phục vụ…) → mô hình hoá → *phân tích, so sánh* (độ chính xác, độ phức tạp) → *hiệu chỉnh* (validation) → *đánh giá kết quả* cho hệ thống thực.
], network: false),
  (id: "A4", question: [Các tham số đánh giá hiệu năng?], answer: [
  - *Thời gian*: thời gian thực hiện một yêu cầu, thời gian đáp ứng, thời gian lưu lại hệ thống.
  - *Không gian*: độ lớn hàng đợi/bộ đệm, bộ nhớ cần cho chương trình.
  - *Khác*: thông lượng, giá thành.
], network: false),
  (id: "A5", question: [Phân biệt sự kiện ngẫu nhiên và biến ngẫu nhiên.], answer: [
  - *Sự kiện ngẫu nhiên* là một tập các kết quả của phép thử, tức một tập con của không gian mẫu $Omega$ (ví dụ: xúc xắc ra số chẵn).
  - *Biến ngẫu nhiên* là *ánh xạ* từ kết quả của phép thử sang *số thực*: $X: Omega -> RR$ (ví dụ: số chấm của xúc xắc).
], network: false),
  (id: "A6", question: [Có mấy loại biến ngẫu nhiên? Dùng tham số gì để mô tả?], answer: [
  - *Rời rạc*: tập giá trị hữu hạn hoặc vô hạn đếm được (số cuộc gọi đến tổng đài, điểm thi).
  - *Liên tục*: giá trị lấp kín một khoảng (nhiệt độ, tuổi thọ bóng đèn).
  - Tham số: *hàm mật độ xác suất* $f(x)$, *hàm phân bố xác suất* $F(x)$, *kỳ vọng* $E(x)$ (giá trị trung bình), *phương sai* $"Var"(x)$ và *độ lệch chuẩn* $sigma$ (độ phân tán quanh kỳ vọng; càng lớn càng bất định).
], network: false),
  (id: "A7", question: [Tiến trình ngẫu nhiên là gì? Khác biến ngẫu nhiên thế nào?], answer: [
  - Tiến trình ngẫu nhiên là *tập hợp các biến ngẫu nhiên ${X(t)}$ thay đổi theo thời gian $t$* (một tập các hàm thời gian kèm luật xác suất).
  - Khác biệt: biến ngẫu nhiên là *một giá trị* ngẫu nhiên; tiến trình ngẫu nhiên là *một hàm theo thời gian*, mỗi thời điểm là một biến ngẫu nhiên. Ví dụ: lưu lượng Internet thay đổi theo giờ trong ngày.
  - Biến ngẫu nhiên *không đủ* mô tả mọi quá trình thực tế vì nhiều quá trình thay đổi theo thời gian → cần tiến trình ngẫu nhiên.
], network: false),
  (id: "A8", question: [Tiến trình đếm, tăng trưởng độc lập, tăng trưởng dừng?], answer: [
  - *Đếm*: $N(0) = 0$, $N(t) >= 0$, không giảm theo $t$; $N(t) - N(s)$ = số sự kiện trong $(s, t]$. Ví dụ: số xe qua ngã tư.
  - *Tăng trưởng độc lập*: số sự kiện trong các khoảng thời gian *không chồng nhau là độc lập* với nhau.
  - *Tăng trưởng dừng*: số sự kiện chỉ phụ thuộc *độ dài* khoảng quan sát, không phụ thuộc thời điểm bắt đầu.
], network: false),
  (id: "A9", question: [Khái niệm tiến trình Poisson.], answer: [
  $N(t)$ là tiến trình Poisson tham số $lambda > 0$ nếu:
  + *tăng trưởng độc lập*;
  + *tăng trưởng dừng*;
  + P(có đúng 1 sự kiện trong khoảng $h$ nhỏ) = $bold(lambda h + o(h))$;
  + P(có từ 2 sự kiện trở lên trong $h$) = $bold(o(h))$.

  Hệ quả: số sự kiện trong khoảng $t$ có *phân bố Poisson* tham số $lambda t$: $display(P(k) = ((lambda t)^k e^(-lambda t)) / k!)$ (Định lý 1); thời gian giữa hai sự kiện liên tiếp có *phân bố mũ*: $P(T <= t) = 1 - e^(-lambda t)$ (Định lý 2).
], network: false),
  (id: "A10", question: [Các tính chất của tiến trình Poisson.], answer: [
  - *Kết hợp (ghép)*: tổng $n$ tiến trình Poisson độc lập $lambda_1 dots lambda_n$ là tiến trình Poisson với $lambda = sum lambda_i$.
  - *Phân tách*: tách tiến trình Poisson $lambda$ theo xác suất $p_1 dots p_n$ được các tiến trình Poisson $lambda p_1 dots lambda p_n$.
  - *Không nhớ* (của phân bố mũ): $P(x <= u + t | x > u) = P(x <= t)$ — đã chờ bao lâu không ảnh hưởng thời gian chờ tiếp.
], network: false),
  (id: "A11", question: [Ứng dụng của phân bố mũ và phân bố Poisson?], answer: [
  - Phân bố *mũ*: mô tả *thời gian* trong hệ thống phục vụ (thời gian chiếm kênh cuộc gọi, thời gian phục vụ ở quầy thu ngân, thời gian giữa hai lần đến).
  - Phân bố *Poisson*: mô tả *số sự kiện* trong một đơn vị thời gian (số cuộc gọi đến tổng đài, số khách vào rạp).
], network: false),
  (id: "B1", question: [Hệ thống phục vụ là gì? Ví dụ.], answer: [
  Hệ thống *tiếp nhận yêu cầu ngẫu nhiên* từ bên ngoài, *xử lý/phục vụ* rồi cho yêu cầu *đi ra*. Mô hình hoá bằng hàng đợi gồm tiến trình tới $A(t)$, tiến trình phục vụ, tiến trình ra $D(t)$. Ví dụ: hệ thống giao thông, xếp hàng ở siêu thị, router trong mạng viễn thông.
], network: false),
  (id: "B2", question: [Ký hiệu Kendall A/B/c/k/N/SD.], answer: [
  - A: tiến trình tới (M = Markov/Poisson, D = tất định, G = bất kỳ);
  - B: tiến trình phục vụ;
  - c: số server;
  - k: dung lượng toàn hệ thống, gồm chỗ chờ và số server (mặc định ∞);
  - N: quy mô nguồn (mặc định ∞);
  - SD: quy tắc phục vụ (FIFO, LIFO, Round Robin, SIRO, Priority; mặc định FIFO).

  Ví dụ M/M/c/∞: tới Poisson, phục vụ mũ, c server, hàng đợi vô hạn.
], network: false),
  (id: "B3", question: [Hệ thống đóng là gì?], answer: [
  Hệ thống đóng (enclosed system) là hệ thống phục vụ mà *số yêu cầu đi vào = số yêu cầu đã đi ra + số đang nằm trong hệ thống*; hệ thống *không tự sinh ra* yêu cầu mới và *không huỷ bỏ* yêu cầu đang có. Hệ thống đóng có thể gồm một hay nhiều hàng đợi.
], network: false),
  (id: "B4", question: [Trong các hàng đợi M/M/1/1, M/M/1/∞, M/M/1/k, M/M/c/∞, M/M/c/c, M/M/c/k, M/G/1/∞, M/D/1/∞, hàng đợi nào là hệ thống đóng?], answer: [
  - *Là hệ thống đóng (khi ổn định $bold(rho < 1)$)*: M/M/1/∞, M/M/c/∞, M/G/1/∞, M/D/1/∞ — hàng đợi vô hạn nên không yêu cầu nào bị huỷ.
  - *Không phải hệ thống đóng*: M/M/1/1, M/M/1/k, M/M/c/c, M/M/c/k — dung lượng hữu hạn nên có yêu cầu *bị từ chối* (bị huỷ) với xác suất $P_B$.
  - Ghi thêm: với các hệ có từ chối, phần yêu cầu *được chấp nhận* (tốc độ $lambda(1 - P_B)$) tạo thành một hệ thống đóng → vẫn áp dụng Little với $lambda(1 - P_B)$.
], network: false),
  (id: "B5", question: [Định lý Little phát biểu thế nào, đúng cho hệ thống có tính chất gì, khi nào áp dụng được?], answer: [
  - $bold(N = lambda T)$: số yêu cầu trung bình trong hệ thống bằng tốc độ tới trung bình nhân thời gian lưu lại trung bình. Tương tự $N_q = lambda T_q$, $N_s = lambda T_s$.
  - Đúng cho *hệ thống đóng ở chế độ ổn định* (các giới hạn trung bình tồn tại), *không phụ thuộc* phân bố của tiến trình tới và tiến trình phục vụ, không phụ thuộc quy tắc phục vụ.
  - Little *chưa đủ* để đánh giá hiệu năng: biết $lambda$ vẫn còn hai ẩn $N$, $T$ → cần thêm mô hình tiến trình tới và phục vụ.
], network: false),
  (id: "B6", question: [Điều kiện ổn định của hàng đợi? Mật độ lưu lượng (tải) là gì?], answer: [
  - Tải $rho = lambda \/ (c mu)$. Với M/M/c có hàng đợi vô hạn: ổn định khi $bold(rho < 1)$, tức $bold(lambda < c mu)$; khi $rho -> 1$ từ phía dưới thì $N, T -> infinity$.
  - Với dung lượng hữu hạn, hệ vẫn có trạng thái dừng khi $rho >= 1$; yêu cầu tới lúc đầy bị từ chối. M/M/∞ có trạng thái dừng với tốc độ tới hữu hạn và $mu > 0$.
], network: false),
  (id: "B7", question: [Tiến trình sinh – tử dùng để làm gì? Mô tả một hàng đợi bằng tiến trình sinh – tử.], answer: [
  - Là trường hợp đặc biệt của *chuỗi Markov*, dùng để mô tả chuyển trạng thái (trạng thái = số yêu cầu trong hệ), giúp *đơn giản hoá* việc tính xác suất trạng thái $p_n$ mà không phải giải phương trình vi phân. Đúng khi tiến trình tới là Poisson và thời gian phục vụ phân bố mũ.
  - Cách dùng:
    + xác định các trạng thái;
    + vẽ đồ hình trạng thái: từ $n$ sang $n+1$ với tốc độ $lambda_n$ (sinh), từ $n$ sang $n-1$ với tốc độ $mu_n$ (tử);
    + viết *phương trình cân bằng*: tốc độ đi ra khỏi trạng thái = tốc độ đi vào trạng thái;
    + dùng $sum p_n = 1$.
  - Ví dụ M/M/1: $lambda p_0 = mu p_1$; $(lambda + mu) p_n = lambda p_(n-1) + mu p_(n+1)$ → $p_n = rho^n (1 - rho)$.
], network: false),
  (id: "B8", question: [Đồ hình trạng thái của M/M/c/∞ khác M/M/1/∞ thế nào?], answer: [
  - M/M/1: mọi mũi tên "tử" đều có tốc độ $mu$.
  - M/M/c: tốc độ "tử" từ trạng thái $n$ là $bold(n mu)$ *khi* #box[$bold(n <= c)$] (chỉ $n$ server bận) và $bold(c mu)$ *khi* #box[$bold(n >= c)$] (cả $c$ server bận). Mũi tên "sinh" vẫn là $lambda$.
], network: false),
  (id: "B9", question: [Vì sao M/M/1/k có $P_B > 0$ dù $rho < 1$?], answer: [
  Vì yêu cầu đến *ngẫu nhiên* (Poisson): dù trung bình $lambda < mu$, vẫn có những lúc yêu cầu đến *dồn dập* làm bộ đệm hữu hạn bị đầy, yêu cầu đến lúc đó bị từ chối. Chỉ khi $k -> infinity$ thì $P_B -> 0$.
], network: false),
  (id: "B10", question: [Công thức Erlang B và Erlang C dùng để làm gì? Erlang là gì?], answer: [
  - *Erlang C* (M/M/c, có chỗ chờ): xác suất một yêu cầu *phải đợi* — dùng cho *call center*.
  - *Erlang B* (M/M/c/c, không có chỗ chờ): xác suất một yêu cầu *bị từ chối* (nghẽn mạch) — dùng cho *tổng đài, nhóm kênh/trung kế*.
  - *Erlang*: đơn vị đo tải/lưu lượng trong một giờ = số cuộc gọi trong giờ × thời gian trung bình mỗi cuộc (giờ). Ví dụ 60 cuộc/giờ × 5 phút = 5 Erlang.
], network: false),
  (id: "B11", question: [Với cùng tải $rho$, hệ M/G/1 nào có hiệu năng tốt nhất? Với cùng tải, nút mạng hoạt động tốt nhất khi nào?], answer: [
  Khi giữ cùng tốc độ tới và cùng thời gian phục vụ trung bình, hệ có *phương sai thời gian phục vụ nhỏ nhất*, tức *M/D/1* (phục vụ cố định, #box[$sigma_s^2 = 0$]), có thời gian chờ nhỏ nhất. $N_q$ của M/D/1 bằng *một nửa* M/M/1. Với nút chuyển mạch gói có dung lượng cố định, các gói có *độ dài bằng nhau* cho thời gian phát $L\/C$ cố định.
], network: false),
  (id: "B12", question: [Định lý Burke. Tiến trình ra của hàng đợi đơn ổn định với tới Poisson $lambda$ là gì?], answer: [
  Với hàng đợi M/M/1, M/M/c, M/M/∞ ổn định, tới Poisson $lambda$:
  + *tiến trình ra cũng là Poisson với tốc độ $lambda$* (thời gian giữa hai lần ra phân bố mũ tham số $lambda$);
  + số yêu cầu trong hệ tại $t$ *độc lập* với tiến trình ra trước $t$.

  Ý nghĩa: cho phép *tách mạng hàng đợi thành các hàng đợi đơn* để tính từng nút.
], network: true),
  (id: "B13", question: [Mạng hàng đợi là gì? Phân loại?], answer: [
  - Tập hợp $k$ nút, mỗi nút là một hàng đợi đơn ($c_i$ server); yêu cầu vào/ra mạng tại một số nút. Rời nút $i$, yêu cầu có thể sang nút $j$ (xác suất $r_(i j)$), quay lại $i$, hoặc ra ngoài ($r_(i 0)$).
  - *Jackson đóng*: không có yêu cầu vào/ra ($gamma_i = 0$, $r_(i 0) = 0$ với mọi $i$), yêu cầu chỉ lưu thông trong mạng.
  - *Jackson mở*: có yêu cầu đi vào và đi ra.
  - *Nối tiếp*: trường hợp riêng của mạng mở, yêu cầu chỉ vào ở nút 1, đi lần lượt 1 → 2 → … → k rồi ra.
], network: true),
  (id: "B14", question: [Định lý Jackson (mạng mở).], answer: [
  $lambda_i = gamma_i + sum_j r_(j i) lambda_j$; #h(0.6em) $rho_i = lambda_i \/ mu_i$; #h(0.6em) xác suất trạng thái $bold(p(n_1, dots, n_k) = product (1 - rho_i) rho_i^(n_i))$ — tức mỗi nút hoạt động như một hàng đợi *M/M/1 độc lập*. Từ đó $N = sum rho_i \/ (1 - rho_i)$, $T = N \/ gamma$.
], network: true),
  (id: "B15", question: [KIA là gì?], answer: [
  Xấp xỉ độc lập Kleinrock: *xấp xỉ* các hàng đợi liên kết là độc lập để phân tích mạng gói. Với giả thiết M/M/1 tại mỗi liên kết, dùng $T_(i j) = 1\/(mu_(i j)-lambda_(i j))$ và lấy trung bình theo lưu lượng: $T = (1\/gamma) sum lambda_(i j) \/ (mu_(i j) - lambda_(i j))$ khi bỏ qua trễ lan truyền.
], network: true),
  (id: "B16", question: [Trễ đầu cuối trong chuyển mạch gói gồm những thành phần nào? Trễ hàng đợi phụ thuộc vào gì?], answer: [
  - $d_(e 2 e) = sum$ (thời gian phát $L\/C_i$ + trễ lan truyền $t_(p i) = d_i \/ v_p$ + trễ hàng đợi $t_(q i)$) trên các chặng ("store-and-forward": nút trung gian nhận hết gói rồi mới gửi tiếp).
  - Với một kết nối cố định, $L\/C$ và $t_p$ không đổi → trễ đầu cuối thay đổi chủ yếu do *trễ hàng đợi*, phụ thuộc *tải* của nút (lưu lượng nền — background traffic — gây tắc nghẽn), dung lượng kênh, độ dài và phân bố gói.
], network: true),
  (id: "B17", question: [Tại sao phải chia bản tin lớp trên thành nhiều gói trước khi truyền?], answer: [
  *Giảm trễ đầu cuối* (các gói đi gối đầu nhau trên các chặng thay vì chờ cả bản tin tới mới gửi tiếp) và *tăng độ tin cậy* (lỗi chỉ phải gửi lại gói nhỏ bị lỗi).
], network: true),
  (id: "C1", question: [Router có trung bình 12 gói trong hệ, thông lượng 400 gói/s. Thời gian trung bình gói ở router?], answer: [
  → $T = N \/ lambda = 12 \/ 400 = bold(30 "ms")$ (Little).
], network: false),
  (id: "C2", question: [Một hàng đợi có $lambda = 50$/s, $mu = 40$/s. Hệ có ổn định không?], answer: [
  → $rho = 1","25 > 1$ → *không ổn định* (với hàng đợi vô hạn).
], network: false),
  (id: "C3", question: [Một M/M/1/k có $lambda = 50$/s, $mu = 40$/s có ổn định không?], answer: [
  → *Có* — dung lượng hữu hạn nên luôn có trạng thái dừng; phần vượt quá bị từ chối.
], network: false),
  (id: "C4", question: [Đầu ra của một M/M/1 ổn định có $lambda = 30$/s là gì?], answer: [
  → *Poisson 30/s* (Burke).
], network: true),
)

// Bản trả lời ngắn cho giấy; cùng mã câu hỏi với phần giải thích đầy đủ phía trên.
#let print-answers = (
  A1: [Mô hình hoá là *trừu tượng hoá, đơn giản hoá* hệ thống thực bằng tham số và ràng buộc. Dùng khi khó đo trực tiếp hoặc cần dự đoán hiệu năng khi thay đổi tải, số server hay dung lượng.],
  A2: [Bốn cách: *đo đạc* trên hệ thống thật; *giả lập* bằng hệ thử nghiệm; *mô phỏng* bằng chương trình; *phân tích* bằng mô hình toán. Chọn cách theo chi phí và độ chính xác cần đạt.],
  A3: [Xác định mục tiêu → thu thập dữ liệu → xây mô hình → phân tích/mô phỏng → so sánh, hiệu chỉnh → đánh giá kết quả. Mô hình cần phản ánh những yếu tố ảnh hưởng đến chỉ tiêu đang xét.],
  A4: [Nhóm *thời gian*: đáp ứng, chờ, lưu lại; nhóm *không gian*: hàng đợi, bộ đệm, bộ nhớ; ngoài ra có *thông lượng, chi phí*. Cần ghi rõ chỉ tiêu và đơn vị đo.],
  A5: [Phép thử có không gian mẫu $Omega$; sự kiện là tập các kết quả, ví dụ “xúc xắc ra số chẵn”. *Biến ngẫu nhiên* là ánh xạ $X: Omega -> RR$, ví dụ số chấm xuất hiện.],
  A6: [*Rời rạc*: hữu hạn hoặc đếm được; *liên tục*: nhận giá trị trên một khoảng. Mô tả bằng xác suất/mật độ, hàm phân bố $F(x)$, kỳ vọng $E[X]$, phương sai $"Var"(X)$ và độ lệch chuẩn $sigma$.],
  A7: [Tiến trình ngẫu nhiên là họ biến ngẫu nhiên $\{X(t)\}$ theo thời gian. Một biến ngẫu nhiên mô tả giá trị; tiến trình mô tả cả sự biến đổi theo thời gian, ví dụ số gói trong router tại từng thời điểm.],
  A8: [Tiến trình đếm: $N(0)=0$, nhận giá trị nguyên không âm và không giảm. *Tăng trưởng độc lập*: số sự kiện trên các khoảng rời nhau độc lập. *Tăng trưởng dừng*: phân bố số sự kiện chỉ phụ thuộc độ dài khoảng.],
  A9: [Tiến trình đếm có tăng trưởng độc lập, dừng; trong khoảng $h$ nhỏ, $P(1)=lambda h+o(h)$, $P(>=2)=o(h)$. Khi đó $N(t)$ có phân bố Poisson($lambda t$), khoảng cách giữa hai lần đến có phân bố mũ tốc độ $lambda$.],
  A10: [Ghép các tiến trình Poisson *độc lập*: tốc độ $sum_i lambda_i$. Tách theo lựa chọn độc lập xác suất $p_i$: tốc độ $lambda p_i$. Phân bố mũ của khoảng cách có tính không nhớ: $P(S>u+t | S>u)=P(S>t)$.],
  A11: [*Poisson đếm số sự kiện* trong một khoảng, ví dụ số cuộc gọi trong 2 phút. *Mũ mô tả thời gian*, ví dụ thời gian giữa hai cuộc gọi hoặc thời gian chiếm kênh theo giả thiết đề.],
  B1: [Hệ thống phục vụ tiếp nhận yêu cầu, xử lý rồi cho yêu cầu đi ra. Mô hình gồm tiến trình tới, chỗ chờ, server, quy tắc phục vụ và tiến trình ra; ví dụ quầy thu ngân hoặc router.],
  B2: [A: tới; B: phục vụ; c: số server; k: *dung lượng toàn hệ*; N: quy mô nguồn; SD: kỷ luật phục vụ. M: Poisson/mũ; D: tất định; G: tổng quát. Có $Q$ chỗ chờ thì $k=Q+c$.],
  B3: [Hệ thống đóng (*enclosed system*) bảo toàn yêu cầu: vào = đã ra + đang ở, với hệ ban đầu rỗng; không tự sinh hoặc huỷ yêu cầu. Khái niệm này khác mạng Jackson đóng có số khách cố định.],
  B4: [Các hệ không từ chối M/M/1/∞, M/M/c/∞, M/G/1/∞, M/D/1/∞ bảo toàn yêu cầu khi ổn định. Hệ hữu hạn có từ chối; xét riêng yêu cầu *được nhận* với tốc độ $lambda_a=lambda(1-P_B)$ để áp dụng Little.],
  B5: [Little: $N=lambda_a T$, $N_q=lambda_a T_q$ khi các trung bình ổn định tồn tại và xét cùng dòng yêu cầu. Không đòi hỏi tới Poisson hay phục vụ mũ. Little liên hệ các đại lượng, cần thêm mô hình để tính đủ $N,T$.],
  B6: [Với M/M/c vô hạn: $rho=lambda/(c mu)<1$. Hệ hữu hạn vẫn có trạng thái dừng khi $rho>=1$, nhưng từ chối lúc đầy. M/M/∞ không phải kiểm tra $lambda<c mu$ vì không giới hạn server.],
  B7: [Sinh–tử là chuỗi Markov liên tục, mỗi bước chỉ tăng/giảm một yêu cầu. Vẽ trạng thái, gán $lambda_n,mu_n$, viết cân bằng và $sum p_n=1$. Quan hệ kề: $lambda_n p_n=mu_(n+1)p_(n+1)$.],
  B8: [M/M/1: tốc độ tử $mu$ khi có khách. M/M/c: tốc độ tử $min(n,c)mu$ vì chỉ tối đa $c$ server hoạt động. Tốc độ sinh là $lambda$ khi hệ còn chỗ; bằng 0 tại trạng thái đầy.],
  B9: [Dù tải trung bình nhỏ hơn năng lực phục vụ, khách vẫn có thể đến dồn dập. Bộ đệm hữu hạn có xác suất đầy dương nên yêu cầu đến lúc đầy bị từ chối. $rho<1$ không có nghĩa $P_B=0$.],
  B10: [*Erlang B*: M/M/c/c, xác suất bị từ chối, dùng cho nhóm kênh/trung kế. *Erlang C*: M/M/c/∞, xác suất phải đợi, dùng cho call center. Tải $a=lambda/mu$ đo bằng Erlang; $rho=a/c$.],
  B11: [Với *cùng $lambda$ và cùng thời gian phục vụ trung bình*, giảm phương sai phục vụ làm giảm thời gian chờ M/G/1. M/D/1 có phương sai 0, $N_q$ bằng một nửa M/M/1. Gói dài bằng nhau cho thời gian phát cố định nếu dung lượng kênh cố định.],
  B12: [Burke: đầu ra của M/M/1 ổn định có tới Poisson $lambda$ cũng là Poisson $lambda$; tương tự cho M/M/c/∞ và M/M/∞. Số khách hiện tại độc lập với quá trình ra trước đó. Đây là cơ sở phân tích một số mạng hàng đợi.],
  B13: [Mạng hàng đợi là tập nút phục vụ liên kết bởi xác suất chuyển tuyến. *Mở*: có khách vào/ra ngoài. *Jackson đóng*: số khách cố định, chỉ lưu thông trong mạng. *Nối tiếp*: khách qua lần lượt các nút rồi ra.],
  B14: [Mạng Jackson mở với các nút M/M/1 ổn định: $lambda_i=gamma_i+sum_j r_(j i)lambda_j$. Phân bố trạng thái dừng có dạng tích $product_i (1-rho_i)rho_i^(n_i)$. Tính từng $N_i$, cộng lại rồi chia tổng tốc độ tới từ ngoài để có $T$.],
  B15: [KIA là *xấp xỉ độc lập Kleinrock*: coi các hàng đợi liên kết gần như độc lập để tính hiệu năng mạng gói. Với giả thiết M/M/1 tại liên kết, $T_(i j)=1/(mu_(i j)-lambda_(i j))$; cộng theo đường hoặc lấy trọng số lưu lượng cho cả mạng.],
  B16: [Trễ đầu cuối gồm *phát gói* $L/C$, *lan truyền* $d/v$, *chờ hàng đợi* và xử lý nếu đề cho. Trong store-and-forward, cộng trên từng chặng. Trễ chờ phụ thuộc tải, năng lực phục vụ và độ biến động của lưu lượng/thời gian phục vụ.],
  B17: [Chia bản tin thành nhiều gói cho phép truyền *gối đầu* trên các chặng, giảm thời gian chờ cả bản tin. Khi lỗi, chỉ gửi lại gói nhỏ bị lỗi thay vì toàn bộ bản tin; đánh đổi là phần tiêu đề và xử lý từng gói.],
  C1: [$T=N/lambda=12/400="0,03"$ s = *30 ms*.],
  C2: [M/M/1 vô hạn: $rho=50/40="1,25">1$ → *không ổn định*.],
  C3: [M/M/1/k hữu hạn: *có trạng thái dừng*; yêu cầu tới lúc đầy bị từ chối.],
  C4: [M/M/1 ổn định, tới Poisson 30/s → ra *Poisson 30/s*.],
)
