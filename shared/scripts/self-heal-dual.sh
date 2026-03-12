#!/bin/bash
# =============================================================================
# Dual-Platform Synchronized Self-Healing Card Test Loop
# =============================================================================
#
# Lock-step visual testing: navigates to the SAME card on both iOS and Android
# simultaneously, waits for both to render, screenshots both, then advances.
# The developer sees the same card on both simulators side-by-side.
#
# Usage:
#   bash shared/scripts/self-heal-dual.sh                          # teams-official
#   bash shared/scripts/self-heal-dual.sh --category element       # element-samples
#   bash shared/scripts/self-heal-dual.sh --card cafe-menu         # single card
#   bash shared/scripts/self-heal-dual.sh --retry 3                # custom retry count
#
# Prerequisites:
#   - iOS Simulator "iPhone 16e" booted
#   - Android emulator running (or device connected)
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_DIR="${REPO_ROOT}/shared/test-output/self-heal-dual-$TIMESTAMP"
REPORT_FILE="$REPORT_DIR/report.md"

# Defaults
CATEGORY="teams-official"
SINGLE_CARD=""
MAX_RETRIES=2
RENDER_WAIT=4  # max seconds per platform — both must finish within this

# Platform config
IOS_SIMULATOR="iPhone 16e"
IOS_APP_ID="com.microsoft.adaptivecards.sampleapp"
ANDROID_APP_ID="com.microsoft.adaptivecards.sample"
ANDROID_MAIN_ACTIVITY="$ANDROID_APP_ID/.MainActivity"

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --category) CATEGORY="$2"; shift 2 ;;
        --card) SINGLE_CARD="$2"; shift 2 ;;
        --retry) MAX_RETRIES="$2"; shift 2 ;;
        --wait) RENDER_WAIT="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

mkdir -p "$REPORT_DIR/screenshots/ios" "$REPORT_DIR/screenshots/android"

# =============================================================================
# Resolve platform tools
# =============================================================================

# iOS — resolve simulator UDID
SIM_UDID=""
IOS_READY=false
SIM_UDID=$(xcrun simctl list devices available 2>/dev/null | grep "$IOS_SIMULATOR" | grep -oE '[A-F0-9-]{36}' | head -1 || true)
if [ -n "$SIM_UDID" ]; then
    SIM_STATE=$(xcrun simctl list devices 2>/dev/null | grep "$SIM_UDID" | grep -oE '\(Booted\)' || true)
    [ -n "$SIM_STATE" ] && IOS_READY=true
fi

# Android — resolve adb
if command -v adb &>/dev/null; then
    ADB="adb"
elif [ -n "${ANDROID_HOME:-}" ]; then
    ADB="$ANDROID_HOME/platform-tools/adb"
else
    ADB="$HOME/Library/Android/sdk/platform-tools/adb"
fi

ANDROID_READY=false
ANDROID_DEVICES=$("$ADB" devices 2>/dev/null | grep -c "device$" || true)
[ "$ANDROID_DEVICES" -gt 0 ] && ANDROID_READY=true

# =============================================================================
# Card Catalog
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

