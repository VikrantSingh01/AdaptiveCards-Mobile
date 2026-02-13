#!/usr/bin/env python3
"""
Cross-platform snapshot parity comparison.

Compares iOS and Android snapshot baselines for the same card names,
generating an HTML report with side-by-side visual comparison.

Usage:
    python3 scripts/compare-snapshots.py \
        --ios-dir ios/Tests/VisualTests/Snapshots/Baselines \
        --android-dir android/ac-rendering/src/test/snapshots \
        --output parity-report.html
"""

import argparse
import os
import sys
from pathlib import Path


def find_snapshots(directory: str, extension: str = ".png") -> dict:
    """Find all snapshot images and index by card name."""
    snapshots = {}
    path = Path(directory)
    if not path.exists():
        print(f"Warning: Directory not found: {directory}")
        return snapshots

    for img_path in path.rglob(f"*{extension}"):
        # Extract card name from filename (strip config suffixes)
        name = img_path.stem
        # Normalize: remove device/config suffixes like _iPhone_15_Pro, _phone_light
        for suffix in ["_iPhone_15_Pro", "_iPad", "_Dark", "_Light",
                        "_phone", "_tablet", "_dark", "_light"]:
            name = name.replace(suffix, "")
        name = name.strip("_")

        if name not in snapshots:
            snapshots[name] = []
        snapshots[name].append(str(img_path))

    return snapshots


def generate_html_report(ios_snapshots: dict, android_snapshots: dict,
                          output_path: str):
    """Generate HTML report with side-by-side comparison."""
    all_cards = sorted(set(list(ios_snapshots.keys()) + list(android_snapshots.keys())))

    ios_only = 0
    android_only = 0
    both = 0

    rows = []
    for card in all_cards:
        has_ios = card in ios_snapshots
        has_android = card in android_snapshots

        if has_ios and has_android:
            status = "matched"
            both += 1
        elif has_ios:
            status = "ios-only"
            ios_only += 1
        else:
            status = "android-only"
            android_only += 1

        ios_img = ios_snapshots.get(card, [None])[0]
        android_img = android_snapshots.get(card, [None])[0]

        rows.append({
            "card": card,
            "status": status,
            "ios_img": ios_img,
            "android_img": android_img
        })

    html = f"""<!DOCTYPE html>
<html>
<head>
<title>Cross-Platform Parity Report</title>
<meta charset="utf-8">
<!-- NOTE: Image paths are local filesystem references. Open this report
     on the same machine where snapshots were recorded. -->
<style>
body {{ font-family: -apple-system, system-ui, sans-serif; margin: 20px; background: #f5f5f5; }}
h1 {{ color: #333; }}
.stats {{ display: flex; gap: 20px; margin: 20px 0; }}
.stat {{ padding: 15px 25px; border-radius: 8px; color: white; font-size: 18px; }}
.stat-both {{ background: #4CAF50; }}
.stat-ios {{ background: #007AFF; }}
.stat-android {{ background: #3DDC84; }}
.card-row {{ display: flex; gap: 20px; margin: 15px 0; padding: 15px; background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }}
.card-name {{ font-weight: bold; min-width: 200px; padding-top: 10px; }}
.snapshot {{ max-width: 400px; }}
.snapshot img {{ max-width: 100%; border: 1px solid #ddd; border-radius: 4px; }}
.label {{ font-size: 12px; color: #666; margin-bottom: 5px; }}
.missing {{ color: #999; font-style: italic; padding: 20px; }}
.status-matched {{ border-left: 4px solid #4CAF50; }}
.status-ios-only {{ border-left: 4px solid #007AFF; }}
.status-android-only {{ border-left: 4px solid #3DDC84; }}
</style>
</head>
<body>
<h1>Cross-Platform Snapshot Parity Report</h1>
<div class="stats">
    <div class="stat stat-both">Both Platforms: {both}</div>
    <div class="stat stat-ios">iOS Only: {ios_only}</div>
    <div class="stat stat-android">Android Only: {android_only}</div>
</div>
<p>Total cards: {len(all_cards)}</p>
"""

    for row in rows:
        ios_content = f'<img src="{row["ios_img"]}" />' if row["ios_img"] else '<span class="missing">No iOS snapshot</span>'
        android_content = f'<img src="{row["android_img"]}" />' if row["android_img"] else '<span class="missing">No Android snapshot</span>'

        html += f"""
<div class="card-row status-{row['status']}">
    <div class="card-name">{row['card']}</div>
    <div class="snapshot">
        <div class="label">iOS</div>
        {ios_content}
    </div>
    <div class="snapshot">
        <div class="label">Android</div>
        {android_content}
    </div>
</div>"""

    html += """
</body>
</html>"""

    try:
        output = Path(output_path)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(html, encoding="utf-8")
    except OSError as e:
        print(f"Error writing report to {output_path}: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"Report generated: {output_path}")
    print(f"  Both platforms: {both}")
    print(f"  iOS only: {ios_only}")
    print(f"  Android only: {android_only}")


def main():
    parser = argparse.ArgumentParser(description="Compare iOS and Android snapshots")
    parser.add_argument("--ios-dir", default="ios/Tests/VisualTests/Snapshots/Baselines",
                        help="iOS baselines directory")
    parser.add_argument("--android-dir", default="android/ac-rendering/src/test/snapshots",
                        help="Android baselines directory")
    parser.add_argument("--output", default="parity-report.html",
                        help="Output HTML report path")
    args = parser.parse_args()

    ios_snapshots = find_snapshots(args.ios_dir)
    android_snapshots = find_snapshots(args.android_dir)

    if not ios_snapshots and not android_snapshots:
        print("No snapshots found on either platform.")
        print("Record baselines first:")
        print("  iOS:     cd ios && RECORD_SNAPSHOTS=1 swift test --filter VisualTests")
        print("  Android: cd android && ./gradlew :ac-rendering:recordPaparazziDebug")
        sys.exit(0)

    generate_html_report(ios_snapshots, android_snapshots, args.output)


if __name__ == "__main__":
    main()
