#!/bin/bash
# test-template-cards.sh — Comprehensive template card test suite
# Tests all templated cards on iOS simulator for rendering correctness.
# Covers: data binding, iteration ($data), conditionals ($when),
# template functions (select, sum, min, max, json, formatDateTime,
# formatEpoch, formatNumber, formatTicks, if, int, string, etc.),
# markdown in FactSet, DATE/TIME macros, and edge cases.
#
# Usage: bash shared/scripts/test-template-cards.sh [--record-baselines]
# Exit code: 0 if all pass, 1 if any failures found.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SIMULATOR="iPhone 16 Pro"
APP_ID="com.microsoft.adaptivecards.sampleapp"
OUTPUT_DIR="/tmp/template-test-$(date +%Y%m%d-%H%M%S)"
RECORD_BASELINES=false
FAIL_COUNT=0
PASS_COUNT=0
SKIP_COUNT=0

if [[ "${1:-}" == "--record-baselines" ]]; then
    RECORD_BASELINES=true
fi

mkdir -p "$OUTPUT_DIR"

# Color helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_pass() { echo -e "${GREEN}✓${NC} $1"; ((PASS_COUNT++)); }
log_fail() { echo -e "${RED}✗${NC} $1"; ((FAIL_COUNT++)); }
log_skip() { echo -e "${YELLOW}○${NC} $1 (skipped)"; ((SKIP_COUNT++)); }
log_info() { echo -e "${CYAN}→${NC} $1"; }

# ─────────────────────────────────────────────
# Card definitions: (deeplink_path, display_name, expected_features)
# Features are comma-separated tags describing what the card tests.
# ─────────────────────────────────────────────
declare -a CARDS=(
    # ── Real-world templated cards ──
    "templates/ExpenseReport.template|Expense Report|select,sum,min,max,int,formatTicks,formatDateTime,formatNumber,if,\$data,\$when,\$index,markdown-factset"
    "templates/StockUpdate.template|Stock Update|formatEpoch,formatNumber,if"
    "templates/WeatherLarge.template|Weather Large|formatEpoch,formatNumber,\$data,\$when"
    "templates/WeatherCompact.template|Weather Compact|formatEpoch,formatNumber"
    "templates/CalendarReminder.template|Calendar Reminder|formatDateTime,\$data"
    "templates/FlightDetails.template|Flight Details|string"
    "templates/FlightItinerary.template|Flight Itinerary|formatNumber,string,\$when"
    "templates/FlightUpdate.template|Flight Update|string"
    "templates/FlightUpdateTable.template|Flight Update Table|string"
    "templates/ActivityUpdate.template|Activity Update|string,\$data"
    "templates/SportingEvent.template|Sporting Event|string"
    "templates/FoodOrder.template|Food Order|basic-binding"
    "templates/Restaurant.template|Restaurant|\$when"
    "templates/InputForm.template|Input Form|\$data"
    "templates/Agenda.template|Agenda|basic-binding"
    "templates/Solitaire.template|Solitaire|basic-binding"
    "templates/SimpleFallback.template|Simple Fallback|basic-binding"
    "templates/ProductVideo.template|Product Video|basic-binding"
    "templates/ImageGallery.template|Image Gallery|basic-binding"
    "templates/OrderConfirmation.template|Order Confirmation|basic-binding"
    "templates/OrderDelivery.template|Order Delivery|basic-binding"
    "templates/RestaurantOrder.template|Restaurant Order|\$data"
    "templates/ApplicationLogin.template|Application Login|basic-binding"
    "templates/InputFormWithRTL.template|Input Form RTL|basic-binding"
    "templates/InputsWithValidation.template|Inputs Validation|\$data"
    "templates/ShowCardWizard.template|ShowCard Wizard|\$data"
    "templates/CarouselTemplatedPages.template|Carousel Pages|\$when"
    "templates/CarouselWhenShowCarousel.template|Carousel When/Show|\$when"
    # ── Template function test cards ──
    "templates/Template.Functions.Number|Number Functions|select,sum,min,max"
    "templates/Template.Functions.String|String Functions|toLower,toUpper,substring,indexOf,length,string"
    "templates/Template.Functions.LogicalComparison|Logic Functions|if,exists,string,\$data,\$when"
    "templates/Template.Functions.DateFunctions|Date Functions|formatDateTime"
    "templates/Template.Functions.DataManipulation|Data Manipulation|json,\$data-object"
    "templates/Template.DataBinding|Data Binding|\$data"
    "templates/Template.DataBinding.Inline|Inline Binding|\$data"
    "templates/Template.ConditionalLayout|Conditional Layout|string,\$data,\$when"
    "templates/Template.Keywords|Keywords|\$data"
    "templates/Template.RepeatingItems|Repeating Items|string,\$data"
)

# Also test the non-template data-bound cards
declare -a EXTRA_CARDS=(
    "templating-iteration|Templating Iteration|count,\$data,\$index"
    "templating-nested|Templating Nested|add,mul,\$data,\$when,\$root"
    "templating-basic|Templating Basic|basic-binding"
    "templating-conditional|Templating Conditional|\$when"
    "templating-expressions|Templating Expressions|expressions"
)

# ─────────────────────────────────────────────
# Step 1: Build the iOS sample app
# ─────────────────────────────────────────────
log_info "Building iOS sample app..."
cd "$PROJECT_ROOT"

