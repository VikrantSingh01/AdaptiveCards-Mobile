#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.

# =============================================================================
# Dual-Platform Action Invocation Test
# =============================================================================
#
# Navigates to action-focused test cards, finds every action button, taps it,
# and verifies:
#   1. The app doesn't crash after tapping
#   2. The correct UX appears (screenshot diff for visual actions)
#
# Visual actions (ShowCard, ToggleVisibility, Popover) MUST change the screen.
# Non-visual actions (Submit, Execute, OpenUrl, RunCommands) just verify no crash.
#
# Usage:
#   bash shared/scripts/action-invoke-test.sh
#   bash shared/scripts/action-invoke-test.sh --cards all-actions popover-action
#   bash shared/scripts/action-invoke-test.sh --ios-only
#   bash shared/scripts/action-invoke-test.sh --android-only
#   bash shared/scripts/action-invoke-test.sh --wait 5
#
# Prerequisites:
#   - iOS Simulator "iPhone 16 Pro" booted with sample app installed
#   - Android emulator running with sample app installed
#   - Accessibility / input automation permissions granted
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_DIR="${REPO_ROOT}/shared/test-output/action-invoke-$TIMESTAMP"
RENDER_WAIT=3
TAP_WAIT=2
IOS_ONLY=false
ANDROID_ONLY=false

# Platform config
IOS_SIMULATOR="iPhone 16 Pro"
IOS_APP_ID="com.microsoft.adaptivecards.sampleapp"
ANDROID_APP_ID="com.microsoft.adaptivecards.sample"

# Default action card list
DEFAULT_CARDS=(
    "all-actions"
    "popover-action"
    "action-overflow"
    "compound-buttons"
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
    "versioned/v1.5/Action.Popover"
    "versioned/v1.5/Action.IsEnabled"
    "versioned/v1.5/Action.MenuActions"
    "versioned/v1.5/ActionModeTestCard"
)

SELECTED_CARDS=()

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cards)
            shift
            while [[ $# -gt 0 ]] && [[ "$1" != --* ]]; do
                SELECTED_CARDS+=("$1")
                shift
            done
            ;;
        --ios-only)    IOS_ONLY=true; shift ;;
        --android-only) ANDROID_ONLY=true; shift ;;
        --wait)        RENDER_WAIT="$2"; shift 2 ;;
        --tap-wait)    TAP_WAIT="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# Use selected cards or default list
