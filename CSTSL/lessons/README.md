# 📚 GIÁO TRÌNH & BÀI HỌC CƠ SỞ TRUYỀN SỐ LIỆU (ET4070 - HUST)

Bộ tài liệu tự học từ căn bản đến nâng cao, bám sát 100% dạng bài thi cuối kỳ môn Cơ sở truyền số liệu (ĐHBK Hà Nội).

---

## 🗺️ LỘ TRÌNH 3 CHẶNG CHINH PHỤC ĐIỂM TỐI ĐA

### 🔹 CHẶNG 1: LÝ THUYẾT HÀNG ĐỢI & MẠNG HÀNG ĐỢI (3.5 Điểm Đề Thi)
- [x] **[Bài 01: Tổng quan Hàng đợi, Ký hiệu Kendall & Định lý Little](./01_Tong_quan_Hang_doi_va_Dinh_ly_Little.md)**
  - Bản chất hàng đợi trong Router mạng.
  - Các tham số cốt lõi: λ, μ, ρ.
  - Phân biệt "Hệ thống" vs. "Hàng đợi" (N, N_Q, T, T_Q).
  - Ký hiệu Kendall A/S/m/K.
  - Định lý Little và bài tập vận dụng.
- [ ] **Bài 02: Mô hình hàng đợi M/M/1 và M/M/1/K**
  - Quá trình Sinh - Tử (Birth-Death Process).
  - Công thức tính xác suất trạng thái p_i, xác suất rỗng p_0, xác suất mất gói p_loss.
  - Các chỉ số hiệu năng E[N], E[T], E[N_Q], E[T_Q].
- [ ] **Bài 03: Mạng hàng đợi Jackson (Jackson Networks)**
  - Định lý Burke và bảo toàn luồng Poisson.
  - Cân bằng luồng tại các nút Router (ghép luồng, rẽ luồng).
  - Tính thời gian trễ trung bình của gói tin qua toàn mạng.

---

### 🔹 CHẶNG 2: ĐỒ THỊ & GIẢI THUẬT ĐỊNH TUYẾN (3.0 Điểm Đề Thi)
- [ ] **Bài 04: Cây khung nhỏ nhất MST (Minimum Spanning Tree)**
  - Giải thuật Prim (phát triển cây từ đỉnh).
  - Giải thuật Kruskal (ghép cạnh có trọng số nhỏ nhất).
- [ ] **Bài 05: Cây đường đi ngắn nhất SPT (Shortest Path Tree)**
  - Giải thuật Dijkstra (lập bảng từng bước chuẩn phòng thi).
  - Giải thuật Floyd-Warshall (tìm đường đi ngắn nhất giữa mọi cặp đỉnh).

---

### 🔹 CHẶNG 3: ĐIỀU KHIỂN LUỒNG & CƠ CHẾ ARQ (3.5 Điểm Đề Thi)
- [ ] **Bài 06: Phân tích các loại Trễ trong mạng**
  - Trễ phát gói tin (t_trans = L / R).
  - Trễ truyền lan tín hiệu (t_prop = d / v).
  - Thời gian trễ khứ hồi RTT (Round Trip Time).
- [ ] **Bài 07: Cơ chế phát lại tự động ARQ & Hiệu suất kênh**
  - Kỹ thuật Stop-and-Wait ARQ.
  - Kỹ thuật Go-Back-N ARQ.
  - Kỹ thuật Selective Repeat ARQ.
  - Vẽ giản đồ thời gian (Time Diagram) khi có lỗi/mất gói/mất ACK.
  - Công thức tính hiệu suất sử dụng kênh (η) và thông lượng (Throughput).
- [ ] **Bài 08: Kiểm soát tắc nghẽn & Cơ chế cửa sổ**
  - Cửa sổ trượt (Sliding Window).
  - Thuật toán thích ứng AIMD.
  - Cơ chế Leaky Bucket & Token Bucket.
