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
BUILT_IN=(
    "simple-text"
    "rich-text"
    "containers"
    "all-inputs"
    "input-form"
    "all-actions"
    "markdown"
    "charts"
    "datagrid"
    "list"
    "carousel"
    "accordion"
    "tab-set"
    "table"
    "media"
    "progress-indicators"
    "rating"
    "code-block"
    "fluent-theming"
    "responsive-layout"
    "themed-images"
    "compound-buttons"
    "split-buttons"
    "popover-action"
    "teams-connector"
    "teams-task-module"
    "copilot-citations"
    "streaming-card"
    "templating-basic"
    "templating-conditional"
    "templating-iteration"
    "templating-expressions"
    "templating-nested"
    "advanced-combined"
    "sample-catalog"
    "action-overflow"
)

EDGE_CASES=(
    "edge-all-unknown-types"
    "edge-deeply-nested"
    "edge-empty-card"
    "edge-empty-containers"
    "edge-long-text"
    "edge-max-actions"
    "edge-mixed-inputs"
    "edge-rtl-content"
)

OFFICIAL=(
    "official-samples/activity-update"
    "official-samples/agenda"
    "official-samples/application-login"
    "official-samples/calendar-reminder"
    "official-samples/expense-report"
    "official-samples/flight-details"
    "official-samples/flight-itinerary"
    "official-samples/flight-update"
    "official-samples/flight-update-table"
    "official-samples/food-order"
    "official-samples/image-gallery"
    "official-samples/input-form-official"
    "official-samples/input-form-rtl"
    "official-samples/inputs-with-validation"
    "official-samples/order-confirmation"
    "official-samples/order-delivery"
    "official-samples/restaurant"
    "official-samples/restaurant-order"
    "official-samples/show-card-wizard"
    "official-samples/sporting-event"
    "official-samples/stock-update"
    "official-samples/weather-compact"
    "official-samples/weather-large"
    "official-samples/product-video"
)

ELEMENT=(
    "element-samples/action-execute-is-enabled"
    "element-samples/action-execute-mode"
    "element-samples/action-execute-tooltip"
    "element-samples/action-openurl-is-enabled"
    "element-samples/action-openurl-mode"
    "element-samples/action-openurl-tooltip"
    "element-samples/action-showcard-is-enabled"
    "element-samples/action-showcard-mode"
    "element-samples/action-showcard-tooltip"
    "element-samples/action-submit-is-enabled"
    "element-samples/action-submit-mode"
    "element-samples/action-submit-tooltip"
    "element-samples/action-role"
    "element-samples/adaptive-card-rtl"
    "element-samples/column-rtl"
    "element-samples/container-rtl"
    "element-samples/image-select-action"
    "element-samples/image-force-load"
    "element-samples/imageset-stacked-style"
    "element-samples/input-choiceset-filtered"
    "element-samples/input-choiceset-dynamic-typeahead"
    "element-samples/input-text-password-style"
    "element-samples/input-label-position"
    "element-samples/input-style"
    "element-samples/input-toggle-consolidated"
    "element-samples/table-basic"
    "element-samples/table-first-row-headers"
    "element-samples/table-grid-style"
    "element-samples/table-horizontal-alignment"
    "element-samples/table-show-grid-lines"
    "element-samples/table-vertical-alignment"
    "element-samples/textblock-style"
    "element-samples/carousel-basic"
    "element-samples/carousel-header"
    "element-samples/carousel-height"
    "element-samples/carousel-height-pixels"
    "element-samples/carousel-height-vertical"
    "element-samples/carousel-initial-page"
    "element-samples/carousel-loop"
    "element-samples/carousel-scenario-cards"
    "element-samples/carousel-scenario-timer"
    "element-samples/carousel-styles"
    "element-samples/carousel-vertical"
    "element-samples/media-basic"
    "element-samples/media-sources"
)

TEAMS_OFFICIAL=(
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

declare -a CARDS
case "$CATEGORY" in
    built-in)
        CARDS=("${BUILT_IN[@]}")
        ;;
    edge-cases)
        CARDS=("${EDGE_CASES[@]}")
        ;;
    official)
        CARDS=("${OFFICIAL[@]}")
        ;;
    element)
        CARDS=("${ELEMENT[@]}")
        ;;
    teams-official)
        CARDS=("${TEAMS_OFFICIAL[@]}")
        ;;
    all)
        # All testable cards (excludes templates which need data binding)
        CARDS=("${BUILT_IN[@]}" "${EDGE_CASES[@]}" "${OFFICIAL[@]}" "${ELEMENT[@]}" "${TEAMS_OFFICIAL[@]}")
        ;;
    *)
        echo "Usage: $0 [built-in|edge-cases|official|element|teams-official|all]"
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
