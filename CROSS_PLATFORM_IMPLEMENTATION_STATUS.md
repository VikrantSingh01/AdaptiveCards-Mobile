# Cross-Platform Alignment Status

## Overview

This document tracks the alignment between iOS and Android implementations of advanced card elements to ensure consistency across platforms.

**Last Updated**: 2026-02-07

## Implementation Status

### ✅ iOS Implementation (COMPLETE)

| Component | Models | Views | Tests | Docs | Accessibility | Responsive |
|-----------|--------|-------|-------|------|---------------|------------|
| Carousel | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Accordion | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| CodeBlock | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Rating Display | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Rating Input | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| ProgressBar | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Spinner | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| TabSet | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**iOS Files**:
- Models: `ios/Sources/ACCore/Models/AdvancedElements.swift`
- Views: `ios/Sources/ACRendering/Views/` (7 files) + `ios/Sources/ACInputs/Views/RatingInputView.swift`
- Tests: `ios/Tests/ACCoreTests/AdvancedElementsParserTests.swift` (40+ tests)
- Docs: `ios/README.md`, `ios/ACCESSIBILITY.md`, `ios/USAGE_GUIDE.md`

### ❌ Android Implementation (PENDING)

| Component | Models | Views | Tests | Docs | Accessibility | Responsive |
|-----------|--------|-------|-------|------|---------------|------------|
| Carousel | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Accordion | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| CodeBlock | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Rating Display | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Rating Input | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| ProgressBar | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Spinner | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| TabSet | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

**Android Files** (to be created):
- Models: `android/ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/models/AdvancedElements.kt`
- Views: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/` (8 files)
- Tests: `android/ac-core/src/test/kotlin/AdvancedElementsParserTest.kt`
- Docs: Update `android/README.md`, create `android/ACCESSIBILITY_GUIDE.md`, `android/USAGE_GUIDE.md`

---

## Naming Convention Alignment

### ✅ Element Type Names (JSON)

| Element | iOS Type String | Android Type String | Status |
|---------|----------------|---------------------|--------|
| Carousel | `"Carousel"` | `"Carousel"` | ✅ Aligned |
| Accordion | `"Accordion"` | `"Accordion"` | ✅ Aligned |
| CodeBlock | `"CodeBlock"` | `"CodeBlock"` | ✅ Aligned |
| Rating Display | `"Rating"` | `"Rating"` | ✅ Aligned |
| Rating Input | `"Input.Rating"` | `"Input.Rating"` | ✅ Aligned |
| ProgressBar | `"ProgressBar"` | `"ProgressBar"` | ✅ Aligned |
| Spinner | `"Spinner"` | `"Spinner"` | ✅ Aligned |
| TabSet | `"TabSet"` | `"TabSet"` | ✅ Aligned |

### ✅ Model/Data Class Names

| Element | iOS Struct | Android Data Class | Status |
|---------|-----------|-------------------|--------|
| Carousel | `Carousel` | `Carousel` | ✅ Aligned |
| Carousel Page | `CarouselPage` | `CarouselPage` | ✅ Aligned |
| Accordion | `Accordion` | `Accordion` | ✅ Aligned |
| Accordion Panel | `AccordionPanel` | `AccordionPanel` | ✅ Aligned |
| Code Block | `CodeBlock` | `CodeBlock` | ✅ Aligned |
| Rating Display | `RatingDisplay` | `RatingDisplay` | ✅ Aligned |
| Rating Input | `RatingInput` | `RatingInput` | ✅ Aligned |
| Progress Bar | `ProgressBar` | `ProgressBar` | ✅ Aligned |
| Spinner | `Spinner` | `Spinner` | ✅ Aligned |
| TabSet | `TabSet` | `TabSet` | ✅ Aligned |
| Tab | `Tab` | `Tab` | ✅ Aligned |

### ✅ View Names

| Element | iOS View | Android Composable | Status |
|---------|----------|-------------------|--------|
| Carousel | `CarouselView` | `CarouselView` | ✅ Aligned |
| Accordion | `AccordionView` | `AccordionView` | ✅ Aligned |
| CodeBlock | `CodeBlockView` | `CodeBlockView` | ✅ Aligned |
| Rating Display | `RatingDisplayView` | `RatingDisplayView` | ✅ Aligned |
| Rating Input | `RatingInputView` | `RatingInputView` | ✅ Aligned |
| ProgressBar | `ProgressBarView` | `ProgressBarView` | ✅ Aligned |
| Spinner | `SpinnerView` | `SpinnerView` | ✅ Aligned |
| TabSet | `TabSetView` | `TabSetView` | ✅ Aligned |

### ✅ Property Names

All property names use **camelCase** on both platforms:

#### Carousel Properties
```swift
// iOS
struct Carousel {
    var pages: [CarouselPage]
    var timer: Int?
    var initialPage: Int?
}
```

```kotlin
// Android (to be implemented)
data class Carousel(
    val pages: List<CarouselPage>,
    val timer: Int? = null,
    val initialPage: Int? = null
)
```

#### Accordion Properties
```swift
// iOS
struct Accordion {
    var panels: [AccordionPanel]
    var expandMode: ExpandMode?
}

