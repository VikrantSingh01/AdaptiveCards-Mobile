#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.

# =============================================================================
# Dual-Platform Bookmark Demo Script
# =============================================================================
#
# Warm-boots both iOS & Android apps side-by-side, then runs an 8-step demo:
#
#   1. Home page (Gallery)                      — 2s
#   2. Scroll to filter chips                   — brief
#   3. Select "Teams Official" filter           — 2s
#   4. Walk bookmarked cards (Z→A) detail pages — card wait + 1s extra
#   5. Charts card with scroll (all chart types)— 7s
#   6. Last card detail → show card preview     — 3s
#   7. More page                                — 3s
#   8. Performance Dashboard                    — 3s
#   9. Settings                                 — 3s
#  10. Return to Home                           — 2s
#
# Design: ZERO builds — UI navigation only via deep links for minimal latency.
#
# Usage:
#   bash shared/scripts/demo-bookmarks.sh
#   bash shared/scripts/demo-bookmarks.sh --wait 3         # 3s per card
#   bash shared/scripts/demo-bookmarks.sh --screenshots    # capture screenshots
#
# Prerequisites:
#   - iOS Simulator "iPhone 16 Pro" booted
#   - Android emulator running
#   - Both sample apps previously installed (warm boot — no build)
# =============================================================================

set -euo pipefail

# ─── Defaults ────────────────────────────────────────────────────────────────
CARD_WAIT=2          # seconds on each card detail page (+ 1s extra per step 4)
TRANSITION_WAIT=0.5  # seconds between navigation transitions
PERF_WAIT=5          # seconds on performance dashboard
SETTINGS_WAIT=3      # seconds on settings page
MORE_WAIT=5          # seconds on more page
HOME_WAIT=2          # seconds on home/gallery page
FILTER_WAIT=2        # seconds on filtered gallery view
IOS_HEAD_START=0.15  # iOS fires first to compensate for slower deep link handling
TAKE_SCREENSHOTS=false
REPORT_DIR="/tmp/demo-bookmarks-$(date +%Y%m%d-%H%M%S)"

# Platform config
IOS_SIMULATOR="iPhone 16 Pro"
IOS_APP_ID="com.microsoft.adaptivecards.sampleapp"
ANDROID_APP_ID="com.microsoft.adaptivecards.sample"
ANDROID_MAIN_ACTIVITY="$ANDROID_APP_ID/.MainActivity"

# ─── Parse Args ──────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --wait)         CARD_WAIT="$2"; shift 2 ;;
        --perf-wait)    PERF_WAIT="$2"; shift 2 ;;
        --screenshots)  TAKE_SCREENSHOTS=true; shift ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# ─── Resolve Platform Tools ─────────────────────────────────────────────────

# iOS — resolve simulator UDID
SIM_UDID=""
IOS_READY=false
SIM_UDID=$(xcrun simctl list devices available 2>/dev/null \
    | grep "$IOS_SIMULATOR" | grep -oE '[A-F0-9-]{36}' | head -1 || true)
if [ -n "$SIM_UDID" ]; then
    SIM_STATE=$(xcrun simctl list devices 2>/dev/null \
        | grep "$SIM_UDID" | grep -oE '\(Booted\)' || true)
    [ -n "$SIM_STATE" ] && IOS_READY=true
fi

# Android — resolve adb
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

# ─── Navigation Helpers ─────────────────────────────────────────────────────

ios_is_running() {
    xcrun simctl spawn "$SIM_UDID" launchctl list 2>/dev/null | grep -q "$IOS_APP_ID" 2>/dev/null
}

ios_launch() {
    if ! ios_is_running; then
        xcrun simctl launch "$SIM_UDID" "$IOS_APP_ID" &>/dev/null
        sleep 1.5
    fi
}

ios_open() {
    xcrun simctl openurl "$SIM_UDID" "adaptivecards://$1" &>/dev/null
}

ios_screenshot() {
    xcrun simctl io "$SIM_UDID" screenshot "$1" &>/dev/null || true
}

