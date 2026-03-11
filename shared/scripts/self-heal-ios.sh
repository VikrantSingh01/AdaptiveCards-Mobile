#!/bin/bash
# =============================================================================
# Self-Healing iOS Card Test Loop
# =============================================================================
#
# Automated detect → diagnose → report cycle for Adaptive Card rendering.
# Uses deep links to navigate to each card, takes screenshots, and analyzes
# them for rendering failures.
#
# Usage:
#   bash shared/scripts/self-heal-ios.sh                    # Full run
#   bash shared/scripts/self-heal-ios.sh --parse-only       # Parse tests only
#   bash shared/scripts/self-heal-ios.sh --visual-only      # Visual tests only
#   bash shared/scripts/self-heal-ios.sh --card cafe-menu   # Single card
#
# What it does:
#   Phase 1: Parse Regression — swift test catches Codable decoder failures
#   Phase 2: Visual Smoke — deep-link to each card, screenshot, analyze
#   Phase 3: Report — markdown report with issues + screenshots
#
# Prerequisites:
#   - iOS Simulator "iPhone 16e" booted
#   - Xcode and swift toolchain available
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SIMULATOR="iPhone 16e"
APP_ID="com.microsoft.adaptivecards.sampleapp"
REPORT_DIR="/tmp/self-heal-$(date +%Y%m%d-%H%M%S)"
REPORT_FILE="$REPORT_DIR/report.md"
MODE="full"
SINGLE_CARD=""

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --parse-only) MODE="parse"; shift ;;
        --visual-only) MODE="visual"; shift ;;
        --card) SINGLE_CARD="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

mkdir -p "$REPORT_DIR/screenshots"

