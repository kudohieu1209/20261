/*
 * vm_inspect.c - Quan sát bộ nhớ ảo THẬT của một tiến trình Linux
 *
 *  1. Địa chỉ ảo của text/data/bss/heap/stack/mmap/libc, tách thành (page number, offset)
 *     và tra /proc/self/pagemap để lấy frame vật lý (PFN). Không có root thì kernel trả PFN = 0.
 *  2. Demand paging: mmap() chưa tốn RAM, chỉ khi chạm vào từng trang mới sinh page fault.
 *  3. Segmentation trên x86-64: các thanh ghi đoạn cs/ds/ss/fs/gs vẫn còn, nhưng ở long mode
 *     base bị bỏ qua (flat model); chỉ fs/gs có base khác 0, dùng cho Thread-Local Storage.
 *  4. In /proc/self/maps: danh sách các vùng nhớ (VMA) của tiến trình.
 *
 * Cách dùng: ./vm_inspect            (PFN = 0)
 *            sudo ./vm_inspect       (thấy PFN thật)
 */
#define _GNU_SOURCE
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <unistd.h>
#if defined(__x86_64__)
#include <asm/prctl.h>
#include <sys/syscall.h>
#endif

int global_init = 42;           /* .data */
int global_uninit;              /* .bss  */
static __thread int tls_var = 7; /* Thread-Local Storage, truy cập qua thanh ghi fs */

static long page_size;

/* Mỗi trang ảo có 1 entry 64 bit trong /proc/self/pagemap:
 * bit 63 = present, bit 62 = swapped, bit 0..54 = PFN (frame vật lý) */
static void show(int fd, const char *label, const void *ptr) {
  uintptr_t va = (uintptr_t)ptr;
  uintptr_t vpn = va / (uintptr_t)page_size;
  uint64_t entry = 0;
  if (fd >= 0 && pread(fd, &entry, sizeof entry, (off_t)(vpn * sizeof entry)) != sizeof entry)
    entry = 0;
  int present = (entry >> 63) & 1;
  uint64_t pfn = entry & ((1ULL << 55) - 1);
  printf("  %-14s VA=0x%012lx  VPN=0x%09lx  offset=0x%03lx  %-8s PFN=0x%lx\n", label,
         (unsigned long)va, (unsigned long)vpn, (unsigned long)(va % (uintptr_t)page_size),
         present ? "present" : "-", (unsigned long)pfn);
}

static long minor_faults(void) {
  struct rusage ru;
  getrusage(RUSAGE_SELF, &ru);
  return ru.ru_minflt;
}

static void demand_paging(void) {
  const size_t size = 64UL << 20; /* 64 MiB */
  long npages = (long)(size / (size_t)page_size);
  printf("\n[2] Demand paging: mmap %zu MiB = %ld trang\n", size >> 20, npages);

  long before = minor_faults();
  char *buf = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  if (buf == MAP_FAILED) {
    perror("mmap");
    return;
  }
  long after_mmap = minor_faults();
  for (size_t off = 0; off < size; off += (size_t)page_size)
    buf[off] = 1; /* chạm vào mỗi trang 1 lần */
  long after_touch = minor_faults();
  printf("  page fault sau mmap()        : %ld\n", after_mmap - before);
  printf("  page fault sau khi chạm %ld trang: %ld (~1 fault/trang)\n", npages,
         after_touch - after_mmap);
  munmap(buf, size);
}

static void segmentation(void) {
  printf("\n[3] Segmentation trên x86-64\n");
#if defined(__x86_64__)
  unsigned short cs, ds, ss, es, fs, gs;
  __asm__ volatile("mov %%cs, %0" : "=r"(cs));
  __asm__ volatile("mov %%ds, %0" : "=r"(ds));
  __asm__ volatile("mov %%ss, %0" : "=r"(ss));
  __asm__ volatile("mov %%es, %0" : "=r"(es));
  __asm__ volatile("mov %%fs, %0" : "=r"(fs));
  __asm__ volatile("mov %%gs, %0" : "=r"(gs));
  /* Selector = index(13 bit) | TI(1 bit: 0=GDT,1=LDT) | RPL(2 bit: mức đặc quyền, 3=user) */
  printf("  cs=0x%04x (GDT index %d, RPL %d)  ss=0x%04x  ds=0x%04x  es=0x%04x  fs=0x%04x  "
         "gs=0x%04x\n",
         cs, cs >> 3, cs & 3, ss, ds, es, fs, gs);
  unsigned long fs_base = 0;
  syscall(SYS_arch_prctl, ARCH_GET_FS, &fs_base);
  printf("  fs.base = 0x%lx, &tls_var = %p (tls_var = %d)\n", fs_base, (void *)&tls_var, tls_var);
  printf("  -> Ở long mode (64 bit), CPU bỏ qua base/limit của cs/ds/ss/es (coi như base = 0):\n"
         "     \"flat model\", việc bảo vệ và dịch địa chỉ do paging đảm nhận.\n");
  printf("     Riêng fs.base trỏ tới vùng TLS của luồng, nên &tls_var nằm ngay cạnh fs.base.\n");
#else
  printf("  (chỉ hỗ trợ x86-64)\n");
#endif
}

static void print_maps(void) {
  printf("\n[4] /proc/self/maps (vùng nhớ ảo của tiến trình này)\n");
  FILE *f = fopen("/proc/self/maps", "r");
  if (!f) {
    perror("/proc/self/maps");
    return;
  }
  char line[512];
  while (fgets(line, sizeof line, f))
    printf("  %s", line);
  fclose(f);
}

int main(void) {
  page_size = sysconf(_SC_PAGESIZE);
  int local = 1;
  int *heap = malloc(sizeof(int));
  *heap = 2;
  global_uninit = 3;
  void *anon = mmap(NULL, (size_t)page_size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS,
                    -1, 0);
  void *untouched = mmap(NULL, (size_t)page_size, PROT_READ | PROT_WRITE,
                         MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  ((char *)anon)[0] = 1;

  printf("PID = %d, page size = %ld byte\n", getpid(), page_size);
  printf("\n[1] Địa chỉ ảo -> (VPN, offset) -> PFN qua /proc/self/pagemap\n");
  int fd = open("/proc/self/pagemap", O_RDONLY);
  if (fd < 0)
    perror("/proc/self/pagemap");
  show(fd, "text (main)", (void *)main);
  show(fd, "libc (printf)", (void *)printf);
  show(fd, "data", &global_init);
  show(fd, "bss", &global_uninit);
  show(fd, "heap (malloc)", heap);
  show(fd, "mmap (touched)", anon);
  show(fd, "mmap (fresh)", untouched);
  show(fd, "stack", &local);
  if (fd >= 0)
    close(fd);
  if (geteuid() != 0)
    printf("  (Không phải root nên kernel giấu PFN = 0. Chạy sudo để thấy frame thật.)\n");

  demand_paging();
  segmentation();
  print_maps();
  free(heap);
  return EXIT_SUCCESS;
}
