// Bố cục theo chủ đề cho giấy A4; giữ nguyên bộ bài học trên tablet.
#import "../print/print-style.typ": note, example, question, formula
#import "gk-exam-examples.typ": exam-examples
#import "gk-exam-formulas.typ": core-formulas, network-formulas
#import "gk-exam-theory.typ": exam-questions, print-answers
#let examples = exam-examples()
#let ex(id) = example(examples.find(x => x.id == id))
#let f(id) = formula((core-formulas + network-formulas).find(x => x.id == id))
#let short-titles = (
  B4: [Những mô hình nào bảo toàn yêu cầu?],
  B5: [Định lý Little và điều kiện áp dụng?],
  B11: [Khi nào M/D/1 cho hiệu năng tốt hơn M/M/1?],
)
#let qa(id) = question(exam-questions.find(x => x.id == id),
  answer: print-answers.at(id), title: short-titles.at(id, default: none))
#let mark(id) = [#metadata((kind:"topic", id:id)) <print-index>]
#let worked(id, title, body) = [
  #metadata((kind:"example", id:id, title:title)) <print-index>
  #note([Bài mẫu. #title], body)
  #metadata((kind:"example-end", id:id)) <print-index>
]

#let topic-one() = [
  = 1. Mô hình hoá và đánh giá hiệu năng
  #mark("1")
  == Khái niệm, phương pháp và chỉ tiêu
  #for id in ("A1", "A2", "A3", "A4") { qa(id) }
  #note("Cách lập một mô hình")[
    Xác định câu hỏi cần trả lời → chọn ranh giới hệ thống → đặt giả thiết → xác định đầu vào,
    tham số và chỉ tiêu đầu ra → phân tích hoặc mô phỏng → đối chiếu dữ liệu, hiệu chỉnh.
    Mô hình càng chi tiết thường càng phức tạp; chọn mức chi tiết đủ cho mục tiêu đánh giá.
  ]
  #worked("X1", [Chọn mô hình cho quầy giao dịch])[
    *Đề.* Một quầy có khách tới ngẫu nhiên, một nhân viên, đủ chỗ đợi. Cần ước lượng thời gian khách ở quầy.

    _Giải._ Đầu vào là tốc độ tới $lambda$ và phân bố thời gian phục vụ $S$;
    đầu ra là $T$ hoặc $T_q$. Nếu tới Poisson, $S$ có phân bố mũ và phục vụ FIFO,
    chọn M/M/1/∞. Đo số khách và thời gian phục vụ để ước lượng $lambda$, $mu=1/E[S]$;
    kiểm tra $lambda<mu$, tính $T=1/(mu-lambda)$ rồi so sánh thời gian đo được.
    Nếu giả thiết mũ không phù hợp, cân nhắc M/G/1 hoặc mô phỏng.
  ]
]