android_is_running() {
    "$ADB" shell pidof "$ANDROID_APP_ID" &>/dev/null
}

android_launch() {
    if ! android_is_running; then
        "$ADB" shell am start -n "$ANDROID_MAIN_ACTIVITY" &>/dev/null
        sleep 1.5
    fi
}

android_open() {
    "$ADB" shell am start -a android.intent.action.VIEW \
        -d "adaptivecards://$1" \
        "$ANDROID_APP_ID" &>/dev/null
}

android_screenshot() {
    local out="$1"
    local device_path="/sdcard/ac_demo_tmp.png"
    "$ADB" shell screencap -p "$device_path" &>/dev/null
    "$ADB" pull "$device_path" "$out" &>/dev/null || true
    "$ADB" shell rm "$device_path" &>/dev/null || true
}

# Navigate both platforms: iOS first (head start), then Android
navigate() {
    local route="$1"
    $IOS_READY && ios_open "$route"
    sleep "$IOS_HEAD_START"
    $ANDROID_READY && android_open "$route"
}

# Scroll both platforms (swipe up to reveal more content)
scroll_down() {
    if $IOS_READY; then
        # Scroll iOS Simulator via Accessibility API (AXScrollDownByPage).
        # JXA recursively finds the first AXScrollArea in the Simulator window
        # and triggers a page-down scroll — works regardless of window position.
        osascript -l JavaScript -e '
            var se = Application("System Events");
            var win = se.processes["Simulator"].windows[0];
            function find(el, d) {
                if (d > 20) return null;
                try {
                    var ch = el.uiElements();
                    for (var i = 0; i < ch.length; i++) {
                        if (ch[i].role() === "AXScrollArea") return ch[i];
                        var r = find(ch[i], d + 1);
                        if (r) return r;
                    }
                } catch(e) {}
                return null;
            }
            var sa = find(win, 0);
            if (sa) sa.actions["AXScrollDownByPage"].perform();
        ' &>/dev/null 2>&1 || true
    fi
    if $ANDROID_READY; then
        "$ADB" shell input swipe 540 1600 540 600 300 &>/dev/null
    fi
}

take_screenshots() {
    local name="$1"
    if $TAKE_SCREENSHOTS; then
        ios_screenshot "$REPORT_DIR/ios/${name}.png" &
        android_screenshot "$REPORT_DIR/android/${name}.png" &
        wait
    fi
}

# ─── Read Bookmarks from Device Storage ──────────────────────────────────────

read_ios_bookmarks() {
    local raw
    raw=$(xcrun simctl spawn "$SIM_UDID" defaults read "$IOS_APP_ID" bookmarkedCardFilenames 2>/dev/null || echo "")
    if [ -z "$raw" ] || echo "$raw" | grep -q "does not exist"; then
        echo ""
        return
    fi
    echo "$raw" | grep -v '^[()]$' | sed 's/^[[:space:]]*//' | sed 's/[",]//g' | sed '/^$/d'
}

read_android_bookmarks() {
    local raw
    raw=$("$ADB" shell run-as "$ANDROID_APP_ID" cat \
        /data/data/"$ANDROID_APP_ID"/shared_prefs/bookmarks.xml 2>/dev/null || echo "")
    if [ -z "$raw" ]; then
        echo ""
        return
    fi
    echo "$raw" | grep '<string>' | sed 's/.*<string>\(.*\)<\/string>.*/\1/'
}

# =============================================================================
# Banner
# =============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Adaptive Cards — Dual-Platform Demo                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Card wait:     ${CARD_WAIT}s (+1s extra)"
echo "  Perf wait:     ${PERF_WAIT}s"
echo "  Settings wait: ${SETTINGS_WAIT}s"
echo "  Screenshots:   $TAKE_SCREENSHOTS"
echo ""

# =============================================================================
# Pre-flight
# =============================================================================
echo "━━━ Pre-flight ━━━"

if $IOS_READY; then
    echo "  ✅ iOS:     $IOS_SIMULATOR ($SIM_UDID) — Booted"
