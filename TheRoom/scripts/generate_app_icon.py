"""Generates the App Icon: a simple flat terracotta circle on a nude field,
matching Theme.swift's bgBase/accent tokens. Regenerate with:

    python scripts/generate_app_icon.py

Output goes to TheRoom/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png
"""
from PIL import Image, ImageDraw

SIZE = 1024
BG = (0xFA, 0xF6, 0xF1)  # Theme.bgBase (light)
ACCENT = (0xC9, 0x7B, 0x5D)  # Theme.accent — terracotta, the only accent

img = Image.new("RGB", (SIZE, SIZE), BG)
draw = ImageDraw.Draw(img)

margin = SIZE * 0.22
draw.ellipse([margin, margin, SIZE - margin, SIZE - margin], fill=ACCENT)

out_path = "TheRoom/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
img.save(out_path)
print(f"Wrote {out_path}")
