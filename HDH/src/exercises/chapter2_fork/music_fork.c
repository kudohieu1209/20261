/*
 * music_fork.c - Tiến trình cha tạo tiến trình con để phát nhạc,
 * chờ con phát xong rồi đọc bản tin và xin khán giả chấm điểm.
 *
 * Minh họa fork() - exec() - wait() của Chương 2 (slide 28-29).
 *
 * Biên dịch: gcc -Wall -o music_fork music_fork.c -lm
 * Chạy:      ./music_fork               (phát bài "Kìa con bướm vàng" tự tổng hợp)
 *            ./music_fork bai_hat.wav   (phát file nhạc của bạn)
 *
 * Cần: pw-play (hoặc aplay) để phát nhạc, spd-say để đọc tiếng Việt.
 */
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#define SAMPLE_RATE  44100
#define BEAT_SEC     0.5                          // 1 phách = 0.5 giây (120 BPM)
#define DEFAULT_SONG "/tmp/kia_con_buom_vang.wav"

// Tần số các nốt (Hz)
#define G3 196.00
#define C4 261.63
#define D4 293.66
#define E4 329.63
#define F4 349.23
#define G4 392.00
#define A4 440.00

struct note {
    double freq;
    double beats;
};

// Kìa con bướm vàng (giai điệu Frère Jacques)
static const struct note song[] = {
    {C4, 1}, {D4, 1}, {E4, 1}, {C4, 1},   {C4, 1}, {D4, 1}, {E4, 1}, {C4, 1},
    {E4, 1}, {F4, 1}, {G4, 2},            {E4, 1}, {F4, 1}, {G4, 2},
    {G4, .5}, {A4, .5}, {G4, .5}, {F4, .5}, {E4, 1}, {C4, 1},
    {G4, .5}, {A4, .5}, {G4, .5}, {F4, .5}, {E4, 1}, {C4, 1},
    {C4, 1}, {G3, 1}, {C4, 2},            {C4, 1}, {G3, 1}, {C4, 2},
};
#define SONG_LEN (sizeof(song) / sizeof(song[0]))

static const char *news[] = {
    "Tiến trình vừa rồi có hay không?",
    "Giờ giải lao đã hết, vui lòng quay về học phần Hệ điều hành.",
    "Bản tin hệ điều hành: tiến trình con đã hoàn thành và được cha thu hồi, không có zombie nào được tạo ra.",
    "Nhắc bài: fork trả về không ở tiến trình con, và trả về PID của con ở tiến trình cha.",
};
#define NEWS_LEN (sizeof(news) / sizeof(news[0]))

static void put16(FILE *f, uint16_t v) { fwrite(&v, sizeof(v), 1, f); }
static void put32(FILE *f, uint32_t v) { fwrite(&v, sizeof(v), 1, f); }

// Tổng hợp bài hát thành file WAV (PCM 16-bit, mono)
static int write_song(const char *path)
{
    uint32_t total = 0;
    for (size_t i = 0; i < SONG_LEN; i++)
        total += (uint32_t)(song[i].beats * BEAT_SEC * SAMPLE_RATE);

    FILE *f = fopen(path, "wb");
    if (!f)
        return -1;

    // Header WAV
    fwrite("RIFF", 1, 4, f);
    put32(f, 36 + total * 2);
    fwrite("WAVEfmt ", 1, 8, f);
    put32(f, 16);               // kích thước khối fmt
    put16(f, 1);                // PCM
    put16(f, 1);                // mono
    put32(f, SAMPLE_RATE);
    put32(f, SAMPLE_RATE * 2);  // byte rate
    put16(f, 2);                // block align
    put16(f, 16);               // bits per sample
    fwrite("data", 1, 4, f);
    put32(f, total * 2);

    // Mỗi nốt: sóng sin + họa âm bậc 2, vào nhanh rồi tắt dần để các nốt tách nhau
    for (size_t i = 0; i < SONG_LEN; i++) {
        uint32_t len = (uint32_t)(song[i].beats * BEAT_SEC * SAMPLE_RATE);
        for (uint32_t t = 0; t < len; t++) {
            double x = 2 * M_PI * song[i].freq * t / SAMPLE_RATE;
            double env = fmin(1.0, t / 441.0) * (1.0 - (double)t / len);
            int16_t s = (int16_t)(12000 * env * (0.7 * sin(x) + 0.3 * sin(2 * x)));
            put16(f, (uint16_t)s);
        }
    }

    return fclose(f);
}

