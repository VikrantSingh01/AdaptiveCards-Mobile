#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.

# Fully Automated iOS Card Visual Test
# Uses osascript to navigate through cards in the iOS Simulator,
# takes screenshots of each card, and analyzes for rendering failures.
#
# Prerequisites:
#   - iOS Simulator booted and visible (not minimized)
#   - ACVisualizer installed
#   - Accessibility permissions granted to Terminal
#
# Usage: bash auto-test-ios-cards.sh

set -euo pipefail

SIMULATOR="iPhone 16 Pro"
APP_ID="com.microsoft.adaptivecards.sampleapp"
SCREENSHOT_DIR="/tmp/card-auto-tests"
REPORT_FILE="$SCREENSHOT_DIR/report.txt"

mkdir -p "$SCREENSHOT_DIR"
echo "iOS Card Auto-Test Report — $(date)" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Teams Official card filenames
CARDS=(
    "account"
    "author-highlight-video"
    "book-a-room"
    "cafe-menu"
    "communication"
    "course-video"
    "editorial"
    "expense-report"
    "insights"
    "issue"
    "list"
    "project-dashboard"
    "recipe"
    "simple-event"
    "simple-time-off-request"
    "standard-video"
    "team-standup-summary"
    "time-off-request"
    "work-item"
)

echo "=== iOS Card Auto-Test ==="
echo "Testing ${#CARDS[@]} Teams Official cards"
echo "Screenshots: $SCREENSHOT_DIR"
echo ""

# Launch app fresh
xcrun simctl terminate "$SIMULATOR" "$APP_ID" 2>/dev/null || true
sleep 1
xcrun simctl launch "$SIMULATOR" "$APP_ID"
sleep 3

# Bring Simulator to front
osascript -e 'tell application "Simulator" to activate'
sleep 1

# Get Simulator window position and size
WINDOW_INFO=$(osascript -e '
tell application "System Events"
    tell process "Simulator"
        set winPos to position of window 1
        set winSize to size of window 1
        return (item 1 of winPos as string) & "," & (item 2 of winPos as string) & "," & (item 1 of winSize as string) & "," & (item 2 of winSize as string)
    end tell
end tell
' 2>/dev/null)

IFS=',' read -r WIN_X WIN_Y WIN_W WIN_H <<< "$WINDOW_INFO"
echo "Simulator window: ${WIN_X},${WIN_Y} ${WIN_W}x${WIN_H}"

# Calculate center X for tapping
CENTER_X=$((WIN_X + WIN_W / 2))

# Function to tap at a position relative to the Simulator window
tap() {
    local rel_x=$1
    local rel_y=$2
    local abs_x=$((WIN_X + rel_x))
    local abs_y=$((WIN_Y + rel_y))
    osascript -e "
        tell application \"System Events\"
            click at {$abs_x, $abs_y}
        end tell
    " 2>/dev/null
}

# Function to type text into search (uses simctl pbcopy + paste)
search_for() {
    local text="$1"
    # Clear search first - tap search bar then select all + delete
    tap $((WIN_W / 2)) 120  # Tap search bar area
    sleep 0.5
    # Use pbcopy to paste text
    echo -n "$text" | xcrun simctl pbcopy "$SIMULATOR"
    sleep 0.3
    # Paste via keyboard shortcut
    osascript -e '
        tell application "System Events"
            keystroke "a" using command down
            delay 0.2
            keystroke "v" using command down
        end tell
    ' 2>/dev/null
    sleep 1
}

# Function to go back to gallery
go_back() {
    tap 40 55  # Back button (top-left)
    sleep 1
}

# Function to clear search
clear_search() {
    tap $((WIN_W / 2)) 120  # Tap search bar
    sleep 0.3
    osascript -e '
        tell application "System Events"
            keystroke "a" using command down
            delay 0.1
            key code 51  -- delete
        end tell
    ' 2>/dev/null
    sleep 0.5
}

PASS=0
FAIL=0
WARN=0

for card in "${CARDS[@]}"; do
    echo -n "Testing: $card... "

    # Search for the card
    clear_search
    search_for "$card"
    sleep 1

    # Tap the first result (should be around y=200 in the list)
    tap $((WIN_W / 2)) 210
    sleep 2.5  # Wait for card to render

    # Take screenshot
    SCREENSHOT="$SCREENSHOT_DIR/${card}.png"
    xcrun simctl io "$SIMULATOR" screenshot "$SCREENSHOT" 2>/dev/null

    # Analyze screenshot size
    SIZE=$(stat -f%z "$SCREENSHOT" 2>/dev/null || echo "0")

    if [ "$SIZE" -lt 30000 ]; then
        echo "FAIL (${SIZE}B - likely blank or error)"
        echo "FAIL: $card - ${SIZE}B (blank/error)" >> "$REPORT_FILE"
        FAIL=$((FAIL + 1))
    elif [ "$SIZE" -lt 80000 ]; then
        echo "WARN (${SIZE}B - may have issues)"
        echo "WARN: $card - ${SIZE}B" >> "$REPORT_FILE"
        WARN=$((WARN + 1))
    else
        echo "PASS (${SIZE}B)"
        echo "PASS: $card - ${SIZE}B" >> "$REPORT_FILE"
        PASS=$((PASS + 1))
    fi

    # Go back to gallery
    go_back
    sleep 0.5
done

echo ""
echo "=========================================="
echo "AUTO-TEST RESULTS"
echo "Total: ${#CARDS[@]} | Pass: $PASS | Warn: $WARN | Fail: $FAIL"
echo "Screenshots: $SCREENSHOT_DIR/"
echo "Report: $REPORT_FILE"
echo "=========================================="
echo ""

# Show failures
if [ $FAIL -gt 0 ] || [ $WARN -gt 0 ]; then
    echo "Issues found:"
    grep -E "^(FAIL|WARN):" "$REPORT_FILE"
fi

exit $FAIL
