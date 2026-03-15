#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.

# =============================================================================
# Design Pass — Full Visual Catalog Generation
# =============================================================================
#
# End-to-end script: captures all card screenshots on both iOS and Android,
# captures app-level screens, and generates an HTML design review catalog.
# Everything lives in a single output directory — no duplication.
#
# Usage:
#   bash shared/scripts/design-pass.sh                    # default: all cards
#   bash shared/scripts/design-pass.sh --category all     # explicit all
#   bash shared/scripts/design-pass.sh --wait 5           # custom render wait
#
# Output:
#   shared/test-results/design-catalog-<TIMESTAMP>/
#     ├── index.html
#     └── screenshots/{ios,android}/*.png
#
# Prerequisites:
#   - iOS Simulator "iPhone 16 Pro" booted
#   - Android emulator running (or device connected)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Output directory — single location, no copies
OUTPUT_DIR="$REPO_ROOT/shared/test-results/design-catalog-$TIMESTAMP"
mkdir -p "$OUTPUT_DIR/screenshots/ios" "$OUTPUT_DIR/screenshots/android"

# Defaults
CATEGORY="all"
RENDER_WAIT=4

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --category) CATEGORY="$2"; shift 2 ;;
        --wait) RENDER_WAIT="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# Platform config
IOS_SIMULATOR="iPhone 16 Pro"
IOS_APP_ID="com.microsoft.adaptivecards.sampleapp"
ANDROID_APP_ID="com.microsoft.adaptivecards.sample"

# =============================================================================
# Pre-flight checks
# =============================================================================
echo "=============================================="
echo " Design Pass — Visual Catalog Generation"
echo "=============================================="
echo ""

# iOS check
SIM_UDID=$(xcrun simctl list devices available 2>/dev/null | grep "$IOS_SIMULATOR" | grep -oE '[A-F0-9-]{36}' | head -1 || true)
IOS_READY=false
if [ -n "$SIM_UDID" ]; then
    SIM_STATE=$(xcrun simctl list devices 2>/dev/null | grep "$SIM_UDID" | grep -oE '\(Booted\)' || true)
    [ -n "$SIM_STATE" ] && IOS_READY=true
fi

# Android check
if command -v adb &>/dev/null; then
    ADB="adb"
elif [ -n "${ANDROID_HOME:-}" ]; then
    ADB="$ANDROID_HOME/platform-tools/adb"
else
    ADB="$HOME/Library/Android/sdk/platform-tools/adb"
fi

ANDROID_READY=false
ANDROID_DEVICES=$("$ADB" devices 2>/dev/null | grep -c "device$" || true)
[ "$ANDROID_DEVICES" -gt 0 ] && ANDROID_READY=true

if ! $IOS_READY && ! $ANDROID_READY; then
    echo "ERROR: Neither iOS Simulator nor Android emulator is running."
    echo ""
    echo "  Boot iOS:    xcrun simctl boot '$IOS_SIMULATOR'"
    echo "  Boot Android: \$ANDROID_HOME/emulator/emulator -avd Medium_Phone_API_36.1 &"
    exit 1
fi

echo "  iOS:     $($IOS_READY && echo 'Ready' || echo 'Not available')"
echo "  Android: $($ANDROID_READY && echo 'Ready' || echo 'Not available')"
echo "  Category: $CATEGORY"
echo "  Output:  $OUTPUT_DIR"
echo ""

# =============================================================================
# Screenshot helpers
# =============================================================================
ios_screenshot() {
    local path="$1"
    xcrun simctl io "$SIM_UDID" screenshot "$path" 2>/dev/null
    # Compress PNG (TinyPNG-style) — full resolution, ~75% smaller
    compress_png "$path"
}

android_screenshot() {
    local path="$1"
    "$ADB" shell screencap -p /sdcard/design-pass-tmp.png 2>/dev/null
    "$ADB" pull /sdcard/design-pass-tmp.png "$path" 2>/dev/null
    "$ADB" shell rm /sdcard/design-pass-tmp.png 2>/dev/null
    # Compress PNG (TinyPNG-style) — full resolution, ~75% smaller
    compress_png "$path"
}

# Lossy PNG compression via pngquant (same engine as TinyPNG)
compress_png() {
    local path="$1"
    [ -f "$path" ] || return 0
    if command -v pngquant &>/dev/null; then
        pngquant --quality=65-85 --force --output "$path" "$path" 2>/dev/null || true
    fi
}

