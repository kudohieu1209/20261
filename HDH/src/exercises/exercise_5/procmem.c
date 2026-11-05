/*
 * procmem.c - Exercise 5: Memory paging and segmentation
 *
 * Cho trước PID, chương trình:
 *   [1] liệt kê tất cả các đoạn bộ nhớ (VMA) đã cấp cho tiến trình     <- /proc/PID/smaps
 *   [2] liệt kê các trang thuộc vùng text, data, heap, stack           <- /proc/PID/pagemap
 *   [3] báo dung lượng RAM thực tế của từng vùng (RSS / PSS / USS)
 *   [4] đối chiếu nhiều nguồn số liệu để đánh giá độ chính xác          <- /proc/PID/status
 *
 * Cách dùng: ./procmem <pid|self> [-p]
 *   -p : in chi tiết TỪNG trang (địa chỉ, có trong RAM không, PFN) thay vì bản đồ thu gọn
 * Tiến trình của user khác (hoặc muốn thấy PFN thật) thì chạy bằng sudo.
 */
#define _GNU_SOURCE
#include <fcntl.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define BITMAP_MAX 128 /* số trang tối đa in trong bản đồ thu gọn của mỗi đoạn */

enum { TEXT, RODATA, DATA, BSS, HEAP, STACK, LIB, ANON, FILEMAP, SPECIAL, NCAT };
static const char *cat_names[NCAT] = {"text", "rodata", "data", "bss",  "heap",
                                      "stack", "lib",   "anon", "file", "kernel"};

typedef struct {
  unsigned long start, end;
  char perms[5];
  char path[PATH_MAX];
  int cat;
  long rss, pss, uss, swap; /* kB, kernel tính sẵn trong smaps */
  long present, swapped;    /* số trang, tự đếm từ pagemap (-1 = không đọc được) */
} Vma;

/* Ranh giới các vùng mà kernel ghi trong mm_struct (xem /proc/PID/stat, man 5 proc) */
typedef struct {
  unsigned long start_code, end_code, start_stack, start_data, end_data, start_brk;
} MmLayout;

static long page_size;
static const char *pid_str;
static Vma *vmas;
static int nvma;

static FILE *open_proc(const char *name) {
  char path[64];
  snprintf(path, sizeof path, "/proc/%s/%s", pid_str, name);
  FILE *f = fopen(path, "r");
  if (!f)
    perror(path);
  return f;
}

static int read_smaps(void) {
  FILE *f = open_proc("smaps");
  if (!f)
    return -1;
  char line[PATH_MAX + 128];
  int cap = 0;
  Vma *cur = NULL;
  while (fgets(line, sizeof line, f)) {
    unsigned long s, e, off;
    char perms[5];
    int n = 0;
    /* Dòng tiêu đề của một VMA: "start-end perms offset dev inode   path" */
    if (sscanf(line, "%lx-%lx %4s %lx %*s %*s %n", &s, &e, perms, &off, &n) == 4 && n > 0) {
      if (nvma == cap) {
        cap = cap ? cap * 2 : 64;
        vmas = realloc(vmas, sizeof(Vma) * (size_t)cap);
      }
      cur = &vmas[nvma++];
      memset(cur, 0, sizeof *cur);
      cur->start = s;
      cur->end = e;
      memcpy(cur->perms, perms, sizeof perms);
      snprintf(cur->path, sizeof cur->path, "%s", line + n);
      cur->path[strcspn(cur->path, "\n")] = '\0';
      continue;
    }
    if (!cur)
      continue;
    /* Các dòng thuộc tính "Tên:   số kB" của VMA hiện tại */
    if (strncmp(line, "Rss:", 4) == 0)
      cur->rss = atol(line + 4);
    else if (strncmp(line, "Pss:", 4) == 0)
      cur->pss = atol(line + 4);
    else if (strncmp(line, "Private_Clean:", 14) == 0)
      cur->uss += atol(line + 14);
    else if (strncmp(line, "Private_Dirty:", 14) == 0)
      cur->uss += atol(line + 14);
    else if (strncmp(line, "Swap:", 5) == 0)
      cur->swap = atol(line + 5);
  }
  fclose(f);
  return 0;
}