echo "# Self-Healing iOS Card Test Report" > "$REPORT_FILE"
echo "**Date:** $(date)" >> "$REPORT_FILE"
echo "**Mode:** $MODE" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Teams Official cards
TEAMS_CARDS=(
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

# =============================================================================
# Phase 1: Parse Regression Tests
# =============================================================================
phase1_parse() {
    echo ""
    echo "━━━ Phase 1: Parse Regression Tests ━━━"
    echo "## Phase 1: Parse Regression" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    cd "$REPO_ROOT/ios"

    # Run regression tests and capture output
    local test_output
    test_output=$(swift test --filter CardParsingRegressionTests 2>&1) || true

    local failures
    failures=$(echo "$test_output" | grep "\.json:" | sed 's/.*  //' | sort -u)

    if [ -z "$failures" ]; then
        echo "  ✅ All cards parse successfully"
        echo "**Result:** All cards parse successfully (0 failures)" >> "$REPORT_FILE"
    else
        local fail_count
        fail_count=$(echo "$failures" | wc -l | tr -d ' ')
        echo "  ❌ $fail_count parsing failures found"
        echo "**Result:** $fail_count parsing failures" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        echo "$failures" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"

        # Categorize failures
        echo "" >> "$REPORT_FILE"
        echo "### Error Categories" >> "$REPORT_FILE"
        echo "$failures" | sed 's/.*: //' | sort | uniq -c | sort -rn | while read -r count pattern; do
            echo "- **$count cards:** $pattern" >> "$REPORT_FILE"
        done
    fi
    echo "" >> "$REPORT_FILE"

    cd "$REPO_ROOT"
}

# =============================================================================
# Phase 2: Visual Smoke Tests
# =============================================================================
phase2_visual() {
    echo ""
    echo "━━━ Phase 2: Visual Smoke Tests ━━━"
    echo "## Phase 2: Visual Rendering" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Build and install
    echo "  Building sample app..."
    cd "$REPO_ROOT"
    local build_output
    build_output=$(xcodebuild -project "$REPO_ROOT/ios/SampleApp.xcodeproj" \
        -scheme AdaptiveCardsSampleApp \
        -sdk iphonesimulator \
        -destination "platform=iOS Simulator,name=$SIMULATOR" \
        build 2>&1)
    local build_result
    build_result=$(echo "$build_output" | tail -1)

    if [[ "$build_result" != *"BUILD SUCCEEDED"* ]]; then
        echo "  ❌ Build failed"
        echo "**Build:** FAILED" >> "$REPORT_FILE"
        return 1
    fi
    echo "  ✅ Build succeeded"

    # Install and launch
    local app_path
    app_path=$(find ~/Library/Developer/Xcode/DerivedData/SampleApp-*/Build/Products/Debug-iphonesimulator -name "AdaptiveCardsSampleApp.app" -maxdepth 1 2>/dev/null | head -1)
    if [ -z "$app_path" ]; then
        echo "  ❌ Could not find built app"
        return 1
    fi
    xcrun simctl install "$SIMULATOR" "$app_path" 2>/dev/null
    xcrun simctl terminate "$SIMULATOR" "$APP_ID" 2>/dev/null || true
    sleep 1
    xcrun simctl launch "$SIMULATOR" "$APP_ID"
    sleep 3

    # Determine which cards to test
    local cards_to_test=()
    if [ -n "$SINGLE_CARD" ]; then
        cards_to_test=("$SINGLE_CARD")
    else
        cards_to_test=("${TEAMS_CARDS[@]}")
    fi

    echo "  Testing ${#cards_to_test[@]} cards..."
    echo "" >> "$REPORT_FILE"
    echo "| Card | Status | Size | Notes |" >> "$REPORT_FILE"
    echo "|------|--------|------|-------|" >> "$REPORT_FILE"

    local pass=0 warn=0 fail=0

    for card_path in "${cards_to_test[@]}"; do
        local card_name
        card_name=$(basename "$card_path")

        # Navigate via deep link
        xcrun simctl openurl "$SIMULATOR" "adaptivecards://card/$card_path" 2>/dev/null
        sleep 3

        # Screenshot
        local screenshot="$REPORT_DIR/screenshots/${card_name}.png"
        xcrun simctl io "$SIMULATOR" screenshot "$screenshot" 2>/dev/null

        local size
        size=$(stat -f%z "$screenshot" 2>/dev/null || echo "0")

        # Analyze
        local status notes
        if [ "$size" -lt 50000 ]; then
            status="FAIL"
            notes="Blank or error (${size}B)"
            fail=$((fail + 1))
            echo "  ❌ $card_name — blank/error (${size}B)"
        elif [ "$size" -lt 100000 ]; then
            status="WARN"
            notes="Low content (${size}B)"
            warn=$((warn + 1))
            echo "  ⚠️  $card_name — low content (${size}B)"
        else
            status="PASS"
            notes="${size}B"
            pass=$((pass + 1))
            echo "  ✅ $card_name (${size}B)"
        fi

        echo "| $card_name | $status | ${size}B | $notes |" >> "$REPORT_FILE"

        # Return to gallery
        xcrun simctl openurl "$SIMULATOR" "adaptivecards://gallery" 2>/dev/null
        sleep 1
    done

    echo "" >> "$REPORT_FILE"
    echo "**Summary:** ${#cards_to_test[@]} cards | $pass pass | $warn warn | $fail fail" >> "$REPORT_FILE"
    echo ""
    echo "  Summary: ${#cards_to_test[@]} tested | $pass pass | $warn warn | $fail fail"
}

# =============================================================================
# Phase 3: Summary Report
# =============================================================================
phase3_report() {
    echo ""
    echo "━━━ Phase 3: Report ━━━"
    echo "" >> "$REPORT_FILE"
    echo "## Artifacts" >> "$REPORT_FILE"
    echo "- Screenshots: \`$REPORT_DIR/screenshots/\`" >> "$REPORT_FILE"
    echo "- Report: \`$REPORT_FILE\`" >> "$REPORT_FILE"

    echo ""
    echo "  Report: $REPORT_FILE"
    echo "  Screenshots: $REPORT_DIR/screenshots/"
    echo ""

    # Print the report to stdout
    cat "$REPORT_FILE"
}

# =============================================================================
# Main
# =============================================================================
echo "╔══════════════════════════════════════╗"
echo "║  Self-Healing iOS Card Test Loop     ║"
echo "╚══════════════════════════════════════╝"

case "$MODE" in
    full)
        phase1_parse
        phase2_visual
        phase3_report
        ;;
    parse)
        phase1_parse
        phase3_report
        ;;
    visual)
        phase2_visual
        phase3_report
        ;;
esac