get_cards_from_dir() {
    local dir="$1"
    local prefix="$2"
    local cards=()
    if [ -d "$REPO_ROOT/shared/test-cards/$dir" ]; then
        for f in "$REPO_ROOT/shared/test-cards/$dir"/*.json; do
            [ -f "$f" ] || continue
            cards+=("$prefix/$(basename "$f" .json)")
        done
    fi
    echo "${cards[@]}"
}

# Select card catalog
cards_to_test=()
if [ -n "$SINGLE_CARD" ]; then
    cards_to_test=("$SINGLE_CARD")
else
    case "$CATEGORY" in
        teams-official) cards_to_test=("${TEAMS_OFFICIAL_CARDS[@]}") ;;
        element) IFS=' ' read -ra cards_to_test <<< "$(get_cards_from_dir element-samples element-samples)" ;;
        official) IFS=' ' read -ra cards_to_test <<< "$(get_cards_from_dir official-samples official-samples)" ;;
        all)
            cards_to_test=("${TEAMS_OFFICIAL_CARDS[@]}")
            IFS=' ' read -ra extra <<< "$(get_cards_from_dir element-samples element-samples)"
            cards_to_test+=("${extra[@]}")
            IFS=' ' read -ra extra <<< "$(get_cards_from_dir official-samples official-samples)"
            cards_to_test+=("${extra[@]}")
            # Versioned cards (v1.5 and v1.6 only — older versions removed)
            for ver in v1.5 v1.6; do
                IFS=' ' read -ra extra <<< "$(get_cards_from_dir "versioned/$ver" "versioned/$ver")"
                cards_to_test+=("${extra[@]}")
            done
            ;;
        versioned)
            for ver in v1.5 v1.6; do
                IFS=' ' read -ra extra <<< "$(get_cards_from_dir "versioned/$ver" "versioned/$ver")"
                cards_to_test+=("${extra[@]}")
            done
            ;;
        *) cards_to_test=("${TEAMS_OFFICIAL_CARDS[@]}") ;;
    esac
fi

# =============================================================================
# Utility Functions
# =============================================================================

# Resize screenshot to 540px wide for smaller file sizes while keeping enough detail
resize_screenshot() {
    local f="$1"
    [ -f "$f" ] || return 0
    sips --resampleWidth 540 "$f" &>/dev/null || true
}

# iOS helpers — all output suppressed for clean terminal
ios_is_running() {
    xcrun simctl spawn "$SIM_UDID" launchctl list 2>/dev/null | grep -q "$IOS_APP_ID" 2>/dev/null
}

ios_restart() {
    xcrun simctl terminate "$SIM_UDID" "$IOS_APP_ID" &>/dev/null || true
    sleep 0.5
    xcrun simctl launch "$SIM_UDID" "$IOS_APP_ID" &>/dev/null
    sleep 3
}

ios_navigate() {
    xcrun simctl openurl "$SIM_UDID" "adaptivecards://card/$1" &>/dev/null
}

ios_screenshot() {
    xcrun simctl io "$SIM_UDID" screenshot "$1" &>/dev/null || true
    resize_screenshot "$1"
}

ios_gallery() {
    xcrun simctl openurl "$SIM_UDID" "adaptivecards://gallery" &>/dev/null
}

# Android helpers — all output suppressed for clean terminal
android_is_running() {
    "$ADB" shell pidof "$ANDROID_APP_ID" &>/dev/null
}

android_restart() {
    "$ADB" shell am force-stop "$ANDROID_APP_ID" &>/dev/null || true
    sleep 0.5
    "$ADB" shell am start -n "$ANDROID_MAIN_ACTIVITY" &>/dev/null
    sleep 2
}

android_navigate() {
    "$ADB" shell am start -a android.intent.action.VIEW \
        -d "adaptivecards://card/$1" \
        "$ANDROID_APP_ID" &>/dev/null
}

android_screenshot() {
    local out="$1"
    local device_path="/sdcard/ac_dual_tmp.png"
    "$ADB" shell screencap -p "$device_path" &>/dev/null
    "$ADB" pull "$device_path" "$out" &>/dev/null || true
    "$ADB" shell rm "$device_path" &>/dev/null || true
    resize_screenshot "$out"
}

android_gallery() {
    "$ADB" shell am start -a android.intent.action.VIEW \
        -d "adaptivecards://gallery" \
        "$ANDROID_APP_ID" &>/dev/null
}

file_size() {
    local f="$1"
    if [ -f "$f" ]; then
        stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Classify screenshot: PASS / WARN / FAIL based on file size
classify() {
    local size="$1"
    local platform="$2"
    # Screenshots resized to 540px wide — smaller thresholds
    local fail_thresh=10000
    local warn_thresh=25000
    if [ "$platform" = "android" ]; then
        fail_thresh=8000
        warn_thresh=20000
    fi
    if [ "$size" -lt "$fail_thresh" ]; then
        echo "FAIL"
    elif [ "$size" -lt "$warn_thresh" ]; then
        echo "WARN"
    else
        echo "PASS"
    fi
}

# =============================================================================
# Banner
# =============================================================================
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  Dual-Platform Synchronized Card Test Loop               ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "  Category:  $CATEGORY"
[ -n "$SINGLE_CARD" ] && echo "  Card:      $SINGLE_CARD"
echo "  Cards:     ${#cards_to_test[@]}"
echo "  Retries:   $MAX_RETRIES"
echo "  Wait:      ${RENDER_WAIT}s per card"
echo "  Report:    $REPORT_DIR"
echo ""

# =============================================================================
# Pre-flight
# =============================================================================
echo "━━━ Pre-flight Checks ━━━"

if $IOS_READY; then
    echo "  ✅ iOS:     iPhone 16e ($SIM_UDID) — Booted"
else
    echo "  ❌ iOS:     Not available"
fi

if $ANDROID_READY; then
    DEVICE_MODEL=$("$ADB" shell getprop ro.product.model 2>/dev/null || echo "unknown")
    echo "  ✅ Android: $DEVICE_MODEL — Connected"
else
    echo "  ❌ Android: Not available"
fi

if ! $IOS_READY && ! $ANDROID_READY; then
    echo "  Neither platform ready. Exiting."
    exit 1
fi
echo ""

# =============================================================================
# Build & Install (parallel)
# =============================================================================
echo "━━━ Build & Install ━━━"

IOS_BUILD_OK=false
ANDROID_BUILD_OK=false

# Launch builds in parallel
IOS_BUILD_LOG="$REPORT_DIR/ios-build.log"
ANDROID_BUILD_LOG="$REPORT_DIR/android-build.log"

if $IOS_READY; then
    echo "  🍎 Building iOS sample app..."
    (
        xcodebuild -project "$REPO_ROOT/ios/SampleApp.xcodeproj" \
            -scheme ACVisualizer \
            -sdk iphonesimulator \
            -destination "platform=iOS Simulator,name=$IOS_SIMULATOR" \
            CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
            build 2>&1 && echo "__BUILD_OK__"
    ) > "$IOS_BUILD_LOG" &
    IOS_BUILD_PID=$!
fi

if $ANDROID_READY; then
    echo "  🤖 Building Android sample app..."
    (
        cd "$REPO_ROOT/android" && ./gradlew :sample-app:installDebug 2>&1 && echo "__BUILD_OK__"
    ) > "$ANDROID_BUILD_LOG" &
    ANDROID_BUILD_PID=$!
fi

# Wait for builds
if $IOS_READY; then
    wait "$IOS_BUILD_PID" 2>/dev/null || true
    if grep -q "__BUILD_OK__" "$IOS_BUILD_LOG" 2>/dev/null; then
        # Install on simulator
        local_app=$(find ~/Library/Developer/Xcode/DerivedData/SampleApp-*/Build/Products/Debug-iphonesimulator -name "ACVisualizer.app" -maxdepth 1 2>/dev/null | head -1)
        if [ -n "$local_app" ]; then
            xcrun simctl install "$SIM_UDID" "$local_app" &>/dev/null
            IOS_BUILD_OK=true
            echo "  ✅ iOS build + install succeeded"
        else
            echo "  ❌ iOS build succeeded but app not found"
        fi
    else
        echo "  ❌ iOS build failed (see $IOS_BUILD_LOG)"
    fi
