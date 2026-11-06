# Tuần 3–7: việc còn lại (cập nhật 07/11/2026)

Báo cáo tuần 3–7 đã có phần chữ (`PROGRESS REPORT tuần 3.docx` … `tuần 7.docx`). Kết quả test trong báo cáo là chạy thật ngày 07/11, tất cả đều đạt. Mỗi file còn **5–6 dòng tô vàng**: thay bằng ảnh thật rồi xoá dòng tô vàng đó.

## 1. Việc làm một lần (Hiếu, hôm nay)

### 1a. Push hai repo (đã commit sẵn trên `main` ở máy Hiếu)

```bash
cd ~/…/HDH/src/subproject/xv6-tty && git push origin main     # sửa CI: clang-format + spin.c
cd ../web && git push origin main                              # web: báo cáo 7 tuần, kiến thức, sửa dữ liệu
```

Sau khi push:
- Mở https://github.com/kudohieu1209/hedieuhanh-hust/actions và chờ khoảng 5–10 phút. Cả **linux** và **macos** phải xanh.
  - Nếu **macos** vẫn đỏ: bấm vào job, chép đoạn lỗi gửi Claude. Phần macOS mình chỉ sửa theo kế hoạch (lỗi `spin.c`), không chạy thử được trên macOS.
- Mở https://github.com/kudohieu1209/hedieuhanh-web/actions, chờ deploy xong rồi mở web. Ở trang **Lộ trình 7 tuần** phải thấy nút "Tải báo cáo tuần N (.docx)".

### 1b. Không cần làm gì với Supabase

Project Supabase trong `.env` không còn tồn tại (tên miền không phân giải được), nên web đang chạy ở chế độ Demo và lấy dữ liệu trong mã. Nếu sau này muốn 3 người đồng bộ dữ liệu: tạo project Supabase mới, chạy `src/supabase/schema.sql` rồi `seed.sql`, và cập nhật secrets `VITE_SUPABASE_URL` / `VITE_SUPABASE_ANON_KEY` của repo web.

## 2. Ảnh minh chứng, mỗi tuần

Chạy trong thư mục `xv6-tty`. Với các ảnh demo, script `chay-demo.py` tự khởi động xv6, tự gõ phím, rồi dừng lại để bạn chụp:

```bash
python3 ../docs/minh-chung/chay-demo.py            # xem danh sách kịch bản
python3 ../docs/minh-chung/chay-demo.py t3-demo    # chạy 1 kịch bản → chụp → Enter để tắt
```

| Tuần | Mục | Ai | Làm gì |
|---|---|---|---|
| 3 | a, e | Tuấn Anh | Trello tuần 3; sơ đồ Figma tuần 3 |
| 3 | b | Hoàng | `grep -n -A 47 '^sigdeliver' kernel/proc.c` và `grep -n -A 28 '^stopcheck' kernel/proc.c` |
| 3 | c | Hiếu | `python3 test-jobctl.py ctrl` → phải thấy `4/4 tests passed` |
| 3 | d | Hiếu | `chay-demo.py t3-demo` |
| 4 | b | Hoàng | `grep -n -A 75 '^kwaitpid' kernel/proc.c` và `cat kernel/wait.h` |
| 4 | c / d | Tuấn Anh / Hiếu | `chay-demo.py t4-jobs` / `chay-demo.py t4-cat` |
| 5 | b | Hoàng | `grep -n -A 22 '^reparent' kernel/proc.c` |
| 5 | c / d | Tuấn Anh / Hoàng | `chay-demo.py t5-pipe` / `chay-demo.py t5-orphan` |
| 6 | b | Tuấn Anh + Hoàng | `python3 test-jobctl.py` (12/12) và `python3 test-xv6.py -q usertests` (ALL TESTS PASSED) |
| 6 | c / d | Hiếu / Tuấn Anh | `chay-demo.py t6-tty` / `chay-demo.py t6-history` |
| 7 | b | Hoàng | `python3 test-xv6.py usertests` và `python3 test-xv6.py crash` |
| 7 | c | Hiếu + Tuấn Anh | các kịch bản ở trên, hoặc làm tay theo DEMO.md |
| 7 | d | Tuấn Anh | ảnh trang Actions (sau bước 1a); điền ô CI trong bảng 6b |
| 4–7 | a, e | Tuấn Anh | Trello và Figma của tuần đó |

