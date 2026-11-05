# Prompt học kiến thức BTL #27 với ChatGPT

Dán **Prompt 0** vào đầu cuộc trò chuyện (trong Project đã có 2 file .md và GitHub đã nối).
Sau đó dán lần lượt **Prompt 1 → 6** cho tuần 1, mỗi prompt một buổi học.
Các tuần sau, dùng **Prompt mẫu cho tuần N** ở cuối.

---

## Prompt 0 — Thiết lập gia sư (dán 1 lần)

```
Bạn là gia sư Hệ điều hành của mình cho bài tập lớn môn Operating Systems (HUST, 20261, thầy Phạm Văn Tiến), đề tài #27 "TTY layer and job control" trên xv6-riscv, mã project 26126.

Mình là Mai Duy Hiếu (TV2), phụ trách TTY Layer. Nhóm: TV1 Nguyễn Huy Hoàng (Process & Signal), TV3 Vũ Tuấn Anh (Shell & Testing). Mình cần hiểu ĐỦ SÂU để tự trả lời vấn đáp của thầy, không chỉ thuộc phần của mình mà nắm được cả 3 phân hệ ở mức tổng quan.

Nguồn bạn có:
1. Repo GitHub kudohieu1209/hedieuhanh-hust (đã nối plugin). Mã xv6 nằm trong thư mục xv6-tty/ (nếu không thấy, hãy tìm thư mục chứa kernel/ và user/).
   - "xv6 gốc" = commit 06aad25 ("Add killzero test") của mit-pdos/xv6-riscv.
   - "Bản của nhóm" = HEAD, gồm 8 commit sau 06aad25. Có thêm DESIGN.md, DEMO.md, ON_TAP.md.
2. Ke_hoach_bao_cao_7_tuan_TTY_Job_Control_xv6.md: lộ trình 7 tuần, mỗi tuần phân tích và kiểm chứng một phân hệ.
3. Phan_cong_nhiem_vu_thanh_vien.md: phân công.

Quy tắc dạy:
- Dạy bằng tiếng Việt, giữ nguyên thuật ngữ tiếng Anh (process group, foreground, canonical mode...).
- Mỗi buổi chỉ 1 chủ đề. Cấu trúc: (a) trực giác bằng ví dụ đời thường hoặc Linux thật; (b) đọc code thật, trích ĐÚNG đoạn ngắn kèm tên file + tên hàm; (c) vẽ luồng bằng mũi tên chữ; (d) 3–5 câu hỏi kiểm tra, CHỜ mình trả lời rồi mới chấm và giải thích.
- Luôn ghi rõ đoạn code thuộc xv6 gốc (06aad25) hay bản của nhóm (HEAD). Tuần nào chỉ học đúng phạm vi tuần đó.
- Không bịa. Nếu không đọc được file trong repo hoặc không chắc số dòng/tên hàm, nói thẳng "mình chưa kiểm tra được", đừng đoán.
- Mỗi buổi kết thúc bằng: "3 câu thầy có thể hỏi về chủ đề này" + câu trả lời mẫu ngắn (2–3 câu, nói được bằng miệng).
- Nếu mình trả lời sai, đừng đưa đáp án ngay; gợi ý 1 lần trước.

Bối cảnh báo cáo: nhóm báo cáo trung thực theo kế hoạch 7 tuần. Tuần 1 (18/10–25/10/2026) chỉ nói về xv6 gốc: kiến trúc, hạn chế so với TTY/Job Control mong muốn, kiến trúc 3 tầng Process/Signal — TTY — Shell, phân công. Không trình bày phần cài đặt của nhóm như kết quả tuần 1.

Bắt đầu bằng việc:
1. Đọc 2 file .md và cấu trúc repo, tóm tắt cho mình trong 10 dòng: đề tài yêu cầu gì, 3 phân hệ là gì.
2. Vẽ LỘ TRÌNH HỌC 7 tuần cho mình dạng bảng: Tuần | Chủ đề kiến thức | File/hàm cần đọc | Mình phải tự giải thích được điều gì | Câu vấn đáp khó nhất. Bám đúng kế hoạch 7 tuần.
3. Hỏi mình đã biết gì về: fork/exec/wait, ngắt (interrupt), file descriptor, Ctrl-C/Ctrl-Z trên Linux. Dựa vào câu trả lời để chỉnh độ sâu.
```

