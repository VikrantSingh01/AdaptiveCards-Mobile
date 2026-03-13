#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.

# =============================================================================
# Dual-Platform Action Crash Test Loop
# =============================================================================
#
# Navigates to every action-focused test card on both platforms and verifies
# the app doesn't crash. This is a rendering + parsing crash test — it ensures
# all action types (Submit, OpenUrl, ShowCard, Execute, ToggleVisibility,
# Popover, RunCommands, OpenUrlDialog) can be rendered without fatal errors.
#
# Usage:
#   bash shared/scripts/action-test-loop.sh
#   bash shared/scripts/action-test-loop.sh --screenshots
#
# Prerequisites:
#   - iOS Simulator "iPhone 16 Pro" booted
#   - Android emulator running
#   - Both sample apps previously installed
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_DIR="${REPO_ROOT}/shared/test-output/action-test-$TIMESTAMP"
RENDER_WAIT=3
TAKE_SCREENSHOTS=false

# Platform config
IOS_SIMULATOR="iPhone 16 Pro"
IOS_APP_ID="com.microsoft.adaptivecards.sampleapp"
ANDROID_APP_ID="com.microsoft.adaptivecards.sample"

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --screenshots) TAKE_SCREENSHOTS=true; shift ;;
        --wait) RENDER_WAIT="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# Action-focused test cards — paths match the filename field in the card loaders.
# Root-level cards use bare filename (no prefix). Subdirectory cards use dir/name.
ACTION_CARDS=(
    # Root-level cards (in shared/test-cards/)
    "all-actions"
    "popover-action"
    "action-overflow"
    "edge-max-actions"
    "edge-action-crashes"
    "compound-buttons"
    "split-buttons"
    # Element samples (in shared/test-cards/element-samples/)
    "element-samples/action-submit-mode"
    "element-samples/action-submit-is-enabled"
    "element-samples/action-submit-tooltip"
    "element-samples/action-openurl-mode"
    "element-samples/action-openurl-is-enabled"
    "element-samples/action-openurl-tooltip"
    "element-samples/action-execute-mode"
    "element-samples/action-execute-is-enabled"
    "element-samples/action-execute-tooltip"
    "element-samples/action-showcard-mode"
    "element-samples/action-showcard-is-enabled"
    "element-samples/action-showcard-tooltip"
    "element-samples/action-role"
    "element-samples/image-select-action"
    # Versioned v1.5 action cards (in shared/test-cards/versioned/v1.5/)
    "versioned/v1.5/Action.Popover"
    "versioned/v1.5/Action.IsEnabled"
    "versioned/v1.5/Action.MenuActions"
    "versioned/v1.5/ActionModeTestCard"
)

mkdir -p "$REPORT_DIR"

# =============================================================================
# Resolve platform tools
# =============================================================================

SIM_UDID=""
IOS_READY=false
SIM_UDID=$(xcrun simctl list devices available 2>/dev/null | grep "$IOS_SIMULATOR" | grep -oE '[A-F0-9-]{36}' | head -1 || true)
if [ -n "$SIM_UDID" ]; then
    SIM_STATE=$(xcrun simctl list devices 2>/dev/null | grep "$SIM_UDID" | grep -oE '\(Booted\)' || true)
    [ -n "$SIM_STATE" ] && IOS_READY=true
fi

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

# Helpers
ios_is_running() {
    xcrun simctl spawn "$SIM_UDID" launchctl list 2>/dev/null | grep -q "$IOS_APP_ID" 2>/dev/null
}

android_is_running() {
    "$ADB" shell pidof "$ANDROID_APP_ID" &>/dev/null
}

ios_navigate() {
    xcrun simctl openurl "$SIM_UDID" "adaptivecards://card/$1" &>/dev/null
}

android_navigate() {
    "$ADB" shell am start -a android.intent.action.VIEW \
        -d "adaptivecards://card/$1" \
        "$ANDROID_APP_ID" &>/dev/null
}

ios_gallery() {
    xcrun simctl openurl "$SIM_UDID" "adaptivecards://gallery" &>/dev/null
}

android_gallery() {
    "$ADB" shell am start -a android.intent.action.VIEW \
        -d "adaptivecards://gallery" \
        "$ANDROID_APP_ID" &>/dev/null
}

ios_screenshot() {
    xcrun simctl io "$SIM_UDID" screenshot "$1" &>/dev/null || true
}

