/**
 * ============================================================================
 * Học phần: HỆ ĐIỀU HÀNH (OPERATING SYSTEMS) - ĐẠI HỌC BÁCH KHOA HÀ NỘI (HUST)
 * Bài thực hành: Quản lý tiến trình (Process Management)
 * Đề bài: Tiến trình cha gọi tiến trình con phát nhạc (fork - exec - wait).
 *         Sau khi con phát xong, cha phát bảng tin hỏi thăm & đánh giá.
 * ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>
#include <math.h>
#include <stdint.h>
#include <fcntl.h>

#define DEFAULT_WAV_FILE "sample_melody.wav"
#define SAMPLE_RATE 22050
#define PI 3.14159265358979323846

/* Cấu trúc Header chuẩn của file WAV (RIFF Waveform Audio Format) */
#pragma pack(push, 1)
typedef struct {
    char     riff_tag[4];       // "RIFF"
    uint32_t riff_size;         // Kích thước file - 8 byte
    char     wave_tag[4];       // "WAVE"
    char     fmt_tag[4];        // "fmt "
    uint32_t fmt_size;          // 16 cho chuẩn PCM
    uint16_t audio_format;      // 1 = PCM (chưa nén)
    uint16_t num_channels;      // 1 = Mono
    uint32_t sample_rate;       // Tần số lấy mẫu (22050 Hz)
    uint32_t byte_rate;         // sample_rate * num_channels * (bits_per_sample/8)
    uint16_t block_align;       // num_channels * (bits_per_sample/8)
    uint16_t bits_per_sample;   // 16-bit
    char     data_tag[4];       // "data"
    uint32_t data_size;         // Số byte dữ liệu âm thanh
} WavHeader;
#pragma pack(pop)

/* Tần số các nốt nhạc cơ bản (Hz) */
#define NOTE_C4 261.63
#define NOTE_D4 293.66
#define NOTE_E4 329.63
#define NOTE_F4 349.23
#define NOTE_G4 392.00
#define NOTE_A4 440.00
#define NOTE_B4 493.88
#define NOTE_C5 523.25
#define NOTE_REST 0.0

/**
 * Tự động tạo một file nhạc WAV mẫu (Giai điệu vui tươi)
 * Giúp chương trình có thể chạy độc lập mà không cần chuẩn bị file nhạc trước!
 */
int generate_sample_wav(const char *filename) {
    FILE *fp = fopen(filename, "wb");
    if (!fp) {
        perror("Lỗi tạo file WAV mẫu");
        return -1;
    }

    /* Bản nhạc mẫu: Khúc nhạc Ode to Joy (Beethoven) vui nhộn */
    double melody[] = {
        NOTE_E4, NOTE_E4, NOTE_F4, NOTE_G4,
        NOTE_G4, NOTE_F4, NOTE_E4, NOTE_D4,
        NOTE_C4, NOTE_C4, NOTE_D4, NOTE_E4,
        NOTE_E4, NOTE_D4, NOTE_D4, NOTE_REST
    };
    double durations[] = {
        0.25, 0.25, 0.25, 0.25,
        0.25, 0.25, 0.25, 0.25,
        0.25, 0.25, 0.25, 0.25,
        0.35, 0.15, 0.40, 0.10
    };
    int num_notes = sizeof(melody) / sizeof(melody[0]);

    // Tính tổng số mẫu âm thanh (samples)
    uint32_t total_samples = 0;
    for (int i = 0; i < num_notes; i++) {
        total_samples += (uint32_t)(SAMPLE_RATE * durations[i]);
    }

    uint32_t data_size = total_samples * sizeof(int16_t);

    WavHeader header;
    memcpy(header.riff_tag, "RIFF", 4);
    header.riff_size = 36 + data_size;
    memcpy(header.wave_tag, "WAVE", 4);
    memcpy(header.fmt_tag, "fmt ", 4);
    header.fmt_size = 16;
    header.audio_format = 1;
    header.num_channels = 1;
    header.sample_rate = SAMPLE_RATE;
    header.bits_per_sample = 16;
    header.byte_rate = SAMPLE_RATE * 1 * (16 / 8);
    header.block_align = 1 * (16 / 8);
    memcpy(header.data_tag, "data", 4);
    header.data_size = data_size;

    fwrite(&header, sizeof(WavHeader), 1, fp);

    // Ghi dữ liệu sóng hình sin cho từng nốt nhạc
    for (int n = 0; n < num_notes; n++) {
        double freq = melody[n];
        double dur = durations[n];
        int note_samples = (int)(SAMPLE_RATE * dur);

        for (int s = 0; s < note_samples; s++) {
            int16_t sample_val = 0;
            if (freq > 0.0) {
                // Tạo hiệu ứng fade-in & fade-out nhẹ ở đầu/cuối mỗi nốt để tránh tiếng 'tách' (click)
                double envelope = 1.0;
                int attack = SAMPLE_RATE * 0.01;
                int release = SAMPLE_RATE * 0.03;
                if (s < attack) {
                    envelope = (double)s / attack;
                } else if (s > note_samples - release) {
                    envelope = (double)(note_samples - s) / release;
                }

                double t = (double)s / SAMPLE_RATE;
                sample_val = (int16_t)(16000.0 * envelope * sin(2.0 * PI * freq * t));
            }
            fwrite(&sample_val, sizeof(int16_t), 1, fp);
        }
    }

    fclose(fp);
    return 0;
}

