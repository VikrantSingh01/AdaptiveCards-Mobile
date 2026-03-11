#!/bin/bash
# =============================================================================
# Self-Healing Android Card Test Loop (Enhanced)
# =============================================================================
#
# Automated detect → diagnose → recover → fix cycle for Adaptive Card rendering
# on Android. Goes beyond simple screenshot analysis with crash detection,
# logcat diagnostics, ANR monitoring, memory profiling, auto-retry with app
# recovery, and structured fix suggestions.
#
# Usage:
#   bash shared/scripts/self-heal-android.sh                    # Full run
#   bash shared/scripts/self-heal-android.sh --parse-only       # Unit tests only
#   bash shared/scripts/self-heal-android.sh --visual-only      # Visual tests only
#   bash shared/scripts/self-heal-android.sh --card cafe-menu   # Single card
#   bash shared/scripts/self-heal-android.sh --retry 3          # Custom retry count
#   bash shared/scripts/self-heal-android.sh --category element # Test element-samples
#
# Phases:
#   1. Parse Regression  — Gradle unit tests catch deserialization failures
#   2. Visual Smoke      — deep-link, screenshot, analyze with multi-signal diagnosis
#   3. Crash Analysis     — logcat mining for exceptions, ANRs, OOM
#   4. Recovery & Retry   — auto-restart app, retry failed cards
#   5. Fix Suggestions    — structured remediation based on error patterns
#   6. Report             — rich markdown report with all artifacts
#
# Prerequisites:
#   - Android emulator running (or device connected)
#   - Android SDK with adb on PATH or ANDROID_HOME set
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
APP_ID="com.microsoft.adaptivecards.sample"
MAIN_ACTIVITY="$APP_ID/.MainActivity"
REPORT_DIR="/tmp/self-heal-android-$(date +%Y%m%d-%H%M%S)"
REPORT_FILE="$REPORT_DIR/report.md"
LOGCAT_DIR="$REPORT_DIR/logcat"
MODE="full"
SINGLE_CARD=""
MAX_RETRIES=2
CATEGORY="teams-official"
RENDER_WAIT=4  # seconds to wait for card to render

# Resolve adb
if command -v adb &>/dev/null; then
    ADB="adb"
elif [ -n "${ANDROID_HOME:-}" ]; then
    ADB="$ANDROID_HOME/platform-tools/adb"
else
    ADB="$HOME/Library/Android/sdk/platform-tools/adb"
fi

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --parse-only) MODE="parse"; shift ;;
        --visual-only) MODE="visual"; shift ;;
        --card) SINGLE_CARD="$2"; shift 2 ;;
        --retry) MAX_RETRIES="$2"; shift 2 ;;
        --category) CATEGORY="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

mkdir -p "$REPORT_DIR/screenshots" "$LOGCAT_DIR"

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
check_emulator() {
    local devices
    devices=$("$ADB" devices 2>/dev/null | grep -c "device$" || true)
    if [ "$devices" -eq 0 ]; then
        echo "  ❌ No Android device/emulator detected."
        echo "     Start one: emulator -avd Medium_Phone_API_36.1 &"
        exit 1
    fi
    echo "  ✅ Device connected"
}

# Check if app is running
is_app_running() {
    "$ADB" shell pidof "$APP_ID" &>/dev/null
}

# Force restart the app (recovery action)
restart_app() {
    echo "  ↻ Restarting app..."
    "$ADB" shell am force-stop "$APP_ID" 2>/dev/null || true
    sleep 1
    "$ADB" shell am start -n "$MAIN_ACTIVITY" 2>/dev/null
    sleep 3
}

# Clear logcat buffer for clean capture
clear_logcat() {
    "$ADB" logcat -c 2>/dev/null || true
}

# Capture logcat for a specific card test
capture_logcat() {
    local card_name="$1"
    local output_file="$LOGCAT_DIR/${card_name}.txt"
    # Capture app-specific logs + crash/ANR markers
    "$ADB" logcat -d -t 200 \
        --pid="$("$ADB" shell pidof "$APP_ID" 2>/dev/null || echo 0)" \
        2>/dev/null > "$output_file" || \
    "$ADB" logcat -d -t 200 2>/dev/null | grep -iE "$APP_ID|AndroidRuntime|FATAL|ANR|OOM|adaptivecards" > "$output_file" || true
    echo "$output_file"
}

