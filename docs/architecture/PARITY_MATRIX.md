# Adaptive Cards v1.6 Feature Parity Matrix

**Last Updated**: February 13, 2026  
**Document Owner**: AdaptiveCards-Mobile Team  
**Target Schema**: Adaptive Cards v1.6  
**Status**: Active

---

## Overview

This document provides a comprehensive feature-by-feature matrix tracking implementation status across iOS and Android platforms. It serves as the single source of truth for platform parity and testing coverage.

**Status Legend**:
- ✅ **Implemented**: Fully implemented with tests
- ⚠️ **Partial**: Implemented with known limitations
- 🚧 **In Progress**: Currently being implemented
- ❌ **Not Implemented**: Not yet started
- 🔵 **Extension**: Custom extension beyond v1.6 spec
- 🎯 **Planned**: Scheduled for future release

---

## Core Elements (v1.0+)

| Element | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **TextBlock** | ✅ | ✅ | ✅ iOS: ACCoreTests<br>✅ Android: TextBlockTests | Full property support: wrap, maxLines, color, size, weight, alignment, Dynamic Type/font scaling |
| **Image** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: ImageViewTests | All sizes, styles (default, person), themed URLs, selectAction |
| **RichTextBlock** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: TextBlockTests | Inline text runs with mixed formatting, markdown support |
| **Media** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: MediaViewTests | Video playback with poster, controls; host handles streaming |

---

## Container Elements (v1.0+)

| Element | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **Container** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: ContainerViewTests | All styles (default, emphasis, good, warning, attention, accent), vertical alignment, bleed, background images, selectAction |
| **ColumnSet** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: ColumnSetViewTests | Column width modes (auto, stretch, weighted), horizontal alignment, spacing |
| **Column** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: ColumnSetViewTests | Individual column rendering with all width modes, items, selectAction |
| **FactSet** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: FactSetViewTests | Key-value pairs with wrapping and alignment |
| **ImageSet** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: ImageSetViewTests | Grid layout with configurable image size |
| **ActionSet** | ✅ | ✅ | ✅ iOS: ACActionsTests<br>✅ Android: ActionSetViewTests | Horizontal/vertical layout with overflow handling |
| **Table** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: TableViewTests | Grid-based table with headers, row styling, column width control (v1.6 feature) |

---

## Input Elements (v1.0+)

| Element | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **Input.Text** | ✅ | ✅ | ✅ iOS: ACInputsTests<br>✅ Android: TextInputTests | Single/multi-line, validation, placeholder, maxLength, inline actions, regex patterns (v1.6) |
| **Input.Number** | ✅ | ✅ | ✅ iOS: ACInputsTests<br>✅ Android: NumberInputTests | Numeric input with min/max validation, decimal support |
| **Input.Date** | ✅ | ✅ | ✅ iOS: ACInputsTests<br>✅ Android: DateInputTests | Native date picker with min/max constraints |
| **Input.Time** | ✅ | ✅ | ✅ iOS: ACInputsTests<br>✅ Android: TimeInputTests | Native time picker with min/max constraints |
| **Input.Toggle** | ✅ | ✅ | ✅ iOS: ACInputsTests<br>✅ Android: ToggleInputTests | Toggle switch/checkbox with custom value mapping |
| **Input.ChoiceSet** | ✅ | ✅ | ✅ iOS: ACInputsTests<br>✅ Android: ChoiceSetInputTests | Compact (dropdown), expanded (radio/checkbox), filtered styles; single/multi-select |
| **Input.Rating** | ✅ | ✅ | ✅ iOS: ACInputsTests<br>✅ Android: RatingInputTests | Star rating input with max rating, size, color customization |

---

## Advanced Elements (v1.3+)

