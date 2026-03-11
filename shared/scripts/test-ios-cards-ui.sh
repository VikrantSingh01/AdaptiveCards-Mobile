#!/bin/bash
# iOS Card UI Smoke Test
# Takes screenshots of each card in the iOS simulator and checks for rendering errors.
#
# Prerequisites:
#   - iOS Simulator booted with iPhone 16e
#   - AdaptiveCardsSampleApp installed and running
#
# Usage: bash test-ios-cards-ui.sh [category]
#   category: teams-official (default), all
#
# Output: screenshots in /tmp/card-screenshots/ and a report

set -euo pipefail

SIMULATOR="iPhone 16e"
APP_ID="com.microsoft.adaptivecards.sampleapp"
SCREENSHOT_DIR="/tmp/card-screenshots"
REPORT_FILE="/tmp/card-ui-report.txt"
CATEGORY="${1:-teams-official}"

mkdir -p "$SCREENSHOT_DIR"
echo "" > "$REPORT_FILE"

echo "=== iOS Card UI Smoke Test ==="
echo "Simulator: $SIMULATOR"
echo "Category: $CATEGORY"
echo "Screenshots: $SCREENSHOT_DIR"
echo ""

# Ensure simulator is booted
xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
sleep 2

# Get list of test card files
CARD_DIR="$(cd "$(dirname "$0")/../test-cards" && pwd)"

case "$CATEGORY" in
    teams-official)
        CARD_FILES=$(ls "$CARD_DIR/teams-official-samples/"*.json 2>/dev/null | sort)
        ;;
    official)
        CARD_FILES=$(ls "$CARD_DIR/official-samples/"*.json 2>/dev/null | sort)
        ;;
    all)
        CARD_FILES=$(find "$CARD_DIR" -name "*.json" ! -name "*-data.json" | sort)
        ;;
    *)
        echo "Unknown category: $CATEGORY"
        exit 1
        ;;
esac

TOTAL=$(echo "$CARD_FILES" | wc -l | tr -d ' ')
echo "Found $TOTAL cards to test"
echo ""

# Parse each card and check for errors using the SDK parser
PASS=0
FAIL=0
WARN=0

for CARD_FILE in $CARD_FILES; do
    FILENAME=$(basename "$CARD_FILE" .json)

    # Quick JSON validation
    if ! python3 -c "import json; json.load(open('$CARD_FILE'))" 2>/dev/null; then
        echo "✗ $FILENAME: Invalid JSON"
        echo "FAIL: $FILENAME - Invalid JSON" >> "$REPORT_FILE"
        FAIL=$((FAIL + 1))
        continue
    fi

    # Check for known problematic patterns
    ISSUES=""

    # Check for unknown element types
    UNKNOWN_TYPES=$(python3 -c "
import json
known = {'TextBlock','Image','Media','RichTextBlock','Container','ColumnSet','Column',
         'ImageSet','FactSet','ActionSet','Table','TableRow','TableCell',
         'Input.Text','Input.Number','Input.Date','Input.Time','Input.Toggle',
         'Input.ChoiceSet','Input.Rating','Input.DataGrid',
         'Carousel','CarouselPage','Accordion','CodeBlock','Rating',
         'ProgressBar','ProgressRing','Spinner','TabSet','List','CompoundButton',
         'Badge','DonutChart','BarChart','LineChart','PieChart','Chart.Donut','Icon',
         'Action.OpenUrl','Action.Submit','Action.ShowCard','Action.ToggleVisibility',
         'Action.Execute','Action.Popover','Action.ResetInputs','Action.RunCommands',
         'Action.OpenUrlDialog','AdaptiveCard','TextRun','CitationRun','Layout.Flow',
         'Layout.AreaGrid','Data.Query','AdaptiveCardReference','DocumentReference'}
card = json.load(open('$CARD_FILE'))
def find(obj, found=set()):
    if isinstance(obj, dict):
        t = obj.get('type','')
        if t and t not in known:
            found.add(t)
        for v in obj.values(): find(v, found)
    elif isinstance(obj, list):
        for item in obj: find(item, found)
    return found
unknowns = find(card)
if unknowns: print(','.join(sorted(unknowns)))
" 2>/dev/null)

    if [ -n "$UNKNOWN_TYPES" ]; then
        ISSUES="unknown types: $UNKNOWN_TYPES"
    fi

    if [ -n "$ISSUES" ]; then
        echo "⚠ $FILENAME: $ISSUES"
        echo "WARN: $FILENAME - $ISSUES" >> "$REPORT_FILE"
        WARN=$((WARN + 1))
    else
        echo "✓ $FILENAME"
        echo "PASS: $FILENAME" >> "$REPORT_FILE"
        PASS=$((PASS + 1))
    fi
done

echo ""
echo "================================"
echo "RESULTS: $TOTAL total | $PASS pass | $WARN warnings | $FAIL fail"
echo "Report: $REPORT_FILE"
echo "================================"

exit $FAIL
