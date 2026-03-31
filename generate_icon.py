#!/usr/bin/env python3
"""Generate DevVault app icon as PNG"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import math
except ImportError:
    print("Installing Pillow...")
    import subprocess
    subprocess.check_call(["pip", "install", "Pillow"])
    from PIL import Image, ImageDraw, ImageFont
    import math

SIZE = 1024
PADDING = 64
RADIUS = 224

def create_icon():
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background gradient (manual)
    for y in range(SIZE):
        t = y / SIZE
        r = int(26 + (15 - 26) * t)
        g = int(26 + (52 - 26) * t)
        b = int(46 + (96 - 46) * t)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b))
    
    # Rounded rectangle background
    bg = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg)
    bg_draw.rounded_rectangle(
        [PADDING, PADDING, SIZE - PADDING, SIZE - PADDING],
        radius=RADIUS,
        fill=(26, 26, 46, 255)
    )
    
    # Inner border
    bg_draw.rounded_rectangle(
        [PADDING + 8, PADDING + 8, SIZE - PADDING - 8, SIZE - PADDING - 8],
        radius=RADIUS - 4,
        outline=(255, 255, 255, 25),
        width=2
    )
    
    img = Image.alpha_composite(img, bg)
    draw = ImageDraw.Draw(img)
    
    # Shield shape
    shield_cx = SIZE // 2
    shield_top = 200
    shield_bottom = 820
    shield_width = 200
    
    shield_points = []
    # Top center
    shield_points.append((shield_cx, shield_top))
    # Top right
    shield_points.append((shield_cx + shield_width, shield_top + 100))
    # Right side down
    shield_points.append((shield_cx + shield_width, shield_top + 260))
    # Bottom right curve (approximate)
    for i in range(20):
        t = i / 19
        angle = math.pi / 2 * t
        x = shield_cx + shield_width * math.cos(angle)
        y = shield_bottom - 100 + 100 * math.sin(angle)
        shield_points.append((int(x), int(y)))
    # Bottom center
    shield_points.append((shield_cx, shield_bottom))
    # Bottom left curve (mirror)
    for i in range(20):
        t = i / 19
        angle = math.pi / 2 * (1 - t)
        x = shield_cx - shield_width * math.cos(angle)
        y = shield_bottom - 100 + 100 * math.sin(angle)
        shield_points.append((int(x), int(y)))
    # Left side up
    shield_points.append((shield_cx - shield_width, shield_top + 260))
    # Top left
    shield_points.append((shield_cx - shield_width, shield_top + 100))
    
    # Draw shield with gradient effect
    shield_img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    shield_draw = ImageDraw.Draw(shield_img)
    shield_draw.polygon(shield_points, fill=(233, 69, 96, 230))
    
    # Shield highlight
    highlight_points = [(int(x * 0.95 + shield_cx * 0.05), int(y * 0.95 + shield_top * 0.05 + 10)) for x, y in shield_points]
    shield_draw.polygon(highlight_points, outline=(255, 255, 255, 50), width=2)
    
    img = Image.alpha_composite(img, shield_img)
    draw = ImageDraw.Draw(img)
    
    # Lock body
    lock_x = shield_cx - 40
    lock_y = 440
    lock_w = 80
    lock_h = 70
    
    # Lock body (white rounded rect)
    lock_img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    lock_draw = ImageDraw.Draw(lock_img)
    lock_draw.rounded_rectangle(
        [lock_x, lock_y, lock_x + lock_w, lock_y + lock_h],
        radius=12,
        fill=(255, 255, 255, 255)
    )
    
    # Lock shackle
    shackle_cx = shield_cx
    shackle_top = lock_y - 30
    shackle_bottom = lock_y
    shackle_width = 20
    
    # Draw shackle as thick arc
    lock_draw.arc(
        [shackle_cx - 20, shackle_top - 20, shackle_cx + 20, shackle_top + 20],
        start=180, end=0,
        fill=(255, 255, 255, 255),
        width=12
    )
    lock_draw.line(
        [(shackle_cx - 20, shackle_top), (shackle_cx - 20, shackle_bottom)],
        fill=(255, 255, 255, 255),
        width=12
    )
    lock_draw.line(
        [(shackle_cx + 20, shackle_top), (shackle_cx + 20, shackle_bottom)],
        fill=(255, 255, 255, 255),
        width=12
    )
    
    # Keyhole
    lock_draw.ellipse(
        [shield_cx - 8, lock_y + 22, shield_cx + 8, lock_y + 38],
        fill=(26, 26, 46, 255)
    )
    lock_draw.rounded_rectangle(
        [shield_cx - 4, lock_y + 34, shield_cx + 4, lock_y + 54],
        radius=4,
        fill=(26, 26, 46, 255)
    )
    
    img = Image.alpha_composite(img, lock_img)
    
    # Decorative dots
    dot_positions = [(120, 120), (904, 120), (120, 904), (904, 904)]
    for dx, dy in dot_positions:
        draw.ellipse([dx - 4, dy - 4, dx + 4, dy + 4], fill=(233, 69, 96, 76))
    
    # Save
    img.save('assets/icon/app_icon.png', 'PNG')
    print(f"Icon saved: assets/icon/app_icon.png ({SIZE}x{SIZE})")
    
    # Also save smaller versions
    for size in [512, 256, 128, 64, 48, 32, 16]:
        small = img.resize((size, size), Image.LANCZOS)
        small.save(f'assets/icon/app_icon_{size}x{size}.png', 'PNG')
        print(f"  Saved: app_icon_{size}x{size}.png")

if __name__ == '__main__':
    create_icon()
    print("\nDone! All icon sizes generated.")