fi

if $ANDROID_READY; then
    wait "$ANDROID_BUILD_PID" 2>/dev/null || true
    if grep -q "__BUILD_OK__" "$ANDROID_BUILD_LOG" 2>/dev/null; then
        ANDROID_BUILD_OK=true
        echo "  ✅ Android build + install succeeded"
    else
        echo "  ❌ Android build failed (see $ANDROID_BUILD_LOG)"
    fi
fi

if ! $IOS_BUILD_OK && ! $ANDROID_BUILD_OK; then
    echo "  Both builds failed. Exiting."
    exit 1
fi
echo ""

# =============================================================================
# Launch apps
# =============================================================================
echo "━━━ Launching Apps ━━━"
$IOS_BUILD_OK && ios_restart &
$ANDROID_BUILD_OK && android_restart &
wait
echo "  Apps launched."
echo ""

# =============================================================================
# Report init
# =============================================================================
cat > "$REPORT_FILE" << EOF
# Dual-Platform Synchronized Card Test Report

**Date:** $(date)
**Category:** $CATEGORY
**Cards:** ${#cards_to_test[@]}
**Retries:** $MAX_RETRIES
**Render wait:** ${RENDER_WAIT}s
$([ -n "$SINGLE_CARD" ] && echo "**Card:** $SINGLE_CARD")

## Visual Rendering (Lock-Step)

| # | Card | iOS | Android | iOS Size | Android Size | Diff | Notes |
|---|------|-----|---------|----------|--------------|------|-------|
EOF

# =============================================================================
# Lock-Step Card Testing
# =============================================================================
echo "━━━ Lock-Step Visual Testing ━━━"
echo ""

ios_pass=0; ios_warn=0; ios_fail=0
android_pass=0; android_warn=0; android_fail=0
declare -a failed_cards_ios=()
declare -a failed_cards_android=()
idx=0

# Stuck-on-gallery detection: track consecutive identical screenshot hashes
ios_prev_hash=""
android_prev_hash=""
ios_stuck_count=0
android_stuck_count=0
STUCK_THRESHOLD=3  # flag after N consecutive identical screenshots

for card_path in "${cards_to_test[@]}"; do
    idx=$((idx + 1))
    card_name=$(basename "$card_path")

    printf "  [%2d/%d] %-30s" "$idx" "${#cards_to_test[@]}" "$card_name"

    # --- Ensure apps are alive (wait for full restart before navigating) ---
    if $IOS_BUILD_OK && ! ios_is_running; then
        ios_restart
        # Wait up to 5s for app to be fully running
        for _w in $(seq 1 10); do ios_is_running && break; sleep 0.5; done
    fi
    if $ANDROID_BUILD_OK && ! android_is_running; then
        android_restart
        # Wait up to 5s for app to be fully running
        for _w in $(seq 1 10); do android_is_running && break; sleep 0.5; done
    fi

    # --- Navigate BOTH platforms simultaneously ---
    $IOS_BUILD_OK && ios_navigate "$card_path" &
    $ANDROID_BUILD_OK && android_navigate "$card_path" &
    wait

    # --- Wait for rendering (single shared wait — both render in parallel) ---
    sleep "$RENDER_WAIT"

    # --- Screenshot BOTH simultaneously ---
    ios_ss="$REPORT_DIR/screenshots/ios/${card_name}.png"
    android_ss="$REPORT_DIR/screenshots/android/${card_name}.png"

    $IOS_BUILD_OK && ios_screenshot "$ios_ss" &
    $ANDROID_BUILD_OK && android_screenshot "$android_ss" &
    wait

    # --- Classify results ---
    ios_status="-"
    android_status="-"
    ios_sz="0"
    android_sz="0"
    notes=""

    if $IOS_BUILD_OK; then
        ios_sz=$(file_size "$ios_ss")
        if ! ios_is_running; then
            ios_status="CRASH"
            ios_fail=$((ios_fail + 1))
            failed_cards_ios+=("$card_path")
        else
            ios_status=$(classify "$ios_sz" "ios")
            case "$ios_status" in
                PASS) ios_pass=$((ios_pass + 1)) ;;
                WARN) ios_warn=$((ios_warn + 1)) ;;
                FAIL) ios_fail=$((ios_fail + 1)); failed_cards_ios+=("$card_path") ;;
            esac
        fi
    fi

    if $ANDROID_BUILD_OK; then
        android_sz=$(file_size "$android_ss")
        if ! android_is_running; then
            android_status="CRASH"
            android_fail=$((android_fail + 1))
            failed_cards_android+=("$card_path")
        else
            android_status=$(classify "$android_sz" "android")
            case "$android_status" in
                PASS) android_pass=$((android_pass + 1)) ;;
                WARN) android_warn=$((android_warn + 1)) ;;
                FAIL) android_fail=$((android_fail + 1)); failed_cards_android+=("$card_path") ;;
            esac
        fi
    fi

    # --- Stuck-on-gallery detection (hash-based) ---
    if $IOS_BUILD_OK && [ -f "$ios_ss" ]; then
        ios_hash=$(md5 -q "$ios_ss" 2>/dev/null || md5sum "$ios_ss" 2>/dev/null | awk '{print $1}')
        if [ "$ios_hash" = "$ios_prev_hash" ]; then
            ios_stuck_count=$((ios_stuck_count + 1))
        else
            ios_stuck_count=0
        fi
        ios_prev_hash="$ios_hash"
        if [ "$ios_stuck_count" -ge "$STUCK_THRESHOLD" ]; then
            if [ "$ios_stuck_count" -eq "$STUCK_THRESHOLD" ]; then
                notes="iOS STUCK (deep link not navigating since card #$((idx - STUCK_THRESHOLD)))"
            fi
            ios_status="STUCK"
        fi
    fi

    if $ANDROID_BUILD_OK && [ -f "$android_ss" ]; then
        android_hash=$(md5 -q "$android_ss" 2>/dev/null || md5sum "$android_ss" 2>/dev/null | awk '{print $1}')
        if [ "$android_hash" = "$android_prev_hash" ]; then
            android_stuck_count=$((android_stuck_count + 1))
        else
            android_stuck_count=0
        fi
        android_prev_hash="$android_hash"
        if [ "$android_stuck_count" -ge "$STUCK_THRESHOLD" ]; then
            if [ "$android_stuck_count" -eq "$STUCK_THRESHOLD" ]; then
                notes="Android STUCK (deep link not navigating since card #$((idx - STUCK_THRESHOLD)))"
            fi
            android_status="STUCK"
        fi
    fi

    # Parity check: use image comparison when both screenshots exist
    parity_diff=""
    if [ "$ios_status" != "-" ] && [ "$android_status" != "-" ]; then
        if [ "$ios_status" = "CRASH" ] || [ "$android_status" = "CRASH" ]; then
            notes="PARITY MISMATCH (crash)"
        elif [ -f "$ios_ss" ] && [ -f "$android_ss" ] && [ "$ios_sz" -gt 5000 ] && [ "$android_sz" -gt 5000 ]; then
            # Use pixel-level image comparison instead of file-size heuristic
            compare_result=$(python3 "$REPO_ROOT/shared/scripts/compare-screenshots.py" "$ios_ss" "$android_ss" --threshold 0.20 2>/dev/null || echo '{"diff": -1, "status": "ERROR"}')
            parity_diff=$(echo "$compare_result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f\"{d['diff']*100:.1f}%\")" 2>/dev/null || echo "?")
            compare_status=$(echo "$compare_result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','ERROR'))" 2>/dev/null || echo "ERROR")
            if [ "$compare_status" = "MISMATCH" ]; then
                notes="PARITY MISMATCH (diff: $parity_diff)"
            fi
        elif [ "$ios_status" != "$android_status" ]; then
            notes="PARITY MISMATCH"
        fi
    fi

    # Status symbols for terminal
    ios_sym="—"
    android_sym="—"
    case "$ios_status" in
        PASS) ios_sym="✅" ;; WARN) ios_sym="⚠️ " ;; FAIL) ios_sym="❌" ;; CRASH) ios_sym="💥" ;; STUCK) ios_sym="🔒" ;;
    esac
    case "$android_status" in
        PASS) android_sym="✅" ;; WARN) android_sym="⚠️ " ;; FAIL) android_sym="❌" ;; CRASH) android_sym="💥" ;; STUCK) android_sym="🔒" ;;
    esac

    parity_info=""
    [ -n "$parity_diff" ] && [ "$parity_diff" != "?" ] && parity_info=" [${parity_diff}]"
    echo "  🍎${ios_sym} 🤖${android_sym}${parity_info}  ${notes}"

    # Write to report
    echo "| $idx | $card_name | $ios_status | $android_status | ${ios_sz}B | ${android_sz}B | ${parity_diff:-—} | $notes |" >> "$REPORT_FILE"

    # --- Return both to gallery simultaneously ---
    $IOS_BUILD_OK && ios_is_running && ios_gallery &
    $ANDROID_BUILD_OK && android_is_running && android_gallery &
    wait
    sleep 0.5
