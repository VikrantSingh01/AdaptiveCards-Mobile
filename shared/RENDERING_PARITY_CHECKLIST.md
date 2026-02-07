# Cross-Platform Rendering Parity Checklist

This document tracks the implementation status of all Adaptive Card element types across iOS (SwiftUI) and Android (Jetpack Compose) platforms. It ensures both SDKs render cards identically and handle all edge cases correctly.

**Last Updated**: February 7, 2026  
**SDK Version**: 1.0.0  
**Status Legend**:
- ✅ **Matched**: Full parity with identical rendering and behavior
- ⚠️ **Partial**: Implemented but with minor visual/behavioral differences
- ❌ **Missing**: Not implemented on one or both platforms

---

## Core Elements

### TextBlock
- **iOS File**: `ios/Sources/ACRendering/Views/TextBlockView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/TextBlockView.kt`
- **Status**: ✅ Matched
- **Notes**: Full property support including wrap, maxLines, color, size, weight, horizontal alignment, and Dynamic Type/font scaling.

### Image
- **iOS File**: `ios/Sources/ACRendering/Views/ImageView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/ImageView.kt`
- **Status**: ✅ Matched
- **Notes**: Supports all image sizes, styles (default, person), themed URLs, and select actions.

### RichTextBlock
- **iOS File**: `ios/Sources/ACRendering/Views/RichTextBlockView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/TextBlockView.kt` (combined with TextBlock)
- **Status**: ✅ Matched
- **Notes**: Inline text runs with mixed formatting (bold, italic, color, size).

### Media
- **iOS File**: `ios/Sources/ACRendering/Views/MediaView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/MediaAndTableViews.kt`
- **Status**: ✅ Matched
- **Notes**: Video playback with poster image, play button overlay, and media controls.

---

## Container Elements

### Container
- **iOS File**: `ios/Sources/ACRendering/Views/ContainerView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/ContainerView.kt`
- **Status**: ✅ Matched
- **Notes**: Supports styles (default, emphasis, good, warning, attention, accent), vertical content alignment, bleed, background images, and select actions.

### ColumnSet
- **iOS File**: `ios/Sources/ACRendering/Views/ColumnSetView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/ColumnSetView.kt`
- **Status**: ✅ Matched
- **Notes**: Column width modes (auto, stretch, weighted), horizontal alignment, and spacing.

### Column
- **iOS File**: `ios/Sources/ACRendering/Views/ColumnView.swift`
- **Android File**: Part of `ColumnSetView.kt`
- **Status**: ✅ Matched
- **Notes**: Individual column rendering within ColumnSet with all width modes.

### FactSet
- **iOS File**: `ios/Sources/ACRendering/Views/FactSetView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/FactSetView.kt`
- **Status**: ✅ Matched
- **Notes**: Key-value pair rendering with proper text wrapping and alignment.

### ImageSet
- **iOS File**: `ios/Sources/ACRendering/Views/ImageSetView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/ImageSetView.kt`
- **Status**: ✅ Matched
- **Notes**: Grid layout with configurable image size.

### ActionSet
- **iOS File**: `ios/Sources/ACRendering/Views/ActionSetView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/ActionSetView.kt`
- **Status**: ✅ Matched
- **Notes**: Horizontal/vertical action button layout with overflow handling.

### Table
- **iOS File**: `ios/Sources/ACRendering/Views/TableView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/MediaAndTableViews.kt`
- **Status**: ✅ Matched
- **Notes**: Grid-based table with headers, row styling, and column width control.

---

## Input Elements

### Input.Text
- **iOS File**: `ios/Sources/ACInputs/Views/TextInputView.swift`
- **Android File**: `android/ac-inputs/src/main/kotlin/com/microsoft/adaptivecards/inputs/composables/TextInputView.kt`
- **Status**: ✅ Matched
- **Notes**: Single/multi-line text input with validation, placeholder, max length, inline actions, and regex pattern support.