# Analyze logcat for errors — returns structured diagnosis
diagnose_logcat() {
    local logfile="$1"
    local diagnosis=""

    if [ ! -f "$logfile" ] || [ ! -s "$logfile" ]; then
        echo "NO_LOGS"
        return
    fi

    # Check for crashes (FATAL EXCEPTION)
    if grep -q "FATAL EXCEPTION" "$logfile"; then
        local exception
        exception=$(grep -A3 "FATAL EXCEPTION" "$logfile" | head -4)
        diagnosis="CRASH: $exception"
    fi

    # Check for ANR
    if grep -qi "ANR\|Application Not Responding" "$logfile"; then
        diagnosis="${diagnosis:+$diagnosis | }ANR_DETECTED"
    fi

    # Check for OOM
    if grep -qi "OutOfMemoryError\|OOM\|Low Memory" "$logfile"; then
        diagnosis="${diagnosis:+$diagnosis | }OOM"
    fi

    # Check for JSON/parsing errors
    if grep -qi "JsonDecodingException\|SerializationException\|MalformedJsonException\|JSONException" "$logfile"; then
        local parse_err
        parse_err=$(grep -i "JsonDecodingException\|SerializationException\|MalformedJsonException\|JSONException" "$logfile" | head -1)
        diagnosis="${diagnosis:+$diagnosis | }PARSE_ERROR: $parse_err"
    fi

    # Check for null pointer / illegal state
    if grep -qi "NullPointerException\|IllegalStateException\|IllegalArgumentException" "$logfile"; then
        local runtime_err
        runtime_err=$(grep -i "NullPointerException\|IllegalStateException\|IllegalArgumentException" "$logfile" | head -1)
        diagnosis="${diagnosis:+$diagnosis | }RUNTIME_ERROR: $runtime_err"
    fi

    # Check for Compose rendering errors
    if grep -qi "ComposeException\|IllegalStateException.*Compose\|recomposition" "$logfile"; then
        diagnosis="${diagnosis:+$diagnosis | }COMPOSE_ERROR"
    fi

    # Check for image loading failures
    if grep -qi "ImageDecoder\|BitmapFactory\|Failed to load image\|HTTP.*404\|HTTP.*500" "$logfile"; then
        diagnosis="${diagnosis:+$diagnosis | }IMAGE_LOAD_FAILURE"
    fi

    if [ -z "$diagnosis" ]; then
        echo "CLEAN"
    else
        echo "$diagnosis"
    fi
}

# Get memory info for the app
get_memory_info() {
    local meminfo
    meminfo=$("$ADB" shell dumpsys meminfo "$APP_ID" 2>/dev/null | grep "TOTAL PSS" | head -1 | awk '{print $3}')
    echo "${meminfo:-0}"
}

# Suggest fixes based on diagnosis
suggest_fix() {
    local diagnosis="$1"
    local card_name="$2"

    case "$diagnosis" in
        *CRASH*)
            echo "**Fix:** Check stack trace in \`$LOGCAT_DIR/${card_name}.txt\`. Likely unhandled exception in card parser or renderer."
            ;;
        *ANR*)
            echo "**Fix:** Card rendering is blocking the main thread. Move parsing to a coroutine with \`Dispatchers.Default\`."
            ;;
        *OOM*)
            echo "**Fix:** Card may contain large images. Check image URLs and add memory-bounded image loading with size limits."
            ;;
        *PARSE_ERROR*)
            echo "**Fix:** Card JSON contains elements not handled by \`@Serializable\` models. Check \`ac-core\` deserializer for missing \`@SerialName\` entries."
            ;;
        *RUNTIME_ERROR*)
            echo "**Fix:** Null safety issue in renderer. Check composable null guards for optional card properties."
            ;;
        *COMPOSE_ERROR*)
            echo "**Fix:** Compose layout issue — likely infinite constraint or missing size modifier. Check \`AdaptiveCardView\` composable tree."
            ;;
        *IMAGE_LOAD_FAILURE*)
            echo "**Fix:** Image URL is broken or unreachable. Consider adding placeholder/fallback image in \`ImageView\` composable."
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
    cat > "$REPORT_FILE" << EOF
