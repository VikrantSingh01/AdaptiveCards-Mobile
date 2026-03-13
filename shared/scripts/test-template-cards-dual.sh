#!/bin/bash
# test-template-cards-dual.sh — Dual-platform template card test suite
# Tests all templated cards on both iOS simulator and Android emulator simultaneously.
#
# Usage: bash shared/scripts/test-template-cards-dual.sh
# Exit code: 0 if all pass, 1 if any failures.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SIMULATOR="iPhone 16 Pro"
IOS_APP_ID="com.microsoft.adaptivecards.sampleapp"
ANDROID_APP_ID="com.microsoft.adaptivecards.sample"
ANDROID_ACTIVITY=".MainActivity"
ADB="${ANDROID_HOME}/platform-tools/adb"
OUTPUT_DIR="/tmp/template-test-dual-$(date +%Y%m%d-%H%M%S)"
IOS_DIR="$OUTPUT_DIR/ios"
ANDROID_DIR="$OUTPUT_DIR/android"
IOS_FAILS=0
IOS_PASSES=0
ANDROID_FAILS=0
ANDROID_PASSES=0

mkdir -p "$IOS_DIR" "$ANDROID_DIR"

# Color helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_pass() { echo -e "  ${GREEN}✓${NC} $1"; }
log_fail() { echo -e "  ${RED}✗${NC} $1"; }
log_info() { echo -e "${CYAN}→${NC} $1"; }
log_header() { echo -e "\n${BOLD}$1${NC}"; }

# ─────────────────────────────────────────────
# Card definitions: deeplink_path|display_name|features
# ─────────────────────────────────────────────
CARDS=(
    # Real-world templated cards
    "templates/ExpenseReport.template|Expense Report|select,sum,min,max,formatTicks,formatDateTime,formatNumber,if,markdown-factset"
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
    # Template function test cards
    "templates/Template.Functions.Number|Number Functions|select,sum,min,max"
    "templates/Template.Functions.String|String Functions|toLower,toUpper,substring"
    "templates/Template.Functions.LogicalComparison|Logic Functions|if,exists,\$when"
    "templates/Template.Functions.DateFunctions|Date Functions|formatDateTime"
    "templates/Template.Functions.DataManipulation|Data Manipulation|json,\$data-object"
    "templates/Template.DataBinding|Data Binding|\$data"
    "templates/Template.DataBinding.Inline|Inline Binding|\$data"
    "templates/Template.ConditionalLayout|Conditional Layout|\$data,\$when"
    "templates/Template.Keywords|Keywords|\$data"
    "templates/Template.RepeatingItems|Repeating Items|\$data"
    # Non-template data-bound cards
    "templating-basic|Basic Templating|basic-binding"
    "templating-conditional|Conditional Templating|\$when"
    "templating-expressions|Expression Templating|functions"
    "templating-iteration|Iteration Templating|\$data,\$index"
    "templating-nested|Nested Templating|\$data,\$root"
)

# ─────────────────────────────────────────────
# Check prerequisites
# ─────────────────────────────────────────────
log_header "Checking prerequisites..."

IOS_AVAILABLE=false
ANDROID_AVAILABLE=false

if xcrun simctl list devices booted 2>/dev/null | grep -q "$SIMULATOR"; then
    IOS_AVAILABLE=true
    log_pass "iOS Simulator '$SIMULATOR' is booted"
else
    log_fail "iOS Simulator '$SIMULATOR' not booted"
fi

if "$ADB" devices 2>/dev/null | grep -q "device$"; then
    ANDROID_AVAILABLE=true
    log_pass "Android emulator connected"
else
    log_fail "No Android emulator connected"
fi

if ! $IOS_AVAILABLE && ! $ANDROID_AVAILABLE; then
    echo -e "${RED}No devices available. Start a simulator or emulator first.${NC}"
    exit 1
fi

# ─────────────────────────────────────────────
# Build both platforms in parallel
# ─────────────────────────────────────────────
log_header "Building..."
cd "$PROJECT_ROOT"

if $IOS_AVAILABLE; then
    log_info "Building iOS sample app..."
    IOS_BUILD_LOG="$OUTPUT_DIR/ios-build.log"
    (xcodebuild -project ios/SampleApp.xcodeproj -scheme ACVisualizer \
        -sdk iphonesimulator -destination "platform=iOS Simulator,name=$SIMULATOR" \
        build CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
        > "$IOS_BUILD_LOG" 2>&1 && echo "IOS_BUILD_OK" >> "$IOS_BUILD_LOG") &
    IOS_BUILD_PID=$!
fi

if $ANDROID_AVAILABLE; then
    log_info "Building Android sample app..."
    ANDROID_BUILD_LOG="$OUTPUT_DIR/android-build.log"
    (cd android && ./gradlew :sample-app:installDebug \
        > "$ANDROID_BUILD_LOG" 2>&1 && echo "ANDROID_BUILD_OK" >> "$ANDROID_BUILD_LOG") &
    ANDROID_BUILD_PID=$!
fi