static void read_layout(MmLayout *mm) {
  memset(mm, 0, sizeof *mm);
  FILE *f = open_proc("stat");
  if (!f)
    return;
  char buf[4096];
  if (fgets(buf, sizeof buf, f)) {
    /* Trường 2 (comm) có thể chứa dấu cách -> bắt đầu tách sau dấu ')' cuối.
     * Token đầu tiên là trường số 3, nên trường N là token thứ N - 3. */
    char *p = strrchr(buf, ')');
    unsigned long field[64] = {0};
    int i = 3;
    for (char *tok = strtok(p + 2, " "); tok && i < 64; tok = strtok(NULL, " "))
      field[i++] = strtoul(tok, NULL, 10);
    mm->start_code = field[26];
    mm->end_code = field[27];
    mm->start_stack = field[28];
    mm->start_data = field[45];
    mm->end_data = field[46];
    mm->start_brk = field[47];
  }
  fclose(f);
}

static long status_kb(const char *key) {
  FILE *f = open_proc("status");
  if (!f)
    return -1;
  char line[256];
  long v = -1;
  size_t len = strlen(key);
  while (fgets(line, sizeof line, f))
    if (strncmp(line, key, len) == 0 && line[len] == ':') {
      v = atol(line + len + 1);
      break;
    }
  fclose(f);
  return v;
}

static int classify(const Vma *v, const char *exe, const MmLayout *mm) {
  if (strcmp(v->path, "[heap]") == 0)
    return HEAP;
  if (strcmp(v->path, "[stack]") == 0)
    return STACK;
  if (strncmp(v->path, "[anon", 5) == 0)
    return ANON; /* vùng ẩn danh được đặt tên bằng prctl(PR_SET_VMA_ANON_NAME), vd. [anon:v8] */
  if (v->path[0] == '[')
    return SPECIAL; /* [vdso], [vvar], [vsyscall]: kernel ánh xạ sẵn */
  if (exe[0] && strcmp(v->path, exe) == 0) {
    if (v->perms[2] == 'x')
      return TEXT;
    return v->perms[1] == 'w' ? DATA : RODATA;
  }
  if (v->path[0] == '\0') {
    /* .bss không có trong file ELF: là vùng ẩn danh nằm giữa cuối .data và đầu heap */
    unsigned long data_end_page = mm->end_data & ~(unsigned long)(page_size - 1);
    if (mm->end_data && v->start >= data_end_page && v->end <= mm->start_brk)
      return BSS;
    return ANON;
  }
  return strstr(v->path, ".so") ? LIB : FILEMAP;
}

/* Mỗi trang ảo có 1 entry 64 bit trong /proc/PID/pagemap (Documentation/admin-guide/mm/pagemap.rst):
 *   bit 63 present, bit 62 swapped, bit 61 file-page/shared-anon, bit 56 exclusively mapped,
 *   bit 0-54 PFN (frame vật lý; kernel trả 0 nếu không có CAP_SYS_ADMIN) */
#define PM_PRESENT(e) (((e) >> 63) & 1)
#define PM_SWAPPED(e) (((e) >> 62) & 1)
#define PM_FILE(e) (((e) >> 61) & 1)
#define PM_EXCL(e) (((e) >> 56) & 1)
#define PM_PFN(e) ((e) & ((1ULL << 55) - 1))

enum { SCAN_COUNT, SCAN_BITMAP, SCAN_LIST };

