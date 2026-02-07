# Accessibility & Responsive Design Guide

## Overview

All advanced card elements in the iOS SDK are designed to be fully accessible and responsive across all device sizes and form factors. This document outlines the accessibility features and responsive design patterns implemented.

## Accessibility Features

### VoiceOver Support

All elements provide comprehensive VoiceOver support with proper:
- **Accessibility Labels**: Descriptive labels for all interactive elements
- **Accessibility Hints**: Usage hints for all actionable elements
- **Accessibility Traits**: Proper traits (button, tab, static text, etc.)
- **Accessibility Values**: Current state information
- **Accessibility Announcements**: State change notifications

#### Element-Specific VoiceOver Features

##### Carousel
- Announces current page number and total pages
- Swipe gestures for navigation
- Accessibility adjustable actions (increment/decrement)
- Example: "Page 2 of 3. Swipe left or right to navigate between pages"

##### Accordion
- Each panel announces its position (e.g., "Panel 1 of 4")
- Announces expand/collapse state
- Button trait for toggle interaction
- Example: "What is Adaptive Cards?, panel 1 of 4. Expanded. Double tap to collapse"

##### CodeBlock
- Announces programming language
- Code content is readable by VoiceOver
- Copy button with clear action hint
- Announces successful copy action
- Example: "Programming language: Swift. Code block. Double tap to copy"

##### Rating Display
- Announces rating value with context
- Includes review count if available
- Example: "Rating: 4.5 out of 5 stars, based on 128 reviews"

##### Rating Input
- Each star is individually accessible
- Announces selection state
- Provides selection hints
- Announces value changes
- Example: "3 stars. Selected. Current rating: 3 out of 5 stars"

##### ProgressBar
- Announces progress percentage
- Provides descriptive label
- Updates frequently trait for live progress
- Example: "Upload progress. 75 percent"

##### Spinner
- Announces loading state
- Reads associated label
- Updates frequently trait
- Example: "Loading. Please wait..."

##### TabSet
- Tab buttons have tab trait
- Announces selected state
- Tab content is properly grouped
- Example: "Overview. Selected tab. Double tap to select"

### Dynamic Type Support

All elements scale properly with Dynamic Type settings:

#### Text Scaling
- All text respects user's preferred text size
- Scales from extra small to accessibility sizes (AX1-AX5)
- Line limits removed for accessibility sizes
- Multi-line text wraps properly

#### Adaptive Sizing
```swift
// Example: Star size adapts to text size
private var adaptiveStarSize: Font {
    if sizeCategory.isAccessibilityCategory {
        return .title  // Larger for accessibility
    } else {
        return .title2  // Normal size
    }
}
```

#### Spacing Adjustments
- Spacing increases for accessibility text sizes
- Touch targets remain 44x44pt minimum
- Padding adjusts based on content size category

### Touch Targets

All interactive elements meet WCAG 2.1 Level AA guidelines:
- **Minimum Size**: 44x44 points
- **Tap Area**: Properly defined with `.contentShape(Rectangle())`
- **Visual Feedback**: Clear pressed and selected states

Examples:
```swift
// Rating input stars
.frame(minWidth: 44, minHeight: 44)

// Tab buttons
.frame(minWidth: 44, minHeight: 44)

// Accordion toggle buttons
.frame(minWidth: 44, minHeight: 44)
```

### Color and Contrast

- Uses system colors that adapt to light/dark mode
- Maintains WCAG AA contrast ratios
- Selected states use blue with sufficient contrast
- Error text uses semantic red color

### Keyboard Navigation

All interactive elements support:
- Tab key navigation (macOS/iPad with keyboard)
- Arrow key navigation where appropriate
- Return/Space key activation
- Escape key for dismissal

## Responsive Design

### Device Support

Elements adapt to all iOS device sizes:
- **iPhone SE** (small screen)
- **iPhone** (standard size)
- **iPhone Plus/Max** (large screen)
- **iPad** (regular horizontal size class)
- **iPad Pro** (extra large)

### Size Class Adaptations

#### Horizontal Size Classes
```swift
@Environment(\.horizontalSizeClass) var horizontalSizeClass

// iPad gets more space
if horizontalSizeClass == .regular {
    padding = hostConfig.spacing.padding * 1.5
} else {
    padding = hostConfig.spacing.padding
}
```

