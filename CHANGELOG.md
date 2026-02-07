# Changelog

All notable changes to the Adaptive Cards Mobile SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-02-07

### 🎉 Initial Release

First stable release of the Adaptive Cards Mobile SDK for iOS and Android with complete feature parity.

### ✨ Added

#### Core Features
- **Adaptive Card Schema 1.5 Support**: Full compliance with Adaptive Cards schema version 1.5
- **JSON Parsing**: Robust JSON deserialization with validation and error handling
- **Template Binding**: Dynamic data binding with expressions and conditional rendering
- **Host Configuration**: Customizable styling, spacing, and behavior configuration

#### Platform SDKs

**iOS (Swift)**
- Swift Package Manager integration
- SwiftUI-native rendering engine
- 11 modular packages for granular dependency management
- Comprehensive unit test suite
- iOS 16+ support

**Android (Kotlin)**
- Gradle dependency management
- Jetpack Compose rendering engine
- 12 modular libraries for flexible integration
- Comprehensive unit test suite
- Android API 26+ support

#### Elements & Containers
- **Text Elements**: TextBlock, RichTextBlock with markdown support
- **Images**: Image with themed variants and fallback support
- **Media**: Audio and video playback
- **Containers**: Container, ColumnSet, Column, FactSet
- **Advanced Containers**: List, Carousel, Accordion, TabSet, Table

#### Input Elements
- Input.Text with validation
- Input.Number with range constraints
- Input.Date and Input.Time
- Input.Toggle (checkbox/switch)
- Input.ChoiceSet (radio/dropdown)

#### Actions
- Action.OpenUrl
- Action.Submit with data aggregation
- Action.ShowCard (inline card expansion)
- Action.ToggleVisibility
- Action.Execute
- **Advanced Actions**: CompoundButton, SplitButton, PopoverAction

#### Advanced Features
- **Charts Module**: Bar, Line, Pie, Donut charts with customizable styling
- **DataGrid**: Sortable, filterable data tables with pagination
- **Markdown Support**: Full CommonMark rendering
- **Fluent UI Integration**: Microsoft Fluent Design theming
- **Teams Integration**: Teams-specific card types and actions
- **Copilot Extensions**: Citation rendering and streaming cards
- **Accessibility**: WCAG 2.1 AA compliance, screen reader support
- **Responsive Design**: Automatic layout adaptation for different screen sizes

#### Sample Applications
- **iOS Sample App**: SwiftUI app with card gallery, editor, Teams simulator, and performance dashboard
- **Android Sample App**: Jetpack Compose app with complete feature showcase

#### Testing & Quality
- 500+ unit tests across both platforms
- Snapshot/visual regression tests
- Performance benchmarks
- CI/CD pipelines with GitHub Actions
- Code coverage reporting

#### Documentation
- Comprehensive README files
- Architecture documentation
- API documentation (inline comments)
- Usage guides and examples
- Migration guide from legacy SDK
- Contributing guidelines

### 📦 Module Structure

**iOS Modules**:
- `ACCore` - Core models and parsing
- `ACRendering` - SwiftUI rendering engine
- `ACInputs` - Input elements
- `ACActions` - Action handling
- `ACAccessibility` - Accessibility support
- `ACTemplating` - Template binding
- `ACMarkdown` - Markdown rendering
- `ACCharts` - Chart components
- `ACFluentUI` - Fluent Design theming
- `ACCopilotExtensions` - Copilot features
- `ACTeams` - Teams integration

**Android Modules**:
- `ac-core` - Core models and parsing
- `ac-rendering` - Compose rendering engine
- `ac-inputs` - Input elements
- `ac-actions` - Action handling
- `ac-accessibility` - Accessibility support
- `ac-templating` - Template binding
- `ac-markdown` - Markdown rendering
- `ac-charts` - Chart components
- `ac-fluent-ui` - Fluent Design theming
- `ac-copilot-extensions` - Copilot features
- `ac-teams` - Teams integration
- `ac-host-config` - Configuration management

### 🔧 Technical Details

#### Performance
- Average parse time: <5ms for typical cards
- Average render time: <10ms for typical cards
- Minimal memory footprint
- Optimized for 60fps scrolling

#### Compatibility
- **iOS**: iOS 16.0+, iPadOS 16.0+
- **Android**: API 26+ (Android 8.0 Oreo)
- **Swift**: 5.9+
- **Kotlin**: 1.9+

### 📝 Known Limitations

- Video playback requires network connectivity
- Some advanced chart types may have rendering variations across platforms
- Custom host config validation is runtime-only (no compile-time checking)

### 🙏 Acknowledgments

Built following the [Adaptive Cards specification](https://adaptivecards.io/) by Microsoft.

---

## [Unreleased]

### Future Enhancements
- Animation support for card transitions
- Offline card caching
- Enhanced analytics and telemetry
- Additional chart types
- Custom element extensibility API

---

[1.0.0]: https://github.com/VikrantSingh01/AdaptiveCards-Mobile/releases/tag/v1.0.0
[Unreleased]: https://github.com/VikrantSingh01/AdaptiveCards-Mobile/compare/v1.0.0...HEAD
