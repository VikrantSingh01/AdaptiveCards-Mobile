#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.

# =============================================================================
# Self-Healing iOS Card Test Loop (v2 — Enhanced)
# =============================================================================
#
# Automated detect → diagnose → recover → fix cycle for Adaptive Card rendering
# on iOS Simulator. Multi-signal diagnosis with crash detection, hang detection,
# memory profiling, auto-retry with app recovery, and structured fix suggestions.
#
# Usage:
#   bash shared/scripts/self-heal-ios.sh                    # Full run
#   bash shared/scripts/self-heal-ios.sh --parse-only       # Parse tests only
#   bash shared/scripts/self-heal-ios.sh --visual-only      # Visual tests only
#   bash shared/scripts/self-heal-ios.sh --card cafe-menu   # Single card
#   bash shared/scripts/self-heal-ios.sh --retry 3          # Custom retry count
#   bash shared/scripts/self-heal-ios.sh --category element # Test element-samples
#
# Phases:
#   1. Parse Regression  — swift test catches Codable decoder failures
#   2. Visual Smoke      — deep-link, screenshot, analyze with multi-signal diagnosis
#   3. Recovery & Retry  — auto-restart app, retry failed cards with escalating recovery
#   4. Crash Analysis     — system log mining for crashes, hangs, OOM
#   5. Fix Suggestions    — structured remediation based on error patterns
#   6. Report             — rich markdown report with all artifacts
#
# Prerequisites:
#   - iOS Simulator "iPhone 16 Pro" booted
#   - Xcode and swift toolchain available
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SIMULATOR="iPhone 16 Pro"
APP_ID="com.microsoft.adaptivecards.sampleapp"
REPORT_DIR="/tmp/self-heal-ios-$(date +%Y%m%d-%H%M%S)"
REPORT_FILE="$REPORT_DIR/report.md"
LOGS_DIR="$REPORT_DIR/logs"
MODE="full"
SINGLE_CARD=""
MAX_RETRIES=2
CATEGORY="teams-official"
RENDER_WAIT=2  # seconds to wait for card to render
BOOT_WAIT=2    # seconds to wait after app launch

# =============================================================================
# Resolve Simulator UDID
# =============================================================================
resolve_simulator_udid() {
    local udid
    udid=$(xcrun simctl list devices available | grep "$SIMULATOR" | grep -oE '[A-F0-9-]{36}' | head -1)
    if [ -z "$udid" ]; then
        echo "  ❌ Simulator '$SIMULATOR' not found or not available."
        echo "     Run: xcrun simctl list devices available"
        exit 1
    fi
    echo "$udid"
}

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --parse-only) MODE="parse"; shift ;;
        --visual-only) MODE="visual"; shift ;;
        --card) SINGLE_CARD="$2"; shift 2 ;;
        --retry) MAX_RETRIES="$2"; shift 2 ;;
        --category) CATEGORY="$2"; shift 2 ;;
        --simulator) SIMULATOR="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

mkdir -p "$REPORT_DIR/screenshots" "$LOGS_DIR"

SIM_UDID=$(resolve_simulator_udid)

