/*
 * linux_sched_demo.c - Quan sát bộ lập lịch THẬT của Linux
 *
 * Tạo N tiến trình con chạy vòng lặp bận (CPU-bound), tất cả bị ghim vào CÙNG một CPU
 * (sched_setaffinity) để chúng phải tranh nhau. Sau T giây, tiến trình cha đọc
 * /proc/<pid>/stat và /proc/<pid>/status để xem mỗi con được bao nhiêu CPU và bị
 * chuyển ngữ cảnh bao nhiêu lần.
 *
 * Cách dùng:
 *   ./linux_sched_demo nice  0 5 10          # 3 con với nice 0, 5, 10 (SCHED_OTHER / EEVDF)
 *   sudo ./linux_sched_demo fifo 10 20       # SCHED_FIFO priority 10 và 20 (cần root)
 *   sudo ./linux_sched_demo rr   10 10 10    # SCHED_RR cùng priority -> chia đều theo lượng tử
 * Tùy chọn môi trường: DURATION=<giây> (mặc định 3), CPU=<số CPU để ghim> (mặc định 0)
 */
#define _GNU_SOURCE
#include <errno.h>
#include <sched.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <unistd.h>

#define MAX_CHILD 16

static void pin_to_cpu(int cpu) {
  cpu_set_t set;
  CPU_ZERO(&set);
  CPU_SET(cpu, &set);
  if (sched_setaffinity(0, sizeof set, &set) < 0) {
    perror("sched_setaffinity");
    exit(EXIT_FAILURE);
  }
}

/* Đọc utime+stime (tính bằng tick, thường 100 tick/giây) từ /proc/<pid>/stat */
static long cpu_ticks(pid_t pid) {
  char path[64], buf[1024];
  snprintf(path, sizeof path, "/proc/%d/stat", pid);
  FILE *f = fopen(path, "r");
  if (!f || !fgets(buf, sizeof buf, f)) {
    if (f)
      fclose(f);
    return -1;
  }
  fclose(f);
  /* Trường 2 (comm) có thể chứa dấu cách -> bắt đầu đếm sau dấu ')' cuối cùng */
  char *p = strrchr(buf, ')');
  unsigned long utime = 0, stime = 0;
  sscanf(p + 2, "%*c %*d %*d %*d %*d %*d %*u %*u %*u %*u %*u %lu %lu", &utime, &stime);
  return (long)(utime + stime);
}

/* Đọc số lần chuyển ngữ cảnh tự nguyện / bị cưỡng bức từ /proc/<pid>/status */
static void ctx_switches(pid_t pid, long *vol, long *invol) {
  char path[64], line[256];
  snprintf(path, sizeof path, "/proc/%d/status", pid);
  FILE *f = fopen(path, "r");
  *vol = *invol = -1;
  if (!f)
    return;
  while (fgets(line, sizeof line, f)) {
    sscanf(line, "voluntary_ctxt_switches: %ld", vol);
    sscanf(line, "nonvoluntary_ctxt_switches: %ld", invol);
  }
  fclose(f);
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Cách dùng: %s <nice|fifo|rr> <giá trị 1> [giá trị 2] ...\n", argv[0]);
    return EXIT_FAILURE;
  }
  const char *mode = argv[1];
  int policy;
  if (strcmp(mode, "nice") == 0)
    policy = SCHED_OTHER;
  else if (strcmp(mode, "fifo") == 0)
    policy = SCHED_FIFO;
  else if (strcmp(mode, "rr") == 0)
    policy = SCHED_RR;
  else {
    fprintf(stderr, "Chế độ không hợp lệ: %s\n", mode);
    return EXIT_FAILURE;
  }

  int n = argc - 2;
  if (n > MAX_CHILD)
    n = MAX_CHILD;
  int seconds = getenv("DURATION") ? atoi(getenv("DURATION")) : 3;
  int cpu = getenv("CPU") ? atoi(getenv("CPU")) : 0;
  long ncpu = sysconf(_SC_NPROCESSORS_ONLN);

  /* Bộ đếm vòng lặp đặt trong vùng nhớ chia sẻ để cha đọc được */
  volatile unsigned long *counters =
      mmap(NULL, sizeof(unsigned long) * MAX_CHILD, PROT_READ | PROT_WRITE,
           MAP_SHARED | MAP_ANONYMOUS, -1, 0);
  if (counters == MAP_FAILED) {
    perror("mmap");
    return EXIT_FAILURE;
  }

  /* Cha chạy trên CPU khác để không bị con SCHED_FIFO chiếm mất CPU */
  pin_to_cpu((int)((cpu + 1) % ncpu));

  int start_pipe[2];
  if (pipe(start_pipe) < 0) {
    perror("pipe");
    return EXIT_FAILURE;
  }

  pid_t pids[MAX_CHILD];
  int values[MAX_CHILD];
  for (int i = 0; i < n; i++) {
    values[i] = atoi(argv[i + 2]);
    pids[i] = fork();
    if (pids[i] < 0) {
      perror("fork");
      return EXIT_FAILURE;
    }
    if (pids[i] == 0) {
      close(start_pipe[1]);
      pin_to_cpu(cpu);
      if (policy == SCHED_OTHER) {
        if (setpriority(PRIO_PROCESS, 0, values[i]) < 0)
          perror("setpriority (nice âm cần sudo)");
      } else {
        struct sched_param sp = {.sched_priority = values[i]};
        if (sched_setscheduler(0, policy, &sp) < 0) {
          perror("sched_setscheduler (cần sudo)");
          _exit(EXIT_FAILURE);
        }
      }
      /* Chờ cha "bắn súng xuất phát": read() trả về 0 khi cha đóng đầu ghi */
      char c;
      if (read(start_pipe[0], &c, 1) < 0)
        _exit(EXIT_FAILURE);
      for (;;)
        counters[i]++;
    }
  }

  close(start_pipe[0]);
  usleep(100 * 1000); /* đợi các con cài đặt policy xong */
  close(start_pipe[1]); /* tất cả con cùng bắt đầu */
  printf("Chạy %d tiến trình con trên CPU %d trong %d giây (policy = %s)...\n", n, cpu, seconds,
         mode);
  sleep((unsigned)seconds);

  long ticks[MAX_CHILD], vol[MAX_CHILD], invol[MAX_CHILD], total = 0;
  unsigned long loops[MAX_CHILD];
  for (int i = 0; i < n; i++) {
    loops[i] = counters[i];
    ticks[i] = cpu_ticks(pids[i]);
    ctx_switches(pids[i], &vol[i], &invol[i]);
    total += ticks[i] > 0 ? ticks[i] : 0;
  }
  for (int i = 0; i < n; i++)
    kill(pids[i], SIGKILL);
  int killed = 0;
  for (int i = 0; i < n; i++) {
    int status;
    waitpid(pids[i], &status, 0);
    if (WIFSIGNALED(status))
      killed++;
  }

  long hz = sysconf(_SC_CLK_TCK);
  printf("\n%-8s %6s %10s %8s %14s %10s %10s\n", "PID", mode, "CPU time", "CPU %", "Vòng lặp",
         "ctx vol", "ctx invol");
  for (int i = 0; i < n; i++)
    printf("%-8d %6d %9.2fs %7.1f%% %14lu %10ld %10ld\n", pids[i], values[i],
           (double)ticks[i] / hz, total ? 100.0 * ticks[i] / total : 0.0, loops[i], vol[i],
           invol[i]);
  if (killed < n)
    printf("\nChú ý: %d tiến trình con thoát sớm (thường do thiếu quyền root).\n", n - killed);
  return EXIT_SUCCESS;
}
