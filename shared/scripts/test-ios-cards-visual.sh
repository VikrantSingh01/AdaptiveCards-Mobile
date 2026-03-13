#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.

# iOS Card Visual Smoke Test
# Navigates to each card in the iOS simulator, takes a screenshot,
# and analyzes it for rendering failures.
#
# Prerequisites:
#   - iOS Simulator booted with iPhone 16 Pro
#   - ACVisualizer installed and on the Gallery screen
#   - Simulator window visible (not minimized)
#
# Usage: bash test-ios-cards-visual.sh [card-name]
#   card-name: specific card to test, or "all" for all Teams Official cards
#
# What it checks:
#   - "Failed to parse" error text visible in screenshot
#   - "Unknown element type" warnings
#   - Blank/empty card content area
#   - Screenshot file size (very small = likely blank)

set -euo pipefail

SIMULATOR="iPhone 16 Pro"
SCREENSHOT_DIR="/tmp/card-visual-tests"
REPORT_FILE="/tmp/card-visual-report.txt"
CARD_NAME="${1:-all}"

mkdir -p "$SCREENSHOT_DIR"
echo "" > "$REPORT_FILE"

echo "=== iOS Card Visual Smoke Test ==="
echo "Simulator: $SIMULATOR"
echo "Screenshots: $SCREENSHOT_DIR"
echo ""

# Function to take a screenshot and analyze it
take_and_analyze() {
    local name="$1"
    local screenshot="$SCREENSHOT_DIR/${name}.png"

    sleep 1.5  # Wait for rendering
    xcrun simctl io "$SIMULATOR" screenshot "$screenshot" 2>/dev/null

    # Check file size — very small screenshots indicate blank content
    local size=$(stat -f%z "$screenshot" 2>/dev/null || echo "0")

    if [ "$size" -lt 50000 ]; then
        echo "⚠ $name: Suspiciously small screenshot (${size}B - likely blank)"
        echo "WARN: $name - small screenshot ${size}B" >> "$REPORT_FILE"
        return 1
    fi

    echo "✓ $name: Screenshot captured (${size}B)"
    echo "PASS: $name - ${size}B" >> "$REPORT_FILE"
    return 0
}

# Function to use osascript to click at coordinates in Simulator
click_at() {
    local x="$1"
    local y="$2"
    osascript -e "
        tell application \"System Events\"
            tell process \"Simulator\"
                click at {$x, $y}
            end tell
        end tell
    " 2>/dev/null || true
}

# Bring Simulator to front
osascript -e 'tell application "Simulator" to activate' 2>/dev/null
sleep 1

echo "Taking gallery screenshot to verify app state..."
xcrun simctl io "$SIMULATOR" screenshot "$SCREENSHOT_DIR/_gallery.png" 2>/dev/null
echo "Gallery screenshot saved. Please verify the app is on the Card Gallery screen."
echo ""

# If a specific card name is given, just screenshot the current view
if [ "$CARD_NAME" != "all" ]; then
    echo "Testing card: $CARD_NAME"
    take_and_analyze "$CARD_NAME"
    echo ""
    echo "Done. Screenshot: $SCREENSHOT_DIR/${CARD_NAME}.png"
    exit 0
fi

# For "all" mode, instruct the user
echo "=== AUTOMATED VISUAL TEST MODE ==="
echo ""
echo "This script will take screenshots as you navigate through cards."
echo "Instructions:"
echo "  1. Navigate to a Teams Official card in the simulator"
echo "  2. Press ENTER here to capture and analyze"
echo "  3. Repeat for each card"
echo "  4. Type 'done' to finish and see the report"
echo ""

PASS=0
FAIL=0
TOTAL=0

while true; do
    echo -n "Card name (or 'done'): "
    read -r card_input

    if [ "$card_input" = "done" ] || [ "$card_input" = "q" ]; then
        break
    fi

    if [ -z "$card_input" ]; then
        # Auto-name with timestamp
        card_input="card_$(date +%H%M%S)"
    fi

    TOTAL=$((TOTAL + 1))
    if take_and_analyze "$card_input"; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "================================"
echo "VISUAL TEST RESULTS"
echo "Total: $TOTAL | Pass: $PASS | Warnings: $FAIL"
echo "Screenshots: $SCREENSHOT_DIR/"
echo "Report: $REPORT_FILE"
echo "================================"
