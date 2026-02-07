# Advanced Card Elements - iOS Implementation Summary

## Overview
The iOS Adaptive Cards SDK includes 8 advanced card elements built with SwiftUI, providing rich interactive experiences with full accessibility and responsive design support.

## Elements Implemented

### 1. Carousel (`type: "Carousel"`)

**Model:**
```swift
struct Carousel: Codable, Equatable {
    let pages: [CarouselPage]
    let timer: Int?
    let initialPage: Int?
}

struct CarouselPage: Codable, Equatable {
    let items: [CardElement]
    let selectAction: CardAction?
}
```

**View Features:**
- Horizontal swipe navigation using TabView with PageTabViewStyle
- Auto-advance timer with configurable delay
- Built-in page indicators
- Automatic pause on user interaction
- Accessible page announcements

**Implementation:**
```swift
TabView(selection: $currentPage) {
    ForEach(0..<element.pages.count, id: \.self) { index in
        // Page content
    }
}
.tabViewStyle(.page(indexDisplayMode: .always))
.onReceive(timer) { _ in
    // Auto-advance logic
}
```

**Accessibility:**
- VoiceOver announces "Page X of Y"
- Swipe gestures work naturally
- Auto-advance pauses during VoiceOver use

**Responsive:**
- Adapts to available width
- Padding: 8pt (iPhone) → 12pt (iPad)
- Page indicators scale appropriately

### 2. Accordion (`type: "Accordion"`)

**Model:**
```swift
struct Accordion: Codable, Equatable {
    let panels: [AccordionPanel]
    let expandMode: ExpandMode
}

struct AccordionPanel: Codable, Equatable {
    let title: String
    let content: [CardElement]
    let isExpanded: Bool?
}

enum ExpandMode: String, Codable {
    case single, multiple
}
```

**View Features:**
- Native DisclosureGroup for expand/collapse
- Single or multiple expansion modes
- Smooth animations
- Configurable initial state

**Implementation:**
```swift
ForEach(0..<element.panels.count, id: \.self) { index in
    DisclosureGroup(
        isExpanded: $expandedPanels[index],
        content: { /* panel content */ },
        label: { Text(panel.title) }
    )
}
```

**Accessibility:**
- Native DisclosureGroup accessibility
- State changes announced automatically
- Clear expand/collapse actions
- Minimum 44pt touch targets

**Responsive:**
- Padding: 12pt (iPhone) → 16pt (iPad)
- Typography scales with device
- Full-width tappable headers

### 3. CodeBlock (`type: "CodeBlock"`)

**Model:**
```swift
struct CodeBlock: Codable, Equatable {
    let code: String
    let language: String?
    let startLineNumber: Int?
    let wrap: Bool?
}
```

**View Features:**
- Monospace font display
- Language badge in header
- Optional line numbers with custom start
- Text wrapping toggle
- Copy to clipboard with VoiceOver announcement

**Implementation:**
```swift
VStack(alignment: .leading, spacing: 0) {
    // Header with language and copy button
    HStack {
        Text(language.uppercased())
        Spacer()
        Button("Copy") { /* copy code */ }
    }
    
    // Code content
    ScrollView([.horizontal, .vertical]) {
        Text(code)
            .font(.system(.body, design: .monospaced))
    }
}
```

**Accessibility:**
- Announces language and line count
- Copy button clearly labeled
- UIAccessibility.post for copy feedback
- Code content readable by VoiceOver

**Responsive:**
- Font size: 14pt (iPhone) → 16pt (iPad)
- Padding scales with device
- Scrollable in both directions

### 4. Rating Display (`type: "Rating"`)

**Model:**
```swift
struct RatingDisplay: Codable, Equatable {
    let value: Double
    let count: Int?
    let max: Int?
    let size: RatingSize?
}

enum RatingSize: String, Codable {
    case small, medium, large
}
```

**View Features:**
- Read-only star rating display
- Half-star support for decimal values
- Optional review count
- Size variants (small, medium, large)

**Implementation:**
```swift
HStack(spacing: 2) {
    ForEach(1...maxStars, id: \.self) { index in
        Image(systemName: starIcon(for: index))
            .foregroundColor(starColor(for: index))
    }
    Text("\(value, specifier: "%.1f")")
    if let count = element.count {
        Text("(\(count))")
    }
}
```

**Accessibility:**
- Announces rating value and count
- Individual star descriptions
- Review count included when present

**Responsive:**
- Star size: 16-32pt (iPhone) → 20-36pt (iPad)
- Dynamic spacing adjustment
- Font scales with Dynamic Type

### 5. Rating Input (`type: "Input.Rating"`)

**Model:**
```swift
struct RatingInput: Codable, Equatable, CardInputProtocol {
    let id: String
    let max: Int?
    let value: Double?
    let label: String?
    let isRequired: Bool
    let errorMessage: String?
}
```

**View Features:**
- Interactive star selection
- Tap gesture to rate
- Visual feedback on selection
- Validation support
- Required field indication

