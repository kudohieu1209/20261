/*
 * addr_translate.c - Dịch địa chỉ logic -> vật lý theo Paging và Segmentation
 *
 * Paging:       địa chỉ logic = (page number p, offset d)
 *               p = addr / page_size, d = addr % page_size
 *               physical = page_table[p] * page_size + d
 * Segmentation: địa chỉ logic = (segment s, offset d)
 *               nếu d >= limit[s] -> trap (segmentation fault)
 *               physical = base[s] + d
 *
 * Cách dùng:
 *   ./addr_translate page <page_size> <addr> [frame0,frame1,...]
 *   ./addr_translate seg  <segment> <offset> [base:limit,base:limit,...]
 * Địa chỉ nhận cả hệ 10 lẫn hệ 16 (0x...). Không truyền bảng thì dùng bảng ví dụ trong sách.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ENTRIES 64

/* Bảng trang ví dụ (Silberschatz, Figure 9.8): page 0..3 -> frame 5, 6, 1, 2 */
static const char *default_page_table = "5,6,1,2";
/* Bảng đoạn ví dụ (Silberschatz, Figure 9.19) */
static const char *default_seg_table = "1400:1000,6300:400,4300:400,3200:1100,4700:1000";

static void print_bits(unsigned long v, int nbits) {
  for (int i = nbits - 1; i >= 0; i--)
    putchar((v >> i) & 1 ? '1' : '0');
}

static int log2_exact(unsigned long x) {
  if (x == 0 || (x & (x - 1)))
    return -1; /* không phải lũy thừa của 2 */
  int n = 0;
  while (x >>= 1)
    n++;
  return n;
}

static int parse_list(const char *s, long *a, long *b, int max) {
  int n = 0;
  char *copy = strdup(s), *save = NULL;
  for (char *tok = strtok_r(copy, ",", &save); tok && n < max; tok = strtok_r(NULL, ",", &save)) {
    char *colon = strchr(tok, ':');
    a[n] = strtol(tok, NULL, 0);
    b[n] = colon ? strtol(colon + 1, NULL, 0) : 0;
    n++;
  }
  free(copy);
  return n;
}

static int do_paging(unsigned long page_size, unsigned long addr, const char *table) {
  int d_bits = log2_exact(page_size);
  if (d_bits < 0) {
    fprintf(stderr, "Kích thước trang phải là lũy thừa của 2\n");
    return EXIT_FAILURE;
  }
  long frames[MAX_ENTRIES], unused[MAX_ENTRIES];
  int n = parse_list(table, frames, unused, MAX_ENTRIES);

  unsigned long p = addr >> d_bits;          /* = addr / page_size */
  unsigned long d = addr & (page_size - 1);  /* = addr % page_size */
  int total_bits = d_bits + 1;
  while ((1UL << total_bits) <= addr)
    total_bits++;
  if (total_bits < d_bits + 2)
    total_bits = d_bits + 2;

  printf("Page size   = %lu byte -> offset dùng %d bit thấp\n", page_size, d_bits);
  printf("Bảng trang  = [%s] (%d entry)\n\n", table, n);
  printf("Địa chỉ logic %lu (0x%lx) = ", addr, addr);
  print_bits(p, total_bits - d_bits);
  printf(" | ");
  print_bits(d, d_bits);
  printf("\n                 page p = %lu, offset d = %lu\n", p, d);

  if (p >= (unsigned long)n) {
    printf("\n-> p = %lu vượt quá bảng trang: TRAP (truy cập địa chỉ không hợp lệ)\n", p);
    return EXIT_SUCCESS;
  }
  unsigned long f = (unsigned long)frames[p];
  unsigned long phys = (f << d_bits) | d;
  printf("page_table[%lu] = frame %lu\n", p, f);
  printf("\n-> Địa chỉ vật lý = %lu * %lu + %lu = %lu (0x%lx)\n", f, page_size, d, phys, phys);
  return EXIT_SUCCESS;
}

static int do_segmentation(long s, long d, const char *table) {
  long base[MAX_ENTRIES], limit[MAX_ENTRIES];
  int n = parse_list(table, base, limit, MAX_ENTRIES);

  printf("Bảng đoạn:\n  %-8s %8s %8s\n", "Segment", "Base", "Limit");
  for (int i = 0; i < n; i++)
    printf("  %-8d %8ld %8ld\n", i, base[i], limit[i]);
  printf("\nĐịa chỉ logic = <segment %ld, offset %ld>\n", s, d);

  if (s < 0 || s >= n) {
    printf("-> segment %ld không tồn tại: TRAP\n", s);
    return EXIT_SUCCESS;
  }
  if (d < 0 || d >= limit[s]) {
    printf("-> offset %ld >= limit %ld: TRAP (segmentation fault)\n", d, limit[s]);
    return EXIT_SUCCESS;
  }
  printf("-> offset %ld < limit %ld: hợp lệ\n", d, limit[s]);
  printf("-> Địa chỉ vật lý = base + offset = %ld + %ld = %ld\n", base[s], d, base[s] + d);
  return EXIT_SUCCESS;
}

int main(int argc, char *argv[]) {
  if (argc >= 4 && strcmp(argv[1], "page") == 0)
    return do_paging(strtoul(argv[2], NULL, 0), strtoul(argv[3], NULL, 0),
                     argc > 4 ? argv[4] : default_page_table);
  if (argc >= 4 && strcmp(argv[1], "seg") == 0)
    return do_segmentation(strtol(argv[2], NULL, 0), strtol(argv[3], NULL, 0),
                           argc > 4 ? argv[4] : default_seg_table);

  fprintf(stderr, "Cách dùng:\n  %s page <page_size> <addr> [frame0,frame1,...]\n", argv[0]);
  fprintf(stderr, "  %s seg  <segment> <offset> [base:limit,...]\n", argv[0]);
  return EXIT_FAILURE;
}
