# ET4070 — bản sách bài giải đen trắng

12 tập, tổng cộng **76 trang A4**. Mỗi PDF có nguồn `.typ` cùng tên; dùng chung `style.typ`.

| PDF | Trang |
|---|---:|
| [GK0_TapInGiay_ViDuTrenLop.pdf](GK0_TapInGiay_ViDuTrenLop.pdf) | 12 |
| [GK1_Poisson_PhanBoMu_MM1.pdf](GK1_Poisson_PhanBoMu_MM1.pdf) | 5 |
| [GK2_HangDoiDon.pdf](GK2_HangDoiDon.pdf) | 7 |
| [GK3_PhuongTrinhLuuLuong.pdf](GK3_PhuongTrinhLuuLuong.pdf) | 5 |
| [GK4_HieuNangMang.pdf](GK4_HieuNangMang.pdf) | 5 |
| [GK5_CauHoiLyThuyet.pdf](GK5_CauHoiLyThuyet.pdf) | 5 |
| [GK6_DeThiThuGiuaKy.pdf](GK6_DeThiThuGiuaKy.pdf) | 7 |
| [CK1_DinhTuyen.pdf](CK1_DinhTuyen.pdf) | 7 |
| [CK2_MoHinhHoaRouter.pdf](CK2_MoHinhHoaRouter.pdf) | 6 |
| [CK3_ARQ_DieuKhienLuong.pdf](CK3_ARQ_DieuKhienLuong.pdf) | 7 |
| [CK4_CongBang_TacNghen.pdf](CK4_CongBang_TacNghen.pdf) | 5 |
| [CK5_DeThiThuCuoiKy.pdf](CK5_DeThiThuCuoiKy.pdf) | 5 |

## Build lại

Trong thư mục này, dùng Typst 0.15.1:

```bash
typst compile GK1_Poisson_PhanBoMu_MM1.typ
bash build.sh
```

Font chính: **Palatino Linotype** (máy có, đã kiểm tra bằng `fc-list`); dự phòng Libertinus Serif. Font toán New Computer Modern Math. Gói dùng đúng phiên bản nguồn: fletcher 0.5.8, cetz 0.3.4 (cần có cache hoặc mạng ở lần build đầu). `content/` và ảnh thang xám `img/` đã nằm trong bộ này, không cần import ra thư mục bên ngoài.

## Các quyết định dàn trang

- Chữ thân bài 11 pt, lề 2–2,2 cm; tiêu đề đậm, nền trắng, đường viền đen mảnh. “Khuôn giải / Bẫy / Sổ tay” thành đoạn có nhãn đậm; bỏ lưới chấm và khoảng viết tay. Chỉ dẫn thao tác đổi thành làm ra giấy riêng.
- Bảng đáp án hai cột chuyển thành các đoạn theo số bài; bảng công thức và bảng thuật toán giữ cấu trúc. CK1 xếp hình và phần diễn giải theo chiều dọc để tránh chồng chữ. CK4 dùng ACK nét đứt/nét liền thay mã màu, giữ nguyên số khung và thời điểm.
- GK6: ba đề A/B/C đặt trước, mỗi đề bắt đầu trang mới; toàn bộ lời giải ở sau. CK5: hai đề trước hai lời giải; bảng tự chấm chuyển lên phần hướng dẫn để không tạo riêng trang gần trống. Giản đồ ARQ lớn giữ nguyên khối để dễ đọc.
- Các nhãn “Sổ tay … trang 1–9” và chỉ dẫn số trang vốn có được giữ như nguồn; chúng không nhất thiết là số trang vật lý của bản dàn lại. Mục lục có liên kết trang ở GK0/GK6/CK5 được tính lại tự động.

## Nội dung cần lưu ý — không tự sửa số

- GK0/GK5 nguồn `.typ` hiện có dùng các tệp `mang-phong-thi/content/gk-exam-*.typ`, và nội dung này không hoàn toàn đồng bộ với PDF đã xuất. Bộ mới sao chép các phần phụ thuộc để build độc lập. GK0 VD7 giữ thêm bốn giá trị làm tròn **0,533; 0,267; 0,133; 0,067** vốn in đậm trong PDF gốc.
- GK0 VD12 giữ nguyên hai ghi chú từ Markdown: bảng lớp ghi **0,10602 — nên hỏi lại**, và **≈ 8,8·10⁻⁷ — nên hỏi lại**; giữ cả ghi chú 1,67 của bảng lớp. Không thay các đáp số trong lời giải bằng số trên bảng.
- Những cảnh báo sẵn có về “ít nhất / không quá”, xác suất phải đợi so với bị từ chối, giả thiết ARQ và dữ kiện thiếu đều được giữ; không đánh giá lại hoặc tự sửa kết quả.

## Kiểm tra

- 12/12 tập biên dịch không lỗi/cảnh báo. Đã render và xem toàn bộ **76 trang**; PNG từng trang và bản xem hai trang nằm ở `qa/GK*/`, `qa/CK*/`.
- Đối chiếu đáp số in đậm bằng `pdftotext` (chuẩn hoá Unicode/khoảng trắng), kết hợp `pdftohtml -xml` để nhận diện phần đậm; không thiếu giá trị đã nhận diện. Đối chiếu nguyên văn các biểu thức `$…$` trong nguồn chính: không mất/thay biểu thức. Chi tiết: `qa/content-audit.json`.
- Toàn bộ PDF dùng ICC một kênh xám (N=1); tất cả pixel của toàn bộ trang render có R=G=B. Ảnh nhúng đều chuyển sang mode L. Chi tiết: `qa/grayscale-audit.json`; kiểm tra lại bằng `python3 qa/verify.py` sau khi render. Đây là phép kiểm tra thang xám thay cho Ghostscript bị môi trường từ chối đọc tệp.
- `qa/source-sha256.json` lưu dấu vân tay 77 tệp nguồn; đã đối chiếu và xác nhận không tệp nào trong `on-luyen-tablet` bị thay đổi. Không commit/push.

`remake.py` lưu cách chuyển hình thức từ nguồn; chạy nó chỉ khi muốn tạo lại nguồn dàn trang từ bộ đầu vào. Build PDF thông thường chỉ cần `build.sh`.