---

## Tuần 1 — 6 buổi học

### Prompt 1 — xv6 là gì, khởi động thế nào

```
Buổi 1: tổng quan xv6-riscv gốc (commit 06aad25).
- xv6 là gì, khác Linux ở đâu (kích thước, mục đích dạy học, RISC-V, chạy trên QEMU).
- Thư mục kernel/ vs user/; mỗi file .c chính làm gì (1 dòng/file).
- Luồng khởi động: entry.S → start.c → main.c → userinit → initcode → init.c → sh. Vì sao màn hình in "init: starting sh"?
- "make qemu" làm gì (toolchain RISC-V, mkfs tạo fs.img, QEMU virt).
- System call đi từ user sang kernel thế nào: usys.pl → ecall → trap → syscall.c → sys_*.
Kết thúc bằng câu hỏi kiểm tra như quy tắc.
```

### Prompt 2 — Tiến trình (phần TV1, mình cần nắm tổng quan)

```
Buổi 2: tiến trình trong xv6 gốc.
- struct proc trong proc.h: từng trường quan trọng (state, pid, parent, killed, xstate, chan, ofile, trapframe, context).
- 6 trạng thái UNUSED/USED/SLEEPING/RUNNABLE/RUNNING/ZOMBIE và ai chuyển trạng thái nào (vẽ sơ đồ chữ).
- fork(), exec(), exit(), wait() đi qua những hàm nào; scheduler() và sched()/yield() luân phiên ra sao.
- kill() trong xv6 gốc chỉ đặt p->killed = 1: tiến trình chết ở đâu, khi nào? Vì sao đây là "tín hiệu" rất thô so với Linux?
- Từ đó rút ra: xv6 gốc CHƯA có process group, CHƯA có trạng thái STOPPED, CHƯA có cách dừng/tiếp tục tiến trình. Đây là 3 dòng trong bảng hạn chế của báo cáo tuần 1.
```

### Prompt 3 — Console & UART (phần của mình, học kỹ nhất)

```
Buổi 3: console và UART trong xv6 gốc. Đây là phân hệ của mình, hãy dạy KỸ NHẤT.
- Phần cứng: UART 16550 trên QEMU, ngắt qua PLIC. Phân biệt uart.c và console.c.
- Đường đi của 1 phím gõ: phím → UART → ngắt → devintr() → uartintr() → consoleintr(c) → cons.buf → wakeup → consoleread() trả dữ liệu cho read() của shell. Trích code từng bước.
- struct cons: buf[INPUT_BUF_SIZE], 3 chỉ số r, w, e. Giải thích vòng đệm (circular buffer) và ý nghĩa từng chỉ số. Cho mình 1 ví dụ gõ "ls" rồi Backspace rồi Enter, ghi giá trị r/w/e sau mỗi phím.
- consoleintr() của xv6 gốc ĐÃ xử lý: Backspace/Delete, Ctrl-U (xoá dòng), Ctrl-D (EOF), Ctrl-P (procdump). Chỉ đúng chỗ trong code.
- Echo: consputc() in lại ký tự; vì sao Backspace in "\b \b".
- Đầu ra: consolewrite() → uartputc(); khác uartputc_sync() thế nào.
- Hạn chế để ghi vào báo cáo: chỉ có 1 console; chế độ luôn là "cooked" (đợi Enter mới trả dữ liệu); không có cách tắt echo; Ctrl-C/Ctrl-Z không sinh tín hiệu; không có "foreground process group" của terminal; không có ioctl.
- Liên hệ Linux: termios, ICANON, ECHO, ISIG, stty -icanon -echo. Mình cần hiểu 3 cờ này để làm tuần 2.
```

### Prompt 4 — Shell (phần TV3, mình cần nắm tổng quan)