# Self-Healing Android Card Test Report

**Date:** $(date)
**Mode:** $MODE
**Category:** $CATEGORY
**Max Retries:** $MAX_RETRIES
**Device:** $("$ADB" shell getprop ro.product.model 2>/dev/null || echo "unknown")
**API Level:** $("$ADB" shell getprop ro.build.version.sdk 2>/dev/null || echo "unknown")

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

    cd "$REPO_ROOT/android"

    local test_output
    test_output=$(./gradlew :ac-core:test 2>&1) || true

    if echo "$test_output" | grep -q "BUILD SUCCESSFUL"; then
        # Extract test counts
        local test_summary
        test_summary=$(echo "$test_output" | grep -E "tests.*passed" | tail -1 || true)
        echo "  ✅ All core unit tests pass"
        echo "**Result:** All core unit tests pass ${test_summary:+($test_summary)}" >> "$REPORT_FILE"
    else
        # Extract detailed failure info
        local fail_count
        fail_count=$(echo "$test_output" | grep -c "FAILED" || echo "0")
        echo "  ❌ $fail_count test failures found"
        echo "**Result:** $fail_count test failures" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"

        # Extract each failure with its assertion message
        echo "### Failed Tests" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "$test_output" | grep -B2 -A5 "FAILED" | head -60 | while IFS= read -r line; do
            echo "    $line" >> "$REPORT_FILE"
        done
        echo "" >> "$REPORT_FILE"

        # Categorize by error type
        echo "### Error Categories" >> "$REPORT_FILE"
        local categories
        categories=$(echo "$test_output" | grep -oE "(SerializationException|JsonDecodingException|NullPointerException|AssertionFailedError|IllegalStateException|ClassCastException)" | sort | uniq -c | sort -rn)
        if [ -n "$categories" ]; then
            echo "$categories" | while read -r count etype; do
                echo "- **$count:** \`$etype\`" >> "$REPORT_FILE"
            done
        fi

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

    check_emulator

    # Build and install
    echo "  Building sample app..."
    cd "$REPO_ROOT/android"
    local build_output
    build_output=$(./gradlew :sample-app:installDebug 2>&1) || true

    if ! echo "$build_output" | grep -q "BUILD SUCCESSFUL"; then
        echo "  ❌ Build failed"
        echo "**Build:** FAILED" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        echo "$build_output" | tail -40 >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        echo "$build_output" > "$REPORT_DIR/build-output.txt"
        return 1
    fi
    echo "  ✅ Build + install succeeded"
    cd "$REPO_ROOT"

    # Launch the app
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

        # Clear logcat before each card
        clear_logcat

        # Check app is alive before navigating
        if ! is_app_running; then
            echo "  ⚠️  App crashed — recovering..."
            restart_app
        fi

        # Navigate via deep link
        "$ADB" shell am start -a android.intent.action.VIEW \
            -d "adaptivecards://card/$card_path" \
            "$APP_ID" 2>/dev/null
        sleep "$RENDER_WAIT"

        # Check if app survived the navigation
        local app_alive=true
        if ! is_app_running; then
            app_alive=false
        fi

        # Capture screenshot
        local device_screenshot="/sdcard/ac_test_${card_name}.png"
        local local_screenshot="$REPORT_DIR/screenshots/${card_name}.png"
        if $app_alive; then
            "$ADB" shell screencap -p "$device_screenshot" 2>/dev/null
            "$ADB" pull "$device_screenshot" "$local_screenshot" 2>/dev/null || true
            "$ADB" shell rm "$device_screenshot" 2>/dev/null || true
        fi

        # Capture logcat for this card
        local logfile
        logfile=$(capture_logcat "$card_name")

        # Diagnose via logcat
        local diagnosis
        diagnosis=$(diagnose_logcat "$logfile")

        # Get memory usage
        local mem_kb="0"
        if $app_alive; then
            mem_kb=$(get_memory_info)
        fi

        # Determine screenshot size
        local size="0"
        if [ -f "$local_screenshot" ]; then
            size=$(stat -f%z "$local_screenshot" 2>/dev/null || stat -c%s "$local_screenshot" 2>/dev/null || echo "0")
        fi

        # Multi-signal analysis
        # Thresholds calibrated for 1080x2400 emulator:
        #   <40KB  = navigation didn't work or blank error screen
        #   <90KB  = card detail loaded but minimal/no card content rendered
        #   >=90KB = card has rendered content (text-only cards ~90-200KB, image cards 300KB+)
        local status notes
        if ! $app_alive; then
            status="CRASH"
            notes="App crashed on navigation"
            fail=$((fail + 1))
            failed_cards+=("$card_path")
            card_diagnoses+=("$diagnosis")
            echo "  💥 $card_name — APP CRASHED"
        elif [[ "$diagnosis" == *"CRASH"* ]] || [[ "$diagnosis" == *"ANR"* ]]; then
            status="FAIL"
            notes="$diagnosis"
            fail=$((fail + 1))
            failed_cards+=("$card_path")
            card_diagnoses+=("$diagnosis")
            echo "  ❌ $card_name — $diagnosis"
        elif [ "$size" -lt 40000 ]; then
            status="FAIL"
            notes="Blank/error (${size}B)"
            if [[ "$diagnosis" != "CLEAN" && "$diagnosis" != "NO_LOGS" ]]; then
                notes="$notes | $diagnosis"
            fi
            fail=$((fail + 1))
            failed_cards+=("$card_path")
            card_diagnoses+=("$diagnosis")
            echo "  ❌ $card_name — blank/error (${size}B) [$diagnosis]"
        elif [ "$size" -lt 90000 ]; then
            status="WARN"
            notes="Low content (${size}B)"
            if [[ "$diagnosis" != "CLEAN" && "$diagnosis" != "NO_LOGS" ]]; then
                notes="$notes | $diagnosis"
            fi
            warn=$((warn + 1))
            failed_cards+=("$card_path")
            card_diagnoses+=("$diagnosis")
            echo "  ⚠️  $card_name — low content (${size}B)"
        else
            status="PASS"
            notes="${size}B"
            pass=$((pass + 1))
            echo "  ✅ $card_name (${size}B, ${mem_kb}KB)"
        fi

        local mem_display="${mem_kb}KB"
        if [ "$mem_kb" -gt 200000 ] 2>/dev/null; then
            mem_display="⚠️ ${mem_kb}KB"
        fi

        echo "| $idx | $card_name | $status | ${size}B | $mem_display | ${diagnosis:0:40} | $notes |" >> "$REPORT_FILE"

        # Return to gallery (if app is alive)
        if $app_alive; then
            "$ADB" shell am start -a android.intent.action.VIEW \
                -d "adaptivecards://gallery" \
                "$APP_ID" 2>/dev/null
            sleep 1
        fi
    done

    echo "" >> "$REPORT_FILE"
    echo "**First Pass Summary:** ${#cards_to_test[@]} cards | $pass pass | $warn warn | $fail fail" >> "$REPORT_FILE"
    echo ""
    echo "  First pass: ${#cards_to_test[@]} tested | $pass pass | $warn warn | $fail fail"

    # =========================================================================
    # Phase 3: Recovery & Retry (unique to Android version)
    # =========================================================================
    if [ ${#failed_cards[@]} -gt 0 ] && [ "$MAX_RETRIES" -gt 0 ]; then
        echo ""
        echo "━━━ Phase 3: Recovery & Retry (${#failed_cards[@]} failed cards) ━━━"
        echo "" >> "$REPORT_FILE"
        echo "## Phase 3: Recovery & Retry" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"

        for retry in $(seq 1 "$MAX_RETRIES"); do
            local still_failing=()
            local still_diagnoses=()

            echo "  Retry $retry/$MAX_RETRIES — restarting app with cleared state..."

            # Recovery actions escalate with each retry
            if [ "$retry" -eq 1 ]; then
                # Retry 1: Simple app restart
                restart_app
            else
                # Retry 2+: Clear app data cache (not full clear — preserves prefs)
                "$ADB" shell run-as "$APP_ID" rm -rf cache/ 2>/dev/null || true
                restart_app
                sleep 2
            fi

            for i in "${!failed_cards[@]}"; do
                local card_path="${failed_cards[$i]}"
                local card_name
                card_name=$(basename "$card_path")

                clear_logcat

                if ! is_app_running; then
                    restart_app
                fi

                "$ADB" shell am start -a android.intent.action.VIEW \
                    -d "adaptivecards://card/$card_path" \
                    "$APP_ID" 2>/dev/null
                sleep "$RENDER_WAIT"

                local app_alive=true
                if ! is_app_running; then
                    app_alive=false
                fi

                local device_screenshot="/sdcard/ac_retry_${card_name}.png"
                local local_screenshot="$REPORT_DIR/screenshots/${card_name}-retry${retry}.png"
                if $app_alive; then
                    "$ADB" shell screencap -p "$device_screenshot" 2>/dev/null
                    "$ADB" pull "$device_screenshot" "$local_screenshot" 2>/dev/null || true
                    "$ADB" shell rm "$device_screenshot" 2>/dev/null || true
                fi

                local logfile
                logfile=$(capture_logcat "${card_name}-retry${retry}")
                local diagnosis
                diagnosis=$(diagnose_logcat "$logfile")

                local size="0"
                if [ -f "$local_screenshot" ]; then
                    size=$(stat -f%z "$local_screenshot" 2>/dev/null || stat -c%s "$local_screenshot" 2>/dev/null || echo "0")
                fi

                if $app_alive && [ "$size" -ge 90000 ] && [[ "$diagnosis" != *"CRASH"* ]]; then
                    recovered=$((recovered + 1))
                    fail=$((fail - 1))
                    pass=$((pass + 1))
                    echo "  ✅ $card_name — RECOVERED on retry $retry (${size}B)"
                    echo "| $card_name | RECOVERED | retry $retry | ${size}B | $diagnosis |" >> "$REPORT_FILE"
                else
                    still_failing+=("$card_path")
                    still_diagnoses+=("$diagnosis")
                    echo "  ❌ $card_name — still failing on retry $retry"
                fi

                if $app_alive; then
                    "$ADB" shell am start -a android.intent.action.VIEW \
                        -d "adaptivecards://gallery" \
                        "$APP_ID" 2>/dev/null
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
# Phase 4: Crash Analysis (deep logcat mining)
# =============================================================================
phase4_crash_analysis() {
    echo ""
    echo "━━━ Phase 4: Crash Analysis ━━━"
    echo "" >> "$REPORT_FILE"
    echo "## Phase 4: Crash Analysis" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    local crash_count=0
    local anr_count=0
    local oom_count=0
    local parse_err_count=0

    for logfile in "$LOGCAT_DIR"/*.txt; do
        [ -f "$logfile" ] || continue
        local name
        name=$(basename "$logfile" .txt)

        if grep -q "FATAL EXCEPTION" "$logfile" 2>/dev/null; then
            crash_count=$((crash_count + 1))
            echo "### Crash: $name" >> "$REPORT_FILE"
            echo '```' >> "$REPORT_FILE"
            grep -A10 "FATAL EXCEPTION" "$logfile" | head -15 >> "$REPORT_FILE"
            echo '```' >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
        fi

        if grep -qi "ANR" "$logfile" 2>/dev/null; then
            anr_count=$((anr_count + 1))
        fi

        if grep -qi "OutOfMemoryError" "$logfile" 2>/dev/null; then
            oom_count=$((oom_count + 1))
        fi

        if grep -qi "JsonDecodingException\|SerializationException" "$logfile" 2>/dev/null; then
            parse_err_count=$((parse_err_count + 1))
        fi
    done

    echo "| Issue Type | Count |" >> "$REPORT_FILE"
    echo "|------------|-------|" >> "$REPORT_FILE"
    echo "| Crashes (FATAL) | $crash_count |" >> "$REPORT_FILE"
    echo "| ANRs | $anr_count |" >> "$REPORT_FILE"
    echo "| OOM | $oom_count |" >> "$REPORT_FILE"
    echo "| Parse Errors | $parse_err_count |" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    echo "  Crashes: $crash_count | ANRs: $anr_count | OOM: $oom_count | Parse errors: $parse_err_count"
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

    # Analyze each logcat file for actionable fixes
    for logfile in "$LOGCAT_DIR"/*.txt; do
        [ -f "$logfile" ] || continue
        local name
        name=$(basename "$logfile" .txt)
        # Skip retry logs for fix suggestions
        [[ "$name" == *"-retry"* ]] && continue

        local diagnosis
        diagnosis=$(diagnose_logcat "$logfile")

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
                    echo "- **Files to check:** \`android/ac-core/src/main/kotlin/.../models/\`, \`SchemaValidator.kt\`" >> "$REPORT_FILE"
                fi
                if [[ "$diagnosis" == *"COMPOSE_ERROR"* ]]; then
                    echo "- **Files to check:** \`android/ac-rendering/src/main/kotlin/.../composables/\`" >> "$REPORT_FILE"
                fi
                if [[ "$diagnosis" == *"IMAGE_LOAD_FAILURE"* ]]; then
                    echo "- **Files to check:** \`android/ac-rendering/src/main/kotlin/.../composables/ImageView.kt\`" >> "$REPORT_FILE"
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
    echo "- Logcat dumps: \`$LOGCAT_DIR/\`" >> "$REPORT_FILE"
    echo "- Report: \`$REPORT_FILE\`" >> "$REPORT_FILE"
    if [ -f "$REPORT_DIR/phase1-test-output.txt" ]; then
        echo "- Unit test output: \`$REPORT_DIR/phase1-test-output.txt\`" >> "$REPORT_FILE"
    fi
    if [ -f "$REPORT_DIR/build-output.txt" ]; then
        echo "- Build output: \`$REPORT_DIR/build-output.txt\`" >> "$REPORT_FILE"
    fi

    echo ""
    echo "  Report: $REPORT_FILE"
    echo "  Screenshots: $REPORT_DIR/screenshots/"
    echo "  Logcat: $LOGCAT_DIR/"
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
    local publish_dir="$REPO_ROOT/shared/test-outputs/android-self-heal"
    mkdir -p "$publish_dir"

    # Copy the markdown report
    cp "$REPORT_FILE" "$publish_dir/report.md"

    # Copy failure screenshots (WARN/FAIL cards + retry screenshots)
    local failure_count=0
    for logfile in "$LOGCAT_DIR"/*.txt; do
        [ -f "$logfile" ] || continue
        local name
        name=$(basename "$logfile" .txt)
        # Skip retries for logcat — they have separate files
        local diag
        diag=$(diagnose_logcat "$logfile")
        if [[ "$diag" != "CLEAN" && "$diag" != "NO_LOGS" ]]; then
            failure_count=$((failure_count + 1))
            # Copy screenshot and logcat for this failure
            local screenshot="$REPORT_DIR/screenshots/${name}.png"
            if [ -f "$screenshot" ]; then
                cp "$screenshot" "$publish_dir/${name}.png"
            fi
            cp "$logfile" "$publish_dir/${name}-logcat.txt"
        fi
    done

    # Also copy screenshots for cards that were WARN/FAIL by size (even if logcat was clean)
    for screenshot in "$REPORT_DIR/screenshots"/*.png; do
        [ -f "$screenshot" ] || continue
        local size
        size=$(stat -f%z "$screenshot" 2>/dev/null || stat -c%s "$screenshot" 2>/dev/null || echo "0")
        if [ "$size" -lt 90000 ]; then
            local base
            base=$(basename "$screenshot")
            if [ ! -f "$publish_dir/$base" ]; then
                cp "$screenshot" "$publish_dir/$base"
                failure_count=$((failure_count + 1))
            fi
        fi
    done

    # Write a machine-readable summary JSON for CI consumption
    local summary_json="$publish_dir/summary.json"
    cat > "$summary_json" << ENDJSON
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "category": "$CATEGORY",
  "mode": "$MODE",
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
echo "║  Self-Healing Android Card Test Loop (v2)    ║"
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