#let topic-two() = [
  = 2. Xác suất và các phân bố ngẫu nhiên
  #mark("2")
  == Biến ngẫu nhiên và các đặc trưng
  #qa("A5")
  #qa("A6")
  #formula((id:"P0", title:[Hàm phân bố, kỳ vọng và phương sai], body:[
    Rời rạc: $p_X(x)=P(X=x)$, $sum_x p_X(x)=1$.
    Liên tục: $f_X(x)>=0$, $integral_(-infinity)^infinity f_X(x) dif x=1$;
    mật độ $f_X(x)$ không phải xác suất tại một điểm.
    $ F_X(x)=P(X<=x), quad P(a<X<=b)=F_X(b)-F_X(a). $
    $ E[X]=sum_x x p_X(x) quad "hoặc" quad integral_(-infinity)^infinity x f_X(x) dif x. $
    $ "Var"(X)=E[X^2]-E[X]^2, quad sigma_X=sqrt("Var"(X)). $
    $ E[a X+b]=a E[X]+b, quad "Var"(a X+b)=a^2 "Var"(X). $
    Kỳ vọng của tổng luôn cộng được; nếu độc lập thì phương sai cũng cộng được:
    $ E[X+Y]=E[X]+E[Y], quad "Var"(X+Y)="Var"(X)+"Var"(Y). $
  ]))
  #formula((id:"P1", title:[Các phân bố rời rạc], body:[
    #table(columns:(1.1fr,2.3fr,1fr,1.1fr), inset:(x:4pt,y:7pt),
      [*Phân bố*], [*Xác suất*], [*$E[X]$*], [*$"Var"(X)$*],
      [Bernoulli($p$)], [$P(X=1)=p$; $P(X=0)=1-p$], [$p$], [$p(1-p)$],
      [Nhị thức($n,p$)], [$P(X=k)=binom(n,k)p^k(1-p)^(n-k)$], [$n p$], [$n p(1-p)$],
      [Poisson($m$)], [$P(X=k)=e^(-m)m^k/k!$], [$m$], [$m$],
    )
    Bernoulli: một phép thử thành công/thất bại; $0<=p<=1$.
    Nhị thức: số thành công trong $n$ phép thử Bernoulli độc lập cùng $p$, $0<=k<=n$.
    Poisson: $m>0$, $k=0,1,dots$; với tiến trình tốc độ $lambda$ trong khoảng $t$, $m=lambda t$.
  ]))
  #formula((id:"P2", title:[Các phân bố liên tục], body:[
    *Đều trên $[a,b]$, $a<b$*: $f(x)=1/(b-a)$ trong đoạn, bằng 0 ngoài đoạn.
    $ E[X]=(a+b)/2, quad "Var"(X)=(b-a)^2/12. $
    *Chuẩn $cal(N)(m,sigma^2)$*, $sigma>0$:
    $ f(x)=1/(sigma sqrt(2 pi)) exp(-(x-m)^2/(2 sigma^2)), quad x in RR. $
    $ E[X]=m, quad "Var"(X)=sigma^2, quad Z=(X-m)/sigma ~ cal(N)(0,1). $
    Với $Phi$ là hàm phân bố chuẩn tắc:
    $ P(a<X<=b)=Phi((b-m)/sigma)-Phi((a-m)/sigma). $
    *Mũ tốc độ $r>0$*: $f(x)=r e^(-r x)$ khi $x>=0$, bằng 0 khi $x<0$.
    $ E[X]=1/r, quad "Var"(X)=1/r^2. $
    *Gamma dạng nguyên (Erlang)*, $n=1,2,dots$, tốc độ $r>0$:
    $ f(x)=(r^n x^(n-1)e^(-r x))/(n-1)! quad (x>=0). $
    $ E[X]=n/r, quad "Var"(X)=n/r^2. $
    Mật độ bằng 0 khi $x<0$; $n=1$ chính là phân bố mũ.
  ]))
  #note("Tổng các biến mũ và tích chập")[
    Nếu $X_1,dots,X_n$ độc lập, cùng phân bố mũ tốc độ $r$, thì
    $S_n=sum_(i=1)^n X_i$ có phân bố Gamma dạng nguyên $(n,r)$.
    Với $X,Y$ độc lập liên tục:
    $ f_(X+Y)(z)=integral_(-infinity)^infinity f_X(u)f_Y(z-u) dif u. $
    Chứng minh quy nạp: giả sử $S_n$ có mật độ Gamma, thì với $x>=0$:
    $ f_(S_(n+1))(x)=integral_0^x (r^n u^(n-1)e^(-r u))/(n-1)! r e^(-r(x-u)) dif u $
    $ = (r^(n+1)e^(-r x))/(n-1)! integral_0^x u^(n-1) dif u
      = (r^(n+1)x^n e^(-r x))/n!. $
  ]
  #worked("X2", [Nhận diện phân bố và tính thời gian qua ba công đoạn])[
    *Đề.* Ba công đoạn độc lập, mỗi công đoạn có thời gian mũ trung bình 2 phút. Tính trung bình,
    phương sai tổng thời gian $S$ và $P(S<=6)$.

    _Giải._ $r=1/2$ mỗi phút, $S$ có Gamma $(3,1/2)$.
    $ E[S]=3/r=6 " phút", quad "Var"(S)=3/r^2=12 " phút"^2. $
    Hàm phân bố Gamma dạng nguyên:
    $ P(S<=t)=1-e^(-r t)sum_(j=0)^(n-1)(r t)^j/j! quad (t>=0). $
    $ P(S<=6)=1-e^(-3)(1+3+9/2) approx 0","5768. $
  ]
]

