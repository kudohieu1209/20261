# 2026.1

Thư mục làm việc của học kỳ **2026.1** tại Đại học Bách khoa Hà Nội (HUST). Gồm tài liệu và bài tập các môn, các đồ án, và ứng dụng **Planner** dùng để xếp lịch học và theo dõi tiến độ cả kỳ.

- Học kỳ: tuần 1 bắt đầu **31/08/2026**, tuần 18 kết thúc **03/01/2027**.
- Múi giờ: Việt Nam (UTC+7).
- Lịch học, việc cần làm và lộ trình ôn tập đang dùng: [LICH_HOC_VA_CONG_VIEC.md](LICH_HOC_VA_CONG_VIEC.md).

## Cấu trúc thư mục

| Thư mục | Nội dung |
| --- | --- |
| [Planner/](Planner/) | Ứng dụng lập lịch cá nhân: web, Android, Firebase và dữ liệu kế hoạch |
| [DA1/](DA1/) | Đồ án 1: HUST Course Advisor (chatbot RAG và kiểm tra tiến độ tốt nghiệp) |
| [DA2/](DA2/) | Đồ án 2: hệ thống giám sát nhiệt độ ATmega16 + DHT11, có LCD và cảnh báo LED |
| [HDH/](HDH/) | Hệ điều hành (ET4291): slide, ghi chú, bài thực hành và dự án xv6-tty |
| [CSTSL/](CSTSL/) | Cơ sở truyền số liệu (ET4070): slide, đề cuối kỳ, bài tổng hợp lý thuyết hàng đợi |
| [VLDT/](VLDT/) | Vật lý điện tử: slide, bài tập, lời giải, đề giữa kỳ và cuối kỳ |
| [GPLX/](GPLX/) | Ôn lý thuyết giấy phép lái xe: bộ 600 câu, biển báo, app web và Android |
| [TOEIC/](TOEIC/) | App luyện đề TOEIC Listening & Reading (ETS), có bản Android |
| [LICH_HOC_VA_CONG_VIEC.md](LICH_HOC_VA_CONG_VIEC.md) | Lịch học cố định, việc linh hoạt, mẫu tự học và lộ trình từng môn |

Một số thư mục con là git repo riêng, được quản lý độc lập. Thư mục gốc `2026.1/` không phải git repo.

| Thư mục | Remote |
| --- | --- |
| `Planner/` | `github.com/kudohieu1209/personal-planner` |
| `DA2/` | `github.com/kudohieu1209/ET1-DA2` |
| `TOEIC/` | `github.com/kudohieu1209/toeic-test` |
| `DA1/project/` | repo riêng |

## Lịch học cố định

Mỗi buổi giữ thêm 30 phút trước và 30 phút sau để di chuyển.

| Ngày | Môn | Phòng | Giờ | Lặp lại |
| --- | --- | --- | --- | --- |
| Thứ Hai | Đồ án 2 | D8-703 | 15:05–17:30 | Tuần lẻ (11, 13, 15, 17) |
| Thứ Ba | Hệ điều hành — ET4291 | D9-304 | 12:30–15:50 | Hằng tuần |
| Thứ Tư | Cơ sở truyền số liệu — ET4070 | D9-303 | 15:05–17:30 | Hằng tuần |
| Thứ Sáu | Vật lý điện tử | D9-502 | 12:30–14:55 | Hằng tuần |

Chi tiết và các thay đổi theo tuần nằm trong [LICH_HOC_VA_CONG_VIEC.md](LICH_HOC_VA_CONG_VIEC.md).

## Ứng dụng Planner

Planner xếp lịch học trên trường, khung sinh hoạt và các buổi tự học, rồi theo dõi tiến độ. Có bản web, bản Android kèm widget màn hình chính, và đồng bộ qua Firebase.

```text
Planner/
├── web/        React 19 + Vite + Tailwind CSS 4 + TypeScript, Firebase Auth/Firestore
├── android/    Kotlin + Jetpack Compose, có widget
├── firebase/   firebase.json, Firestore rules và indexes
├── data/       Dữ liệu dùng chung web/Android: lịch mẫu, mẫu tự học, kế hoạch GPLX/HĐH
├── docs/       Hướng dẫn cài đặt, kết quả kiểm thử, ghi chú theo ngày
├── design/     Icon và tài nguyên thương hiệu
└── release/    File APK đã build
```

### Chạy bản web

```bash
cd Planner/web
npm install
npm run dev        # http://localhost:5173
npm test           # unit test phần lõi (scheduler, state, plan...)
npm run test:e2e   # Playwright
npm run build      # kết quả trong Planner/web/dist/
```

Biến môi trường Firebase: sao chép `Planner/web/.env.example` thành `.env.local` rồi điền thông tin dự án.

### Build bản Android

```powershell
Planner\android\build-local.ps1                  # mặc định :app:assembleDebug
Planner\android\build-local.ps1 :app:testDebugUnitTest
```

Script đặt `GRADLE_USER_HOME` vào `2026.1/.gradle-user-home` để dùng chung cache Gradle với GPLX và TOEIC. Bản Android đọc trực tiếp các file trong `Planner/data/`, nên web và Android dùng cùng một nguồn kế hoạch.

### Triển khai Firebase

```bash
cd Planner/firebase
firebase use --add <PROJECT_ID>
firebase deploy
```

Hướng dẫn đầy đủ: [Planner/docs/HUONG_DAN_CAI_DAT_VA_SU_DUNG.md](Planner/docs/HUONG_DAN_CAI_DAT_VA_SU_DUNG.md).

### Cập nhật kế hoạch theo môn

Các file `Planner/data/*_plan_*.json` được sinh từ script Python cùng thư mục, ví dụ:

```bash
python Planner/data/build_gplx_plan.py
python Planner/data/build_hdh_plan.py
```

App bổ sung kế hoạch mới khi mở, và giữ nguyên các buổi đã sửa, dời, xóa hoặc đã hoàn thành.

## Ghi chú

- Không đưa dữ liệu cá nhân lên git. `Planner/artifacts/backups/` và các bản sao database từ điện thoại đã nằm trong `.gitignore`.
- `firebase-debug.log` ở thư mục gốc là log do Firebase CLI tự sinh, có thể xóa.