### Input.Number
- **iOS File**: `ios/Sources/ACInputs/Views/NumberInputView.swift`
- **Android File**: `android/ac-inputs/src/main/kotlin/com/microsoft/adaptivecards/inputs/composables/NumberInputView.kt`
- **Status**: ✅ Matched
- **Notes**: Numeric input with min/max validation and decimal support.

### Input.Date
- **iOS File**: `ios/Sources/ACInputs/Views/DateInputView.swift`
- **Android File**: `android/ac-inputs/src/main/kotlin/com/microsoft/adaptivecards/inputs/composables/DateInputView.kt`
- **Status**: ✅ Matched
- **Notes**: Native date picker with min/max date constraints.

### Input.Time
- **iOS File**: `ios/Sources/ACInputs/Views/TimeInputView.swift`
- **Android File**: `android/ac-inputs/src/main/kotlin/com/microsoft/adaptivecards/inputs/composables/TimeInputView.kt`
- **Status**: ✅ Matched
- **Notes**: Native time picker with min/max time constraints.

### Input.Toggle
- **iOS File**: `ios/Sources/ACInputs/Views/ToggleInputView.swift`
- **Android File**: `android/ac-inputs/src/main/kotlin/com/microsoft/adaptivecards/inputs/composables/ToggleInputView.kt`
- **Status**: ✅ Matched
- **Notes**: Toggle switch/checkbox with custom value mapping.

### Input.ChoiceSet
- **iOS File**: `ios/Sources/ACInputs/Views/ChoiceSetInputView.swift`
- **Android File**: `android/ac-inputs/src/main/kotlin/com/microsoft/adaptivecards/inputs/composables/ChoiceSetInputView.kt`
- **Status**: ✅ Matched
- **Notes**: Supports compact (dropdown), expanded (radio/checkbox), and filtered styles with single/multi-select.

### Input.Rating
- **iOS File**: `ios/Sources/ACInputs/Views/RatingInputView.swift`
- **Android File**: Part of `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/RatingDisplayView.kt`
- **Status**: ✅ Matched
- **Notes**: Star rating input with configurable max rating, size, and color.

---

## Advanced Elements (Phase 2)

### Carousel
- **iOS File**: `ios/Sources/ACRendering/Views/CarouselView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/CarouselView.kt`
- **Status**: ✅ Matched
- **Notes**: Swipeable carousel with page indicators, auto-play, loop, timer, height mode, and RTL support.

### Accordion
- **iOS File**: `ios/Sources/ACRendering/Views/AccordionView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/AccordionView.kt`
- **Status**: ✅ Matched
- **Notes**: Collapsible panels with single/multi-expand modes, expand/collapse animations.

### CodeBlock
- **iOS File**: `ios/Sources/ACRendering/Views/CodeBlockView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/CodeBlockView.kt`
- **Status**: ✅ Matched
- **Notes**: Syntax-highlighted code display with line numbers, copy-to-clipboard, and monospace font.

### Rating (Display)
- **iOS File**: `ios/Sources/ACRendering/Views/RatingDisplayView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/RatingDisplayView.kt`
- **Status**: ✅ Matched
- **Notes**: Read-only star rating display with half-star support, size, and color customization.

### ProgressBar
- **iOS File**: `ios/Sources/ACRendering/Views/ProgressBarView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/ProgressIndicatorViews.kt`
- **Status**: ✅ Matched
- **Notes**: Determinate linear progress bar with value display and theming.

### Spinner
- **iOS File**: `ios/Sources/ACRendering/Views/SpinnerView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/ProgressIndicatorViews.kt`
- **Status**: ✅ Matched
- **Notes**: Indeterminate circular loading spinner with size and color options.

### TabSet
- **iOS File**: `ios/Sources/ACRendering/Views/TabSetView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/TabSetView.kt`
- **Status**: ✅ Matched
- **Notes**: Tabbed interface with lazy loading, scrollable tabs, and selected tab highlighting.

