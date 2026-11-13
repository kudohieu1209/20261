// Công thức dùng chung. Bản in tách công thức dài thành dòng riêng để giữ chỉ số rõ.
#let core-formulas = (
  (id: "F1", title: "Poisson — số lần đến trong khoảng t", body: [
    Đặt $m = lambda t$, với $lambda$ và $t$ cùng đơn vị; $k = 0,1,2,dots$.
    $ P(X=k) = (m^k e^(-m))/k!, quad E[X] = "Var"(X) = m. $
    Ít nhất một sự kiện: $P(X>=1)=1-e^(-m)$. Không quá $k$ sự kiện:
    $ P(X<=k) = e^(-m) sum_(j=0)^k m^j/j!. $
    Ghép các luồng Poisson độc lập: $lambda=sum_i lambda_i$.
    Tách độc lập theo xác suất $p_i$: $lambda_i=lambda p_i$.
  ]),
  (id: "F2", title: "Phân bố mũ — thời gian giữa hai lần đến / phục vụ", body: [
    Trung bình $tau$ tương ứng tốc độ $r=1/tau$.
    $ E[S]=1/r, quad "Var"(S)=1/r^2. $
    $ P(S>t)=e^(-r t), quad P(S<=t)=1-e^(-r t). $
    Với $0<=a<=b$:
    $ P(a<=S<=b)=e^(-r a)-e^(-r b). $
    Không nhớ: $P(S>u+t | S>u)=P(S>t)$.
  ]),
  (id: "F3", title: "M/M/1 — một server, chỗ chờ vô hạn", body: [
    Điều kiện: $rho=lambda/mu<1$.
    $ p_0=1-rho, quad p_n=(1-rho)rho^n, quad P(X>=n)=rho^n. $
    $ N=rho/(1-rho), quad N_q=rho^2/(1-rho). $
    $ T=1/(mu-lambda), quad T_q=rho/(mu-lambda)=T-1/mu. $
    Xác suất thời gian trong hệ / chờ không quá $t$, với $t>=0$:
    $ P(T_"hệ"<=t)=1-e^(-(mu-lambda)t), $
    $ P(T_"chờ"<=t)=1-rho e^(-(mu-lambda)t). $
    Hỏi ngược với $T_0>0$:
    $ T<=T_0 quad => quad lambda<=mu-1/T_0. $
  ]),
  (id: "F4", title: "M/M/1/k — một server, dung lượng hữu hạn", body: [
    $k=Q+1$, với $Q$ là số chỗ chờ; $rho=lambda/mu$. Khi $rho!=1$:
    $ p_0=(1-rho)/(1-rho^(k+1)), quad p_n=rho^n p_0, quad P_B=p_k. $
    $ N=rho/(1-rho)-((k+1)rho^(k+1))/(1-rho^(k+1)). $
    $ N_q=N-(1-p_0), quad lambda_a=lambda(1-P_B). $
    $ T=N/lambda_a, quad T_q=N_q/lambda_a. $
    Khi $rho=1$: $p_n=1/(k+1)$ và $N=k/2$.

    Trường hợp M/M/1/1, không có chỗ chờ:
    $ P_B=lambda/(lambda+mu), quad N=P_B, quad T=1/mu. $
    Hệ hữu hạn vẫn có trạng thái dừng khi $rho>=1$.
  ]),
  (id: "F5", title: "M/M/c — Erlang C, chỗ chờ vô hạn", body: [
    $a=lambda/mu$ là tải toàn hệ; $rho=a/c=lambda/(c mu)<1$.
    $ p_0=(sum_(n=0)^(c-1) a^n/n!+a^c/(c!(1-rho)))^(-1). $
    $ C(c,a)=a^c/(c!(1-rho)) p_0=P("phải đợi"). $
    $ N_q=C rho/(1-rho), quad N=a+N_q. $
    $ T_q=C/(c mu-lambda), quad T=T_q+1/mu. $
    Phục vụ ngay: $1-C$. Chọn số server bằng cách thử các $c$ nguyên thỏa $c>a$, rồi kiểm tra $C$ không vượt ngưỡng đề cho.
  ]),
  (id: "F6", title: "M/M/c/c — Erlang B, không có chỗ chờ", body: [
    Đặt $a=lambda/mu$; $P_B=B(c,a)$. Không cần $rho<1$ để có trạng thái dừng.
    $ B(c,a)=(a^c/c!)/(sum_(n=0)^c a^n/n!). $
    Bấm theo đệ quy với $B(0,a)=1$:
    $ B(j,a)=(a B(j-1,a))/(j+a B(j-1,a)). $
    $ N=a(1-B), quad T=1/mu, quad N_q=T_q=0. $
    Tốc độ được nhận: $lambda_a=lambda(1-B)$.
    Tải Erlang = số cuộc/giờ × thời gian trung bình mỗi cuộc tính bằng giờ.
  ]),
  (id: "F7", title: "M/M/c/k — c server, dung lượng k ≥ c", body: [
    Đặt $a=lambda/mu$, $rho=a/c$. Chuẩn hoá bằng tổng hữu hạn:
    $ w_n=cases(a^n/n! & 0<=n<=c, (a^c/c!)rho^(n-c) & c<n<=k). $
    $ p_0=1/(sum_(n=0)^k w_n), quad p_n=w_n p_0, quad P_B=p_k. $
    $ N=sum_(n=0)^k n p_n, quad N_q=sum_(n=c)^k (n-c)p_n. $
    $ lambda_a=lambda(1-P_B), quad T=N/lambda_a, quad T_q=N_q/lambda_a. $
    Xác suất được nhận và phải đợi:
    $ P_"đợi"=sum_(n=c)^(k-1) p_n. $
    Xác suất phải đợi trong số đã được nhận:
    $ P("đợi" | "nhận")=P_"đợi"/(1-P_B). $
    Phục vụ ngay:
    $ P_"ngay"=sum_(n=0)^(c-1) p_n. $
    Kiểm tra: $P_"ngay"+P_"đợi"+P_B=1$.
  ]),
  (id: "F8", title: "M/M/∞ — mọi yêu cầu được phục vụ ngay", body: [
    Với $a=lambda/mu$:
    $ p_n=(a^n e^(-a))/n!, quad N=a, quad T=1/mu. $
    $N_q=T_q=P_B=0$. Tốc độ sinh là $lambda$; tốc độ tử ở trạng thái $n$ là $n mu$.
  ]),
  (id: "F9", title: "M/G/1 và M/D/1 — một server, FIFO, chỗ chờ vô hạn", body: [
    Đặt $E[S]=1/mu$, $sigma_s^2="Var"(S)$ và $rho=lambda E[S]<1$.
    $ E[S^2]=sigma_s^2+E[S]^2. $
    $ T_q=(lambda E[S^2])/(2(1-rho)), quad T=T_q+E[S]. $
    $ N_q=(rho^2+lambda^2 sigma_s^2)/(2(1-rho)), quad N=rho+N_q=lambda T. $
    Nhiều loại tác vụ: $p_i$ là tỉ lệ loại $i$:
    $ E[S^j]=sum_i p_i E[S_i^j]. $
    Riêng M/D/1, $sigma_s^2=0$:
    $ N_q=rho^2/(2(1-rho)), quad T=(2-rho)/(2 mu(1-rho)). $
  ]),
  (id: "F10", title: "Tự lập phương trình sinh–tử", body: [
    Trạng thái $n$ là số yêu cầu trong hệ; sinh $lambda_n$, tử $mu_n$.
    Cân bằng giữa hai trạng thái kề:
    $ lambda_n p_n=mu_(n+1) p_(n+1). $
    $ p_n=p_0 product_(j=0)^(n-1) lambda_j/mu_(j+1), quad sum_n p_n=1. $
    Với M/M/c/k:
    $ lambda_n=cases(lambda & n<k, 0 & n=k), quad mu_n=min(n,c)mu quad (n>=1). $
    Trình tự: vẽ đồ hình → viết cân bằng từng trạng thái → chuẩn hoá → tính $N$, $lambda_a$, $T$.
  ]),
  (id: "F11", title: "Kỳ vọng và phương sai theo phân bố", body: [
    #table(columns: (1.35fr, 1fr, 1fr), inset: (x: 5pt, y: 7pt),
      [*Phân bố*], [*$E[X]$*], [*$"Var"(X)$*],
      [Poisson($m$)], [$m$], [$m$],
      [Mũ (tốc độ $r$)], [$1/r$], [$1/r^2$],
      [Nhị thức($n,p$)], [$n p$], [$n p(1-p)$],
      [Đều trên $[a,b]$], [$(a+b)/2$], [$(b-a)^2/12$],
    )
  ]),
)

