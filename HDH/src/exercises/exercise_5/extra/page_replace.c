/*
 * page_replace.c - Mô phỏng các thuật toán thay trang (page replacement)
 *
 *   FIFO  : thay trang vào bộ nhớ sớm nhất
 *   LRU   : thay trang lâu nhất chưa được dùng
 *   OPT   : thay trang lâu nhất SẼ được dùng lại (tối ưu, chỉ dùng để so sánh)
 *   CLOCK : Second-chance, mỗi frame có 1 bit tham chiếu
 *
 * Cách dùng:
 *   ./page_replace <fifo|lru|opt|clock> <số frame> <chuỗi tham chiếu...>
 *   ./page_replace all <số frame> <chuỗi tham chiếu...>      # so sánh số lỗi trang
 *   ./page_replace belady                                     # minh họa nghịch lý Belady
 * Ví dụ: ./page_replace lru 3 7 0 1 2 0 3 0 4 2 3 0 3 2 1 2 0 1 7 0 1
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#define MAX_FRAMES 32
#define MAX_REFS 256

typedef enum { FIFO, LRU, OPT, CLOCK } Algo;

static const char *algo_names[] = {"FIFO", "LRU", "OPT", "CLOCK"};

/* history[r][f] = trang trong frame f sau tham chiếu thứ r (-1 = trống) */
static int history[MAX_REFS][MAX_FRAMES];
static int fault_at[MAX_REFS];

static int find(const int *frames, int n, int page) {
  for (int i = 0; i < n; i++)
    if (frames[i] == page)
      return i;
  return -1;
}

/* Chọn frame nạn nhân khi bộ nhớ đã đầy */
static int victim(Algo a, int nframes, const int *frames, const long *loaded, const long *used,
                  int *ref_bit, int *hand, const int *refs, int nrefs, int now) {
  int v = 0;
  switch (a) {
  case FIFO:
    for (int i = 1; i < nframes; i++)
      if (loaded[i] < loaded[v])
        v = i;
    return v;
  case LRU:
    for (int i = 1; i < nframes; i++)
      if (used[i] < used[v])
        v = i;
    return v;
  case OPT: {
    int farthest = -1;
    for (int i = 0; i < nframes; i++) {
      int next = nrefs; /* không bao giờ dùng lại = xa nhất */
      for (int j = now + 1; j < nrefs; j++)
        if (refs[j] == frames[i]) {
          next = j;
          break;
        }
      if (next > farthest) {
        farthest = next;
        v = i;
      }
    }
    return v;
  }
  case CLOCK:
    /* Kim đồng hồ quay: bit = 1 thì cho "cơ hội thứ hai" (xóa về 0), bit = 0 thì thay */
    while (ref_bit[*hand]) {
      ref_bit[*hand] = 0;
      *hand = (*hand + 1) % nframes;
    }
    v = *hand;
    *hand = (*hand + 1) % nframes;
    return v;
  }
  return v;
}

static int simulate(Algo a, int nframes, const int *refs, int nrefs) {
  int frames[MAX_FRAMES], ref_bit[MAX_FRAMES] = {0}, hand = 0, faults = 0;
  long loaded[MAX_FRAMES], used[MAX_FRAMES];
  for (int i = 0; i < nframes; i++)
    frames[i] = -1;

  for (int t = 0; t < nrefs; t++) {
    int page = refs[t];
    int f = find(frames, nframes, page);
    fault_at[t] = (f < 0);
    if (f < 0) {
      faults++;
      f = find(frames, nframes, -1); /* còn frame trống? */
      if (f < 0)
        f = victim(a, nframes, frames, loaded, used, ref_bit, &hand, refs, nrefs, t);
      else if (a == CLOCK)
        hand = (f + 1) % nframes;
      frames[f] = page;
      loaded[f] = t;
    }
    used[f] = t;
    ref_bit[f] = 1;
    memcpy(history[t], frames, sizeof(int) * nframes);
  }
  return faults;
}

static void print_table(Algo a, int nframes, const int *refs, int nrefs, int faults) {
  printf("=== %s, %d frame ===\n\n%-8s", algo_names[a], nframes, "Ref");
  for (int t = 0; t < nrefs; t++)
    printf("%3d", refs[t]);
  printf("\n");
  for (int f = 0; f < nframes; f++) {
    printf("Frame %-2d", f);
    for (int t = 0; t < nrefs; t++) {
      if (history[t][f] < 0)
        printf("  .");
      else
        printf("%3d", history[t][f]);
    }
    printf("\n");
  }
  printf("%-8s", "Fault");
  for (int t = 0; t < nrefs; t++)
    printf("%3s", fault_at[t] ? "F" : "");
  printf("\n\nSố lỗi trang = %d / %d tham chiếu (hit ratio = %.1f%%)\n", faults, nrefs,
         100.0 * (nrefs - faults) / nrefs);
}

static void belady(void) {
  static const int refs[] = {1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5};
  int n = sizeof refs / sizeof refs[0];
  printf("Nghịch lý Belady với chuỗi 1 2 3 4 1 2 5 1 2 3 4 5:\n");
  printf("%-7s %6s %6s %6s %6s\n", "Frames", "FIFO", "LRU", "OPT", "CLOCK");
  for (int f = 1; f <= 6; f++) {
    printf("%-7d", f);
    for (int a = FIFO; a <= CLOCK; a++)
      printf(" %6d", simulate((Algo)a, f, refs, n));
    printf("\n");
  }
  printf("-> FIFO: 3 frame bị 9 lỗi nhưng 4 frame lại bị 10 lỗi. LRU/OPT là thuật toán\n"
         "   \"stack\" nên không bao giờ bị nghịch lý này.\n");
}

int main(int argc, char *argv[]) {
  if (argc == 2 && strcmp(argv[1], "belady") == 0) {
    belady();
    return EXIT_SUCCESS;
  }
  if (argc < 4) {
    fprintf(stderr, "Cách dùng: %s <fifo|lru|opt|clock|all> <số frame> <trang...>\n", argv[0]);
    fprintf(stderr, "           %s belady\n", argv[0]);
    return EXIT_FAILURE;
  }
  int nframes = atoi(argv[2]);
  int nrefs = argc - 3;
  if (nframes <= 0 || nframes > MAX_FRAMES || nrefs > MAX_REFS) {
    fprintf(stderr, "Số frame phải trong 1..%d, tối đa %d tham chiếu\n", MAX_FRAMES, MAX_REFS);
    return EXIT_FAILURE;
  }
  int refs[MAX_REFS];
  for (int i = 0; i < nrefs; i++)
    refs[i] = atoi(argv[i + 3]);

  if (strcmp(argv[1], "all") == 0) {
    printf("%-6s %8s\n", "Algo", "Faults");
    for (int a = FIFO; a <= CLOCK; a++)
      printf("%-6s %8d\n", algo_names[a], simulate((Algo)a, nframes, refs, nrefs));
    return EXIT_SUCCESS;
  }
  for (int a = FIFO; a <= CLOCK; a++) {
    if (strcasecmp(argv[1], algo_names[a]) == 0) {
      int faults = simulate((Algo)a, nframes, refs, nrefs);
      print_table((Algo)a, nframes, refs, nrefs, faults);
      return EXIT_SUCCESS;
    }
  }
  fprintf(stderr, "Thuật toán không hợp lệ: %s\n", argv[1]);
  return EXIT_FAILURE;
}
