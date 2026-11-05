# 🎵 Bài Tập Quản Lý Tiến Trình: Tiến Trình Cha - Con Phát Nhạc & Bảng Tin

Học phần: **Hệ Điều Hành (Operating Systems)** – Đại học Bách khoa Hà Nội (HUST).

---

## 🎯 1. Đề Bài & Yêu Cầu

Viết một chương trình trong đó:
1. **Tiến trình cha (Parent Process)** sử dụng lời gọi hệ thống `fork()` để tạo ra một **tiến trình con (Child Process)**.
2. **Tiến trình con** thực thi phát một bản nhạc (sử dụng họ hàm `exec` gọi trình phát nhạc hệ thống).
3. **Tiến trình cha** sử dụng `wait()` / `waitpid()` để tạm dừng và đồng bộ, chờ tiến trình con hoàn tất việc phát nhạc.
4. Sau khi tiến trình con kết thúc, **tiến trình cha** phát đi một **bảng tin thông báo** (vừa hiển thị banner, vừa có thể phát âm thanh giọng nói qua công cụ Text-to-Speech `spd-say` trên Linux) với các câu hỏi:
   - *"Tiến trình vừa rồi nghe có hay không?"*
   - *"Vui lòng quay về học phần Hệ Điều Hành!"*
   - *"Quý vị chấm điểm tiến trình vừa rồi mấy sao (1 đến 5 sao)?"*
5. Người dùng tương tác nhập điểm đánh giá và tiến trình cha phản hồi tương ứng theo các khái niệm Hệ điều hành (Zombie, Orphan, Scheduler, IPC, Deadlock...).

---

## 🧠 2. Cơ Chế Hoạt Động & Kiến Thức Hệ Điều Hành

### Sơ đồ luồng thực thi (Process Lifecycle):

```text
               [Bắt đầu: Tiến trình cha]
                          │
                       fork()
                     ┌────┴────────────────────────┐
                     ▼                             ▼
         (Trả về PID của con > 0)          (Trả về 0)
             [Tiến trình cha]            [Tiến trình con]
                     │                             │
                 waitpid()                  execlp("aplay", ...)
                     │                      (Thay thế không gian nhớ)
                     │                             │
             [Chờ (Blocked)]                       ▼
                     │                     [Phát xong bản nhạc]
                     │                             │
                     │                          exit(0)
                     │                             │
                     └────────◄── (SIGCHLD) ───────┘
                     │          (Giải phóng PCB con, tránh Zombie)
                     ▼
          [Đọc exit status của con]
                     │
          [Phát bảng tin & Giọng nói]
                     │
          [Nhận đánh giá sao từ User]
                     │
          [Tiến trình cha exit(0)]
```

### Các Lời Gọi Hệ Thống (System Calls) Cốt Lõi:

| Lời gọi hệ thống | Chức năng trong bài tập | Chi tiết kỹ thuật |
| :--- | :--- | :--- |
| `fork()` | Nhân bản tiến trình cha thành tiến trình con | Trả về `0` cho tiến trình con, trả về `PID con` cho tiến trình cha, `< 0` nếu thất bại. Hai tiến trình có không gian địa chỉ độc lập (Copy-on-Write). |
| `execlp()` | Thay thế toàn bộ hình ảnh tiến trình con bằng trình phát nhạc (`aplay`, `paplay`...) | Nạp file nhị phân mới vào vùng `.text`, thiết lập lại stack/heap của con. Nếu thành công thì code phía sau lệnh `exec` không bao giờ chạy. |
| `waitpid()` | Tiến trình cha chuyển sang trạng thái Blocked để chờ con kết thúc | Thu dọn `PCB` (Process Control Block) của tiến trình con, ngăn chặn tình trạng **Zombie Process** (tiến trình thây ma). |
| `WIFEXITED()` / `WEXITSTATUS()` | Macro kiểm tra trạng thái kết thúc của con | Xác định tiến trình con kết thúc bình thường và lấy mã thoát (exit code). |

---

## 📂 3. Cấu Trúc Mã Nguồn

Thư mục `src/exercises/process_music/` bao gồm:

* [`process_music.c`](process_music.c): Mã nguồn ngôn ngữ **C** chuẩn POSIX (tự động tạo file WAV giai điệu mẫu nếu không có sẵn nhạc, gọi `aplay`, `waitpid`, phát bảng tin và Text-to-Speech).
* [`process_music.py`](process_music.py): Mã nguồn ngôn ngữ **Python** (`os.fork`, `os.execvp`, `os.waitpid`) để đối chiếu và tham khảo.
* [`Makefile`](Makefile): Script tự động biên dịch C với `gcc -Wall -Wextra -O2 -lm`.

---

## 🚀 4. Hướng Dẫn Biên Dịch & Chạy

### Cách 1: Chạy bằng mã nguồn C (Khuyên dùng cho môn Hệ điều hành)

1. **Biên dịch:**
   ```bash
   cd "src/exercises/process_music"
   make
   ```

2. **Chạy với bản nhạc mẫu tự động tạo:**
   ```bash
   ./process_music
   ```

3. **Chạy với một bản nhạc WAV/MP3 riêng của bạn:**
   ```bash
   ./process_music /path/to/your/song.wav
   ```

4. **Dọn dẹp file biên dịch:**
   ```bash
   make clean
   ```

---

### Cách 2: Chạy bằng mã nguồn Python

```bash
python3 process_music.py
# Hoặc truyền file nhạc riêng:
python3 process_music.py /path/to/your/song.wav
```

---

## 🔊 5. Tính Năng Đặc Biệt

1. **Tự sinh file WAV chuẩn (PCM 16-bit, 22050 Hz):**
   Chương trình tự động tính toán sóng âm hình sin của khúc nhạc *Ode to Joy (Beethoven)* và ghi ra file `sample_melody.wav`, giúp chạy ngay lập tức mà không cần tải nhạc bên ngoài.
2. **Text-To-Speech (Phát giọng nói thực tế):**
   Tiến trình cha kiểm tra công cụ `spd-say` có trên hệ thống Ubuntu/Linux để thực sự "nói" bảng tin qua loa máy tính bên cạnh việc hiển thị text trên terminal.
3. **Chấm điểm & Nhận xét hài hước theo thuật ngữ OS:**
   - 5 ⭐: Hệ thống không có Zombie hay Orphan, lập lịch context switch hoàn hảo!
   - 4 ⭐: CPU Scheduler cấp time-slice mượt mà.
   - 1-2 ⭐: Cảnh báo Deadlock và Starvation!
