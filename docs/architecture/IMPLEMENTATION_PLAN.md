# Adaptive Cards Mobile SDK - Complete Implementation Plan

## Project Overview
This document provides a comprehensive implementation plan for completing all 5 phases of the Adaptive Cards Mobile SDK to achieve desktop parity with ac-react-sdk.

## Current Status (as of Phase 1 Progress)

### ✅ Completed Components

#### iOS ACTemplating Module
- **DataContext.swift**: Full nested context support with $root, $data, $index
- **ExpressionParser.swift**: Complete AST-based parser for template expressions
  - Literals: strings, numbers, booleans
  - Property access: dot notation, nested paths
  - Binary operators: +, -, *, /, %, ==, !=, <, >, <=, >=, &&, ||
  - Unary operators: !, -
  - Ternary operator: condition ? true : false
  - Function calls with arguments
- **ExpressionEvaluator.swift**: Type-safe evaluation with automatic coercion
- **TemplateEngine.swift**: Full template expansion with ${...} syntax
  - String template expansion
  - JSON object expansion
  - $when conditional rendering
  - $data array iteration
- **5 Function Categories** (60+ total functions):
  - StringFunctions (13): toLower, toUpper, substring, indexOf, length, replace, split, join, trim, startsWith, endsWith, contains, format
  - DateFunctions (8): formatDateTime, addDays, addHours, getYear, getMonth, getDay, dateDiff, utcNow
  - CollectionFunctions (8): count, first, last, filter, sort, flatten, union, intersection
  - LogicFunctions (10): if, equals, not, and, or, greaterThan, lessThan, exists, empty, isMatch
  - MathFunctions (11): add, sub, mul, div, mod, min, max, round, floor, ceil, abs
- **ACTemplatingTests.swift**: 40+ comprehensive unit tests
- **Package.swift**: Updated with ACTemplating module and dependencies

#### Test Cards
- ✅ templating-basic.json: Simple property binding
- ✅ templating-conditional.json: $when conditions
- ✅ templating-iteration.json: $data array iteration with $index
- ✅ templating-expressions.json: Complex expressions with functions
- ✅ templating-nested.json: Nested data contexts with $root

### ✅ Completed

#### Android ac-templating Module
- ✅ Directory structure created
- ✅ build.gradle.kts configured with proper plugin management
- ✅ settings.gradle.kts updated
- ✅ **DataContext.kt**: Full nested context support with $root, $data, $index
- ✅ **ExpressionParser.kt**: Complete AST-based parser for template expressions
- ✅ **ExpressionEvaluator.kt**: Type-safe evaluation with automatic coercion
- ✅ **TemplateEngine.kt**: Full template expansion with ${...} syntax
- ✅ **5 Function Categories** (50 total functions):
  - StringFunctions (13): toLower, toUpper, substring, indexOf, length, replace, split, join, trim, startsWith, endsWith, contains, format
  - DateFunctions (8): formatDateTime, addDays, addHours, getYear, getMonth, getDay, dateDiff, utcNow
  - CollectionFunctions (8): count, first, last, filter, sort, flatten, union, intersection
  - LogicFunctions (10): if, equals, not, and, or, greaterThan, lessThan, exists, empty, isMatch
  - MathFunctions (11): add, sub, mul, div, mod, min, max, round, floor, ceil, abs
- ✅ **TemplateEngineTest.kt**: 50+ comprehensive unit tests

### 📋 Remaining Work

## Phase 1: Templating Engine (Completion: 100%) ✅

**Status:** Complete

Phase 1 is now complete with full feature parity between iOS and Android templating engines. Both platforms support:
- Complete AST-based expression parsing
- Type-safe evaluation with automatic coercion
- 50+ built-in functions across 5 categories
- Full template expansion with $when and $data
- Nested data contexts with $root, $data, and $index
- Comprehensive unit test coverage (40+ iOS tests, 50+ Android tests)

