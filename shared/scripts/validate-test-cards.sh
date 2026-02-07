#!/bin/bash
# Script to validate all JSON files in shared/test-cards/ directory
# Checks for valid JSON format and required AdaptiveCard fields

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_CARDS_DIR="$(cd "${SCRIPT_DIR}/../test-cards" && pwd)"

echo "Validating test cards in: $TEST_CARDS_DIR"
echo "----------------------------------------"

# Check if jq is available for JSON validation
if ! command -v jq &> /dev/null; then
    echo "Warning: jq not found. Using basic JSON validation only."
    HAS_JQ=false
else
    HAS_JQ=true
fi

# Track validation results
TOTAL_CARDS=0
VALID_CARDS=0
INVALID_CARDS=0
FAILED_FILES=()

# Iterate over all .json files in the test-cards directory
for json_file in "$TEST_CARDS_DIR"/*.json; do
    if [ ! -f "$json_file" ]; then
        continue
    fi
    
    TOTAL_CARDS=$((TOTAL_CARDS + 1))
    filename=$(basename "$json_file")
    
    # Check if file is valid JSON
    if [ "$HAS_JQ" = true ]; then
        if ! jq empty "$json_file" 2>/dev/null; then
            echo "❌ INVALID JSON: $filename"
            INVALID_CARDS=$((INVALID_CARDS + 1))
            FAILED_FILES+=("$filename - Invalid JSON format")
            continue
        fi
    else
        # Basic validation using python if jq is not available
        if ! python3 -m json.tool "$json_file" > /dev/null 2>&1; then
            echo "❌ INVALID JSON: $filename"
            INVALID_CARDS=$((INVALID_CARDS + 1))
            FAILED_FILES+=("$filename - Invalid JSON format")
            continue
        fi
    fi
    
    # Check for required AdaptiveCard fields
    if [ "$HAS_JQ" = true ]; then
        card_type=$(jq -r '.type // "missing"' "$json_file")
        card_version=$(jq -r '.version // "missing"' "$json_file")
    else
        # Use python to extract fields
        card_type=$(python3 -c "import json; f=open('$json_file'); d=json.load(f); print(d.get('type', 'missing'))" 2>/dev/null || echo "error")
        card_version=$(python3 -c "import json; f=open('$json_file'); d=json.load(f); print(d.get('version', 'missing'))" 2>/dev/null || echo "error")
    fi
    
    # Validate required fields
    if [ "$card_type" != "AdaptiveCard" ]; then
        echo "❌ MISSING/INVALID TYPE: $filename (type: $card_type)"
        INVALID_CARDS=$((INVALID_CARDS + 1))
        FAILED_FILES+=("$filename - Missing or invalid 'type' field (expected 'AdaptiveCard')")
        continue
    fi
    
    if [ "$card_version" = "missing" ] || [ "$card_version" = "error" ]; then
        echo "❌ MISSING VERSION: $filename"
        INVALID_CARDS=$((INVALID_CARDS + 1))
        FAILED_FILES+=("$filename - Missing 'version' field")
        continue
    fi
    
    # Card is valid
    echo "✅ VALID: $filename (version: $card_version)"
    VALID_CARDS=$((VALID_CARDS + 1))
done

# Print summary
echo ""
echo "========================================"
echo "Validation Summary"
echo "========================================"
echo "Total cards: $TOTAL_CARDS"
echo "Valid cards: $VALID_CARDS"
echo "Invalid cards: $INVALID_CARDS"

if [ $INVALID_CARDS -gt 0 ]; then
    echo ""
    echo "Failed validations:"
    for failed in "${FAILED_FILES[@]}"; do
        echo "  - $failed"
    done
    echo ""
    echo "❌ Validation FAILED"
    exit 1
else
    echo ""
    echo "✅ All test cards are valid!"
    exit 0
fi
