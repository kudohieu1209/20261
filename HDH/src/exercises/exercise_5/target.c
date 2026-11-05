/*
 * target.c - Tiến trình "mẫu" để kiểm tra procmem: cấp phát lượng bộ nhớ BIẾT TRƯỚC
 * ở từng vùng, rồi đứng chờ để procmem đọc. Biết trước kết quả thì mới đánh giá được
 * procmem báo đúng hay sai.
 *
 * Cách dùng: ./target &      rồi      ./procmem $!
 */
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define KiB 1024UL
#define MiB (1024 * KiB)

char data_buf[64 * KiB] = {1}; /* .data: có giá trị khởi tạo -> nằm trong file ELF */
char bss_buf[4 * MiB];         /* .bss : chỉ chiếm chỗ ẢO, chưa tốn RAM cho tới khi bị ghi */

/* Đệ quy để stack lớn lên ~depth * 16 KiB; khi hàm trả về, các trang stack VẪN ở lại RAM */
static unsigned long grow_stack(int depth) {
  volatile char local[16 * KiB];
  memset((char *)local, depth, sizeof local);
  unsigned long v = (unsigned char)local[0];
  return depth > 0 ? v + grow_stack(depth - 1) : v;
}

int main(void) {
  memset(data_buf, 2, sizeof data_buf); /* ghi toàn bộ 64 KiB .data  -> 16 trang      */
  memset(bss_buf, 3, 1 * MiB);          /* chỉ ghi 1 MiB đầu của .bss -> 256 trang     */

  char *small[64];                      /* 64 khối x 1 KiB: malloc lấy từ [heap] (brk) */
  for (int i = 0; i < 64; i++) {
    small[i] = malloc(KiB);
    memset(small[i], 4, KiB);
  }
  for (int i = 0; i < 32; i++)          /* free một nửa: RAM KHÔNG trả lại cho kernel   */
    free(small[i]);

  char *big = malloc(8 * MiB);          /* > 128 KiB: glibc dùng mmap, KHÔNG nằm trong [heap] */
  memset(big, 5, 2 * MiB);              /* chỉ chạm 2 MiB -> 512 trang                  */
  volatile char sum = 0;                /* chỉ ĐỌC 1 MiB tiếp theo: kernel trỏ cả 256 trang */
  for (unsigned long off = 2 * MiB; off < 3 * MiB; off += 4 * KiB) /* vào 1 "zero page" */
    sum += big[off];

  unsigned long r = grow_stack(32);     /* stack sâu ~512 KiB -> ~128 trang             */

  printf("target PID = %d (r=%lu)\n", getpid(), r);
  printf("Dự kiến:\n");
  printf("  data : 64 KiB ghi hết        -> RAM ~64 KiB (16 trang)\n");
  printf("  bss  : 4 MiB ảo, ghi 1 MiB    -> RAM ~1024 KiB (256 trang)\n");
  printf("  heap : 64 x 1 KiB, free 32    -> RAM ~64 KiB+, vùng [heap] mặc định 132 KiB\n");
  printf("  mmap : 8 MiB ảo, ghi 2 MiB    -> RAM ~2048 KiB (512 trang), nhóm 'anon'\n");
  printf("         + đọc 1 MiB (zero page)  -> pagemap thấy 256 trang 'present', smaps RSS không tính\n");
  printf("  stack: đệ quy ~512 KiB        -> RAM ~512 KiB+ (~128 trang)\n");
  printf("Chạy: ./procmem %d    (Ctrl-C hoặc kill để dừng)\n", getpid());
  fflush(stdout);
  pause();
  free(big);
  return 0;
}
