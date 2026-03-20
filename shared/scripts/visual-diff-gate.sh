#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.

# =============================================================================
# Visual Diff Gate — Before/After Screenshot Comparison for Rendering Changes
# =============================================================================
#
# Captures before/after screenshots of impacted cards and flags regressions
# using pixel comparison. Designed to run before committing rendering changes.
#
# Usage:
#   bash shared/scripts/visual-diff-gate.sh
#   bash shared/scripts/visual-diff-gate.sh --cards "table,markdown,list"
#   bash shared/scripts/visual-diff-gate.sh --platform ios
#   bash shared/scripts/visual-diff-gate.sh --threshold 10
#
# Exit codes:
#   0 = all cards PASS
#   1 = at least one card FAIL (diff > threshold)
#   2 = at least one card WARN (diff > threshold/2) but none FAIL
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RESULTS_DIR="$REPO_ROOT/shared/test-results/visual-diff-gate-$TIMESTAMP"

# Defaults
THRESHOLD=5
PLATFORM="both"
EXPLICIT_CARDS=""
RENDER_WAIT=3

# Platform config
IOS_SIMULATOR="iPhone 16 Pro"
IOS_APP_ID="com.microsoft.adaptivecards.sampleapp"
ANDROID_APP_ID="com.microsoft.adaptivecards.sample"

# ADB path with fallback
if [[ -n "${ANDROID_HOME:-}" ]]; then
    ADB="$ANDROID_HOME/platform-tools/adb"
else
    ADB="$HOME/Library/Android/sdk/platform-tools/adb"
fi

# Tracking
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
ERROR_COUNT=0
FINAL_EXIT=0

# =============================================================================
# Argument parsing
# =============================================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cards) EXPLICIT_CARDS="$2"; shift 2 ;;
        --platform) PLATFORM="$2"; shift 2 ;;
        --threshold) THRESHOLD="$2"; shift 2 ;;
        --wait) RENDER_WAIT="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: visual-diff-gate.sh [--cards CARDS] [--platform ios|android|both] [--threshold N]"
            echo ""
            echo "Options:"
            echo "  --cards      Comma-separated card paths (e.g. table,markdown,list)"
            echo "  --platform   ios, android, or both (default: both)"
            echo "  --threshold  Max pixel diff % before FAIL (default: 5)"
            echo "  --wait       Seconds to wait after deep-link (default: 3)"
            exit 0
            ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

WARN_THRESHOLD=$(echo "$THRESHOLD / 2" | bc -l | xargs printf "%.1f")

# =============================================================================
# Hardcoded file-to-card mapping (fallback when impact-map.json is unavailable)
# =============================================================================
declare -A FILE_CARD_MAP
FILE_CARD_MAP["FlowLayoutView.swift"]="versioned/v1.5/MultiColumnFlowLayout,versioned/v1.5/ContainerFlowLayout"
FILE_CARD_MAP["FlowLayoutView.kt"]="versioned/v1.5/MultiColumnFlowLayout,versioned/v1.5/ContainerFlowLayout"
FILE_CARD_MAP["AreaGridLayoutView.swift"]="versioned/v1.5/Table.AreaGrid,versioned/v1.5/Container.AreaGrid,versioned/v1.5/AdaptiveCard.AreaGrid"
FILE_CARD_MAP["AreaGridLayoutView.kt"]="versioned/v1.5/Table.AreaGrid,versioned/v1.5/Container.AreaGrid,versioned/v1.5/AdaptiveCard.AreaGrid"
FILE_CARD_MAP["ImageView.swift"]="versioned/v1.5/Image.Svg,versioned/v1.5/Image.FitMode.Contain"
FILE_CARD_MAP["ImageView.kt"]="versioned/v1.5/Image.Svg,versioned/v1.5/Image.FitMode.Contain"
FILE_CARD_MAP["CompoundButtonView.swift"]="versioned/v1.6/CompoundButton,compound-buttons"
FILE_CARD_MAP["CompoundButtonView.kt"]="versioned/v1.6/CompoundButton,compound-buttons"
FILE_CARD_MAP["TableView.swift"]="table,element-samples/table-first-row-headers,versioned/v1.5/Table.AreaGrid"
FILE_CARD_MAP["TableView.kt"]="table,element-samples/table-first-row-headers,versioned/v1.5/Table.AreaGrid"
FILE_CARD_MAP["BadgeView.swift"]="versioned/v1.5/badge"
FILE_CARD_MAP["BadgeView.kt"]="versioned/v1.5/badge"
FILE_CARD_MAP["IconElementView.swift"]="versioned/v1.6/Icon.Clickable,versioned/v1.6/Icon.Styles"
FILE_CARD_MAP["IconElementView.kt"]="versioned/v1.6/Icon.Clickable,versioned/v1.6/Icon.Styles"
FILE_CARD_MAP["ListView.swift"]="list"
FILE_CARD_MAP["ListView.kt"]="list"
FILE_CARD_MAP["TextBlockView.swift"]="markdown,rich-text"
FILE_CARD_MAP["TextBlockView.kt"]="markdown,rich-text"
FILE_CARD_MAP["ActionButton.swift"]="versioned/v1.6/Icon.Styles"
FILE_CARD_MAP["ActionButton.kt"]="versioned/v1.6/Icon.Styles"
FILE_CARD_MAP["ActionSetView.swift"]="versioned/v1.6/Icon.Styles"
FILE_CARD_MAP["ActionSetView.kt"]="versioned/v1.6/Icon.Styles"
FILE_CARD_MAP["ColumnSetView.swift"]="official-samples/agenda,official-samples/flight-update,official-samples/expense-report"
FILE_CARD_MAP["ColumnSetView.kt"]="official-samples/agenda,official-samples/flight-update,official-samples/expense-report"
FILE_CARD_MAP["ContainerView.swift"]="versioned/v1.5/AdaptiveCardFlowLayout"
FILE_CARD_MAP["ContainerView.kt"]="versioned/v1.5/AdaptiveCardFlowLayout"
FILE_CARD_MAP["CarouselView.swift"]="carousel"
FILE_CARD_MAP["CarouselView.kt"]="carousel"
FILE_CARD_MAP["MarkdownRenderer.swift"]="markdown"
FILE_CARD_MAP["MarkdownRenderer.kt"]="markdown"

