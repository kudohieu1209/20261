# Tuần 2 (25/10 – 01/11/2026): việc còn lại trước khi nộp

Trong `PROGRESS REPORT tuần 2.docx` có các chỗ **tô vàng**. Mỗi chỗ cần thay bằng ảnh hoặc kết quả thật, rồi xoá dòng tô vàng đó.

**Hạn:** mọi người gửi ảnh vào nhóm chat **trước 12h trưa Chủ nhật 01/11**. Hiếu ghép báo cáo và nộp trong chiều/tối Chủ nhật.

## 1. Phân công

### Hoàng (Process & Signal, chủ trì trình bày tuần 2)

| Mục | Làm gì | Ảnh phải thấy |
|---|---|---|
| b | Trong thư mục repo chạy `git diff 06aad25 HEAD -- kernel/proc.h kernel/termios.h` (chạy được cả trên Windows) | Dòng `+ STOPPED`, `+ int pgid;`, `+ int pendstop;`…, file `termios.h` mới |
| d | `make qemu` trên Ubuntu. Ở dấu nhắc `$` nhấn Ctrl-P. Chạy `counter \| cat`, nhấn Ctrl-P khi đang chạy, rồi Ctrl-C để thoát | Bảng `pid pgid state name`: `sh`, `counter`, `cat` của job có **chung pgid**, khác pgid của shell |

Chuẩn bị trình bày (mục "Nội dung báo cáo với giảng viên" của tuần 2 trong kế hoạch):
- So sánh struct proc của xv6 gốc với bản triển khai: bảng ở minh chứng b.
- Vì sao cần Process Group và `fgpgid`.
- Đường đi `setpgid()` từ user → `ecall` → `syscall()` → `sys_setpgid()` → `ksetpgid()`.

Đọc lại Activity 1 và Member 1 trong báo cáo; chỗ nào không đúng việc mình làm thì báo Hiếu.

### Hiếu (TTY Layer, ghép và nộp báo cáo)

| Mục | Làm gì | Ảnh phải thấy |
|---|---|---|
| c | `make qemu`.<br>`ttydemo cooked`: gõ `abc`, Backspace, Enter, rồi `q` Enter<br>`ttydemo noecho`: gõ `hello`, Enter<br>`ttydemo raw`: gõ `a`, Ctrl-C, mũi tên lên, rồi `q` | cooked in `read() returned 3 bytes: ab`<br>noecho in `you typed 5 characters (not shown)`<br>raw in `key ^C = 3`; mũi tên lên in 3 dòng 27, 91, 65 |

- Ghép 5 ảnh vào báo cáo và xoá các dòng tô vàng.
- Ở mục **4c**, thay `[PASS/FAIL – điền sau khi chạy]` bằng kết quả thật. Ảnh nào không giống cột "Ảnh phải thấy" thì ghi FAIL kèm mô tả và thêm vào mục **5a**. Không sửa cho đẹp.
- Chuẩn bị giải thích phần TTY khi Hoàng trình bày: đường đi `ioctl()`, 3 chế độ Cooked / No-Echo / Raw.

### Tuấn Anh (Shell & Testing)

| Mục | Làm gì | Ảnh phải thấy |
|---|---|---|
| a | Cập nhật Trello theo mục 3 rồi chụp | Thẻ tuần 2 ở cột Đã xong, thẻ tuần 3 ở cột Cần làm |
| e | Vẽ sơ đồ tuần 2 trên Figma theo cách của Tuấn Anh (prompt ở mục 2 chỉ để tham khảo), rồi chụp | Sơ đồ nội dung tuần 2: struct proc / struct tty, đường đi `ioctl()` và `setpgid()` |

- Chuẩn bị giải thích bảng job: các trường của `struct job`, và vì sao cả shell lẫn tiến trình con đều gọi `setpgid()`.
- Đọc lại Activity 3 và Member 3 trong báo cáo.

## Tin nhắn gửi nhóm (dán vào nhóm chat)