enum ExpandMode {
    case single
    case multiple
}
```

```kotlin
// Android (to be implemented)
data class Accordion(
    val panels: List<AccordionPanel>,
    val expandMode: ExpandMode? = null
)

enum class ExpandMode {
    Single, Multiple
}
```

#### CodeBlock Properties
```swift
// iOS
struct CodeBlock {
    var code: String
    var language: String?
    var startLineNumber: Int?
    var wrap: Bool?
}
```

```kotlin
// Android (to be implemented)
data class CodeBlock(
    val code: String,
    val language: String? = null,
    val startLineNumber: Int? = null,
    val wrap: Boolean? = null
)
```

---

## Enum Alignment

### ✅ New Enums Required

| Enum | iOS | Android | Status |
|------|-----|---------|--------|
| ExpandMode | `.single`, `.multiple` | `Single`, `Multiple` | ✅ Aligned |
| RatingSize | `.small`, `.medium`, `.large` | `Small`, `Medium`, `Large` | ✅ Aligned |
| SpinnerSize | `.small`, `.medium`, `.large` | `Small`, `Medium`, `Large` | ✅ Aligned |

**iOS Implementation**:
```swift
// ios/Sources/ACCore/Models/Enums.swift
public enum ExpandMode: String, Codable {
    case single = "Single"
    case multiple = "Multiple"
}

public enum RatingSize: String, Codable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}

public enum SpinnerSize: String, Codable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
}
```

**Android Implementation** (to be added):
```kotlin
// android/ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/models/Enums.kt
enum class ExpandMode {
    @SerialName("Single") Single,
    @SerialName("Multiple") Multiple
}

enum class RatingSize {
    @SerialName("Small") Small,
    @SerialName("Medium") Medium,
    @SerialName("Large") Large
}

