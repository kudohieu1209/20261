// Nội dung dùng chung của GK0 và bản in A4. Chỉnh đề/lời giải tại đây.
#import "@preview/fletcher:0.5.8": diagram, node, edge

#let jackson-diagram(accent) = diagram(
  spacing: (2.5cm, 1.7cm), node-stroke: 0.8pt + accent, node-fill: white,
  edge-stroke: 0.85pt + accent, mark-scale: 85%,
  node((-2, 0), [Vào], stroke: none),
  node((-1, 0), [Nút 4], inset: 7pt),
  node((0, 0), [Nút 1], inset: 7pt),
  node((1, -1), [Nút 2], inset: 7pt),
  node((1, 1), [Nút 3], inset: 7pt),
  node((2, 1), [Ra], stroke: none),
  edge((-2, 0), (-1, 0), "-|>", $gamma_4=4$),
  edge((-1, 0), (0, 0), "-|>", $r_41=1$),
  edge((0, 0), (1, -1), "-|>", $"0,5"$, bend: 22deg),
  edge((1, -1), (0, 0), "-|>", $1$, bend: 22deg),
  edge((0, 0), (1, 1), "-|>", $"0,5"$, bend: 22deg),
  edge((1, 1), (0, 0), "-|>", $"0,6"$, bend: 22deg),
  edge((1, 1), (2, 1), "-|>", $"0,4"$),
)

