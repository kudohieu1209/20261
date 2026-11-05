# KẾ HOẠCH BÁO CÁO TIẾN ĐỘ 7 TUẦN

**Đề tài:** Xây dựng TTY Layer và Job Control trên hệ điều hành xv6-riscv  
**Nhóm thực hiện:** 3 thành viên  
**Repository:** https://github.com/kudohieu1209/hedieuhanh-hust  
**Tài liệu tham khảo chính:** `README.md`, `DESIGN.md`, `DEMO.md`

## 1. Mục tiêu chung

Triển khai, tìm hiểu, kiểm chứng và hoàn thiện cơ chế **TTY Layer** và **Job Control** trên xv6-riscv, gồm:

- Các chế độ terminal: Cooked (Canonical), Raw và No-Echo.
- Process Group, tín hiệu và các trạng thái tiến trình như `STOPPED`.
- Foreground/Background Job, các lệnh `jobs`, `fg`, `bg`, `kill %n`.
- Pipeline và điều khiển nhiều tiến trình thuộc cùng một Job.
- Các tính năng mở rộng: lịch sử lệnh, soạn thảo dòng lệnh, Multi-TTY.
- Kiểm thử tự động, kiểm thử tương thích xv6 và hoàn thiện tài liệu.

> **Lưu ý về tiến độ:** Nhóm đã có bản triển khai ban đầu của đề tài. Lộ trình 7 tuần dưới đây là kế hoạch **nghiên cứu, kiểm chứng, sửa lỗi, hoàn thiện và nghiệm thu theo từng phân hệ**, không phải lịch sử cam kết rằng mỗi phần mã nguồn chỉ được viết đúng trong tuần tương ứng. Khi báo cáo, nêu trung thực trạng thái và bằng chứng thực tế tại thời điểm đó.

## 2. Phân công nhiệm vụ theo thành viên

| Thành viên | Mảng phụ trách | Công việc chính | File chủ đạo |
|---|---|---|---|
| **Thành viên 1** | **Process & Signal (Kernel)** | Process Group, `pgid`, `STOPPED`, `setpgid()`, `getpgid()`, `waitpid()`, tín hiệu, scheduler, xử lý orphaned process, các vấn đề đồng bộ | `kernel/proc.c`, `kernel/proc.h`, `kernel/trap.c`, `kernel/sysproc.c`, `kernel/signal.h`, `kernel/wait.h` |
| **Thành viên 2** | **TTY Layer (Kernel)** | Chế độ Cooked/Raw/No-Echo, bộ đệm nhập/xuất, `ioctl()`, Foreground Process Group, Ctrl-C/Z, `SIGTTIN`, Multi-TTY | `kernel/console.c`, `kernel/termios.h`, `kernel/file.c`, `kernel/sysfile.c`, `user/init.c` |
| **Thành viên 3** | **Shell & Testing (User Space)** | Bảng Job, `jobs`, `fg`, `bg`, `kill %n`, pipeline, `&`, history, line editor, demo và kiểm thử tự động | `user/sh.c`, `user/ulib.c`, `user/ttydemo.c`, `user/counter.c`, `user/spin.c`, `test-jobctl.py` |

**Nguyên tắc phối hợp:** Mỗi người chịu trách nhiệm sâu về phân hệ của mình, nhưng tất cả phải hiểu kiến trúc tổng thể và cùng tham gia kiểm thử tích hợp, giải thích được đường đi của một thao tác như `Ctrl-Z` từ terminal đến process và shell.

---

## 3. Kế hoạch chi tiết 7 tuần

### Tuần 1 — Tìm hiểu xv6 và phân tích yêu cầu

**Mục tiêu:** Nắm kiến trúc xv6 gốc, xác định vấn đề cần giải quyết và thiết kế tổng quan của đề tài.

