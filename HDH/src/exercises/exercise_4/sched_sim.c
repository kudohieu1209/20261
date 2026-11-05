/*
 * sched_sim.c - Mô phỏng các thuật toán lập lịch CPU (Chương 2 - Task Scheduling)
 *
 *   FCFS   : First Come First Served          (không chiếm quyền)
 *   SJF    : Shortest Job First               (không chiếm quyền)
 *   SRTF   : Shortest Remaining Time First    (chiếm quyền - SJF preemptive)
 *   PRIO   : Priority                         (không chiếm quyền)
 *   PPRIO  : Priority                         (chiếm quyền)
 *   RR     : Round Robin với lượng tử q
 *
 * Quy ước: số priority NHỎ hơn = ưu tiên CAO hơn (giống sách Silberschatz).
 * Mô phỏng theo từng đơn vị thời gian (tick), nên mọi thời gian là số nguyên.
 *
 * Cách dùng:  ./sched_sim <fcfs|sjf|srtf|prio|pprio|rr|all> <file> [quantum]
 * File input: mỗi dòng "Tên Arrival Burst [Priority]", dòng bắt đầu bằng # bị bỏ qua.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#define MAX_PROC 64
#define MAX_SEG 4096
#define NAME_LEN 16

typedef struct {
  char name[NAME_LEN];
  int arrival, burst, prio;
  int remaining;
  int start;  /* lần đầu được chạy (-1 = chưa chạy) */
  int finish; /* thời điểm kết thúc (-1 = chưa xong) */
} Proc;

typedef struct {
  int pid; /* -1 = CPU rảnh (idle) */
  int start, end;
} Segment; /* một ô trên biểu đồ Gantt */

typedef enum { FCFS, SJF, SRTF, PRIO, PPRIO, RR } Algo;

static const char *algo_names[] = {"FCFS", "SJF", "SRTF", "PRIO", "PPRIO", "RR"};

static Proc procs[MAX_PROC];
static int nproc;
static Segment gantt[MAX_SEG];
static int nseg;

static int load_file(const char *path) {
  FILE *f = fopen(path, "r");
  if (!f) {
    perror(path);
    return -1;
  }
  char line[256];
  nproc = 0;
  while (fgets(line, sizeof line, f)) {
    char *p = line;
    while (*p == ' ' || *p == '\t')
      p++;
    if (*p == '#' || *p == '\n' || *p == '\0')
      continue;
    if (nproc == MAX_PROC) {
      fprintf(stderr, "Quá %d tiến trình\n", MAX_PROC);
      break;
    }
    Proc *pr = &procs[nproc];
    pr->prio = 0;
    int got = sscanf(p, "%15s %d %d %d", pr->name, &pr->arrival, &pr->burst, &pr->prio);
    if (got < 3 || pr->arrival < 0 || pr->burst <= 0) {
      fprintf(stderr, "Dòng không hợp lệ: %s", line);
      continue;
    }
    nproc++;
  }
  fclose(f);
  return nproc > 0 ? 0 : -1;
}

static void reset(void) {
  for (int i = 0; i < nproc; i++) {
    procs[i].remaining = procs[i].burst;
    procs[i].start = -1;
    procs[i].finish = -1;
  }
  nseg = 0;
}

/* Ghi tick [t, t+1) cho pid vào Gantt, gộp với ô trước nếu cùng tiến trình */
static void record(int pid, int t) {
  if (nseg > 0 && gantt[nseg - 1].pid == pid && gantt[nseg - 1].end == t) {
    gantt[nseg - 1].end = t + 1;
    return;
  }
  if (nseg == MAX_SEG)
    return;
  gantt[nseg++] = (Segment){pid, t, t + 1};
}

/* Khóa so sánh của từng thuật toán: nhỏ hơn = được chọn trước */
static int key(Algo a, const Proc *p) {
  switch (a) {
  case SJF:
    return p->burst;
  case SRTF:
    return p->remaining;
  case PRIO:
  case PPRIO:
    return p->prio;
  default:
    return p->arrival; /* FCFS */
  }
}

/* Chọn tiến trình sẵn sàng có key nhỏ nhất; hòa thì ưu tiên tiến trình đang chạy
 * (tránh chuyển ngữ cảnh thừa), rồi đến arrival sớm hơn, rồi thứ tự trong file. */
static int pick(Algo a, int t, int cur) {
  int best = -1;
  for (int i = 0; i < nproc; i++) {
    Proc *p = &procs[i];
    if (p->arrival > t || p->remaining == 0)
      continue;
    if (best == -1) {
      best = i;
      continue;
    }
    int ki = key(a, p), kb = key(a, &procs[best]);
    if (ki != kb) {
      if (ki < kb)
        best = i;
      continue;
    }
    if (best != cur && (i == cur || p->arrival < procs[best].arrival))
      best = i;
  }
  return best;
}

static int all_done(void) {
  for (int i = 0; i < nproc; i++)
    if (procs[i].remaining > 0)
      return 0;
  return 1;
}

static void run_tick(int cur, int t) {
  record(cur, t);
  if (cur < 0)
    return;
  Proc *p = &procs[cur];
  if (p->start < 0)
    p->start = t;
  if (--p->remaining == 0)
    p->finish = t + 1;
}

static void simulate_priority_like(Algo a) {
  int preemptive = (a == SRTF || a == PPRIO);
  int cur = -1;
  for (int t = 0; !all_done(); t++) {
    if (cur >= 0 && procs[cur].remaining == 0)
      cur = -1;
    if (cur < 0 || preemptive)
      cur = pick(a, t, cur);
    run_tick(cur, t);
  }
}

