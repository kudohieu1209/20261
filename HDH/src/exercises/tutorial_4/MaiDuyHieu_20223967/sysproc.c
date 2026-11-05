#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if (t == SBRK_EAGER || n < 0) {
    if (growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
      return -1;
    if (addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if (n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    release(&tickslock);
    sleep();
    acquire(&tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// Tutorial 4: syscall chạy trong kernel, in ra console bằng printk.
uint64
sys_hello(void)
{
  struct proc *p = myproc();
  printk("kernel: hello() called by pid %d (running in kernel)\n", p->pid);
  return 0;
}

// Bài tập 6.1: cấp phát bộ nhớ trong kernel.
// Xin 1 trang (4096 byte) bằng kalloc(), ghi dữ liệu vào, rồi trả lại bằng kfree().
uint64
sys_kmem(void)
{
  char *page = kalloc();
  if(page == 0){
    printk("kernel: kalloc() failed, out of memory\n");
    return -1;
  }
  printk("kernel: kalloc() -> page at %p (%d bytes)\n", page, PGSIZE);

  memset(page, 0, PGSIZE);
  safestrcpy(page, "data written in kernel memory", PGSIZE);
  printk("kernel: page content = \"%s\"\n", page);

  kfree(page);
  printk("kernel: kfree(%p) done\n", page);
  return 0;
}

// Bài tập 6.2: liệt kê các tiến trình đang dùng trong bảng proc[].
extern struct proc proc[NPROC];

uint64
sys_ps(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [USED]      "used",
  [SLEEPING]  "sleeping",
  [RUNNABLE]  "runnable",
  [RUNNING]   "running",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  int n = 0;

  printk("PID\tSTATE\t\tNAME\n");
  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->state != UNUSED){
      printk("%d\t%s\t%s\n", p->pid, states[p->state], p->name);
      n++;
    }
    release(&p->lock);
  }
  printk("total: %d process(es)\n", n);
  return n;
}