**Effort:** 15 hours total

---

## Phase 2: Advanced Elements + Markdown + Fluent Theming (0%)

### 2A. Markdown Rendering
- **iOS ACMarkdown module**: MarkdownParser, MarkdownRenderer
- **Android ac-markdown module**: Same functionality
- Integration with TextBlock element
- Test cards: markdown.json

### 2B. ListView Element
- **iOS**: ListView.swift with LazyVStack
- **Android**: ListView.kt with LazyColumn
- Properties: maxHeight, style, spacing
- Test cards: list.json

### 2C. DataGridInput
- **iOS**: DataGridInputView.swift
- **Android**: DataGridInputView.kt
- Column types: text, number, date, toggle
- Sorting, filtering, editing
- Test cards: datagrid.json

### 2D. CompoundButton
- **iOS**: CompoundButtonView.swift
- **Android**: CompoundButtonView.kt
- Fluent-style layout with icon, title, subtitle
- Test cards: compound-buttons.json

### 2E. Charts
- **iOS ACCharts module**: 4 chart types (Donut, Bar, Line, Pie)
- **Android ac-charts module**: Same 4 chart types
- Accessibility: Verbal descriptions, data point navigation
- Test cards: charts.json

### 2F. Fluent UI Theming
- **iOS ACFluentUI module**: FluentTheme, FluentColorTokens
- **Android ac-fluent-ui module**: Same
- Integration with HostConfig
- Test cards: fluent-theming.json

### 2G. Schema Validation
- Validate against Adaptive Card schema v1.6
- Offline validation
- Structured error reporting

### 2H. Model Updates
- Add `targetWidth` property to all elements
- Add `themedUrls` / `themedIconUrls` to Image
- Test cards: responsive-layout.json, themed-images.json

**Estimated Effort:** 40-50 hours

---

## Phase 3: Advanced Actions + Copilot Extensions + Teams (0%)

### 3A. Advanced Actions
- Action.Popover: iOS .sheet(), Android ModalBottomSheet
- Action.RunCommands: Command dispatch to host
- Action.OpenUrlDialog: iOS SFSafariViewController, Android Custom Tab
- Test cards: popover-action.json

### 3B. Menu Actions / Split Buttons
- ActionSet overflow mode
- iOS Menu, Android DropdownMenu
- Test cards: split-buttons.json

### 3C. Copilot Extensions Module
- **iOS ACCopilotExtensions**: CitationView, StreamingCardView, CopilotReferenceView, CopilotExtensionTypes
- **Android ac-copilot-extensions**: Same
- Test cards: copilot-citations.json, streaming-card.json

### 3D. Teams Integration Module
- **iOS ACTeams**: TeamsCardHost, AuthTokenProvider, DeepLinkHandler, TaskModulePresenter, StageViewPresenter, TeamsFluentTheme
- **Android ac-teams**: Same
- Test cards: teams-task-module.json

**Estimated Effort:** 30-40 hours

---

## Phase 4: Sample Apps (0%)

### iOS Sample App
- SwiftUI app with 6 screens:
  - Card Gallery: Browse 30+ test cards
  - Card JSON Editor: Live preview
  - Teams Simulator: Chat UI simulation
  - Action Log: Real-time action tracking
  - Settings: Theme, form factor, accessibility toggles
  - Performance Dashboard: Parse/render/memory metrics
- README with build instructions

### Android Sample App
- Jetpack Compose app with same 6 screens
- Material 3 theming
- README with build instructions

**Estimated Effort:** 24-30 hours

---

## Phase 5: Production Readiness (0%)

### 5A. Visual Regression Tests
- **iOS**: swift-snapshot-testing, multiple configurations
- **Android**: Paparazzi, multiple configurations

### 5B. CI/CD Hardening
- Snapshot test jobs
- Lint checks (SwiftLint, ktlint)
- Build matrix (multiple OS versions)
- Code coverage reporting

