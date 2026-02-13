#!/bin/bash
# Schema Coverage Comparison Script
# Compares element types and action types across iOS and Android platforms
# Fails if there's a significant parity gap between platforms

set -e

echo "========================================="
echo "  Schema Coverage Parity Check"
echo "========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directories
IOS_VALIDATOR="ios/Sources/ACCore/SchemaValidator.swift"
ANDROID_VALIDATOR="android/ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/SchemaValidator.kt"

# Temp files
IOS_ELEMENTS="/tmp/ios-elements.txt"
IOS_ACTIONS="/tmp/ios-actions.txt"
ANDROID_ELEMENTS="/tmp/android-elements.txt"
ANDROID_ACTIONS="/tmp/android-actions.txt"

# Extract element types from iOS
echo "Extracting iOS element types..."
if [ -f "$IOS_VALIDATOR" ]; then
    # Extract from validElementTypes set - stop at closing bracket
    grep -A 20 "validElementTypes" "$IOS_VALIDATOR" | \
        grep -o '"[^"]*"' | \
        tr -d '"' | \
        grep -E "^[A-Z]|^Input\." | \
        sort -u > "$IOS_ELEMENTS"
    
    # Extract action types
    grep -A 10 "validActionTypes" "$IOS_VALIDATOR" | \
        grep -o '"Action\.[^"]*"' | \
        tr -d '"' | \
        sort -u > "$IOS_ACTIONS"
else
    echo -e "${RED}Error: iOS SchemaValidator not found${NC}"
    exit 1
fi

# Extract element types from Android
echo "Extracting Android element types..."
if [ -f "$ANDROID_VALIDATOR" ]; then
    # Extract from VALID_ELEMENT_TYPES set - stop at closing paren
    grep -A 20 "VALID_ELEMENT_TYPES" "$ANDROID_VALIDATOR" | \
        grep -o '"[^"]*"' | \
        tr -d '"' | \
        grep -E "^[A-Z]|^Input\." | \
        sort -u > "$ANDROID_ELEMENTS"
    
    # Extract action types
    grep -A 10 "VALID_ACTION_TYPES" "$ANDROID_VALIDATOR" | \
        grep -o '"Action\.[^"]*"' | \
        tr -d '"' | \
        sort -u > "$ANDROID_ACTIONS"
else
    echo -e "${RED}Error: Android SchemaValidator not found${NC}"
    exit 1
fi

# Count elements
ios_element_count=$(cat "$IOS_ELEMENTS" | wc -l)
android_element_count=$(cat "$ANDROID_ELEMENTS" | wc -l)
ios_action_count=$(cat "$IOS_ACTIONS" | wc -l)
android_action_count=$(cat "$ANDROID_ACTIONS" | wc -l)

echo ""
echo "Element Type Counts:"
echo "  iOS:     $ios_element_count"
echo "  Android: $android_element_count"
echo ""
echo "Action Type Counts:"
echo "  iOS:     $ios_action_count"
echo "  Android: $android_action_count"
echo ""

# Check for differences in elements
echo "Checking element type parity..."
element_diff=$(diff "$IOS_ELEMENTS" "$ANDROID_ELEMENTS" 2>/dev/null || true)
if [ -z "$element_diff" ]; then
    echo -e "${GREEN}✅ Element types match perfectly${NC}"
else
    echo -e "${YELLOW}⚠️  Element type differences detected${NC}"
fi

# Check for differences in actions
echo "Checking action type parity..."
action_diff=$(diff "$IOS_ACTIONS" "$ANDROID_ACTIONS" 2>/dev/null || true)
if [ -z "$action_diff" ]; then
    echo -e "${GREEN}✅ Action types match perfectly${NC}"
else
    echo -e "${YELLOW}⚠️  Action type differences detected${NC}"
fi

# Calculate differences
element_count_diff=$((ios_element_count - android_element_count))
element_count_diff=${element_count_diff#-}  # absolute value
action_count_diff=$((ios_action_count - android_action_count))
action_count_diff=${action_count_diff#-}  # absolute value

# Fail if difference is too large
THRESHOLD=2
failed=0

if [ "$element_count_diff" -gt "$THRESHOLD" ]; then
    echo -e "${RED}❌ Significant element type parity gap detected (difference > $THRESHOLD)${NC}"
    echo "Please ensure new elements are implemented on both platforms"
    failed=1
fi

if [ "$action_count_diff" -gt "$THRESHOLD" ]; then
    echo -e "${RED}❌ Significant action type parity gap detected (difference > $THRESHOLD)${NC}"
    echo "Please ensure new actions are implemented on both platforms"
    failed=1
fi

# List elements only on iOS
echo ""
echo "Elements only in iOS:"
ios_only=$(comm -23 "$IOS_ELEMENTS" "$ANDROID_ELEMENTS" 2>/dev/null || echo "")
if [ -z "$ios_only" ]; then
    echo "  (none)"
else
    echo "$ios_only" | sed 's/^/  /'
fi

echo ""
echo "Elements only in Android:"
android_only=$(comm -13 "$IOS_ELEMENTS" "$ANDROID_ELEMENTS" 2>/dev/null || echo "")
if [ -z "$android_only" ]; then
    echo "  (none)"
else
    echo "$android_only" | sed 's/^/  /'
fi

echo ""
echo "Actions only in iOS:"
ios_actions_only=$(comm -23 "$IOS_ACTIONS" "$ANDROID_ACTIONS" 2>/dev/null || echo "")
if [ -z "$ios_actions_only" ]; then
    echo "  (none)"
else
    echo "$ios_actions_only" | sed 's/^/  /'
fi

echo ""
echo "Actions only in Android:"
android_actions_only=$(comm -13 "$IOS_ACTIONS" "$ANDROID_ACTIONS" 2>/dev/null || echo "")
if [ -z "$android_actions_only" ]; then
    echo "  (none)"
else
    echo "$android_actions_only" | sed 's/^/  /'
fi

echo ""
echo "========================================="
if [ "$failed" -eq 1 ]; then
    echo -e "${RED}❌ Parity check FAILED${NC}"
    echo "========================================="
    exit 1
else
    echo -e "${GREEN}✅ Parity check PASSED${NC}"
    echo "========================================="
fi

# Cleanup
rm -f "$IOS_ELEMENTS" "$IOS_ACTIONS" "$ANDROID_ELEMENTS" "$ANDROID_ACTIONS"

exit 0