enum class SpinnerSize {
    @SerialName("Small") Small,
    @SerialName("Medium") Medium,
    @SerialName("Large") Large
}
```

---

## Test Card Alignment

### ✅ Shared Test Cards

Both platforms use the **same test cards** from `shared/test-cards/`:

| Test Card | Purpose | iOS Uses | Android Uses |
|-----------|---------|----------|--------------|
| `carousel.json` | 3-page photo carousel | ✅ Via symlink | ✅ Direct reference |
| `accordion.json` | 4-panel FAQ | ✅ Via symlink | ✅ Direct reference |
| `code-block.json` | Swift/JS/JSON examples | ✅ Via symlink | ✅ Direct reference |
| `rating.json` | Display & input examples | ✅ Via symlink | ✅ Direct reference |
| `progress-indicators.json` | Progress bars & spinners | ✅ Via symlink | ✅ Direct reference |
| `tab-set.json` | 4-tab project dashboard | ✅ Via symlink | ✅ Direct reference |
| `advanced-combined.json` | All elements together | ✅ Via symlink | ✅ Direct reference |

**iOS Approach**: Symlinks in `ios/Tests/ACCoreTests/Resources/` → `shared/test-cards/`
**Android Approach**: Direct file references from `shared/test-cards/`

---

## API Alignment

### ✅ Core APIs

| API | iOS | Android | Status |
|-----|-----|---------|--------|
| Parse Card | `CardParser().parse(json)` | `CardParser.parse(json)` | ✅ Aligned |
| Get Input Value | `viewModel.getInputValue(forId:)` | `viewModel.getInputValue(id)` | ✅ Aligned |
| Set Input Value | `viewModel.setInputValue(id:value:)` | `viewModel.setInputValue(id, value)` | ✅ Aligned |
| Element Visibility | `element.isVisible` | `element.isVisible` | ✅ Aligned |

---

## Accessibility Requirements

Both platforms must meet **WCAG 2.1 Level AA** compliance:

### iOS Requirements ✅
- [x] VoiceOver support (labels, hints, traits)
- [x] Dynamic Type (all size categories)
- [x] 44×44pt minimum touch targets
- [x] State change announcements
- [x] Adjustable trait for Carousel

### Android Requirements (to be implemented)
- [ ] TalkBack support (contentDescription, roles)
- [ ] Font scaling (sp units, accessibility sizes)
- [ ] 44×44dp minimum touch targets
- [ ] Live region announcements
- [ ] Semantics for accessibility services

---

## Responsive Design Requirements

### iOS Implementation ✅
- [x] Size classes (regular/compact)
- [x] Adaptive layouts (iPhone SE to iPad Pro)
- [x] Orientation support (portrait/landscape)
- [x] Adaptive spacing and sizing
- [x] Content size category support

### Android Implementation (to be implemented)
- [ ] Window size classes (compact/medium/expanded)
- [ ] Adaptive layouts (phone to tablet)
- [ ] Orientation support (portrait/landscape)
- [ ] Density-independent pixels (dp)
- [ ] Configuration changes handling

---

## Documentation Alignment

### iOS Documentation ✅
- [x] `README.md` - Installation, quick start, supported elements
- [x] `ACCESSIBILITY.md` - VoiceOver, Dynamic Type, testing
- [x] `USAGE_GUIDE.md` - Examples, best practices, troubleshooting

### Android Documentation (to be created)
- [ ] `README.md` - Update with advanced elements
- [ ] `ACCESSIBILITY_GUIDE.md` - TalkBack, font scaling, testing
- [ ] `USAGE_GUIDE.md` - Examples, best practices, troubleshooting

**Template**: Use iOS docs as template, adapt for:
- Jetpack Compose instead of SwiftUI
- TalkBack instead of VoiceOver
- Material Design guidelines
- Kotlin code examples

---

## Implementation Checklist for Android

### Phase 1: Models ❌
- [ ] Create `AdvancedElements.kt` with data classes:
  - [ ] Carousel + CarouselPage
  - [ ] Accordion + AccordionPanel
  - [ ] CodeBlock
  - [ ] RatingDisplay
  - [ ] RatingInput
  - [ ] ProgressBar
  - [ ] Spinner
  - [ ] TabSet + Tab
- [ ] Add enums to `Enums.kt`:
  - [ ] ExpandMode
  - [ ] RatingSize
  - [ ] SpinnerSize
- [ ] Update `CardElement.kt` sealed interface
- [ ] Update `CardInput.kt` sealed interface
- [ ] Add serialization annotations

### Phase 2: Views ❌
- [ ] Create Composable views in `ac-rendering/composables/`:
  - [ ] CarouselView.kt
  - [ ] AccordionView.kt
  - [ ] CodeBlockView.kt
  - [ ] RatingDisplayView.kt
  - [ ] ProgressBarView.kt
  - [ ] SpinnerView.kt
  - [ ] TabSetView.kt
- [ ] Create input view in `ac-inputs/`:
  - [ ] RatingInputView.kt
- [ ] Update `ElementView.kt` to route new elements

### Phase 3: Tests ❌
- [ ] Create `AdvancedElementsParserTest.kt`
- [ ] Add parsing tests for all 8 elements
- [ ] Add round-trip encode/decode tests
- [ ] Add edge case tests
- [ ] Add visibility tests
- [ ] Add ID tests

### Phase 4: Accessibility ❌
- [ ] Add contentDescription to all views
- [ ] Add semantic roles
- [ ] Ensure 44dp minimum touch targets
- [ ] Add live region announcements
- [ ] Test with TalkBack
- [ ] Test with font scaling

### Phase 5: Responsive Design ❌
- [ ] Test on phones (small to large)
- [ ] Test on tablets (7" to 12")
- [ ] Test portrait and landscape
- [ ] Verify adaptive spacing
- [ ] Verify window size class handling

### Phase 6: Documentation ❌
- [ ] Update `README.md` with advanced elements
- [ ] Create `ACCESSIBILITY_GUIDE.md`
- [ ] Create `USAGE_GUIDE.md` with Kotlin examples
- [ ] Add inline code documentation
- [ ] Document known limitations

---

## PR Coordination

### Current PRs
- **PR #3** (this one): iOS advanced elements implementation
- **PR #4**: Work in progress (details pending)
- **PR #5**: Work in progress (details pending)

### Recommendations
1. **Android team should**:
   - Review iOS implementation for patterns
   - Use same test cards from `shared/test-cards/`
   - Match naming conventions exactly
   - Follow same accessibility requirements
   - Use USAGE_GUIDE.md as template

2. **Both teams should**:
   - Keep this document updated
   - Sync on API changes
   - Share test results
   - Review each other's PRs
   - Document any intentional differences

---

## Validation Checklist

Before merging advanced elements on either platform:

- [ ] All 8 elements implemented
- [ ] All tests passing
- [ ] Accessibility compliance verified
- [ ] Responsive design tested
- [ ] Documentation complete
- [ ] Code review completed
- [ ] Security scan passed
- [ ] Cross-platform naming verified
- [ ] Test cards work on both platforms

---

## Contact & Updates

**Last reviewed**: 2026-02-07
**Next review**: After Android PR submission

For questions or alignment issues, update this document and notify both teams.