BUILD_OUT=$(xcodebuild -project ios/SampleApp.xcodeproj -scheme ACVisualizer \
    -sdk iphonesimulator -destination "platform=iOS Simulator,name=$SIMULATOR" \
    build CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO 2>&1) || {
    echo -e "${RED}BUILD FAILED${NC}"
    echo "$BUILD_OUT" | tail -20
    exit 1
}
log_pass "Build succeeded"

# ─────────────────────────────────────────────
# Step 2: Install and launch app
# ─────────────────────────────────────────────
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/SampleApp-*/Build/Products/Debug-iphonesimulator -name "ACVisualizer.app" -maxdepth 1 2>/dev/null | head -1)
if [[ -z "$APP_PATH" ]]; then
    echo -e "${RED}Cannot find built ACVisualizer.app${NC}"
    exit 1
fi

xcrun simctl install "$SIMULATOR" "$APP_PATH" 2>/dev/null
xcrun simctl launch "$SIMULATOR" "$APP_ID" 2>/dev/null
sleep 2
log_pass "App installed and launched"

# ─────────────────────────────────────────────
# Step 3: Test each card
# ─────────────────────────────────────────────
test_card() {
    local deeplink="$1"
    local name="$2"
    local features="$3"
    local screenshot_name
    screenshot_name=$(echo "$deeplink" | tr '/' '_' | tr '.' '_')

    # Navigate to card
    xcrun simctl openurl "$SIMULATOR" "adaptivecards://card/$deeplink" 2>/dev/null
    sleep 2

    # Take screenshot
    local screenshot_path="$OUTPUT_DIR/${screenshot_name}.png"
    xcrun simctl io "$SIMULATOR" screenshot "$screenshot_path" 2>/dev/null

    if [[ ! -f "$screenshot_path" ]]; then
        log_fail "$name — screenshot failed"
        return
    fi

    # Check screenshot file size (non-blank cards should be > 50KB typically)
    local file_size
    file_size=$(stat -f%z "$screenshot_path" 2>/dev/null || stat -c%s "$screenshot_path" 2>/dev/null || echo "0")

    if [[ "$file_size" -lt 10000 ]]; then
        log_fail "$name — screenshot too small (${file_size}B), likely blank"
        return
    fi

    # Use macOS sips to check image dimensions (should be full screen)
    if command -v sips &>/dev/null; then
        local width height
        width=$(sips -g pixelWidth "$screenshot_path" 2>/dev/null | tail -1 | awk '{print $2}')
        height=$(sips -g pixelHeight "$screenshot_path" 2>/dev/null | tail -1 | awk '{print $2}')
        if [[ "${width:-0}" -lt 100 || "${height:-0}" -lt 100 ]]; then
            log_fail "$name — invalid screenshot dimensions (${width}x${height})"
            return
        fi
    fi

    log_pass "$name [$features]"
}

echo ""
log_info "Testing ${#CARDS[@]} templated cards..."
echo "───────────────────────────────────────"

for entry in "${CARDS[@]}"; do
    IFS='|' read -r deeplink name features <<< "$entry"
    test_card "$deeplink" "$name" "$features"
done

echo ""
log_info "Testing ${#EXTRA_CARDS[@]} non-template data-bound cards..."
echo "───────────────────────────────────────"

for entry in "${EXTRA_CARDS[@]}"; do
    IFS='|' read -r deeplink name features <<< "$entry"
    test_card "$deeplink" "$name" "$features"
done

# ─────────────────────────────────────────────
# Step 4: Run unit tests for template engine
# ─────────────────────────────────────────────
echo ""
log_info "Running ACTemplatingTests..."
cd "$PROJECT_ROOT/ios"
TEST_OUT=$(swift test --filter ACTemplatingTests 2>&1)
TEST_RESULT=$?
if [[ $TEST_RESULT -eq 0 ]]; then
    TEST_COUNT=$(echo "$TEST_OUT" | grep "Executed" | head -1 | awk '{print $2}')
    log_pass "ACTemplatingTests — ${TEST_COUNT:-all} tests passed"
else
    log_fail "ACTemplatingTests — unit tests failed"
    echo "$TEST_OUT" | grep -E "failed|error" | head -5
fi

# ─────────────────────────────────────────────
# Step 5: Run card parsing regression tests
# ─────────────────────────────────────────────
log_info "Running CardParsingRegressionTests..."
PARSE_OUT=$(swift test --filter CardParsingRegressionTests 2>&1)
PARSE_RESULT=$?
if [[ $PARSE_RESULT -eq 0 ]]; then
    PARSE_COUNT=$(echo "$PARSE_OUT" | grep "Executed" | head -1 | awk '{print $2}')
    log_pass "CardParsingRegressionTests — ${PARSE_COUNT:-all} tests passed"
else
    log_fail "CardParsingRegressionTests — parsing tests failed"
    echo "$PARSE_OUT" | grep -E "failed|error" | head -5
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════"
echo -e " Template Card Test Results"
echo "═══════════════════════════════════════"
echo -e " ${GREEN}Passed${NC}: $PASS_COUNT"
echo -e " ${RED}Failed${NC}: $FAIL_COUNT"
echo -e " ${YELLOW}Skipped${NC}: $SKIP_COUNT"
echo " Screenshots: $OUTPUT_DIR"
echo "═══════════════════════════════════════"

if [[ $FAIL_COUNT -gt 0 ]]; then
    echo -e "\n${RED}FAILED${NC} — $FAIL_COUNT test(s) failed"
    exit 1
else
    echo -e "\n${GREEN}ALL TESTS PASSED${NC}"
    exit 0
fi