navigate_and_capture() {
    local deep_link="$1"
    local screenshot_name="$2"

    # Navigate via deep link on both platforms
    if $IOS_READY; then
        xcrun simctl openurl "$SIM_UDID" "$deep_link" 2>/dev/null &
    fi
    if $ANDROID_READY; then
        "$ADB" shell am start -a android.intent.action.VIEW \
            -d "$deep_link" \
            "$ANDROID_APP_ID" 2>/dev/null &
    fi
    wait

    sleep "$RENDER_WAIT"

    # Capture
    if $IOS_READY; then
        ios_screenshot "$OUTPUT_DIR/screenshots/ios/${screenshot_name}.png" &
    fi
    if $ANDROID_READY; then
        android_screenshot "$OUTPUT_DIR/screenshots/android/${screenshot_name}.png" &
    fi
    wait
}

# =============================================================================
# Phase 1: Capture app-level screens
# =============================================================================
echo "=== Phase 1: Capturing app-level screens ==="

# Screens with deep link support on both platforms
# (no deep link for "teams" on iOS or "action-log" — those are only reachable via More tab)
APP_SCREENS=("gallery" "editor" "more" "bookmarks" "performance" "settings")

for screen in "${APP_SCREENS[@]}"; do
    echo "  $screen"
    navigate_and_capture "adaptivecards://$screen" "_app-${screen}"
done

echo "  Done: ${#APP_SCREENS[@]} app screens"
echo ""

# =============================================================================
# Phase 2: Capture card screenshots
# =============================================================================
echo "=== Phase 2: Capturing card screenshots ==="

TEST_CARDS_DIR="$REPO_ROOT/shared/test-cards"

# Build card list (same logic as self-heal-dual.sh --category all)
TEAMS_OFFICIAL_CARDS=(
    "teams-official-samples/account"
    "teams-official-samples/author-highlight-video"
    "teams-official-samples/book-a-room"
    "teams-official-samples/cafe-menu"
    "teams-official-samples/communication"
    "teams-official-samples/course-video"
    "teams-official-samples/editorial"
    "teams-official-samples/expense-report"
    "teams-official-samples/insights"
    "teams-official-samples/issue"
    "teams-official-samples/list"
    "teams-official-samples/project-dashboard"
    "teams-official-samples/recipe"
    "teams-official-samples/simple-event"
    "teams-official-samples/simple-time-off-request"
    "teams-official-samples/standard-video"
    "teams-official-samples/team-standup-summary"
    "teams-official-samples/time-off-request"
    "teams-official-samples/work-item"
)