#let network-formulas = (
  (id: "N1", title: "Lập phương trình lưu lượng và kiểm tra ổn định", body: [
    $ lambda_i=gamma_i+sum_j r_(j i)lambda_j, quad gamma=sum_i gamma_i. $
    $r_(j i)$ là xác suất rời nút $j$ sang nút $i$; nhánh không ghi tỉ lệ là phần còn lại.
    Giải hệ rồi kiểm tra tổng lưu lượng ra ngoài bằng $gamma$.

    Điều kiện ổn định tại từng nút:
    $ lambda_i<mu_i quad ("M/M/1"), $
    $ lambda_i<c_i mu_i quad ("M/M/" c_i). $
    Nếu có tham số, giải từng bất đẳng thức và lấy giao.
  ]),
  (id: "N2", title: "Jackson mở với các nút M/M/1 — số yêu cầu, trễ, xác suất", body: [
    Từng nút có $rho_i=lambda_i/mu_i<1$:
    $ N_i=rho_i/(1-rho_i), quad T_i=1/(mu_i-lambda_i). $
    $ N_"mạng"=sum_i N_i, quad T_"mạng"=N_"mạng"/gamma. $
    $ P(n_1,dots,n_k)=product_(i=1)^k (1-rho_i)rho_i^(n_i). $
    Mạng rỗng và mạng có đúng một yêu cầu:
    $ P_0=product_i (1-rho_i), quad P_1=P_0 sum_i rho_i. $
    Không chia $N_"mạng"$ cho $sum_i lambda_i$.
    Với nút nhiều server, dùng phân bố M/M/c tương ứng.
  ]),
  (id: "N3", title: "Trễ theo đường và xấp xỉ KIA", body: [
    Trễ đường $p$ là $D_p=sum_(i in p) T_i$; xác suất đường là tích xác suất rẽ nhánh.
    Với lưu lượng $f_p$ theo đường $p$:
    $ T_(S->D)=(sum_p f_p D_p)/(sum_p f_p). $
    Có vòng lặp thì cộng theo số lần đi qua nút.

    KIA: $lambda_(i j)$ là tổng luồng qua liên kết $(i,j)$:
    $ mu_(i j)=C_(i j)/L, quad T_(i j)=1/(mu_(i j)-lambda_(i j)). $
    Khi có trễ lan truyền $d_(i j)$:
    $ T_"mạng"=(sum_(i j) lambda_(i j)(T_(i j)+d_(i j)))/gamma. $
  ]),
  (id: "N4", title: "Store-and-forward và ARQ đầu cuối", body: [
    $ d_"e2e"=sum_i (L/C_i+t_(p i)+t_(q i)). $
    Mỗi chặng nhận hết gói rồi mới gửi tiếp; $L$ tính bằng bit.
    Nếu lỗi xác suất $p_e$ mỗi lần truyền và phải gửi lại toàn tuyến:
    $ E["số lần truyền"]=1/(1-p_e). $
    Tính lại lưu lượng qua từng nút trước khi tính $T_i$:
    $ T_"hoàn tất"=(sum_i T_i)/(1-p_e). $
    Công thức trên bỏ qua trễ ACK/time-out và giả thiết các lần truyền có cùng trễ trung bình.
  ]),
)