Mỗi tuần chụp ảnh trong đúng tuần đó. Nếu chạy ra khác chú thích (ví dụ pid khác 4), sửa chú thích theo ảnh, đừng chạy lại cho giống.

## 3. Ghép ảnh vào báo cáo

1. Mở file `.docx` bằng Word hoặc LibreOffice, bấm vào dòng tô vàng.
2. Chọn Insert → Picture (Chèn → Ảnh), chọn ảnh, kéo cho vừa chiều ngang trang.
3. Xoá dòng tô vàng.
4. Hoàng và Tuấn Anh đọc lại đoạn "Member" của mình ở mục 3 (viết theo kế hoạch), sai chỗ nào thì sửa.

## 4. Đưa báo cáo lên OneDrive để cả nhóm tải

1. Tải file `.docx` lên OneDrive. Bấm chuột phải vào file → **Share** (Chia sẻ) → đổi quyền thành **Anyone with the link can view** (Bất kỳ ai có liên kết đều xem được) → **Copy link**.
2. Gửi link cho Claude, hoặc tự dán vào `web/src/data/initialWeeks.ts`, mục `REPORT_LINKS` ở đầu file:
   ```ts
   3: 'https://1drv.ms/w/...',
   ```
3. Commit và push repo web. Vercel tự deploy, nút "Xem báo cáo tuần N (OneDrive)" ở trang Lộ trình sẽ mở link đó.

Lưu ý: web giờ **chỉ để xem** (không có đăng nhập, không có máy chủ dữ liệu). Mọi thay đổi (trạng thái tuần, checklist, link, nội dung) đều sửa trong mã nguồn `web/src/data/` rồi commit + push, Vercel tự cập nhật cho cả nhóm.

## 5. Sau khi sửa một file báo cáo: cập nhật nội dung trên web

```bash
cd ~/…/HDH/src/subproject/web
pip install python-docx                        # chỉ lần đầu
python3 scripts/docx2ts.py ../docs src/data/weeklyReports.ts
cp "../docs/PROGRESS REPORT tuần 3.docx" public/reports/progress-report-tuan-3.docx   # đổi số tuần
git add -A && git commit -m "bao cao tuan 3 da nop" && git push
```

Khi nộp xong một tuần, đổi trạng thái tuần đó trong `src/data/initialWeeks.ts`: `status: 'reported'`, đánh dấu `completed: true` cho các mục checklist đã xong, và tăng `currentWeek` / `nextReportDate` trong `src/data/initialSettings.ts`. Nếu thầy có nhận xét thì ghi đúng lời thầy vào `lecturerFeedback`.

## 6. Không bắt buộc

- **Email của Hoàng và Tuấn Anh** trên web đang để trống (`src/data/initialMembers.ts`). Điền nếu muốn.
- **Giao diện mới của tab "Báo cáo (Mẫu Word HUST)"** bị hỏng trong bản sửa dở trước đây nên đang dùng bản cũ. Bản hỏng vẫn còn trong git: `git show 22ac92f:src/components/report/WeeklyProgressReportTab.tsx`.

## Tin nhắn gửi nhóm (tuần 3)

```
Mọi người ơi, báo cáo tuần 3 (01/11 – 08/11) mình soạn xong phần chữ rồi, còn thiếu ảnh. Gửi ảnh vào nhóm trước 12h trưa CN 08/11 giúp mình nhé.

Hoàng (tuần này Hoàng chủ trì trình bày):
- Ảnh b: trong thư mục xv6-tty chạy
    grep -n -A 47 '^sigdeliver' kernel/proc.c
    grep -n -A 28 '^stopcheck' kernel/proc.c
  rồi chụp.
- Chuẩn bị trình bày: sigdeliver chỉ đánh dấu (killed / pendstop), stopcheck dừng ở điểm an toàn, phân biệt SIGINT / SIGTSTP / SIGCONT.

Tuấn Anh:
- Ảnh a: Trello (thẻ tuần 3 sang Đã xong, thêm thẻ tuần 4) rồi chụp.
- Ảnh e: sơ đồ tuần 3 trên Figma: Ctrl-C/Z → consoleintr → ksignal(-fgpgid) → sigdeliver → usertrap: kexit hoặc stopcheck → STOPPED → shell waitpid(WUNTRACED).
- Chuẩn bị giải thích fgjob() và "[1]+ Stopped".

Mình (Hiếu): ảnh c, d, ghép và nộp.
Mọi người đọc lại đoạn "Member" của mình trong báo cáo, sai chỗ nào báo mình nhé.
```
