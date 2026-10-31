#!/usr/bin/env python3
"""Draws the one pixel font left, the numbers on the clock boss, as a BMFont (a
.fnt and its .png), which Godot imports as it is and draws without any blur:

    assets/fonts/heading.fnt   Vermin Vibes 1989 (the original game's logo font), 16 tall

The UI doesn't use it: that's in the TTFs themselves, at full resolution.

    python3 tools/make_font.py
"""
import argparse
import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
OUT = os.path.join(REPO, "assets", "fonts")

def write_fnt(name, glyphs, cell_h, base, line_height, size):
    """Lays the glyphs out in rows in a PNG and writes the BMFont text beside it."""
    columns = 512
    image = Image.new("RGBA", (columns, 8), (0, 0, 0, 0))
    x = y = 1
    lines = []
    rows_used = cell_h + 2
    placed = {}
    for ch, (bitmap, advance) in glyphs.items():
        w, h = bitmap.size
        if x + w + 1 >= columns:
            x = 1
            y += rows_used
        placed[ch] = (x, y, w, h, advance)
        x += w + 2
    image = Image.new("RGBA", (columns, y + rows_used), (0, 0, 0, 0))
    for ch, (bitmap, advance) in glyphs.items():
        px, py, w, h, _ = placed[ch]
        image.paste(bitmap, (px, py))
    image.save(os.path.join(OUT, name + ".png"))
    lines.append(f'info face="{name}" size={size} bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=1,1 outline=0')
    lines.append(f'common lineHeight={line_height} base={base} scaleW={image.width} scaleH={image.height} pages=1 packed=0 alphaChnl=0 redChnl=4 greenChnl=4 blueChnl=4')
    lines.append(f'page id=0 file="{name}.png"')
    lines.append(f"chars count={len(placed)}")
    for ch, (px, py, w, h, advance) in placed.items():
        lines.append(f"char id={ord(ch)} x={px} y={py} width={w} height={h} xoffset=0 yoffset=0 xadvance={advance} page=0 chnl=15")
    with open(os.path.join(OUT, name + ".fnt"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(f"{name}: {len(placed)} glyphs, {image.width}x{image.height}")


def vermin_font(name, size):
    path = os.path.join(OUT, "vermin_vibes_1989.ttf")
    font = ImageFont.truetype(path, size)
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,:;!?'-+/()&%"
    ascent, descent = font.getmetrics()
    height = ascent + descent + 1
    glyphs = {}
    for ch in chars:
        advance = max(int(round(font.getlength(ch))), 2) + 1
        bitmap = Image.new("L", (advance + 2, height), 0)
        draw = ImageDraw.Draw(bitmap)
        draw.fontmode = "1"
        draw.text((0, 0), ch, font=font, fill=255)
        rgba = Image.new("RGBA", bitmap.size, (255, 255, 255, 0))
        rgba.putalpha(bitmap.point(lambda v: 255 if v > 127 else 0))
        glyphs[ch] = (rgba, advance)
    write_fnt(name, glyphs, height, ascent, height, size)


def main():
    os.makedirs(OUT, exist_ok=True)
    vermin_font("heading", 16)


if __name__ == "__main__":
    main()