#let exam-examples(accent: black) = (
  (id: "VD 1", title: "Tổng đài 1080", short: "Tổng đài 1080 (Poisson)", network: false,
    prompt: [Trung bình 10 cuộc/phút, Poisson. Xác suất có 15 cuộc trong 2 phút?],
    answer: [
      Số cuộc gọi trong khoảng $t$ có phân bố Poisson tham số $m=lambda t$:
      $ m=10 times 2=20. $
      $ P(N=15)=(20^15 e^(-20))/(15!) approx 0","0516. $
      Kết quả: *0,0516*.
    ]),
  (id: "VD 2", title: "Xe buýt", short: "Xe buýt (phân bố mũ)", network: false,
    prompt: [Tần suất 5 phút/chuyến, Poisson. Vừa lỡ một chuyến. Xác suất đợi chuyến sau ít hơn 3 phút?],
    answer: [
      Trung bình 5 phút/chuyến nên $lambda=1/5$ chuyến/phút.
      Thời gian giữa hai lần đến có phân bố mũ:
      $ P(T<3)=1-e^(-lambda times 3)=1-e^(-3/5) approx 0","451. $
      Kết quả: *45,1%*.
    ]),
  (id: "VD 3", title: "Ghép luồng", short: "Ghép luồng Poisson", network: false,
    prompt: [Ô tô 6 xe/phút, xe máy 9 xe/phút, hai luồng Poisson độc lập.],
    answer: [
      Ghép hai luồng Poisson độc lập:
      $ lambda=6+9=15. $
      Luồng phương tiện qua nút là Poisson, *15 phương tiện/phút*.
    ]),
  (id: "VD 4", title: "Tách luồng", short: "Tách luồng Poisson", network: false,
    prompt: [12 bé/tuần theo Poisson; 55% trai, 45% gái.],
    answer: [
      Tách theo xác suất của từng nhóm:
      $ lambda_"trai"=12 times 0","55=6","6, $
      $ lambda_"gái"=12 times 0","45=5","4. $
      Hai luồng là Poisson; kết quả lần lượt *6,6 bé/tuần* và *5,4 bé/tuần*.
    ]),
  (id: "VD 5", title: "ATM, M/M/1/1", short: "ATM, M/M/1/1", network: false,
    prompt: [Một máy ATM; 10 người/giờ (Poisson); mỗi người cần trung bình 3 phút. Xác suất một người đến nhưng không được phục vụ khi không có chỗ chờ?],
    answer: [
      Một server, không có chỗ chờ: M/M/1/1.
      $ lambda=10, quad mu=60/3=20 quad ("người/giờ"). $
      $ P_B=lambda/(lambda+mu)=10/(10+20)=1/3 approx 0","333. $
      Xác suất bị từ chối: *33,3%*. Ngoài ra, $N=1/3$ và $T=1/mu=$ #box[3 phút].
    ]),
  (id: "VD 6", title: "Quầy tính tiền siêu thị, M/M/1/∞", short: "Siêu thị, M/M/1/∞", network: false,
    prompt: [40 khách/giờ (Poisson); phục vụ mũ, trung bình 1 phút; một quầy, đủ chỗ xếp hàng. Tìm thời gian chờ trung bình và xác suất thời gian từ lúc xếp hàng đến lúc trả tiền xong không quá 1,5 phút.],
    answer: [
      Mô hình M/M/1/∞. Đổi về khách/phút:
      $ lambda=40/60=2/3, quad mu=1, quad rho=2/3<1. $
      Thời gian chờ trung bình:
      $ T_q=rho/(mu-lambda)=(2/3)/(1-2/3)=2 " phút". $
      Xác suất thời gian trong hệ không quá 1,5 phút:
      $ P(T<=1","5)=1-e^(-(mu-lambda) times 1","5) $
      $ =1-e^(-0","5) approx 0","393. $
      Kết quả: *2 phút* và *39,3%*. Kiểm tra thêm:
      $ T=3 " phút", quad N=2, quad N_q=4/3. $
    ]),
  (id: "VD 7", title: "M/M/1/3, tự lập phương trình", short: "M/M/1/3 tự lập phương trình", network: false,
    prompt: [Tới 2 cuộc/phút, tốc độ phục vụ 4 cuộc/phút; hệ chứa tối đa 3 cuộc. Vẽ sinh–tử, tự lập phương trình cân bằng và tính xác suất trạng thái, số cuộc trung bình, thời gian trung bình trong hệ.],
    answer: [
      Trạng thái 0, 1, 2, 3 là số cuộc gọi trong hệ.
      #align(center, block(above: 5pt, below: 8pt, diagram(
        spacing: (22mm, 10mm), node-stroke: 1pt + accent, node-fill: white,
        edge-stroke: 0.9pt, mark-scale: 90%,
        node((0,0), $0$, shape: circle, inset: 7pt),
        node((1,0), $1$, shape: circle, inset: 7pt),
        node((2,0), $2$, shape: circle, inset: 7pt),
        node((3,0), $3$, shape: circle, inset: 7pt),
        ..range(3).map(i => (
          edge((i,0),(i+1,0),"-|>",$lambda=2$,bend:35deg,label-side:left),
          edge((i+1,0),(i,0),"-|>",$mu=4$,bend:35deg,label-side:left),
        )).flatten(),
      )))
      Cân bằng tốc độ ra và vào tại mỗi trạng thái:
      $ 2p_0=4p_1, quad 6p_1=2p_0+4p_2, $
      $ 6p_2=2p_1+4p_3, quad 4p_3=2p_2. $
      Suy ra $p_1=p_0/2$, $p_2=p_0/4$, $p_3=p_0/8$.
      Chuẩn hoá:
      $ p_0(1+1/2+1/4+1/8)=1. $
      $ (p_0,p_1,p_2,p_3)=(8/15,4/15,2/15,1/15). $
      Số cuộc trung bình và tốc độ được nhận:
      $ N=(1 times 4+2 times 2+3 times 1)/15=11/15, $
      $ P_B=1/15, quad lambda_a=2(1-1/15)=28/15. $
      Theo Little:
      $ T=N/lambda_a=(11/15)/(28/15)=11/28 " phút". $
      Kết quả: *N ≈ 0,733 cuộc; T ≈ 0,393 phút ≈ 23,6 giây*.
    ]),
  (id: "VD 8", title: "Bãi gửi xe máy, M/M/1/k", short: "Bãi gửi xe, M/M/1/k", network: false,
    prompt: [Một nhân viên; chỗ cho 10 khách đợi; tới 3 khách/phút (Poisson); xử lý mũ, trung bình 15 giây/xe. Tìm xác suất được phục vụ ngay, thời gian chờ trung bình và xác suất bị từ chối do đầy.],
    answer: [
      Có $Q=10$ chỗ chờ và một server, nên $k=11$: M/M/1/11.
      $ lambda=3, quad mu=60/15=4, quad rho=0","75. $
      Xác suất rỗng, cũng là xác suất được phục vụ ngay:
      $ p_0=(1-rho)/(1-rho^12)=(0","25)/(1-0","75^12) approx 0","258. $
      Xác suất bị từ chối:
      $ P_B=p_11=rho^11 p_0 approx 0","0109. $
      Số khách trung bình:
      $ N=rho/(1-rho)-(12rho^12)/(1-rho^12) approx 2","607, $
      $ N_q=N-(1-p_0) approx 1","866. $
      Thời gian chờ tính trên khách được nhận:
      $ T_q=N_q/(lambda(1-P_B)) approx (1","866)/(3 times 0","9891) $
      $ approx 0","629 " phút" approx 37","7 " giây". $
      Kết quả: *phục vụ ngay 25,8%; bị từ chối 1,09%; chờ trung bình 37,7 giây*.
    ]),
  (id: "VD 9", title: "Call center, M/M/c/∞ (Erlang C)", short: "Call center, Erlang C", network: false,
    prompt: [Ba điện thoại viên; trung bình 3 cuộc/10 phút (Poisson); mỗi cuộc kéo dài trung bình 3 phút (mũ); bận thì khách nghe nhạc chờ. Tính xác suất phục vụ ngay và kiểm tra yêu cầu không quá 10% khách phải đợi.],
    answer: [
      Mô hình M/M/3/∞:
      $ lambda=0","3, quad mu=1/3 quad ("cuộc/phút"), $
      $ a=lambda/mu=0","9, quad rho=a/3=0","3<1. $
      Chuẩn hoá:
      $ p_0=(1+0","9+0","405+(0","729)/(6 times 0","7))^(-1) $
      $ approx 0","4035. $
      Erlang C:
      $ C(3,a)=(a^3)/(3!(1-rho))p_0 $
      $ approx 0","1736 times 0","4035 approx 0","070. $
      Phục vụ ngay: $1-C approx 0","930$.
      *Chỉ 7% phải đợi, đạt ngưỡng 10%; không cần tăng số bàn.*
      Nếu chưa đạt thì thử $c=4,5,dots$; với $c=4$ được $C approx 0","014$.
    ]),
  (id: "VD 10", title: "Đơn vị Erlang", short: "Đơn vị Erlang", network: false,
    prompt: [Tổng đài một giờ có 60 cuộc, mỗi cuộc trung bình 5 phút.],
    answer: [
      Đổi thời gian mỗi cuộc sang giờ:
      $ a=60 times 5/60=5 " Erlang". $
    ]),
  (id: "VD 11", title: "Tổng đài cơ quan, M/M/c/c (Erlang B)", short: "Tổng đài cơ quan, Erlang B", network: false,
    prompt: [Ba đường trung kế; gọi ra 6 cuộc/giờ, gọi vào 9 cuộc/giờ (Poisson độc lập); chiếm kênh mũ, trung bình 3 phút. Tính tải và xác suất bị từ chối do nghẽn mạch.],
    answer: [
      Mô hình M/M/3/3, không có chỗ chờ.
      $ lambda=6+9=15, quad mu=60/3=20 quad ("cuộc/giờ"). $
      Tải:
      $ a=lambda/mu=15/20=0","75 " Erlang". $
      Erlang B:
      $ B(3,a)=(0","75^3/6)/(1+0","75+0","28125+0","07031) $
      $ approx 0","0335. $
      Kết quả: *0,75 Erlang; xác suất bị từ chối 3,35%*.
    ]),
  (id: "VD 12", title: "CPU 4 nhân, M/M/c và M/M/c/k", short: "CPU 4 nhân, M/M/4 và M/M/4/14", network: false,
    prompt: [
      Tới 20 task/µs (Poisson); phục vụ mũ, trung bình 0,08 µs/task.
      TH1: bộ nhớ đệm đủ lớn, tính thời gian trong hệ và số tác vụ trung bình.
      TH2: chỉ có 10 chỗ chờ, tính xác suất từ chối và xác suất phải đợi.
    ],
    answer: [
      #block(breakable:false, above:5pt, below:12pt)[
        *TH1. Bộ nhớ đệm đủ lớn — M/M/4/∞.*
        $ mu=1/(0","08)=12","5 " task/µs", $
        $ a=20/(12","5)=1","6, quad rho=a/4=0","4. $
        $ p_0=(1+1","6+1","28+0","6827+(1","6^4)/(4! times 0","6))^(-1) $
        $ approx 0","1993. $
        $ C=(1","6^4)/(4! times 0","6)p_0 approx 0","0907. $
        $ N_q=C rho/(1-rho) approx 0","0605, $
        $ T=1/mu+C/(4mu-lambda)=0","08+(0","0907)/30 $
        $ approx 0","083 " µs". $
        $ N=a+N_q approx 1","66 " tác vụ". $
        Kết quả: *T ≈ 0,083 µs; N ≈ 1,66 tác vụ*.
      ]
      #block(breakable:false, above:6pt)[
        *TH2. Mười chỗ chờ — M/M/4/14.*
        Dung lượng toàn hệ: $k=10+4=14$. Chuẩn hoá hữu hạn:
        $ p_0=(sum_(n=0)^3 a^n/n!+(a^4)/(4!)sum_(j=0)^10 rho^j)^(-1) $
        $ approx 0","1993. $
        $ P_B=p_14=(a^4)/(4!)rho^10 p_0 approx 5","71 times 10^(-6). $
        Xác suất được nhận và phải đợi:
        $ P_"đợi"=sum_(n=4)^13 p_n=1-sum_(n=0)^3 p_n-p_14 $
        $ approx 0","0907. $
        Nếu chỉ xét các yêu cầu đã được nhận:
        $ P("đợi" | "nhận")=P_"đợi"/(1-P_B). $
        Kết quả: *$P_B approx 5","71 times 10^(-6)$; $P_"đợi" approx 9","07%$*.
      ]
    ]),
  (id: "BT 3.1", title: "M/M/∞", short: "M/M/∞", network: false,
    prompt: [Mọi yêu cầu được phục vụ ngay. Tìm phân bố trạng thái và các đại lượng hiệu năng.],
    answer: [
      Ở trạng thái $n$: sinh $lambda$, tử $n mu$. Với $a=lambda/mu$:
      $ p_n=(a^n)/(n!)p_0, quad sum_(n=0)^infinity p_n=1. $
      Suy ra:
      $ p_0=e^(-a), quad p_n=(a^n e^(-a))/(n!). $
      Số yêu cầu trong hệ có phân bố Poisson tham số $a$.
      $ N=a, quad T=1/mu, quad N_q=T_q=P_B=0. $
      Hệ có trạng thái dừng với tốc độ tới hữu hạn và $mu>0$.
    ]),
  (id: "BT 3.2", title: "Chọn công ty sửa máy", short: "Chọn công ty sửa máy", network: false,
    prompt: [Trung bình 3 máy hỏng/ngày làm việc 8 giờ (Poisson); thiệt hại 500.000đ cho mỗi máy nằm hỏng trong ngày; sửa lần lượt, thời gian mũ. Công ty 1: 2 giờ/máy, phí 600.000đ/ngày. Công ty 2: 80 phút/máy, phí 800.000đ/ngày.],
    answer: [
      Mỗi phương án là M/M/1, với $lambda=3/8=0","375$ máy/giờ.

      Công ty 1: $mu_1=0","5$ máy/giờ, $rho_1=0","75$:
      $ N_1=rho_1/(1-rho_1)=3. $
      Chi phí: #box[*600.000 + 3 × 500.000 = 2.100.000đ/ngày*].

      Công ty 2: $mu_2=0","75$ máy/giờ, $rho_2=0","5$:
      $ N_2=rho_2/(1-rho_2)=1. $
      Chi phí: #box[*800.000 + 1 × 500.000 = 1.300.000đ/ngày*].

      *Chọn công ty 2.* Phí dịch vụ cao hơn nhưng số máy nằm hỏng trung bình ít hơn.
    ]),
  (id: "VD 13", title: "Mạng mở 4 nút", short: "Mạng mở 4 nút (Jackson)", network: true,
    prompt: [
      $gamma_4=4$ yêu cầu/s vào nút 4.
      Thời gian phục vụ trung bình tại các nút 1–4 lần lượt là 0,03; 0,04; 0,05; 0,06 s.
      $r_41=1$, $r_12=r_13=0","5$, $r_21=1$, $r_31=0","6$, $r_30=0","4$.
      #align(center, block(above:7pt, below:7pt,jackson-diagram(accent)))
    ],
    answer: [
      Phương trình lưu lượng:
      $ lambda_4=4, quad lambda_1=lambda_4+lambda_2+0","6lambda_3, $
      $ lambda_2=lambda_3=0","5lambda_1. $
      Suy ra $0","2lambda_1=4$. Kết quả từng nút:
      #table(columns:(auto,1fr,1fr,1fr), inset:(x:6pt,y:5pt),
        [*Nút*],[*$lambda_i$ (yêu cầu/s)*],[*$rho_i$*],[*$N_i$*],
        [1],[20],[0,6],[1,5],
        [2],[10],[0,4],[0,667],
        [3],[10],[0,5],[1],
        [4],[4],[0,24],[0,316],
      )
      Mọi $rho_i<1$, hệ ổn định. Xác suất mạng rỗng và đúng một yêu cầu:
      $ P_0=0","4 times 0","6 times 0","5 times 0","76=0","0912, $
      $ P_1=P_0(0","6+0","4+0","5+0","24) approx 0","159. $
      Hiệu năng toàn mạng:
      $ N=sum_i N_i approx 3","48, quad T=N/gamma_4 approx 0","871 " s". $
      Giữ $r_30,r_31$ và $r_12+r_13=1$; điều kiện ổn định:
      $ lambda_1=10/r_13, quad lambda_2=(10(1-r_13))/r_13, $
      $ rho_1=(0","3)/r_13<1 quad => quad r_13>0","3, $
      $ rho_2=(0","4(1-r_13))/r_13<1 quad => quad r_13>2/7. $
      Kết luận: *0,3 < r#sub[13] ≤ 1; 0 ≤ r#sub[12] < 0,7*.
    ]),
  (id: "BT 3.3", title: "Mạng LAN có ARQ", short: "Mạng LAN có ARQ", network: true,
    prompt: [
      S1 → R1 → R2 → D; S2 → R2. Hai nguồn tới lần lượt 240 và 120 gói/phút;
      thời gian phục vụ trung bình tại R1, R2 là 0,2 và 0,1 s.
      R2 → D có lỗi $p_e=10%$; ARQ đầu cuối gửi lại từ nguồn.
    ],
    answer: [
      Đổi tốc độ nguồn: 4 và 2 gói/s. Gửi lại làm lưu lượng tăng $1/(1-p_e)$ lần:
      $ lambda_("R1")=4/(0","9) approx 4","444 " gói/s", $
      $ lambda_("R2")=6/(0","9) approx 6","667 " gói/s". $
      Với $mu_1=5$, $mu_2=10$ gói/s:
      $ rho_1 approx 0","889, quad rho_2 approx 0","667, $
      $ N_1=8, quad N_2=2 quad ("tổng 10 gói"). $
      Trễ cho mỗi lần đi qua nút:
      $ T_1=1/(5-4","444) approx 1","8 " s", $
      $ T_2=1/(10-6","667) approx 0","3 " s". $
      Trễ hoàn tất, kể cả các lần gửi lại:
      $ T_("S1"->D)=(T_1+T_2)/(1-p_e)=(2","1)/(0","9) approx 2","33 " s", $
      $ T_("S2"->D)=T_2/(1-p_e)=(0","3)/(0","9) approx 0","33 " s". $
      Kết quả: *S1 → D: 2,33 s; S2 → D: 0,33 s*.
    ]),
)