| Thành viên | Nội dung phụ trách |
|---|---|
| 1 | Nghiên cứu vòng đời tiến trình, scheduler, `fork`, `exec`, `wait` trong xv6 gốc. |
| 2 | Nghiên cứu console, UART, cơ chế nhận và xử lý ký tự của xv6 gốc. |
| 3 | Nghiên cứu shell xv6 gốc, pipeline và cơ chế thực thi lệnh. |

**Nội dung báo cáo với giảng viên:**
- Giới thiệu xv6-riscv và mục tiêu của đề tài.
- Đối chiếu các hạn chế của xv6 gốc với TTY và Job Control mong muốn.
- Trình bày sơ đồ kiến trúc tổng quát: Process/Signal — TTY — Shell.
- Nêu phân công thành viên và phương pháp kiểm chứng tiến độ.

**Sản phẩm/bằng chứng:** Bảng yêu cầu, sơ đồ kiến trúc, môi trường phát triển và khả năng khởi động xv6 qua QEMU.

### Tuần 2 — Thiết kế và xây dựng nền tảng

**Mục tiêu:** Làm rõ cấu trúc dữ liệu, system call và giao diện kết nối các phân hệ.

| Thành viên | Nội dung phụ trách |
|---|---|
| 1 | Phân tích `struct proc`, Process Group, `pgid`, `STOPPED`, `setpgid()` và `getpgid()`. |
| 2 | Phân tích `struct tty`, Cooked/Raw/No-Echo, `TCGETS`, `TCSETS`, `ioctl()`. |
| 3 | Phân tích và kiểm chứng thiết kế bảng Job trong Shell: Job ID, PGID, trạng thái và tên lệnh. |

**Nội dung báo cáo với giảng viên:**
- So sánh cấu trúc dữ liệu xv6 gốc và cấu trúc mở rộng.
- Giải thích lý do cần Process Group và biến `fgpgid` của terminal.
- Trình bày đường đi của các system call liên quan.

**Demo/bằng chứng:** `ttydemo` ở các chế độ nhập liệu; kết quả quan sát Process Group nếu phần tích hợp đã ổn định.

### Tuần 3 — Xử lý tín hiệu và Ctrl-C/Ctrl-Z

**Mục tiêu:** Làm rõ cách Kernel chuyển sự kiện bàn phím thành tín hiệu tác động tới tiến trình.

| Thành viên | Nội dung phụ trách |
|---|---|
| 1 | Nghiên cứu/kiểm chứng `sigdeliver()`, `ksignal()`, `stopcheck()`, `SIGINT`, `SIGTSTP`, `SIGCONT`. |
| 2 | Nghiên cứu/kiểm chứng Ctrl-C/Z trong `consoleintr()` và cách gửi tín hiệu tới Foreground Process Group. |
| 3 | Kiểm chứng Shell tương tác với Foreground Job và xử lý trạng thái của lệnh đơn. |

**Nội dung báo cáo với giảng viên:**
- Luồng xử lý: phím bấm → UART/console → Kernel signal → process state.
- Phân biệt kết thúc bởi `SIGINT` và tạm dừng bởi `SIGTSTP`.
- Giải thích vì sao `stopcheck()` thực hiện dừng ở điểm an toàn nhằm hạn chế deadlock.

**Demo/bằng chứng:** Chạy `counter`, nhấn `Ctrl-Z`, quan sát `STOPPED` qua `Ctrl-P`; thử `Ctrl-C` với chương trình tiền cảnh.

### Tuần 4 — Hoàn thiện cơ chế Job Control

**Mục tiêu:** Kiểm chứng luồng điều khiển foreground/background đầy đủ.

| Thành viên | Nội dung phụ trách |
|---|---|
| 1 | Nghiên cứu/kiểm chứng `waitpid()`, `WNOHANG`, `WUNTRACED`, trạng thái dừng và thoát. |
| 2 | Nghiên cứu/kiểm chứng `TIOCGPGRP`, `TIOCSPGRP`, quyền đọc TTY và `SIGTTIN`. |
| 3 | Nghiên cứu/kiểm chứng các lệnh `jobs`, `fg`, `bg`, `kill %n` và chạy nền bằng `&`. |

