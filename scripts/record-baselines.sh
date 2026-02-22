#!/usr/bin/env bash
set -euo pipefail

# =============================================================
# Record Visual Regression Baselines
# =============================================================
#
# Records baseline images for visual regression testing on both
# iOS (custom SnapshotTestCase) and Android (Paparazzi).
#
# Usage:
#   ./scripts/record-baselines.sh            # Record all
#   ./scripts/record-baselines.sh ios        # iOS only
#   ./scripts/record-baselines.sh android    # Android only
#   ./scripts/record-baselines.sh verify     # Verify only (no recording)
#
# =============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PLATFORM="${1:-all}"
CARD_COUNT=$(find "$ROOT_DIR/shared/test-cards" -name "*.json" | wc -l | tr -d ' ')

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Adaptive Cards Visual Regression Baseline Tool          ║"
echo "╠═══════════════════════════════════════════════════════════╣"
echo "║  Test Cards: $CARD_COUNT files discovered"
echo "║  Platform:   $PLATFORM"
echo "║  Mode:       $([ "$PLATFORM" = "verify" ] && echo "VERIFY" || echo "RECORD")"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Show card breakdown
echo "📋 Card Inventory:"
echo "   Top-level:       $(ls "$ROOT_DIR/shared/test-cards/"*.json 2>/dev/null | wc -l | tr -d ' ') cards"
for dir in "$ROOT_DIR/shared/test-cards"/*/; do
    [ -d "$dir" ] && echo "   $(basename "$dir"): $(find "$dir" -name '*.json' | wc -l | tr -d ' ') cards"
done
echo ""

# ---------------------------------------------------------------
# iOS Baselines
# ---------------------------------------------------------------
record_ios() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🍎 Recording iOS baselines..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd "$ROOT_DIR/ios"

    # Parse validation first (fast fail)
    echo "→ Step 1/3: Validating all cards parse..."
    swift test --filter "AllCardsDiscoveryTests/testAllCards_parseOnly" 2>&1 | tail -20
    echo ""

    # Record baselines
    echo "→ Step 2/3: Recording snapshot baselines (smoke test)..."
    RECORD_SNAPSHOTS=1 swift test --filter "AllCardsDiscoveryTests/testAllCards_smokeTest" 2>&1 | tail -30
    echo ""

    echo "→ Step 3/3: Recording snapshot baselines (core matrix)..."
    RECORD_SNAPSHOTS=1 swift test --filter "AllCardsDiscoveryTests/testAllCards_coreMatrix" 2>&1 | tail -30
    echo ""

    # Count baselines
    BASELINE_COUNT=$(find "$ROOT_DIR/ios/Tests/VisualTests/Snapshots/Baselines" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ iOS baselines recorded: $BASELINE_COUNT images"
    echo ""
}

verify_ios() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🍎 Verifying iOS snapshots..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd "$ROOT_DIR/ios"
    swift test --filter "VisualTests" 2>&1 | tail -40
    echo ""
}

# ---------------------------------------------------------------
# Android Baselines
# ---------------------------------------------------------------
record_android() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🤖 Recording Android Paparazzi baselines..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd "$ROOT_DIR/android"
    ./gradlew :ac-rendering:recordPaparazziDebug --stacktrace 2>&1 | tail -20
    echo ""

    BASELINE_COUNT=$(find "$ROOT_DIR/android/ac-rendering/src/test/snapshots" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ Android baselines recorded: $BASELINE_COUNT images"
    echo ""
}

verify_android() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🤖 Verifying Android Paparazzi snapshots..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd "$ROOT_DIR/android"
    ./gradlew :ac-rendering:verifyPaparazziDebug --stacktrace 2>&1 | tail -20
    echo ""
}

# ---------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------
case "$PLATFORM" in
    ios)
        record_ios
        ;;
    android)
        record_android
        ;;
    verify)
        verify_ios
        verify_android
        ;;
    all|*)
        record_ios
        record_android
        ;;
esac

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Done!                                                   ║"
echo "║                                                          ║"
echo "║  Next steps:                                             ║"
echo "║  1. Review baselines in Snapshots/Baselines/             ║"
echo "║  2. Commit baseline images: git add -A && git commit     ║"
echo "║  3. Push to trigger CI verification                      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