# =============================================================================
# Python pixel-diff script (written to temp file)
# =============================================================================
PYTHON_DIFF_SCRIPT="$RESULTS_DIR/pixel_diff.py"

write_python_script() {
    cat <<'PYEOF' > "$PYTHON_DIFF_SCRIPT"
#!/usr/bin/env python3
"""Pixel diff between two screenshots. Prints diff percentage to stdout."""

from PIL import Image
import sys

def pixel_diff_percent(img1_path, img2_path):
    img1 = Image.open(img1_path).convert('RGB')
    img2 = Image.open(img2_path).convert('RGB')

    # Resize to same dimensions if different
    if img1.size != img2.size:
        img2 = img2.resize(img1.size, Image.LANCZOS)

    pixels1 = img1.load()
    pixels2 = img2.load()
    w, h = img1.size
    diff_count = 0
    channel_threshold = 30  # per-channel tolerance for anti-aliasing

    for y in range(h):
        for x in range(w):
            r1, g1, b1 = pixels1[x, y]
            r2, g2, b2 = pixels2[x, y]
            if (abs(r1 - r2) > channel_threshold or
                abs(g1 - g2) > channel_threshold or
                abs(b1 - b2) > channel_threshold):
                diff_count += 1

    return (diff_count / (w * h)) * 100

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: pixel_diff.py <before.png> <after.png>", file=sys.stderr)
        sys.exit(2)
    pct = pixel_diff_percent(sys.argv[1], sys.argv[2])
    print(f"{pct:.2f}")
PYEOF
    chmod +x "$PYTHON_DIFF_SCRIPT"
}

# =============================================================================
# Helper functions
# =============================================================================

log() {
    echo "[visual-diff-gate] $*"
}