else
    echo "  ❌ iOS:     Not available"
fi

if $ANDROID_READY; then
    DEVICE_MODEL=$("$ADB" shell getprop ro.product.model 2>/dev/null || echo "unknown")
    echo "  ✅ Android: $DEVICE_MODEL — Connected"
else
    echo "  ❌ Android: Not available"
fi

if ! $IOS_READY && ! $ANDROID_READY; then
    echo "  ⛔ Neither platform available."
    exit 1
fi
echo ""

# =============================================================================
# Warm Boot
# =============================================================================
echo "━━━ Warm Boot (no build) ━━━"

$IOS_READY && ios_launch &
$ANDROID_READY && android_launch &
wait

$IOS_READY && echo "  🍎 iOS app: running"
$ANDROID_READY && echo "  🤖 Android app: running"
echo ""

# =============================================================================
# Read Bookmarks
# =============================================================================
echo "━━━ Reading Bookmarks ━━━"

declare -a ios_bookmarks=()
declare -a android_bookmarks=()
declare -a all_bookmarks=()

if $IOS_READY; then
    while IFS= read -r line; do
        [ -n "$line" ] && ios_bookmarks+=("$line")
    done <<< "$(read_ios_bookmarks)"
    echo "  🍎 iOS bookmarks:     ${#ios_bookmarks[@]}"
fi

if $ANDROID_READY; then
    while IFS= read -r line; do
        [ -n "$line" ] && android_bookmarks+=("$line")
    done <<< "$(read_android_bookmarks)"
    echo "  🤖 Android bookmarks: ${#android_bookmarks[@]}"
fi

# Merge unique (bash 3.x compatible)
for b in "${ios_bookmarks[@]+"${ios_bookmarks[@]}"}" "${android_bookmarks[@]+"${android_bookmarks[@]}"}"; do
    [ -z "$b" ] && continue
    is_dup=false
    for existing in "${all_bookmarks[@]+"${all_bookmarks[@]}"}"; do
        [ "$existing" = "$b" ] && is_dup=true && break
    done
    $is_dup || all_bookmarks+=("$b")
done