| Element | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **Carousel** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: CarouselViewTests | Swipeable carousel with indicators, auto-play, loop, timer, height mode, RTL (v1.3) |
| **Accordion** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: AccordionViewTests | Collapsible panels with single/multi-expand, animations |
| **CodeBlock** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: CodeBlockViewTests | Syntax-highlighted code with line numbers, copy-to-clipboard |
| **Rating** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: RatingDisplayTests | Read-only star rating with half-star support, customization |
| **ProgressBar** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: ProgressIndicatorTests | Determinate linear progress with value display, theming |
| **Spinner** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: ProgressIndicatorTests | Indeterminate circular loading spinner |
| **TabSet** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: TabSetViewTests | Tabbed interface with lazy loading, scrollable tabs, highlighting |
| **List** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: ListViewTests | Ordered/unordered lists with markers, nested list support |
| **CompoundButton** | ✅ | ✅ | ✅ iOS: ACRenderingTests<br>✅ Android: CompoundButtonTests | Button with title, description, icon, badge (v1.6 feature) |

---

## Chart Elements (Custom Extension) 🔵

| Element | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **DonutChart** | ✅ | ✅ | ✅ iOS: ACChartsTests<br>✅ Android: DonutChartTests | Donut chart with center label, legend, colors |
| **BarChart** | ✅ | ✅ | ✅ iOS: ACChartsTests<br>✅ Android: BarChartTests | Horizontal/vertical bars with grid, axis labels, data labels |
| **LineChart** | ✅ | ✅ | ✅ iOS: ACChartsTests<br>✅ Android: LineChartTests | Line chart with multiple series, grid, markers, smooth curves |
| **PieChart** | ✅ | ✅ | ✅ iOS: ACChartsTests<br>✅ Android: PieChartTests | Pie chart with percentage labels, legend, slice selection |

**Note**: Chart elements follow Adaptive Cards extensibility model and are not part of official v1.6 spec.

---

## Actions (v1.0+)

| Action | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **Action.Submit** | ✅ | ✅ | ✅ iOS: ACActionsTests<br>✅ Android: SubmitActionTests | Form submission with data collection, validation (v1.0) |
| **Action.OpenUrl** | ✅ | ✅ | ✅ iOS: ACActionsTests<br>✅ Android: OpenUrlActionTests | Opens URL in browser or webview (v1.0) |
| **Action.ShowCard** | ✅ | ✅ | ✅ iOS: ACActionsTests<br>✅ Android: ShowCardActionTests | Inline card expansion with animation (v1.0) |
| **Action.ToggleVisibility** | ✅ | ✅ | ✅ iOS: ACActionsTests<br>✅ Android: ToggleVisibilityTests | Show/hide elements by ID with animation (v1.2) |
| **Action.Execute** | ✅ | ✅ | ✅ iOS: ACActionsTests<br>✅ Android: ExecuteActionTests | Universal action handler for bot operations (v1.4), enhanced in v1.6 with verb and associatedInputs |

---

## Layout & Container Features

| Feature | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **Spacing** | ✅ | ✅ | ✅ | none, small, default, medium, large, extraLarge, padding |
| **Separator** | ✅ | ✅ | ✅ | Line separator between elements |
| **Height** | ✅ | ✅ | ✅ | auto, stretch |
| **Horizontal Alignment** | ✅ | ✅ | ✅ | left, center, right |
| **Vertical Alignment** | ✅ | ✅ | ✅ | top, center, bottom |
| **Bleed** | ✅ | ✅ | ✅ | Container bleed to parent edges (v1.6) |
| **Min Height** | ✅ | ✅ | ✅ | Minimum height constraints (v1.6) |
| **Background Images** | ✅ | ✅ | ✅ | With fillMode, horizontalAlignment, verticalAlignment |
| **RTL Support** | ✅ | ✅ | ✅ | Right-to-left language support |
| **Responsive Layout** | ✅ | ✅ | ✅ | Target width ranges (v1.6): narrow/standard/wide |

---

## HostConfig (v1.0+)

| Feature | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **Font Family** | ✅ | ✅ | ✅ | Custom font family support |
| **Font Sizes** | ✅ | ✅ | ✅ | small, default, medium, large, extraLarge |
| **Font Weights** | ✅ | ✅ | ✅ | lighter, default, bolder |
| **Colors** | ✅ | ✅ | ✅ | default, dark, light, accent, good, warning, attention |
| **Container Styles** | ✅ | ✅ | ✅ | default, emphasis, good, warning, attention, accent |
| **Spacing** | ✅ | ✅ | ✅ | Configurable spacing values |
| **Actions Config** | ✅ | ✅ | ✅ | maxActions, buttonSpacing, showCard behavior, actionsOrientation, actionAlignment |
| **Image Sizes** | ✅ | ✅ | ✅ | auto, stretch, small, medium, large |
| **Adaptive Card Config** | ✅ | ✅ | ✅ | allowCustomStyle |