if [ ${#SELECTED_CARDS[@]} -eq 0 ]; then
    SELECTED_CARDS=("${DEFAULT_CARDS[@]}")
fi

mkdir -p "$REPORT_DIR/screenshots/ios" "$REPORT_DIR/screenshots/android"

# =============================================================================
# Action types that MUST produce a visible UX change when tapped
# =============================================================================
VISUAL_ACTIONS="Action.ShowCard Action.ToggleVisibility Action.Popover"

is_visual_action() {
    local action_type="$1"
    [[ " $VISUAL_ACTIONS " == *" $action_type "* ]]
}

# =============================================================================
# Resolve platform tools
# =============================================================================
SIM_UDID=""
IOS_READY=false
if ! $ANDROID_ONLY; then
    SIM_UDID=$(xcrun simctl list devices available 2>/dev/null | grep "$IOS_SIMULATOR" | grep -oE '[A-F0-9-]{36}' | head -1 || true)
    if [ -n "$SIM_UDID" ]; then
        SIM_STATE=$(xcrun simctl list devices 2>/dev/null | grep "$SIM_UDID" | grep -oE '\(Booted\)' || true)
        [ -n "$SIM_STATE" ] && IOS_READY=true
    fi
fi

if command -v adb &>/dev/null; then
    ADB="adb"
elif [ -n "${ANDROID_HOME:-}" ]; then
    ADB="$ANDROID_HOME/platform-tools/adb"
else
    ADB="$HOME/Library/Android/sdk/platform-tools/adb"
fi

ANDROID_READY=false
if ! $IOS_ONLY; then
    ANDROID_DEVICES=$("$ADB" devices 2>/dev/null | grep -c "device$" || true)
    [ "$ANDROID_DEVICES" -gt 0 ] && ANDROID_READY=true
fi

# =============================================================================
# Platform helpers
# =============================================================================
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
    local device_path="/sdcard/ac_invoke_tmp.png"
    "$ADB" shell screencap -p "$device_path" &>/dev/null
    "$ADB" pull "$device_path" "$out" &>/dev/null || true
    "$ADB" shell rm "$device_path" &>/dev/null || true
}

screenshot_hash() {
    local f="$1"
    [ -f "$f" ] && md5 -q "$f" 2>/dev/null || echo ""
}

# =============================================================================
# JSON parser: extract actions from card JSON
# =============================================================================
# Returns lines of: type|title
extract_actions_from_json() {
    local json_file="$1"
    python3 -c "
import json, sys

def find_actions(obj, results, context='card'):
    \"\"\"Recursively find all actions in a card JSON.
    Returns lines of: type|title|mode  (mode is primary/secondary/body)\"\"\"
    if isinstance(obj, dict):
        # Check 'actions' arrays (card-level and ActionSet)
        for action in obj.get('actions', []):
            atype = action.get('type', '')
            title = action.get('title', '')
            enabled = action.get('isEnabled', True)
            mode = (action.get('mode') or 'primary').lower()
            if context == 'body':
                mode = 'body'
            if title and enabled is not False:
                results.append(f'{atype}|{title}|{mode}')
        # Check selectAction on elements
        sa = obj.get('selectAction')
        if isinstance(sa, dict):
            atype = sa.get('type', '')
            title = sa.get('title', '') or 'selectAction'
            results.append(f'{atype}|{title}|body')
        # Recurse into body, items, columns, cells, content, card
        for key in ('body', 'items', 'columns', 'cells', 'content', 'card', 'inlines'):
            child = obj.get(key)
            child_ctx = 'body' if key in ('body', 'items', 'columns') else context
            if isinstance(child, list):
                for item in child:
                    find_actions(item, results, child_ctx)
            elif isinstance(child, dict):
                find_actions(child, results, child_ctx)
    elif isinstance(obj, list):
        for item in obj:
            find_actions(item, results, context)

with open('$json_file') as f:
    card = json.load(f)

results = []
find_actions(card, results)
# Deduplicate while preserving order
seen = set()
for r in results:
    if r not in seen:
        seen.add(r)
        print(r)
" 2>/dev/null
}

resolve_card_json() {
    local card_path="$1"
    local json_file="${REPO_ROOT}/shared/test-cards/${card_path}.json"
    [ -f "$json_file" ] && echo "$json_file" || echo ""
}

# =============================================================================
# Android: find and tap action buttons via uiautomator
# =============================================================================
android_dump_ui() {
    local out="$1"
    "$ADB" shell uiautomator dump /sdcard/ac_ui_dump.xml &>/dev/null
    "$ADB" pull /sdcard/ac_ui_dump.xml "$out" &>/dev/null 2>&1
    "$ADB" shell rm /sdcard/ac_ui_dump.xml &>/dev/null || true
}

# Find a button in the UI dump by its label (content-desc or text).
# In Jetpack Compose, content-desc is on a non-clickable child node while the
# clickable wrapper parent has empty content-desc. So we:
#   1. Find any node matching the label (content-desc or text)
#   2. Walk up to find the nearest clickable ancestor
#   3. Return the clickable ancestor's center coordinates
# Returns: cx|cy  (center coordinates) or empty string.
android_find_button() {
    local dump_file="$1"
    local label="$2"
    python3 -c "
import xml.etree.ElementTree as ET, re, sys

tree = ET.parse('$dump_file')
root = tree.getroot()
label = '''$label'''

# Build parent map for ancestor traversal
parent_map = {}
for parent in root.iter():
    for child in parent:
        parent_map[child] = parent

def find_clickable_ancestor(node):
    \"\"\"Walk up the tree to find the nearest clickable ancestor.\"\"\"
    current = node
    while current is not None:
        if current.get('clickable') == 'true' and current.get('enabled', 'true') == 'true':
            return current
        current = parent_map.get(current)
    return None

# Search all nodes for matching label
for node in root.iter('node'):
    content_desc = node.get('content-desc', '')
    text = node.get('text', '')
    if content_desc == label or text == label:
        # Check if this node itself is clickable
        target = node if node.get('clickable') == 'true' else find_clickable_ancestor(node)
        if target is not None:
            bounds = target.get('bounds', '')
            m = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', bounds)
            if m:
                x1, y1, x2, y2 = int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4))
                print(f'{(x1+x2)//2}|{(y1+y2)//2}')
                sys.exit(0)
" 2>/dev/null
}

