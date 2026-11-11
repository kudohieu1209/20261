# Tài liệu giữa kỳ và cách in A4

## Chỉ cần in tập chính

| File | Nội dung | Trang PDF | Tờ A4 in hai mặt |
|---|---|---:|---:|
| [Tập A4 đen trắng](./GK_InA4_DenTrang.pdf) | Đủ 7 chủ đề; mục lục sơ đồ; 21 bài mẫu/ví dụ; 32 câu lý thuyết và tính nhanh được đặt trong chủ đề liên quan | 22 | 11 |
| [Bản tách mạng hàng đợi và chuyển mạch gói](./GK_PhuLuc_Mang_InA4_DenTrang.pdf) | Trích nguyên chủ đề 6–7 của tập chính, đánh số P1–P6 | 6 | 3 |

**In tập chính là đủ cả bộ. Không in thêm bản tách mạng hay GK0 để tránh trùng nội dung.**
Bản tách mạng giữ lại để học riêng, thay cho vai trò phụ lục in thêm trước đây.

| Chủ đề | Trang |
|---|---:|
| 1. Mô hình hoá và đánh giá hiệu năng | 2 |
| 2. Xác suất, biến ngẫu nhiên và bảy phân bố | 3–4 |
| 3. Tiến trình ngẫu nhiên, Poisson và thời gian mũ | 5–6 |
| 4. Hệ thống phục vụ, Kendall, Little, ổn định và sinh–tử | 7–8 |
| 5. Hàng đợi đơn: M/M/1, hữu hạn, nhiều server, M/M/∞, M/G/1, M/D/1 | 9–16 |
| 6. Mạng nối tiếp, Burke, Jackson mở/đóng và KIA | 17–20 |
| 7. Trễ, chuyển mạch gói, đường tích luỹ và LAN có gửi lại | 21–22 |

Mỗi chủ đề đặt kiến thức ngắn, điều kiện và công thức cạnh bài mẫu tương ứng. Chủ đề lớn bắt đầu trang mới.
Mục lục sơ đồ ghi tên nội dung và số trang thật, tự cập nhật khi dựng PDF.
Các ví dụ gốc giữ số bài để đối chiếu với bộ học; không hiển thị mã công thức F1, F2… hay mã câu hỏi.

Bản mới giữ đủ 16 ví dụ/bài tập gốc, thêm 5 bài mẫu: chọn mô hình, Gamma, so sánh M/M/1 với M/D/1,
Jackson đóng hai khách và chia bản tin thành nhiều gói. Bảy phân bố gồm Bernoulli, nhị thức, đều,
chuẩn, mũ, Poisson và Gamma dạng nguyên.

Bộ in bao phủ các mảng nội dung trong hai chương Mô hình hoá – tiến trình ngẫu nhiên và Hàng đợi
của slide Dũng hiện có. Chương Hàng đợi có cả mạng hàng đợi và ứng dụng chuyển mạch gói.
Ghi chú “thi đến hết phần hàng đợi” chưa xác định riêng điểm dừng giữa hàng đợi đơn và toàn chương;
bộ in giữ cả hai phần cuối để không bỏ sót vì cách hiểu này.

## Cài đặt in

- Giấy **A4**, hướng dọc, **đen trắng**, **100% / Actual size**.
- **Một trang PDF trên một mặt giấy**; in hai mặt chọn **lật cạnh dài**.
- Không ghép hai trang PDF lên một mặt vì công thức và chỉ số sẽ bị nhỏ.
- Đóng tập ở mép trái, giữ trang mục lục ở đầu.

Chữ Palatino 11pt, toán hiển thị 11,5pt, lề 2,5 cm; nền trắng chữ đen, tiêu đề đậm,
không khung hộp, không header hoặc dòng nguồn. Số trang nằm giữa chân trang.
Giữ trọn từng bài hoặc từng trường hợp; bài CPU bốn nhân có thể tách giữa TH1 và TH2.

## Học và luyện trên tablet

Bộ học gốc ở [docs_claude](../docs_claude/README.md):
GK1–GK5 để học, xem giải thích và ghi chú; GK6 để luyện đề 60 phút; GK0 là bản gộp cũ;
CK1–CK5 dành cho cuối kỳ. Khi luyện đề, dùng tập in mới để quen tìm nội dung theo mục lục.

## Cập nhật và xuất PDF

- `content/gk-print-topics.typ`: thứ tự 7 chủ đề và nội dung bổ sung dành cho bản in.
- `content/gk-exam-examples.typ`, `gk-exam-formulas.typ`: dữ liệu dùng chung với GK0.
- `content/gk-exam-theory.typ`: câu hỏi, đáp án đầy đủ cho GK5 và đáp án ngắn cho giấy.
- `print/print-style.typ`: kiểu chữ, bố cục và mục lục tự tính số trang.
- Hai file `GK_*InA4_DenTrang.typ`: tập đầy đủ và bản tách chủ đề 6–7.

Không sửa trực tiếp PDF. Chạy trong thư mục này:

~~~powershell
.\build-print.ps1
~~~

Cần Typst và Palatino Linotype. Nếu trình biên dịch chưa có trong PATH:

~~~powershell
.\build-print.ps1 -Typst 'C:\duong-dan\typst.exe'
~~~

Mặc định chỉ dựng hai PDF trong thư mục này. Thêm `-IncludeClaude` để dựng lại GK0/GK5
vào đúng thư mục `docs_claude`; khi đó cần thêm Noto Sans (Regular, Bold, Italic, BoldItalic),
có thể chỉ định bằng `-FontPath`.

Nếu PowerShell chặn script, cho phép riêng tiến trình dựng:

~~~powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\build-print.ps1
~~~
