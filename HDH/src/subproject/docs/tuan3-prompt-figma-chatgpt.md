# Prompt ChatGPT vẽ sơ đồ tuần 3 cho Figma

Cách dùng: copy phần trong khung "PROMPT" dán vào ChatGPT. ChatGPT không điều khiển được Figma, nên prompt yêu cầu nó trả **SVG** (dán thẳng vào Figma bằng Ctrl+V, ra vector sửa được) và **Mermaid** (dùng cho FigJam hoặc plugin Mermaid to Figma).

## PROMPT

````
Bạn là chuyên gia thiết kế sơ đồ kỹ thuật. Hãy vẽ giúp mình một "design thinking board" cho báo cáo môn Hệ điều hành (đồ án xv6-riscv, đề tài TTY + Job Control). Sơ đồ mô tả luồng xử lý phím Ctrl-C / Ctrl-Z trong kernel, theo đúng mã nguồn bên dưới.

## Tiêu đề
"Tuần 3: Luồng phím bấm → tín hiệu → trạng thái tiến trình"

## Các bước chính (từ trên xuống dưới, 1 luồng chính)
1. Người dùng bấm Ctrl-C hoặc Ctrl-Z. UART nhận ký tự và gọi consoleintr(c) [kernel/uart.c → kernel/console.c].
2. consoleintr(): nếu cờ ISIG bật và c là ^C hoặc ^Z thì xoá dòng đang gõ dở (t->e = t->w), in "^C" hoặc "^Z", rồi gọi ksignal(-fgpgid, sig).
   - ^C → SIGINT, ^Z → SIGTSTP.
   - Chỉ gửi cho nhóm tiến trình foreground (t->fgpgid).
3. ksignal(-fgpgid, sig) [kernel/proc.c]: duyệt bảng proc[], với mỗi tiến trình có pgid khớp thì giữ p->lock và gọi sigdeliver(p, sig).
4. sigdeliver(p, sig): chỉ ghi nhận, chưa hành động. Rẽ nhánh theo tín hiệu:
   - SIGINT (và tín hiệu mặc định khác): đặt p->killed = sig.
   - SIGTSTP / SIGSTOP / SIGTTIN / SIGTTOU: đặt p->pendstop = sig.
   - SIGCONT: xoá pendstop, nếu đang STOPPED thì chuyển sang RUNNABLE.
   - SIGKILL: đặt killed, STOPPED hoặc SLEEPING chuyển sang RUNNABLE.
   - Nếu tiến trình đang SLEEPING thì đánh thức sang RUNNABLE để nó sớm nhận ra tín hiệu.
5. Tiến trình bị tín hiệu quay về user space qua usertrap() [kernel/trap.c], tại đây có 2 điểm kiểm tra:
   - killed(p) khác 0 → kexit(-1) (nhánh SIGINT: tiến trình thoát).
   - stopcheck() (nhánh Ctrl-Z): nếu pendstop khác 0 và chưa bị kill thì wakeup(parent), đặt stopsig = pendstop, pendstop = 0, state = STOPPED, rồi gọi sched() để nhường CPU.
   - (Ghi chú nhỏ: stopcheck() cũng được gọi trong các chỗ chờ ngắt được: consoleread, pipe, pause, wait.)
6. Shell (user/sh.c) đang chờ trong waitpid(pgid, &status, WUNTRACED). Kernel (kwaitpid trong proc.c) thấy con ở trạng thái STOPPED và stopsig khác 0 → trả về pid và status = (stopsig << 8) | 0x7f, rồi xoá stopsig (mỗi lần dừng chỉ báo một lần).
7. Shell nhận status: tcsetpgrp(0, shell_pgid) để lấy lại terminal, lưu termios của job (tcgetattr), đánh dấu JOB_STOPPED và in "Stopped" (printjob).
   Với nhánh Ctrl-C: tiến trình đã thoát nên waitpid trả về trạng thái thoát do tín hiệu, shell giải phóng job và không in gì thêm.

## Yêu cầu bố cục
- Luồng chính chạy dọc từ trên xuống, các hộp nối bằng mũi tên có nhãn.
- Chia 3 vùng (swimlane) tô màu nền nhạt khác nhau: "Phần cứng / Console" (bước 1-2), "Kernel: tiến trình + tín hiệu" (bước 3-5), "User: shell" (bước 6-7).
- Ở bước 4 và 5 vẽ rẽ nhánh 2 đường song song: nhánh Ctrl-C (SIGINT → killed → kexit) và nhánh Ctrl-Z (SIGTSTP → pendstop → stopcheck → STOPPED). Hai nhánh dùng 2 màu khác nhau (ví dụ đỏ cho Ctrl-C, cam cho Ctrl-Z).
- Bên phải vẽ một khối nhỏ "Máy trạng thái tiến trình": RUNNING → (Ctrl-Z) STOPPED → (SIGCONT) RUNNABLE, và RUNNING → (Ctrl-C) ZOMBIE.
- Mỗi hộp có tên hàm in đậm và đường dẫn file bên dưới bằng chữ nhỏ, xám.
- Hộp lệnh/hàm dùng chữ monospace; chú thích dùng sans-serif. Tiếng Việt cho chú thích, giữ nguyên tên hàm tiếng Anh.
- Nền trắng, đủ lớn để chèn vào Word (tỉ lệ khoảng 16:10 hoặc dọc A4), cỡ chữ tối thiểu 14px.

## Định dạng trả lời (rất quan trọng)
Trả về đúng 3 phần theo thứ tự:
1. Một khối code ```svg``` hoàn chỉnh, hợp lệ (có xmlns, viewBox, dùng <rect>, <text>, <path> và <marker> cho mũi tên, KHÔNG dùng ảnh nhúng, KHÔNG dùng font ngoài). Mình sẽ dán thẳng vào Figma.
2. Một khối code ```mermaid``` (flowchart TD, dùng subgraph cho 3 vùng) cho cùng sơ đồ để mình dùng trong FigJam.
3. Danh sách 5 dòng hướng dẫn chỉnh trong Figma sau khi dán (đổi font, căn lề, đổi màu...).
Không giải thích dài dòng ngoài 3 phần trên.
````

## Sau khi có kết quả

1. Mở board Figma: https://www.figma.com/board/VohV5EoTLyQ9YczJvytmDU
2. Dán SVG (Ctrl+V). Nếu ra FigJam thì dùng Mermaid qua plugin.
3. Chụp sơ đồ, chèn vào mục e của báo cáo tuần 3, xoá dòng ghi chú "Tuấn Anh vẽ sơ đồ tuần 3...".
4. Đối chiếu nhanh với mã nguồn: console.c:334-367, proc.c:671-722, proc.c:799-826, trap.c:80-88, proc.c:441-448, sh.c:283-300.