/**
 * Hàm hỗ trợ Text-to-Speech (tiến trình phát giọng nói nếu hệ thống hỗ trợ)
 */
void speak_message(const char *text) {
    pid_t tts_pid = fork();
    if (tts_pid == 0) {
        // Chuyển hướng stdout/stderr sang /dev/null để không làm nhiễu console
        int devnull = open("/dev/null", O_WRONLY);
        if (devnull >= 0) {
            dup2(devnull, STDOUT_FILENO);
            dup2(devnull, STDERR_FILENO);
            close(devnull);
        }
        execlp("spd-say", "spd-say", "-t", "female1", "-r", "-10", text, NULL);
        // Nếu không có spd-say, thử espeak
        execlp("espeak", "espeak", text, NULL);
        exit(0);
    } else if (tts_pid > 0) {
        // Chờ giọng nói đọc xong
        waitpid(tts_pid, NULL, 0);
    }
}

/**
 * Thực thi chương trình phát nhạc trong tiến trình con
 */
void play_music_in_child(const char *music_file) {
    printf("\n\033[1;36m[TIẾN TRÌNH CON - PID: %d, PPID (Cha): %d]\033[0m\n", getpid(), getppid());
    printf("🎵 Đang khởi chạy trình phát nhạc với tệp: '%s'...\n", music_file);
    fflush(stdout);

    // Thử lần lượt các công cụ phát nhạc phổ biến trên Linux
    // 1. aplay (mặc định trên ALSA - hầu hết distro Linux đều có)
    execlp("aplay", "aplay", "-q", music_file, NULL);

    // 2. paplay (PulseAudio)
    execlp("paplay", "paplay", music_file, NULL);

    // 3. canberra-gtk-play
    execlp("canberra-gtk-play", "canberra-gtk-play", "-f", music_file, NULL);

    // 4. ffplay (ffmpeg)
    execlp("ffplay", "ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet", music_file, NULL);

    // 5. mpv
    execlp("mpv", "mpv", "--no-video", music_file, NULL);

    // Nếu tất cả các lệnh exec ở trên đều thất bại:
    fprintf(stderr, "❌ Không tìm thấy trình phát nhạc (aplay, paplay, ffplay...). Vui lòng cài alsa-utils.\n");
    exit(1);
}

