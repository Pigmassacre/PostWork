#!/usr/bin/env python3
"""Makes every sprite in assets/sprites/, and icon.svg.

The ship, the froglet, the starball, the yellowcrab and the floor are the
original game's, from art/original, copied as they are. Everything new is drawn
here to match them: in the same palette (DawnBringer's 32, which the originals
are in), as text where a letter is a colour and a dot is nothing, with the
black outline they all wear added afterwards.

    python3 tools/make_sprites.py
"""
import math
import os
import shutil

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
OUT = os.path.join(REPO, "assets", "sprites")
ORIG = os.path.join(REPO, "art", "original")

PALETTE = {
    "k": "000000", "n": "222034", "p": "45283c", "m": "663931", "b": "8f563b", "o": "df7126", "t": "d9a066",
    "s": "eec39a", "y": "fbf236", "g": "99e550", "G": "6abe30", "e": "37946e", "E": "4b692f", "D": "524b24",
    "d": "323c39", "i": "3f3f74", "j": "306082", "B": "5b6ee1", "L": "639bff", "c": "5fcde4", "C": "cbdbfc",
    "w": "ffffff", "h": "9badb7", "H": "847e87", "f": "696a6a", "F": "595652", "v": "76428a", "r": "ac3232",
    "R": "d95763", "P": "d77bba", "O": "8f974a", "T": "8a6f30",
}


def rgba(letter, alpha=255):
    h = PALETTE[letter]
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), alpha)