static void print_page(unsigned long va, uint64_t e) {
  if (PM_PRESENT(e))
    printf("      0x%012lx  RAM   PFN=0x%-9llx %s%s\n", va, (unsigned long long)PM_PFN(e),
           PM_FILE(e) ? "file/shared" : "anon", PM_EXCL(e) ? " excl" : "");
  else if (PM_SWAPPED(e))
    printf("      0x%012lx  SWAP\n", va);
  else
    printf("      0x%012lx  -     (chưa có frame vật lý)\n", va);
}

static void scan_pages(int fd, Vma *v, int mode) {
  uint64_t buf[512];
  unsigned long vpn = v->start / (unsigned long)page_size;
  unsigned long end = v->end / (unsigned long)page_size;
  unsigned long idx = 0;
  v->present = v->swapped = 0;
  if (mode == SCAN_BITMAP)
    printf("      ");
  while (vpn < end) {
    size_t want = end - vpn < 512 ? end - vpn : 512;
    ssize_t got = pread(fd, buf, want * sizeof(uint64_t), (off_t)(vpn * sizeof(uint64_t)));
    if (got <= 0) {
      v->present = v->swapped = -1;
      break;
    }
    size_t n = (size_t)got / sizeof(uint64_t);
    for (size_t i = 0; i < n; i++, idx++) {
      uint64_t e = buf[i];
      v->present += PM_PRESENT(e);
      v->swapped += !PM_PRESENT(e) && PM_SWAPPED(e);
      if (mode == SCAN_LIST)
        print_page((vpn + i) * (unsigned long)page_size, e);
      else if (mode == SCAN_BITMAP && idx < BITMAP_MAX) {
        putchar(PM_PRESENT(e) ? '#' : PM_SWAPPED(e) ? 's' : '.');
        if (idx % 64 == 63 && idx + 1 < BITMAP_MAX && vpn + i + 1 < end)
          printf("\n      ");
      }
    }
    vpn += n;
  }
  if (mode == SCAN_BITMAP) {
    unsigned long total = (v->end - v->start) / (unsigned long)page_size;
    if (total > BITMAP_MAX)
      printf(" ...(+%lu trang)", total - BITMAP_MAX);
    printf("\n");
  }
}

/* In chuỗi UTF-8 trong cột rộng |width| ký tự (width < 0: căn trái). Không dùng %-*s được
 * vì printf đếm theo byte, mà chữ có dấu như "Vùng" chiếm 2-3 byte mỗi ký tự. */
static void print_col(const char *s, int width) {
  int chars = 0, w = width < 0 ? -width : width;
  for (const char *p = s; *p; p++)
    if ((*p & 0xC0) != 0x80)
      chars++;
  int pad = w > chars ? w - chars : 0;
  if (width < 0)
    printf("%s%*s", s, pad, "");
  else
    printf("%*s%s", pad, "", s);
}

static unsigned long pages_of(const Vma *v) {
  return (v->end - v->start) / (unsigned long)page_size;
}

static void print_vma_table(void) {
  printf("\n[1] Các đoạn (VMA) đã cấp cho tiến trình: %d đoạn\n", nvma);
  printf("%3s %-25s %-4s ", "#", "START-END", "PERM");
  print_col("VÙNG", -6);
  printf(" %9s %7s %7s %7s %7s  %s\n", "SIZE kB", "PAGES", "IN RAM", "RSS kB", "PSS kB", "PATH");
  for (int i = 0; i < nvma; i++) {
    Vma *v = &vmas[i];
    char present[24] = "n/a";
    if (v->present >= 0)
      snprintf(present, sizeof present, "%ld", v->present);
    printf("%3d %012lx-%012lx %-4s %-6s %9lu %7lu %7s %7ld %7ld  %s\n", i, v->start, v->end,
           v->perms, cat_names[v->cat], (v->end - v->start) / 1024, pages_of(v), present, v->rss,
           v->pss, v->path);
  }
}