if [ ${#all_bookmarks[@]} -eq 0 ]; then
    echo ""
    echo "  ⚠️  No bookmarks found. Bookmark some cards first."
    exit 0
fi

# Sort Z→A
IFS=$'\n' sorted_bookmarks=($(printf '%s\n' "${all_bookmarks[@]}" | sort -r)); unset IFS

echo "  📚 Total unique:      ${#sorted_bookmarks[@]} (sorted Z→A)"
echo ""

if $TAKE_SCREENSHOTS; then
    mkdir -p "$REPORT_DIR/ios" "$REPORT_DIR/android"
fi

# =============================================================================
# Step 1: Home Page (Gallery)
# =============================================================================
echo "━━━ Step 1: Home Page ━━━"

navigate "gallery"
sleep "$HOME_WAIT"
take_screenshots "01-home"

echo "  🏠 Gallery home displayed (${HOME_WAIT}s)"
echo ""

# =============================================================================
# Step 2: Scroll to Filter Chips
# =============================================================================
echo "━━━ Step 2: Filter Chips ━━━"

# The gallery already shows filter chips at the top — brief pause
sleep "$TRANSITION_WAIT"

echo "  🔖 Filter chip bar visible"
echo ""

# =============================================================================
# Step 3: Select "Teams Official" Filter
# =============================================================================
echo "━━━ Step 3: Teams Official Filter ━━━"

navigate "gallery/teams-official"
sleep "$FILTER_WAIT"
take_screenshots "03-teams-official-filter"

echo "  🏷️  Teams Official filter selected (${FILTER_WAIT}s)"
echo ""

# =============================================================================
# Step 4: Bookmarked Cards — Detail Pages (Z→A)
# =============================================================================
echo "━━━ Step 4: Bookmarked Card Details (Z→A) ━━━"
echo ""

total=${#sorted_bookmarks[@]}
idx=0
last_card_path=""

for bookmark in "${sorted_bookmarks[@]}"; do
    idx=$((idx + 1))

    card_path="${bookmark%.json}"
    card_name=$(basename "$card_path")
    last_card_path="$card_path"

    printf "  [%2d/%d] %-35s" "$idx" "$total" "$card_name"

    navigate "card/$card_path"

    # Card wait + 1 extra second per requirement
    sleep $((CARD_WAIT + 1))

    take_screenshots "04-card-${idx}-${card_name}"

    echo "🍎✅  🤖✅"

    if [ "$idx" -lt "$total" ]; then
        sleep "$TRANSITION_WAIT"
    fi
done

echo ""
echo "  ✅ All $total bookmarked cards shown."
echo ""

# =============================================================================
# Step 5: Charts Card — Show All Chart Types with Scroll
# =============================================================================
echo "━━━ Step 5: Charts Card ━━━"

navigate "card/charts"
sleep 3
take_screenshots "05-charts-top"
echo "  📊 Charts card — donut + bar charts (3s)"

# Scroll down to reveal more chart types
scroll_down
sleep 2
take_screenshots "05-charts-mid"
echo "  📊 Charts card — scrolled to more charts (2s)"

scroll_down
sleep 2
take_screenshots "05-charts-mid2"
echo "  📊 Charts card — scrolled to more charts (2s)"

scroll_down
sleep 2
take_screenshots "05-charts-bottom"
echo "  📊 Charts card — scrolled to bottom (2s)"

echo ""

# =============================================================================
# Step 6: Last Card Detail — Show Card Preview
# =============================================================================
echo "━━━ Step 6: Card Detail Preview ━━━"

if [ -n "$last_card_path" ]; then
    navigate "card/$last_card_path"
    sleep 3
    take_screenshots "06-card-detail-preview"

    echo "  🔍 Card detail preview: $(basename "$last_card_path") (3s)"
else
    echo "  ⚠️  No card available."
fi
echo ""

# =============================================================================
# Step 7: More Page
# =============================================================================
echo "━━━ Step 7: More Page ━━━"

navigate "more"
sleep "$MORE_WAIT"
take_screenshots "07-more-page"

echo "  📋 More page displayed (${MORE_WAIT}s)"
echo ""

# =============================================================================
# Step 8: Performance Dashboard
# =============================================================================
echo "━━━ Step 8: Performance Dashboard ━━━"

navigate "performance"
sleep "$PERF_WAIT"
take_screenshots "08-performance"

echo "  📊 Performance dashboard displayed (${PERF_WAIT}s)"
echo ""

# =============================================================================
# Step 9: Settings
# =============================================================================
echo "━━━ Step 9: Settings ━━━"

navigate "settings"
sleep "$SETTINGS_WAIT"
take_screenshots "09-settings"

echo "  ⚙️  Settings displayed (${SETTINGS_WAIT}s)"
echo ""

# =============================================================================
# Step 10: Return to Home
# =============================================================================
echo "━━━ Step 10: Back to Home ━━━"

navigate "gallery"
sleep "$HOME_WAIT"
take_screenshots "10-home-final"

echo "  🏠 Gallery home displayed (${HOME_WAIT}s)"
echo ""

# =============================================================================
# Summary
# =============================================================================
echo "━━━ Demo Complete ━━━"
echo ""
echo "  Step 1  🏠 Home page"
echo "  Step 2  🔖 Filter chips"
echo "  Step 3  🏷️  Teams Official filter"
echo "  Step 4  📚 $total bookmarked cards (Z→A)"
echo "  Step 5  📊 Charts card (scrolled)"
echo "  Step 6  🔍 Card detail preview"
echo "  Step 7  📋 More page"
echo "  Step 8  📊 Performance dashboard"
echo "  Step 9  ⚙️  Settings"
echo "  Step 10 🏠 Back to home"
if $TAKE_SCREENSHOTS; then
    echo ""
    echo "  📸 Screenshots: $REPORT_DIR"
fi
echo ""
