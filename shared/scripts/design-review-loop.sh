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
#   5. Spawns 2-3 parallel Claude Code agents in git worktrees to fix issues
#   6. Merges fixes and loops back to step 1
#   7. Stops when P0=0 and P1=0, or max iterations reached
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
P0_COUNT=999
P1_COUNT=999
P2_COUNT=0
P3_COUNT=0
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

    log "Running design-pass.sh (this takes ~20 minutes for 287 cards)..."
    local capture_log="$LOOP_DIR/capture-iteration-$iteration.log"

    if bash "$SCRIPT_DIR/design-pass.sh" --wait "$RENDER_WAIT" > "$capture_log" 2>&1; then
        CATALOG_DIR=$(find_latest_catalog)
        log "Capture complete: $(basename "$CATALOG_DIR")"
    else
        log "WARNING: design-pass.sh exited with errors. Check $capture_log"
        CATALOG_DIR=$(find_latest_catalog)
        [ -z "$CATALOG_DIR" ] && { log "ERROR: No catalog produced"; exit 1; }
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
      \"fix_hint\": \"Suggested fix approach\"
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
- Use timestamp: $review_ts"

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
        issue_count=$(grep -c "^### " "$REPORT_FILE" 2>/dev/null || echo "0")
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

    # Save previous total for stall detection
    PREV_TOTAL_ISSUES=$((P0_COUNT + P1_COUNT + P2_COUNT + P3_COUNT))

    # If issues.json exists (from review agent), parse it
    if [ -f "$ISSUES_FILE" ]; then
        P0_COUNT=$(python3 -c "import json; d=json.load(open('$ISSUES_FILE')); print(d.get('p0_count', 0))" 2>/dev/null || echo "0")
        P1_COUNT=$(python3 -c "import json; d=json.load(open('$ISSUES_FILE')); print(d.get('p1_count', 0))" 2>/dev/null || echo "0")
        P2_COUNT=$(python3 -c "import json; d=json.load(open('$ISSUES_FILE')); print(d.get('p2_count', 0))" 2>/dev/null || echo "0")
        P3_COUNT=$(python3 -c "import json; d=json.load(open('$ISSUES_FILE')); print(d.get('p3_count', 0))" 2>/dev/null || echo "0")
        TOTAL_ISSUES=$((P0_COUNT + P1_COUNT + P2_COUNT + P3_COUNT))
        log "Issues found: P0=$P0_COUNT  P1=$P1_COUNT  P2=$P2_COUNT  P3=$P3_COUNT  Total=$TOTAL_ISSUES"
    elif [ -f "$REPORT_FILE" ]; then
        # Fallback: count from markdown summary table (| # | **P0** | ... rows)
        P0_COUNT=$(grep -c '| \*\*P0\*\* |' "$REPORT_FILE" 2>/dev/null || echo "0")
        P1_COUNT=$(grep -c '| \*\*P1\*\* |' "$REPORT_FILE" 2>/dev/null || echo "0")
        P2_COUNT=$(grep -c '| \*\*P2\*\* |' "$REPORT_FILE" 2>/dev/null || echo "0")
        P3_COUNT=$(grep -c '| \*\*P3\*\* |' "$REPORT_FILE" 2>/dev/null || echo "0")
        TOTAL_ISSUES=$((P0_COUNT + P1_COUNT + P2_COUNT + P3_COUNT))
        log "Issues (from markdown table): P0=$P0_COUNT  P1=$P1_COUNT  P2=$P2_COUNT  P3=$P3_COUNT  Total=$TOTAL_ISSUES"
        log "WARNING: issues.json not found — using markdown table grep (less reliable)"

        # Generate issues.json from report for triage to work
        generate_issues_json_from_report "$iteration"
    else
        log "ERROR: No report or issues.json found. Cannot triage."
        P0_COUNT=0; P1_COUNT=0; P2_COUNT=0; P3_COUNT=0; TOTAL_ISSUES=0
        return 1
    fi

    # Partition issues into P0/P1/P2 worklists with file-level conflict detection
    if [ -f "$ISSUES_FILE" ]; then
        export ISSUES_FILE LOOP_DIR
        ITERATION="$iteration" python3 << 'PARTITION_EOF'
import json, sys, os

issues_file = os.environ["ISSUES_FILE"]
loop_dir = os.environ["LOOP_DIR"]
iteration = os.environ.get("ITERATION", "1")

with open(issues_file) as f:
    data = json.load(f)

issues = data.get("issues", [])

