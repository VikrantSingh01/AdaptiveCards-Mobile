#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.

# =============================================================================
# Design Review Loop — Automated Visual Parity Testing + AI-Driven Fixes
# =============================================================================
#
# Automated loop that:
#   1. Captures screenshots of all cards on iOS + Android (design-pass.sh)
#   2. Deploys the HTML catalog to GitHub Pages for team review (deploy-catalog.sh)
#   3. Runs AI-powered design review via Claude Code (reads screenshots)
#   4. Generates a structured DESIGN_REVIEW_REPORT.md with P0/P1/P2 issues
#   5. Spawns up to N parallel Claude Code agents in git worktrees to fix issues (--max-agents)
#   6. Merges fixes and loops back to step 1
#   7. Stops when P1=0 and P2=0, or max iterations reached
#
# Usage:
#   bash shared/scripts/design-review-loop.sh                    # default: 5 iterations
#   bash shared/scripts/design-review-loop.sh --max-iterations 3 # custom limit
#   bash shared/scripts/design-review-loop.sh --skip-capture     # skip step 1 (reuse latest catalog)
#   bash shared/scripts/design-review-loop.sh --skip-review      # skip step 2 (reuse existing report)
#   bash shared/scripts/design-review-loop.sh --fix-only         # skip steps 1+2, jump to fixes
#   bash shared/scripts/design-review-loop.sh --review-only      # only run steps 1+2, no fixes
#   bash shared/scripts/design-review-loop.sh --wait 5           # custom render wait (seconds)
#   bash shared/scripts/design-review-loop.sh --model opus       # model for review/fix agents
#   bash shared/scripts/design-review-loop.sh --max-agents 5    # max parallel fix agents (default: 5)
#
# Prerequisites:
#   - iOS Simulator "iPhone 16 Pro" booted
#   - Android emulator running (or device connected)
#   - Claude Code CLI installed (`claude` in PATH)
#
# Output (stable top-level paths):
#   shared/test-results/index.html                      — latest design catalog HTML
#   shared/test-results/DESIGN_REVIEW_PROMPT.md         — review prompt template
#   shared/test-results/DESIGN_REVIEW_REPORT.md         — latest consolidated report
#
# Output (timestamped per-run):
#   shared/test-results/design-catalog-<TIMESTAMP>/     — screenshots + HTML catalog
#   shared/test-results/design-review-loop-<TIMESTAMP>/ — loop artifacts + agent logs
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Loop output directory
LOOP_DIR="$REPO_ROOT/shared/test-results/design-review-loop-$TIMESTAMP"
mkdir -p "$LOOP_DIR"
LOOP_LOG="$LOOP_DIR/loop.log"

# Prompt and report locations
PROMPT_FILE="$REPO_ROOT/shared/test-results/DESIGN_REVIEW_PROMPT.md"
REPORT_FILE="$REPO_ROOT/shared/test-results/DESIGN_REVIEW_REPORT.md"
LEARNINGS_FILE="$REPO_ROOT/shared/test-results/DESIGN_REVIEW_LEARNINGS.md"
ISSUES_FILE="$LOOP_DIR/issues.json"

# Defaults
MAX_ITERATIONS=5
SKIP_CAPTURE=false
SKIP_REVIEW=false
FIX_ONLY=false
REVIEW_ONLY=false
RENDER_WAIT=4
MODEL="opus"
EXIT_ON_P2=false
MAX_AGENTS=5

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --max-iterations) MAX_ITERATIONS="$2"; shift 2 ;;
        --skip-capture)   SKIP_CAPTURE=true; shift ;;
        --skip-review)    SKIP_REVIEW=true; shift ;;
        --fix-only)       FIX_ONLY=true; SKIP_CAPTURE=true; SKIP_REVIEW=true; shift ;;
        --review-only)    REVIEW_ONLY=true; shift ;;
        --wait)           RENDER_WAIT="$2"; shift 2 ;;
        --model)          MODEL="$2"; shift 2 ;;
        --exit-on-p2)     EXIT_ON_P2=true; shift ;;
        --max-agents)     MAX_AGENTS="$2"; shift 2 ;;
        -h|--help)
            sed -n '/^# Usage:/,/^# ===/{/^# ===/d;s/^# //;p}' "$0"
            exit 0 ;;
        *)                echo "Unknown arg: $1 (use --help for usage)"; exit 1 ;;
    esac
done

# =============================================================================
# Logging
# =============================================================================
log() {
    local msg="[$(date '+%H:%M:%S')] $1"
    echo "$msg" | tee -a "$LOOP_LOG"
}

log_section() {
    echo "" | tee -a "$LOOP_LOG"
    echo "==============================================================" | tee -a "$LOOP_LOG"
    log "$1"
    echo "==============================================================" | tee -a "$LOOP_LOG"
}

# =============================================================================
# Pre-flight Checks
# =============================================================================
log_section "Design Review Loop — Pre-flight Checks"

# Check Claude CLI
if ! command -v claude &>/dev/null; then
    log "ERROR: Claude Code CLI not found. Install from https://claude.com/download"
    exit 1
fi
# Unset CLAUDECODE to allow spawning sub-agents from within a Claude Code session
unset CLAUDECODE 2>/dev/null || true
CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
log "Claude Code: $CLAUDE_VERSION"

# iOS check
IOS_SIMULATOR="iPhone 16 Pro"
SIM_UDID=$(xcrun simctl list devices available 2>/dev/null | grep "$IOS_SIMULATOR" | grep -oE '[A-F0-9-]{36}' | head -1 || true)
IOS_READY=false
if [ -n "$SIM_UDID" ]; then
    SIM_STATE=$(xcrun simctl list devices 2>/dev/null | grep "$SIM_UDID" | grep -oE '\(Booted\)' || true)
    [ -n "$SIM_STATE" ] && IOS_READY=true
fi

# Android check
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

if [ "$IOS_READY" = true ]; then
    log "iOS Simulator: $IOS_SIMULATOR (Booted) — $SIM_UDID"
else
    log "WARNING: iOS Simulator not booted. Screenshot capture will skip iOS."
fi

if [ "$ANDROID_READY" = true ]; then
    log "Android: emulator connected"
else
    log "WARNING: Android emulator not connected. Screenshot capture will skip Android."
fi

log "Max iterations: $MAX_ITERATIONS"
log "Model: $MODEL"
log "Loop artifacts: $LOOP_DIR"

# =============================================================================
# Tracking
# =============================================================================
CATALOG_DIR=""
P1_COUNT=999
P2_COUNT=999
P3_COUNT=0
P4_COUNT=0
P5_COUNT=0
PREV_TOTAL_ISSUES=999
LAST_ITERATION=0

# =============================================================================
# Find Latest Catalog (for --skip-capture or --fix-only)
# =============================================================================
find_latest_catalog() {
    ls -dt "$REPO_ROOT/shared/test-results/design-catalog-"* 2>/dev/null | head -1 || true
}