done

echo ""

# =============================================================================
# First-pass summary
# =============================================================================
ios_total=$((ios_pass + ios_warn + ios_fail))
android_total=$((android_pass + android_warn + android_fail))

echo "━━━ First Pass Results ━━━"
echo ""
$IOS_BUILD_OK     && echo "  🍎 iOS:     $ios_total tested | $ios_pass pass | $ios_warn warn | $ios_fail fail"
$ANDROID_BUILD_OK && echo "  🤖 Android: $android_total tested | $android_pass pass | $android_warn warn | $android_fail fail"
echo ""

cat >> "$REPORT_FILE" << EOF

**iOS:**     $ios_total tested | $ios_pass pass | $ios_warn warn | $ios_fail fail
**Android:** $android_total tested | $android_pass pass | $android_warn warn | $android_fail fail

EOF

# =============================================================================
# Retry failed cards (lock-step)
# =============================================================================
# Merge unique failed cards from both platforms
all_failed=()
for c in "${failed_cards_ios[@]+"${failed_cards_ios[@]}"}" "${failed_cards_android[@]+"${failed_cards_android[@]}"}"; do
    [ -z "$c" ] && continue
    local_dup=false
    for existing in "${all_failed[@]+"${all_failed[@]}"}"; do
        [ "$existing" = "$c" ] && local_dup=true && break
    done
    $local_dup || all_failed+=("$c")