#### Vertical Size Classes
Used for landscape vs portrait adaptations:
```swift
@Environment(\.verticalSizeClass) var verticalSizeClass

// Adjust carousel height for iPad
private var adaptiveMinHeight: CGFloat {
    if horizontalSizeClass == .regular && verticalSizeClass == .regular {
        return 300  // iPad
    } else {
        return 200  // iPhone
    }
}
```

### Orientation Support

All elements work in both orientations:
- **Portrait**: Optimal layout for vertical space
- **Landscape**: Adapts to horizontal space
- **Rotation**: Smooth transitions between orientations

### Scrolling Behavior

- **Carousel**: Horizontal paging with swipe gestures
- **TabSet**: Horizontal tab scrolling for many tabs
- **CodeBlock**: Horizontal scroll for long code lines
- **Tab Content**: Vertical scrolling for content

### Text Wrapping

- Accordion titles wrap on multiple lines
- Tab content wraps properly
- Code can wrap if configured
- All labels support multi-line text

## Testing Accessibility

### VoiceOver Testing
1. Enable VoiceOver: Settings → Accessibility → VoiceOver
2. Navigate elements with swipe gestures
3. Verify all elements announce properly
4. Test interactions (double-tap to activate)

### Dynamic Type Testing
1. Change text size: Settings → Accessibility → Display & Text Size → Larger Text
2. Test all text size categories (XS to AX5)
3. Verify layout adjusts properly
4. Ensure touch targets remain accessible

### Device Testing
Test on multiple devices:
- [ ] iPhone SE (small screen)
- [ ] iPhone 15/16 (standard)
- [ ] iPhone 15/16 Plus (large)
- [ ] iPad (10.9")
- [ ] iPad Pro (12.9")

### Orientation Testing
- [ ] Portrait mode
- [ ] Landscape mode
- [ ] Rotation transitions

## Accessibility Checklist

For each element, verify:
- [ ] VoiceOver announces element purpose
- [ ] Interactive elements have button/tab traits
- [ ] State changes are announced
- [ ] Hints explain how to interact
- [ ] Touch targets are 44x44pt minimum
- [ ] Text scales with Dynamic Type
- [ ] Works on iPhone and iPad
- [ ] Works in portrait and landscape
- [ ] Color contrast meets WCAG AA
- [ ] Keyboard navigable (where applicable)

## Code Examples

### Adding Accessibility to New Elements

```swift
struct MyCustomElement: View {
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Button("Action") {
            // Action
        }
        .frame(minWidth: 44, minHeight: 44)  // Touch target
        .font(adaptiveFont)  // Dynamic Type
        .padding(adaptivePadding)  // Size class
        .accessibilityLabel("My button")
        .accessibilityHint("Double tap to activate")
        .accessibilityAddTraits(.isButton)
    }
    
    private var adaptiveFont: Font {
        sizeCategory.isAccessibilityCategory ? .title3 : .body
    }
    
    private var adaptivePadding: CGFloat {
        horizontalSizeClass == .regular ? 20 : 12
    }
}
```

### Announcing State Changes

```swift
Button("Rate 5 stars") {
    rating = 5
    // Announce to VoiceOver
    UIAccessibility.post(
        notification: .announcement,
        argument: "5 stars selected"
    )
}
```

### Adaptive Layout

```swift
VStack(spacing: adaptiveSpacing) {
    // Content
}

private var adaptiveSpacing: CGFloat {
    if sizeCategory.isAccessibilityCategory {
        return 16  // More space for accessibility
    } else {
        return 8   // Normal spacing
    }
}
```

## Best Practices

1. **Always Test with VoiceOver**: Don't just add labels—test the experience
2. **Use System Fonts**: They automatically scale with Dynamic Type
3. **Minimum Touch Targets**: 44x44pt is the minimum, not the target
4. **Semantic Colors**: Use `.primary`, `.secondary`, `.blue` instead of hardcoded colors
5. **Descriptive Labels**: "Submit button" not just "Submit"
6. **Meaningful Hints**: Explain the result, not the gesture
7. **Test on Device**: Simulator doesn't fully represent the accessibility experience
8. **Support Dark Mode**: Use system colors that adapt automatically

## Resources

- [Apple Human Interface Guidelines - Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [SwiftUI Accessibility](https://developer.apple.com/documentation/swiftui/view-accessibility)
- [iOS Accessibility Programming Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/iPhoneAccessibility/)