#let topic-three() = [
  = 3. Tiến trình ngẫu nhiên và Poisson
  #mark("3")
  == Khái niệm và tính chất
  #for id in ("A7", "A8", "A9", "A10", "A11") { qa(id) }
  == Công thức đếm và thời gian chờ
  #f("F1")
  #f("F2")
  == Bài mẫu Poisson, mũ, ghép và tách luồng
  #for id in ("VD 1", "VD 2", "VD 3", "VD 4") { ex(id) }
]

#let topic-four() = [
  = 4. Nền tảng hệ thống phục vụ và hàng đợi
  #mark("4")
  == Thành phần hệ thống và ký hiệu Kendall
  #for id in ("B1", "B2", "B3", "B4") { qa(id) }
  #note("Ký hiệu, tải và đổi đơn vị")[
    $lambda$: tốc độ tới; $mu$: tốc độ phục vụ *mỗi server*; $c$: số server;
    $Q$: số chỗ chờ; $k=Q+c$: dung lượng toàn hệ.
    $a=lambda/mu$: tải toàn hệ (Erlang); $rho=lambda/(c mu)$: tải mỗi server.

    $N,T$ tính trong hệ; $N_q,T_q$ chỉ tính phần chờ. Với các yêu cầu được nhận:
    $ T=T_q+1/mu, quad N=N_q+lambda_a/mu. $
    $ mu=1/E[S], quad mu=C/L quad ("liên kết truyền gói"). $
    #box[1 byte = 8 bit;] #box[1 phút = 60 s;] #box[1 ms = $10^(-3)$ s;] #box[1 µs = $10^(-6)$ s].
    $C$ và $L$ phải cùng đơn vị bit; $lambda$ và $mu$ phải cùng đơn vị thời gian.
  ]
  == Little và điều kiện trạng thái dừng
  #question(exam-questions.find(x => x.id == "B5"), title:[Little và dòng tới được nhận], answer:[
    Các trung bình phải tồn tại ở trạng thái ổn định và xét cùng dòng yêu cầu.
    Little không đòi hỏi tới Poisson hay phục vụ mũ; cần thêm mô hình để tính đủ $N,T$.
    Khi có từ chối, dùng $lambda_a=lambda(1-P_B)$:
    $ N=lambda_a T, quad N_q=lambda_a T_q. $
    Phục vụ ngay + được nhận và phải đợi + bị từ chối = 1.
    $T,T_q$ là thời gian trung bình của yêu cầu được nhận.
  ])
  #qa("B6")
  #for id in ("C1", "C2", "C3") { qa(id) }
  == Sinh–tử: tự thiết lập thay vì học thuộc
  #qa("B7")
  #qa("B8")
  #f("F10")
  #ex("VD 7")
]