# Find ALL action buttons in the UI dump by scanning for labeled nodes
# and resolving their clickable ancestors (Compose parent-traversal).
# Returns lines of: label|cx|cy
android_find_all_buttons() {
    local dump_file="$1"
    python3 -c "
import xml.etree.ElementTree as ET, re

tree = ET.parse('$dump_file')
root = tree.getroot()

# Build parent map
parent_map = {}
for parent in root.iter():
    for child in parent:
        parent_map[child] = parent

SKIP_LABELS = {'More actions', 'Back', 'Navigate up', 'Gallery',
               'Editor', 'Performance', 'More', 'Settings', 'Teams',
               'Show JSON', 'Copy JSON', 'Edit in Editor', 'Bookmark', 'Reload'}

def find_clickable_ancestor(node):
    current = node
    while current is not None:
        if current.get('clickable') == 'true' and current.get('enabled', 'true') == 'true':
            return current
        current = parent_map.get(current)
    return None

seen_bounds = set()
for node in root.iter('node'):
    pkg = node.get('package', '')
    if 'adaptivecards' not in pkg:
        continue
    content_desc = node.get('content-desc', '')
    text = node.get('text', '')
    label = content_desc or text
    if not label or label in SKIP_LABELS:
        continue
    # Find clickable target
    target = node if node.get('clickable') == 'true' else find_clickable_ancestor(node)
    if target is None:
        continue
    bounds = target.get('bounds', '')
    if bounds in seen_bounds:
        continue
    seen_bounds.add(bounds)
    m = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', bounds)
    if m:
        x1, y1, x2, y2 = int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4))
        print(f'{label}|{(x1+x2)//2}|{(y1+y2)//2}')
" 2>/dev/null
}

android_tap_at() {
    "$ADB" shell input tap "$1" "$2" &>/dev/null
}

android_press_back() {
    "$ADB" shell input keyevent KEYCODE_BACK &>/dev/null
}

# Scroll down to find overflow/secondary actions that may be below fold
android_scroll_down() {
    "$ADB" shell input swipe 540 1500 540 800 300 &>/dev/null
}

# =============================================================================
# iOS: trigger actions via deep link
# =============================================================================
# Uses the `adaptivecards://tap-action/{title}` deep link supported by the
# iOS sample app. The app programmatically finds the action by title in the
# currently displayed card and triggers it via the ActionHandler, which has
# full access to the CardViewModel for visual actions (ShowCard, Popover, etc).
# This is 100% reliable regardless of button position or card layout.