# Wait for builds
if $IOS_AVAILABLE; then
    wait $IOS_BUILD_PID
    if grep -q "IOS_BUILD_OK" "$IOS_BUILD_LOG"; then
        log_pass "iOS build succeeded"
        APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/SampleApp-*/Build/Products/Debug-iphonesimulator -name "ACVisualizer.app" -maxdepth 1 2>/dev/null | head -1)
        xcrun simctl install "$SIMULATOR" "$APP_PATH" 2>/dev/null
        xcrun simctl launch "$SIMULATOR" "$IOS_APP_ID" 2>/dev/null
        sleep 2
    else
        log_fail "iOS build failed"
        IOS_AVAILABLE=false
    fi
fi

if $ANDROID_AVAILABLE; then
    wait $ANDROID_BUILD_PID
    if grep -q "ANDROID_BUILD_OK" "$ANDROID_BUILD_LOG"; then
        log_pass "Android build succeeded"
        "$ADB" shell am start -n "$ANDROID_APP_ID/$ANDROID_ACTIVITY" 2>/dev/null
        sleep 2
    else
        log_fail "Android build failed"
        ANDROID_AVAILABLE=false
    fi
fi

# ─────────────────────────────────────────────
# Test function: take screenshot and validate
# ─────────────────────────────────────────────
test_ios() {
    local deeplink="$1" name="$2" screenshot_name="$3"
    xcrun simctl openurl "$SIMULATOR" "adaptivecards://card/$deeplink" 2>/dev/null
    sleep 2
    local path="$IOS_DIR/${screenshot_name}.png"
    xcrun simctl io "$SIMULATOR" screenshot "$path" 2>/dev/null
    local size
    size=$(stat -f%z "$path" 2>/dev/null || echo "0")
    if [[ "$size" -gt 10000 ]]; then
        return 0
    fi
    return 1
}

test_android() {
    local deeplink="$1" name="$2" screenshot_name="$3"
    "$ADB" shell am start -a android.intent.action.VIEW -d "adaptivecards://card/$deeplink" 2>/dev/null
    sleep 2
    "$ADB" exec-out screencap -p > "$ANDROID_DIR/${screenshot_name}.png" 2>/dev/null
    local size
    size=$(stat -f%z "$ANDROID_DIR/${screenshot_name}.png" 2>/dev/null || echo "0")
    if [[ "$size" -gt 10000 ]]; then
        return 0
    fi
    return 1
}

# ─────────────────────────────────────────────
# Run tests on both platforms
# ─────────────────────────────────────────────
log_header "Testing ${#CARDS[@]} template cards on both platforms..."
echo "═══════════════════════════════════════════════════════════════"
printf "  %-35s  %s  %s\n" "CARD" "iOS" "Android"
echo "───────────────────────────────────────────────────────────────"

for entry in "${CARDS[@]}"; do
    IFS='|' read -r deeplink name features <<< "$entry"
    screenshot_name=$(echo "$deeplink" | tr '/' '_' | tr '.' '_')

    ios_result="—"
    android_result="—"

    if $IOS_AVAILABLE; then
        if test_ios "$deeplink" "$name" "$screenshot_name"; then
            ios_result="${GREEN}✓${NC}"
            ((IOS_PASSES++))
        else
            ios_result="${RED}✗${NC}"
            ((IOS_FAILS++))
        fi
    fi

    if $ANDROID_AVAILABLE; then
        if test_android "$deeplink" "$name" "$screenshot_name"; then
            android_result="${GREEN}✓${NC}"
            ((ANDROID_PASSES++))
        else
            android_result="${RED}✗${NC}"
            ((ANDROID_FAILS++))
        fi
    fi

    printf "  %-35s  %b    %b\n" "$name" "$ios_result" "$android_result"
done

# ─────────────────────────────────────────────
# Run unit tests
# ─────────────────────────────────────────────
log_header "Running unit tests..."

if $IOS_AVAILABLE; then
    cd "$PROJECT_ROOT/ios"
    if swift test --filter ACTemplatingTests 2>&1 | grep -q "passed"; then
        log_pass "iOS ACTemplatingTests passed"
        ((IOS_PASSES++))
    else
        log_fail "iOS ACTemplatingTests failed"
        ((IOS_FAILS++))
    fi
fi

if $ANDROID_AVAILABLE; then
    cd "$PROJECT_ROOT/android"
    if ./gradlew :ac-templating:test 2>&1 | grep -q "BUILD SUCCESSFUL"; then
        log_pass "Android ac-templating tests passed"
        ((ANDROID_PASSES++))
    else
        log_fail "Android ac-templating tests failed"
        ((ANDROID_FAILS++))
    fi
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e " ${BOLD}Dual-Platform Template Test Results${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""
if $IOS_AVAILABLE; then
    echo -e "  iOS:     ${GREEN}${IOS_PASSES} passed${NC}  ${RED}${IOS_FAILS} failed${NC}"
fi
if $ANDROID_AVAILABLE; then
    echo -e "  Android: ${GREEN}${ANDROID_PASSES} passed${NC}  ${RED}${ANDROID_FAILS} failed${NC}"
fi
echo ""
echo "  Screenshots: $OUTPUT_DIR"
echo "═══════════════════════════════════════════════════════════════"

TOTAL_FAILS=$((IOS_FAILS + ANDROID_FAILS))
if [[ $TOTAL_FAILS -gt 0 ]]; then
    echo -e "\n${RED}FAILED${NC} — $TOTAL_FAILS total failure(s)"
    exit 1
else
    echo -e "\n${GREEN}ALL TESTS PASSED${NC}"
    exit 0
fi