#let topic-five() = [
  = 5. Các mô hình hàng đợi đơn
  #mark("5")
  Mỗi mô hình đi cùng điều kiện áp dụng, công thức và bài mẫu. Dung lượng $k$ luôn gồm cả
  yêu cầu đang phục vụ; tốc độ $mu$ tính cho một server.

  == 5.1. Một server: M/M/1/1, M/M/1/∞, M/M/1/k
  #f("F3")
  #ex("VD 6")
  #f("F4")
  #ex("VD 5")
  #qa("B9")
  #ex("VD 8")
  #ex("BT 3.2")

  == 5.2. Nhiều server: Erlang C, Erlang B, dung lượng hữu hạn
  #qa("B10")
  #ex("VD 10")
  #f("F5")
  #ex("VD 9")
  #f("F6")
  #ex("VD 11")
  #f("F7")
  #ex("VD 12")
  #note("Kiểm tra bài nhiều server")[
    “10 chỗ chờ” nghĩa là $k=c+10$; “tối đa 10 yêu cầu trong hệ” nghĩa là $k=10$.
    M/M/c/k dùng chuẩn hoá hữu hạn; không thay bằng Erlang C vô hạn.
    “Được nhận và phải đợi” khác “phải đợi trong số đã được nhận” khi $P_B>0$.
  ]

  == 5.3. Vô hạn server: M/M/∞
  #f("F8")
  #ex("BT 3.1")
  == 5.4. Phục vụ tổng quát và tất định: M/G/1, M/D/1
  #f("F9")
  #qa("B11")
  #worked("X3", [So sánh M/M/1 và M/D/1])[
    *Đề.* Cùng tới Poisson $lambda=4$/phút, cùng thời gian phục vụ trung bình 10 s.
    So sánh thời gian chờ nếu phục vụ mũ và phục vụ cố định.

    _Giải._ $mu=6$/phút, $rho=2/3<1$.
    $ T_q^("M/M/1")=rho/(mu(1-rho))=1/3 " phút"=20 " s". $
    $ T_q^("M/D/1")=rho/(2 mu(1-rho))=1/6 " phút"=10 " s". $
    Tổng thời gian trong hệ lần lượt 30 s và 20 s. Cùng tải và cùng trung bình phục vụ,
    giảm biến động phục vụ giúp giảm thời gian chờ.
  ]
]

#let topic-six() = [
  = 6. Mạng hàng đợi
  #mark("6")
  == Mạng nối tiếp, Jackson mở và định lý Burke
  #for id in ("B13", "B12", "C4", "B14") { qa(id) }
  #f("N1")
  #f("N2")
  #note("Mạng nối tiếp")[
    Một nguồn Poisson tốc độ $gamma$ đi lần lượt qua các nút M/M/1, không chia nhánh hay phản hồi:
    $lambda_i=gamma$. Khi mọi nút ổn định, $T_"mạng"=sum_i 1/(mu_i-gamma)$.
    Burke giúp xác định dòng ra của nút trước; không suy ra thời gian chờ tại các nút độc lập.
  ]
  #ex("VD 13")

  == Jackson đóng: cố định tổng số khách
  #formula((id:"N5", title:[Phân bố tích với ràng buộc số khách], body:[
    Xét mạng đóng bất khả quy có $M$ khách, $k$ nút M/M/1, tốc độ $mu_i>0$.
    Không có nguồn vào/ra ngoài; giải tỉ lệ lượt thăm:
    $ v_i=sum_j v_j r_(j i). $
    Chọn một thang tuỳ ý cho $v_i>0$, đặt $w_i=v_i/mu_i$. Với $sum_i n_i=M$:
    $ P(n_1,dots,n_k)=1/G(M) product_(i=1)^k w_i^(n_i), $
    $ G(M)=sum_(n_1+ dots +n_k=M) product_(i=1)^k w_i^(n_i). $
    $ N_i=sum_(bold(n): sum_j n_j=M) n_i P(bold(n)). $
    Các trạng thái ngoài ràng buộc có xác suất 0. Khách giữa các nút không độc lập do tổng cố định.
    Không dùng $N_i=rho_i/(1-rho_i)$ của Jackson mở; không áp điều kiện $rho_i<1$ từ mạng mở.
  ]))
  #worked("X4", [Mạng đóng hai nút, hai khách])[
    *Đề.* Hai khách luân phiên qua hai nút M/M/1 theo tuyến $1 -> 2 -> 1$,
    $mu_1=2$/s, $mu_2=4$/s. Tìm phân bố số khách và thông lượng qua mỗi nút.

    _Giải._ Chọn $v_1=v_2=1$, nên $w_1=1/2$, $w_2=1/4$.
    Các trạng thái $(n_1,n_2)=(0,2),(1,1),(2,0)$ có trọng số lần lượt $1/16,1/8,1/4$;
    tổng $G(2)=7/16$. Suy ra xác suất tương ứng $1/7,2/7,4/7$.
    $ N_1=(0+2+8)/7=10/7, quad N_2=4/7, quad N_1+N_2=2. $
    $ X_1=mu_1 P(n_1>0)=2 times 6/7=12/7 " khách/s", $
    $ X_2=mu_2 P(n_2>0)=4 times 3/7=12/7 " khách/s". $
    Thông lượng chu trình $X=12/7$/s, thời gian một vòng $T=M/X=7/6$ s.
  ]

  == Trễ theo tuyến và xấp xỉ độc lập KIA
  #qa("B15")
  #f("N3")
  #note("Trình tự giải mạng mở")[
    Đọc hướng mũi tên → lập và giải hệ lưu lượng → kiểm tra ổn định từng nút → tính $N_i,T_i$
    và xác suất → cộng $N_i$ rồi chia tổng tốc độ tới *từ ngoài*.
    Nếu hỏi theo tuyến, cộng trễ mỗi lần đi qua nút và lấy trọng số đúng theo luồng.
  ]
]

