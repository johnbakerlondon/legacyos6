#!/usr/bin/env python3
"""
generate_assets.py -- procedurally generates every texture, sprite, and
icon PNG used by Pixel Siege. Re-run after editing colors/shapes below to
re-theme the game. Requires Pillow: pip install pillow
"""
import os
import random
from PIL import Image, ImageDraw

try:
    RESAMPLE_NEAREST = Image.Resampling.NEAREST
except AttributeError:
    RESAMPLE_NEAREST = Image.NEAREST

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "Resources")
os.makedirs(OUT, exist_ok=True)


def new_canvas(size):
    return Image.new("RGBA", (size, size), (0, 0, 0, 0))


# ---------------------------------------------------------------- tiles --

def make_grass():
    img = new_canvas(64)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 64, 64], fill=(71, 130, 58, 255))
    random.seed(42)
    for _ in range(140):
        x, y = random.randint(0, 63), random.randint(0, 63)
        shade = random.choice([(59, 112, 47, 255), (86, 150, 70, 255)])
        d.point((x, y), fill=shade)
    img.save(f"{OUT}/tile_grass.png")


def make_forest():
    img = new_canvas(64)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 64, 64], fill=(66, 122, 54, 255))
    random.seed(7)
    for _ in range(90):
        x, y = random.randint(0, 63), random.randint(0, 63)
        d.point((x, y), fill=(54, 104, 44, 255))
    for cx, cy in [(16, 20), (42, 16), (26, 44), (48, 46)]:
        d.ellipse([cx - 10, cy - 12, cx + 10, cy + 8], fill=(31, 77, 38, 255))
        d.rectangle([cx - 2, cy + 6, cx + 2, cy + 15], fill=(74, 51, 32, 255))
    img.save(f"{OUT}/tile_forest.png")


def make_water():
    img = new_canvas(64)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 64, 64], fill=(43, 97, 168, 255))
    for y in range(6, 64, 12):
        d.line([(2, y), (20, y - 3), (40, y), (62, y - 3)], fill=(94, 158, 214, 255), width=2)
    img.save(f"{OUT}/tile_water.png")


def make_gold():
    img = new_canvas(64)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 64, 64], fill=(126, 101, 66, 255))
    random.seed(3)
    for _ in range(80):
        x, y = random.randint(0, 63), random.randint(0, 63)
        d.point((x, y), fill=(107, 84, 53, 255))
    random.seed(11)
    for _ in range(14):
        x, y = random.randint(6, 55), random.randint(6, 55)
        d.rectangle([x, y, x + 3, y + 3], fill=(255, 214, 82, 255))
    img.save(f"{OUT}/tile_gold.png")


# --------------------------------------------------------------- troops --

def make_troop(filename, body_color, weapon):
    img = new_canvas(48)
    d = ImageDraw.Draw(img)
    d.ellipse([13, 14, 35, 34], fill=body_color, outline=(25, 25, 25, 255))
    d.ellipse([18, 5, 30, 17], fill=(224, 172, 118, 255), outline=(25, 25, 25, 255))
    if weapon == "sword":
        d.line([(33, 22), (44, 10)], fill=(220, 220, 225, 255), width=3)
        d.line([(30, 25), (36, 19)], fill=(120, 80, 40, 255), width=3)
    else:
        d.arc([28, 6, 46, 40], start=250, end=110, fill=(150, 110, 70, 255), width=2)
        d.line([(37, 8), (37, 38)], fill=(60, 45, 30, 255), width=1)
    img.save(f"{OUT}/{filename}")


# ---------------------------------------------------------------- keeps --

def make_keep(filename, flag_color):
    img = new_canvas(64)
    d = ImageDraw.Draw(img)
    d.rectangle([10, 26, 54, 58], fill=(130, 128, 122, 255), outline=(70, 68, 64, 255))
    for x in range(10, 50, 8):
        d.rectangle([x, 19, x + 5, 26], fill=(130, 128, 122, 255))
    d.rectangle([29, 4, 31, 20], fill=(94, 66, 40, 255))
    d.polygon([(31, 4), (31, 13), (46, 8)], fill=flag_color)
    d.rectangle([25, 42, 39, 58], fill=(64, 48, 32, 255))
    img.save(f"{OUT}/{filename}")


# ----------------------------------------------------------------- icon --

def make_icon():
    grid, cell = 16, 16
    size = grid * cell
    base = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    d = ImageDraw.Draw(base)

    def px(x, y, color):
        d.rectangle([x * cell, y * cell, x * cell + cell - 1, y * cell + cell - 1], fill=color)

    sky_top, sky_bottom = (98, 160, 216, 255), (156, 202, 232, 255)
    stone, stone_dark, stone_light = (154, 152, 146, 255), (112, 110, 104, 255), (182, 180, 174, 255)
    flag, pole, gate = (198, 50, 50, 255), (94, 66, 40, 255), (66, 46, 28, 255)

    for y in range(grid):
        c = sky_top if y < 8 else sky_bottom
        for x in range(grid):
            px(x, y, c)

    for x in list(range(2, 5)) + list(range(11, 14)):
        for y in range(6, 16):
            px(x, y, stone)
    for y in range(6, 16):
        px(2, y, stone_light)
        px(13, y, stone_dark)
    for x in (2, 3, 4, 11, 12, 13):
        px(x, 5, stone)

    for x in range(5, 11):
        for y in range(10, 16):
            px(x, y, stone)
    for x in (5, 7, 9):
        px(x, 9, stone)

    for x in (7, 8):
        for y in range(13, 16):
            px(x, y, gate)

    px(3, 2, pole)
    px(3, 3, pole)
    px(3, 4, pole)
    px(4, 1, flag)
    px(5, 1, flag)
    px(4, 2, flag)

    base.save(os.path.join(ROOT, "icon_master_preview.png"))

    for name, size_px in [("Icon.png", 57), ("Icon@2x.png", 114), ("Icon-72.png", 72), ("Icon-72@2x.png", 144)]:
        base.resize((size_px, size_px), RESAMPLE_NEAREST).save(f"{OUT}/{name}")


if __name__ == "__main__":
    make_grass()
    make_forest()
    make_water()
    make_gold()
    make_troop("troop_swordsman_blue.png", (60, 110, 200, 255), "sword")
    make_troop("troop_swordsman_red.png", (200, 70, 60, 255), "sword")
    make_troop("troop_archer_blue.png", (60, 110, 200, 255), "bow")
    make_troop("troop_archer_red.png", (200, 70, 60, 255), "bow")
    make_keep("keep_blue.png", (60, 110, 200, 255))
    make_keep("keep_red.png", (200, 70, 60, 255))
    make_icon()
    print("Assets written to", OUT)