**Nội dung báo cáo với giảng viên:**
- Phân biệt Process, Process Group và Job.
- Shell trao quyền terminal cho Foreground Job, nhận trạng thái và lấy lại quyền điều khiển ra sao.
- Ý nghĩa của `SIGCONT`, `WUNTRACED`, `WNOHANG`.

**Demo/bằng chứng:**
```text
$ counter
# Ctrl-Z
$ jobs
$ bg
$ jobs
$ fg
# Ctrl-C
```

### Tuần 5 — Pipeline và các trường hợp đặc biệt

**Mục tiêu:** Kiểm chứng khả năng phối hợp nhiều tiến trình và xử lý các tình huống biên.

| Thành viên | Nội dung phụ trách |
|---|---|
| 1 | Kiểm chứng dừng cả Process Group, xử lý tiến trình mồ côi ở trạng thái STOPPED, `SIGHUP` và `SIGCONT`. |
| 2 | Kiểm chứng khôi phục chế độ TTY, xử lý background job cố đọc terminal (`SIGTTIN`). |
| 3 | Kiểm chứng pipeline là một Job, điều phối các tiến trình trong `counter \| cat`. |

**Nội dung báo cáo với giảng viên:**
- Vì sao một pipeline phải được điều khiển như một Job duy nhất.
- Phân tích nguy cơ deadlock khi tiến trình dừng lúc còn giữ khóa.
- Cách xử lý tiến trình mồ côi bị dừng.

**Demo/bằng chứng:**
```text
$ counter | cat
# Ctrl-Z
$ fg
# Ctrl-C

$ cat &
$ jobs
$ fg
```

### Tuần 6 — Tính năng mở rộng và kiểm thử

**Mục tiêu:** Đánh giá tính ổn định và hoàn thiện các tính năng bổ sung.

| Thành viên | Nội dung phụ trách |
|---|---|
| 1 | Rà soát các điểm dừng an toàn, race condition, deadlock; kiểm thử scheduler, process và signal. |
| 2 | Kiểm chứng Multi-TTY, hai shell độc lập, chuyển terminal qua `Ctrl-T`. |
| 3 | Kiểm chứng history, line editor, phím mũi tên; chạy và cải thiện 12 bài test trong `test-jobctl.py`. |

**Nội dung báo cáo với giảng viên:**
- Trình bày tính năng mở rộng và cách chúng được xây dựng.
- Giới thiệu phương pháp kiểm thử và thống kê test pass/fail thực tế.
- Báo cáo các lỗi phát hiện, nguyên nhân, phương án sửa và kiểm thử lại.

**Demo/bằng chứng:** `Ctrl-T` chuyển TTY; điều hướng lịch sử bằng ↑/↓; sửa lệnh bằng ←/→; chạy `python3 test-jobctl.py` từ terminal máy host.

### Tuần 7 — Kiểm thử tổng thể và nghiệm thu

**Mục tiêu:** Xác nhận hệ thống vận hành ổn định trong phạm vi đề tài và tổng kết kết quả.

| Thành viên | Nội dung phụ trách |
|---|---|
| 1 | Kiểm tra lại Process/Signal, trạng thái biên, hồi quy và các vấn đề đồng bộ. |
| 2 | Kiểm tra TTY, Multi-TTY, cơ chế chuyển foreground và lỗi tích hợp. |
| 3 | Hoàn thiện bộ test, CI, tài liệu thiết kế, hướng dẫn chạy và kịch bản demo. |

**Cả nhóm cùng thực hiện:**
- Chạy kiểm thử Job Control và kiểm thử tương thích xv6 gốc.
- Kiểm tra việc biên dịch và trạng thái GitHub Actions.
- Chuẩn bị slide, chia thời lượng thuyết trình, luyện demo và trả lời phản biện.
- Tổng hợp hạn chế kỹ thuật và hướng phát triển tiếp theo.

