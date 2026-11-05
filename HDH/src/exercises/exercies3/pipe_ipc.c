#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define DEFAULT_NAME "MaiDuyHieu"
#define DEFAULT_MSSV "20223967"
#define BUF_SIZE 256

/* Ghi đủ len byte vào fd (write() có thể ghi thiếu, nên phải lặp) */
static int write_all(int fd, const char *buf, size_t len) {
  while (len > 0) {
    ssize_t n = write(fd, buf, len);
    if (n < 0) {
      if (errno == EINTR)
        continue;
      return -1;
    }
    buf += n;
    len -= (size_t)n;
  }
  return 0;
}

/* Đọc cho tới khi đầu ghi bị đóng (read() trả về 0 = EOF) hoặc đầy buffer */
static ssize_t read_all(int fd, char *buf, size_t cap) {
  size_t total = 0;
  while (total < cap - 1) {
    ssize_t n = read(fd, buf + total, cap - 1 - total);
    if (n < 0) {
      if (errno == EINTR)
        continue;
      return -1;
    }
    if (n == 0)
      break; /* EOF */
    total += (size_t)n;
  }
  buf[total] = '\0';
  return (ssize_t)total;
}

int main(int argc, char *argv[]) {
  const char *name = (argc > 1) ? argv[1] : DEFAULT_NAME;
  const char *mssv = (argc > 2) ? argv[2] : DEFAULT_MSSV;

  int pipe_p2c[2]; /* Cha -> Con */
  int pipe_c2p[2]; /* Con -> Cha */

  if (pipe(pipe_p2c) == -1 || pipe(pipe_c2p) == -1) {
    perror("pipe");
    return EXIT_FAILURE;
  }

  pid_t pid = fork();
  if (pid < 0) {
    perror("fork");
    return EXIT_FAILURE;
  }

  if (pid == 0) {
    /* ======================= TIẾN TRÌNH CON ======================= */
    /* Đóng các đầu không dùng; nếu không đóng thì read() sẽ không bao giờ thấy
     * EOF */
    close(pipe_p2c[1]);
    close(pipe_c2p[0]);

    char msg[BUF_SIZE];
    ssize_t n = read_all(pipe_p2c[0], msg, sizeof(msg));
    close(pipe_p2c[0]);
    if (n < 0) {
      perror("[Con] read");
      _exit(EXIT_FAILURE);
    }
    printf("[Con  PID=%d] Nhận %zd byte: \"%s\"\n", getpid(), n, msg);

    /* Tách bản tin theo dấu '_' cuối cùng: <Tên>_<MSSV> */
    char reply[BUF_SIZE * 2];
    char *sep = strrchr(msg, '_');
    if (sep != NULL && sep != msg && sep[1] != '\0') {
      *sep = '\0';
      printf("[Con  PID=%d]   -> Tên : %s\n", getpid(), msg);
      printf("[Con  PID=%d]   -> MSSV: %s\n", getpid(), sep + 1);
      snprintf(reply, sizeof(reply), "ACK: Xin chao %s (MSSV %s)!", msg,
               sep + 1);
    } else {
      snprintf(reply, sizeof(reply),
               "NACK: Ban tin sai dinh dang <Ten>_<MSSV>");
    }

    printf("[Con  PID=%d] Gửi phản hồi: \"%s\"\n", getpid(), reply);
    fflush(stdout); /* _exit() không tự flush stdio; flush trước khi cha nhận
                       được phản hồi */
    if (write_all(pipe_c2p[1], reply, strlen(reply)) == -1) {
      perror("[Con] write");
      _exit(EXIT_FAILURE);
    }
    close(pipe_c2p[1]); /* Báo EOF cho cha */
    _exit(EXIT_SUCCESS);
  }

  /* ========================= TIẾN TRÌNH CHA ========================= */
  close(pipe_p2c[0]);
  close(pipe_c2p[1]);

  char msg[BUF_SIZE];
  snprintf(msg, sizeof(msg), "%s_%s", name, mssv);

  printf("[Cha  PID=%d] Tạo tiến trình con PID=%d\n", getpid(), pid);
  printf("[Cha  PID=%d] Gửi bản tin: \"%s\"\n", getpid(), msg);
  fflush(stdout); /* Tránh lẫn thứ tự output giữa 2 tiến trình */

  if (write_all(pipe_p2c[1], msg, strlen(msg)) == -1) {
    perror("[Cha] write");
    return EXIT_FAILURE;
  }
  close(pipe_p2c[1]); /* Báo EOF cho con: đã gửi xong */

  /* read() sẽ BLOCK (tiến trình cha chuyển sang trạng thái Blocked) cho tới khi
   * con ghi */
  char reply[BUF_SIZE * 2];
  ssize_t n = read_all(pipe_c2p[0], reply, sizeof(reply));
  close(pipe_c2p[0]);
  if (n < 0) {
    perror("[Cha] read");
    return EXIT_FAILURE;
  }
  printf("[Cha  PID=%d] Nhận phản hồi: \"%s\"\n", getpid(), reply);

  int status;
  waitpid(pid, &status, 0);
  if (WIFEXITED(status))
    printf("[Cha  PID=%d] Con kết thúc với mã %d\n", getpid(),
           WEXITSTATUS(status));

  return EXIT_SUCCESS;
}