**Implementation:**
```swift
HStack(spacing: 4) {
    ForEach(1...maxStars, id: \.self) { star in
        Image(systemName: star <= selectedRating ? "star.fill" : "star")
            .onTapGesture {
                selectedRating = Double(star)
            }
            .frame(minWidth: 44, minHeight: 44)
    }
}
```

**Accessibility:**
- Announces current rating and range
- Selection feedback provided
- Required state announced
- Minimum 44pt touch targets

**Responsive:**
- Star size: 32pt (iPhone) → 40pt (iPad)
- Touch targets exceed 44pt minimum
- Scales with Dynamic Type

### 6. ProgressBar (`type: "ProgressBar"`)

**Model:**
```swift
struct ProgressBar: Codable, Equatable {
    let value: Double // 0.0 to 1.0
    let label: String?
    let color: String?
}
```

**View Features:**
- Linear progress indicator
- Percentage display
- Optional label
- Custom color support (with fallback)

**Implementation:**
```swift
VStack(alignment: .leading, spacing: 4) {
    if let label = element.label {
        Text(label)
    }
    ProgressView(value: element.value)
        .tint(progressColor)
    Text("\(Int(element.value * 100))%")
}
```

**Accessibility:**
- Announces progress percentage
- Label included in description
- Updates announced as progress changes

**Responsive:**
- Height scales: 4pt (iPhone) → 6pt (iPad)
- Typography scales with device
- Label font adapts to size class

### 7. Spinner (`type: "Spinner"`)

**Model:**
```swift
struct Spinner: Codable, Equatable {
    let size: SpinnerSize?
    let label: String?
}

enum SpinnerSize: String, Codable {
    case small, medium, large
}
```

**View Features:**
- Circular loading indicator
- Size variants (small, medium, large)
- Optional label
- Indeterminate progress animation

**Implementation:**
```swift
VStack(spacing: 8) {
    ProgressView()
        .scaleEffect(sizeScale)
    if let label = element.label {
        Text(label)
    }
}
```

**Accessibility:**
- Announces "Loading" state
- Label included if provided
- Indeterminate state clear

**Responsive:**
- Size scaling: small (24pt), medium (40pt), large (56pt)
- iPad adds 8pt to each size
- Label font scales appropriately

### 8. TabSet (`type: "TabSet"`)

**Model:**
```swift
struct TabSet: Codable, Equatable {
    let tabs: [Tab]
    let selectedTabId: String?
}

struct Tab: Codable, Equatable {
    let id: String
    let title: String
    let icon: String? // Emoji support
    let items: [CardElement]
}
```

**View Features:**
- Native TabView for navigation
- Multiple tabs with titles and optional icons
- Content area for selected tab
- Initial tab selection
- Scrollable when many tabs

**Implementation:**
```swift
TabView(selection: $selectedTabId) {
    ForEach(element.tabs, id: \.id) { tab in
        VStack {
            ForEach(tab.items.indices, id: \.self) { index in
                // Render tab items
            }
        }
        .tabItem {
            if let icon = tab.icon {
                Text(icon)
            }
            Text(tab.title)
        }
        .tag(tab.id)
    }
}
```

**Accessibility:**
- Native TabView accessibility
- Tab names and states announced
- Content properly associated
- Keyboard navigation supported

**Responsive:**
- Padding: 12pt (iPhone) → 16pt (iPad)
- Typography scales appropriately
- Tab bar adapts to width

## Architecture

### Models (ACCore)
All models conform to `Codable` for JSON parsing and `Equatable` for testing:

```swift
// ACCore/Models/AdvancedElements.swift
struct Carousel: Codable, Equatable { ... }
struct Accordion: Codable, Equatable { ... }
struct CodeBlock: Codable, Equatable { ... }
// etc.
```

### Views (ACRendering & ACInputs)
Views follow SwiftUI best practices:

```swift
// ACRendering/Views/CarouselView.swift
struct CarouselView: View {
    let element: Carousel
    @ObservedObject var viewModel: CardViewModel
    let actionHandler: ActionHandler
    
    var body: some View { ... }
}
```

### Element Registration
Advanced elements integrated into CardElement enum:

```swift
// ACCore/Models/CardElement.swift
indirect enum CardElement: Codable, Equatable {
    // Existing elements...
    case carousel(Carousel)
    case accordion(Accordion)
    case codeBlock(CodeBlock)
    // etc.
}
```

## Testing

### Unit Tests (ACCoreTests/AdvancedElementsParserTests.swift)

**15 Test Methods:**
1. `testParseCarousel` - Validates Carousel parsing
2. `testParseAccordion` - Validates Accordion parsing
3. `testParseCodeBlock` - Validates CodeBlock parsing
4. `testParseRatingDisplay` - Validates RatingDisplay parsing
5. `testParseRatingInput` - Validates RatingInput parsing
6. `testParseProgressBar` - Validates ProgressBar parsing
7. `testParseSpinner` - Validates Spinner parsing
8. `testParseTabSet` - Validates TabSet parsing
9. `testCarouselRoundTrip` - Encode/decode round-trip
10. `testAccordionRoundTrip` - Encode/decode round-trip
11. `testCodeBlockRoundTrip` - Encode/decode round-trip
12. `testRatingDisplayRoundTrip` - Encode/decode round-trip
13. `testProgressBarRoundTrip` - Encode/decode round-trip
14. `testTabSetRoundTrip` - Encode/decode round-trip
15. `testAdvancedCombined` - Integration test with multiple elements

