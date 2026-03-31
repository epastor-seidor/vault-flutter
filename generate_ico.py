#!/usr/bin/env python3
"""Generate .ico file from PNG for Windows app icon"""

from PIL import Image
import os

def create_ico():
    icon_path = 'assets/icon/app_icon.png'
    if not os.path.exists(icon_path):
        print(f"Error: {icon_path} not found. Run generate_icon.py first.")
        return
    
    img = Image.open(icon_path)
    
    # Create .ico with multiple sizes (Windows standard)
    sizes = [(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)]
    
    # Resize images for ICO
    images = []
    for size in sizes:
        resized = img.resize(size, Image.LANCZOS)
        images.append(resized)
    
    # Save as ICO
    ico_path = 'windows/runner/resources/app_icon.ico'
    os.makedirs(os.path.dirname(ico_path), exist_ok=True)
    
    images[0].save(
        ico_path,
        format='ICO',
        sizes=[(img.width, img.height) for img in images],
        append_images=images[1:]
    )
    
    print(f"ICO saved: {ico_path}")
    print(f"  Sizes: {', '.join(f'{s[0]}x{s[1]}' for s in sizes)}")

if __name__ == '__main__':
    create_ico()
