#import "print/print-style.typ": print-style, topic-map
#import "content/gk-print-topics.typ": topic-one, topic-two, topic-three, topic-four, topic-five, topic-six, topic-seven
#show: print-style.with(title:"CSTSL — Ôn giữa kỳ A4 đen trắng")

#align(center, text(16pt, weight:"bold")[MỤC LỤC NỘI DUNG ÔN THI])
#v(14pt)
#topic-map((
  (title:[1. Mô hình hoá và đánh giá hiệu năng], items:(
    (title:[Khái niệm, phương pháp, chỉ tiêu], kind:"question", ids:("A1","A2","A3","A4")),
    (title:[Bài mẫu chọn mô hình], kind:"example", ids:("X1",)),
  )),
  (title:[2. Xác suất và các phân bố ngẫu nhiên], items:(
    (title:[Biến ngẫu nhiên; bảy phân bố], kind:"formula", ids:("P0","P1","P2")),
    (title:[Tích chập, tổng các biến mũ, Gamma], kind:"example", ids:("X2",)),
  )),
  (title:[3. Tiến trình ngẫu nhiên và Poisson], items:(
    (title:[Khái niệm; đếm và thời gian chờ], kind:"question", ids:("A7","A8","A9","A10","A11")),
    (title:[Bài đếm, xe buýt, ghép/tách luồng], kind:"example", ids:("VD 1","VD 2","VD 3","VD 4")),
  )),
  (title:[4. Nền tảng hệ thống phục vụ và hàng đợi], items:(
    (title:[Kendall, tải, Little, ổn định], kind:"question", ids:("B1","B2","B3","B4","B5","B6","C1","C2","C3")),
    (title:[Sinh–tử và bài cân bằng trạng thái], kind:"span", ids:("B7","VD 7")),
  )),
  (title:[5. Các mô hình hàng đợi đơn], items:(
    (title:[Một server và dung lượng hữu hạn], kind:"span", ids:("F3","BT 3.2")),
    (title:[Nhiều server; Erlang B, Erlang C], kind:"span", ids:("B10","VD 12")),
    (title:[M/M/∞, M/G/1, M/D/1], kind:"span", ids:("F8","X3")),
  )),
  (title:[6. Mạng hàng đợi], items:(
    (title:[Nối tiếp, Burke, Jackson mở], kind:"span", ids:("B13","VD 13")),
    (title:[Jackson đóng và bài hai khách], kind:"span", ids:("N5","X4")),
    (title:[Trễ theo tuyến và KIA], kind:"span", ids:("B15","N3")),
  )),
  (title:[7. Ứng dụng trong chuyển mạch gói], items:(
    (title:[Trễ, store-and-forward, chia gói], kind:"span", ids:("B16","X5")),
    (title:[Đường tích luỹ; LAN và gửi lại ARQ], kind:"span", ids:("N7","BT 3.3")),
  )),
))
#pagebreak()
#topic-one()
#pagebreak()
#topic-two()
#pagebreak()
#topic-three()
#pagebreak()
#topic-four()
#pagebreak()
#topic-five()
#pagebreak()
#topic-six()
#pagebreak()
#topic-seven()