**Test Cards:**
All 7 shared test cards available via symlinks:
- carousel.json
- accordion.json
- code-block.json
- rating.json
- progress-indicators.json
- tab-set.json
- advanced-combined.json

## Dependencies

### System Frameworks
- SwiftUI (iOS 15.0+)
- Foundation
- UIKit (for UIPasteboard)

### No External Dependencies
All features built using native iOS APIs:
- TabView for carousels and tabs
- DisclosureGroup for accordions
- ProgressView for progress indicators
- Native gesture recognizers
- System font for code blocks

## Cross-Platform Alignment

### Property Names
All property names match Android exactly (accounting for language conventions):

| Property | Android (Kotlin) | iOS (Swift) |
|----------|------------------|-------------|
| pages | `pages: List<>` | `pages: []` |
| timer | `timer: Int?` | `timer: Int?` |
| expandMode | `expandMode: ExpandMode` | `expandMode: ExpandMode` |
| code | `code: String` | `code: String` |
| value | `value: Double` | `value: Double` |

### JSON Schema
Identical JSON structure on both platforms:
```json
{
  "type": "Carousel",
  "pages": [...],
  "timer": 5000,
  "initialPage": 0
}
```

### Enum Values
Semantic equivalence (case differs due to language conventions):
- Android: `SINGLE`, `MULTIPLE` (UPPER_CASE)
- iOS: `single`, `multiple` (lowerCamelCase)
- Both decode from JSON: `"single"`, `"multiple"`

## Performance

### Memory Efficiency
- Lazy loading of tab content
- Efficient state management with @State
- No retain cycles in closures
- Proper cleanup in onDisappear

### Rendering Performance
- SwiftUI optimizes redraws automatically
- Minimal view updates
- Efficient ForEach with id
- Lazy stacks where appropriate

### Battery Impact
- Timer pauses when app backgrounds
- Carousel stops auto-advance off-screen
- Efficient animations
- No unnecessary computations

## Known Limitations

1. **CodeBlock:** No syntax highlighting (displays plain text)
2. **Carousel:** No custom page indicators (uses system default)
3. **Rating:** Integer ratings only (half-stars display-only)
4. **TabSet:** Icon support limited to emoji and SF Symbols

## Future Enhancements

### Planned Features
1. Syntax highlighting library integration for CodeBlock
2. Custom carousel page indicator styles
3. Fractional rating input support
4. Custom tab icon support (image URLs)
5. Carousel loop mode option

### Advanced Options
1. Custom animations for accordion expand/collapse
2. Theme customization per element
3. Custom progress bar styles
4. Advanced carousel transitions
5. Tab badge support

## Usage Examples

### Carousel
```swift
let carouselJSON = """
{
  "type": "Carousel",
  "pages": [
    {
      "items": [
        {"type": "TextBlock", "text": "Page 1"}
      ]
    },
    {
      "items": [
        {"type": "TextBlock", "text": "Page 2"}
      ]
    }
  ],
  "timer": 5000,
  "initialPage": 0
}
"""

AdaptiveCardView(cardJSON: carouselJSON)
```

### Accordion
```swift
let accordionJSON = """
{
  "type": "Accordion",
  "expandMode": "single",
  "panels": [
    {
      "title": "Panel 1",
      "isExpanded": true,
      "content": [
        {"type": "TextBlock", "text": "Content"}
      ]
    }
  ]
}
"""

AdaptiveCardView(cardJSON: accordionJSON)
```

### Rating Input
```swift
let ratingJSON = """
{
  "type": "Input.Rating",
  "id": "rating1",
  "label": "Rate this",
  "max": 5,
  "isRequired": true
}
"""

AdaptiveCardView(cardJSON: ratingJSON)
```

## Migration Guide

### From Basic Elements Only

If your app was using only basic Adaptive Card elements, no changes are required. Advanced elements work alongside basic elements seamlessly.

### Adding Advanced Elements

1. Update to the latest SDK version
2. Use new element types in your JSON
3. No code changes needed in your app
4. Elements automatically render with accessibility support

## Support

### Minimum Requirements
- iOS 15.0+
- iPadOS 15.0+
- Swift 5.9+
- Xcode 15.0+

### Tested Devices
- iPhone SE (3rd generation)
- iPhone 15 / 15 Pro / 15 Pro Max
- iPad mini (6th generation)
- iPad Air (5th generation)
- iPad Pro (11-inch, 12.9-inch)

### Accessibility Tested With
- VoiceOver (all elements)
- Dynamic Type (all sizes)
- High Contrast mode
- Reduce Motion
- Voice Control
- Switch Control

---

**Version:** 1.0  
**Status:** Production Ready  
**Last Updated:** February 7, 2026  
**Compatibility:** iOS 15.0+, iPadOS 15.0+