### List
- **iOS File**: `ios/Sources/ACRendering/Views/ListView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/ListView.kt`
- **Status**: ✅ Matched
- **Notes**: Ordered/unordered lists with custom markers and nested list support.

### CompoundButton
- **iOS File**: `ios/Sources/ACRendering/Views/CompoundButtonView.swift`
- **Android File**: `android/ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/composables/CompoundButtonView.kt`
- **Status**: ✅ Matched
- **Notes**: Button with title, description, and optional icon/badge.

---

## Chart Elements (Phase 2)

### DonutChart
- **iOS File**: `ios/Sources/ACCharts/DonutChartView.swift`
- **Android File**: `android/ac-charts/src/main/kotlin/com/microsoft/adaptivecards/charts/DonutChartView.kt`
- **Status**: ✅ Matched
- **Notes**: Donut chart with center label, legend, and customizable colors.

### BarChart
- **iOS File**: `ios/Sources/ACCharts/BarChartView.swift`
- **Android File**: `android/ac-charts/src/main/kotlin/com/microsoft/adaptivecards/charts/BarChartView.kt`
- **Status**: ✅ Matched
- **Notes**: Horizontal/vertical bar chart with grid lines, axis labels, and data labels.

### LineChart
- **iOS File**: `ios/Sources/ACCharts/LineChartView.swift`
- **Android File**: `android/ac-charts/src/main/kotlin/com/microsoft/adaptivecards/charts/LineChartView.kt`
- **Status**: ✅ Matched
- **Notes**: Line chart with multiple series, grid, markers, and smooth curves.

### PieChart
- **iOS File**: `ios/Sources/ACCharts/PieChartView.swift`
- **Android File**: `android/ac-charts/src/main/kotlin/com/microsoft/adaptivecards/charts/PieChartView.kt`
- **Status**: ✅ Matched
- **Notes**: Pie chart with percentage labels, legend, and slice selection.

---

## Actions

### Action.Submit
- **iOS File**: `ios/Sources/ACActions/SubmitAction.swift`
- **Android File**: `android/ac-actions/src/main/kotlin/com/microsoft/adaptivecards/actions/SubmitAction.kt`
- **Status**: ✅ Matched
- **Notes**: Form submission with data collection and validation.

### Action.OpenUrl
- **iOS File**: `ios/Sources/ACActions/OpenUrlAction.swift`
- **Android File**: `android/ac-actions/src/main/kotlin/com/microsoft/adaptivecards/actions/OpenUrlAction.kt`
- **Status**: ✅ Matched
- **Notes**: Opens URL in system browser or in-app web view.

### Action.ShowCard
- **iOS File**: `ios/Sources/ACActions/ShowCardAction.swift`
- **Android File**: `android/ac-actions/src/main/kotlin/com/microsoft/adaptivecards/actions/ShowCardAction.kt`
- **Status**: ✅ Matched
- **Notes**: Expands inline card with smooth animation.

### Action.ToggleVisibility
- **iOS File**: `ios/Sources/ACActions/ToggleVisibilityAction.swift`
- **Android File**: `android/ac-actions/src/main/kotlin/com/microsoft/adaptivecards/actions/ToggleVisibilityAction.kt`
- **Status**: ✅ Matched
- **Notes**: Shows/hides elements by ID with animation.

### Action.Execute (Phase 3)
- **iOS File**: `ios/Sources/ACActions/ExecuteAction.swift`
- **Android File**: `android/ac-actions/src/main/kotlin/com/microsoft/adaptivecards/actions/ExecuteAction.kt`
- **Status**: ✅ Matched
- **Notes**: Universal action handler for custom backend operations.

---

## Special Features