static void print_pages(int fd, int list) {
  printf("\n[2] Các trang của vùng text / data / heap / stack");
  printf(list ? "\n" : "  (# = trong RAM, s = swap, . = chưa cấp frame)\n");
  for (int c = TEXT; c <= STACK; c++)
    for (int i = 0; i < nvma; i++) {
      Vma *v = &vmas[i];
      if (v->cat != c)
        continue;
      printf("  %-6s %012lx-%012lx %s  %lu trang ảo\n", cat_names[c], v->start, v->end, v->perms,
             pages_of(v));
      scan_pages(fd, v, list ? SCAN_LIST : SCAN_BITMAP);
    }
}

static void print_summary(void) {
  long kb_per_page = page_size / 1024;
  long virt[NCAT] = {0}, pages[NCAT] = {0}, present[NCAT] = {0}, rss[NCAT] = {0};
  long pss[NCAT] = {0}, uss[NCAT] = {0}, swap[NCAT] = {0};
  for (int i = 0; i < nvma; i++) {
    Vma *v = &vmas[i];
    virt[v->cat] += (long)((v->end - v->start) / 1024);
    pages[v->cat] += (long)pages_of(v);
    present[v->cat] += v->present > 0 ? v->present : 0;
    rss[v->cat] += v->rss;
    pss[v->cat] += v->pss;
    uss[v->cat] += v->uss;
    swap[v->cat] += v->swap;
  }

  printf("\n[3] Dung lượng RAM thực tế theo vùng\n");
  printf("  RSS = trang đang nằm trong RAM (trang dùng chung tính đủ cho mỗi tiến trình)\n");
  printf("  PSS = RSS nhưng trang dùng chung chia đều cho số tiến trình dùng nó\n");
  printf("  USS = trang riêng của tiến trình, sẽ được giải phóng khi tiến trình kết thúc\n\n");
  printf("  ");
  print_col("Vùng", -7);
  print_col("Ảo kB", 13);
  print_col("Trang ảo", 11);
  print_col("Trang RAM", 10);
  printf(" %9s %9s %9s %8s\n", "RSS kB", "PSS kB", "USS kB", "Swap kB");
  long t[7] = {0};
  for (int c = 0; c < NCAT; c++) {
    if (c == LIB)
      printf("  -- ngoài 4 vùng của đề --\n");
    printf("  %-7s %12ld %10ld %9ld %9ld %9ld %9ld %8ld\n", cat_names[c], virt[c], pages[c],
           present[c], rss[c], pss[c], uss[c], swap[c]);
    long row[7] = {virt[c], pages[c], present[c], rss[c], pss[c], uss[c], swap[c]};
    for (int k = 0; k < 7; k++)
      t[k] += row[k];
  }
  printf("  ");
  print_col("TỔNG", -7);
  printf(" %12ld %10ld %9ld %9ld %9ld %9ld %8ld\n", t[0], t[1], t[2], t[3], t[4], t[5], t[6]);

  printf("\n  Gộp theo 4 vùng của đề (data = rodata + data + bss):\n");
  long data_rss = rss[RODATA] + rss[DATA] + rss[BSS];
  long data_pages = present[RODATA] + present[DATA] + present[BSS];
  printf("    text : %6ld kB RAM (%ld trang)\n", rss[TEXT], present[TEXT]);
  printf("    data : %6ld kB RAM (%ld trang)\n", data_rss, data_pages);
  printf("    heap : %6ld kB RAM (%ld trang)\n", rss[HEAP], present[HEAP]);
  printf("    stack: %6ld kB RAM (%ld trang)\n", rss[STACK], present[STACK]);

  printf("\n[4] Đối chiếu các nguồn số liệu\n");
  long vmrss = status_kb("VmRSS");
  printf("  Tổng RSS cộng từ smaps (kernel đếm theo từng VMA)   : %8ld kB\n", t[3]);
  printf("  Tổng trang present đếm từ pagemap x %ld kB          : %8ld kB\n", kb_per_page,
         t[2] * kb_per_page);
  printf("  VmRSS trong /proc/PID/status (bộ đếm nhanh)        : %8ld kB", vmrss);
  printf("  (= RssAnon %ld + RssFile %ld + RssShmem %ld)\n", status_kb("RssAnon"),
         status_kb("RssFile"), status_kb("RssShmem"));
  printf("  -> chênh lệch smaps - status = %+ld kB, smaps - pagemap = %+ld kB\n", t[3] - vmrss,
         t[3] - t[2] * kb_per_page);
  printf("  VmExe / VmStk / VmData (kích thước ẢO, không phải RAM): %ld / %ld / %ld kB\n",
         status_kb("VmExe"), status_kb("VmStk"), status_kb("VmData"));
  printf("  VmPTE: bảng trang của tiến trình (RAM của kernel, KHÔNG có trong RSS): %ld kB\n",
         status_kb("VmPTE"));

  int mismatch = 0;
  for (int i = 0; i < nvma; i++)
    if (vmas[i].present >= 0 && vmas[i].rss != vmas[i].present * kb_per_page)
      mismatch++;
  printf("  Số VMA có RSS (smaps) khác số trang present (pagemap): %d\n", mismatch);
}