resolve_cards_from_impact_map() {
    local changed_files="$1"
    local impact_map="$SCRIPT_DIR/impact-map.json"
    local cards=""

    if [[ ! -f "$impact_map" ]]; then
        return 1
    fi

    # Extract card lists for each changed file from impact-map.json
    while IFS= read -r file; do
        local map_cards
        map_cards=$(python3 -c "
import json, sys
with open('$impact_map') as f:
    data = json.load(f)
patterns = data.get('file_patterns', {})
file_path = '$file'
if file_path in patterns:
    print(','.join(patterns[file_path].get('test_cards', [])))
" 2>/dev/null || true)
        if [[ -n "$map_cards" ]]; then
            cards="${cards:+$cards,}$map_cards"
        fi
    done <<< "$changed_files"

    if [[ -n "$cards" ]]; then
        echo "$cards"
        return 0
    fi
    return 1
}

resolve_cards_from_hardcoded_map() {
    local changed_files="$1"
    local cards=""

    while IFS= read -r file; do
        local basename
        basename=$(basename "$file")
        if [[ -n "${FILE_CARD_MAP[$basename]:-}" ]]; then
            cards="${cards:+$cards,}${FILE_CARD_MAP[$basename]}"
        fi
    done <<< "$changed_files"

    echo "$cards"
}

deduplicate_cards() {
    local csv="$1"
    echo "$csv" | tr ',' '\n' | sort -u | grep -v '^$' | paste -sd ',' -
}

capture_ios_screenshot() {
    local card_path="$1"
    local output_path="$2"
    xcrun simctl openurl "$IOS_SIMULATOR" "adaptivecards://card/$card_path" 2>/dev/null || true
    sleep "$RENDER_WAIT"
    xcrun simctl io "$IOS_SIMULATOR" screenshot "$output_path" 2>/dev/null || true
}

capture_android_screenshot() {
    local card_path="$1"
    local output_path="$2"
    "$ADB" shell am start -a android.intent.action.VIEW \
        -d "adaptivecards://card/$card_path" \
        "$ANDROID_APP_ID" >/dev/null 2>&1 || true
    sleep "$RENDER_WAIT"
    "$ADB" exec-out screencap -p > "$output_path" 2>/dev/null || true
}

build_ios() {
    log "Building iOS sample app..."
    (cd "$REPO_ROOT" && xcodebuild \
        -project ios/SampleApp.xcodeproj \
        -scheme ACVisualizer \
        -sdk iphonesimulator \
        -destination "platform=iOS Simulator,name=$IOS_SIMULATOR" \
        CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
        build 2>&1 | tail -5)
    log "iOS build complete."
}

build_android() {
    log "Building Android sample app..."
    (cd "$REPO_ROOT/android" && ./gradlew :sample-app:installDebug 2>&1 | tail -5)
    log "Android build + install complete."
}

needs_ios() {
    [[ "$PLATFORM" == "ios" || "$PLATFORM" == "both" ]]
}

needs_android() {
    [[ "$PLATFORM" == "android" || "$PLATFORM" == "both" ]]
}

# =============================================================================
# Main flow
# =============================================================================

log "Starting visual diff gate (threshold=${THRESHOLD}%, platform=${PLATFORM})"

mkdir -p "$RESULTS_DIR/before/ios" "$RESULTS_DIR/before/android" \
         "$RESULTS_DIR/after/ios" "$RESULTS_DIR/after/android"

write_python_script

# ---- Step 1: Determine impacted cards ----
if [[ -n "$EXPLICIT_CARDS" ]]; then
    CARDS="$EXPLICIT_CARDS"
    log "Using explicit card list."
else
    CHANGED_FILES=$(cd "$REPO_ROOT" && git diff --name-only HEAD 2>/dev/null || true)
    STAGED_FILES=$(cd "$REPO_ROOT" && git diff --name-only --cached 2>/dev/null || true)
    ALL_CHANGED=$(printf '%s\n%s' "$CHANGED_FILES" "$STAGED_FILES" | sort -u | grep -v '^$' || true)

    if [[ -z "$ALL_CHANGED" ]]; then
        log "No changed files detected. Nothing to diff."
        exit 0
    fi

    log "Changed files:"
    echo "$ALL_CHANGED" | sed 's/^/  /'

    # Try impact-map.json first, fall back to hardcoded map
    CARDS=$(resolve_cards_from_impact_map "$ALL_CHANGED" 2>/dev/null || true)
    if [[ -z "$CARDS" ]]; then
        CARDS=$(resolve_cards_from_hardcoded_map "$ALL_CHANGED")
    fi

    if [[ -z "$CARDS" ]]; then
        log "No impacted cards found for the changed files. Nothing to diff."
        exit 0
    fi
fi

CARDS=$(deduplicate_cards "$CARDS")
IFS=',' read -ra CARD_ARRAY <<< "$CARDS"

log "Impacted cards (${#CARD_ARRAY[@]}):"
for c in "${CARD_ARRAY[@]}"; do
    echo "  $c"
done

# ---- Step 2: Capture BEFORE screenshots (stash changes) ----
log "Stashing changes to capture BEFORE screenshots..."
STASH_RESULT=$(cd "$REPO_ROOT" && git stash push -m "visual-diff-gate-$TIMESTAMP" 2>&1)
STASHED=false
if echo "$STASH_RESULT" | grep -q "Saved working directory"; then
    STASHED=true
fi

# Build and install with the BEFORE state
if needs_ios; then
    build_ios
fi
if needs_android; then
    build_android
fi

log "Capturing BEFORE screenshots..."
for card in "${CARD_ARRAY[@]}"; do
    safe_name=$(echo "$card" | tr '/' '_')
    if needs_ios; then
        capture_ios_screenshot "$card" "$RESULTS_DIR/before/ios/${safe_name}.png"
    fi
    if needs_android; then
        capture_android_screenshot "$card" "$RESULTS_DIR/before/android/${safe_name}.png"
    fi
done

# ---- Step 3: Restore changes ----
if [[ "$STASHED" == "true" ]]; then
    log "Restoring stashed changes..."
    (cd "$REPO_ROOT" && git stash pop) || {
        log "ERROR: git stash pop failed. Resolve manually."
        exit 1
    }
fi

# ---- Step 4: Build with changes applied ----
if needs_ios; then
    build_ios
fi
if needs_android; then
    build_android
fi

# ---- Step 5: Capture AFTER screenshots ----
log "Capturing AFTER screenshots..."
for card in "${CARD_ARRAY[@]}"; do
    safe_name=$(echo "$card" | tr '/' '_')
    if needs_ios; then
        capture_ios_screenshot "$card" "$RESULTS_DIR/after/ios/${safe_name}.png"
    fi
    if needs_android; then
        capture_android_screenshot "$card" "$RESULTS_DIR/after/android/${safe_name}.png"
    fi
done

# ---- Step 6: Pixel diff comparison ----
log "Running pixel diff comparison..."
echo ""

# Report header
REPORT_FILE="$RESULTS_DIR/report.txt"
HEADER=$(printf "%-45s %-10s %-10s %s" "Card" "Platform" "Diff %" "Status")
SEPARATOR=$(printf '%0.s-' {1..80})

echo "$HEADER" | tee "$REPORT_FILE"
echo "$SEPARATOR" | tee -a "$REPORT_FILE"

compare_pair() {
    local card="$1"
    local plat="$2"
    local safe_name
    safe_name=$(echo "$card" | tr '/' '_')

    local before_img="$RESULTS_DIR/before/$plat/${safe_name}.png"
    local after_img="$RESULTS_DIR/after/$plat/${safe_name}.png"

    if [[ ! -f "$before_img" || ! -f "$after_img" ]]; then
        printf "%-45s %-10s %-10s %s\n" "$card" "$plat" "N/A" "SKIP" | tee -a "$REPORT_FILE"
        return
    fi

    # Check file sizes (empty screenshots)
    local before_size after_size
    before_size=$(wc -c < "$before_img" | tr -d ' ')
    after_size=$(wc -c < "$after_img" | tr -d ' ')
    if [[ "$before_size" -lt 1000 || "$after_size" -lt 1000 ]]; then
        printf "%-45s %-10s %-10s %s\n" "$card" "$plat" "N/A" "SKIP" | tee -a "$REPORT_FILE"
        ((ERROR_COUNT++)) || true
        return
    fi

    local diff_pct
    diff_pct=$(python3 "$PYTHON_DIFF_SCRIPT" "$before_img" "$after_img" 2>/dev/null || echo "-1")

    if [[ "$diff_pct" == "-1" ]]; then
        printf "%-45s %-10s %-10s %s\n" "$card" "$plat" "ERR" "ERROR" | tee -a "$REPORT_FILE"
        ((ERROR_COUNT++)) || true
        return
    fi

    local status="PASS"
    local is_fail is_warn
    is_fail=$(echo "$diff_pct > $THRESHOLD" | bc -l)
    is_warn=$(echo "$diff_pct > $WARN_THRESHOLD" | bc -l)

    if [[ "$is_fail" -eq 1 ]]; then
        status="FAIL"
        ((FAIL_COUNT++)) || true
    elif [[ "$is_warn" -eq 1 ]]; then
        status="WARN"
        ((WARN_COUNT++)) || true
    else
        ((PASS_COUNT++)) || true
    fi

    printf "%-45s %-10s %-10s %s\n" "$card" "$plat" "${diff_pct}%" "$status" | tee -a "$REPORT_FILE"
}

for card in "${CARD_ARRAY[@]}"; do
    if needs_ios; then
        compare_pair "$card" "ios"
    fi
    if needs_android; then
        compare_pair "$card" "android"
    fi
done

# ---- Step 7: Summary ----
echo "" | tee -a "$REPORT_FILE"
echo "$SEPARATOR" | tee -a "$REPORT_FILE"
echo "Summary: ${PASS_COUNT} PASS, ${WARN_COUNT} WARN, ${FAIL_COUNT} FAIL, ${ERROR_COUNT} ERROR/SKIP" | tee -a "$REPORT_FILE"
echo "Threshold: ${THRESHOLD}% (FAIL), ${WARN_THRESHOLD}% (WARN)" | tee -a "$REPORT_FILE"
echo "Results saved to: $RESULTS_DIR" | tee -a "$REPORT_FILE"
echo ""

if [[ "$FAIL_COUNT" -gt 0 ]]; then
    log "GATE FAILED: ${FAIL_COUNT} card(s) exceed the ${THRESHOLD}% pixel diff threshold."
    FINAL_EXIT=1
elif [[ "$WARN_COUNT" -gt 0 ]]; then
    log "GATE WARNING: ${WARN_COUNT} card(s) exceed the ${WARN_THRESHOLD}% warning threshold."
    FINAL_EXIT=2
else
    log "GATE PASSED: All cards within acceptable diff range."
fi

exit $FINAL_EXIT
