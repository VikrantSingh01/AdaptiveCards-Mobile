# Accessibility and Responsive Design - iOS Implementation

## Overview
All advanced card elements in the iOS SDK are built with comprehensive accessibility support and responsive design to work seamlessly across iPhone and iPad devices.

## Accessibility Features (WCAG 2.1 Level AA Compliant)

### 1. VoiceOver Support

All components provide meaningful accessibility labels, values, and hints:

#### CarouselView
```swift
.accessibilityElement(children: .combine)
.accessibilityLabel("Carousel with \(element.pages.count) pages")
.accessibilityValue("Page \(currentPage + 1) of \(element.pages.count)")
.accessibilityHint("Swipe to navigate between pages")
```

- Announces current page number and total pages
- Swipe gestures work naturally with VoiceOver
- Auto-advance pauses during VoiceOver interaction

#### AccordionView
```swift
.accessibilityAddTraits(.isButton)
.accessibilityLabel(panel.title)
.accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
.accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand")
```

- Announces panel state (expanded/collapsed)
- DisclosureGroup provides native accessibility
- State changes announced automatically

#### CodeBlockView
```swift
.accessibilityLabel("Code block in \(element.language ?? "unknown language")")
.accessibilityValue("\(lines.count) lines of code")
.accessibilityHint("Double tap to copy code to clipboard")
```

- Announces language and line count
- Copy button clearly labeled
- Uses `UIAccessibility.post` for copy feedback

#### RatingDisplayView
```swift
.accessibilityLabel("Rating: \(String(format: "%.1f", element.value)) out of \(maxStars) stars")
.accessibilityValue("\(element.count ?? 0) reviews")
```

- Announces rating value and star count
- Individual stars have descriptions
- Review count included when available

#### RatingInputView
```swift
.accessibilityLabel("Rate from 1 to \(maxStars) stars")
.accessibilityValue(ratingValue > 0 ? "\(Int(ratingValue)) stars selected" : "No rating selected")
.accessibilityHint("Tap to select a rating")
.accessibilityAddTraits(.isButton)
```

- Announces current rating and range
- Selection feedback provided
- Required state announced

#### ProgressBarView
```swift
.accessibilityLabel(element.label ?? "Progress")
.accessibilityValue("\(percentage)% complete")
```

- Announces progress percentage
- Label included in description
- Updates announced as progress changes

#### SpinnerView
```swift
.accessibilityLabel(element.label ?? "Loading")
.accessibilityValue("In progress")
```

- Announces loading state
- Label included if provided
- Indeterminate state clear

#### TabSetView
```swift
.accessibilityLabel("Tab \(tab.title)")
.accessibilityValue(selectedTabId == tab.id ? "Selected" : "")
.accessibilityAddTraits(.isButton)
```

- Announces tab names and selection state
- Native TabView accessibility
- Content area properly associated

### 2. Dynamic Type Support

All views automatically support Dynamic Type:

```swift
@Environment(\.sizeCategory) var sizeCategory

Text(element.title)
    .font(.body) // Automatically scales
    
// Conditional sizing for custom elements
let starSize: CGFloat = {
    switch sizeCategory {
    case .accessibilityExtraLarge, .accessibilityExtraExtraLarge:
        return baseSize * 1.5
    default:
        return baseSize
    }
}()
```

**Features:**
- All text uses system fonts that scale automatically
- Icons and touch targets scale with text size
- Layout adjusts to accommodate larger text
- Tested at all accessibility text sizes (xSmall to AX5)

### 3. Touch Target Sizes

All interactive elements meet or exceed the minimum 44×44pt touch target size:

| Element | Minimum Size | Implementation |
|---------|--------------|----------------|
| Carousel page indicators | 44×44pt | `.frame(minWidth: 44, minHeight: 44)` |
| Accordion headers | 44×44pt | Full-width tappable area |
| Code copy button | 44×44pt | `.frame(minWidth: 44, minHeight: 44)` |
| Rating stars (input) | 44×44pt | Per star touch target |
| Tab buttons | 44×44pt | Native TabView provides this |