# =============================================================================
# Phase 1: Screenshot Capture + Deploy
# =============================================================================
run_capture() {
    local iteration=$1
    log_section "Iteration $iteration — Phase 1: Screenshot Capture + Deploy"

    if [ "$SKIP_CAPTURE" = true ]; then
        CATALOG_DIR=$(find_latest_catalog)
        if [ -z "$CATALOG_DIR" ]; then
            log "ERROR: --skip-capture set but no existing catalog found"
            exit 1
        fi
        log "Reusing existing catalog: $(basename "$CATALOG_DIR")"
        # Only skip on first iteration; subsequent iterations always capture
        SKIP_CAPTURE=false
        return 0
    fi

    local capture_log="$LOOP_DIR/capture-iteration-$iteration.log"
    local capture_args="--wait $RENDER_WAIT"

    # On iteration 2+, build a cards-file from the previous iteration's worklists
    # to only re-capture cards that were in fix worklists (incremental capture)
    if [ "$iteration" -gt 1 ]; then
        local prev_iter=$((iteration - 1))
        local cards_file="$LOOP_DIR/recapture-cards-$iteration.txt"
        : > "$cards_file"

        # Extract card names from all worklists of the previous iteration
        # Glob for all worklist files (p1, p2-1, p2-2, p2-3, p3, etc.)
        for worklist in "$LOOP_DIR"/worklist-*-iteration-${prev_iter}.json; do
            [ -f "$worklist" ] || continue
            python3 -c "
import json
with open('$worklist') as f:
    data = json.load(f)
for issue in data.get('issues', []):
    card = issue.get('card', '')
    if card:
        print(card)
" >> "$cards_file" 2>/dev/null || true
        done

        # Deduplicate
        if [ -s "$cards_file" ]; then
            sort -u "$cards_file" -o "$cards_file"
            local card_count
            card_count=$(wc -l < "$cards_file" | tr -d '[:space:]')
            log "Incremental capture: $card_count cards from previous fix worklists"
            capture_args="$capture_args --cards-file $cards_file --fast"

            # Copy previous catalog screenshots as base, then overlay with new captures
            local prev_catalog
            prev_catalog=$(find_latest_catalog)
            if [ -n "$prev_catalog" ] && [ -d "$prev_catalog/screenshots" ]; then
                log "Copying previous screenshots as baseline..."
                # design-pass.sh creates a new timestamped dir; we pre-populate it
                # by letting it run normally — the new screenshots overwrite the old ones
            fi
        else
            log "No cards to recapture — running full capture."
            rm -f "$cards_file"
        fi
    else
        log "Running full design-pass.sh..."
    fi

    log "Capture args: $capture_args"
    if bash "$SCRIPT_DIR/design-pass.sh" $capture_args > "$capture_log" 2>&1; then
        CATALOG_DIR=$(find_latest_catalog)
        log "Capture complete: $(basename "$CATALOG_DIR")"
    else
        log "WARNING: design-pass.sh exited with errors. Check $capture_log"
        CATALOG_DIR=$(find_latest_catalog)
        [ -z "$CATALOG_DIR" ] && { log "ERROR: No catalog produced"; exit 1; }
    fi

    # For incremental captures, copy missing screenshots from the previous catalog
    if [ "$iteration" -gt 1 ]; then
        local prev_catalogs
        prev_catalogs=$(ls -dt "$REPO_ROOT/shared/test-results/design-catalog-"* 2>/dev/null | head -2 | tail -1)
        if [ -n "$prev_catalogs" ] && [ "$prev_catalogs" != "$CATALOG_DIR" ]; then
            for platform in ios android; do
                local src_dir="$prev_catalogs/screenshots/$platform"
                local dst_dir="$CATALOG_DIR/screenshots/$platform"
                [ -d "$src_dir" ] || continue
                for png in "$src_dir"/*.png; do
                    [ -f "$png" ] || continue
                    local fname
                    fname=$(basename "$png")
                    # Only copy if not already captured in this iteration
                    if [ ! -f "$dst_dir/$fname" ]; then
                        cp "$png" "$dst_dir/$fname"
                    fi
                done
            done
            log "Backfilled missing screenshots from previous catalog."
        fi
    fi

    # Deploy catalog to GitHub Pages — disabled for now
    # local fail_count
    # fail_count=$(grep -oP '\d+ failed' "$capture_log" 2>/dev/null | grep -oP '\d+' || echo "0")
    # if [ "$fail_count" -ge 10 ]; then
    #     log "SKIPPING GitHub Pages deploy: $fail_count card failures (threshold: 10)"
    # else
    #     log "Deploying catalog to GitHub Pages ($fail_count failures, under threshold)..."
    #     local deploy_log="$LOOP_DIR/deploy-iteration-$iteration.log"
    #     if bash "$SCRIPT_DIR/deploy-catalog.sh" "$CATALOG_DIR" > "$deploy_log" 2>&1; then
    #         log "Catalog deployed to GitHub Pages."
    #     else
    #         log "WARNING: deploy-catalog.sh failed. Check $deploy_log"
    #     fi
    # fi
    log "GitHub Pages deploy skipped (disabled)."
}

# =============================================================================
# Phase 1.5: OCR Pre-Scan (deterministic issue detection)
# =============================================================================
OCR_PRESCAN_FILE=""

run_ocr_prescan() {
    local iteration=$1
    log_section "Iteration $iteration — Phase 1.5: OCR Pre-Scan"

    if [ -z "$CATALOG_DIR" ] || [ ! -d "$CATALOG_DIR/screenshots" ]; then
        log "No screenshots directory — skipping OCR pre-scan."
        return 0
    fi

    # Source the OCR helper
    source "$SCRIPT_DIR/check-screenshot-text.sh"

    OCR_PRESCAN_FILE="$LOOP_DIR/ocr-prescan-iteration-$iteration.md"
    local ocr_fails=0
    local ocr_clean=0
    local ocr_skipped=0
    local empty_ios=0
    local empty_android=0

    echo "# OCR Pre-Scan Results (Iteration $iteration)" > "$OCR_PRESCAN_FILE"
    echo "" >> "$OCR_PRESCAN_FILE"
    echo "| Card | Platform | Issue | OCR Detail |" >> "$OCR_PRESCAN_FILE"
    echo "|---|---|---|---|" >> "$OCR_PRESCAN_FILE"

    # Scan iOS screenshots
    for screenshot in "$CATALOG_DIR/screenshots/ios/"*.png; do
        [ -f "$screenshot" ] || continue
        local card_name
        card_name=$(basename "$screenshot" .png)

        # Check file size — very small screenshots indicate blank/empty renders
        local size
        size=$(stat -f%z "$screenshot" 2>/dev/null || stat -c%s "$screenshot" 2>/dev/null || echo "0")
        if [ "$size" -lt 5000 ]; then
            echo "| $card_name | iOS | BLANK_RENDER | Screenshot ${size}B (< 5KB threshold) |" >> "$OCR_PRESCAN_FILE"
            empty_ios=$((empty_ios + 1))
            continue
        fi

        local ocr_result
        ocr_result=$(check_screenshot_text "$screenshot" || true)
        if [[ "$ocr_result" == TEMPLATE_FAIL* ]]; then
            echo "| $card_name | iOS | TEMPLATE_FAIL | ${ocr_result#TEMPLATE_FAIL: } |" >> "$OCR_PRESCAN_FILE"
            ocr_fails=$((ocr_fails + 1))
        else
            ocr_clean=$((ocr_clean + 1))
        fi
    done

    # Scan Android screenshots
    for screenshot in "$CATALOG_DIR/screenshots/android/"*.png; do
        [ -f "$screenshot" ] || continue
        local card_name
        card_name=$(basename "$screenshot" .png)

        local size
        size=$(stat -f%z "$screenshot" 2>/dev/null || stat -c%s "$screenshot" 2>/dev/null || echo "0")
        if [ "$size" -lt 5000 ]; then
            echo "| $card_name | Android | BLANK_RENDER | Screenshot ${size}B (< 5KB threshold) |" >> "$OCR_PRESCAN_FILE"
            empty_android=$((empty_android + 1))
            continue
        fi

        local ocr_result
        ocr_result=$(check_screenshot_text "$screenshot" || true)
        if [[ "$ocr_result" == TEMPLATE_FAIL* ]]; then
            echo "| $card_name | Android | TEMPLATE_FAIL | ${ocr_result#TEMPLATE_FAIL: } |" >> "$OCR_PRESCAN_FILE"
            ocr_fails=$((ocr_fails + 1))
        else
            ocr_clean=$((ocr_clean + 1))
        fi
    done

    # Also detect missing screenshots (iOS exists but Android doesn't, or vice versa)
    local missing=0
    for screenshot in "$CATALOG_DIR/screenshots/ios/"*.png; do
        local card_name
        card_name=$(basename "$screenshot" .png)
        if [ ! -f "$CATALOG_DIR/screenshots/android/$card_name.png" ]; then
            echo "| $card_name | Android | MISSING_SCREENSHOT | No Android screenshot found |" >> "$OCR_PRESCAN_FILE"
            missing=$((missing + 1))
        fi
    done
    for screenshot in "$CATALOG_DIR/screenshots/android/"*.png; do
        local card_name
        card_name=$(basename "$screenshot" .png)
        if [ ! -f "$CATALOG_DIR/screenshots/ios/$card_name.png" ]; then
            echo "| $card_name | iOS | MISSING_SCREENSHOT | No iOS screenshot found |" >> "$OCR_PRESCAN_FILE"
            missing=$((missing + 1))
        fi
    done

    # Phase 1.5b: Pixel-diff pre-filter — compare iOS vs Android screenshot file sizes
    # Cards where both screenshots are similar size (within 15%) are likely identical renders.
    # Cards with large size differences are worth AI review.
    local diff_flagged=0
    local diff_similar=0
    echo "" >> "$OCR_PRESCAN_FILE"
    echo "## Size-Diff Pre-Filter" >> "$OCR_PRESCAN_FILE"
    echo "" >> "$OCR_PRESCAN_FILE"
    echo "Cards with >15% screenshot size difference between iOS and Android (likely visual differences):" >> "$OCR_PRESCAN_FILE"
    echo "" >> "$OCR_PRESCAN_FILE"

    DIFF_FLAGGED_CARDS="$LOOP_DIR/diff-flagged-cards-$iteration.txt"
    : > "$DIFF_FLAGGED_CARDS"

    for ios_screenshot in "$CATALOG_DIR/screenshots/ios/"*.png; do
        [ -f "$ios_screenshot" ] || continue
        local card_name
        card_name=$(basename "$ios_screenshot" .png)
        local android_screenshot="$CATALOG_DIR/screenshots/android/$card_name.png"
        [ -f "$android_screenshot" ] || continue

        local ios_size android_size
        ios_size=$(stat -f%z "$ios_screenshot" 2>/dev/null || stat -c%s "$ios_screenshot" 2>/dev/null || echo "0")
        android_size=$(stat -f%z "$android_screenshot" 2>/dev/null || stat -c%s "$android_screenshot" 2>/dev/null || echo "0")

        # Skip if either is blank (already caught above)
        if [ "$ios_size" -lt 5000 ] || [ "$android_size" -lt 5000 ]; then
            continue
        fi

        # Calculate size ratio — larger/smaller
        local ratio
        if [ "$ios_size" -ge "$android_size" ] && [ "$android_size" -gt 0 ]; then
            ratio=$((ios_size * 100 / android_size))
        elif [ "$android_size" -gt 0 ]; then
            ratio=$((android_size * 100 / ios_size))
        else
            ratio=999
        fi

        # Flag cards with >15% size difference (ratio > 115)
        if [ "$ratio" -gt 115 ]; then
            echo "- $card_name (iOS: ${ios_size}B, Android: ${android_size}B, ratio: ${ratio}%)" >> "$OCR_PRESCAN_FILE"
            echo "$card_name" >> "$DIFF_FLAGGED_CARDS"
            diff_flagged=$((diff_flagged + 1))
        else
            diff_similar=$((diff_similar + 1))
        fi
    done

    log "OCR pre-scan: $ocr_fails template failures, $((empty_ios + empty_android)) blank renders, $missing missing screenshots, $ocr_clean clean"
    log "Size-diff filter: $diff_flagged cards flagged (>15% size diff), $diff_similar similar — AI can skip similar cards"
    log "Results written to: $OCR_PRESCAN_FILE"
}

# =============================================================================
# Phase 2: AI-Powered Design Review
# =============================================================================
run_review() {
    local iteration=$1
    log_section "Iteration $iteration — Phase 2: AI-Powered Design Review"

    if [ "$SKIP_REVIEW" = true ]; then
        if [ -f "$REPORT_FILE" ]; then
            log "Reusing existing report: $REPORT_FILE"
            # Only skip on first iteration
            SKIP_REVIEW=false
            return 0
        else
            log "ERROR: --skip-review set but no existing report found at $REPORT_FILE"
            exit 1
        fi
    fi

    local review_log="$LOOP_DIR/review-iteration-$iteration.log"
    local catalog_name
    catalog_name=$(basename "$CATALOG_DIR")
    local review_ts
    review_ts=$(date '+%Y-%m-%d %H:%M:%S')

    # Read the design review prompt from the canonical location
    if [ ! -f "$PROMPT_FILE" ]; then
        log "ERROR: Design review prompt not found at $PROMPT_FILE"
        return 1
    fi

    # Build the review prompt: base prompt from file + dynamic paths + issues.json output spec
    local review_prompt
    review_prompt=$(cat "$PROMPT_FILE")
    review_prompt="$review_prompt

---

## Additional Output: issues.json

In addition to the DESIGN_REVIEW_REPORT.md, also write a machine-parseable JSON file with this structure:

File path: $ISSUES_FILE

\`\`\`json
{
  \"catalog\": \"$catalog_name\",
  \"timestamp\": \"$review_ts\",
  \"total_cards\": 287,
  \"p0_count\": 0,
  \"p1_count\": 0,
  \"p2_count\": 0,
  \"p3_count\": 0,
  \"issues\": [
    {
      \"id\": 1,
      \"priority\": \"P0\",
      \"card\": \"card-name\",
      \"category\": \"Root\",
      \"platform\": \"android|ios|both\",
      \"type\": \"crash|render_fail|truncation|missing_feature|style_diff|layout_diff\",
      \"summary\": \"Short description\",
      \"ios_behavior\": \"What iOS shows\",
      \"android_behavior\": \"What Android shows\",
      \"affected_files\": [\"path/to/file1.kt\", \"path/to/file2.swift\"],
      \"reference_file\": \"path/to/working-platform-file.kt:30-50\",
      \"reference_pattern\": \"Brief description of what the working code does\",
      \"fix_hint\": \"Concrete fix: file:line — change property X from A to B\",
      \"verify_cards\": [\"card-deep-link-path\"],
      \"blocks\": [],
      \"status\": \"New|Confirmed|Regression|Stuck\",
      \"fix_confidence\": \"high|medium|low\"
    }
  ]
}
\`\`\`

## Key File Locations (for affected_files field)
- Android composables: android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/
- iOS views: ios/Sources/ACRendering/Views/
- Android models: android/ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/models/
- iOS models: ios/Sources/ACCore/Models/
- Date functions: ios/Sources/ACTemplating/Functions/DateFunctions.swift and android/ac-templating/src/main/kotlin/com/microsoft/adaptivecards/templating/functions/DateFunctions.kt
- Markdown: ios/Sources/ACMarkdown/ and android/ac-markdown/
- Actions: ios/Sources/ACActions/ and android/ac-actions/
- Sample app (Android): android/sample-app/src/main/kotlin/com/microsoft/adaptivecards/sample/

## Dynamic Paths
- Screenshots: $CATALOG_DIR/screenshots/ios/ and $CATALOG_DIR/screenshots/android/
- HTML catalog: $CATALOG_DIR/index.html
- Write report to: $REPORT_FILE
- Write issues.json to: $ISSUES_FILE
- Use catalog name: $catalog_name
- Use timestamp: $review_ts
- Learnings file: $LEARNINGS_FILE"

    # Inject OCR pre-scan results if available
    if [ -n "${OCR_PRESCAN_FILE:-}" ] && [ -f "$OCR_PRESCAN_FILE" ]; then
        review_prompt="$review_prompt

---

## OCR Pre-Scan Results (Deterministic)

The following issues were detected programmatically via OCR before your visual review. These are **confirmed issues** — do not re-verify them visually, just include them in the report with appropriate severity:

- TEMPLATE_FAIL = unresolved \${expression} or curly brackets in rendered text → **P0** (template engine failure)
- BLANK_RENDER = screenshot < 5KB, card rendered empty/blank → **P0** (render failure)
- MISSING_SCREENSHOT = one platform has a screenshot but the other doesn't → **P1** (card failed to load on one platform)

$(cat "$OCR_PRESCAN_FILE")

Focus your visual review time on cards NOT flagged by OCR — that's where subtle P1/P2/P3 issues hide."
    fi

    # Inject size-diff flagged cards list if available
    local diff_file="$LOOP_DIR/diff-flagged-cards-$iteration.txt"
    if [ -f "$diff_file" ] && [ -s "$diff_file" ]; then
        local flagged_count
        flagged_count=$(wc -l < "$diff_file" | tr -d '[:space:]')
        review_prompt="$review_prompt

---

## Screenshot Size-Diff Priority List

These $flagged_count cards have >15% file size difference between iOS and Android screenshots, indicating likely visual differences. **Review these cards first** — they are most likely to have real issues:

$(cat "$diff_file" | sed 's/^/- /')

Cards NOT on this list had similar screenshot sizes on both platforms. You can do a quick scan of those but spend less time on them — they are likely fine."
    fi

    log "Launching Claude review agent (model: $MODEL)..."
    log "Using prompt from: $PROMPT_FILE"
    echo "$review_prompt" > "$LOOP_DIR/review-prompt-$iteration.md"

    # Run Claude in print mode for automation
    if claude -p "$review_prompt" \
        --model "$MODEL" \
        --allow-dangerously-skip-permissions \
        --dangerously-skip-permissions \
        --allowed-tools "Read,Glob,Grep,Write,Edit" \
        --no-session-persistence \
        > "$review_log" 2>&1; then
        log "Review complete."
    else
        log "WARNING: Review agent exited with errors. Check $review_log"
    fi

    # Verify outputs exist
    if [ -f "$REPORT_FILE" ]; then
        local issue_count
        issue_count=$(grep -c "^### " "$REPORT_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
        log "Report generated: $REPORT_FILE ($issue_count issue sections)"
    else
        log "WARNING: Report not generated at $REPORT_FILE"
    fi

    if [ -f "$ISSUES_FILE" ]; then
        log "Issues JSON generated: $ISSUES_FILE"
    else
        log "WARNING: issues.json not generated — will fall back to markdown parsing"
    fi
}

# =============================================================================
# Phase 3: Parse Issues & Triage
# =============================================================================
parse_issues() {
    local iteration=$1
    log_section "Iteration $iteration — Phase 3: Triage Issues"

    # Save previous values for stall detection
    PREV_TOTAL_ISSUES=$((P1_COUNT + P2_COUNT + P3_COUNT + P4_COUNT + P5_COUNT))
    PREV_P1=$P1_COUNT
    PREV_P2=$P2_COUNT
    PREV_P3=$P3_COUNT

    # Helper to read priority count from issues.json
    read_counts_from_json() {
        P1_COUNT=$(python3 -c "import json; d=json.load(open('$ISSUES_FILE')); print(d.get('p1_count', 0))" 2>/dev/null | tr -d '[:space:]' || echo "0")
        P2_COUNT=$(python3 -c "import json; d=json.load(open('$ISSUES_FILE')); print(d.get('p2_count', 0))" 2>/dev/null | tr -d '[:space:]' || echo "0")
        P3_COUNT=$(python3 -c "import json; d=json.load(open('$ISSUES_FILE')); print(d.get('p3_count', 0))" 2>/dev/null | tr -d '[:space:]' || echo "0")
        P4_COUNT=$(python3 -c "import json; d=json.load(open('$ISSUES_FILE')); print(d.get('p4_count', 0))" 2>/dev/null | tr -d '[:space:]' || echo "0")
        P5_COUNT=$(python3 -c "import json; d=json.load(open('$ISSUES_FILE')); print(d.get('p5_count', 0))" 2>/dev/null | tr -d '[:space:]' || echo "0")
        TOTAL_ISSUES=$((P1_COUNT + P2_COUNT + P3_COUNT + P4_COUNT + P5_COUNT))
    }

    # If issues.json exists (from review agent), parse it
    if [ -f "$ISSUES_FILE" ]; then
        read_counts_from_json
        log "Issues found: P1=$P1_COUNT  P2=$P2_COUNT  P3=$P3_COUNT  P4=$P4_COUNT  P5=$P5_COUNT  Total=$TOTAL_ISSUES"
    elif [ -f "$REPORT_FILE" ]; then
        # Fallback: count from markdown summary table (| # | **P1** | ... rows)
        P1_COUNT=$(grep -c '| \*\*P1\*\* |' "$REPORT_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
        P2_COUNT=$(grep -c '| \*\*P2\*\* |' "$REPORT_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
        P3_COUNT=$(grep -c '| \*\*P3\*\* |' "$REPORT_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
        P4_COUNT=$(grep -c '| \*\*P4\*\* |' "$REPORT_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
        P5_COUNT=$(grep -c '| \*\*P5\*\* |' "$REPORT_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
        TOTAL_ISSUES=$((P1_COUNT + P2_COUNT + P3_COUNT + P4_COUNT + P5_COUNT))
        log "Issues (from markdown table): P1=$P1_COUNT  P2=$P2_COUNT  P3=$P3_COUNT  P4=$P4_COUNT  P5=$P5_COUNT  Total=$TOTAL_ISSUES"
        log "WARNING: issues.json not found — using markdown table grep (less reliable)"

        # Generate issues.json from report for triage to work
        generate_issues_json_from_report "$iteration"

        # Re-read counts from generated issues.json (more accurate than markdown grep)
        if [ -f "$ISSUES_FILE" ]; then
            read_counts_from_json
            log "Updated counts from issues.json: P1=$P1_COUNT  P2=$P2_COUNT  P3=$P3_COUNT  P4=$P4_COUNT  P5=$P5_COUNT  Total=$TOTAL_ISSUES"
        fi
    else
        log "ERROR: No report or issues.json found. Cannot triage."
        P1_COUNT=0; P2_COUNT=0; P3_COUNT=0; P4_COUNT=0; P5_COUNT=0; TOTAL_ISSUES=0
        return 1
    fi

    # Partition issues into P1-P5 worklists with file-level conflict detection
    if [ -f "$ISSUES_FILE" ]; then
        export ISSUES_FILE LOOP_DIR MAX_AGENTS
        ITERATION="$iteration" python3 << 'PARTITION_EOF'
import json, sys, os

issues_file = os.environ["ISSUES_FILE"]
loop_dir = os.environ["LOOP_DIR"]
iteration = os.environ.get("ITERATION", "1")

with open(issues_file) as f:
    data = json.load(f)

issues = data.get("issues", [])

# Partition by priority, sort by fix_confidence (high first)
confidence_order = {"high": 0, "medium": 1, "low": 2}
worklists = {"P1": [], "P2": [], "P3": [], "P4": [], "P5": []}
for issue in issues:
    p = issue.get("priority", "P3")
    if p in worklists:
        worklists[p].append(issue)
    # Issues outside P1-P5 (e.g., info-only) are not assigned to fix agents

# Sort each worklist: dependency order first, then high confidence
# "blocks" field means "this issue blocks issue X" — so issues with blocks entries go first
for p in worklists:
    # Collect IDs that are blocked by something (appear in another issue's blocks list)
    blocked_ids = set()
    for item in worklists[p]:
        for bid in item.get("blocks", []):
            blocked_ids.add(bid)

    def sort_key(item, _blocked=blocked_ids):
        item_id = item.get("id", 999)
        has_blocks = len(item.get("blocks", [])) > 0  # This issue blocks others
        is_blocked = item_id in _blocked  # This issue is blocked by another
        # 0 = blocks others (do first), 1 = independent, 2 = is blocked (do last)
        if has_blocks:
            order = 0
        elif is_blocked:
            order = 2
        else:
            order = 1
        conf = confidence_order.get(item.get("fix_confidence", "medium"), 1)
        return (order, conf)

    worklists[p].sort(key=sort_key)

# Compute file ownership — higher priority (lower number) wins conflicts
# Process P1 first, then P2, P3, P4, P5
priority_order = ["P1", "P2", "P3", "P4", "P5"]
file_owners = {}
for priority in priority_order:
    for item in worklists[priority]:
        for f in item.get("affected_files", []):
            if f not in file_owners:
                file_owners[f] = priority
            # If already owned by higher priority, leave it

# Reassign issues whose files are all owned by a higher priority
for lower in reversed(priority_order[1:]):  # P5, P4, P3, P2
    reassigned = []
    for item in worklists[lower]:
        files = item.get("affected_files", [])
        if files and all(file_owners.get(f) != lower for f in files):
            # All files owned by higher priority — reassign this issue up
            higher = file_owners.get(files[0], lower) if files else lower
            worklists[higher].append(item)
            reassigned.append(item)
    for item in reassigned:
        worklists[lower].remove(item)

# Write worklists with file ownership metadata
# Split large worklists into sub-groups for parallel agents (up to MAX_AGENTS total)
max_agents = int(os.environ.get("MAX_AGENTS", "5"))

# Collect all non-empty priority groups
all_groups = []
for priority in priority_order:
    items = worklists[priority]
    if items:
        all_groups.append((priority, items))

# Calculate how many agent slots each priority gets (proportional to issue count)
total_issues = sum(len(items) for _, items in all_groups)
if total_issues == 0:
    pass  # nothing to do
else:
    # Each priority gets at least 1 slot; distribute remainder proportionally
    slots = {}
    remaining_slots = max_agents
    for priority, items in all_groups:
        slots[priority] = 1
        remaining_slots -= 1

    # Distribute remaining slots proportionally
    for priority, items in sorted(all_groups, key=lambda x: len(x[1]), reverse=True):
        if remaining_slots <= 0:
            break
        extra = min(remaining_slots, max(0, round(len(items) / total_issues * max_agents) - 1))
        slots[priority] += extra
        remaining_slots -= extra

    # Give any leftover slots to the largest group
    if remaining_slots > 0 and all_groups:
        largest = max(all_groups, key=lambda x: len(x[1]))[0]
        slots[largest] += remaining_slots

    for priority, items in all_groups:
        n_slots = min(slots.get(priority, 1), len(items))  # no more slots than issues
        owned_files = sorted(set(f for f, owner in file_owners.items() if owner == priority))
        excluded_files = sorted(set(f for f, owner in file_owners.items() if owner != priority))

        if n_slots <= 1:
            # Single worklist for this priority
            worklist = {
                "priority": priority,
                "issue_count": len(items),
                "issues": items,
                "owned_files": owned_files,
                "excluded_files": excluded_files
            }
            outfile = os.path.join(loop_dir, f"worklist-{priority.lower()}-iteration-{iteration}.json")
            with open(outfile, "w") as out:
                json.dump(worklist, out, indent=2)
            print(f"{priority}: {len(items)} issues, {len(owned_files)} owned files (1 agent)")
        else:
            # Split into sub-groups by clustering issues that share files.
            # Uses union-find to guarantee NO two agents edit the same file.
            # Issues sharing any file (even via directory overlap) are merged
            # into the same cluster.

            # Union-Find
            parent = {}
            def find(x):
                while parent.get(x, x) != x:
                    parent[x] = parent.get(parent[x], parent[x])
                    x = parent[x]
                return x
            def union(a, b):
                ra, rb = find(a), find(b)
                if ra != rb:
                    parent[ra] = rb

            # Helper: check if two file paths overlap (one is a prefix of the other)
            def paths_overlap(a, b):
                # Normalize: ensure directories end with /
                na = a.rstrip("/") + "/" if a.endswith("/") else a
                nb = b.rstrip("/") + "/" if b.endswith("/") else b
                # a is a directory containing b, or b is a directory containing a
                if a.endswith("/") and nb.startswith(na):
                    return True
                if b.endswith("/") and na.startswith(nb):
                    return True
                return a == b

            # Build file→issue index, respecting directory overlap
            file_to_issues = {}
            for i, item in enumerate(items):
                for f in item.get("affected_files", []):
                    # Check against existing keys for directory overlap
                    merged_key = f
                    for existing_key in list(file_to_issues.keys()):
                        if paths_overlap(f, existing_key):
                            merged_key = existing_key
                            break
                    if merged_key not in file_to_issues:
                        file_to_issues[merged_key] = []
                    file_to_issues[merged_key].append(i)

            # Union issues that share any file (or overlapping directory)
            for indices in file_to_issues.values():
                for j in range(1, len(indices)):
                    union(indices[0], indices[j])

            # Also union issues with no affected_files into one group
            no_files = [i for i, item in enumerate(items) if not item.get("affected_files")]
            for j in range(1, len(no_files)):
                union(no_files[0], no_files[j])

            # Collect clusters
            from collections import defaultdict
            clusters = defaultdict(list)
            for i in range(len(items)):
                clusters[find(i)].append(i)
            cluster_list = sorted(clusters.values(), key=lambda c: len(c), reverse=True)

            # Merge smallest clusters until we have at most n_slots groups
            while len(cluster_list) > n_slots:
                # Merge the two smallest clusters
                smallest = cluster_list.pop()
                cluster_list[-1].extend(smallest)
                cluster_list.sort(key=lambda c: len(c), reverse=True)

            chunks = [[items[i] for i in cluster] for cluster in cluster_list]

            for idx, chunk in enumerate(chunks):
                chunk_owned = sorted(set(
                    f for issue in chunk for f in issue.get("affected_files", [])
                    if file_owners.get(f) == priority
                ))
                chunk_excluded = sorted(set(
                    f for f, owner in file_owners.items() if f not in chunk_owned
                ))
                # Verify no file overlap with other chunks (defensive check)
                for other_idx, other_chunk in enumerate(chunks):
                    if other_idx == idx:
                        continue
                    other_files = set(
                        f for issue in other_chunk for f in issue.get("affected_files", [])
                    )
                    overlap = set(chunk_owned) & other_files
                    if overlap:
                        print(f"  WARNING: file overlap between {priority}-{idx+1} and {priority}-{other_idx+1}: {overlap}", file=sys.stderr)

                worklist = {
                    "priority": f"{priority}-{idx+1}",
                    "issue_count": len(chunk),
                    "issues": chunk,
                    "owned_files": chunk_owned,
                    "excluded_files": chunk_excluded
                }
                outfile = os.path.join(loop_dir, f"worklist-{priority.lower()}-{idx+1}-iteration-{iteration}.json")
                with open(outfile, "w") as out:
                    json.dump(worklist, out, indent=2)
            print(f"{priority}: {len(items)} issues, {len(owned_files)} owned files ({len(chunks)} agents)")

PARTITION_EOF
        log "Worklists generated."
    fi
}

# Generate a minimal issues.json from the markdown report (for --fix-only mode)
generate_issues_json_from_report() {
    local iteration=$1
    log "Generating issues.json from markdown report..."

    # Use Claude to parse the report into structured JSON
    local parse_log="$LOOP_DIR/parse-report-$iteration.log"
    local parse_prompt="Read the file at $REPORT_FILE and extract all issues into a JSON file at $ISSUES_FILE.

Use this exact JSON structure:
{
  \"catalog\": \"from-report\",
  \"timestamp\": \"$(date '+%Y-%m-%d %H:%M:%S')\",
  \"total_cards\": 287,
  \"p1_count\": <count>,
  \"p2_count\": <count>,
  \"p3_count\": <count>,
  \"p4_count\": <count>,
  \"p5_count\": <count>,
  \"issues\": [
    {
      \"id\": 1,
      \"priority\": \"P1\",
      \"card\": \"card-name\",
      \"category\": \"Root\",
      \"platform\": \"android\",
      \"type\": \"crash\",
      \"summary\": \"Short description\",
      \"ios_behavior\": \"What iOS shows\",
      \"android_behavior\": \"What Android shows\",
      \"affected_files\": [\"relative/path/to/file.kt\"],
      \"fix_hint\": \"Suggested fix\"
    }
  ]
}

For affected_files, use these paths:
- Android composables: android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/
- iOS views: ios/Sources/ACRendering/Views/
- Date functions: ios/Sources/ACTemplating/Functions/DateFunctions.swift and android/ac-templating/src/main/kotlin/com/microsoft/adaptivecards/templating/functions/DateFunctions.kt
- Markdown: ios/Sources/ACMarkdown/ and android/ac-markdown/
- Sample app: android/sample-app/src/main/kotlin/com/microsoft/adaptivecards/sample/

Search the codebase to find exact file paths. Extract ALL issues from the Summary of Action Items table."

    if claude -p "$parse_prompt" \
        --model "$MODEL" \
        --allow-dangerously-skip-permissions \
        --dangerously-skip-permissions \
        --allowed-tools "Read,Glob,Grep,Write" \
        --no-session-persistence \
        > "$parse_log" 2>&1; then
        log "Issues JSON generated from report."
    else
        log "WARNING: Failed to generate issues.json from report. Check $parse_log"
    fi
}

# =============================================================================
# Phase 4: Parallel Fix Agents
# =============================================================================
run_fixes() {
    local iteration=$1
    log_section "Iteration $iteration — Phase 4: Parallel Fix Agents"

    if [ "$REVIEW_ONLY" = true ]; then
        log "Review-only mode — skipping fixes."
        return 0
    fi

    # Discover all worklist files for this iteration (supports split sub-groups)
    local agent_count=0
    local pids_file="$LOOP_DIR/fix-pids-iteration-${iteration}.txt"
    > "$pids_file"  # truncate

    # Find all worklist files: worklist-p0-iteration-N.json, worklist-p0-1-iteration-N.json, etc.
    local worklist_files
    worklist_files=$(find "$LOOP_DIR" -name "worklist-*-iteration-${iteration}.json" | sort)

    for worklist in $worklist_files; do
        local basename_wl
        basename_wl=$(basename "$worklist")
        # Extract priority tag: e.g., "p0", "p0-1", "p1-2" from "worklist-p0-1-iteration-3.json"
        local priority
        priority=$(echo "$basename_wl" | sed "s/worklist-//;s/-iteration-${iteration}\.json//")

        local issue_count
        issue_count=$(python3 -c "import json; print(json.load(open('$worklist')).get('issue_count', 0))" 2>/dev/null | tr -d '[:space:]' || echo "0")
        [ "$issue_count" -eq 0 ] && continue

        local fix_log="$LOOP_DIR/fix-${priority}-iteration-${iteration}.log"
        local PRIORITY_UPPER
        PRIORITY_UPPER=$(echo "$priority" | tr 'a-z' 'A-Z')
        local branch_name="fix-${priority}-round-${iteration}"

        # Build fix prompt — heredoc with expansion (we want $REPO_ROOT to resolve)
        # Include learnings if available
        local learnings_content=""
        if [ -f "$LEARNINGS_FILE" ]; then
            learnings_content=$(cat "$LEARNINGS_FILE")
        fi

        # Build fix prompt by concatenation to avoid heredoc quoting issues
        local worklist_content
        worklist_content=$(cat "$worklist")
        local fix_prompt="You are fixing $PRIORITY_UPPER design parity issues in the AdaptiveCards-Mobile project.

## Your Worklist
$worklist_content

## Fix Protocol — ONE ISSUE AT A TIME

Process issues in the order listed. For EACH issue, complete this full cycle before moving to the next:

### Step 1: Understand (read before you write)
a. Read the reference_file if provided — this is the WORKING platform's code. It shows exactly what correct looks like. Study the pattern.
b. Read every file in affected_files — understand the current broken code.
c. Read the test card JSON from shared/test-cards/ for the affected card — understand what the card is trying to render.
d. If the issue is iOS-specific, find the Android counterpart view in android/ac-rendering/.../composables/ and vice versa. The counterpart is your blueprint.

### Step 2: Fix (minimal, targeted change)
a. Apply the minimal change needed. Copy the pattern from the reference/counterpart implementation.
b. If fixing iOS, check if Android needs the same change for parity, and vice versa.
c. Grep for other callers of any function/property you changed to check for side effects.

### Step 3: Build (catch errors immediately)
a. Build iOS: cd $REPO_ROOT/ios && swift build
b. Build Android: cd $REPO_ROOT/android && ./gradlew :sample-app:compileDebugKotlin
c. If build fails, fix the error NOW before moving on.

### Step 4: Commit (one commit per issue — enables bisection)
a. Stage only the files you changed for THIS issue.
b. Commit with format: fix(ios,android): issue-summary
c. Include the issue ID in the commit body so regressions can be traced.

### Step 5: Move to next issue
Repeat steps 1-4 for the next issue in the worklist.

IMPORTANT: Do NOT batch all fixes into one commit. One commit per issue makes it possible to identify which fix caused a regression. If you fix 5 issues, you should have 5 commits.

## File Access Rules
- You may ONLY EDIT files listed in owned_files from the worklist.
- You may READ any file in the repo, including files in excluded_files — you just cannot modify them. Reading excluded files is encouraged when they provide context for your fix.
- Do NOT touch files in excluded_files — another agent is handling those.

## Constraints
- Do not add unnecessary comments, docstrings, or refactoring beyond the fix.
- Do not introduce ScrollView or LazyVStack in iOS rendering views as it breaks snapshot tests.
- When fixing spacing/padding, use the HostConfig reference values below — do not guess.
- For layout fixes, always prefer copying the pattern from the working platform rather than inventing a new approach.

## Learnings from Past Iterations

Read these carefully — they contain failed approaches and pitfalls from previous fix attempts:

$learnings_content

## HostConfig Reference Values from Figma design spec

| Property | iOS | Android |
|---|---|---|
| fontSizes sm/def/med/lg/xl | 12/15/15/17/22 | 12/14/14/16/20 |
| fontWeights light/def/bold | 300/400/600 | 400/400/500 |
| spacing sm/def/med/lg/xl/pad | 8/10/12/16/20/8 | 8/8/12/16/20/10 |
| separator color | #FFDFDEDE | #0D16233A |
| imageSizes sm/med/lg | 32/52/100 | 32/52/100 |
| cornerRadius | 4 | 4 |
| accent | #6264A7 | #6264A7 |

## SwiftUI Layout Quick Reference (iOS fixes)
- .frame(maxWidth: .infinity) expands to available width — causes overflow if parent is unconstrained
- .fixedSize(horizontal: false, vertical: true) uses intrinsic height, prevents vertical squashing
- .fixedSize() uses intrinsic size for BOTH axes — use cautiously, can cause horizontal overflow
- .layoutPriority(1) raises view priority in layout negotiation
- GeometryReader provides parent size but causes lazy evaluation — avoid in snapshot views
- .frame(idealWidth:) sets preferred size without forcing — respects parent constraints
- Never use ScrollView in card rendering views (breaks layer.render snapshot capture)

## Compose Layout Quick Reference (Android fixes)
- Modifier.fillMaxWidth() expands to parent width — equivalent to iOS frame(maxWidth: .infinity)
- Modifier.wrapContentWidth() uses intrinsic width — the Compose default
- Modifier.wrapContentHeight() uses intrinsic height
- Modifier.widthIn(min, max) constrains width range — use for badges, pills
- Modifier.heightIn(min, max) constrains height range — max must be >= min
- Modifier.weight(1f) in Row/Column distributes remaining space proportionally
- IntrinsicSize.Min/Max used with .height(IntrinsicSize.Min) for cross-axis sizing

## Key Architecture Notes
- iOS SwiftUI views: ios/Sources/ACRendering/Views/
- Android Compose composables: android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/
- Template engine: ios/Sources/ACTemplating/ and android/ac-templating/
- Models: ios/Sources/ACCore/Models/ and android/ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/models/
- Shared test cards: shared/test-cards/
- Schema validators: ios/Sources/ACCore/SchemaValidator.swift and android/ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/SchemaValidator.kt

## Counterpart File Mapping
When fixing a view on one platform, the counterpart on the other platform is usually at:
- ios/Sources/ACRendering/Views/{Name}View.swift <-> android/ac-rendering/.../composables/{Name}View.kt
- ios/Sources/ACCore/Models/{Name}.swift <-> android/ac-core/.../models/{Name}.kt
- ios/Sources/ACTemplating/Functions/{Name}.swift <-> android/ac-templating/.../functions/{Name}.kt
- ios/Sources/ACMarkdown/{Name}.swift <-> android/ac-markdown/.../markdown/{Name}.kt"

        log "Launching $PRIORITY_UPPER fix agent ($issue_count issues)..."
        echo "$fix_prompt" > "$LOOP_DIR/fix-prompt-${priority}-${iteration}.md"

        # Launch Claude in a git worktree for isolation
        claude -p "$fix_prompt" \
            --model "$MODEL" \
            --worktree "$branch_name" \
            --allow-dangerously-skip-permissions \
            --dangerously-skip-permissions \
            --allowed-tools "Read,Glob,Grep,Write,Edit,Bash" \
            --no-session-persistence \
            > "$fix_log" 2>&1 &

        local this_pid=$!
        echo "$this_pid $PRIORITY_UPPER $branch_name" >> "$pids_file"
        log "  $PRIORITY_UPPER agent PID: $this_pid (worktree branch: $branch_name)"
        agent_count=$((agent_count + 1))
    done

    if [ "$agent_count" -eq 0 ]; then
        log "No fix agents needed — all worklists empty or zero issues."
        return 0
    fi

    # Wait for all agents
    log "Waiting for $agent_count fix agents to complete..."
    local failed=0
    while IFS=' ' read -r this_pid this_name this_branch; do
        if wait "$this_pid"; then
            log "  $this_name agent completed successfully."
        else
            log "  WARNING: $this_name agent exited with errors."
            failed=$((failed + 1))
        fi
    done < "$pids_file"

    log "Fix phase complete. $failed/$agent_count agents had errors."
}

# =============================================================================
# Phase 5: Merge Fix Branches
# =============================================================================

# Helper: find and remove the worktree for a given branch, then delete the branch
cleanup_branch() {
    local branch="$1"
    # Remove worktree if it exists for this branch
    local wt_line
    wt_line=$(git -C "$REPO_ROOT" worktree list --porcelain 2>/dev/null | grep -B2 "branch refs/heads/$branch" | head -1 || true)
    local wt_path="${wt_line#worktree }"
    if [ -n "$wt_path" ] && [ "$wt_path" != "$REPO_ROOT" ] && [ -d "$wt_path" ]; then
        git -C "$REPO_ROOT" worktree remove "$wt_path" --force 2>/dev/null || true
        log "  Removed worktree: $wt_path"
    fi
    # Also check Claude Code's default worktree location
    local claude_wt="$REPO_ROOT/.claude/worktrees/${branch#worktree-}"
    if [ -d "$claude_wt" ]; then
        git -C "$REPO_ROOT" worktree remove "$claude_wt" --force 2>/dev/null || true
        log "  Removed worktree: $claude_wt"
    fi
    # Use -D (force delete) since branch is merged to HEAD but not to origin
    git -C "$REPO_ROOT" branch -D "$branch" 2>/dev/null || true
}

# Helper: resolve the branch name for a given priority (handles naming conventions)
resolve_fix_branch() {
    local worktree_name="$1"
    # Claude Code --worktree creates branches named "worktree-<name>"
    local branch="worktree-${worktree_name}"
    if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        echo "$branch"
        return 0
    fi
    # Fall back to non-prefixed name
    branch="$worktree_name"
    if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        echo "$branch"
        return 0
    fi
    return 1
}

merge_fixes() {
    local iteration=$1
    log_section "Iteration $iteration — Phase 5: Merge Fix Branches"

    if [ "$REVIEW_ONLY" = true ]; then
        return 0
    fi

    # Clean up orphaned fix branches from prior iterations first
    if [ "$iteration" -gt 1 ]; then
        for old_iter in $(seq 1 $((iteration - 1))); do
            local old_pids_file="$LOOP_DIR/fix-pids-iteration-${old_iter}.txt"
            if [ -f "$old_pids_file" ]; then
                while IFS=' ' read -r _ _ old_branch_name; do
                    local old_branch
                    old_branch=$(resolve_fix_branch "$old_branch_name" 2>/dev/null) || continue
                    log "Cleaning up orphaned branch from iteration $old_iter: $old_branch"
                    cleanup_branch "$old_branch"
                done < "$old_pids_file"
            else
                # Fallback: check legacy p0/p1/p2 naming
                for old_priority in p0 p1 p2; do
                    local old_name="fix-${old_priority}-round-${old_iter}"
                    local old_branch
                    old_branch=$(resolve_fix_branch "$old_name" 2>/dev/null) || continue
                    log "Cleaning up orphaned branch from iteration $old_iter: $old_branch"
                    cleanup_branch "$old_branch"
                done
            fi
        done
    fi

    local current_branch
    current_branch=$(git -C "$REPO_ROOT" branch --show-current)
    local merged_count=0
    local empty_count=0

    # Discover branches from pids file (supports dynamic agent count)
    local pids_file="$LOOP_DIR/fix-pids-iteration-${iteration}.txt"
    if [ ! -f "$pids_file" ] || [ ! -s "$pids_file" ]; then
        log "No fix agents were launched — nothing to merge."
        return 0
    fi

    while IFS=' ' read -r _ agent_name worktree_name; do
        local PRIORITY_UPPER="$agent_name"
        local branch
        branch=$(resolve_fix_branch "$worktree_name") || {
            log "WARNING: $PRIORITY_UPPER agent produced NO branch ($worktree_name). Agent may have failed silently."
            empty_count=$((empty_count + 1))
            continue
        }

        # Check if branch has commits ahead of current branch
        local ahead
        ahead=$(git -C "$REPO_ROOT" rev-list --count "$current_branch..$branch" 2>/dev/null | tr -d '[:space:]' || echo "0")
        if [ "$ahead" -eq 0 ]; then
            log "WARNING: $PRIORITY_UPPER agent produced 0 commits. Likely stuck or all issues outside owned_files."
            empty_count=$((empty_count + 1))
            cleanup_branch "$branch"
            continue
        fi

        # Rebase the fix branch onto current main before merging.
        # Parallel agents fork from the same base commit, so later branches
        # don't have earlier branches' changes. Rebasing first avoids merge
        # conflicts caused by overlapping fixes.
        log "Rebasing $branch onto $current_branch before merge..."
        if git -C "$REPO_ROOT" rebase "$current_branch" "$branch" 2>>"$LOOP_LOG"; then
            # Switch back to main after rebase (rebase leaves us on the rebased branch)
            git -C "$REPO_ROOT" checkout "$current_branch" 2>>"$LOOP_LOG"
            log "  Rebase successful."
        else
            log "  WARNING: Rebase conflict on $PRIORITY_UPPER branch. Aborting rebase, falling back to merge."
            git -C "$REPO_ROOT" rebase --abort 2>/dev/null || true
            git -C "$REPO_ROOT" checkout "$current_branch" 2>/dev/null || true
        fi

        # Re-count ahead after potential rebase
        ahead=$(git -C "$REPO_ROOT" rev-list --count "$current_branch..$branch" 2>/dev/null | tr -d '[:space:]' || echo "0")

        log "Merging $branch into $current_branch ($ahead commits ahead)..."
        if git -C "$REPO_ROOT" merge "$branch" --no-edit 2>>"$LOOP_LOG"; then
            log "  Merged $PRIORITY_UPPER branch successfully ($ahead commits)."
            merged_count=$((merged_count + 1))
            cleanup_branch "$branch"
        else
            log "  Merge conflict on $PRIORITY_UPPER branch. Attempting auto-resolution..."
            auto_resolve_merge "$branch" "$PRIORITY_UPPER" "$current_branch" "$iteration"
            local resolve_status=$?
            if [ $resolve_status -eq 0 ]; then
                log "  Auto-resolved and merged $PRIORITY_UPPER branch successfully."
                merged_count=$((merged_count + 1))
                cleanup_branch "$branch"
            else
                log "  WARNING: Auto-resolution failed for $PRIORITY_UPPER branch. Keeping for manual resolution."
            fi
        fi
    done < "$pids_file"

    log "Merge summary: $merged_count merged, $empty_count agents produced no changes."
    if [ "$empty_count" -gt 0 ]; then
        log "NOTE: $empty_count fix agents produced no output. Check fix logs for errors."
    fi
}

# =============================================================================
# Auto-Resolve Merge Conflicts
# =============================================================================
# Called when `git merge` fails with conflicts. Uses Claude to intelligently
# resolve by understanding both branches' intent from commit messages and diffs.
# Falls back to abort if resolution fails or introduces syntax errors.
#
# Args: $1=branch $2=priority_label $3=target_branch $4=iteration
# Returns: 0 on success, 1 on failure (merge left aborted)

auto_resolve_merge() {
    local branch="$1"
    local priority="$2"
    local target="$3"
    local iteration="$4"
    local resolve_log="$LOOP_DIR/conflict-resolve-${priority}-iteration-${iteration}.log"

    # Collect conflict context
    local conflicted_files
    conflicted_files=$(git -C "$REPO_ROOT" diff --name-only --diff-filter=U 2>/dev/null)
    if [ -z "$conflicted_files" ]; then
        log "  No conflicted files found (unexpected). Aborting merge."
        git -C "$REPO_ROOT" merge --abort 2>/dev/null || true
        return 1
    fi

    local conflict_count
    conflict_count=$(echo "$conflicted_files" | wc -l | tr -d ' ')
    log "  $conflict_count conflicted file(s): $(echo "$conflicted_files" | tr '\n' ' ')"

    # Gather context for the resolution agent
    local branch_commits
    branch_commits=$(git -C "$REPO_ROOT" log --oneline "$target..$branch" 2>/dev/null | head -20)
    local target_recent
    target_recent=$(git -C "$REPO_ROOT" log --oneline -10 "$target" 2>/dev/null)

    # Build the conflict diff (with markers) for each file
    local conflict_diffs=""
    local file_list=""
    while IFS= read -r cfile; do
        [ -z "$cfile" ] && continue
        file_list="$file_list $cfile"
        conflict_diffs="$conflict_diffs
=== $cfile ===
$(cat "$REPO_ROOT/$cfile" 2>/dev/null | head -500)
"
    done <<< "$conflicted_files"

    # Build the resolution prompt
    local resolve_prompt
    resolve_prompt=$(cat <<RESOLVE_PROMPT_EOF
You are resolving git merge conflicts in the AdaptiveCards-Mobile repository.

## Context

**Target branch** ($target) recent commits:
$target_recent

**Incoming branch** ($branch) commits being merged:
$branch_commits

## Conflicted Files

$conflict_diffs

## Resolution Rules

1. **Read each conflicted file** using the Read tool to see the full context around conflicts.
2. **Understand the intent of both sides** from the commit messages and surrounding code:
   - Code between \`<<<<<<< HEAD\` and \`=======\` is from the target branch ($target)
   - Code between \`=======\` and \`>>>>>>> $branch\` is from the incoming branch ($branch)
3. **Resolve by combining both changes** when they modify different aspects (e.g., one adds a property, the other changes a comment). Prefer the more complete/correct version when they conflict on the same logic.
4. **Prioritization rules:**
   - If one side uses host config / theme values and the other hardcodes, keep the host config version
   - If one side has a more complete implementation (handles more cases), keep it
   - If one side is a bug fix and the other is a refactor, keep the bug-fix logic with the refactor structure
   - If both add new code (non-overlapping), keep both
   - When modifiers chain (\`modifier.xyz()\` vs \`Modifier.xyz()\`), prefer the chained version that preserves parent context
5. **Remove ALL conflict markers** (\`<<<<<<<\`, \`=======\`, \`>>>>>>>\`) — the file must be valid source code after resolution.
6. **Verify syntax**: After editing, ensure the file has balanced braces/brackets and no leftover conflict markers.

## Process

For each conflicted file:
1. Read the full file
2. Edit to resolve each conflict region (use the Edit tool to replace the conflicted section)
3. Verify no conflict markers remain (search for \`<<<<<<<\`)

Files to resolve:$file_list

IMPORTANT: Only edit the conflicted files listed above. Do not modify any other files.
RESOLVE_PROMPT_EOF
    )

    # Launch Claude to resolve
    log "  Launching conflict resolution agent..."
    if claude --print \
        --model "$MODEL" \
        --max-turns 30 \
        --allowed-tools "Read,Edit,Grep,Glob,Bash" \
        -p "$resolve_prompt" \
        > "$resolve_log" 2>&1; then
        log "  Resolution agent completed."
    else
        log "  Resolution agent exited with errors. Checking if conflicts were resolved anyway..."
    fi

    # Verify: no conflict markers remain in any file
    local remaining_conflicts
    remaining_conflicts=$(grep -rl '<<<<<<<' $file_list 2>/dev/null || true)
    if [ -n "$remaining_conflicts" ]; then
        log "  FAILED: Conflict markers still present in: $remaining_conflicts"
        git -C "$REPO_ROOT" merge --abort 2>/dev/null || true
        return 1
    fi

    # Verify: files are syntactically valid (basic check — balanced braces for Swift/Kotlin)
    local syntax_ok=true
    while IFS= read -r cfile; do
        [ -z "$cfile" ] && continue
        local ext="${cfile##*.}"
        if [ "$ext" = "swift" ] || [ "$ext" = "kt" ]; then
            local open_braces close_braces
            open_braces=$(grep -o '{' "$REPO_ROOT/$cfile" 2>/dev/null | wc -l | tr -d ' ')
            close_braces=$(grep -o '}' "$REPO_ROOT/$cfile" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$open_braces" -ne "$close_braces" ]; then
                log "  FAILED: Unbalanced braces in $cfile (open=$open_braces, close=$close_braces)"
                syntax_ok=false
            fi
        fi
    done <<< "$conflicted_files"

    if [ "$syntax_ok" = false ]; then
        git -C "$REPO_ROOT" merge --abort 2>/dev/null || true
        return 1
    fi

    # Stage resolved files and commit
    while IFS= read -r cfile; do
        [ -z "$cfile" ] && continue
        git -C "$REPO_ROOT" add "$cfile"
    done <<< "$conflicted_files"

    if git -C "$REPO_ROOT" commit --no-edit 2>>"$LOOP_LOG"; then
        log "  Merge commit created after auto-resolution."
        return 0
    else
        log "  FAILED: Could not create merge commit."
        git -C "$REPO_ROOT" merge --abort 2>/dev/null || true
        return 1
    fi
}

# =============================================================================
# Phase 6: Update Learnings (Self-Improving Loop)
# =============================================================================
update_learnings() {
    local iteration=$1
    log_section "Iteration $iteration — Phase 6: Update Learnings"

    # Learnings update runs every iteration — even iteration 1 captures
    # initial false positives and platform-intentional differences

    local learnings_log="$LOOP_DIR/learnings-iteration-$iteration.log"

    # Collect fix agent logs for this iteration to extract what worked/failed
    local fix_logs=""
    for priority in p0 p1 p2; do
        local flog="$LOOP_DIR/fix-${priority}-iteration-${iteration}.log"
        [ -f "$flog" ] && fix_logs="$fix_logs $flog"
    done

    local learnings_prompt
    learnings_prompt=$(cat <<LEARN_EOF
You are maintaining the design review learning loop for AdaptiveCards-Mobile.

Read these files:
1. Current learnings: $LEARNINGS_FILE
2. Current design review report: $REPORT_FILE
3. Issues JSON (if exists): $ISSUES_FILE

Also check recent git log for this iteration's fix commits:
  git log --oneline -20

Your task: Update $LEARNINGS_FILE with new learnings from this iteration.

Specifically:
1. **False Positives**: If any issues from the report turned out to be non-issues (check if fix agents skipped them with explanation), add to "False Positives to Skip".

2. **Failed Fix Patterns**: Check fix agent logs and git diff. If any fix was attempted but the issue persists or caused a regression, document the failed approach and suggest alternatives.

3. **Recurring Root Causes**: If multiple issues share a root cause, group them so future fix agents can batch the fix.

4. **Intentional Platform Differences**: If the review flagged something that's actually an intentional design choice (per HostConfig or platform conventions), add it so future reviews skip it.

5. **Fix Agent Pitfalls**: If fix agents made common mistakes (touching wrong files, missing cross-platform parity, breaking builds), document the pattern.

Rules:
- Only ADD or UPDATE entries — never remove existing learnings unless they are proven wrong.
- Keep entries concise — one pattern per bullet.
- Use the existing format in the file.
- Update the "Last updated" date.
LEARN_EOF
)

    log "Updating learnings file..."
    if claude -p "$learnings_prompt" \
        --model "$MODEL" \
        --allow-dangerously-skip-permissions \
        --dangerously-skip-permissions \
        --allowed-tools "Read,Glob,Grep,Write,Edit,Bash" \
        --no-session-persistence \
        > "$learnings_log" 2>&1; then
        log "Learnings updated."
    else
        log "WARNING: Learnings update failed. Check $learnings_log"
    fi
}

# =============================================================================
# Stall Detection (per-priority weighted)
# =============================================================================
PREV_P1=999
PREV_P2=999
PREV_P3=0

check_stall() {
    local iteration=$1
    local current_total=$((P1_COUNT + P2_COUNT + P3_COUNT + P4_COUNT + P5_COUNT))

    if [ "$iteration" -le 1 ] || [ "$PREV_TOTAL_ISSUES" -ge 999 ]; then
        return 1  # Not stalled — first iteration or no baseline
    fi

    # Weighted score: P1 issues are 10x worse than P5
    local prev_weighted=$(( PREV_P1 * 10 + PREV_P2 * 5 + PREV_P3 * 2 + (PREV_TOTAL_ISSUES - PREV_P1 - PREV_P2 - PREV_P3) ))
    local curr_weighted=$(( P1_COUNT * 10 + P2_COUNT * 5 + P3_COUNT * 2 + P4_COUNT + P5_COUNT ))

    # Detect P1 regression — always stall if P1 count increased
    if [ "$P1_COUNT" -gt "$PREV_P1" ] && [ "$PREV_P1" -lt 999 ]; then
        log "REGRESSION DETECTED: P1 count increased ($PREV_P1 -> $P1_COUNT). Stopping to prevent further damage."
        return 0
    fi

    # Stall if weighted score didn't improve
    if [ "$curr_weighted" -ge "$prev_weighted" ]; then
        log "STALL DETECTED: Weighted issue score did not decrease ($prev_weighted -> $curr_weighted)."
        log "  Breakdown: P1=$PREV_P1->$P1_COUNT  P2=$PREV_P2->$P2_COUNT  P3=$PREV_P3->$P3_COUNT"
        log "Fix agents may not have resolved any issues. Stopping to avoid infinite loop."
        return 0
    fi

    log "Progress: weighted score $prev_weighted -> $curr_weighted (P1=$PREV_P1->$P1_COUNT  P2=$PREV_P2->$P2_COUNT  P3=$PREV_P3->$P3_COUNT)"
    return 1  # Not stalled
}

# =============================================================================
# Loop Termination Check
# =============================================================================
should_continue() {
    local iteration=$1

    # Check P1 + P2 = 0 (critical issues resolved)
    if [ "${P1_COUNT:-0}" -eq 0 ] && [ "${P2_COUNT:-0}" -eq 0 ]; then
        if [ "$EXIT_ON_P2" = true ] && [ "${P3_COUNT:-0}" -gt 0 ]; then
            log "P1/P2 resolved but P3 issues remain ($P3_COUNT). Continuing (--exit-on-p2 set)."
            return 0  # Continue to fix P3
        fi
        log "All P1 and P2 issues resolved! ($P3_COUNT P3, $P4_COUNT P4, $P5_COUNT P5 remaining)"
        return 1  # Stop
    fi

    # Max iterations
    if [ "$iteration" -ge "$MAX_ITERATIONS" ]; then
        log "Max iterations ($MAX_ITERATIONS) reached. Stopping."
        log "Remaining: P1=$P1_COUNT  P2=$P2_COUNT  P3=$P3_COUNT  P4=$P4_COUNT  P5=$P5_COUNT"
        return 1  # Stop
    fi

    # Stall detection
    if check_stall "$iteration"; then
        return 1  # Stop
    fi

    return 0  # Continue
}

# =============================================================================
# Main Loop
# =============================================================================
log_section "Design Review Loop — Starting"
log "Config: max_iterations=$MAX_ITERATIONS skip_capture=$SKIP_CAPTURE skip_review=$SKIP_REVIEW"
log "Config: fix_only=$FIX_ONLY review_only=$REVIEW_ONLY model=$MODEL"
echo ""

LOOP_START_TIME=$(date +%s)

for iteration in $(seq 1 "$MAX_ITERATIONS"); do
    LAST_ITERATION=$iteration
    ITER_START=$(date +%s)
    log_section "=== ITERATION $iteration / $MAX_ITERATIONS ==="

    # Phase 1: Capture + Deploy
    T_PHASE=$(date +%s)
    run_capture "$iteration"
    T_NOW=$(date +%s); log "Phase 1 (capture): $((T_NOW - T_PHASE))s"; T_PHASE=$T_NOW

    # Phase 1.5: OCR Pre-Scan (deterministic detection of template failures, blank renders)
    run_ocr_prescan "$iteration"
    T_NOW=$(date +%s); log "Phase 1.5 (OCR pre-scan): $((T_NOW - T_PHASE))s"; T_PHASE=$T_NOW

    # Phase 2: Review
    run_review "$iteration"
    T_NOW=$(date +%s); log "Phase 2 (AI review): $((T_NOW - T_PHASE))s"; T_PHASE=$T_NOW

    # Phase 3: Triage
    parse_issues "$iteration"
    T_NOW=$(date +%s); log "Phase 3 (triage): $((T_NOW - T_PHASE))s"; T_PHASE=$T_NOW

    # Check if we should fix or stop
    if [ "$REVIEW_ONLY" = true ]; then
        log "Review-only mode. Report written to $REPORT_FILE"
        break
    fi

    if [ "${P1_COUNT:-0}" -eq 0 ] && [ "${P2_COUNT:-0}" -eq 0 ]; then
        log "No P1/P2 issues found. Done!"
        break
    fi

    # Phase 4: Fix (parallel agents in worktrees)
    run_fixes "$iteration"
    T_NOW=$(date +%s); log "Phase 4 (fix agents): $((T_NOW - T_PHASE))s"; T_PHASE=$T_NOW

    # Phase 5: Merge fix branches
    merge_fixes "$iteration"
    T_NOW=$(date +%s); log "Phase 5 (merge): $((T_NOW - T_PHASE))s"; T_PHASE=$T_NOW

    # Phase 6: Update learnings from this iteration
    update_learnings "$iteration"
    T_NOW=$(date +%s); log "Phase 6 (learnings): $((T_NOW - T_PHASE))s"

    log "Iteration $iteration total: $((T_NOW - ITER_START))s"

    # Reset skip flags for subsequent iterations (always capture + review after fixes)
    SKIP_CAPTURE=false
    SKIP_REVIEW=false

    # Check termination
    if ! should_continue "$iteration"; then
        break
    fi

    log "Looping back to Phase 1 for verification..."
    sleep 2
done

# =============================================================================
# Final Summary
# =============================================================================
LOOP_END_TIME=$(date +%s)
LOOP_DURATION=$((LOOP_END_TIME - LOOP_START_TIME))
LOOP_MINUTES=$((LOOP_DURATION / 60))
LOOP_SECONDS=$((LOOP_DURATION % 60))

log_section "Design Review Loop — Complete"
log "Iterations run: $LAST_ITERATION"
log "Total duration: ${LOOP_MINUTES}m ${LOOP_SECONDS}s"
log "Final issue counts: P1=${P1_COUNT:-?}  P2=${P2_COUNT:-?}  P3=${P3_COUNT:-?}  P4=${P4_COUNT:-?}  P5=${P5_COUNT:-?}"
log "Report: $REPORT_FILE"
log "Learnings: $LEARNINGS_FILE"
log "Loop artifacts: $LOOP_DIR"
log "Loop log: $LOOP_LOG"

if [ "${P1_COUNT:-0}" -eq 0 ] && [ "${P2_COUNT:-0}" -eq 0 ]; then
    log "STATUS: ALL P1/P2 ISSUES RESOLVED"
    exit 0
else
    log "STATUS: ISSUES REMAIN — manual review needed"
    exit 1
fi