```
Mọi người ơi, báo cáo tuần 2 (25/10 – 01/11) mình soạn xong phần chữ rồi, giờ còn thiếu 5 ảnh minh chứng. Mọi người gửi ảnh vào nhóm trước 12h trưa CN 01/11 giúp mình nhé, mình ghép vào rồi nộp.

Hoàng (tuần này Hoàng chủ trì trình bày):
- Ảnh b: trong thư mục repo chạy  git diff 06aad25 HEAD -- kernel/proc.h kernel/termios.h  rồi chụp màn hình.
- Ảnh d: make qemu, ở dấu $ nhấn Ctrl-P; sau đó chạy  counter | cat , đang chạy thì nhấn Ctrl-P lần nữa rồi chụp. Trong bảng pid/pgid, sh, counter và cat của job phải chung một pgid. Xong thì Ctrl-C để thoát.
- Phần trình bày: so sánh struct proc của xv6 gốc với bản triển khai, vì sao cần pgid và fgpgid, đường đi của setpgid().

Tuấn Anh:
- Ảnh a: cập nhật Trello (thẻ tuần 2 chuyển sang Đã xong, thêm các thẻ tuần 3) rồi chụp.
- Ảnh e: vẽ sơ đồ tuần 2 trên Figma, vẽ thế nào tuỳ Tuấn Anh, xong thì chụp.
- Chuẩn bị giải thích struct job trong sh.c.

Mình (Hiếu): chụp ttydemo 3 chế độ (ảnh c), điền kết quả, ghép báo cáo và nộp.

Lưu ý: chạy ra khác hướng dẫn thì cứ chụp đúng như nó hiện, đừng chạy lại cho đẹp, mình sẽ ghi vào phần vấn đề còn tồn tại. Mọi người đọc lại đoạn "Personal contribution" của mình trong báo cáo, chỗ nào sai thì báo mình sửa nhé.
```

## 2. Prompt cho ChatGPT (Figma), sơ đồ tuần 2

```
Trong FigJam board "OS Project 26126", tạo một section mới tên "Tuần 2 — Cấu trúc dữ liệu & system call", đặt bên phải các sơ đồ tuần 1. Vẽ sơ đồ bằng đúng đoạn Mermaid sau, giữ nguyên thứ tự trên xuống dưới, không tự sắp xếp lại:

flowchart TD
  subgraph U["USER SPACE"]
    A["ttydemo / sh"] --> B["tcsetattr() / tcsetpgrp()  (user/ulib.c)"]
    C["sh: setpgid(pid, pid)"]
  end
  B --> D["ioctl(fd, TCSETS / TIOCSPGRP) → ecall"]
  C --> E["setpgid(pid, pgid) → ecall"]
  subgraph K["KERNEL"]
    D --> F["syscall()  SYS_ioctl = 28"]
    F --> G["sys_ioctl()  sysfile.c"]
    G --> H["fileioctl()  file.c"]
    H --> I["devsw[CONSOLE].ioctl"]
    I --> J["consoleioctl()  console.c"]
    J --> T["struct tty: buf r/w/e, lflag, fgpgid"]
    E --> L["syscall()  SYS_setpgid = 26"]
    L --> M["sys_setpgid()  sysproc.c"]
    M --> N["ksetpgid()  proc.c"]
    N --> P["struct proc: pgid, STOPPED, pendstop, stopsig"]
  end
  T -. "Ctrl-C / Ctrl-Z: ksignal(-fgpgid, sig)" .-> P

Bên cạnh sơ đồ, thêm 3 sticky note (màu khác nhau):
1. "Cooked = ECHO | ICANON | ISIG — read() trả về cả dòng, có echo, Ctrl-C/Z thành tín hiệu"
2. "No-Echo = ICANON | ISIG — như Cooked nhưng không hiện chữ (gõ mật khẩu)"
3. "Raw = 0 — mỗi phím trả về ngay, Ctrl-C chỉ là byte 3"
Tiêu đề section ghi thêm dòng nhỏ: "Prototype — đường đi ioctl() và setpgid(), cầu nối TTY ↔ Process là fgpgid".
```

## 3. Trello

- **Đã xong (tuần 2):**
  - Phân tích struct proc & Process Group (Hoàng)
  - Phân tích struct tty, 3 chế độ & ioctl (Hiếu)
  - Kiểm chứng thiết kế bảng job (Tuấn Anh)
  - Demo ttydemo 3 chế độ
  - Quan sát pgid bằng Ctrl-P
  - Báo cáo tuần 2
- **Cần làm (tuần 3):**
  - Phân tích & kiểm chứng ksignal / sigdeliver / stopcheck (Hoàng)
  - Kiểm chứng Ctrl-C / Ctrl-Z trong consoleintr (Hiếu)
  - Kiểm chứng shell với job tiền cảnh, chạy test Ctrl-C / Ctrl-Z (Tuấn Anh)
  - Demo counter → Ctrl-Z → Ctrl-P (Hiếu + Hoàng)
  - Figma & Trello tuần 3