# Partition by priority
worklists = {"P0": [], "P1": [], "P2": []}
for issue in issues:
    p = issue.get("priority", "P2")
    if p in worklists:
        worklists[p].append(issue)
    # P3 issues are not assigned to fix agents

# Compute file ownership — higher priority wins conflicts
# Process P0 first, then P1, then P2
file_owners = {}
for priority in ["P0", "P1", "P2"]:
    for item in worklists[priority]:
        for f in item.get("affected_files", []):
            if f not in file_owners:
                file_owners[f] = priority
            # If already owned by higher priority, leave it

# Reassign issues whose files are all owned by a higher priority
for lower in ["P2", "P1"]:
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
for priority, items in worklists.items():
    if not items:
        continue
    owned_files = sorted(set(f for f, owner in file_owners.items() if owner == priority))
    excluded_files = sorted(set(f for f, owner in file_owners.items() if owner != priority))

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

    print(f"{priority}: {len(items)} issues, {len(owned_files)} owned files")

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
  \"p0_count\": <count>,
  \"p1_count\": <count>,
  \"p2_count\": <count>,
  \"p3_count\": <count>,
  \"issues\": [
    {
      \"id\": 1,
      \"priority\": \"P0\",
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

    # Use indexed tracking instead of arrays to avoid bash array subscript issues with set -u
    local agent_count=0
    local pid_0="" pid_1="" pid_2=""
    local name_0="" name_1="" name_2=""
    local branch_0="" branch_1="" branch_2=""

    for priority in p0 p1 p2; do
        local worklist="$LOOP_DIR/worklist-${priority}-iteration-${iteration}.json"
        [ -f "$worklist" ] || continue

        local issue_count
        issue_count=$(python3 -c "import json; print(json.load(open('$worklist')).get('issue_count', 0))" 2>/dev/null || echo "0")
        [ "$issue_count" -eq 0 ] && continue

        local fix_log="$LOOP_DIR/fix-${priority}-iteration-${iteration}.log"
        local PRIORITY_UPPER
        PRIORITY_UPPER=$(echo "$priority" | tr 'a-z' 'A-Z')
        local branch_name="fix-${priority}-round-${iteration}"

        # Build fix prompt — heredoc with expansion (we want $REPO_ROOT to resolve)
        local fix_prompt
        fix_prompt=$(cat <<FIX_EOF
You are fixing $PRIORITY_UPPER design parity issues in the AdaptiveCards-Mobile project.

## Your Worklist
$(cat "$worklist")

## Instructions
1. Read each issue carefully. Understand the root cause.
2. Read the affected source files before making changes.
3. Fix each issue while maintaining cross-platform parity (iOS + Android).
4. After all fixes, verify the build compiles:
   - iOS: cd $REPO_ROOT/ios && swift build
   - Android: cd $REPO_ROOT/android && ./gradlew :sample-app:compileDebugKotlin
5. Commit each logical fix with conventional commit format: fix(ios,android): <description>

## Constraints
- ONLY modify files listed in "owned_files" from the worklist above.
- Do NOT touch files in "excluded_files" — another agent is handling those.
- Maintain cross-platform parity — if you fix iOS, apply the equivalent fix on Android (and vice versa).
- Do not add unnecessary comments, docstrings, or refactoring beyond the fix.
- Run the build after fixes to catch compilation errors.

## Key Architecture Notes
- iOS: SwiftUI views in ios/Sources/ACRendering/Views/
- Android: Jetpack Compose composables in android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/
- Template engine: ios/Sources/ACTemplating/ and android/ac-templating/
- Models: ios/Sources/ACCore/Models/ and android/ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/models/
- Both platforms use shared test cards in shared/test-cards/
- Schema validators: ios/Sources/ACCore/SchemaValidator.swift and android/ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/SchemaValidator.kt
FIX_EOF
)

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
        # Store PID and metadata by index
        eval "pid_${agent_count}=$this_pid"
        eval "name_${agent_count}=$PRIORITY_UPPER"
        eval "branch_${agent_count}=$branch_name"
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
    for i in $(seq 0 $((agent_count - 1))); do
        local this_pid this_name
        eval "this_pid=\$pid_${i}"
        eval "this_name=\$name_${i}"
        if wait "$this_pid"; then
            log "  $this_name agent completed successfully."
        else
            log "  WARNING: $this_name agent exited with errors."
            failed=$((failed + 1))
        fi
    done

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

    local current_branch
    current_branch=$(git -C "$REPO_ROOT" branch --show-current)
    local merged_count=0

    for priority in p0 p1 p2; do
        local worktree_name="fix-${priority}-round-${iteration}"
        local branch
        branch=$(resolve_fix_branch "$worktree_name") || {
            log "No branch for $worktree_name found — agent may not have made changes."
            continue
        }

        # Check if branch has commits ahead of current branch
        local ahead
        ahead=$(git -C "$REPO_ROOT" rev-list --count "$current_branch..$branch" 2>/dev/null || echo "0")
        if [ "$ahead" -eq 0 ]; then
            log "Branch $branch has no new commits — cleaning up."
            cleanup_branch "$branch"
            continue
        fi

        log "Merging $branch into $current_branch ($ahead commits ahead)..."
        if git -C "$REPO_ROOT" merge "$branch" --no-edit 2>>"$LOOP_LOG"; then
            log "  Merged $branch successfully ($ahead commits)."
            merged_count=$((merged_count + 1))
            cleanup_branch "$branch"
        else
            log "  WARNING: Merge conflict on $branch. Aborting merge."
            git -C "$REPO_ROOT" merge --abort 2>/dev/null || true
            log "  Keeping $branch for manual resolution."
        fi
    done

    log "Merged $merged_count branches this iteration."
}

