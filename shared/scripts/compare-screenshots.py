#!/usr/bin/env python3
"""
Cross-platform screenshot comparison for parity testing.

Compares an iOS and Android screenshot by:
1. Cropping out platform chrome (status bar, nav bar, bottom bar)
2. Resizing both to the same dimensions
3. Computing structural similarity (SSIM-like) via normalized pixel diff

Usage:
    python3 compare-screenshots.py <ios.png> <android.png> [--threshold 0.15]

Exit codes:
    0 = PASS (diff within threshold)
    1 = PARITY MISMATCH (diff exceeds threshold)
    2 = ERROR (file not found, etc.)

Output (stdout):
    JSON: {"diff": 0.123, "status": "PASS"|"MISMATCH", "ios_crop": [t,b], "android_crop": [t,b]}
"""

import sys
import json
import numpy as np
from PIL import Image

# Default crop ratios to remove platform chrome
# iOS: status bar ~7% top, bottom bar ~5% bottom
# Android: status bar ~5% top, nav bar + bottom bar ~12% bottom
IOS_CROP_TOP = 0.07
IOS_CROP_BOTTOM = 0.05
ANDROID_CROP_TOP = 0.05
ANDROID_CROP_BOTTOM = 0.12

COMPARE_SIZE = (360, 640)  # Normalize both to this size


def crop_chrome(img, crop_top_ratio, crop_bottom_ratio):
    """Remove platform chrome (status bar, nav bar) by cropping."""
    w, h = img.size
    top = int(h * crop_top_ratio)
    bottom = int(h * (1 - crop_bottom_ratio))
    return img.crop((0, top, w, bottom))


def compute_diff(ios_path, android_path, threshold=0.15):
    """Compare two screenshots and return diff percentage."""
    try:
        ios_img = Image.open(ios_path).convert("RGB")
        android_img = Image.open(android_path).convert("RGB")
    except Exception as e:
        return {"diff": 1.0, "status": "ERROR", "error": str(e)}

    # Crop platform chrome
    ios_cropped = crop_chrome(ios_img, IOS_CROP_TOP, IOS_CROP_BOTTOM)
    android_cropped = crop_chrome(android_img, ANDROID_CROP_TOP, ANDROID_CROP_BOTTOM)

    # Resize both to same dimensions
    ios_resized = ios_cropped.resize(COMPARE_SIZE, Image.LANCZOS)
    android_resized = android_cropped.resize(COMPARE_SIZE, Image.LANCZOS)

    # Convert to numpy arrays and compute normalized difference
    ios_arr = np.array(ios_resized, dtype=np.float32) / 255.0
    android_arr = np.array(android_resized, dtype=np.float32) / 255.0

    # Mean absolute difference across all channels
    diff = np.mean(np.abs(ios_arr - android_arr))

    status = "PASS" if diff <= threshold else "MISMATCH"

    return {
        "diff": round(float(diff), 4),
        "status": status,
        "threshold": threshold,
        "ios_size": list(ios_img.size),
        "android_size": list(android_img.size),
    }


def main():
    if len(sys.argv) < 3:
        print("Usage: compare-screenshots.py <ios.png> <android.png> [--threshold 0.15]", file=sys.stderr)
        sys.exit(2)

    ios_path = sys.argv[1]
    android_path = sys.argv[2]
    threshold = 0.15

    for i, arg in enumerate(sys.argv):
        if arg == "--threshold" and i + 1 < len(sys.argv):
            threshold = float(sys.argv[i + 1])

    result = compute_diff(ios_path, android_path, threshold)
    print(json.dumps(result))

    if result["status"] == "MISMATCH":
        sys.exit(1)
    elif result["status"] == "ERROR":
        sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()