def from_text(text):
    rows = text.split()
    image = Image.new("RGBA", (max(len(r) for r in rows), len(rows)), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c != ".":
                image.putpixel((x, y), rgba(c))
    return image


def outlined(image):
    """One pixel bigger all round, with a black edge round what's there."""
    out = Image.new("RGBA", (image.width + 2, image.height + 2), (0, 0, 0, 0))
    for y in range(image.height):
        for x in range(image.width):
            if image.getpixel((x, y))[3] > 0:
                for dx in (-1, 0, 1):
                    for dy in (-1, 0, 1):
                        out.putpixel((x + 1 + dx, y + 1 + dy), (0, 0, 0, 255))
    out.paste(image, (1, 1), image)
    return out


def save(name, image):
    image.save(os.path.join(OUT, name + ".png"))


def text_sprite(name, *frames):
    for i, frame in enumerate(frames):
        save(f"{name}{i + 1}" if len(frames) > 1 else name, outlined(from_text(frame)))


# --- what's new, in text. They all face up, as the originals do. -----------------------------------
TEXT = {
    "tadpole": ["""
..cc..
.cwwc.
.cccc.
..cc..
..j...
...j..""", """
..cc..
.cwwc.
.cccc.
..cc..
...j..
..j..."""],
    "squid": ["""
..PP..
.PPPP.
.kPPk.
.PPPP.
P.PP.P
.P..P.""", """
..PP..
.PPPP.
.kPPk.
.PPPP.
.PPPP.
P.PP.P"""],
    "urchin": ["""
r..rr..r
.r.RR.r.
..RRRR..
rRRyyRRr
rRRyyRRr
..RRRR..
.r.RR.r.
r..rr..r""", """
..r..r..
r..RR..r
..RRRR..
.RRwwRR.
.RRwwRR.
..RRRR..
r..RR..r
..r..r.."""],
    "hermit": ["""
...hhhh...
..hCCChh..
.hCCChhHH.
.hChhhHHH.
.hhhHHHff.
.HHHHHfff.
..HHfffF..
y.yFFFFy.y
.yyy..yyy.
y..y..y..y""", """
...hhhh...
..hCCChh..
.hCCChhHH.
.hChhhHHH.
.hhhHHHff.
.HHHHHfff.
..HHfffF..
.yyFFFFyy.
y.yy..yy.y
..y....y.."""],
    "train_head": ["""
..LLLLLLLL..
.LLLLLLLLLL.
.LccccccccL.
.LcCCCCCCcL.
.LccccccccL.
.BLLLLLLLLB.
.BwLLLLLLwB.
.BLLLLLLLLB.
.BBBBBBBBBB.
.BiiBBBBiiB.
.BiiBBBBiiB.
.BBBBBBBBBB."""],
    "train_car": ["""
.iiiiiiii.
.BBBBBBBB.
.BcBBBBcB.
.BcBBBBcB.
.BBBBBBBB.
.BcBBBBcB.
.BcBBBBcB.
.BBBBBBBB.
.iiiiiiii."""],
    "train_car_hurt": ["""
.iiiiiiii.
.BBBBrBBB.
.BcBrBBkB.
.BkBBrBcB.
.BBrBBBBB.
.BcBBrBkB.
.BkBBBBcB.
.BBBrBBBB.
.iiiiiiii."""],
    "coffee": ["""
.w.w..
..w.w.
CCCCC.
CmmmCCC
CCCCC.C
CCCCCC.
.CCC.."""],
    "coin1": ["""
.yyy.
yyTyy
yyTyy
yyTyy
.yyy."""],
    "coin2": ["""
.yy.
yTyy
yTyy
yTyy
.yy."""],
    "coin3": ["""
.y.
yTy
yTy
yTy
.y."""],
    "coin4": ["""
y
y
y
y
y"""],
    "hull_pip": ["""
...L...
..LLL..
.LLcLL.
LLLLLLL
LL.o.LL"""],
    "shot_round": ["""
.yy.
yywy
yyyy
.yy."""],
    "shot_small": ["""
yw
yy"""],
    "shot_star": ["""
..P..
.PPP.
PPwPP
.PPP.
..P.."""],
    "shot_mail": ["""
CCCCCC
CwCCwC
CCwwCC
CCCCCC"""],
    # The perks' icons.
    "perk_twin": ["""
.c...c.
ccc.ccc
.c...c.
.c...c.
.c...c.
.h...h.
.c...c."""],
    "perk_warhead": ["""
...r...
..rRr..
..hwh..
..hwh..
..hwh..
.ohhho.
.o.y.o."""],
    "perk_frag": ["""
o..y..o
.o.y.o.
..yyy..
yyywyyy
..yyy..
.o.y.o.
o..y..o"""],
    "perk_track": ["""
...c...
.ccccc.
.c...c.
cc.w.cc
.c...c.
.ccccc.
...c..."""],
    "perk_burn": ["""
...o...
..oo...
..oyo..
.ooyoo.
.oyyyo.
.oywyo.
..oyo.."""],
    "perk_slick": ["""
.......
.LL..L.
L..LL..
.......
.cc..c.
c..cc..
......."""],
    "perk_bumper": ["""
g.....g
.g...g.
..g.g..
...g...
.......
yyyyyyy
yyyyyyy"""],
    "perk_ram": ["""
...w...
..wCw..
..wCw..
.wCCCw.
.wCCCw.
wCC.CCw
C.....C"""],
    "perk_fuse": ["""
...yy..
..yy...
.yy....
.yyyyy.
....yy.
...yy..
..yy..."""],
    "perk_long": ["""
.......
....y..
.....y.
yyyyyyy
.....y.
....y..
......."""],
    "perk_shock": ["""
..RRR..
.R...R.
R..w..R
R.www.R
R..w..R
.R...R.
..RRR.."""],
    "perk_echo": ["""
.c.c.c.
ccccccc
.c.c.c.
.c.c.c.
.c.c.c.
.c.c.c.
.h.h.h."""],
    "perk_hull": ["""
.LLLLL.
LLLwLLL
LLLwLLL
LwwwwwL
LLLwLLL
.LLwLL.
..LLL.."""],
    "perk_second": ["""
.RR.RR.
RRRRRwR
RRRRRRR
RRRRRRR
.RRRRR.
..RRR..
...R..."""],
    "perk_magnet": ["""
.rrrrr.
rrrrrrr
rr...rr
rr...rr
rr...rr
hh...hh
hh...hh"""],
    "perk_pay": ["""
...g...
.ggggg.
g..g...
.gggg..
...g.g.
ggggg..
...g..."""],
}


def drawn():
    # The frogspawn: a clutch of eggs, their dots turning.
    eggs = [(4, 3), (10, 3), (1, 7), (7, 7), (13, 7), (4, 11), (10, 11)]
    for frame in (0, 1):
        s = 3
        image = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
        draw = ImageDraw.Draw(image)
        for i, (x, y) in enumerate(eggs):
            draw.ellipse((x - s + 1, y - s + 1, x + s - 1 + 1, y + s - 1 + 1), fill=rgba("E"))
        for i, (x, y) in enumerate(eggs):
            draw.ellipse((x - 1, y - 1, x + 2, y + 2), fill=rgba("g" if (i + frame) % 2 == 0 else "G"))
            image.putpixel((x + (frame + i) % 2, y + (frame + i + 1) % 2), rgba("k"))
        save(f"frogspawn{frame + 1}", outlined(image))

    # Reply All: an envelope, at each size it splits to.
    for name, w, h in (("mail_big", 30, 20), ("mail_mid", 14, 10), ("mail_small", 8, 6)):
        for frame in (0, 1):
            image = Image.new("RGBA", (w, h), rgba("C"))
            draw = ImageDraw.Draw(image)
            draw.rectangle((0, h - 1 - max(1, h // 8), w - 1, h - 1), fill=rgba("h"))
            flap = rgba("H")
            mid_y = h // 2 + (1 if frame else 0)
            draw.line((0, 0, w // 2, mid_y), fill=flap)
            draw.line((w - 1, 0, w - w // 2 - 1, mid_y), fill=flap)
            if w > 10:
                # The seal, and two furious eyes.
                seal = max(1, w // 10)
                draw.ellipse((w // 2 - seal, mid_y - seal, w // 2 + seal - 1 + 1, mid_y + seal), fill=rgba("r"))
                eye = max(1, w // 15)
                draw.rectangle((w // 5, h // 2 + 1, w // 5 + eye, h // 2 + 1 + eye), fill=rgba("k"))
                draw.rectangle((w - w // 5 - eye - 1, h // 2 + 1, w - w // 5 - 1, h // 2 + 1 + eye), fill=rgba("k"))
            else:
                image.putpixel((w // 2 - 1, mid_y), rgba("r"))
                image.putpixel((w // 2, mid_y), rgba("r"))
            save(f"{name}{frame + 1}", outlined(image))

    # The bumper: a pinball's.
    for frame in (0, 1):
        s = 14
        image = Image.new("RGBA", (s, s), (0, 0, 0, 0))
        draw = ImageDraw.Draw(image)
        draw.ellipse((0, 0, s - 1, s - 1), fill=rgba("r" if frame == 0 else "o"))
        draw.ellipse((2, 2, s - 3, s - 3), fill=rgba("R" if frame == 0 else "y"))
        draw.ellipse((4, 4, s - 5, s - 5), fill=rgba("C" if frame == 0 else "w"))
        save(f"bumper{frame + 1}", outlined(image))

    # A soft round glow, for what shines (drawn additively).
    s = 32
    glow = Image.new("RGBA", (s, s), (255, 255, 255, 0))
    for y in range(s):
        for x in range(s):
            d = math.hypot(x + 0.5 - s / 2, y + 0.5 - s / 2) / (s / 2)
            glow.putpixel((x, y), (255, 255, 255, int(255 * max(0.0, 1.0 - d) ** 2)))
    save("glow", glow)


def icon():
    """The ship, as pixels in an SVG, on the floor's dark."""
    ship = Image.open(os.path.join(ORIG, "player_ship3.png")).convert("RGBA")
    scale = 8
    size = (ship.width + 4) * scale
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" shape-rendering="crispEdges">',
        f'<rect width="{size}" height="{size}" rx="{scale * 2}" fill="#{PALETTE["n"]}"/>']
    for y in range(ship.height):
        for x in range(ship.width):
            r, g, b, a = ship.getpixel((x, y))
            if a > 0:
                parts.append(f'<rect x="{(x + 2) * scale}" y="{(y + 2) * scale}" width="{scale}" height="{scale}" fill="#{r:02x}{g:02x}{b:02x}"/>')
    parts.append("</svg>")
    with open(os.path.join(REPO, "icon.svg"), "w", encoding="utf-8") as f:
        f.write("\n".join(parts) + "\n")


def main():
    os.makedirs(OUT, exist_ok=True)
    for name in ("froglet_enemy1", "froglet_enemy2", "starball_enemy1", "starball_enemy2", "yellowcrab_enemy1", "yellowcrab_enemy2",
            "player_ship1", "player_ship2", "player_ship3", "player_ship4", "bg"):
        shutil.copyfile(os.path.join(ORIG, name + ".png"), os.path.join(OUT, name.replace("_enemy", "").replace("player_", "") + ".png"))
    for name, frames in TEXT.items():
        text_sprite(name, *frames)
    drawn()
    icon()
    # A sheet of them all, to look at.
    names = sorted(f for f in os.listdir(OUT) if f.endswith(".png"))
    print(f"{len(names)} sprites")


if __name__ == "__main__":
    main()