---

## Templating (v1.2+)

| Feature | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **Data Binding** | ✅ | ✅ | ✅ iOS: ACTemplatingTests<br>✅ Android: TemplateEngineTests | `${path.to.data}` syntax |
| **Conditional Rendering** | ✅ | ✅ | ✅ | `$when` expression for conditional elements |
| **Iteration** | ✅ | ✅ | ✅ | `$data` for repeating elements |
| **String Functions** | ✅ (13) | ✅ (13) | ✅ | concat, substring, toUpper, toLower, trim, length, replace, indexOf, startsWith, endsWith, split, join, padStart |
| **Math Functions** | ✅ (11) | ✅ (11) | ✅ | add, sub, mul, div, mod, abs, ceil, floor, round, min, max |
| **Logic Functions** | ✅ (10) | ✅ (10) | ✅ | if, equals, not, and, or, greater, greaterOrEquals, less, lessOrEquals, notEquals |
| **Date Functions** | ✅ (8) | ✅ (8) | ✅ | utcNow, formatDateTime, addDays, addHours, addMinutes, addSeconds, dayOfWeek, dayOfMonth |
| **Collection Functions** | ✅ (8) | ✅ (8) | ✅ | count, first, last, slice, where, select, orderBy, reverse |
| **Nested Contexts** | ✅ | ✅ | ✅ | Proper scope resolution for nested data |
| **Expression Limits** | ✅ | ✅ | ✅ | Max depth (~100), token limit (~10k), input limit (~100KB) for DoS prevention |

**Total**: 60 expression functions across 5 categories (13+11+10+8+8)

---

## Markdown Support (v1.0+)

| Feature | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **Emphasis** | ✅ | ✅ | ✅ | *italic*, **bold** |
| **Links** | ✅ | ✅ | ✅ | [text](url) |
| **Lists** | ✅ | ✅ | ✅ | Ordered and unordered |
| **Inline Code** | ✅ | ✅ | ✅ | `code` |
| **Headings** | ✅ | ✅ | ✅ | # H1 through ###### H6 |
| **Blockquotes** | ✅ | ✅ | ✅ | > quoted text |
| **Line Breaks** | ✅ | ✅ | ✅ | Two spaces + newline |

**Note**: CommonMark subset, no code blocks or tables in markdown (use CodeBlock and Table elements)

---

## v1.6 Specific Features

| Feature | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **Table Element** | ✅ | ✅ | ✅ | Grid-based tables with headers, styling, column definitions |
| **CompoundButton** | ✅ | ✅ | ✅ | Button with title, description, icon, badge |
| **Enhanced Input Validation** | ✅ | ✅ | ✅ | Error messages, required fields, regex patterns |
| **Action.Execute Enhancements** | ✅ | ✅ | ✅ | Verb property, associatedInputs |
| **Container Bleed** | ✅ | ✅ | ✅ | Containers bleed to parent edges |
| **Min Height** | ✅ | ✅ | ✅ | Minimum height constraints |
| **Responsive Design** | ✅ | ✅ | ✅ | Target width ranges (narrow/standard/wide) |
| **menuActions (Overflow)** | ✅ | ✅ | ✅ | Primary/secondary action mode; overflow "..." menu via SwiftUI Menu / Compose DropdownMenu |
| **Refresh.expires** | ✅ | ✅ | ✅ | ISO-8601 expiration timestamp on Refresh model (v1.6) |

---

## Gaps & Future Work

### Known Gaps (v1.6 Features Not Yet Implemented)

| Feature | Priority | Status | Notes |
|---------|----------|--------|-------|
| **menuActions (Overflow Menu)** | High | ✅ Done | Primary/secondary mode, maxActions overflow, "..." menu button |
| **Advanced Table Spanning** | Medium | 🎯 Planned | Complex row/column spanning; basic table support exists |
| **Authentication Flow** | Low | Out of Scope | Host application responsibility |

### Test Coverage Summary