# =============================================================================
# Stall Detection
# =============================================================================
check_stall() {
    local iteration=$1
    local current_total=$((P0_COUNT + P1_COUNT + P2_COUNT + P3_COUNT))

    if [ "$iteration" -gt 1 ] && [ "$current_total" -ge "$PREV_TOTAL_ISSUES" ] && [ "$PREV_TOTAL_ISSUES" -lt 999 ]; then
        log "STALL DETECTED: Issue count did not decrease ($PREV_TOTAL_ISSUES -> $current_total)."
        log "Fix agents may not have resolved any issues. Stopping to avoid infinite loop."
        return 0  # Stalled
    fi
    return 1  # Not stalled
}

# =============================================================================
# Loop Termination Check
# =============================================================================
should_continue() {
    local iteration=$1

    # Check P0 + P1 = 0
    if [ "${P0_COUNT:-0}" -eq 0 ] && [ "${P1_COUNT:-0}" -eq 0 ]; then
        if [ "$EXIT_ON_P2" = true ] && [ "${P2_COUNT:-0}" -gt 0 ]; then
            log "P0/P1 resolved but P2 issues remain ($P2_COUNT). Continuing (--exit-on-p2 set)."
            return 0  # Continue to fix P2
        fi
        log "All P0 and P1 issues resolved! ($P2_COUNT P2, $P3_COUNT P3 remaining)"
        return 1  # Stop
    fi

    # Max iterations
    if [ "$iteration" -ge "$MAX_ITERATIONS" ]; then
        log "Max iterations ($MAX_ITERATIONS) reached. Stopping."
        log "Remaining: P0=$P0_COUNT  P1=$P1_COUNT  P2=$P2_COUNT  P3=$P3_COUNT"
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

for iteration in $(seq 1 "$MAX_ITERATIONS"); do
    LAST_ITERATION=$iteration
    log_section "=== ITERATION $iteration / $MAX_ITERATIONS ==="

    # Phase 1: Capture + Deploy
    run_capture "$iteration"

    # Phase 2: Review
    run_review "$iteration"

    # Phase 3: Triage
    parse_issues "$iteration"

    # Check if we should fix or stop
    if [ "$REVIEW_ONLY" = true ]; then
        log "Review-only mode. Report written to $REPORT_FILE"
        break
    fi

    if [ "${P0_COUNT:-0}" -eq 0 ] && [ "${P1_COUNT:-0}" -eq 0 ]; then
        log "No P0/P1 issues found. Done!"
        break
    fi

    # Phase 4: Fix (parallel agents in worktrees)
    run_fixes "$iteration"

    # Phase 5: Merge fix branches
    merge_fixes "$iteration"

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
log_section "Design Review Loop — Complete"
log "Iterations run: $LAST_ITERATION"
log "Final issue counts: P0=${P0_COUNT:-?}  P1=${P1_COUNT:-?}  P2=${P2_COUNT:-?}  P3=${P3_COUNT:-?}"
log "Report: $REPORT_FILE"
log "Loop artifacts: $LOOP_DIR"
log "Loop log: $LOOP_LOG"

if [ "${P0_COUNT:-0}" -eq 0 ] && [ "${P1_COUNT:-0}" -eq 0 ]; then
    log "STATUS: ALL P0/P1 ISSUES RESOLVED"
    exit 0
else
    log "STATUS: ISSUES REMAIN — manual review needed"
    exit 1
fi