#let topic-seven() = [
  = 7. Ứng dụng trong chuyển mạch gói
  #mark("7")
  == Các thành phần trễ và truyền gối đầu
  #qa("B16")
  #qa("B17")
  #formula((id:"N6", title:[Phát, lan truyền và truyền nhiều gói], body:[
    $ t_s=L/C, quad t_p=d/v. $
    $L$: độ dài gói (bit); $C$: dung lượng (bit/s); $d$: chiều dài kênh (m); $v$: vận tốc (m/s).
    Store-and-forward phải nhận hết gói trước khi gửi tiếp.
    Nếu $T_i$ đã là thời gian *trong nút* gồm chờ và phát, chỉ cộng thêm lan truyền,
    không cộng $L/C_i$ lần nữa.

    Với $m$ gói bằng nhau qua $h$ liên kết cùng dung lượng $C$, không có lưu lượng khác,
    bỏ qua xử lý và hàng đợi phát sinh ngoài luồng:
    $ t_"xong"=(h+m-1)L/C+sum_(i=1)^h t_(p i). $
    Một bản tin dài $M=m L$ gửi nguyên khối cần $h M/C+sum_i t_(p i)$.
    Nếu mỗi gói thêm tiêu đề $H$ bit, thay $L$ bằng $L+H$ trong thời gian phát.
  ]))
  #worked("X5", [Bản tin nguyên khối và chia gói])[
    *Đề.* Bản tin 12.000 bit đi qua 3 liên kết 1 Mbit/s. Bỏ qua lan truyền, tiêu đề và xử lý.
    So sánh gửi nguyên khối với chia thành 4 gói bằng nhau.

    _Giải._ Nguyên khối: $3 times 12000/10^6=36$ ms.
    Chia gói: $L=3000$ bit, mỗi chặng phát một gói mất 3 ms.
    $ t_"xong"=(3+4-1) times 3=18 " ms". $
    Gói sau được phát khi gói trước đang đi tiếp ở chặng kế tiếp, tạo truyền gối đầu.
  ]

  == Đọc hàng đợi từ các đường tích luỹ
  #formula((id:"N7", title:[Lượng tồn và trễ trên đồ thị A(t), D(t)], body:[
    Với hệ FIFO ban đầu rỗng, không mất dữ liệu, $A(t)$ và $D(t)$ là lượng tích luỹ đã vào và đã ra,
    cùng đo bằng gói hoặc bit. Hai hàm không giảm và $A(t)>=D(t)$.
    $ Q(t)=A(t)-D(t). $
    Khoảng cách đứng là lượng còn trong ranh giới hệ đang xét.
    Khoảng cách ngang tại cùng mức tích luỹ cho thời gian một phần tử lưu lại:
    $ d(t)=inf {tau>=0 : D(t+tau)>=A(t)}. $
    Nếu đầu ra được tính sau khi phát xong, lượng tồn gồm cả dữ liệu đang phục vụ;
    phân biệt với $N_q$ chỉ đếm phần chờ.
  ]))
  == Gửi lại đầu cuối và lưu lượng thực qua router
  #f("N4")
  #ex("BT 3.3")
]
