# BÀI 01: TỔNG QUAN VỀ HÀNG ĐỢI & ĐỊNH LÝ LITTLE

> **Mục tiêu bài học:**
> 1. Hiểu bản chất mô hình hàng đợi bên trong một thiết bị mạng (Router/Switch).
> 2. Nắm vững 3 tham số sống còn: Tốc độ đến (λ), Tốc độ phục vụ (μ), Hệ số sử dụng (ρ).
> 3. Phân biệt chính xác giữa **"Hệ thống" (System)** và **"Hàng đợi" (Queue)**.
> 4. Hiểu cách đọc Ký hiệu Kendall: A / S / m / K.
> 5. Sử dụng thành thạo **Định lý Little** để giải quyết các câu hỏi tính toán cơ bản.

---

## 1. HÌNH DUNG TRỰC QUAN: TỪ ĐỜI THỰC ĐẾN THIẾT BỊ MẠNG

### ☕ Ví dụ đời thực: Quầy trà sữa
Hãy tưởng tượng bạn đi mua trà sữa:
- Quầy chỉ có **1 nhân viên pha chế** (gọi là **Server** / Trạm phục vụ).
- Khách hàng tới quầy với tốc độ trung bình **λ** (ví dụ: 1 phút có 2 người tới).
- Mỗi cốc trà sữa nhân viên cần thời gian pha chế là **T_S**, tương ứng tốc độ phục vụ là **μ** (ví dụ: 1 phút pha được 3 cốc).
- Nếu nhân viên đang bận pha cho khách trước, khách mới đến buộc phải xếp hàng chờ trong **Hàng đợi (Queue)**.
- **Hệ thống (System)** = Toàn bộ người đang đứng chờ trong hàng đợi + Người đang được pha chế.

```
Khách tới (λ)                                                 Khách rời đi
────────────► [ Khách 3 | Khách 2 ] ────────► [ Khách 1 ] ────────────►
                  HÀNG ĐỢI (Queue)            SERVER (Trạm)
              │                                           │
              └──────────────── HỆ THỐNG ─────────────────┘
```

---

### 🌐 Áp dụng vào Thiết bị mạng (Router / Switch)
Trong mạng máy tính viễn thông:
- **Khách hàng** chính là các **Gói tin (Packets)**.
- **Quầy phục vụ** chính là **Cổng ra (Outgoing Interface / Link)** của Router.
- **Hàng đợi** chính là **Bộ nhớ đệm (Buffer)** của Router.
- **Nguyên tắc phục vụ:** Thông thường tuân theo **FIFO (First In, First Out)** - gói tin nào đến trước thì được truyền đi trước.

```
Luồng gói tin tới (λ)                                         Đường truyền
─────────────────────► [ Gói 3 | Gói 2 ] ─────► [ Gói 1 ] ─────────────────►
                         BỘ NHỚ ĐỆM (Buffer)      CỔNG PHÁT (Transmitter)
                       │                                                 │
                       └────────────── BÊN TRONG ROUTER ─────────────────┘
```

---

## 2. BỘ BA THAM SỐ CỐT LÕI (λ, μ, ρ)

### 2.1. Tốc độ đến: λ (Arrival Rate)
- **Định nghĩa:** Số lượng gói tin (hoặc yêu cầu) đến hệ thống trong một đơn vị thời gian.
- **Đơn vị thường dùng:** 
  - `gói/giây` (packets per second - `pps`)
  - `yêu cầu/giây` (requests/s)

---

### 2.2. Tốc độ phục vụ: μ (Service Rate)
- **Định nghĩa:** Số lượng gói tin tối đa mà trạm có thể xử lý/truyền đi trong một đơn vị thời gian.
- **Đơn vị:** `gói/giây` (`pps`).
- **Thời gian phục vụ trung bình cho 1 gói tin (T_S):**
  
  ```
  T_S = 1 / μ
  ```
  *(Ví dụ: Tốc độ phục vụ μ = 100 gói/s → Thời gian truyền 1 gói tin là T_S = 1/100 = 0.01s = 10ms).*

- **🔥 Công thức kinh điển trong đề thi:**
  Đề bài thường không cho trực tiếp `μ`, mà cho:
  - Dung lượng kênh truyền: `C` (đơn vị: bps, Kbps, Mbps).
  - Kích thước gói tin: `L` (đơn vị: bit, Byte. Lưu ý: `1 Byte = 8 bits`).
  
  Khi đó tốc độ phục vụ `μ` được tính bằng:
  
  ```
  μ = C / L   (gói/giây)
  ```
  *(Ví dụ: Đường truyền C = 1 Mbps = 10^6 bps, gói tin L = 1000 bits → μ = 10^6 / 1000 = 1000 gói/s).*