# =============================================================================
# Card Catalogs (extensible by category)
# =============================================================================
TEAMS_OFFICIAL_CARDS=(
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

get_element_cards() {
    local cards=()
    if [ -d "$REPO_ROOT/shared/test-cards/element-samples" ]; then
        for f in "$REPO_ROOT/shared/test-cards/element-samples"/*.json; do
            [ -f "$f" ] || continue
            local name
            name=$(basename "$f" .json)
            cards+=("element-samples/$name")
        done
    fi
    echo "${cards[@]}"
}

get_official_cards() {
    local cards=()
    if [ -d "$REPO_ROOT/shared/test-cards/official-samples" ]; then
        for f in "$REPO_ROOT/shared/test-cards/official-samples"/*.json; do
            [ -f "$f" ] || continue
            local name
            name=$(basename "$f" .json)
            cards+=("official-samples/$name")
        done
    fi
    echo "${cards[@]}"
}

# =============================================================================
# Utility Functions
# =============================================================================

# Check if the simulator is booted
check_simulator() {
    local state
    state=$(xcrun simctl list devices | grep "$SIM_UDID" | grep -oE '\(Booted\)' || true)
    if [ -z "$state" ]; then
        echo "  ❌ Simulator '$SIMULATOR' ($SIM_UDID) is not booted."
        echo "     Boot it: xcrun simctl boot '$SIM_UDID'"
        exit 1
    fi
    echo "  ✅ Simulator booted: $SIMULATOR ($SIM_UDID)"
}

# Check if app is running on the simulator
is_app_running() {
    # Use simctl to check if the app's process exists
    local pid
    pid=$(xcrun simctl spawn "$SIM_UDID" launchctl list 2>/dev/null | grep "$APP_ID" | awk '{print $1}' || true)
    if [ -n "$pid" ] && [ "$pid" != "-" ]; then
        return 0
    fi
    # Fallback: check if we can get the app's PID via the process list
    xcrun simctl spawn "$SIM_UDID" ps aux 2>/dev/null | grep -q "ACVisualizer" 2>/dev/null
}

# Force restart the app (recovery action)
restart_app() {
    echo "  ↻ Restarting app..."
    xcrun simctl terminate "$SIM_UDID" "$APP_ID" 2>/dev/null || true
    sleep 1
    xcrun simctl launch "$SIM_UDID" "$APP_ID" 2>/dev/null
    sleep "$BOOT_WAIT"
}

# Known simulator system daemon noise — these are NOT app crashes
# These fire constantly on every simctl log capture and must be excluded
SYSTEM_NOISE_FILTER="pairedsyncd|chronod|locationd|promotedcontentd|fileproviderd|nsurlsessiond|symptomsd|runningboardd|dasd|healthd|HealthPluginHost|contextstored|coreduetd|duetexpertd|CoreSimulator|SpringBoard.*backlight|mDNSResponder|UserEventAgent|wifid|WiFiPolicy|BlueTool"

# Capture simulator system log around a card test
# Uses `log show` with a time window to get app-specific logs
# NOTE: `log show` can hang — we bound each call to prevent blocking
LOG_CAPTURE_TIMEOUT=5  # seconds max for each log capture call

capture_logs() {
    local card_name="$1"
    local start_time="$2"
    local output_file="$LOGS_DIR/${card_name}.txt"
    > "$output_file"  # initialize empty

    # Primary: capture ONLY logs from our app process (strict filter)
    xcrun simctl spawn "$SIM_UDID" log show \
        --start "$start_time" \
        --predicate "processImagePath CONTAINS 'ACVisualizer'" \
        --style compact \
        --last 30s \
        > "$output_file" 2>/dev/null &
    local log_pid=$!
    ( sleep "$LOG_CAPTURE_TIMEOUT" && kill "$log_pid" 2>/dev/null ) &
    local wdog=$!
    wait "$log_pid" 2>/dev/null || true
    kill "$wdog" 2>/dev/null; wait "$wdog" 2>/dev/null || true

    # Secondary: also capture CrashReporter entries specifically about our app
    xcrun simctl spawn "$SIM_UDID" log show \
        --start "$start_time" \
        --predicate "subsystem == 'com.apple.CrashReporter' AND composedMessage CONTAINS 'AdaptiveCards'" \
        --style compact \
        --last 30s \
        >> "$output_file" 2>/dev/null &
    log_pid=$!
    ( sleep "$LOG_CAPTURE_TIMEOUT" && kill "$log_pid" 2>/dev/null ) &
    wdog=$!
    wait "$log_pid" 2>/dev/null || true
    kill "$wdog" 2>/dev/null; wait "$wdog" 2>/dev/null || true

    # Strip out known system daemon noise that leaks through
    if [ -s "$output_file" ]; then
        grep -ivE "$SYSTEM_NOISE_FILTER" "$output_file" > "${output_file}.filtered" 2>/dev/null || true
        mv "${output_file}.filtered" "$output_file" 2>/dev/null || true
    fi

    echo "$output_file"
}

# Get the current timestamp in log-compatible format
log_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Analyze logs for errors — returns structured diagnosis
# IMPORTANT: By this point logs have already been filtered to our app process
# and system daemon noise has been stripped. We only diagnose genuine app issues.
diagnose_logs() {
    local logfile="$1"
    local diagnosis=""

    if [ ! -f "$logfile" ] || [ ! -s "$logfile" ]; then
        echo "NO_LOGS"
        return
    fi

    # Double-check: count lines that are actually from our app (not system noise leaks)
    local app_lines
    app_lines=$(grep -ciE "AdaptiveCard" "$logfile" 2>/dev/null | head -1 || echo "0")
    app_lines="${app_lines:-0}"

    # If no app-specific lines at all, this is just system noise that leaked through
    if [ "$app_lines" -eq 0 ]; then
        # Check if there are ANY non-empty lines (could still be relevant crash reporter entries)
        local total_lines
        total_lines=$(wc -l < "$logfile" 2>/dev/null | tr -d ' ')
        if [ "$total_lines" -lt 3 ]; then
            echo "CLEAN"
            return
        fi
    fi

    # Check for app crash (EXC_ signals, SIGABRT, fatal errors from OUR app)
    if grep -iE "AdaptiveCard" "$logfile" | grep -qiE "EXC_BAD_ACCESS|EXC_CRASH|EXC_BREAKPOINT|SIGABRT|SIGBUS|SIGSEGV|Fatal error|fatalError" 2>/dev/null; then
        local crash_detail
        crash_detail=$(grep -iE "AdaptiveCard" "$logfile" | grep -iE "EXC_BAD_ACCESS|EXC_CRASH|EXC_BREAKPOINT|SIGABRT|SIGBUS|SIGSEGV|Fatal error|fatalError" | head -2)
        diagnosis="CRASH: $crash_detail"
    fi

    # Check for Jetsam (OOM) targeting our app specifically
    if grep -qiE "Jetsam.*AdaptiveCard|memorystatus.*AdaptiveCard|killed.*AdaptiveCard.*memory" "$logfile" 2>/dev/null; then
        diagnosis="${diagnosis:+$diagnosis | }OOM_JETSAM"
    fi

    # Check for watchdog / hang on our app specifically
    # NOTE: Exclude normal CFNetwork "timeouts(60.0, ...)" and RunningBoardServices lifecycle noise
    if grep -iE "AdaptiveCard" "$logfile" | grep -ivE "CFNetwork|timeouts\(|RunningBoardServices|didChangeInheritances" | grep -qiE "watchdog|hang.*detected|scene.*not respond|UIApplication.*timeout|BKProcess.*timeout" 2>/dev/null; then
        diagnosis="${diagnosis:+$diagnosis | }HANG_WATCHDOG"
    fi

    # Check for Codable / JSON decoding errors (these are always app-specific)
    if grep -qiE "DecodingError|typeMismatch|keyNotFound|valueNotFound|dataCorrupted|CodingKey|JSONDecoder|NSCocoaErrorDomain.*3840" "$logfile" 2>/dev/null; then
        local parse_err
        parse_err=$(grep -iE "DecodingError|typeMismatch|keyNotFound|valueNotFound|dataCorrupted|CodingKey" "$logfile" | head -1)
        diagnosis="${diagnosis:+$diagnosis | }PARSE_ERROR: $parse_err"
    fi

    # Check for Swift runtime errors from our app
    if grep -iE "AdaptiveCard" "$logfile" | grep -qiE "unexpectedly found nil|force unwrap|index out of range" 2>/dev/null; then
        local runtime_err
        runtime_err=$(grep -iE "AdaptiveCard" "$logfile" | grep -iE "unexpectedly found nil|force unwrap|index out of range" | head -1)
        diagnosis="${diagnosis:+$diagnosis | }RUNTIME_ERROR: $runtime_err"
    fi

    # Check for SwiftUI rendering errors from our app
    if grep -iE "AdaptiveCard" "$logfile" | grep -qiE "SwiftUI.*error|View.*body.*error|Layout.*overflow|attributeGraph|AG:.*precondition" 2>/dev/null; then
        diagnosis="${diagnosis:+$diagnosis | }SWIFTUI_ERROR"
    fi

    # Check for image loading failures (app-specific context)
    if grep -qiE "imageDownload.*fail|CGImage.*NULL|ImageIO.*error|URLSession.*fail.*image" "$logfile" 2>/dev/null; then
        if grep -iE "imageDownload.*fail|CGImage.*NULL|ImageIO.*error|URLSession.*fail.*image" "$logfile" | grep -qiE "AdaptiveCard" 2>/dev/null; then
            diagnosis="${diagnosis:+$diagnosis | }IMAGE_LOAD_FAILURE"
        fi
    fi

    # Check for constraint / layout issues from our app
    if grep -qiE "Unable to simultaneously satisfy|NSLayoutConstraint|Ambiguous.*layout|constraint.*conflict" "$logfile" 2>/dev/null; then
        if grep -iE "Unable to simultaneously satisfy|NSLayoutConstraint|Ambiguous.*layout" "$logfile" | grep -qiE "AdaptiveCard" 2>/dev/null; then
            diagnosis="${diagnosis:+$diagnosis | }LAYOUT_CONSTRAINT"
        fi
    fi

    if [ -z "$diagnosis" ]; then
        echo "CLEAN"
    else
        echo "$diagnosis"
    fi
}

# Get memory footprint for the app (in KB)
get_memory_info() {
    # Try to get memory via simctl spawn and footprint utility (quick, non-blocking)
    local tmpfile="/tmp/ac_meminfo_$$.txt"
    xcrun simctl spawn "$SIM_UDID" footprint -a > "$tmpfile" 2>/dev/null &
    local pid=$!
    ( sleep 5 && kill "$pid" 2>/dev/null ) &
    local wdog=$!
    wait "$pid" 2>/dev/null || true
    kill "$wdog" 2>/dev/null; wait "$wdog" 2>/dev/null || true

    local mem_bytes=""
    if [ -s "$tmpfile" ]; then
        mem_bytes=$(grep -i "$APP_ID" "$tmpfile" | awk '{print $NF}' | head -1 || true)
    fi
    rm -f "$tmpfile"

    if [ -n "$mem_bytes" ] && [ "$mem_bytes" != "0" ]; then
        echo "$mem_bytes"
        return
    fi

    echo "0"
}

# Check for crash reports generated by the system
check_crash_reports() {
    local card_name="$1"
    local since_time="$2"
    local crash_dir="$HOME/Library/Logs/DiagnosticReports"
    local sim_crash_dir="$HOME/Library/Developer/CoreSimulator/Devices/$SIM_UDID/data/Library/Logs/CrashReporter"

    local found_crash=false

    for dir in "$crash_dir" "$sim_crash_dir"; do
        if [ -d "$dir" ]; then
            # Look for recent crash reports matching our app
            local crashes
            crashes=$(find "$dir" -name "*AdaptiveCards*" -newer "$REPORT_DIR" -type f 2>/dev/null || true)
            if [ -n "$crashes" ]; then
                found_crash=true
                echo "$crashes" | head -1 | while IFS= read -r crash_file; do
                    cp "$crash_file" "$LOGS_DIR/${card_name}-crash-report.ips" 2>/dev/null || true
                done
            fi
        fi
    done

    $found_crash && echo "CRASH_REPORT_FOUND" || echo "NO_CRASH_REPORT"
}

# Suggest fixes based on diagnosis
suggest_fix() {
    local diagnosis="$1"
    local card_name="$2"

    case "$diagnosis" in
        *CRASH*)
            echo "**Fix:** Check crash log in \`$LOGS_DIR/${card_name}.txt\`. Likely unhandled exception in card parser or SwiftUI view body. Look for force-unwraps or unimplemented element types."
            ;;
        *HANG_WATCHDOG*)
            echo "**Fix:** Card rendering is blocking the main thread. Move heavy parsing/template evaluation off MainActor. Check \`ACTemplating\` for synchronous compute in \`body\`."
            ;;
        *OOM_JETSAM*)
            echo "**Fix:** App terminated by Jetsam (iOS OOM killer). Card may reference large images or deep nesting. Add image size limits in \`ACRendering\` and cap recursive container depth."
            ;;
        *PARSE_ERROR*)
            echo "**Fix:** Card JSON has elements/properties not handled by \`Codable\` models. Check \`ACCore/Models/\` for missing \`CodingKeys\` or unhandled element types in \`CardElement\`."
            ;;
        *RUNTIME_ERROR*)
            echo "**Fix:** Force-unwrap or index-out-of-range in rendering code. Check optional chaining in \`ACRendering/Views/\`. Grep for \`!\` (force unwrap) in the view layer."
            ;;
        *SWIFTUI_ERROR*)
            echo "**Fix:** SwiftUI view body error — likely invalid layout, missing required data, or infinite loop in \`some View\` body. Check \`ACRendering/Views/\` composites."
            ;;
        *IMAGE_LOAD_FAILURE*)
            echo "**Fix:** Image URL is broken or unreachable. Add a placeholder/fallback image in \`ImageElementView\`. Check URL scheme validation for image sources."
            ;;
        *LAYOUT_CONSTRAINT*)
            echo "**Fix:** Auto Layout constraint conflict (UIKit interop?). Check any \`UIViewRepresentable\` wrappers in the rendering layer."
            ;;
        *)
            echo ""
            ;;
    esac
}

# =============================================================================
# Report Initialization
# =============================================================================
init_report() {
    local ios_version
    ios_version=$(xcrun simctl list devices | grep "$SIM_UDID" | grep -oE 'iOS [0-9.]+' | head -1 || echo "unknown")
    local xcode_version
    xcode_version=$(xcodebuild -version 2>/dev/null | head -1 || echo "unknown")

    cat > "$REPORT_FILE" << EOF
# Self-Healing iOS Card Test Report (v2)

**Date:** $(date)
**Mode:** $MODE
**Category:** $CATEGORY
**Max Retries:** $MAX_RETRIES
**Simulator:** $SIMULATOR ($SIM_UDID)
**iOS Version:** $ios_version
**Xcode:** $xcode_version

EOF
}

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

        # Save full test output for debugging
        echo "$test_output" > "$REPORT_DIR/phase1-test-output.txt"
        echo "" >> "$REPORT_FILE"
        echo "> Full output: \`$REPORT_DIR/phase1-test-output.txt\`" >> "$REPORT_FILE"
    fi
    echo "" >> "$REPORT_FILE"

    cd "$REPO_ROOT"
}

# =============================================================================
# Phase 2: Visual Smoke Tests (with multi-signal diagnosis)
# =============================================================================
phase2_visual() {
    echo ""
    echo "━━━ Phase 2: Visual Smoke Tests ━━━"
    echo "## Phase 2: Visual Rendering" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    check_simulator

    # Build and install
    echo "  Building sample app..."
    cd "$REPO_ROOT"
    local build_output
    build_output=$(xcodebuild -project "$REPO_ROOT/ios/SampleApp.xcodeproj" \
        -scheme ACVisualizer \
        -sdk iphonesimulator \
        -destination "platform=iOS Simulator,name=$SIMULATOR" \
        CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
        build 2>&1)
    local build_result
    build_result=$(echo "$build_output" | tail -1)

    if [[ "$build_result" != *"BUILD SUCCEEDED"* ]]; then
        echo "  ❌ Build failed"
        echo "**Build:** FAILED" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        echo "$build_output" | tail -40 >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        echo "$build_output" > "$REPORT_DIR/build-output.txt"
        return 1
    fi
    echo "  ✅ Build succeeded"

    # Install and launch
    local app_path
    app_path=$(find ~/Library/Developer/Xcode/DerivedData/SampleApp-*/Build/Products/Debug-iphonesimulator -name "ACVisualizer.app" -maxdepth 1 2>/dev/null | head -1)
    if [ -z "$app_path" ]; then
        echo "  ❌ Could not find built app"
        return 1
    fi
    xcrun simctl install "$SIM_UDID" "$app_path" 2>/dev/null
    restart_app

    # Select card catalog
    local cards_to_test=()
    if [ -n "$SINGLE_CARD" ]; then
        cards_to_test=("$SINGLE_CARD")
    else
        case "$CATEGORY" in
            teams-official) cards_to_test=("${TEAMS_OFFICIAL_CARDS[@]}") ;;
            element) IFS=' ' read -ra cards_to_test <<< "$(get_element_cards)" ;;
            official) IFS=' ' read -ra cards_to_test <<< "$(get_official_cards)" ;;
            all)
                cards_to_test=("${TEAMS_OFFICIAL_CARDS[@]}")
                IFS=' ' read -ra element_cards <<< "$(get_element_cards)"
                cards_to_test+=("${element_cards[@]}")
                IFS=' ' read -ra official_cards <<< "$(get_official_cards)"
                cards_to_test+=("${official_cards[@]}")
                ;;
            *) cards_to_test=("${TEAMS_OFFICIAL_CARDS[@]}") ;;
        esac
    fi

    echo "  Testing ${#cards_to_test[@]} cards (category: $CATEGORY)..."
    echo "" >> "$REPORT_FILE"
    echo "| # | Card | Status | Size | Memory | Diagnosis | Notes |" >> "$REPORT_FILE"
    echo "|---|------|--------|------|--------|-----------|-------|" >> "$REPORT_FILE"

    local pass=0 warn=0 fail=0 recovered=0 idx=0
    local -a failed_cards=()
    local -a card_diagnoses=()

    for card_path in "${cards_to_test[@]}"; do
        idx=$((idx + 1))
        local card_name
        card_name=$(basename "$card_path")

        # Record timestamp before navigation for log capture window
        local test_start
        test_start=$(log_timestamp)

        # Check app is alive before navigating
        if ! is_app_running; then
            echo "  ⚠️  App not running — recovering..."
            restart_app
        fi

        # Navigate via deep link
        xcrun simctl openurl "$SIM_UDID" "adaptivecards://card/$card_path" 2>/dev/null
        sleep "$RENDER_WAIT"

        # Check if app survived the navigation
        local app_alive=true
        if ! is_app_running; then
            app_alive=false
        fi

        # Capture screenshot (resized to 540px wide for smaller files)
        local screenshot="$REPORT_DIR/screenshots/${card_name}.png"
        if $app_alive; then
            xcrun simctl io "$SIM_UDID" screenshot "$screenshot" 2>/dev/null || true
            [ -f "$screenshot" ] && sips --resampleWidth 540 "$screenshot" &>/dev/null || true
        fi

        # Capture logs for this card's time window
        local logfile
        logfile=$(capture_logs "$card_name" "$test_start")

        # Check for crash reports
        local crash_report_status
        crash_report_status=$(check_crash_reports "$card_name" "$test_start")

        # Diagnose via logs
        local diagnosis
        diagnosis=$(diagnose_logs "$logfile")

        # If we found a crash report but logs don't show crash, add it
        if [[ "$crash_report_status" == "CRASH_REPORT_FOUND" ]] && [[ "$diagnosis" != *"CRASH"* ]]; then
            diagnosis="${diagnosis:+$diagnosis | }CRASH_REPORT_FOUND"
        fi

        # Get memory usage
        local mem_info="0"
        if $app_alive; then
            mem_info=$(get_memory_info)
        fi

        # Determine screenshot size
        local size="0"
        if [ -f "$screenshot" ]; then
            size=$(stat -f%z "$screenshot" 2>/dev/null || echo "0")
        fi

        # Multi-signal analysis
        local status notes
        if ! $app_alive; then
            status="CRASH"
            notes="App crashed on navigation"
            fail=$((fail + 1))
            failed_cards+=("$card_path")
            card_diagnoses+=("$diagnosis")
            echo "  💥 [$idx/${#cards_to_test[@]}] $card_name — APP CRASHED"
        elif [[ "$diagnosis" == *"CRASH"* ]] || [[ "$diagnosis" == *"HANG"* ]]; then
            status="FAIL"
            notes="$diagnosis"
            fail=$((fail + 1))
            failed_cards+=("$card_path")
            card_diagnoses+=("$diagnosis")
            echo "  ❌ [$idx/${#cards_to_test[@]}] $card_name — $diagnosis"
        elif [ "$size" -lt 10000 ]; then
            status="FAIL"
            notes="Blank/error (${size}B)"
            if [[ "$diagnosis" != "CLEAN" && "$diagnosis" != "NO_LOGS" ]]; then
                notes="$notes | $diagnosis"
            fi
            fail=$((fail + 1))
            failed_cards+=("$card_path")
            card_diagnoses+=("$diagnosis")
            echo "  ❌ [$idx/${#cards_to_test[@]}] $card_name — blank/error (${size}B) [$diagnosis]"
        elif [ "$size" -lt 25000 ]; then
            status="WARN"
            notes="Low content (${size}B)"
            if [[ "$diagnosis" != "CLEAN" && "$diagnosis" != "NO_LOGS" ]]; then
                notes="$notes | $diagnosis"
            fi
            warn=$((warn + 1))
            echo "  ⚠️  [$idx/${#cards_to_test[@]}] $card_name — low content (${size}B)"
        elif [[ "$mem_info" == "HIGH_PRESSURE" ]]; then
            status="WARN"
            notes="${size}B | Memory pressure detected"
            warn=$((warn + 1))
            echo "  ⚠️  [$idx/${#cards_to_test[@]}] $card_name — (${size}B) MEMORY PRESSURE"
        else
            status="PASS"
            notes="${size}B"
            pass=$((pass + 1))
            echo "  ✅ [$idx/${#cards_to_test[@]}] $card_name (${size}B, mem:${mem_info})"
        fi

        local mem_display="${mem_info}"
        if [[ "$mem_info" == "HIGH_PRESSURE" ]]; then
            mem_display="⚠️ HIGH"
        fi

        echo "| $idx | $card_name | $status | ${size}B | $mem_display | ${diagnosis:0:40} | $notes |" >> "$REPORT_FILE"

        # Return to gallery (if app is alive)
        if $app_alive; then
            xcrun simctl openurl "$SIM_UDID" "adaptivecards://gallery" 2>/dev/null
            sleep 1
        fi
    done

    echo "" >> "$REPORT_FILE"
    echo "**First Pass Summary:** ${#cards_to_test[@]} cards | $pass pass | $warn warn | $fail fail" >> "$REPORT_FILE"
    echo ""
    echo "  First pass: ${#cards_to_test[@]} tested | $pass pass | $warn warn | $fail fail"

    # =========================================================================
    # Phase 3: Recovery & Retry
    # =========================================================================
    if [ ${#failed_cards[@]} -gt 0 ] && [ "$MAX_RETRIES" -gt 0 ]; then
        echo ""
        echo "━━━ Phase 3: Recovery & Retry (${#failed_cards[@]} failed cards) ━━━"
        echo "" >> "$REPORT_FILE"
        echo "## Phase 3: Recovery & Retry" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "| Card | Status | Retry | Size | Diagnosis |" >> "$REPORT_FILE"
        echo "|------|--------|-------|------|-----------|" >> "$REPORT_FILE"

        for retry in $(seq 1 "$MAX_RETRIES"); do
            local still_failing=()
            local still_diagnoses=()

            echo "  Retry $retry/$MAX_RETRIES — restarting app..."

            # Recovery actions escalate with each retry
            if [ "$retry" -eq 1 ]; then
                # Retry 1: Simple app restart
                restart_app
            else
                # Retry 2+: Terminate, wait longer, cold start
                xcrun simctl terminate "$SIM_UDID" "$APP_ID" 2>/dev/null || true
                sleep 2
                xcrun simctl launch "$SIM_UDID" "$APP_ID" 2>/dev/null
                sleep 3
            fi

            for i in "${!failed_cards[@]}"; do
                local card_path="${failed_cards[$i]}"
                local card_name
                card_name=$(basename "$card_path")

                local test_start
                test_start=$(log_timestamp)

                if ! is_app_running; then
                    restart_app
                fi

                xcrun simctl openurl "$SIM_UDID" "adaptivecards://card/$card_path" 2>/dev/null
                sleep "$RENDER_WAIT"

                local app_alive=true
                if ! is_app_running; then
                    app_alive=false
                fi

                local screenshot="$REPORT_DIR/screenshots/${card_name}-retry${retry}.png"
                if $app_alive; then
                    xcrun simctl io "$SIM_UDID" screenshot "$screenshot" 2>/dev/null || true
                    [ -f "$screenshot" ] && sips --resampleWidth 540 "$screenshot" &>/dev/null || true
                fi

                local logfile
                logfile=$(capture_logs "${card_name}-retry${retry}" "$test_start")
                local diagnosis
                diagnosis=$(diagnose_logs "$logfile")

                local size="0"
                if [ -f "$screenshot" ]; then
                    size=$(stat -f%z "$screenshot" 2>/dev/null || echo "0")
                fi

                if $app_alive && [ "$size" -ge 10000 ] && [[ "$diagnosis" != *"CRASH"* ]]; then
                    recovered=$((recovered + 1))
                    fail=$((fail - 1))
                    pass=$((pass + 1))
                    echo "  ✅ $card_name — RECOVERED on retry $retry (${size}B)"
                    echo "| $card_name | RECOVERED | $retry | ${size}B | $diagnosis |" >> "$REPORT_FILE"
                else
                    still_failing+=("$card_path")
                    still_diagnoses+=("$diagnosis")
                    echo "  ❌ $card_name — still failing on retry $retry"
                    echo "| $card_name | STILL_FAILING | $retry | ${size}B | $diagnosis |" >> "$REPORT_FILE"
                fi

                if $app_alive; then
                    xcrun simctl openurl "$SIM_UDID" "adaptivecards://gallery" 2>/dev/null
                    sleep 1
                fi
            done

            failed_cards=("${still_failing[@]+"${still_failing[@]}"}")
            card_diagnoses=("${still_diagnoses[@]+"${still_diagnoses[@]}"}")

            if [ ${#failed_cards[@]} -eq 0 ]; then
                echo "  🎉 All cards recovered after retry $retry!"
                break
            fi
        done

        echo "" >> "$REPORT_FILE"
        echo "**Recovery:** $recovered cards recovered | ${#failed_cards[@]} persistent failures" >> "$REPORT_FILE"
        echo ""
        echo "  Recovery: $recovered recovered | ${#failed_cards[@]} persistent failures"
    fi
}

# =============================================================================
# Phase 4: Crash Analysis (deep log mining)
# =============================================================================
phase4_crash_analysis() {
    echo ""
    echo "━━━ Phase 4: Crash Analysis ━━━"
    echo "" >> "$REPORT_FILE"
    echo "## Phase 4: Crash Analysis" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    local crash_count=0
    local hang_count=0
    local oom_count=0
    local parse_err_count=0
    local runtime_err_count=0
    local swiftui_err_count=0

    for logfile in "$LOGS_DIR"/*.txt; do
        [ -f "$logfile" ] || continue
        local name
        name=$(basename "$logfile" .txt)

        if grep -qiE "EXC_BAD_ACCESS|EXC_CRASH|SIGABRT|Fatal error" "$logfile" 2>/dev/null; then
            crash_count=$((crash_count + 1))
            echo "### Crash: $name" >> "$REPORT_FILE"
            echo '```' >> "$REPORT_FILE"
            grep -iE -A5 "EXC_BAD_ACCESS|EXC_CRASH|SIGABRT|Fatal error" "$logfile" | head -15 >> "$REPORT_FILE"
            echo '```' >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
        fi

        if grep -ivE "CFNetwork|timeouts\(|RunningBoardServices|didChangeInheritances" "$logfile" | grep -qiE "watchdog|hang.*detected|scene.*not respond|UIApplication.*timeout|BKProcess.*timeout" 2>/dev/null; then
            hang_count=$((hang_count + 1))
        fi

        if grep -qiE "Jetsam|memorystatus|killed.*memory" "$logfile" 2>/dev/null; then
            oom_count=$((oom_count + 1))
        fi

        if grep -qiE "DecodingError|typeMismatch|keyNotFound" "$logfile" 2>/dev/null; then
            parse_err_count=$((parse_err_count + 1))
        fi

        if grep -qiE "unexpectedly found nil|force unwrap|index out of range" "$logfile" 2>/dev/null; then
            runtime_err_count=$((runtime_err_count + 1))
        fi

        if grep -qiE "SwiftUI.*error|attributeGraph|AG:.*precondition" "$logfile" 2>/dev/null; then
            swiftui_err_count=$((swiftui_err_count + 1))
        fi
    done

    # Also check for .ips crash reports we captured
    local crash_report_count=0
    for ips in "$LOGS_DIR"/*-crash-report.ips; do
        [ -f "$ips" ] || continue
        crash_report_count=$((crash_report_count + 1))
        local name
        name=$(basename "$ips" -crash-report.ips)
        echo "### System Crash Report: $name" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        head -30 "$ips" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    done

    echo "| Issue Type | Count |" >> "$REPORT_FILE"
    echo "|------------|-------|" >> "$REPORT_FILE"
    echo "| Crashes (EXC_/SIGABRT/Fatal) | $crash_count |" >> "$REPORT_FILE"
    echo "| System Crash Reports (.ips) | $crash_report_count |" >> "$REPORT_FILE"
    echo "| Hangs (Watchdog) | $hang_count |" >> "$REPORT_FILE"
    echo "| OOM (Jetsam) | $oom_count |" >> "$REPORT_FILE"
    echo "| Parse Errors (DecodingError) | $parse_err_count |" >> "$REPORT_FILE"
    echo "| Runtime Errors (nil/bounds) | $runtime_err_count |" >> "$REPORT_FILE"
    echo "| SwiftUI Errors | $swiftui_err_count |" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    echo "  Crashes: $crash_count | Hangs: $hang_count | OOM: $oom_count | Parse: $parse_err_count | Runtime: $runtime_err_count | SwiftUI: $swiftui_err_count"
}

# =============================================================================
# Phase 5: Fix Suggestions
# =============================================================================
phase5_fix_suggestions() {
    echo ""
    echo "━━━ Phase 5: Fix Suggestions ━━━"
    echo "" >> "$REPORT_FILE"
    echo "## Phase 5: Fix Suggestions" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    local has_suggestions=false

    # Analyze each log file for actionable fixes
    for logfile in "$LOGS_DIR"/*.txt; do
        [ -f "$logfile" ] || continue
        local name
        name=$(basename "$logfile" .txt)
        # Skip retry logs for fix suggestions
        [[ "$name" == *"-retry"* ]] && continue

        local diagnosis
        diagnosis=$(diagnose_logs "$logfile")

        if [[ "$diagnosis" != "CLEAN" && "$diagnosis" != "NO_LOGS" ]]; then
            local fix
            fix=$(suggest_fix "$diagnosis" "$name")
            if [ -n "$fix" ]; then
                has_suggestions=true
                echo "### $name" >> "$REPORT_FILE"
                echo "- **Diagnosis:** \`$diagnosis\`" >> "$REPORT_FILE"
                echo "- $fix" >> "$REPORT_FILE"

                # Add file-level hints for common patterns
                if [[ "$diagnosis" == *"PARSE_ERROR"* ]]; then
                    echo "- **Files to check:** \`ios/Sources/ACCore/Models/\`, \`SchemaValidator.swift\`, \`CardElement.swift\`" >> "$REPORT_FILE"
                fi
                if [[ "$diagnosis" == *"SWIFTUI_ERROR"* ]]; then
                    echo "- **Files to check:** \`ios/Sources/ACRendering/Views/\`" >> "$REPORT_FILE"
                fi
                if [[ "$diagnosis" == *"IMAGE_LOAD_FAILURE"* ]]; then
                    echo "- **Files to check:** \`ios/Sources/ACRendering/Views/ImageElementView.swift\`" >> "$REPORT_FILE"
                fi
                if [[ "$diagnosis" == *"OOM_JETSAM"* ]]; then
                    echo "- **Files to check:** Image caching, container nesting depth limits in \`ACRendering\`" >> "$REPORT_FILE"
                fi
                if [[ "$diagnosis" == *"RUNTIME_ERROR"* ]]; then
                    echo "- **Action:** \`grep -rn '!' ios/Sources/ACRendering/Views/\` to find force-unwraps" >> "$REPORT_FILE"
                fi
                echo "" >> "$REPORT_FILE"
            fi
        fi
    done

    if ! $has_suggestions; then
        echo "No actionable fix suggestions — all cards appear healthy." >> "$REPORT_FILE"
        echo "  No fix suggestions needed — all clean."
    else
        echo "  Fix suggestions written to report."
    fi
    echo "" >> "$REPORT_FILE"
}

# =============================================================================
# Phase 6: Summary Report
# =============================================================================
phase6_report() {
    echo ""
    echo "━━━ Phase 6: Report ━━━"
    echo "" >> "$REPORT_FILE"
    echo "## Artifacts" >> "$REPORT_FILE"
    echo "- Screenshots: \`$REPORT_DIR/screenshots/\`" >> "$REPORT_FILE"
    echo "- Simulator logs: \`$LOGS_DIR/\`" >> "$REPORT_FILE"
    echo "- Report: \`$REPORT_FILE\`" >> "$REPORT_FILE"
    if [ -f "$REPORT_DIR/phase1-test-output.txt" ]; then
        echo "- Unit test output: \`$REPORT_DIR/phase1-test-output.txt\`" >> "$REPORT_FILE"
    fi
    if [ -f "$REPORT_DIR/build-output.txt" ]; then
        echo "- Build output: \`$REPORT_DIR/build-output.txt\`" >> "$REPORT_FILE"
    fi

    # Count crash report files
    local ips_count=0
    for ips in "$LOGS_DIR"/*-crash-report.ips; do
        [ -f "$ips" ] && ips_count=$((ips_count + 1))
    done
    if [ "$ips_count" -gt 0 ]; then
        echo "- System crash reports: $ips_count files in \`$LOGS_DIR/\`" >> "$REPORT_FILE"
    fi

    echo ""
    echo "  Report: $REPORT_FILE"
    echo "  Screenshots: $REPORT_DIR/screenshots/"
    echo "  Logs: $LOGS_DIR/"
    echo ""

    cat "$REPORT_FILE"

    # Publish failure outputs to a stable location for CI / downstream consumers
    publish_failure_outputs
}

# =============================================================================
# Publish failure outputs — copies failure artifacts to a stable, well-known
# directory so CI pipelines and post-processing scripts can pick them up.
# =============================================================================
publish_failure_outputs() {
    local publish_dir="$REPO_ROOT/shared/test-outputs/ios-self-heal"
    mkdir -p "$publish_dir"

    # Copy the markdown report
    cp "$REPORT_FILE" "$publish_dir/report.md"

    # Copy failure screenshots and logs (WARN/FAIL cards + retry screenshots)
    local failure_count=0
    for logfile in "$LOGS_DIR"/*.txt; do
        [ -f "$logfile" ] || continue
        local name
        name=$(basename "$logfile" .txt)
        # Skip retries — they have separate files
        [[ "$name" == *"-retry"* ]] && continue
        local diag
        diag=$(diagnose_logs "$logfile")
        if [[ "$diag" != "CLEAN" && "$diag" != "NO_LOGS" ]]; then
            failure_count=$((failure_count + 1))
            # Copy screenshot and log for this failure
            local screenshot="$REPORT_DIR/screenshots/${name}.png"
            if [ -f "$screenshot" ]; then
                cp "$screenshot" "$publish_dir/${name}.png"
            fi
            cp "$logfile" "$publish_dir/${name}-log.txt"
        fi
    done

    # Also copy screenshots for cards that were WARN/FAIL by size (even if logs were clean)
    for screenshot in "$REPORT_DIR/screenshots"/*.png; do
        [ -f "$screenshot" ] || continue
        local size
        size=$(stat -f%z "$screenshot" 2>/dev/null || echo "0")
        if [ "$size" -lt 25000 ]; then
            local base
            base=$(basename "$screenshot")
            if [ ! -f "$publish_dir/$base" ]; then
                cp "$screenshot" "$publish_dir/$base"
                failure_count=$((failure_count + 1))
            fi
        fi
    done

    # Copy any crash reports (.ips files)
    for ips in "$LOGS_DIR"/*-crash-report.ips; do
        [ -f "$ips" ] || continue
        cp "$ips" "$publish_dir/"
    done

    # Write a machine-readable summary JSON for CI consumption
    local summary_json="$publish_dir/summary.json"
    cat > "$summary_json" << ENDJSON
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "category": "$CATEGORY",
  "mode": "$MODE",
  "simulator": "$SIMULATOR",
  "report_dir": "$REPORT_DIR",
  "publish_dir": "$publish_dir",
  "failure_count": $failure_count
}
ENDJSON

    if [ "$failure_count" -gt 0 ]; then
        echo ""
        echo "━━━ Published $failure_count failure artifact(s) ━━━"
        echo "  Output dir: $publish_dir"
        echo "  Summary:    $summary_json"
        ls -la "$publish_dir/"
    else
        echo ""
        echo "  No failures to publish — all clean."
    fi
}

# =============================================================================
# Main
# =============================================================================
echo "╔══════════════════════════════════════════════╗"
echo "║  Self-Healing iOS Card Test Loop (v2)        ║"
echo "╚══════════════════════════════════════════════╝"

init_report

case "$MODE" in
    full)
        phase1_parse
        phase2_visual
        phase4_crash_analysis
        phase5_fix_suggestions
        phase6_report
        ;;
    parse)
        phase1_parse
        phase6_report
        ;;
    visual)
        phase2_visual
        phase4_crash_analysis
        phase5_fix_suggestions
        phase6_report
        ;;
esac