done

if [ ${#all_failed[@]} -gt 0 ] && [ "$MAX_RETRIES" -gt 0 ]; then
    echo "━━━ Retry Phase (${#all_failed[@]} cards, up to $MAX_RETRIES retries) ━━━"
    echo "" >> "$REPORT_FILE"
    echo "## Retry Phase" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "| Card | Retry | iOS | Android | Notes |" >> "$REPORT_FILE"
    echo "|------|-------|-----|---------|-------|" >> "$REPORT_FILE"

    for retry in $(seq 1 "$MAX_RETRIES"); do
        echo ""
        echo "  Retry $retry/$MAX_RETRIES — restarting apps..."
        $IOS_BUILD_OK && ios_restart &
        $ANDROID_BUILD_OK && android_restart &
        wait

        next_failed=()

        # Take gallery baseline screenshots to detect "bounced back to gallery" vs "rendered card"
        sleep 2
        ios_gallery_baseline="$REPORT_DIR/screenshots/ios/_gallery_baseline_r${retry}.png"
        android_gallery_baseline="$REPORT_DIR/screenshots/android/_gallery_baseline_r${retry}.png"
        $IOS_BUILD_OK && ios_screenshot "$ios_gallery_baseline" &
        $ANDROID_BUILD_OK && android_screenshot "$android_gallery_baseline" &
        wait
        ios_gallery_hash=""
        android_gallery_hash=""
        [ -f "$ios_gallery_baseline" ] && ios_gallery_hash=$(md5 -q "$ios_gallery_baseline" 2>/dev/null || md5sum "$ios_gallery_baseline" 2>/dev/null | awk '{print $1}')
        [ -f "$android_gallery_baseline" ] && android_gallery_hash=$(md5 -q "$android_gallery_baseline" 2>/dev/null || md5sum "$android_gallery_baseline" 2>/dev/null | awk '{print $1}')

        for card_path in "${all_failed[@]}"; do
            card_name=$(basename "$card_path")

            # Ensure apps alive before navigating
            if $IOS_BUILD_OK && ! ios_is_running; then
                ios_restart
                for _w in $(seq 1 10); do ios_is_running && break; sleep 0.5; done
            fi
            if $ANDROID_BUILD_OK && ! android_is_running; then
                android_restart
                for _w in $(seq 1 10); do android_is_running && break; sleep 0.5; done
            fi

            # Navigate both
            $IOS_BUILD_OK && ios_navigate "$card_path" &
            $ANDROID_BUILD_OK && android_navigate "$card_path" &
            wait
            sleep "$RENDER_WAIT"

            # Screenshot both
            ios_ss="$REPORT_DIR/screenshots/ios/${card_name}-retry${retry}.png"
            android_ss="$REPORT_DIR/screenshots/android/${card_name}-retry${retry}.png"
            $IOS_BUILD_OK && ios_screenshot "$ios_ss" &
            $ANDROID_BUILD_OK && android_screenshot "$android_ss" &
            wait

            ios_retry_st="-"
            android_retry_st="-"
            still_failing=false
            retry_notes=""

            if $IOS_BUILD_OK; then
                if ! ios_is_running; then
                    ios_retry_st="CRASH"
                    still_failing=true
                    retry_notes="iOS crash"
                else
                    local_sz=$(file_size "$ios_ss")
                    ios_retry_st=$(classify "$local_sz" "ios")
                    # Check if screenshot matches gallery (card didn't actually render)
                    if [ -f "$ios_ss" ] && [ -n "$ios_gallery_hash" ]; then
                        local_hash=$(md5 -q "$ios_ss" 2>/dev/null || md5sum "$ios_ss" 2>/dev/null | awk '{print $1}')
                        if [ "$local_hash" = "$ios_gallery_hash" ]; then
                            ios_retry_st="FAIL"
                            still_failing=true
                            retry_notes="iOS shows gallery (deep link failed)"
                        fi
                    fi
                    [ "$ios_retry_st" = "FAIL" ] && still_failing=true
                fi
            fi

            if $ANDROID_BUILD_OK; then
                if ! android_is_running; then
                    android_retry_st="CRASH"
                    still_failing=true
                    retry_notes="${retry_notes:+$retry_notes; }Android crash"
                else
                    local_sz=$(file_size "$android_ss")
                    android_retry_st=$(classify "$local_sz" "android")
                    # Check if screenshot matches gallery (card didn't actually render)
                    if [ -f "$android_ss" ] && [ -n "$android_gallery_hash" ]; then
                        local_hash=$(md5 -q "$android_ss" 2>/dev/null || md5sum "$android_ss" 2>/dev/null | awk '{print $1}')
                        if [ "$local_hash" = "$android_gallery_hash" ]; then
                            android_retry_st="FAIL"
                            still_failing=true
                            retry_notes="${retry_notes:+$retry_notes; }Android shows gallery (deep link failed)"
                        fi
                    fi
                    [ "$android_retry_st" = "FAIL" ] && still_failing=true
                fi
            fi

            if $still_failing; then
                next_failed+=("$card_path")
                echo "    ❌ $card_name — still failing${retry_notes:+ ($retry_notes)}"
            else
                echo "    ✅ $card_name — recovered"
            fi

            echo "| $card_name | $retry | $ios_retry_st | $android_retry_st | $retry_notes |" >> "$REPORT_FILE"

            # Gallery
            $IOS_BUILD_OK && ios_is_running && ios_gallery &
            $ANDROID_BUILD_OK && android_is_running && android_gallery &
            wait
            sleep 1
        done

        all_failed=("${next_failed[@]+"${next_failed[@]}"}")
        [ ${#all_failed[@]} -eq 0 ] && echo "  All cards recovered!" && break
    done
    echo "" >> "$REPORT_FILE"
fi

# =============================================================================
# Cross-Platform Parity Summary
# =============================================================================
echo "" >> "$REPORT_FILE"
echo "## Cross-Platform Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| Platform | Pass | Warn | Fail |" >> "$REPORT_FILE"
echo "|----------|------|------|------|" >> "$REPORT_FILE"
echo "| iOS      | $ios_pass | $ios_warn | $ios_fail |" >> "$REPORT_FILE"
echo "| Android  | $android_pass | $android_warn | $android_fail |" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "## Artifacts" >> "$REPORT_FILE"
echo "- Report: \`$REPORT_FILE\`" >> "$REPORT_FILE"
echo "- iOS screenshots: \`$REPORT_DIR/screenshots/ios/\`" >> "$REPORT_FILE"
echo "- Android screenshots: \`$REPORT_DIR/screenshots/android/\`" >> "$REPORT_FILE"

echo ""
echo "━━━ Done ━━━"
echo ""
echo "  Report:              $REPORT_FILE"
echo "  iOS screenshots:     $REPORT_DIR/screenshots/ios/"
echo "  Android screenshots: $REPORT_DIR/screenshots/android/"
echo ""