| Platform | Total Tests | Pass Rate | Coverage |
|----------|-------------|-----------|----------|
| **iOS** | 250+ | 100% ✅ | 85%+ |
| **Android** | 200+ | 100% ✅ | 80%+ |
| **Shared Test Cards** | 43 cards | ✅ | All element types |
| **Edge Cases** | 8 cards | ✅ | Empty, nested, unknown, overflow, etc. |

---

## Accessibility & Responsiveness

| Feature | iOS Status | Android Status | Tests | Notes |
|---------|------------|----------------|-------|-------|
| **Screen Reader** | ✅ VoiceOver | ✅ TalkBack | ✅ | WCAG 2.1 AA compliant |
| **Dynamic Fonts** | ✅ Dynamic Type | ✅ Font Scaling | ✅ | System font size preferences |
| **Minimum Touch Targets** | ✅ 44x44pt | ✅ 48x48dp | ✅ | Platform recommendations |
| **Semantic Labels** | ✅ | ✅ | ✅ | Proper accessibility labels and hints |
| **Keyboard Navigation** | ✅ | ✅ | ✅ | Full keyboard support where applicable |
| **High Contrast** | ✅ | ✅ | ✅ | Respects system high contrast settings |
| **Portrait/Landscape** | ✅ | ✅ | ✅ | Responsive layout in all orientations |
| **Phone/Tablet** | ✅ | ✅ | ✅ | Optimized for different screen sizes |

---

## Cross-Platform Sync Enforcement

### Automated Checks

| Check | Status | CI Integration | Notes |
|-------|--------|----------------|-------|
| **Schema Parity Script** | ✅ | ✅ | Compares element types across platforms |
| **Test Parity Gate** | ✅ | ✅ | Both platforms must pass for CI success |
| **Shared Test Cards** | ✅ | ✅ | 43 cards validated on both platforms |
| **Schema Validation** | ✅ | ✅ | v1.6 schema validation on test cards |
| **Round-Trip Tests** | ✅ | ✅ | JSON parse → model → JSON serialization |

### PR Requirements

- [ ] Feature implemented on both iOS and Android
- [ ] Tests added for both platforms
- [ ] PARITY_MATRIX.md updated with implementation status
- [ ] Shared test card added (if new element type)
- [ ] Documentation updated (if user-facing change)

---

## Visual Regression Testing

| Platform | Status | Framework | Notes |
|----------|--------|-----------|-------|
| **iOS** | 🚧 Scaffolding | Swift Snapshot Testing | README and scaffolding added; full integration planned |
| **Android** | 🚧 Scaffolding | Paparazzi/Compose Preview | README and scaffolding added; full integration planned |

**Scaffolding Includes**:
- Directory structure: `ios/Tests/ACSnapshotTests/`, `android/ac-rendering/src/androidTest/`
- README with setup instructions
- Sample snapshot test demonstrating framework usage
- CI integration placeholder (can be enabled when tests are added)

---

## Schema Validation

### v1.6 Schema File

**Location**: `shared/schema/adaptive-card-schema-1.6.json`

**Contents**:
- JSON Schema definition for Adaptive Cards v1.6
- All element types, properties, and validation rules
- Used by iOS and Android SchemaValidator classes

### Validation Tests

| Platform | Test File | Coverage |
|----------|-----------|----------|
| **iOS** | `ios/Tests/ACCoreTests/SchemaValidatorTests.swift` | ✅ v1.6 validation, round-trip |
| **Android** | `android/ac-core/src/test/kotlin/SchemaValidatorTest.kt` | ✅ v1.6 validation, round-trip |

---

## References

- [PARITY_TARGET.md](./PARITY_TARGET.md) - Target schema and policy document
- [RENDERING_PARITY_CHECKLIST.md](../../shared/RENDERING_PARITY_CHECKLIST.md) - Detailed rendering parity
- [Adaptive Cards Schema v1.6](http://adaptivecards.io/schemas/adaptive-card.json)
- [Official Documentation](https://adaptivecards.io/)

---

## Change History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2026-02-13 | 1.0 | Initial comprehensive parity matrix for v1.6 | AdaptiveCards-Mobile Team |

---

**Document Status**: ✅ Active  
**Next Review**: Monthly or when new features are added