**Sản phẩm/bằng chứng:** Bản mã nguồn nghiệm thu, kết quả kiểm thử có log, báo cáo cuối kỳ, slide và demo tổng thể.

---

## 4. Phân công trình bày trước giảng viên

| Tuần | Người chủ trì | Nội dung trình bày trọng tâm |
|---|---|---|
| 1 | Thành viên 2 | Kiến trúc tổng thể, TTY/console gốc và yêu cầu đề tài |
| 2 | Thành viên 1 | Nền tảng Process, Process Group, cấu trúc dữ liệu |
| 3 | Thành viên 1 | Signals, xử lý Ctrl-C/Z và điểm dừng an toàn |
| 4 | Thành viên 3 | Job Control, `jobs`, `fg`, `bg` |
| 5 | Thành viên 3 | Pipeline, background và phối hợp đa tiến trình |
| 6 | Thành viên 2 | Multi-TTY và tính năng mở rộng, phối hợp với thành viên 3 phần test |
| 7 | Cả 3 | Tổng kết, demo, kiểm thử, phản biện |

Người chủ trì trình bày phần chính; các thành viên khác cập nhật ngắn phần liên quan và cùng trả lời câu hỏi tích hợp.

## 5. Tiêu chí hoàn thành mỗi tuần

Mỗi tuần nên có tối thiểu:

1. **Nội dung đã hiểu:** Sơ đồ, thuật ngữ và nguyên lý kỹ thuật có thể giải thích được.
2. **Bằng chứng từ mã nguồn:** Danh sách hàm/file đã đọc, liên kết tới commit hoặc đoạn code có liên quan.
3. **Demo hoặc kiểm thử:** Lệnh chạy, dữ liệu quan sát được, kết quả pass/fail thật.
4. **Vấn đề còn tồn tại:** Bug, rủi ro, việc cần xử lý tuần tiếp theo.
5. **Phần phụ trách của từng người:** Nhiệm vụ hoàn tất và nhiệm vụ cần phối hợp.

### Các điểm cần ưu tiên kiểm chứng trước nghiệm thu

- Khắc phục lỗi định dạng `clang-format` làm Linux CI thất bại.
- Khắc phục lỗi `user/spin.c` bị cảnh báo `unused-but-set-variable` khi build với `-Werror` trên macOS.
- Bổ sung bộ `test-jobctl.py` vào quy trình CI nếu môi trường hỗ trợ.
- Chạy lại `test-xv6.py usertests` và các kịch bản kiểm thử Job Control.
- Đồng bộ tài liệu với nhánh Git thực tế và kết quả kiểm thử hiện tại.

> Chỉ báo cáo một tính năng hoặc test **đã hoàn thành/đã PASS** khi có bằng chứng thực tế. Không cần tạo lịch sử commit giả để khớp với 7 tuần; lịch trình phản ánh quá trình nhóm nghiên cứu và nghiệm thu trên bản triển khai sẵn có.

## 6. Tài liệu trong repository

- [README.md](https://github.com/kudohieu1209/hedieuhanh-hust/blob/main/README.md) — Tổng quan, chức năng, hướng dẫn chạy.
- [DESIGN.md](https://github.com/kudohieu1209/hedieuhanh-hust/blob/main/DESIGN.md) — Kiến trúc kỹ thuật, cấu trúc dữ liệu, Signal, TTY và Shell.
- [DEMO.md](https://github.com/kudohieu1209/hedieuhanh-hust/blob/main/DEMO.md) — Kịch bản trình diễn.
- [test-jobctl.py](https://github.com/kudohieu1209/hedieuhanh-hust/blob/main/test-jobctl.py) — Kiểm thử tự động cho Job Control.
- [GitHub Actions](https://github.com/kudohieu1209/hedieuhanh-hust/actions) — Theo dõi kiểm thử và build CI.
