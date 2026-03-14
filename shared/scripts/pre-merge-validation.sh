#!/bin/bash
# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.
#
# Pre-Merge Validation Script
# Runs all regression tests across both platforms before merge.
# Exit code 0 = all checks pass, non-zero = regression detected.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
SKIPPED=0
FAILURES=""

log_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
}

log_pass() {
    echo -e "${GREEN}  ✅ PASS: $1${NC}"
    PASSED=$((PASSED + 1))
}

log_fail() {
    echo -e "${RED}  ❌ FAIL: $1${NC}"
    FAILED=$((FAILED + 1))
    FAILURES="${FAILURES}\n  - $1"
}

log_skip() {
    echo -e "${YELLOW}  ⚠️  SKIP: $1${NC}"
    SKIPPED=$((SKIPPED + 1))
}

log_info() {
    echo -e "  $1"
}

# ─────────────────────────────────────────────────────────────
# 1. iOS Unit Tests
# ─────────────────────────────────────────────────────────────
log_header "1/8  iOS Unit Tests"
if command -v swift &>/dev/null; then
    cd "$REPO_ROOT/ios"
    if swift test 2>&1 | tail -5; then
        log_pass "iOS unit tests"
    else
        log_fail "iOS unit tests"
    fi
    cd "$REPO_ROOT"
else
    log_skip "Swift not available — skipping iOS tests"
fi

# ─────────────────────────────────────────────────────────────
# 2. Android Unit Tests
# ─────────────────────────────────────────────────────────────
log_header "2/8  Android Unit Tests"
if [ -f "$REPO_ROOT/android/gradlew" ]; then
    cd "$REPO_ROOT/android"
    if ./gradlew test 2>&1 | tail -5; then
        log_pass "Android unit tests"
    else
        log_fail "Android unit tests"
    fi
    cd "$REPO_ROOT"
else
    log_skip "Gradle wrapper not found — skipping Android tests"
fi

# ─────────────────────────────────────────────────────────────
# 3. iOS Visual Snapshot Regression Tests
# ─────────────────────────────────────────────────────────────
log_header "3/8  iOS Visual Snapshot Tests"
if command -v xcodebuild &>/dev/null; then
    cd "$REPO_ROOT/ios"
    if xcodebuild test \
        -scheme AdaptiveCards-Package \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
        -only-testing:VisualTests/CardElementSnapshotTests \
        CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
        2>&1 | tail -10; then
        log_pass "iOS visual snapshot tests"
    else
        log_fail "iOS visual snapshot tests"
    fi
    cd "$REPO_ROOT"
else
    log_skip "xcodebuild not available — skipping iOS visual tests"
fi

# ─────────────────────────────────────────────────────────────
# 4. Android Paparazzi Snapshot Tests
# ─────────────────────────────────────────────────────────────
log_header "4/8  Android Paparazzi Snapshot Tests"
if [ -f "$REPO_ROOT/android/gradlew" ]; then
    cd "$REPO_ROOT/android"
    if ./gradlew :ac-rendering:verifyPaparazziDebug 2>&1 | tail -5; then
        log_pass "Android Paparazzi snapshot tests"
    else
        log_fail "Android Paparazzi snapshot tests"
    fi
    cd "$REPO_ROOT"
else
    log_skip "Gradle wrapper not found — skipping Android snapshot tests"
fi

# ─────────────────────────────────────────────────────────────
# 5. Card Parsing Regression Tests
# ─────────────────────────────────────────────────────────────
log_header "5/8  Card Parsing Regression Tests"
if command -v swift &>/dev/null; then
    cd "$REPO_ROOT/ios"
    if swift test --filter CardParsingRegressionTests 2>&1 | tail -5; then
        log_pass "Card parsing regression tests"
    else
        log_fail "Card parsing regression tests"
    fi
    cd "$REPO_ROOT"
else
    log_skip "Swift not available — skipping card parsing tests"
fi

# ─────────────────────────────────────────────────────────────
# 6. Schema Parity Check
# ─────────────────────────────────────────────────────────────
log_header "6/8  Schema Parity Check"
if [ -f "$SCRIPT_DIR/compare-schema-coverage.sh" ]; then
    if bash "$SCRIPT_DIR/compare-schema-coverage.sh" 2>&1 | tail -5; then
        log_pass "Schema parity check"
    else
        log_fail "Schema parity check — iOS/Android element type count mismatch"
    fi
else
    log_skip "compare-schema-coverage.sh not found"
fi

# ─────────────────────────────────────────────────────────────
# 7. Test Card JSON Validation
# ─────────────────────────────────────────────────────────────
log_header "7/8  Test Card JSON Validation"
if [ -f "$SCRIPT_DIR/validate-test-cards.sh" ]; then
    if bash "$SCRIPT_DIR/validate-test-cards.sh" 2>&1 | tail -5; then
        log_pass "Test card JSON validation"
    else
        log_fail "Test card JSON validation — invalid JSON in shared/test-cards/"
    fi
else
    log_skip "validate-test-cards.sh not found"
fi

# ─────────────────────────────────────────────────────────────
# 8. Template Card Dual-Platform Tests
# ─────────────────────────────────────────────────────────────
log_header "8/8  Template Card Dual-Platform Tests"
if [ -f "$SCRIPT_DIR/test-template-cards-dual.sh" ]; then
    log_info "Running template card tests on both platforms..."
    log_info "(This requires iOS Simulator and Android Emulator to be running)"
    if bash "$SCRIPT_DIR/test-template-cards-dual.sh" 2>&1 | tail -10; then
        log_pass "Template card dual-platform tests"
    else
        log_fail "Template card dual-platform tests"
    fi
else
    log_skip "test-template-cards-dual.sh not found"
fi

# ─────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PRE-MERGE VALIDATION SUMMARY${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}Passed:  $PASSED${NC}"
echo -e "  ${RED}Failed:  $FAILED${NC}"
echo -e "  ${YELLOW}Skipped: $SKIPPED${NC}"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}  REGRESSIONS DETECTED — DO NOT MERGE${NC}"
    echo -e "${RED}  Failed checks:${FAILURES}${NC}"
    echo ""
    exit 1
else
    echo ""
    echo -e "${GREEN}  ALL CHECKS PASSED — SAFE TO MERGE${NC}"
    echo ""
    exit 0
fi
