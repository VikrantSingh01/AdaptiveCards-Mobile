# Adaptive Cards v1.6 Parity Target

**Last Updated**: February 13, 2026  
**Document Owner**: AdaptiveCards-Mobile Team  
**Target Schema Version**: 1.6  
**Status**: Active

---

## Overview

This document defines the target schema version, host environment constraints, and feature support policy for the AdaptiveCards-Mobile SDK. It serves as the authoritative reference for what features are in scope and what assumptions the SDK makes about its host environment.

---

## Target Schema

### Adaptive Cards Version 1.6

The AdaptiveCards-Mobile SDK targets **Adaptive Cards schema version 1.6**, which is the current stable version used by Microsoft Teams and other Microsoft 365 applications.

**Official Schema Reference**:
- Schema URL: `http://adaptivecards.io/schemas/adaptive-card.json`
- Documentation: https://adaptivecards.io/explorer/
- Schema Specification: https://github.com/microsoft/AdaptiveCards/tree/main/schemas

### Version Compatibility

- **Supported**: Cards with `"version": "1.0"` through `"version": "1.6"`
- **Forward Compatibility**: Cards with versions > 1.6 are accepted but features beyond 1.6 may not be supported
- **Unknown Elements**: Elements not in the v1.6 spec are parsed as `UnknownElement` and handled gracefully without rendering errors

---

## Host Constraints and Assumptions

### Microsoft Teams Integration

The SDK is designed to be compatible with Microsoft Teams host capabilities:

1. **Action Handling**
   - `Action.Submit`: Collects input data and returns to host
   - `Action.OpenUrl`: Opens URLs in system browser or in-app webview
   - `Action.Execute`: Universal action handler for bot framework operations
   - `Action.ShowCard`: Inline card expansion within the current card
   - `Action.ToggleVisibility`: Client-side element visibility control

2. **Authentication & Security**
   - SDK does not handle authentication tokens directly
   - Host application is responsible for securing network calls
   - Image URLs must be publicly accessible or authenticated by host
   - No execution of arbitrary code or scripts

3. **Network Operations**
   - SDK loads images asynchronously with caching
   - Host application handles all backend API calls
   - No direct network calls to third-party services without host mediation

4. **Data Binding & Templating**
   - Full support for Adaptive Cards templating language
   - 60+ expression functions across 5 categories
   - Host provides data context for template expansion

### Platform-Specific Constraints

#### iOS (SwiftUI)
- **Minimum Deployment Target**: iOS 16.0+
- **Swift Version**: 5.9+
- **Frameworks**: SwiftUI, UIKit (for media playback)
- **Accessibility**: VoiceOver, Dynamic Type
- **UI Paradigm**: Declarative SwiftUI views

#### Android (Jetpack Compose)
- **Minimum SDK**: API 24 (Android 7.0 Nougat)
- **Kotlin Version**: 1.9+
- **Frameworks**: Jetpack Compose, Material 3
- **Accessibility**: TalkBack, Dynamic Font Scaling
- **UI Paradigm**: Declarative Compose composables

---

## Supported Features Policy

### ✅ Fully Supported (In Scope)

All features in this category are implemented and tested on both iOS and Android:

#### Core Elements
- TextBlock, Image, RichTextBlock, Media
- Container, ColumnSet, Column, FactSet, ImageSet, ActionSet
- Table (with headers, styling, column definitions)

#### Input Elements
- Input.Text, Input.Number, Input.Date, Input.Time
- Input.Toggle, Input.ChoiceSet, Input.Rating

#### Advanced Elements (v1.3+)
- Carousel (with auto-play, page indicators, RTL support)
- Accordion (with expand/collapse animations)
- CodeBlock (with syntax highlighting)
- Rating (display mode)
- ProgressBar, Spinner
- TabSet, List, CompoundButton

#### Chart Elements (Extension)
- DonutChart, BarChart, LineChart, PieChart
- Custom extension following Adaptive Cards extensibility model

#### Actions
- Action.Submit (form submission)
- Action.OpenUrl (URL navigation)
- Action.Execute (universal bot framework action)
- Action.ShowCard (inline card expansion)
- Action.ToggleVisibility (element visibility control)

#### Advanced Features
- Templating with 60+ expression functions
- Markdown parsing (CommonMark subset)
- Theming via HostConfig
- Accessibility (WCAG 2.1 AA compliance)
- Responsive layout (phone/tablet, portrait/landscape)
- RTL (Right-to-Left) language support
- Unknown element fallback handling

### ⚠️ Partially Supported (Limitations)

Features with known platform limitations or host dependencies:

#### Media Playback
- **Supported**: Video with poster, basic controls
- **Limitation**: Advanced media controls depend on platform media player capabilities
- **Host Dependency**: Some DRM or streaming protocols require host support

