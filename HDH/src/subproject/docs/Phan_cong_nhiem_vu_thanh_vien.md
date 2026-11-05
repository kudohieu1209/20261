# BẢNG PHÂN CÔNG NHIỆM VỤ THÀNH VIÊN NHÓM
## ĐỒ ÁN HỆ ĐIỀU HÀNH — HUST (2026.1)

---

- **Học phần:** Hệ điều hành (Operating Systems [Multimedia] — Mã lớp: 20261)
- **Mã đề tài:** 26126 (Đề số #27)
- **Tên đề tài:** **Xây dựng TTY Layer và Job Control trên hệ điều hành xv6-riscv**
- **Giảng viên hướng dẫn:** TS. Phạm Văn Tiến (`tien.phamvan1@hust.edu.vn`)
- **Kho lưu trữ (Repository):** [github.com/kudohieu1209/hedieuhanh-hust](https://github.com/kudohieu1209/hedieuhanh-hust)
- **Design Thinking (Figma):** [Figma Board — OS Project 26126](https://www.figma.com/board/VohV5EoTLyQ9YczJvytmDU)
- **Quản lý tiến độ (Trello):** [Trello Board — OS Project 26126](https://trello.com/b/fgC11Nz9/os-project-26126)

---

## 1. Danh sách thành viên và Phân vai chính

| STT | Họ và tên | Mã sinh viên | Email VNU / HUST | Vai trò chính | Phân hệ phụ trách |
|:---:|---|:---:|---|---|---|
| **1** | **Mai Duy Hiếu** | **20223967** | `hieu.md223967@sis.hust.edu.vn` | **Trưởng nhóm** | **TTY Layer & Device Driver (Console)** |
| **2** | **Nguyễn Huy Hoàng** | **20223912** *(20227610)* | `hoang.nh223912@sis.hust.edu.vn` | **Thành viên** | **Kernel & Signal (Process Management)** |
| **3** | **Nguyễn Tuấn Anh** | **20223988** *(20223864)* | `anh.nt223988@sis.hust.edu.vn` | **Thành viên** | **Shell, Job Control & Automated Testing** |

---

## 2. Mô hình kiến trúc 3 tầng và Ma trận RACI

Hệ thống Job Control & TTY Layer trên xv6-riscv được phân chia theo kiến trúc 3 tầng phối hợp chặt chẽ:

```
+-----------------------------------------------------------------------------+
|                               USER SPACE                                    |
|   user/sh.c (Bảng Job, jobs, fg, bg, kill, Line Editor, Pipeline Control)    |
|   -> Phụ trách: Nguyễn Tuấn Anh                                             |
+-----------------------------------------------------------------------------+
                                      ▲  System calls: ioctl, waitpid,
                                      │  setpgid, kill, pause
                                      ▼
+-----------------------------------------------------------------------------+
|                               KERNEL CORE                                   |
|   kernel/proc.c, trap.c, sysproc.c (Process Group, STOPPED, Signal, Safe-stop) |
|   -> Phụ trách: Nguyễn Huy Hoàng                                            |
+-----------------------------------------------------------------------------+
                                      ▲  Phát tín hiệu theo nhóm:
                                      │  ksignal(-fgpgid, SIGINT/SIGTSTP)
                                      ▼
+-----------------------------------------------------------------------------+
|                          DEVICE DRIVER & TTY                                |
|   kernel/console.c, termios.h, sysfile.c (Cooked/Raw/No-Echo, ioctl, Multi-TTY)|
|   -> Phụ trách: Mai Duy Hiếu                                                |
+-----------------------------------------------------------------------------+
```

### Ma trận trách nhiệm (RACI Matrix)

> **Ghi chú viết tắt:**
> - **R (Responsible):** Người trực tiếp thực hiện và chịu trách nhiệm chính.
> - **A (Accountable):** Người phê duyệt cuối cùng (Trưởng nhóm).
> - **C (Consulted):** Người phối hợp, tham vấn kỹ thuật.
> - **I (Informed):** Người được thông báo để đảm bảo tính đồng bộ toàn hệ thống.

| Hạng mục / Module kỹ thuật | Mai Duy Hiếu | Nguyễn Huy Hoàng | Nguyễn Tuấn Anh | File mã nguồn chủ đạo |
|---|:---:|:---:|:---:|---|
| **TTY Layer, 3 chế độ (Cooked/Raw/No-Echo)** | **R, A** | C | I | `kernel/console.c`, `kernel/termios.h` |
| **System call `ioctl()` & Terminal Attributes** | **R, A** | C | I | `kernel/sysfile.c`, `kernel/file.c` |
| **Bắt phím Ctrl-C / Ctrl-Z trong ngắt UART** | **R, A** | C | I | `kernel/console.c` (`consoleintr`) |
| **Chống đọc ngầm `SIGTTIN` & Multi-TTY (Ctrl-T)** | **R, A** | I | I | `kernel/console.c`, `user/init.c` |
| **Mở rộng `struct proc` & Quản lý `pgid`** | C | **R** | C | `kernel/proc.h`, `kernel/proc.c` |
| **Trạng thái `STOPPED` & Cơ chế Signal Kernel** | C | **R** | I | `kernel/signal.h`, `kernel/proc.c` |
| **Điểm dừng an toàn `stopcheck()` (Anti-Deadlock)** | I | **R** | I | `kernel/trap.c`, `kernel/proc.c` |
| **System call `waitpid()` (WUNTRACED, WNOHANG)** | I | **R** | C | `kernel/sysproc.c`, `kernel/wait.h` |
| **Xử lý tiến trình mồ côi (Reparenting, SIGHUP)** | I | **R** | I | `kernel/proc.c` (`exit`, `reparent`) |
| **Bảng quản lý Job trong Shell (`job_t`)** | I | C | **R** | `user/sh.c` |
| **Lệnh nội tại Shell: `jobs`, `fg`, `bg`, `kill %n`** | C | C | **R** | `user/sh.c` |
| **Điều phối Pipeline thành 1 Job (`p1 \| p2`)** | I | C | **R** | `user/sh.c` |
| **Line Editor (Phím mũi tên, lịch sử lệnh)** | C | I | **R** | `user/sh.c`, `user/ulib.c` |
| **Bộ kiểm thử tự động `test-jobctl.py`** | C | C | **R** | `test-jobctl.py` |
| **Kiểm thử hồi quy gốc xv6 (`usertests`)** | C | C | **R** | `test-xv6.py` |
| **Báo cáo tiến độ tuần theo mẫu & Slide** | **A** | R | R | `docs/`, `PROGRESS REPORT.docx` |

---

## 3. Phân công chi tiết theo từng thành viên

### 3.1. Mai Duy Hiếu — Trưởng nhóm / Phụ trách TTY Layer & Device Driver

- **Phân hệ:** Thiết bị đầu cuối, điều khiển Console/UART và giao tiếp phần cứng.
- **Mục tiêu kỹ thuật:** Chuyển đổi console nguyên thủy của xv6 thành hệ thống TTY tiêu chuẩn POSIX-lite hỗ trợ cấu hình đa chế độ, phát tín hiệu từ bàn phím và cô lập các phiên làm việc độc lập.
- **Danh sách tập tin phụ trách:**
  - `kernel/console.c`: Xử lý ngắt bàn phím, bộ đệm console, logic Cooked/Raw/No-Echo, cơ chế `SIGTTIN`, và chuyển đổi terminal ảo.
  - `kernel/termios.h`: Khai báo cấu trúc `struct termios`, các cờ `c_lflag` (`ECHO`, `ICANON`, `ISIG`) và các hằng số `ioctl`.
  - `kernel/file.c` & `kernel/file.h`: Mở rộng bảng thiết bị `devsw` thêm hàm `ioctl`.
  - `kernel/sysfile.c`: Cài đặt system call `sys_ioctl()` kiểm tra thiết bị `FD_DEVICE`.
  - `user/init.c`: Khởi tạo và gắn shell cho các terminal ảo.

#### Nhiệm vụ cụ thể:
1. **Mô hình hóa cấu trúc `struct tty`:** Quản lý các biến trạng thái terminal gồm `termios` hiện tại, `fgpgid` (nhóm tiến trình tiền cảnh đang chiếm quyền terminal), bộ đệm đầu vào/đầu ra.
2. **Cài đặt system call `ioctl`:**
   - Hỗ trợ các request: `TCGETS` (lấy thuộc tính), `TCSETS` (thiết lập thuộc tính), `TIOCGPGRP` (lấy nhóm tiền cảnh), `TIOCSPGRP` (chuyển giao nhóm tiền cảnh).
   - Đảm bảo an toàn bộ nhớ khi dùng `copyin()` / `copyout()` giữa Kernel và User Space.
3. **Hiện thực 3 chế độ terminal:**
   - **Cooked Mode (Canonical):** Đệm dòng, hỗ trợ xóa lùi (`Backspace`), hủy dòng (`Ctrl-U`), kết thúc tập tin (`Ctrl-D`).
   - **Raw Mode:** Bỏ qua đệm dòng, chuyển ngay từng phím bấm thô về ứng dụng (dùng cho Line Editor, Vim/Nano sau này).
   - **No-Echo Mode:** Ẩn ký tự hiển thị (dùng cho nhập mật khẩu).
4. **Bắt phím Ctrl-C / Ctrl-Z trong ngữ cảnh ngắt (`consoleintr`):**
   - Bắt phím ngắt `0x03` (`Ctrl-C`) và `0x1A` (`Ctrl-Z`).
   - Gọi `ksignal(-fgpgid, SIGINT/SIGTSTP)` để chuyển tín hiệu đến toàn bộ Process Group tiền cảnh.
   - **Ràng buộc quan trọng:** Tuyệt đối không gọi `sleep()` hay block trong `consoleintr()` vì đang chạy ở ngắt UART (Interrupt Context).
5. **Cơ chế bảo vệ đọc nền `SIGTTIN`:**
   - Khi một tiến trình chạy nền (Background Job có `pgid != fgpgid`) cố gắng gọi `consoleread()`, TTY Layer phải tự động kích hoạt gửi `SIGTTIN` để dừng tiến trình đó lại, không cho phép tranh chấp bàn phím với tiến trình tiền cảnh.
6. **Mở rộng Multi-TTY ảo:**
   - Cấu hình hỗ trợ 2 terminal ảo (`NTTY = 2`) trên cùng 1 cổng UART vật lý.
   - Bắt phím nóng `Ctrl-T` để chuyển đổi qua lại giữa TTY0 và TTY1 một cách mượt mà.

---

### 3.2. Nguyễn Huy Hoàng — Phụ trách Kernel & Signal (Process Management)

- **Phân hệ:** Quản lý tiến trình, vòng đời, hệ thống tín hiệu Kernel và kiểm soát tranh chấp/khóa.
- **Mục tiêu kỹ thuật:** Mở rộng nhân xv6 để hỗ trợ khái niệm nhóm tiến trình (Process Group), trạng thái dừng tạm thời `STOPPED`, và cơ chế chuyển phát tín hiệu an toàn, không gây Deadlock.
- **Danh sách tập tin phụ trách:**
  - `kernel/proc.h`: Mở rộng enum `procstate` thêm `STOPPED`, mở rộng `struct proc` với các trường `pgid`, `pendstop`, `stopsig`, `sigignore`.
  - `kernel/proc.c`: Logic khởi tạo, kế thừa trong `allocproc()`, `fork()`, `exec()`, giải phóng tại `exit()`, và thuật toán lập lịch `scheduler()`.
  - `kernel/trap.c`: Cơ chế bắt bẫy ngắt `usertrap()`, kiểm tra tín hiệu chờ và gọi `stopcheck()`.
  - `kernel/sysproc.c`: Cài đặt các system call `sys_setpgid()`, `sys_getpgid()`, `sys_waitpid()`, `sys_pause()`.
  - `kernel/signal.h`: Định nghĩa các hằng số tín hiệu (`SIGINT`, `SIGTSTP`, `SIGCONT`, `SIGKILL`, `SIGTTIN`, `SIGHUP`).
  - `kernel/wait.h`: Định nghĩa các cờ trạng thái `WUNTRACED`, `WNOHANG` và các macro kiểm tra `WIFEXITED`, `WIFSTOPPED`, `WEXITSTATUS`, `WSTOPSIG`.

#### Nhiệm vụ cụ thể:
1. **Mở rộng cấu trúc dữ liệu tiến trình:**
   - Bổ sung `enum procstate`: `STOPPED` (tiến trình bị tạm dừng khi nhận `SIGTSTP`/`SIGTTIN`, không được scheduler cấp CPU).
   - Thêm các trường vào `struct proc`:
     - `int pgid`: ID của nhóm tiến trình mà process trực thuộc.
     - `int pendstop`: Cờ đánh dấu tiến trình đang có lệnh phải dừng.
     - `int stopsig`: Lưu mã tín hiệu đã khiến tiến trình phải dừng.
     - `int sigignore`: Mặt nạ bỏ qua tín hiệu (đặc biệt cho Shell).
2. **Kế thừa và thiết lập Process Group:**
   - Viết `sys_setpgid(pid, pgid)` và `sys_getpgid(pid)`.
   - Cập nhật `fork()`: Tiến trình con mặc định kế thừa `pgid` và `sigignore` từ cha.
   - Cập nhật `exec()`: Giữ nguyên `pgid` qua các lần thay thế không gian nhớ.
3. **Hệ thống phân phối tín hiệu Kernel (`ksignal` & `sigdeliver`):**
   - Hỗ trợ gửi tín hiệu theo nhóm: Nếu tham số truyền vào là `-pgid`, duyệt bảng tiến trình và phát tín hiệu cho mọi tiến trình thuộc nhóm.
   - Thức tỉnh tiến trình đang `SLEEPING` nếu nhận được tín hiệu cần xử lý hoặc `SIGCONT`.
4. **Cài đặt điểm dừng an toàn `stopcheck()` (Anti-Deadlock):**
   - **Vấn đề cốt lõi:** Tuyệt đối không cho phép tiến trình chuyển sang `STOPPED` khi đang nắm giữ các spinlock/sleeplock trong kernel (ví dụ: `pipe_lock`, `inode_lock`), vì sẽ dẫn đến tê liệt toàn hệ thống.
   - **Giải pháp:** Chỉ cho phép dừng tại các điểm an toàn: trước khi trả quyền về User Space ở cuối hàm `usertrap()`, hoặc tại các điểm chờ đọc I/O (`consoleread`, `piperead`, `pause`).
   - **Đồng bộ khóa:** Tuân thủ chặt chẽ thứ tự lấy khóa: `acquire(&wait_lock)` -> đánh thức tiến trình cha `wakeup(p->parent)` -> lấy khóa riêng `acquire(&p->lock)` -> đổi trạng thái thành `STOPPED` -> gọi `sched()`.
5. **Nâng cấp `waitpid()` với cờ `WUNTRACED` và `WNOHANG`:**
   - `WUNTRACED`: Báo cáo cho tiến trình cha ngay khi con bị tạm dừng (`STOPPED`), không chỉ khi con đã chết (`ZOMBIE`).
   - `WNOHANG`: Không block tiến trình cha nếu chưa có tiến trình con nào thay đổi trạng thái, giúp Shell tiếp tục tương tác.
6. **Xử lý tiến trình mồ côi (Orphaned Process Handling):**
   - Khi Group Leader kết thúc, tiến trình con mồ côi chuyển sang làm con của tiến trình `init`.
   - Nếu một nhóm tiến trình mồ côi đang ở trạng thái `STOPPED`, phải tự động gửi `SIGHUP` kèm `SIGCONT` để tránh tiến trình bị kẹt vĩnh viễn trong RAM.

---

### 3.3. Nguyễn Tuấn Anh — Phụ trách Shell, Job Control & Automated Testing

- **Phân hệ:** Trình thông dịch dòng lệnh (User Space Shell), quản lý tác vụ nền/tiền cảnh và bộ công cụ kiểm thử tự động.
- **Mục tiêu kỹ thuật:** Xây dựng Shell xv6 có đầy đủ tính năng Job Control tương tự Bash, giao diện soạn thảo dòng lệnh thân thiện và phát triển bộ kiểm thử tự động kiểm tra tính đúng đắn của toàn bộ đồ án.
- **Danh sách tập tin phụ trách:**
  - `user/sh.c`: Cấu trúc bảng Job, phân tích câu lệnh, các lệnh nội tại (`jobs`, `fg`, `bg`), điều phối pipeline, Line Editor và lịch sử lệnh.
  - `user/ulib.c`: Các hàm thư viện bổ trợ (`tcsetattr`, `tcgetattr`, `tcsetpgrp`, `tcgetpgrp`).
  - `user/ttydemo.c`: Chương trình minh họa 3 chế độ TTY phục vụ báo cáo tuần 2.
  - `user/counter.c` & `user/spin.c`: Các chương trình mẫu chiếm CPU và in số phục vụ demo `Ctrl-C`, `Ctrl-Z`, `fg`, `bg`.
  - `test-jobctl.py`: Kịch bản kiểm thử tự động sử dụng thư viện Python `pexpect`.
  - `test-xv6.py`: Kịch bản chạy bộ kiểm thử hồi quy `usertests` của xv6 gốc.

#### Nhiệm vụ cụ thể:
1. **Thiết kế Bảng quản lý Job (`Job Table`):**
   - Định nghĩa cấu trúc `job_t` gồm: `job_id` (số thứ tự %1, %2), `pgid` (nhóm tiến trình), `state` (`FOREGROUND`, `BACKGROUND`, `STOPPED`), `char cmd[64]` (tên dòng lệnh).
   - Quản lý danh sách tối đa 16 Jobs đồng thời trong Shell.
2. **Cài đặt các lệnh nội tại (Built-in Commands):**
   - `jobs`: Liệt kê tất cả các job hiện có kèm trạng thái (`Running`, `Stopped`) và tên lệnh.
   - `fg [%n]`: Chuyển job thứ `n` lên tiền cảnh, bàn giao quyền terminal qua `ioctl(TIOCSPGRP)`, gửi `SIGCONT` nếu job đang dừng, và gọi `waitpid()` chờ job.
   - `bg [%n]`: Gửi `SIGCONT` để đánh thức job thứ `n` chạy tiếp dưới nền (`Background`), in trạng thái ra màn hình.
   - `kill %n`: Gửi tín hiệu kết thúc tới toàn bộ Process Group của job tương ứng.
3. **Thực thi lệnh nền với toán tử `&`:**
   - Khi lệnh có ký tự `&`, Shell không gọi `waitpid()` chờ đợi mà lập tức in mã `[job_id] pgid` và trả lại dấu nhắc lệnh `$` cho người dùng.
4. **Giải quyết Race Condition giữa Shell và Process Con:**
   - **Vấn đề:** Tiến trình cha (Shell) và tiến trình con sinh ra từ `fork()` chạy đồng thời. Nếu con gọi lệnh terminal trước khi cha kịp đặt `setpgid()`, hoặc ngược lại, sẽ dẫn đến sai lệch `fgpgid`.
   - **Giải pháp:** Cả cha và con đều chủ động gọi `setpgid(pid, pgid)` ngay sau khi `fork()` trước khi con chạy `exec()`, triệt tiêu hoàn toàn race condition.
5. **Điều phối Pipeline thành 1 Job thống nhất:**
   - Với lệnh ghép ống như `counter | cat`: Cả hai tiến trình đều phải được gắn chung một `pgid` duy nhất (lấy PID của tiến trình đầu tiên làm `pgid`).
   - Khi nhấn `Ctrl-Z` hay `Ctrl-C`, cả `counter` và `cat` cùng nhận tín hiệu và dừng/kết thúc đồng loạt, không để sót tiến trình rác.
6. **Xây dựng Line Editor & Lịch sử lệnh (Command History):**
   - Chuyển terminal sang Raw Mode khi đọc dòng lệnh.
   - Bắt các mã Escape Sequence (`\033[A`, `\033[B`, `\033[C`, `\033[D`) để điều hướng phím mũi tên lên/xuống (duyệt lịch sử lệnh) và trái/phải (chèn/sửa ký tự giữa dòng).
7. **Phát triển hệ thống Automated Test (`test-jobctl.py`):**
   - Xây dựng 12 kịch bản tự động hóa bằng Python `pexpect` mô phỏng phím bấm người dùng:
     - `TC-01`: Thoát chương trình tiền cảnh bằng `Ctrl-C`.
     - `TC-02`: Tạm dừng tiến trình bằng `Ctrl-Z` và kiểm tra lệnh `jobs`.
     - `TC-03`: Đưa tiến trình chạy nền tiếp tục bằng lệnh `bg`.
     - `TC-04`: Đưa tiến trình trở lại tiền cảnh bằng `fg` và tiếp tục nhận tín hiệu.
     - `TC-05`: Quản lý Pipeline như một Job thống nhất (`counter | cat`).
     - `TC-06`: Background Job cố đọc terminal bị chặn bởi `SIGTTIN`.
     - `TC-07` đến `TC-12`: Kiểm tra lệnh `kill %n`, nhiều tiến trình đồng thời, phục hồi terminal mode, và Multi-TTY.
   - Tích hợp kiểm tra hồi quy `usertests` đảm bảo xv6 gốc không bị hỏng chức năng cũ.

---

## 4. Kế hoạch phối hợp & Phân công theo tiến độ 7 tuần

| Tuần | Mục tiêu chính | Nhiệm vụ Mai Duy Hiếu | Nhiệm vụ Nguyễn Huy Hoàng | Nhiệm vụ Nguyễn Tuấn Anh | Người chủ trì báo cáo |
|:---:|---|---|---|---|:---:|
| **Tuần 1** | Khảo sát xv6 gốc & Phân tích yêu cầu | Nghiên cứu `console.c`, `uart.c`, luồng nhận phím. Dựng Figma Board. | Khảo sát `proc.c`, `proc.h`, vòng đời tiến trình và luồng trap. | Khảo sát `sh.c`, cơ chế parse/fork/pipe. Lập Trello & Test Matrix 6 test case. | **Mai Duy Hiếu** |
| **Tuần 2** | Thiết kế nền tảng & Cấu trúc dữ liệu | Thiết kế `termios.h`, mở rộng `devsw.ioctl`, viết `sys_ioctl`. Chuẩn bị `ttydemo`. | Mở rộng `struct proc` (`pgid`, `STOPPED`, cờ dừng), viết `setpgid`/`getpgid`. | Thiết kế cấu trúc `job_t` trong Shell, các hàm bọc ulib (`tcsetattr`, `tcsetpgrp`). | **Nguyễn Huy Hoàng** |
| **Tuần 3** | Xử lý tín hiệu & Bắt Ctrl-C/Z | Bắt mã ASCII 0x03/0x1A trong `consoleintr()`, phát tín hiệu theo `fgpgid`. | Cài đặt `ksignal()`, `sigdeliver()`, điểm dừng an toàn `stopcheck()` ở `usertrap`. | Cập nhật Shell đón nhận trạng thái tiến trình đơn bị dừng/thoát. | **Nguyễn Huy Hoàng** |
| **Tuần 4** | Hoàn thiện cơ chế Job Control | Cài đặt `TIOCGPGRP`, `TIOCSPGRP`, cơ chế bẫy `SIGTTIN` khi đọc TTY. | Hoàn thiện `sys_waitpid()` với cờ `WUNTRACED` và `WNOHANG`. | Viết hoàn chỉnh các lệnh `jobs`, `fg`, `bg`, `kill %n`, toán tử `&`. | **Nguyễn Tuấn Anh** |
| **Tuần 5** | Pipeline & Xử lý tình huống góc | Khôi phục chế độ TTY khi chuyển foreground/background. | Xử lý dừng cả Process Group, cô lập deadlock, gửi SIGHUP cho tiến trình mồ côi. | Ghép toàn bộ tiến trình trong Pipeline (`p1 \| p2`) vào 1 Job duy nhất. | **Nguyễn Tuấn Anh** |
| **Tuần 6** | Tính năng mở rộng & Automated Test | Hoàn thiện Multi-TTY ảo (NTTY=2), chuyển đổi qua phím `Ctrl-T`. | Rà soát race condition, đồng bộ khóa, tối ưu scheduler khi có tiến trình STOPPED. | Cài đặt Line Editor (phím mũi tên, lịch sử lệnh), chạy và tinh chỉnh bộ 12 test case. | **Mai Duy Hiếu** *(phối hợp Tuấn Anh phần test)* |
| **Tuần 7** | Kiểm thử tổng thể & Nghiệm thu | Kiểm tra hồi quy toàn bộ TTY, hoàn thiện tài liệu kỹ thuật `DESIGN.md`. | Kiểm tra rà soát kernel panic, rò rỉ bộ nhớ, kiểm tra tính toàn vẹn hệ thống. | Chạy toàn bộ suite `test-jobctl.py` + `usertests`, đóng gói slide và kịch bản demo. | **Cả 3 thành viên** |

---

## 5. Quy chuẩn làm việc nhóm & Tiêu chí hoàn thành (Definition of Done)

### 5.1. Quy chuẩn Quản lý Mã nguồn (Git Workflow)
- **Nhánh chính (Main Branch):** `main` và `tty-jobctl` — chỉ merge code khi đã vượt qua biên dịch không cảnh báo và pass các test case liên quan.
- **Quy tắc đặt tên nhánh tính năng:**
  - `feat/tty-<tên-chức-năng>` (Mai Duy Hiếu)
  - `feat/kernel-<tên-chức-năng>` (Nguyễn Huy Hoàng)
  - `feat/shell-<tên-chức-năng>` hoặc `feat/test-<tên-chức-năng>` (Nguyễn Tuấn Anh)
- **Quy tắc Commit Message:** Sử dụng chuẩn Conventional Commits (ví dụ: `feat(kernel): add STOPPED state to procstate`, `fix(tty): prevent sleep in consoleintr context`).

### 5.2. Tiêu chí Hoàn thành Nhiệm vụ (Definition of Done - DoD)
Một nhiệm vụ chỉ được đánh dấu là **Done** khi thỏa mãn toàn bộ 4 điều kiện:
1. **Biên dịch sạch sẽ:** Mã nguồn biên dịch qua `make qemu` trên RISC-V GCC không có lỗi và không có cảnh báo (`-Wall -Werror`).
2. **Không phá vỡ chức năng cũ:** Chạy `test-xv6.py usertests` vượt qua các bài kiểm tra cơ bản của xv6.
3. **Có minh chứng kiểm thử:** Được xác nhận bởi ít nhất 1 test case tương ứng trong `test-jobctl.py` hoặc log chạy thực tế trên QEMU.
4. **Code Review chéo:** Ít nhất 1 thành viên khác trong nhóm xem qua và xác nhận giao diện kết nối giữa các tầng không bị xung đột.

### 5.3. Quy trình Chuẩn bị Báo cáo Hàng tuần với Giảng viên
- **Thứ Sáu hàng tuần:** Chốt các hạng mục kỹ thuật đã hoàn thành, tổng hợp log kiểm thử và ảnh chụp màn hình QEMU.
- **Thứ Bảy hàng tuần:** Cập nhật bảng Trello, Figma và hoàn thiện file `PROGRESS REPORT.docx` (dung lượng 200–300 từ cho mục tóm tắt theo quy chuẩn của TS. Phạm Văn Tiến).
- **Chủ Nhật / Ngày báo cáo:** Họp nhóm nội bộ 30 phút, chạy thử kịch bản demo trước khi thuyết trình chính thức.

---

> *Bản phân công này là căn cứ chính thức để đánh giá mức độ đóng góp cá nhân (Personal Contribution) và nghiệm thu đồ án Hệ điều hành nhóm 26126.*