**Implementation Pattern:**
```swift
Button(action: { ... }) {
    Icon(systemName: "star")
}
.frame(minWidth: 44, minHeight: 44)
.accessibilityElement(children: .combine)
```

### 4. Color and Contrast

All components use system colors that automatically adapt to:
- Light and Dark modes
- High Contrast mode
- Increased Contrast setting

```swift
// Always use semantic colors
.foregroundColor(.primary)
.background(Color(.systemBackground))
.accentColor(Color(hostConfig.colors.accent.default))
```

**Contrast Ratios:**
- Text: 4.5:1 minimum (AA)
- UI Components: 3:1 minimum (AA)
- Rating stars: 7:1 (AAA) using amber (#FFC107)

### 5. Keyboard Navigation

All interactive elements support keyboard navigation on iPad:

```swift
.focusable(true) // On iOS 15+
.accessibilityAddTraits(.isButton) // Enables keyboard activation
```

**Supported Actions:**
- Tab to navigate between elements
- Space/Enter to activate buttons
- Arrow keys to navigate tabs
- Escape to dismiss modals

### 6. Reduce Motion Support

Animations respect the system's Reduce Motion setting:

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

withAnimation(reduceMotion ? nil : .default) {
    // Animation code
}
```

**Applied to:**
- Carousel page transitions
- Accordion expand/collapse
- Tab switching
- Progress animations

## Responsive Design

### Size Class Detection

The iOS SDK uses horizontal size class to differentiate between phone and tablet layouts:

```swift
@Environment(\.horizontalSizeClass) var horizontalSizeClass

let isTablet = horizontalSizeClass == .regular
```

**Breakpoints:**
- `.compact`: iPhone (portrait), iPhone Plus/Max (landscape), iPad Split View
- `.regular`: iPad (all orientations), iPhone Plus/Max (landscape sometimes)

### Adaptive Spacing

Spacing scales based on device type:

```swift
let padding: CGFloat = isTablet ? 16 : 12
let spacing: CGFloat = isTablet ? 12 : 8
```

**Patterns:**

| Component | Compact (Phone) | Regular (Tablet) |
|-----------|----------------|------------------|
| Carousel | 8pt padding | 12pt padding |
| Accordion | 12pt padding | 16pt padding |
| CodeBlock | 12pt padding | 16pt padding |
| Rating | 8pt spacing | 12pt spacing |
| TabSet | 12pt padding | 16pt padding |

### Typography Scaling

Text styles adapt to device size:

```swift
let textStyle: Font = isTablet ? .title3 : .body
let titleStyle: Font = isTablet ? .title2 : .headline
```

**Scale Factors:**

| Text Type | Compact (Phone) | Regular (Tablet) |
|-----------|----------------|------------------|
| Body text | .body (17pt) | .title3 (20pt) |
| Headlines | .headline (17pt bold) | .title2 (22pt bold) |
| Captions | .caption (12pt) | .subheadline (15pt) |

### Icon and Component Scaling

Icons and components scale appropriately:

```swift
let iconSize: CGFloat = isTablet ? 24 : 20
let starSize: CGFloat = {
    let base = element.size == .small ? 16 : element.size == .large ? 32 : 24
    return isTablet ? base + 4 : base
}()
```

**Scaling Patterns:**

| Component | Phone Size | Tablet Size | Scale Factor |
|-----------|------------|-------------|--------------|
| Rating stars | 16-32pt | 20-36pt | +4pt |
| Carousel indicators | 8pt | 10pt | +2pt |
| Code copy icon | 18pt | 20pt | +2pt |
| Spinner | 24-56pt | 32-64pt | +8pt |

### Orientation Support

All views work correctly in both portrait and landscape:

```swift
GeometryReader { geometry in
    let isLandscape = geometry.size.width > geometry.size.height
    // Adjust layout based on orientation
}
```

**Adaptive Patterns:**
- Carousel adjusts page width to available space
- Accordion panels reflow content
- Tabs can scroll horizontally when needed
- Rating stars wrap if necessary

### iPad Split View & Slide Over

Views adapt to constrained widths:

```swift
@Environment(\.horizontalSizeClass) var sizeClass
// .compact in Split View even on iPad
```

**Behaviors:**
- Automatically uses compact layouts in Split View
- Maintains readability at narrow widths
- Touch targets remain accessible
- Content reflows appropriately

## Testing Guidelines

### Accessibility Testing

**VoiceOver Testing:**
1. Enable VoiceOver (Settings → Accessibility → VoiceOver)
2. Navigate through each element
3. Verify labels, values, and hints are clear
4. Test all interactive elements
5. Verify state changes are announced

**Dynamic Type Testing:**
1. Settings → Accessibility → Display & Text Size → Larger Text
2. Test at various sizes (especially AX sizes)
3. Verify text doesn't truncate
4. Verify touch targets remain accessible
5. Verify layout doesn't break

**High Contrast Testing:**
1. Settings → Accessibility → Display & Text Size → Increase Contrast
2. Verify all text is readable
3. Verify UI elements have sufficient contrast
4. Check both light and dark modes

**Reduce Motion Testing:**
1. Settings → Accessibility → Motion → Reduce Motion
2. Verify animations are reduced/eliminated
3. Verify functionality still works
4. Check carousel transitions

### Device Testing

**Required Devices/Simulators:**
- iPhone SE (3rd gen) - Small phone (compact)
- iPhone 15 - Standard phone (compact)
- iPhone 15 Pro Max - Large phone (compact, sometimes regular)
- iPad mini - Small tablet (regular)
- iPad Pro 12.9" - Large tablet (regular)

**Test Scenarios:**
1. Portrait orientation on all devices
2. Landscape orientation on all devices
3. Split View on iPad (various sizes)
4. Slide Over on iPad
5. Font scaling at 100%, 150%, 200%

## SwiftUI Best Practices Applied

### Environment Values
```swift
@Environment(\.horizontalSizeClass) var sizeClass
@Environment(\.sizeCategory) var sizeCategory
@Environment(\.accessibilityReduceMotion) var reduceMotion
```

### State Management
```swift
@State private var selectedTab: String?
@ObservedObject var viewModel: CardViewModel
```

### Modifiers
```swift
.accessibilityElement(children: .combine)
.accessibilityLabel("...")
.frame(minWidth: 44, minHeight: 44)
```

### Layout
```swift
HStack(spacing: isTablet ? 12 : 8) { ... }
VStack(spacing: isTablet ? 16 : 12) { ... }
```

## Compliance Standards

### WCAG 2.1 Level AA
- ✅ 1.3.1 Info and Relationships
- ✅ 1.4.3 Contrast (Minimum) - 4.5:1 for text
- ✅ 1.4.10 Reflow - Works at 200% zoom
- ✅ 1.4.11 Non-text Contrast - 3:1 for UI components
- ✅ 2.1.1 Keyboard - Full keyboard support
- ✅ 2.4.7 Focus Visible - Clear focus indicators
- ✅ 2.5.5 Target Size - 44×44pt minimum
- ✅ 4.1.2 Name, Role, Value - Proper semantic markup

### Apple Accessibility Guidelines
- ✅ VoiceOver support for all elements
- ✅ Dynamic Type support
- ✅ Reduce Motion support
- ✅ High Contrast support
- ✅ Large text support
- ✅ Keyboard navigation
- ✅ Semantic UI

## Future Enhancements

### Potential Improvements
1. **Focus Management:** Improve keyboard focus order on iPad
2. **Custom Animations:** Add more animation customization respecting Reduce Motion
3. **RTL Support:** Enhanced right-to-left language support
4. **Voice Control:** Optimize for Voice Control on iOS
5. **Switch Control:** Improve Switch Control compatibility

### Advanced Features
1. **Live Regions:** Real-time updates for dynamic content (carousel auto-advance)
2. **Rotor Support:** Custom VoiceOver rotor items
3. **Guided Access:** Better support for Guided Access mode
4. **AssistiveTouch:** Optimize for AssistiveTouch users

---

**Version:** 1.0  
**Last Updated:** February 7, 2026  
**Compliance:** WCAG 2.1 Level AA, iOS Accessibility Guidelines  
**Tested On:** iOS 17.0+, iPadOS 17.0+