get_cards_from_dir() {
    local dir="$1"
    local prefix="$2"
    local cards=()
    if [ -d "$TEST_CARDS_DIR/$dir" ]; then
        for f in "$TEST_CARDS_DIR/$dir"/*.json; do
            [ -f "$f" ] || continue
            cards+=("$prefix/$(basename "$f" .json)")
        done
    fi
    echo "${cards[@]}"
}

cards_to_test=()
case "$CATEGORY" in
    teams-official) cards_to_test=("${TEAMS_OFFICIAL_CARDS[@]}") ;;
    element) IFS=' ' read -ra cards_to_test <<< "$(get_cards_from_dir element-samples element-samples)" ;;
    official) IFS=' ' read -ra cards_to_test <<< "$(get_cards_from_dir official-samples official-samples)" ;;
    all)
        cards_to_test=("${TEAMS_OFFICIAL_CARDS[@]}")
        IFS=' ' read -ra extra <<< "$(get_cards_from_dir element-samples element-samples)"
        cards_to_test+=("${extra[@]}")
        IFS=' ' read -ra extra <<< "$(get_cards_from_dir official-samples official-samples)"
        cards_to_test+=("${extra[@]}")
        for ver in v1.5 v1.6; do
            IFS=' ' read -ra extra <<< "$(get_cards_from_dir "versioned/$ver" "versioned/$ver")"
            cards_to_test+=("${extra[@]}")
        done
        for f in "$TEST_CARDS_DIR"/*.json; do
            [ -f "$f" ] || continue
            local_name=$(basename "$f")
            [[ "$local_name" == *.data.json ]] && continue
            [[ "$local_name" == "sample-catalog.json" ]] && continue
            cards_to_test+=("$(basename "$f" .json)")
        done
        for f in "$TEST_CARDS_DIR/templates"/*.template.json; do
            [ -f "$f" ] || continue
            cards_to_test+=("templates/$(basename "$f" .json)")
        done
        for f in "$TEST_CARDS_DIR/templates"/Template.*.json; do
            [ -f "$f" ] || continue
            [[ "$(basename "$f")" == *.data.json ]] && continue
            cards_to_test+=("templates/$(basename "$f" .json)")
        done
        ;;
    versioned)
        for ver in v1.5 v1.6; do
            IFS=' ' read -ra extra <<< "$(get_cards_from_dir "versioned/$ver" "versioned/$ver")"
            cards_to_test+=("${extra[@]}")
        done
        ;;
    root)
        for f in "$TEST_CARDS_DIR"/*.json; do
            [ -f "$f" ] || continue
            [[ "$(basename "$f")" == *.data.json ]] && continue
            [[ "$(basename "$f")" == "sample-catalog.json" ]] && continue
            cards_to_test+=("$(basename "$f" .json)")
        done
        ;;
    templates)
        for f in "$TEST_CARDS_DIR/templates"/*.template.json; do
            [ -f "$f" ] || continue
            cards_to_test+=("templates/$(basename "$f" .json)")
        done
        for f in "$TEST_CARDS_DIR/templates"/Template.*.json; do
            [ -f "$f" ] || continue
            [[ "$(basename "$f")" == *.data.json ]] && continue
            cards_to_test+=("templates/$(basename "$f" .json)")
        done
        ;;
    *) echo "Unknown category: $CATEGORY"; exit 1 ;;
esac

TOTAL=${#cards_to_test[@]}
echo "  Cards to capture: $TOTAL"
echo ""

PASS=0
FAIL=0

for i in "${!cards_to_test[@]}"; do
    card_path="${cards_to_test[$i]}"
    # Use full path with / replaced by - to avoid collisions
    # (e.g., teams-official-samples/list → teams-official-samples-list)
    card_name=$(echo "$card_path" | tr '/' '-')
    idx=$((i + 1))

    printf "  [%d/%d] %s" "$idx" "$TOTAL" "$card_name"

    # Navigate to gallery first (clean slate)
    if $IOS_READY; then
        xcrun simctl openurl "$SIM_UDID" "adaptivecards://gallery" 2>/dev/null || true
    fi
    if $ANDROID_READY; then
        "$ADB" shell am start -a android.intent.action.VIEW \
            -d "adaptivecards://gallery" \
            "$ANDROID_APP_ID" 2>/dev/null || true
    fi
    sleep 1

    # Navigate to card and capture
    navigate_and_capture "adaptivecards://card/$card_path" "$card_name"

    # Check if at least one screenshot was captured
    ios_ok=false
    android_ok=false
    [ -f "$OUTPUT_DIR/screenshots/ios/${card_name}.png" ] && ios_ok=true
    [ -f "$OUTPUT_DIR/screenshots/android/${card_name}.png" ] && android_ok=true

    if $ios_ok || $android_ok; then
        PASS=$((PASS + 1))
        echo " ✓"
    else
        FAIL=$((FAIL + 1))
        echo " ✗"
    fi
done

echo ""
echo "  Results: $PASS passed, $FAIL failed out of $TOTAL cards"

# Return to gallery
if $IOS_READY; then
    xcrun simctl openurl "$SIM_UDID" "adaptivecards://gallery" 2>/dev/null || true
fi
if $ANDROID_READY; then
    "$ADB" shell am start -a android.intent.action.VIEW \
        -d "adaptivecards://gallery" \
        "$ANDROID_APP_ID" 2>/dev/null || true
fi

# =============================================================================
# Phase 3: Generate HTML catalog
# =============================================================================
echo ""
echo "=== Phase 3: Generating design catalog ==="

bash "$SCRIPT_DIR/generate-design-catalog.sh" "$OUTPUT_DIR"

# Copy index.html to top-level test-results for stable access
cp "$OUTPUT_DIR/index.html" "$REPO_ROOT/shared/test-results/index.html"

# Create/update screenshots symlink so top-level index.html can find images
ln -sfn "$OUTPUT_DIR/screenshots" "$REPO_ROOT/shared/test-results/screenshots"

# =============================================================================
# Done
# =============================================================================
echo ""
echo "=============================================="
echo " Design Pass Complete"
echo "=============================================="
echo ""
echo "  Catalog: $OUTPUT_DIR/index.html"
echo "  Stable:  shared/test-results/index.html"
echo "  Cards: $PASS/$TOTAL  |  App screens: ${#APP_SCREENS[@]}"
echo "  To share: zip -r design-catalog.zip \"$OUTPUT_DIR\""
echo ""

# Open in default browser (macOS)
if command -v open &>/dev/null; then
    open "$OUTPUT_DIR/index.html"
fi