---

### 2.3. Hệ số sử dụng kênh / Cường độ tải: ρ (Utilization / Traffic Intensity)
- **Công thức:**
  
  ```
  ρ = λ / μ
  ```

- **Ý nghĩa vật lý:**
  - `ρ` biểu thị **tỷ lệ phần trăm thời gian mà cổng phát phải làm việc (bận)**.
  - Ví dụ: `ρ = 0.8` nghĩa là server bận 80% thời gian, rảnh rỗi 20% thời gian.
  - Xác suất server bận: `p_busy = ρ`.
  - Xác suất server rảnh (không có ai): `p_idle = 1 - ρ`.

- **⚠️ Điều kiện hệ thống ổn định:**
  
  ```
  ρ < 1   (tức là: λ < μ)
  ```
  - Nếu `λ ≥ μ`: Gói tin đến nhanh hơn tốc độ gửi đi. Hàng đợi sẽ phình to vô hạn dẫn đến tràn bộ đệm, mất gói 100% (hệ thống sụp đổ).
  - Vì vậy, mọi bài toán hàng đợi ổn định đều bắt buộc phải thỏa mãn `ρ < 1`.

---

## 3. PHÂN BIỆT: "HỆ THỐNG" (SYSTEM) vs. "HÀNG ĐỢI" (QUEUE)

Hầu hết sinh viên bị mất điểm trong đề thi vì nhầm lẫn giữa hai khái niệm này.

| Đại lượng | Trong HÀNG ĐỢI (Queue - Đang chờ) | Tại SERVER (Đang phục vụ) | Toàn bộ HỆ THỐNG (System) |
| :--- | :--- | :--- | :--- |
| **Số gói trung bình** | **N_Q** | **N_S** (với 1 server: N_S = ρ) | **N = N_Q + N_S** |
| **Thời gian trung bình** | **T_Q** (Thời gian chờ) | **T_S = 1 / μ** (Thời gian phục vụ) | **T = T_Q + T_S** (Tổng trễ) |

> 📌 **Ghi nhớ:**
> - `Hệ thống` bao gồm TẤT CẢ các gói (cả gói đang xếp hàng và gói đang nằm trong bộ phát).
> - `Hàng đợi` CHỈ tính các gói đang nằm chờ trong bộ nhớ đệm.

---

## 4. ĐỊNH LÝ LITTLE (LITTLE'S LAW)

Định lý Little là định lý cơ bản và quan trọng nhất của lý thuyết xếp hàng. Định lý này đúng cho **mọi hệ thống ổn định**, bất kể phân bố đến và phân bố phục vụ là gì.

### 4.1. Phát biểu bằng lời
> *"Số lượng khách hàng trung bình trong một hệ thống bằng tốc độ đến trung bình nhân với thời gian trung bình mà một khách hàng lưu lại trong hệ thống đó."*

### 4.2. Bộ 3 công thức Little

```
1) Đối với toàn bộ hệ thống:     N   = λ × T
2) Đối với hàng đợi:             N_Q = λ × T_Q
3) Đối với trạm phục vụ:         N_S = λ × T_S = λ × (1 / μ) = ρ
```

```
       ┌──────────────────────────────────────────────┐
       │                 ĐỊNH LÝ LITTLE               │
       │                                              │
       │             Số lượng = λ × Thời gian         │
       └──────────────────────────────────────────────┘
```

Chỉ cần bạn biết 2 trong 3 đại lượng, bạn luôn luôn suy ra được đại lượng còn lại!

---

## 5. KÝ HIỆU KENDALL: A / S / m / K

Ký hiệu Kendall dùng để mô tả cấu trúc của một hệ thống hàng đợi theo chuẩn quốc tế:

```
                  A  /  S  /  m  /  K
                  │     │     │     │
                  │     │     │     └─► Sức chứa tối đa của hệ thống (mặc định là ∞)
                  │     │     └───────► Số trạm phục vụ (Số server)
                  │     └─────────────► Phân bố thời gian phục vụ
                  └───────────────────► Phân bố thời gian giữa các lần đến
```

### Các ký hiệu quy ước:
- **`M` (Markov / Memoryless):** Phân bố mũ (Exponential). Với tiến trình đến, tương đương luồng đến là **Poisson**.
- **`D` (Deterministic):** Xác định, thời gian đến hoặc phục vụ là một hằng số cố định.
- **`G` (General):** Phân bố bất kỳ tổng quát.
- **`m`:** Số lượng server chạy song song (1, 2, ..., c).
- **`K`:** Sức chứa tối đa của cả hệ thống (bao gồm cả hàng đợi và server). Nếu không ghi rõ thì mặc định `K = ∞`.