### Markdown Parsing
- **iOS File**: `ios/Sources/ACMarkdown/MarkdownParser.swift`
- **Android File**: `android/ac-markdown/src/main/kotlin/com/microsoft/adaptivecards/markdown/MarkdownParser.kt`
- **Status**: ✅ Matched
- **Notes**: CommonMark-compliant markdown with emphasis, links, lists, and code.

### Templating Engine
- **iOS File**: `ios/Sources/ACTemplating/TemplateEngine.swift`
- **Android File**: `android/ac-templating/src/main/kotlin/com/microsoft/adaptivecards/templating/TemplateEngine.kt`
- **Status**: ⚠️ Partial
- **Notes**: iOS has 60+ expression functions fully implemented. Android implementation is in progress.

### Schema Validation
- **iOS File**: `ios/Sources/ACCore/SchemaValidator.swift`
- **Android File**: Part of `CardParser` in `android/ac-core`
- **Status**: ✅ Matched
- **Notes**: Validates card JSON against Adaptive Cards schema v1.6.

### Accessibility
- **iOS File**: `ios/Sources/ACAccessibility/`
- **Android File**: `android/ac-accessibility/`
- **Status**: ✅ Matched
- **Notes**: WCAG 2.1 AA compliant with VoiceOver/TalkBack support, minimum touch targets, Dynamic Type/font scaling, and semantic labeling.

### Unknown Element Fallback
- **iOS Model**: `ios/Sources/ACCore/Models/CardElement.swift` (line 106-107)
- **Android Model**: `android/ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/parsing/CardParser.kt`
- **Status**: ✅ Matched
- **Notes**: Both platforms gracefully handle unknown element types using `.unknown(type:)` enum case without throwing errors, per Adaptive Cards spec.

---

## Edge Cases Tested

The following edge case test cards validate proper handling of unusual scenarios:

1. **edge-empty-card.json**: Empty body array
2. **edge-deeply-nested.json**: 6 levels of container nesting
3. **edge-all-unknown-types.json**: Multiple unknown element types (validates fallback behavior)
4. **edge-max-actions.json**: 12 actions (validates overflow handling)
5. **edge-long-text.json**: Extremely long text with and without spaces (validates wrapping/truncation)
6. **edge-rtl-content.json**: Arabic and Hebrew RTL text (validates bidirectional text support)
7. **edge-mixed-inputs.json**: All input types interleaved with display elements
8. **edge-empty-containers.json**: Empty containers, column sets, and tables

All edge cases are handled consistently across both platforms without crashes or errors.

---

## Summary Statistics

| Category | iOS Count | Android Count | Parity Status |
|----------|-----------|---------------|---------------|
| **Core Elements** | 4 | 4 | ✅ 100% |
| **Container Elements** | 8 | 8 | ✅ 100% |
| **Input Elements** | 7 | 7 | ✅ 100% |
| **Advanced Elements** | 9 | 9 | ✅ 100% |
| **Chart Elements** | 4 | 4 | ✅ 100% |
| **Actions** | 5 | 5 | ✅ 100% |
| **Special Features** | 4 | 4 | ⚠️ 75% (templating in progress) |
| **Total** | 41 | 41 | ✅ 98% |

---

## Known Differences

### Minor Platform-Specific Variations

1. **Font Rendering**: Native platform fonts may differ slightly (San Francisco on iOS vs. Roboto on Android).
2. **Animation Timings**: Some animations may have slightly different timing curves due to platform defaults.
3. **Touch Feedback**: Ripple effect on Android vs. highlight on iOS for interactive elements.

These differences are expected and do not impact functional parity or user experience quality.

---

## Validation Process

To verify rendering parity:

1. Run iOS integration tests: `cd ios && swift test`
2. Run Android integration tests: `cd android && ./gradlew test`
3. Run visual snapshot tests for both platforms
4. Compare rendered output for all shared test cards
5. Validate edge case handling

---

**Document Ownership**: AdaptiveCards-Mobile Team  
**Review Frequency**: Updated with each major release  
**Next Review**: Phase 7 (Performance Optimization)
