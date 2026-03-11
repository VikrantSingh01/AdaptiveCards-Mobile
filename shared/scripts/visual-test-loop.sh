#!/bin/bash
# Self-Healing Visual Test Loop for iOS Cards
# Uses deep links (adaptivecards://card/{path}) to navigate to each card,
# takes a screenshot, and analyzes it for rendering failures.
#
# Usage: bash visual-test-loop.sh [category]
#   category: teams-official (default), official, all-built-in

set -euo pipefail

SIMULATOR="iPhone 16e"
APP_ID="com.microsoft.adaptivecards.sampleapp"
SCREENSHOT_DIR="/tmp/card-visual-tests"
REPORT_FILE="$SCREENSHOT_DIR/report.md"
CATEGORY="${1:-teams-official}"

mkdir -p "$SCREENSHOT_DIR"

# Card lists by category
declare -a CARDS
case "$CATEGORY" in
    teams-official)
        CARDS=(
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
        ;;
    *)
        echo "Usage: $0 [teams-official]"
        exit 1
        ;;
esac

echo "# iOS Card Visual Test Report" > "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"
echo "Category: $CATEGORY" >> "$REPORT_FILE"
echo "Cards: ${#CARDS[@]}" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== iOS Visual Test Loop ==="
echo "Testing ${#CARDS[@]} cards via deep links"
echo ""

# Ensure app is running
xcrun simctl terminate "$SIMULATOR" "$APP_ID" 2>/dev/null || true
sleep 1
xcrun simctl launch "$SIMULATOR" "$APP_ID"
sleep 3

PASS=0
FAIL=0
WARN=0

for card_path in "${CARDS[@]}"; do
    card_name=$(basename "$card_path")
    echo -n "  $card_name... "

    # Navigate via deep link
    xcrun simctl openurl "$SIMULATOR" "adaptivecards://card/$card_path" 2>/dev/null
    sleep 3

    # Screenshot
    SCREENSHOT="$SCREENSHOT_DIR/${card_name}.png"
    xcrun simctl io "$SIMULATOR" screenshot "$SCREENSHOT" 2>/dev/null

    SIZE=$(stat -f%z "$SCREENSHOT" 2>/dev/null || echo "0")

    # Analyze: very small = blank, medium-small = possible issue
    if [ "$SIZE" -lt 50000 ]; then
        echo "FAIL (${SIZE}B — likely blank/error)"
        echo "| $card_name | FAIL | ${SIZE}B | Blank or error screen |" >> "$REPORT_FILE"
        FAIL=$((FAIL + 1))
    elif [ "$SIZE" -lt 100000 ]; then
        echo "WARN (${SIZE}B — may have minimal content)"
        echo "| $card_name | WARN | ${SIZE}B | Low content |" >> "$REPORT_FILE"
        WARN=$((WARN + 1))
    else
        echo "PASS (${SIZE}B)"
        echo "| $card_name | PASS | ${SIZE}B | |" >> "$REPORT_FILE"
        PASS=$((PASS + 1))
    fi

    # Navigate back to gallery for next card
    xcrun simctl openurl "$SIMULATOR" "adaptivecards://gallery" 2>/dev/null
    sleep 1
done

echo ""
echo "=========================================="
echo "| Total | Pass | Warn | Fail |"
echo "| ${#CARDS[@]} | $PASS | $WARN | $FAIL |"
echo "=========================================="
echo "Screenshots: $SCREENSHOT_DIR/"
echo "Report: $REPORT_FILE"

exit $FAIL
