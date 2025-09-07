#!/usr/bin/env python3
import argparse
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

def load_font(font_size: int):
    # Try some common fonts; fall back to PIL’s default
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf",
        "/usr/share/fonts/truetype/freefont/FreeSans.ttf",
        "/Library/Fonts/Arial.ttf",
        "C:/Windows/Fonts/arial.ttf",
    ]
    for p in candidates:
        fp = Path(p)
        if fp.exists():
            return ImageFont.truetype(str(fp), font_size)
    return ImageFont.load_default()

def safe_name(p: Path, max_chars: int):
    name = p.stem
    if len(name) <= max_chars:
        return name
    return name[: max_chars - 1] + "…"

def paste_center(dst: Image.Image, img: Image.Image, box):
    """Paste `img` centered into `box=(x,y,w,h)`, preserving alpha."""
    x, y, w, h = box
    img = img.copy()
    # Scale image to fit box while keeping aspect
    img.thumbnail((w, h), Image.Resampling.LANCZOS)
    cx = x + (w - img.width) // 2
    cy = y + (h - img.height) // 2
    dst.paste(img, (cx, cy), img if img.mode in ("RGBA", "LA") else None)

def main():
    ap = argparse.ArgumentParser(description="Create a labeled emoji collage.")
    ap.add_argument("input_dir", help="Directory containing .tga/.png emojis")
    ap.add_argument("-o", "--output", default="collage.png", help="Output image path")
    ap.add_argument("--size", type=int, default=64, help="Emoji square size (pixels)")
    ap.add_argument("--cols", type=int, default=12, help="Number of columns")
    ap.add_argument("--pad", type=int, default=10, help="Outer padding (pixels)")
    ap.add_argument("--gap", type=int, default=10, help="Gap between tiles (pixels)")
    ap.add_argument("--tilepad", type=int, default=8, help="Inner padding inside each tile")
    ap.add_argument("--fontsize", type=int, default=14, help="Label font size")
    ap.add_argument("--maxname", type=int, default=18, help="Max label chars (ellipsis if longer)")
    ap.add_argument("--bg", default="#1e1e1e", help="Background color")
    ap.add_argument("--fg", default="#ffffff", help="Label/text color")
    args = ap.parse_args()

    in_dir = Path(args.input_dir)
    files = sorted(
        [p for p in in_dir.iterdir() if p.suffix.lower() in (".tga", ".png") and p.is_file()]
    )
    if not files:
        raise SystemExit(f"No .tga/.png files found in: {in_dir}")

    font = load_font(args.fontsize)

    # Fixed label strip height (approx + a little padding)
    dummy = Image.new("RGB", (10, 10))
    d = ImageDraw.Draw(dummy)
    ascent, descent = font.getmetrics()
    text_h = ascent + descent
    label_h = int(text_h * 1.6)

    tile_w = args.size + args.tilepad * 2
    tile_h = args.size + args.tilepad * 2 + label_h

    n = len(files)
    cols = max(1, args.cols)
    rows = math.ceil(n / cols)

    W = args.pad * 2 + cols * tile_w + (cols - 1) * args.gap
    H = args.pad * 2 + rows * tile_h + (rows - 1) * args.gap

    # Use RGBA to preserve any alpha in final PNG if bg has alpha (not needed here)
    collage = Image.new("RGBA", (W, H), args.bg)
    draw = ImageDraw.Draw(collage)

    for idx, fp in enumerate(files):
        r = idx // cols
        c = idx % cols
        x0 = args.pad + c * (tile_w + args.gap)
        y0 = args.pad + r * (tile_h + args.gap)

        # Tile background (optional: draw a rounded rect or border)
        # draw.rectangle([x0, y0, x0 + tile_w - 1, y0 + tile_h - 1], outline="#444444")

        # Load image; convert to RGBA for alpha-safe pasting
        try:
            im = Image.open(fp).convert("RGBA")
        except Exception as e:
            print(f"Skip {fp}: {e}")
            continue

        # Paste emoji centered in the top part of the tile
        paste_center(
            collage,
            im,
            (x0 + args.tilepad, y0 + args.tilepad, args.size, args.size),
        )

        # Draw centered label
        label = safe_name(fp, args.maxname)
        tw, th = draw.textbbox((0, 0), label, font=font)[2:]
        lx = x0 + (tile_w - tw) // 2
        ly = y0 + args.tilepad + args.size + (label_h - th) // 2
        draw.text((lx, ly), label, font=font, fill=args.fg)

    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    collage.save(out)
    print(f"✓ Collage written to: {out}  ({n} images, {rows}x{cols})")

if __name__ == "__main__":
    main()