**Ví dụ thường gặp trong đề thi:**
- `M / M / 1`: Luồng đến Poisson, thời gian phục vụ phân bố mũ, có 1 server, bộ đệm vô hạn (K = ∞).
- `M / M / 1 / K`: Giống trên nhưng bộ đệm có giới hạn, tối đa chỉ chứa được K gói tin (nếu quá K gói thì gói mới đến sẽ bị vứt bỏ - drop).
- `M / M / c`: Hệ thống có `c` server phục vụ cùng lúc.

---

## 6. VÍ DỤ VẬN DỤNG CÓ LỜI GIẢI CHI TIẾT

### 📝 Bài toán mẫu
Một router trong mạng nhận các gói tin với tốc độ trung bình `λ = 120 pps` (packets per second). Kích thước trung bình của mỗi gói tin là `L = 1000 Byte`. Cổng ra của router có băng thông `C = 1.6 Mbps`. Đo đạc thực tế cho thấy một gói tin mất trung bình `T = 25 ms` để đi qua router (tính từ lúc vào hàng đợi đến khi truyền xong).

**Yêu cầu:**
1. Tính tốc độ phục vụ `μ` của cổng ra và hệ số sử dụng `ρ`?
2. Tính số lượng gói tin trung bình hiện diện trong toàn bộ router (`N`)?
3. Tính thời gian một gói tin phải nằm chờ trong bộ đệm (`T_Q`) và số lượng gói tin trung bình đang xếp hàng chờ (`N_Q`)?

---

### 💡 Lời giải chi tiết:

#### Câu 1: Tính μ và ρ
- Đổi đơn vị kích thước gói:
  `L = 1000 Byte = 1000 × 8 bits = 8000 bits`.
- Đổi đơn vị băng thông kênh:
  `C = 1.6 Mbps = 1.6 × 10^6 bps = 1,600,000 bps`.
- Tốc độ phục vụ của cổng ra:
  `μ = C / L = 1,600,000 / 8,000 = 200 (gói/s)`.
- Hệ số sử dụng:
  `ρ = λ / μ = 120 / 200 = 0.6`.
  *(Nhận xét: ρ = 0.6 < 1 → Hệ thống ổn định; Cổng ra bận 60% thời gian).*

#### Câu 2: Tính N (Số gói trung bình trong hệ thống)
- Đổi thời gian: `T = 25 ms = 0.025 s`.
- Áp dụng Định lý Little cho toàn bộ hệ thống:
  `N = λ × T = 120 × 0.025 = 3 (gói)`.

#### Câu 3: Tính T_Q và N_Q
- Thời gian phục vụ trung bình tại cổng phát:
  `T_S = 1 / μ = 1 / 200 = 0.005 s = 5 ms`.
- Thời gian gói tin phải chờ trong hàng đợi:
  `T_Q = T - T_S = 25 ms - 5 ms = 20 ms = 0.02 s`.
- Số gói tin trung bình nằm chờ trong hàng đợi:
  - *Cách 1 (Áp dụng Định lý Little cho hàng đợi):*
    `N_Q = λ × T_Q = 120 × 0.02 = 2.4 (gói)`.
  - *Cách 2 (Dùng mối quan hệ N = N_Q + N_S):*
    `N_S = ρ = 0.6 (gói)`.
    `N_Q = N - N_S = 3 - 0.6 = 2.4 (gói)`.
  *(Cả hai cách đều cho kết quả hoàn toàn khớp nhau!)*

---

## 🎯 BÀI TẬP TỰ LUYỆN (CHECKPOINT 1)

Hãy thử lấy giấy nháp và tính nhanh bài toán sau:

> **Đề bài:** Một switch có 1 cổng ra với dung lượng `C = 10 Mbps`. Các gói tin có độ dài cố định `L = 1250 Byte`. Tốc độ gói tin gửi đến cổng này là `λ = 800 gói/s`. Biết thời gian chờ trung bình trong bộ đệm là `T_Q = 3 ms`.
> 
> Hãy tính:
> 1. Tốc độ phục vụ `μ` (gói/s) và hệ số sử dụng `ρ`?
> 2. Thời gian trung bình một gói tin lưu lại trong switch (`T`)?
> 3. Số gói tin trung bình trong hàng đợi (`N_Q`) và trong toàn bộ switch (`N`)?