int main(int argc, char *argv[]) {
  if (argc < 2) {
    fprintf(stderr, "Cách dùng: %s <pid|self> [-p]\n", argv[0]);
    return EXIT_FAILURE;
  }
  pid_str = argv[1];
  int list = argc > 2 && strcmp(argv[2], "-p") == 0;
  page_size = sysconf(_SC_PAGESIZE);

  char path[64], exe[PATH_MAX] = "", comm[64] = "?";
  snprintf(path, sizeof path, "/proc/%s/exe", pid_str);
  ssize_t n = readlink(path, exe, sizeof exe - 1);
  exe[n > 0 ? n : 0] = '\0';
  FILE *f = open_proc("comm");
  if (!f) {
    fprintf(stderr, "Không có tiến trình %s hoặc không đủ quyền đọc.\n", pid_str);
    return EXIT_FAILURE;
  }
  if (fgets(comm, sizeof comm, f))
    comm[strcspn(comm, "\n")] = '\0';
  fclose(f);

  if (read_smaps() < 0) {
    fprintf(stderr, "Không đọc được smaps (tiến trình của user khác? thử chạy bằng sudo)\n");
    return EXIT_FAILURE;
  }
  MmLayout mm;
  read_layout(&mm);
  for (int i = 0; i < nvma; i++)
    vmas[i].cat = classify(&vmas[i], exe, &mm);

  snprintf(path, sizeof path, "/proc/%s/pagemap", pid_str);
  int fd = open(path, O_RDONLY);
  if (fd < 0)
    perror(path);
  for (int i = 0; i < nvma; i++) {
    if (fd >= 0)
      scan_pages(fd, &vmas[i], SCAN_COUNT);
    else
      vmas[i].present = vmas[i].swapped = -1;
  }

  printf("=== PID %s (%s) ===\n", pid_str, comm);
  printf("Executable: %s\nPage size : %ld byte\n", exe[0] ? exe : "(không đọc được)", page_size);
  printf("Ranh giới kernel ghi trong mm_struct (/proc/PID/stat):\n");
  printf("  code  [0x%lx, 0x%lx)\n  data  [0x%lx, 0x%lx)\n  heap  bắt đầu 0x%lx\n"
         "  stack bắt đầu 0x%lx\n",
         mm.start_code, mm.end_code, mm.start_data, mm.end_data, mm.start_brk, mm.start_stack);

  print_vma_table();
  if (fd >= 0) {
    print_pages(fd, list);
    close(fd);
  }
  print_summary();
  if (geteuid() != 0)
    printf("\n(Không phải root: kernel giấu PFN = 0. Chạy sudo để thấy frame vật lý thật.)\n");
  free(vmas);
  return EXIT_SUCCESS;
}