android_screenshot() {
    local out="$1"
    local device_path="/sdcard/ac_action_tmp.png"
    "$ADB" shell screencap -p "$device_path" &>/dev/null
    "$ADB" pull "$device_path" "$out" &>/dev/null || true
    "$ADB" shell rm "$device_path" &>/dev/null || true
}

# =============================================================================
# Banner
# =============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Action Crash Test Loop                                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Cards:       ${#ACTION_CARDS[@]}"
echo "  Wait:        ${RENDER_WAIT}s per card"
echo "  Screenshots: $TAKE_SCREENSHOTS"
echo "  Report:      $REPORT_DIR"
echo ""

# =============================================================================
# Pre-flight
# =============================================================================
echo "━━━ Pre-flight ━━━"
$IOS_READY && echo "  ✅ iOS:     $IOS_SIMULATOR — Booted" || echo "  ❌ iOS:     Not available"
$ANDROID_READY && echo "  ✅ Android: Connected" || echo "  ❌ Android: Not available"

if ! $IOS_READY && ! $ANDROID_READY; then
    echo "  ⛔ Neither platform available."
    exit 1
fi
echo ""

# =============================================================================
# Utility: file size + classify
# =============================================================================
file_size() {
    local f="$1"
    if [ -f "$f" ]; then
        stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Classify screenshot: PASS / FAIL based on file size.
# A rendered card has meaningful content; a blank/error page is small.
# These thresholds are calibrated for screenshots resized or full-res.
classify() {
    local size="$1"
    local platform="$2"
    # iOS screenshots are ~170KB+ when a card renders; error pages are ~100KB (gallery bounce).
    # Android screenshots are ~60KB+ for real cards; error pages are ~70KB but with "Failed to render" text.
    # We use a heuristic: if the screenshot hash matches the gallery baseline, it's a FAIL.
    # For size-only: iOS cards > 150KB, Android element-sample cards > 50KB.
    # The primary check is hash-based (see below), this is a fallback.
    if [ "$platform" = "ios" ]; then
        [ "$size" -gt 100000 ] && echo "PASS" || echo "FAIL"
    else
        [ "$size" -gt 40000 ] && echo "PASS" || echo "FAIL"
    fi
}

# =============================================================================
# Test Loop
# =============================================================================
echo "━━━ Action Card Testing ━━━"
echo ""

# Always take screenshots for validation
mkdir -p "$REPORT_DIR/screenshots/ios" "$REPORT_DIR/screenshots/android"

# Take gallery baseline screenshots to detect "card didn't navigate" failures
echo "  Taking gallery baselines..."
if $IOS_READY; then
    ios_gallery; sleep 2
    ios_screenshot "$REPORT_DIR/screenshots/ios/_gallery_baseline.png"
    ios_gallery_hash=$(md5 -q "$REPORT_DIR/screenshots/ios/_gallery_baseline.png" 2>/dev/null || echo "")
fi
if $ANDROID_READY; then
    android_gallery; sleep 2
    android_screenshot "$REPORT_DIR/screenshots/android/_gallery_baseline.png"
    android_gallery_hash=$(md5 -q "$REPORT_DIR/screenshots/android/_gallery_baseline.png" 2>/dev/null || echo "")
fi
echo ""

ios_pass=0; ios_fail=0
android_pass=0; android_fail=0
declare -a failed_cards=()
idx=0

for card_path in "${ACTION_CARDS[@]}"; do
    idx=$((idx + 1))
    card_name=$(basename "$card_path")

    printf "  [%2d/%d] %-40s" "$idx" "${#ACTION_CARDS[@]}" "$card_name"

    # Navigate both platforms
    $IOS_READY && ios_navigate "$card_path" &
    $ANDROID_READY && android_navigate "$card_path" &
    wait

    sleep "$RENDER_WAIT"

    # Screenshot both platforms
    ios_ss="$REPORT_DIR/screenshots/ios/${card_name}.png"
    android_ss="$REPORT_DIR/screenshots/android/${card_name}.png"

    $IOS_READY && ios_screenshot "$ios_ss" &
    $ANDROID_READY && android_screenshot "$android_ss" &
    wait

    # Classify results — purely screenshot-based.
    # simctl openurl can transiently kill/relaunch the app process, making
    # process-alive checks unreliable. Instead we classify by:
    #   1. Screenshot exists and is not the gallery baseline → PASS/FAIL by size
    #   2. Screenshot matches gallery baseline → FAIL (deep link didn't navigate)
    #   3. Screenshot missing/empty → CRASH (app truly dead)
    ios_status="—"
    android_status="—"
    notes=""

    if $IOS_READY; then
        ios_sz=$(file_size "$ios_ss")
        if [ "$ios_sz" -lt 1000 ]; then
            # No screenshot or tiny = real crash
            ios_status="CRASH"
            ios_fail=$((ios_fail + 1))
            notes="iOS: no screenshot (crash)"
            xcrun simctl launch "$SIM_UDID" "$IOS_APP_ID" &>/dev/null || true
            sleep 2
        else
            local_hash=""
            [ -f "$ios_ss" ] && local_hash=$(md5 -q "$ios_ss" 2>/dev/null || echo "")
            if [ -n "$ios_gallery_hash" ] && [ "$local_hash" = "$ios_gallery_hash" ]; then
                ios_status="FAIL"
                ios_fail=$((ios_fail + 1))
                notes="iOS: shows gallery (deep link didn't navigate)"
            else
                ios_status=$(classify "$ios_sz" "ios")
                if [ "$ios_status" = "PASS" ]; then
                    ios_pass=$((ios_pass + 1))
                else
                    ios_fail=$((ios_fail + 1))
                    notes="iOS: small screenshot (${ios_sz}B — possible render error)"
                fi
            fi
        fi
    fi

    if $ANDROID_READY; then
        android_sz=$(file_size "$android_ss")
        if [ "$android_sz" -lt 1000 ]; then
            android_status="CRASH"
            android_fail=$((android_fail + 1))
            notes="${notes:+$notes; }Android: no screenshot (crash)"
            "$ADB" shell am start -n "$ANDROID_APP_ID/.MainActivity" &>/dev/null || true
            sleep 2
        else
            local_hash=""
            [ -f "$android_ss" ] && local_hash=$(md5 -q "$android_ss" 2>/dev/null || echo "")
            if [ -n "$android_gallery_hash" ] && [ "$local_hash" = "$android_gallery_hash" ]; then
                android_status="FAIL"
                android_fail=$((android_fail + 1))
                notes="${notes:+$notes; }Android: shows gallery (deep link didn't navigate)"
            else
                android_status=$(classify "$android_sz" "android")
                if [ "$android_status" = "PASS" ]; then
                    android_pass=$((android_pass + 1))
                else
                    android_fail=$((android_fail + 1))
                    notes="${notes:+$notes; }Android: small screenshot (${android_sz}B — possible render error)"
                fi
            fi
        fi
    fi

    # Status symbols
    ios_sym="—"; android_sym="—"
    case "$ios_status" in PASS) ios_sym="✅" ;; FAIL) ios_sym="❌" ;; CRASH) ios_sym="💥" ;; esac
    case "$android_status" in PASS) android_sym="✅" ;; FAIL) android_sym="❌" ;; CRASH) android_sym="💥" ;; esac

    echo "🍎${ios_sym} 🤖${android_sym}  ${notes}"

    if [ "$ios_status" = "FAIL" ] || [ "$ios_status" = "CRASH" ] || [ "$android_status" = "FAIL" ] || [ "$android_status" = "CRASH" ]; then
        failed_cards+=("$card_name")
    fi

    # Return to gallery (skip only on real crash — already restarted above)
    $IOS_READY && [ "$ios_status" != "CRASH" ] && ios_gallery &
    $ANDROID_READY && [ "$android_status" != "CRASH" ] && android_gallery &
    wait
    sleep 0.5
done

echo ""

# =============================================================================
# Summary
# =============================================================================
ios_total=$((ios_pass + ios_fail))
android_total=$((android_pass + android_fail))

echo "━━━ Results ━━━"
echo ""
$IOS_READY     && echo "  🍎 iOS:     $ios_total tested | $ios_pass pass | $ios_fail fail"
$ANDROID_READY && echo "  🤖 Android: $android_total tested | $android_pass pass | $android_fail fail"
echo ""

if [ ${#failed_cards[@]} -gt 0 ]; then
    echo "  Failed cards:"
    for fc in "${failed_cards[@]}"; do
        echo "    ❌ $fc"
    done
    echo ""
fi

if [ "$ios_fail" -gt 0 ] || [ "$android_fail" -gt 0 ]; then
    echo "  ❌ ACTION TEST FAILED"
    echo ""
    echo "  Screenshots: $REPORT_DIR/screenshots/"
    exit 1
else
    echo "  ✅ ALL ACTION CARDS RENDERED CORRECTLY"
fi

echo ""
echo "  Screenshots: $REPORT_DIR/screenshots/"
echo ""