int main(int argc, char *argv[]) {
    char music_path[256];

    // Kiểm tra xem người dùng có truyền file nhạc riêng không
    if (argc > 1) {
        strncpy(music_path, argv[1], sizeof(music_path) - 1);
        music_path[sizeof(music_path) - 1] = '\0';
    } else {
        // Nếu không truyền tham số, tự động tạo file WAV giai điệu mẫu
        printf("ℹ️  Không có file nhạc đầu vào. Đang khởi tạo bản nhạc mẫu: %s...\n", DEFAULT_WAV_FILE);
        if (generate_sample_wav(DEFAULT_WAV_FILE) != 0) {
            fprintf(stderr, "Không thể tạo file WAV mẫu!\n");
            return 1;
        }
        strncpy(music_path, DEFAULT_WAV_FILE, sizeof(music_path) - 1);
    }

    printf("\n======================================================================\n");
    printf("   BÀI TẬP TIẾN TRÌNH HỆ ĐIỀU HÀNH: QUẢN LÝ TIẾN TRÌNH CHA - CON\n");
    printf("======================================================================\n");
    printf("\033[1;33m[TIẾN TRÌNH CHA - PID: %d]\033[0m: Chuẩn bị fork() tạo tiến trình con...\n", getpid());

    // 1. TẠO TIẾN TRÌNH CON BẰNG fork()
    pid_t pid = fork();

    if (pid < 0) {
        // fork() thất bại (< 0)
        perror("❌ Lỗi khi thực hiện fork()");
        return 1;
    } 
    else if (pid == 0) {
        // ===================================================================
        // VÙNG THỰC THI CỦA TIẾN TRÌNH CON (CHILD PROCESS)
        // fork() trả về 0 trong không gian nhớ của tiến trình con.
        // ===================================================================
        play_music_in_child(music_path);
        // Lưu ý: Sau execlp(), nếu thành công thì mã code bên dưới sẽ không bao giờ được chạy
        // vì hình ảnh tiến trình (process image) đã bị thay thế hoàn toàn bởi trình phát nhạc.
        exit(0);
    } 
    else {
        // ===================================================================
        // VÙNG THỰC THI CỦA TIẾN TRÌNH CHA (PARENT PROCESS)
        // fork() trả về PID của tiến trình con cho tiến trình cha (> 0).
        // ===================================================================
        printf("\033[1;33m[TIẾN TRÌNH CHA - PID: %d]\033[0m: Đã sinh ra tiến trình con với PID = %d.\n", getpid(), pid);
        printf("\033[1;33m[TIẾN TRÌNH CHA - PID: %d]\033[0m: Đang gọi waitpid() để đợi tiến trình con phát nhạc xong...\n", getpid());
        fflush(stdout);

        // 2. CHA CHỜ CON HOÀN THÀNH BẰNG waitpid()
        int status;
        waitpid(pid, &status, 0);

        printf("\n----------------------------------------------------------------------\n");
        if (WIFEXITED(status)) {
            printf("✅ [HỆ THỐNG]: Tiến trình con (PID: %d) đã kết thúc bình thường (Exit code: %d).\n", 
                   pid, WEXITSTATUS(status));
        } else {
            printf("⚠️  [HỆ THỐNG]: Tiến trình con (PID: %d) kết thúc bất thường.\n", pid);
        }
        printf("----------------------------------------------------------------------\n");

        // 3. TIẾN TRÌNH CHA PHÁT BẢNG TIN VÀ TƯƠNG TÁC
        printf("\n\033[1;32m======================================================================\n");
        printf("      📢 BẢNG TIN PHÁT THANH TỪ TIẾN TRÌNH CHA (PARENT PID: %d)\n", getpid());
        printf("======================================================================\033[0m\n");
        printf("🔊 \033[1m\"Alo alo! Bản tin thông báo đặc biệt:\033[0m\n");
        printf("   1. Tiến trình vừa rồi nghe có hay không ạ?\n");
        printf("   2. Bản nhạc đã kết thúc, xin vui lòng quay về học phần Hệ Điều Hành!\n");
        printf("   3. Quý vị chấm điểm tiến trình vừa rồi mấy sao (1 đến 5 sao)?\"\n");
        printf("\033[1;32m======================================================================\033[0m\n\n");

        // Phát âm thanh giọng nói qua loa (nếu có spd-say trên Linux)
        speak_message("Tien trinh phat nhac da xong. Xin moi quay ve hoc phan he dieu hanh!");

        // Nhận đánh giá từ người dùng
        int rating = 0;
        printf("👉 Xin mời nhập số sao đánh giá (từ 1 đến 5): ");
        if (scanf("%d", &rating) == 1) {
            printf("\n\033[1;35m[PHẢN HỒI TỪ TIẾN TRÌNH CHA]:\033[0m\n");
            switch (rating) {
                case 5:
                    printf("⭐⭐⭐⭐⭐ Tuyệt vời! Hệ thống không xảy ra Zombie hay Orphan process, context switch hoàn hảo! Điểm A+ môn Hệ Điều Hành!\n");
                    break;
                case 4:
                    printf("⭐⭐⭐⭐ Rất tốt! CPU Scheduler đã lập lịch mượt mà cho tiến trình phát nhạc.\n");
                    break;
                case 3:
                    printf("⭐⭐⭐ Tạm ổn! Cần tối ưu lại IPC (Inter-Process Communication) để âm thanh sống động hơn.\n");
                    break;
                case 1:
                case 2:
                    printf("⭐ Có vẻ tiến trình đã bị Starvation hoặc Deadlock trong lòng bạn rồi! Hãy ôn tập kỹ lại chương Process & Synchronization nhé!\n");
                    break;
                default:
                    printf("🌟 Điểm số lạ mắt (%d sao)! Cảm ơn bạn đã trải nghiệm mô hình fork - exec - wait.\n", rating);
                    break;
            }
        }

        printf("\n\033[1;33m[TIẾN TRÌNH CHA - PID: %d]\033[0m: Hoàn thành nhiệm vụ, tiến trình cha kết thúc an toàn. Bye bye!\n\n", getpid());
    }

    return 0;
}