static void simulate_rr(int q) {
  int queue[MAX_PROC], head = 0, size = 0;
  int enqueued[MAX_PROC] = {0};
  int cur = -1, slice = 0;

  for (int t = 0; !all_done(); t++) {
    /* 1. Tiến trình mới đến được xếp vào cuối hàng đợi TRƯỚC tiến trình vừa hết lượng tử */
    for (int i = 0; i < nproc; i++)
      if (!enqueued[i] && procs[i].arrival <= t) {
        enqueued[i] = 1;
        queue[(head + size++) % MAX_PROC] = i;
      }
    /* 2. Hết lượng tử -> quay về cuối hàng đợi */
    if (cur >= 0 && slice == q) {
      queue[(head + size++) % MAX_PROC] = cur;
      cur = -1;
    }
    /* 3. CPU rảnh -> lấy tiến trình đầu hàng đợi */
    if (cur < 0 && size > 0) {
      cur = queue[head];
      head = (head + 1) % MAX_PROC;
      size--;
      slice = 0;
    }
    run_tick(cur, t);
    if (cur >= 0) {
      slice++;
      if (procs[cur].remaining == 0)
        cur = -1;
    }
  }
}

static const char *seg_name(int pid) { return pid < 0 ? "--" : procs[pid].name; }

static void print_gantt(void) {
  int width[MAX_SEG];
  printf("\nGantt chart (\"--\" = CPU rảnh):\n|");
  for (int i = 0; i < nseg; i++) {
    width[i] = (int)strlen(seg_name(gantt[i].pid)) + 2;
    if (width[i] < 4)
      width[i] = 4;
    int pad = width[i] - (int)strlen(seg_name(gantt[i].pid));
    printf("%*s%s%*s|", pad / 2, "", seg_name(gantt[i].pid), pad - pad / 2, "");
  }
  printf("\n%-*d", width[0] + 1, gantt[0].start);
  for (int i = 0; i < nseg; i++)
    printf("%-*d", i + 1 < nseg ? width[i + 1] + 1 : 1, gantt[i].end);
  printf("\n");
}

static int context_switches(void) {
  int n = 0, last = -1;
  for (int i = 0; i < nseg; i++) {
    if (gantt[i].pid < 0)
      continue;
    if (last >= 0 && gantt[i].pid != last)
      n++;
    last = gantt[i].pid;
  }
  return n;
}

/* In bảng kết quả, trả về thời gian chờ trung bình */
static double print_table(int verbose) {
  double sum_tat = 0, sum_wt = 0, sum_rt = 0;
  int end = gantt[nseg - 1].end, busy = 0;
  for (int i = 0; i < nseg; i++)
    if (gantt[i].pid >= 0)
      busy += gantt[i].end - gantt[i].start;

  if (verbose)
    printf("\n%-6s %4s %4s %4s | %5s %6s %4s %4s %4s\n", "Name", "AT", "BT", "PR", "Start",
           "Finish", "TAT", "WT", "RT");
  for (int i = 0; i < nproc; i++) {
    Proc *p = &procs[i];
    int tat = p->finish - p->arrival; /* Turnaround = Completion - Arrival */
    int wt = tat - p->burst;          /* Waiting    = Turnaround - Burst   */
    int rt = p->start - p->arrival;   /* Response   = First run - Arrival  */
    sum_tat += tat;
    sum_wt += wt;
    sum_rt += rt;
    if (verbose)
      printf("%-6s %4d %4d %4d | %5d %6d %4d %4d %4d\n", p->name, p->arrival, p->burst, p->prio,
             p->start, p->finish, tat, wt, rt);
  }
  if (verbose) {
    printf("\nAvg TAT = %.2f   Avg WT = %.2f   Avg RT = %.2f\n", sum_tat / nproc, sum_wt / nproc,
           sum_rt / nproc);
    printf("CPU utilization = %.1f%%   Throughput = %.3f proc/unit   Context switches = %d\n",
           100.0 * busy / end, (double)nproc / end, context_switches());
  } else {
    printf(" %8.2f %8.2f %8.2f %6d\n", sum_tat / nproc, sum_wt / nproc, sum_rt / nproc,
           context_switches());
  }
  return sum_wt / nproc;
}

static void run(Algo a, int q, int verbose) {
  reset();
  if (a == RR)
    simulate_rr(q);
  else
    simulate_priority_like(a);
  if (verbose) {
    if (a == RR)
      printf("=== RR (quantum = %d) ===\n", q);
    else
      printf("=== %s ===\n", algo_names[a]);
    print_gantt();
  } else {
    printf("%-6s", algo_names[a]);
  }
  print_table(verbose);
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Cách dùng: %s <fcfs|sjf|srtf|prio|pprio|rr|all> <file> [quantum]\n", argv[0]);
    return EXIT_FAILURE;
  }
  int q = argc > 3 ? atoi(argv[3]) : 2;
  if (q <= 0) {
    fprintf(stderr, "quantum phải > 0\n");
    return EXIT_FAILURE;
  }
  if (load_file(argv[2]) < 0)
    return EXIT_FAILURE;

  if (strcmp(argv[1], "all") == 0) {
    printf("So sánh các thuật toán (RR quantum = %d)\n", q);
    printf("%-6s %8s %8s %8s %6s\n", "Algo", "AvgTAT", "AvgWT", "AvgRT", "CtxSw");
    for (int a = FCFS; a <= RR; a++)
      run((Algo)a, q, 0);
    return EXIT_SUCCESS;
  }
  for (int a = FCFS; a <= RR; a++) {
    if (strcasecmp(argv[1], algo_names[a]) == 0) {
      run((Algo)a, q, 1);
      return EXIT_SUCCESS;
    }
  }
  fprintf(stderr, "Thuật toán không hợp lệ: %s\n", argv[1]);
  return EXIT_FAILURE;
}
