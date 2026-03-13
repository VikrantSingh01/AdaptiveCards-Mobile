#!/bin/bash
# check-screenshot-text.sh — OCR-based screenshot validation
# Detects unresolved template markers ({ }) or "fail" text in card screenshots.
#
# Uses macOS Vision framework via inline Swift for zero-dependency OCR.
#
# Usage:
#   source shared/scripts/check-screenshot-text.sh
#   check_screenshot_text "/path/to/screenshot.png"
#   # Returns: "TEMPLATE_FAIL: found '{' '}' in rendered text" or "OCR_CLEAN"
#
# Or run standalone:
#   bash shared/scripts/check-screenshot-text.sh /path/to/screenshot.png
#   Exit code: 0 = clean, 1 = curly brackets or fail text detected, 2 = OCR unavailable

# Compile the Swift OCR helper once per session (cached in /tmp)
_OCR_BINARY="/tmp/ac-ocr-check"
_OCR_SOURCE="/tmp/ac-ocr-check.swift"

_ensure_ocr_binary() {
    if [ -x "$_OCR_BINARY" ] && [ "$_OCR_BINARY" -nt "$_OCR_SOURCE" ]; then
        return 0
    fi

    cat > "$_OCR_SOURCE" << 'SWIFT_EOF'
import Foundation
import Vision
import AppKit

guard CommandLine.arguments.count > 1 else {
    fputs("Usage: ac-ocr-check <image-path>\n", stderr)
    exit(2)
}

let imagePath = CommandLine.arguments[1]
guard let image = NSImage(contentsOfFile: imagePath),
      let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    fputs("ERROR: Cannot load image: \(imagePath)\n", stderr)
    exit(2)
}

let request = VNRecognizeTextRequest()
request.recognitionLevel = .accurate
request.usesLanguageCorrection = false

let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
do {
    try handler.perform([request])
} catch {
    fputs("ERROR: OCR failed: \(error)\n", stderr)
    exit(2)
}

guard let observations = request.results else {
    // No text found at all — clean
    print("OCR_CLEAN")
    exit(0)
}

var allText = ""
for observation in observations {
    if let candidate = observation.topCandidates(1).first {
        allText += candidate.string + "\n"
    }
}

// Check for unresolved template markers: curly brackets { or }
// These indicate ${expression} was not resolved by the template engine
let hasCurlyBrackets = allText.contains("{") || allText.contains("}")

// Check for "fail" text (case-insensitive) in the rendered card
let hasFailText = allText.range(of: "fail", options: .caseInsensitive) != nil

// Collect detected issues
var issues: [String] = []
if hasCurlyBrackets {
    // Extract lines containing curly brackets for diagnostic output
    let bracketLines = allText.components(separatedBy: "\n")
        .filter { $0.contains("{") || $0.contains("}") }
        .prefix(3)
        .joined(separator: " | ")
    issues.append("curly brackets: \(bracketLines)")
}
if hasFailText {
    let failLines = allText.components(separatedBy: "\n")
        .filter { $0.range(of: "fail", options: .caseInsensitive) != nil }
        .prefix(3)
        .joined(separator: " | ")
    issues.append("fail text: \(failLines)")
}

if issues.isEmpty {
    print("OCR_CLEAN")
    exit(0)
} else {
    print("TEMPLATE_FAIL: \(issues.joined(separator: "; "))")
    exit(1)
}
SWIFT_EOF

    swiftc -O -o "$_OCR_BINARY" "$_OCR_SOURCE" 2>/dev/null
}

# Main function: check a screenshot for template rendering failures
# Args: $1 = path to screenshot PNG
# Stdout: "OCR_CLEAN" or "TEMPLATE_FAIL: ..."
# Returns: 0 = clean, 1 = template failure detected, 2 = OCR unavailable
check_screenshot_text() {
    local screenshot="$1"

    if [ ! -f "$screenshot" ]; then
        echo "OCR_SKIP"
        return 2
    fi

    _ensure_ocr_binary

    if [ ! -x "$_OCR_BINARY" ]; then
        echo "OCR_UNAVAILABLE"
        return 2
    fi

    "$_OCR_BINARY" "$screenshot" 2>/dev/null
}

# Standalone mode: run directly on a file
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <screenshot.png>"
        exit 2
    fi
    result=$(check_screenshot_text "$1")
    echo "$result"
    case "$result" in
        OCR_CLEAN) exit 0 ;;
        TEMPLATE_FAIL*) exit 1 ;;
        *) exit 2 ;;
    esac
fi
