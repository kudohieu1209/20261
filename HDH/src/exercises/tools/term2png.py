#!/usr/bin/env python3
"""term2png.py - Vẽ transcript terminal (lệnh + output thật) thành ảnh PNG giống cửa sổ Ptyxis (GNOME).

Cách dùng: term2png.py <transcript.txt> <output.png> [thư mục hiện tại]
Trong transcript, dòng bắt đầu bằng "$ " là lệnh (vẽ kèm prompt bash có màu),
các dòng còn lại là output được vẽ nguyên văn.
Màu lấy từ palette HDH-Dark và thanh tiêu đề Ptyxis 50 trên máy KudoHieu-Legion5.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

FONT_DIR = os.path.expanduser("~/.local/share/fonts/jetbrains-mono")
FALLBACK = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
UI_FONT = "/usr/share/fonts/truetype/ubuntu/UbuntuSans[wdth,wght].ttf"
FONT_SIZE = 16
LINE_H = 22
PAD_X, PAD_Y = 14, 12
HEADER_H, RADIUS = 46, 12

BG = (30, 33, 40)            # nền terminal (palette HDH-Dark)
HEADER_BG = (36, 41, 52)     # thanh tiêu đề Ptyxis
HEADER_EDGE = (22, 23, 30)   # đường viền dưới thanh tiêu đề
BUTTON_BG = (58, 62, 72)     # nền tròn của nút thu nhỏ / phóng to / đóng
ICON = (238, 238, 239)
SUBTITLE = (156, 159, 164)
FG = (220, 223, 228)
GREEN = (138, 226, 52)
BLUE = (114, 159, 207)

PROMPT_USER = "hieu_20223967@KudoHieu-Legion5"


def load_font(name):
    path = os.path.join(FONT_DIR, name)
    return ImageFont.truetype(path if os.path.exists(path) else FALLBACK, FONT_SIZE)


def ui_font(size, weight):
    try:
        font = ImageFont.truetype(UI_FONT, size)
        font.set_variation_by_name(weight)
        return font
    except (OSError, ValueError):
        return ImageFont.truetype(FALLBACK, size)


def pretty_cwd(cwd):
    home = os.path.expanduser("~")
    return "~" + cwd[len(home):] if cwd.startswith(home) else cwd


def draw_header(draw, width, cwd):
    """Thanh tiêu đề kiểu libadwaita: [tab mới]  tiêu đề + dòng phụ  [lưới][menu] (–)(□)(×)"""
    draw.rounded_rectangle([0, 0, width - 1, HEADER_H + RADIUS], RADIUS, fill=HEADER_BG)
    draw.rectangle([0, HEADER_H, width - 1, HEADER_H + RADIUS], fill=BG)
    draw.line([(0, HEADER_H), (width, HEADER_H)], fill=HEADER_EDGE, width=1)
    cy = HEADER_H // 2

    # Nút "tab mới": khung tab hở đáy, có dấu + bên trong
    x0, x1, yt, yb = 20, 34, cy - 7, cy + 7
    draw.line([(x0 - 3, yb), (x0, yb), (x0, yt), (x1, yt), (x1, yb), (x1 + 3, yb)], fill=ICON, width=2)
    draw.line([(x0 + 4, cy + 1), (x1 - 4, cy + 1)], fill=ICON, width=2)
    draw.line([((x0 + x1) // 2, cy - 3), ((x0 + x1) // 2, cy + 5)], fill=ICON, width=2)

    # Tiêu đề do bash đặt: "user@host: thư mục", dòng phụ là thư mục
    title, sub = f"{PROMPT_USER}: {cwd}", cwd
    f_title, f_sub = ui_font(15, "Bold"), ui_font(12, "Regular")
    draw.text(((width - draw.textlength(title, font=f_title)) / 2, 6), title, font=f_title, fill=ICON)
    draw.text(((width - draw.textlength(sub, font=f_sub)) / 2, 26), sub, font=f_sub, fill=SUBTITLE)

    # Ba nút tròn bên phải: thu nhỏ, phóng to, đóng
    r, gap = 12, 33
    cx_close = width - 24
    centers = [cx_close - 2 * gap, cx_close - gap, cx_close]
    for cx in centers:
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=BUTTON_BG)
    mx, xx, cx = centers
    draw.line([(mx - 4, cy + 3), (mx + 4, cy + 3)], fill=ICON, width=2)
    draw.rectangle([xx - 4, cy - 4, xx + 4, cy + 4], outline=ICON, width=1)
    draw.line([(cx - 4, cy - 4), (cx + 4, cy + 4)], fill=ICON, width=2)
    draw.line([(cx - 4, cy + 4), (cx + 4, cy - 4)], fill=ICON, width=2)

    # Nút menu (3 gạch) và nút xem tab (lưới 2x2)
    hx = mx - 44
    for dy in (-5, 0, 5):
        draw.line([(hx - 6, cy + dy), (hx + 6, cy + dy)], fill=ICON, width=1)
    gx = hx - 40
    for dx in (-6, 2):
        for dy in (-6, 2):
            draw.rectangle([gx + dx, cy + dy, gx + dx + 4, cy + dy + 4], outline=ICON, width=1)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    src, dst = sys.argv[1], sys.argv[2]
    cwd = pretty_cwd(sys.argv[3] if len(sys.argv) > 3 else os.getcwd())

    with open(src, encoding="utf-8", errors="replace") as f:
        lines = [l.rstrip("\n").expandtabs(8) for l in f]
    while lines and not lines[-1].strip():
        lines.pop()

    regular, bold = load_font("JetBrainsMonoNL-Regular.ttf"), load_font("JetBrainsMonoNL-Bold.ttf")
    char_w = regular.getlength("M")
    prompt = f"{PROMPT_USER}:{cwd}$ "
    widest = max(len(prompt) + len(l) - 2 if l.startswith("$ ") else len(l) for l in lines)
    width = max(900, int(widest * char_w) + 2 * PAD_X)
    height = HEADER_H + 2 * PAD_Y + LINE_H * len(lines)

    # Nền trong suốt để thấy góc bo tròn của cửa sổ
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, width - 1, height - 1], RADIUS, fill=BG)
    draw_header(draw, width, cwd)

    y = HEADER_H + PAD_Y
    for line in lines:
        x = PAD_X
        if line.startswith("$ "):
            for text, font, color in [(PROMPT_USER, bold, GREEN), (":", regular, FG),
                                      (cwd, bold, BLUE), ("$ ", regular, FG),
                                      (line[2:], regular, FG)]:
                draw.text((x, y), text, font=font, fill=color)
                x += char_w * len(text)
        else:
            draw.text((x, y), line, font=regular, fill=FG)
        y += LINE_H
    img.save(dst)


if __name__ == "__main__":
    main()