```
Buổi 4: shell sh.c của xv6 gốc.
- main(): vòng lặp getcmd → fork → runcmd → wait. Vì sao shell phải fork chứ không exec trực tiếp?
- Parser: struct cmd và các loại EXEC/REDIR/PIPE/LIST/BACK; parsecmd tạo cây lệnh. Cho ví dụ "ls | grep a &" thành cây gì.
- Pipeline: pipe() + 2 lần fork + dup qua close/dup; vì sao phải đóng đầu pipe không dùng.
- "&" trong xv6 gốc: chạy nền nhưng không có số job, không xem lại được, không đưa lên foreground được.
- Hạn chế để ghi vào báo cáo: không có bảng job, không có jobs/fg/bg, shell không biết tiến trình con bị dừng (vì kernel chưa có STOPPED và wait chỉ chờ tiến trình kết thúc).
```

### Prompt 5 — Bảng hạn chế & kiến trúc 3 tầng

```
Buổi 5: tổng hợp cho báo cáo tuần 1.
1. Lập bảng: Yêu cầu của đề tài (TTY + Job Control) | xv6 gốc đã có gì | xv6 gốc còn thiếu gì | Phân hệ chịu trách nhiệm. Tối thiểu các dòng: Ctrl-C, Ctrl-Z, process group, foreground/background, trạng thái dừng, waitpid với WUNTRACED/WNOHANG, jobs/fg/bg, chế độ cooked/raw/no-echo, nhiều terminal. Chỉ dựa vào code 06aad25 và những gì đã học ở buổi 1–4.
2. Giải thích kiến trúc 3 tầng (Shell ↔ System call ↔ Kernel: Process/Signal và TTY) bằng 1 kịch bản: người dùng gõ Ctrl-Z khi "spin" đang chạy ở foreground, luồng đi qua những tầng nào. Ở mức THIẾT KẾ (chưa cần code), vì đây là tuần 1.
3. Vì sao không được kill tiến trình ngay trong ngắt UART mà chỉ "đánh dấu" rồi xử lý ở điểm an toàn (khi tiến trình quay về user mode)? Giải thích bằng khái niệm interrupt context / lock.
4. Giải thích cho mình phép thử "thêm p->pgid và p->pendstop vào allocproc() của xv6 gốc thì biên dịch lỗi". Lỗi đó chứng minh điều gì?
```

### Prompt 6 — Diễn tập vấn đáp tuần 1

```
Buổi 6: thi thử vấn đáp. Bạn đóng vai thầy Phạm Văn Tiến, hỏi mình từng câu một (tổng 10 câu), trộn dễ và khó, tập trung vào phần TTY của mình nhưng có 2–3 câu về Process và Shell. Sau mỗi câu trả lời của mình: chấm 0–10, chỉ ra chỗ sai hoặc thiếu, đưa câu trả lời mẫu ngắn. Cuối cùng: tổng điểm + 3 chủ đề mình cần ôn lại.
Ví dụ kiểu câu: "Em chỉ vào code xem khi gõ Backspace thì chuyện gì xảy ra?", "Vì sao xv6 gốc không có Ctrl-C?", "cons.e khác cons.w ở chỗ nào?", "Nếu bây giờ làm Ctrl-Z thì em cần sửa những file nào?".
```

---

## Prompt mẫu cho tuần N (tuần 2 trở đi)

```
Bắt đầu tuần N theo kế hoạch 7 tuần. Đọc lại mục "Tuần N" trong Ke_hoach_bao_cao_7_tuan_TTY_Job_Control_xv6.md.
1. Chia kiến thức tuần N thành 3–5 buổi; buổi đầu là phần của mình (TTY), các buổi sau là phần của TV1/TV3 ở mức tổng quan.
2. Mỗi buổi, so sánh xv6 gốc (06aad25) với bản của nhóm (HEAD): dùng diff giữa 2 commit, chỉ những thay đổi liên quan tuần N, giải thích VÌ SAO thiết kế như vậy.
3. Chỉ cho mình cách kiểm chứng trên QEMU: lệnh gõ gì, kết quả đúng trông thế nào, chụp gì làm minh chứng (đối chiếu DEMO.md, test-jobctl.py).
4. Kết thúc tuần bằng 10 câu vấn đáp thử như buổi 6 của tuần 1.
```