#### Action.OpenUrl
- **Supported**: Opening URLs in system browser
- **Limitation**: In-app webview requires host application implementation
- **Security**: URL scheme filtering (http/https) enforced by default

#### Refresh Behavior
- **Supported**: Card refresh via host application API
- **Limitation**: Automatic refresh requires host implementation
- **Note**: SDK provides refresh callbacks but does not initiate network calls

### ❌ Not Supported (Out of Scope)

Features explicitly not implemented:

#### Authentication Flow
- **Reason**: Security-sensitive operation handled by host application
- **Alternative**: Host provides authenticated context and data

#### Arbitrary Code Execution
- **Reason**: Security risk, violates app store policies
- **Alternative**: Use Action.Execute with controlled backend operations

#### Third-Party Extensions
- **Reason**: Version 1.6 does not define extension mechanism
- **Alternative**: Use UnknownElement pattern for forward compatibility

#### Direct Backend Communication
- **Reason**: Network calls are host responsibility
- **Alternative**: Action.Execute triggers host-mediated API calls

---

## v1.6 Specific Features

### New in v1.6

1. **Enhanced Table Support**
   - Grid-based table with row/column spanning (basic support)
   - Table headers with styling
   - Column width control

2. **Action.Execute Enhancements**
   - Associated inputs property
   - Verb property for semantic action identification
   - Fallback action support

3. **Compound Button**
   - Button with title, description, and icon
   - Badge support for notifications

4. **Enhanced Input Validation**
   - Error messages on inputs
   - Required field validation
   - Regex pattern validation for Input.Text

5. **Responsive Design**
   - Target width ranges (narrow/standard/wide)
   - Container bleed support
   - Minimum height constraints

### v1.6 Features Not Yet Implemented

The following v1.6 features are **tracked for future implementation**:

1. **menuActions (Overflow Menu)**
   - **Status**: Research phase
   - **Tracking**: See PARITY_MATRIX.md for updates
   - **Workaround**: Use ActionSet with standard actions

2. **Advanced Table Features**
   - Row/column spanning (basic support only)
   - Complex cell merging
   - **Workaround**: Use nested containers for complex layouts

3. **Enhanced Authentication Flow**
   - Auth token management
   - **Reason**: Host application responsibility

---

## Feature Request Process

### Adding New Features

1. **Verify v1.6 Compliance**: Check if feature is part of Adaptive Cards v1.6 spec
2. **Cross-Platform Requirement**: All features must be implemented on both iOS and Android
3. **Update Documentation**: Update PARITY_MATRIX.md and this document
4. **Add Tests**: Include unit tests and integration tests with shared test cards
5. **Schema Validation**: Ensure schema validator recognizes new elements

### Deprecating Features

1. **Announcement**: Provide 2 release cycles notice
2. **Migration Path**: Document alternatives and upgrade guide
3. **Fallback Behavior**: Gracefully handle deprecated features for backward compatibility

---

## Testing Requirements

### Schema Validation

All cards must:
- Include `"type": "AdaptiveCard"`
- Include `"version"` field with X.Y format (e.g., "1.6")
- Contain valid element types from v1.6 spec
- Pass JSON schema validation

### Cross-Platform Testing

All features must be tested on:
- iOS: Xcode with Swift Package Manager tests
- Android: Gradle with Kotlin unit tests
- Shared test cards: 40+ cards covering all element types
- Edge cases: Empty cards, deeply nested structures, unknown types

### CI/CD Requirements

- Automated tests run on every PR
- Parity gate ensures both platforms pass
- Schema validation for all test cards
- Visual regression tests (where applicable)

---

## References

### Official Documentation
- [Adaptive Cards Homepage](https://adaptivecards.io/)
- [Schema Explorer](https://adaptivecards.io/explorer/)
- [Schema Specification](https://github.com/microsoft/AdaptiveCards)
- [Teams Adaptive Cards](https://docs.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-reference)

### Internal Documentation
- [PARITY_MATRIX.md](./PARITY_MATRIX.md) - Feature-by-feature implementation status
- [RENDERING_PARITY_CHECKLIST.md](../../shared/RENDERING_PARITY_CHECKLIST.md) - Rendering parity tracking
- [IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md) - Development roadmap

### Related Standards
- [WCAG 2.1 Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design (Android)](https://m3.material.io/)
- [Human Interface Guidelines (iOS)](https://developer.apple.com/design/human-interface-guidelines/)

---

## Change History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2026-02-13 | 1.0 | Initial document creation for v1.6 parity target | AdaptiveCards-Mobile Team |

---

**Document Status**: ✅ Active  
**Next Review**: Q2 2026 (or when v1.7 is released)