### 5C. SDK Publishing Configuration
- **iOS**: Package.swift products, version tagging, umbrella module
- **Android**: maven-publish plugin, POM metadata

### 5D. API Documentation
- **iOS**: DocC catalog, doc comments, examples
- **Android**: Dokka, KDoc comments, examples

### 5E. Performance Benchmarks
- **iOS**: CardParsingBenchmarks, CardRenderingBenchmarks, TemplatingBenchmarks
- **Android**: Same with AndroidX Benchmark

### 5F-5H. Documentation
- Comprehensive README update
- CHANGELOG.md for v1.0.0
- MIGRATION.md from legacy SDK

**Estimated Effort:** 20-25 hours

---

## Total Estimated Effort: 130-165 hours

## Implementation Priority

### High Priority (Must Have for v1.0)
1. ✅ Phase 1: Templating Engine (100% complete)
2. Phase 2: Markdown + Basic Advanced Elements (ListView, CompoundButton)
3. Phase 5: API Documentation + README

### Medium Priority (Should Have)
4. Phase 2: Charts + Fluent Theming
5. Phase 3: Basic Advanced Actions (Popover, RunCommands)
6. Phase 4: Sample Apps

### Lower Priority (Nice to Have)
7. Phase 2: DataGridInput + Schema Validation
8. Phase 3: Copilot Extensions + Teams Integration
9. Phase 5: Visual Regression Tests + Performance Benchmarks

## Success Criteria

### Functional Requirements
- [x] Templating works with all expression types
- [ ] All test cards render correctly on both platforms
- [ ] 100% cross-platform naming consistency
- [ ] Full accessibility compliance (WCAG 2.1 AA)
- [ ] Responsive design on phone and tablet

### Quality Requirements
- [ ] <16ms render time for all cards
- [ ] No memory leaks
- [ ] Graceful error handling
- [ ] 80%+ code coverage
- [ ] All public APIs documented

### Publishing Requirements
- [ ] iOS Package.swift ready for SPM
- [ ] Android modules ready for Maven Central
- [ ] Comprehensive documentation
- [ ] Migration guide from legacy SDK
- [ ] Sample apps demonstrating features

## Next Immediate Steps

1. **Complete Android ac-templating module** (~10 hours)
   - Port iOS implementation to Kotlin
   - Match all 60+ functions
   - Add 40+ unit tests

2. **Integrate templating with parsers** (~4 hours)
   - Update ACCore (both platforms) to accept template data
   - Add AdaptiveCardView(template:data:) overloads

3. **Begin Phase 2: Markdown + ListView** (~8 hours)
   - Essential for basic content rendering
   - High ROI for developer experience

4. **Documentation sprint** (~4 hours)
   - API reference for completed modules
   - Usage examples
   - Update root README

## Risk Mitigation

### Technical Risks
- **SwiftUI/Compose compatibility**: Test on minimum supported OS versions early
- **Performance**: Profile early and often, especially for templating
- **Memory leaks**: Use instruments/leak canary throughout development

### Schedule Risks
- **Scope creep**: Stick to defined phases, defer non-essential features
- **Platform parity**: Use shared test cards to verify consistency
- **Testing overhead**: Automate as much as possible

### Quality Risks
- **Accessibility**: Test with VoiceOver/TalkBack from day one
- **Error handling**: Never crash on malformed JSON
- **Thread safety**: All parsing on background threads, UI on main thread

## Conclusion

This implementation plan provides a clear roadmap for completing all 5 phases of the Adaptive Cards Mobile SDK. Phase 1 is now 100% complete with full cross-platform parity in templating engines. Both iOS and Android have feature-complete implementations with 50+ functions and comprehensive test coverage. The remaining work is well-defined and estimated at 115-155 hours total.

The prioritization ensures that the most critical features (templating, basic rendering, documentation) are completed first, while advanced features (Copilot, Teams integration) can be deferred to later releases if needed.