ios_tap_action() {
    local title="$1"
    # URL-encode the title for the deep link
    local encoded_title
    encoded_title=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$title'''))")
    xcrun simctl openurl "$SIM_UDID" "adaptivecards://tap-action/${encoded_title}" &>/dev/null
}

# =============================================================================
# Test a single action tap on Android
# =============================================================================
android_test_action() {
    local card_name="$1"
    local action_type="$2"
    local action_title="$3"
    local action_idx="$4"
    local dump_file="/tmp/ac_ui_dump_${card_name}.xml"

    # Dump current UI
    android_dump_ui "$dump_file"

    # Try to find the button by title
    local coords
    coords=$(android_find_button "$dump_file" "$action_title")

    if [ -z "$coords" ]; then
        # Button not found — may be in overflow menu ("More actions")
        # Try tapping the overflow button first
        local overflow_coords
        overflow_coords=$(android_find_button "$dump_file" "More actions")
        if [ -n "$overflow_coords" ]; then
            local ox oy
            IFS='|' read -r ox oy <<< "$overflow_coords"
            android_tap_at "$ox" "$oy"
            sleep 1
            # Re-dump to find the menu item
            android_dump_ui "$dump_file"
            coords=$(android_find_button "$dump_file" "$action_title")
        fi
    fi

    if [ -z "$coords" ]; then
        # Still not found — try scrolling down
        android_press_back  # dismiss any open menu
        sleep 0.5
        android_scroll_down
        sleep 1
        android_dump_ui "$dump_file"
        coords=$(android_find_button "$dump_file" "$action_title")
    fi

    if [ -z "$coords" ]; then
        echo "NOTFOUND"
        return 0
    fi

    local cx cy
    IFS='|' read -r cx cy <<< "$coords"

    # Pre-tap screenshot
    local pre_ss="$REPORT_DIR/screenshots/android/${card_name}-pre-${action_idx}.png"
    android_screenshot "$pre_ss"
    local pre_hash
    pre_hash=$(screenshot_hash "$pre_ss")

    # Tap the button
    android_tap_at "$cx" "$cy"
    sleep "$TAP_WAIT"

    # Check crash
    if ! android_is_running; then
        echo "CRASH"
        "$ADB" shell am start -n "$ANDROID_APP_ID/.MainActivity" &>/dev/null || true
        sleep 2
        return 1
    fi

    # Post-tap screenshot
    local post_ss="$REPORT_DIR/screenshots/android/${card_name}-post-${action_idx}.png"
    android_screenshot "$post_ss"
    local post_hash
    post_hash=$(screenshot_hash "$post_ss")

    # UX verification
    local ux_changed=false
    if [ "$pre_hash" != "$post_hash" ]; then
        ux_changed=true
    fi

    if is_visual_action "$action_type"; then
        if $ux_changed; then
            echo "PASS"
        else
            echo "UX_UNCHANGED"
        fi
    else
        # Non-visual: just verify no crash
        echo "PASS"
    fi

    # Dismiss overlays (popover, show card, etc.)
    android_press_back
    sleep 0.5

    return 0
}

# =============================================================================
# Test a single action tap on iOS (via deep link)
# =============================================================================
ios_test_action() {
    local card_name="$1"
    local action_type="$2"
    local action_title="$3"
    local action_idx="$4"

    # Pre-tap screenshot
    local pre_ss="$REPORT_DIR/screenshots/ios/${card_name}-pre-${action_idx}.png"
    ios_screenshot "$pre_ss"
    local pre_hash
    pre_hash=$(screenshot_hash "$pre_ss")

    # Trigger the action via deep link
    ios_tap_action "$action_title"
    sleep "$TAP_WAIT"

    # Check crash
    if ! ios_is_running; then
        echo "CRASH"
        xcrun simctl launch "$SIM_UDID" "$IOS_APP_ID" &>/dev/null || true
        sleep 2
        return 1
    fi

    # Post-tap screenshot
    local post_ss="$REPORT_DIR/screenshots/ios/${card_name}-post-${action_idx}.png"
    ios_screenshot "$post_ss"
    local post_hash
    post_hash=$(screenshot_hash "$post_ss")

    # UX verification
    local ux_changed=false
    if [ "$pre_hash" != "$post_hash" ]; then
        ux_changed=true
    fi

    if is_visual_action "$action_type"; then
        if $ux_changed; then
            echo "PASS"
        else
            echo "UX_UNCHANGED"
        fi
    else
        echo "PASS"
    fi

    return 0
}

# =============================================================================
# Banner
# =============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Action Invocation Test                                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Cards:      ${#SELECTED_CARDS[@]}"
echo "  Render wait: ${RENDER_WAIT}s"
echo "  Tap wait:    ${TAP_WAIT}s"
echo "  Report:      $REPORT_DIR"
echo ""

# =============================================================================
# Pre-flight
# =============================================================================
echo "━━━ Pre-flight ━━━"
$IOS_READY     && echo "  ✅ iOS:     $IOS_SIMULATOR — Booted" || echo "  ❌ iOS:     Not available"
$ANDROID_READY && echo "  ✅ Android: Connected" || echo "  ❌ Android: Not available"

if ! $IOS_READY && ! $ANDROID_READY; then
    echo "  ⛔ Neither platform available."
    exit 1
fi

echo ""

# =============================================================================
# Main test loop
# =============================================================================
echo "━━━ Action Invocation Testing ━━━"
echo ""

total_pass=0
total_fail=0
total_crash=0
total_skip=0
declare -a failed_entries=()

card_idx=0
for card_path in "${SELECTED_CARDS[@]}"; do
    card_idx=$((card_idx + 1))
    card_name=$(basename "$card_path")

    # Resolve card JSON
    json_file=$(resolve_card_json "$card_path")
    if [ -z "$json_file" ]; then
        printf "  [%2d/%d] %-35s ⚠️  JSON not found — skipped\n" "$card_idx" "${#SELECTED_CARDS[@]}" "$card_name"
        total_skip=$((total_skip + 1))
        continue
    fi

    # Extract actions from card
    actions_list=$(extract_actions_from_json "$json_file")
    if [ -z "$actions_list" ]; then
        printf "  [%2d/%d] %-35s ⚠️  No actions found — skipped\n" "$card_idx" "${#SELECTED_CARDS[@]}" "$card_name"
        total_skip=$((total_skip + 1))
        continue
    fi

    action_count=$(echo "$actions_list" | wc -l | tr -d ' ')
    printf "  [%2d/%d] %-35s (%d actions)\n" "$card_idx" "${#SELECTED_CARDS[@]}" "$card_name" "$action_count"

    # Navigate to card on both platforms
    $IOS_READY && ios_navigate "$card_path" &
    $ANDROID_READY && android_navigate "$card_path" &
    wait
    sleep "$RENDER_WAIT"

    # --- Android action tapping ---
    # Use fd 3 to prevent child processes (adb, python3) from consuming the loop's stdin
    if $ANDROID_READY; then
        action_idx=0
        while IFS='|' read -r -u 3 action_type action_title action_mode; do
            [ -z "$action_title" ] && continue
            action_idx=$((action_idx + 1))

            result=$(android_test_action "$card_name" "$action_type" "$action_title" "$action_idx")
            case "$result" in
                PASS)
                    printf "         🤖 [%d] %-30s ✅ %s\n" "$action_idx" "$action_title" "$action_type"
                    total_pass=$((total_pass + 1))
                    ;;
                UX_UNCHANGED)
                    printf "         🤖 [%d] %-30s ⚠️  UX unchanged (%s)\n" "$action_idx" "$action_title" "$action_type"
                    total_fail=$((total_fail + 1))
                    failed_entries+=("🤖 $card_name → $action_title ($action_type): UX unchanged")
                    ;;
                CRASH)
                    printf "         🤖 [%d] %-30s 💥 CRASH after tap\n" "$action_idx" "$action_title"
                    total_crash=$((total_crash + 1))
                    failed_entries+=("🤖 $card_name → $action_title ($action_type): CRASH")
                    ;;
                NOTFOUND)
                    printf "         🤖 [%d] %-30s ⏭️  Button not found in UI\n" "$action_idx" "$action_title"
                    total_skip=$((total_skip + 1))
                    ;;
            esac

            # Re-navigate to card for next action (clean state)
            android_navigate "$card_path" &>/dev/null
            sleep 1.5
        done 3<<< "$actions_list"
    fi

    # --- iOS action tapping (via deep link) ---
    if $IOS_READY; then
        # Use fd 4 to prevent child processes from consuming the loop's stdin
        action_idx=0
        while IFS='|' read -r -u 4 action_type action_title action_mode; do
            [ -z "$action_title" ] && continue
            # Skip selectAction entries — they're on elements, not tappable buttons
            [ "$action_title" = "selectAction" ] && continue
            action_idx=$((action_idx + 1))

            result=$(ios_test_action "$card_name" "$action_type" "$action_title" "$action_idx")
            case "$result" in
                PASS)
                    printf "         🍎 [%d] %-30s ✅ %s\n" "$action_idx" "$action_title" "$action_type"
                    total_pass=$((total_pass + 1))
                    ;;
                UX_UNCHANGED)
                    printf "         🍎 [%d] %-30s ⚠️  UX unchanged (%s)\n" "$action_idx" "$action_title" "$action_type"
                    total_fail=$((total_fail + 1))
                    failed_entries+=("🍎 $card_name → $action_title ($action_type): UX unchanged")
                    ;;
                CRASH)
                    printf "         🍎 [%d] %-30s 💥 CRASH after tap\n" "$action_idx" "$action_title"
                    total_crash=$((total_crash + 1))
                    failed_entries+=("🍎 $card_name → $action_title ($action_type): CRASH")
                    ;;
            esac

            # Re-navigate for clean state
            ios_navigate "$card_path" &>/dev/null
            sleep 1.5
        done 4<<< "$actions_list"
    fi

    # Return to gallery
    $IOS_READY && ios_gallery &
    $ANDROID_READY && android_gallery &
    wait
    sleep 0.5
done

echo ""

# =============================================================================
# Summary
# =============================================================================
echo "━━━ Results ━━━"
echo ""
echo "  ✅ Pass:     $total_pass"
echo "  ⚠️  Fail:     $total_fail"
echo "  💥 Crash:    $total_crash"
echo "  ⏭️  Skipped:  $total_skip"
echo ""

if [ ${#failed_entries[@]} -gt 0 ]; then
    echo "  Failed actions:"
    for entry in "${failed_entries[@]}"; do
        echo "    ❌ $entry"
    done
    echo ""
fi

echo "  Screenshots: $REPORT_DIR/screenshots/"
echo ""

if [ "$total_crash" -gt 0 ] || [ "$total_fail" -gt 0 ]; then
    echo "  ❌ ACTION INVOCATION TEST FAILED"
    exit 1
else
    echo "  ✅ ALL ACTIONS INVOKED SUCCESSFULLY"
fi

echo ""