// Tiến trình con: thay mình bằng chương trình phát nhạc
static void child_play(const char *file)
{
    printf("[Con %d] Cha của mình là %d. Bắt đầu phát: %s\n", getpid(), getppid(), file);
    fflush(stdout);

    execlp("pw-play", "pw-play", file, (char *)NULL);
    // exec chỉ trả về khi lỗi -> thử trình phát khác
    execlp("aplay", "aplay", "-q", file, (char *)NULL);

    perror("exec");
    _exit(127);
}

// Cha "nói" bằng cách tạo thêm một tiến trình con chạy spd-say (giọng tiếng Việt)
static void say(const char *msg)
{
    printf("[Cha %d] 📢 %s\n", getpid(), msg);
    fflush(stdout);

    pid_t pid = fork();
    if (pid == 0) {
        execlp("spd-say", "spd-say", "-o", "espeak-ng", "-l", "vi", "-w", msg, (char *)NULL);
        _exit(127);  // không có spd-say thì chỉ in chữ
    }
    if (pid > 0)
        waitpid(pid, NULL, 0);
}

int main(int argc, char *argv[])
{
    const char *file = argc > 1 ? argv[1] : DEFAULT_SONG;

    if (argc == 1 && write_song(file) != 0) {
        perror(file);
        return 1;
    }

    printf("[Cha %d] Tạo tiến trình con để phát nhạc...\n", getpid());
    fflush(stdout);  // xả buffer trước fork, tránh con in lặp lại

    pid_t pid = fork();
    if (pid < 0) {
        perror("fork");
        return 1;
    }
    if (pid == 0)
        child_play(file);  // không bao giờ quay về

    // Tiến trình cha: chờ con phát xong (nếu không wait, con sẽ thành zombie)
    printf("[Cha %d] Đã tạo con PID = %d, đang chờ con phát xong...\n", getpid(), pid);
    fflush(stdout);

    int status;
    waitpid(pid, &status, 0);
    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        printf("[Cha %d] Con %d phát nhạc thất bại (status %d).\n",
               getpid(), pid, WIFEXITED(status) ? WEXITSTATUS(status) : -1);
        return 1;
    }
    printf("[Cha %d] Con %d đã phát xong, exit status = 0.\n\n", getpid(), pid);

    srand((unsigned)time(NULL) ^ (unsigned)getpid());
    say(news[rand() % NEWS_LEN]);
    say("Quý vị chấm tiến trình vừa rồi mấy sao? Nhập từ 1 đến 5.");

    printf("⭐ Số sao: ");
    fflush(stdout);
    int stars;
    if (scanf("%d", &stars) != 1 || stars < 1 || stars > 5)
        stars = 0;

    printf("[Cha %d] ", getpid());
    for (int i = 0; i < 5; i++)
        printf(i < stars ? "★" : "☆");
    printf("\n");

    if (stars == 0)
        say("Không chấm là cha tự ghi năm sao đấy nhé.");
    else if (stars <= 2)
        say("Cảm ơn góp ý, lần sau tiến trình con sẽ hát hay hơn.");
    else if (stars <= 4)
        say("Cảm ơn quý vị, tiến trình con sẽ cố gắng hơn nữa.");
    else
        say("Tuyệt vời, năm sao cho tiến trình con! Giờ quay về học Hệ điều hành thôi.");

    return 0;
}
