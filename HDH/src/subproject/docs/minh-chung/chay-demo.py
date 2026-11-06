#!/usr/bin/env python3
"""Chạy một kịch bản demo trên xv6 thật (QEMU) để chụp ảnh minh chứng.

Script khởi động xv6 bằng `make qemu`, tự gõ phím theo kịch bản (giống test-jobctl.py),
hiện toàn bộ output ra terminal, rồi DỪNG LẠI để bạn chụp màn hình.

Cách dùng (chạy trong thư mục xv6-tty, cần python3-pexpect):
    python3 ../docs/minh-chung/chay-demo.py            # liệt kê kịch bản
    python3 ../docs/minh-chung/chay-demo.py t3-demo    # chạy một kịch bản
"""
import sys, time
import pexpect

Z, C, P, T, D = "\x1a", "\x03", "\x10", "\x14", "\x04"
UP, LEFT = "\x1b[A", "\x1b[D"

# tên: (minh chứng nào, [(phím gõ, số giây chờ sau đó)])
SCENES = {
    "t3-demo": ("Tuần 3, minh chứng d: counter → Ctrl-Z → Ctrl-P → fg → Ctrl-C → Ctrl-P",
                [("counter\r", 3), (Z, 1), (P, 1), ("fg\r", 2.5), (C, 1), (P, 1)]),
    "t4-jobs": ("Tuần 4, minh chứng c: counter → Ctrl-Z → jobs → Ctrl-P → bg → jobs → fg → Ctrl-C",
                [("counter\r", 2.5), (Z, 1), ("jobs\r", 1), (P, 1), ("bg\r", 2), ("jobs\r", 1.5),
                 ("fg\r", 2), (C, 1)]),
    "t4-cat": ("Tuần 4, minh chứng d: cat & → jobs → fg → hello → Ctrl-D",
               [("cat &\r", 1), ("jobs\r", 1), ("fg\r", 1), ("hello\r", 1), (D, 1)]),
    "t5-pipe": ("Tuần 5, minh chứng c: counter | cat → Ctrl-Z → Ctrl-P → fg → Ctrl-C → Ctrl-P",
                [("counter | cat\r", 2.5), (Z, 1), (P, 1), ("fg\r", 2), (C, 1), (P, 1)]),
    "t5-orphan": ("Tuần 5, minh chứng d: counter | cat → Ctrl-Z → exit → Ctrl-P",
                  [("counter | cat\r", 2), (Z, 1), ("exit\r", 2), (P, 1)]),
    "t6-tty": ("Tuần 6, minh chứng c: hai terminal ảo (Ctrl-T)",
               [(T, 1), ("echo on-tty1\r", 1), ("counter\r", 2), (T, 2.5), ("echo on-tty0\r", 1),
                (T, 1.5), (C, 1)]),
    "t6-history": ("Tuần 6, minh chứng d: lịch sử lệnh và sửa dòng",
                   [("echo first\r", 0.7), ("echo second\r", 0.7), (UP + UP + "\r", 1),
                    ("echo hllo" + LEFT * 3 + "e\r", 1), ("history\r", 1)]),
    "t7-spin": ("Tuần 7, minh chứng c (DEMO.md phần 3): spin → Ctrl-Z → kill %1 → jobs",
                [("spin\r", 1.5), (Z, 1), ("kill %1\r", 1), ("jobs\r", 1)]),
}


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in SCENES:
        print(__doc__)
        for k, (what, _) in SCENES.items():
            print(f"  {k:<11} {what}")
        return
    what, steps = SCENES[sys.argv[1]]
    c = pexpect.spawn("make qemu", encoding="utf-8", codec_errors="replace", timeout=60)
    c.expect(r"\$ ")
    time.sleep(0.5)
    print("\033[2J\033[H", end="")  # xoá màn hình để ảnh chỉ có phần demo
    print(f"[{what}] (phím do chay-demo.py gõ hộ)\n$ ", end="", flush=True)
    c.logfile_read = sys.stdout

    def drain(sec):
        end = time.time() + sec
        while time.time() < end:
            try:
                c.read_nonblocking(4096, timeout=0.1)
            except pexpect.TIMEOUT:
                pass

    for keys, wait in steps:
        for ch in keys:
            c.send(ch)
            time.sleep(0.02)
        drain(wait)
    c.logfile_read = None
    try:
        input("\n\n>>> CHỤP MÀN HÌNH BÂY GIỜ. Xong thì nhấn Enter để tắt QEMU. ")
    except EOFError:
        pass
    c.sendcontrol("a")
    c.send("x")
    c.expect(pexpect.EOF)


if __name__ == "__main__":
    main()
