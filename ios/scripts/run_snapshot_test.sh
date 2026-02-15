#!/usr/bin/env bash
# Run snapshot tests for AdaptiveCards iOS
# Usage:
#   ./scripts/run_snapshot_test.sh                          # Run all snapshot tests
#   ./scripts/run_snapshot_test.sh testTextBlockBasic        # Run specific test
#   ./scripts/run_snapshot_test.sh testTextBlockBasic --log  # Run + save full log
#   ./scripts/run_snapshot_test.sh --build-only              # Build without running
#   ./scripts/run_snapshot_test.sh --check-pixels            # Analyze baseline PNGs

set -euo pipefail
cd "$(dirname "$0")/.."

SCHEME="AdaptiveCards-Package"
SIM_ID="${AC_SIM_ID:-77339DE3-6E63-40E0-A1E4-385BF583EBF7}"
DESTINATION="platform=iOS Simulator,id=$SIM_ID"
BASELINES_DIR="Tests/VisualTests/Snapshots/Baselines"
LOG_DIR="/tmp"

case "${1:-all}" in
  --build-only)
    echo "==> Building for testing..."
    xcodebuild build-for-testing \
      -scheme "$SCHEME" \
      -destination "$DESTINATION" \
      CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO 2>&1 | \
      grep -E "error:|BUILD" | grep -v "Xcode3\|IDE\|DVT" | tail -20
    echo "==> Build complete"
    ;;

  --check-pixels)
    echo "==> Checking baseline pixel content..."
    python3 - "$BASELINES_DIR" <<'PYEOF'
import sys, os
from PIL import Image
from collections import Counter

basedir = sys.argv[1]
pngs = sorted(f for f in os.listdir(basedir) if f.endswith('.png'))
if not pngs:
    print("No PNG baselines found.")
    sys.exit(0)

for fname in pngs:
    path = os.path.join(basedir, fname)
    img = Image.open(path)
    pixels = list(img.getdata())
    total = len(pixels)
    if img.mode == 'RGBA':
        visible = sum(1 for r,g,b,a in pixels if a > 0)
    elif img.mode == 'LA':
        visible = sum(1 for l,a in pixels if a > 0)
    elif img.mode == 'RGB':
        visible = sum(1 for r,g,b in pixels if (r,g,b) != (255,255,255))
    else:
        visible = sum(1 for p in pixels if p > 0)
    pct = 100 * visible / total if total else 0
    status = "OK" if pct > 1 else "EMPTY"
    colors = len(Counter(pixels))
    print(f"  [{status}] {fname}: {img.size} {img.mode} — {pct:.1f}% visible, {colors} unique colors")
PYEOF
    ;;

  --clean)
    echo "==> Cleaning baselines..."
    find "$BASELINES_DIR" -name "*.png" -delete 2>/dev/null || true
    echo "==> Baselines cleaned"
    ;;

  *)
    TEST_NAME="${1:-}"
    SAVE_LOG="${2:-}"
    LOG_FILE="$LOG_DIR/ac_snapshot_$(date +%H%M%S).log"

    ONLY_TESTING=""
    if [[ -n "$TEST_NAME" && "$TEST_NAME" != "all" ]]; then
      ONLY_TESTING="-only-testing:VisualTests/CardElementSnapshotTests/$TEST_NAME"
    fi

    echo "==> Running snapshot test${TEST_NAME:+: $TEST_NAME}..."
    echo "    Simulator: $SIM_ID"
    echo "    Record mode: $([ -f Tests/VisualTests/Snapshots/.record ] && echo YES || echo NO)"

    # CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
    # works around Xcode 26 SPM test target codesign "bundle format unrecognized" errors
    CODESIGN_FLAGS="CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO"

    if [[ "$SAVE_LOG" == "--log" ]]; then
      xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        ${ONLY_TESTING} \
        $CODESIGN_FLAGS > "$LOG_FILE" 2>&1; RC=$?
      echo "==> Full log: $LOG_FILE"
      grep -E "SNAPSHOT_DIAG|Test Case|SNAPSHOT RECORDED|passed|failed|INTERRUPT" "$LOG_FILE" | tail -20
    else
      xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        ${ONLY_TESTING} \
        $CODESIGN_FLAGS 2>&1 | \
        grep -E "SNAPSHOT_DIAG|Test Case|SNAPSHOT RECORDED|passed|failed|INTERRUPT" | tail -20; RC=$?
    fi

    echo ""
    echo "==> Exit code: $RC"

    # Auto-check pixels if baselines exist
    PNG_COUNT=$(find "$BASELINES_DIR" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$PNG_COUNT" -gt 0 ]]; then
      echo "==> $PNG_COUNT baseline(s) found. Run --check-pixels to analyze."
    fi
    ;;
esac
