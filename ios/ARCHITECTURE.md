# iOS Adaptive Cards SDK - Architecture Documentation

**Platform:** iOS 16+, Swift 5.9+, SwiftUI

---

## Table of Contents

1. [Overview](#overview)
2. [Module Architecture](#module-architecture)
3. [Module Details](#module-details)
4. [Data Flow](#data-flow)
5. [Rendering Pipeline](#rendering-pipeline)
6. [Extension Points](#extension-points)
7. [Design Patterns](#design-patterns)
8. [Performance Considerations](#performance-considerations)
9. [Accessibility Architecture](#accessibility-architecture)
10. [Testing Strategy](#testing-strategy)

---

## Overview

The iOS Adaptive Cards SDK is a modular, SwiftUI-based framework for rendering Adaptive Cards on Apple platforms. The architecture follows clean separation of concerns with distinct modules for parsing, rendering, actions, inputs, templating, and accessibility.

### Core Principles

- **Modularity**: Each concern is isolated in its own Swift Package Manager module
- **Type Safety**: Strong typing throughout with Codable models
- **Declarative UI**: Pure SwiftUI views with no UIKit dependencies in rendering layer
- **Performance**: Lazy loading, caching, and efficient rendering
- **Accessibility**: VoiceOver support built into every component
- **Testability**: Protocol-based design enables comprehensive unit testing

### High-Level Rendering Pipeline

```
┌─────────────────────────────────────────────┐
│          SwiftUI Host Application           │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│          ACRendering (Views)                │
│  • AdaptiveCardView                         │
│  • Element Views (TextBlock, Image, etc.)   │
│  • Container Views                          │
│  • Advanced Element Views                   │
└──────┬──────────────────────────┬───────────┘
       │                          │
┌──────▼──────┐           ┌──────▼──────────┐
│  ACInputs   │           │   ACActions     │
│  • Input    │           │   • Action      │
│    Controls │           │     Handlers    │
└──────┬──────┘           └──────┬──────────┘
       │                          │
       │      ┌──────────┐        │
       └──────►  ACCore  ◄────────┘
              │  • Models│
              │  • Parser│
              └──────┬───┘
                     │
              ┌──────▼─────────┐
              │ ACTemplating   │
              │ • Template     │
              │   Engine       │
              └────────────────┘
```

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
│                  (Host App / Sample App)                     │
└────────────┬────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────┐
│                   ACRendering Module                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ AdaptiveCard │  │   Element    │  │   Renderer   │     │
│  │     View     │──│   Registry   │──│    Views     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└───────┬──────────────────┬──────────────────┬──────────────┘
        │                  │                  │
        ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  ACInputs    │  │  ACActions   │  │  ACMarkdown  │
│              │  │              │  │              │
│ Input Views  │  │Action Handler│  │  Markdown    │
│ & Validation │  │& Dispatching │  │  Rendering   │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                  │                  │
       └──────────────────┴──────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │   ACAccessibility     │
              │  Accessibility Utils  │
              └───────────┬───────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │      ACCore           │
              │  ┌─────────────────┐  │
              │  │ Models (Codable)│  │
              │  ├─────────────────┤  │
              │  │  Card Parser    │  │
              │  ├─────────────────┤  │
              │  │   HostConfig    │  │
              │  └─────────────────┘  │
              └───────────┬───────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │    ACTemplating       │
              │  ┌─────────────────┐  │
              │  │ Template Engine │  │
              │  ├─────────────────┤  │
              │  │Expression Parser│  │
              │  ├─────────────────┤  │
              │  │   60 Functions  │  │
              │  └─────────────────┘  │
              └───────────────────────┘
```

---

## Module Architecture

### Module Dependency Graph

```
ACRendering
  ├── ACCore
  ├── ACInputs
  │   ├── ACCore
  │   └── ACAccessibility
  ├── ACActions
  │   ├── ACCore
  │   └── ACAccessibility
  └── ACAccessibility
      └── ACCore

ACMarkdown
  └── ACCore

ACTemplating
  └── ACCore
```

### Module Responsibilities

| Module | Responsibility | Public API Surface |
|--------|---------------|-------------------|
| **ACCore** | Data models, parsing, host configuration | Models, Parser, HostConfig |
| **ACAccessibility** | VoiceOver support, Dynamic Type, accessibility utilities | Accessibility modifiers, helpers |
| **ACRendering** | SwiftUI views for all card elements | AdaptiveCardView, element views |
| **ACInputs** | Input elements (text, choice, date, etc.) | Input views, validation |
| **ACActions** | Action handling (submit, open URL, etc.) | Action views, delegates |
| **ACTemplating** | Template expansion with expressions | TemplateEngine, functions |
| **ACMarkdown** | Markdown parsing and rendering | MarkdownParser, MarkdownTextView |

---

## Module Details

### ACCore

**Purpose:** Foundation module containing all data models, JSON parsing, and host configuration.

**Key Components:**

```swift
// Core Models
public struct AdaptiveCard: Codable
public enum CardElement: Codable {
    case textBlock(TextBlock)
    case image(Image)
    case container(Container)
    case columnSet(ColumnSet)
    case factSet(FactSet)
    case imageSet(ImageSet)
    case actionSet(ActionSet)
    case list(ListElement)
    // ... advanced elements
}

// Parser
public final class CardParser {
    public static func parse(json: String) throws -> AdaptiveCard
    public static func parse(data: Data) throws -> AdaptiveCard
}

// Host Configuration
public struct HostConfig: Codable {
    public var spacing: SpacingConfig
    public var fontFamily: String?
    public var fontSizes: FontSizeConfig
    public var fontWeights: FontWeightConfig
    public var containerStyles: ContainerStyleConfig
    // ...
}
```

**Design Decisions:**
- All models are `struct` (value types) for thread safety and immutability
- `Codable` conformance for automatic JSON serialization/deserialization
- Enums with associated values for polymorphic element types
- Custom `CodingKeys` for property name mapping

**Files:**
- `Models/`: CardElement.swift, CardAction.swift, CardInput.swift, ContainerTypes.swift, AdvancedElements.swift, Enums.swift, Metadata.swift
- `Parser/`: CardParser.swift, ElementDecoder.swift, FallbackHandler.swift
- `Config/`: HostConfig.swift

---

### ACAccessibility

**Purpose:** Centralized accessibility utilities and SwiftUI modifiers for VoiceOver support.

**Key Components:**

```swift
// Accessibility Extensions
public extension View {
    func cardAccessibility(
        label: String?,
        hint: String?,
        traits: AccessibilityTraits
    ) -> some View
    
    func minimumTouchTarget(
        minWidth: CGFloat = 44,
        minHeight: CGFloat = 44
    ) -> some View
}

// Dynamic Type Support
public struct ScaledFont: ViewModifier {
    let size: CGFloat
    let weight: Font.Weight
}
```

**Design Decisions:**
- View extensions for consistent accessibility patterns
- Minimum 44pt touch targets enforced via modifiers
- Dynamic Type support using `@ScaledMetric`
- VoiceOver announcements for state changes

**Files:**
- `AccessibilityExtensions.swift`
- `DynamicTypeSupport.swift`

---

### ACRendering

**Purpose:** SwiftUI views for rendering all Adaptive Card elements.

**Key Components:**

```swift
// Main View
public struct AdaptiveCardView: View {
    public init(card: AdaptiveCard, hostConfig: HostConfig = .default)
    public init(json: String, hostConfig: HostConfig = .default)
    public var body: some View { /* rendering logic */ }
}

// Element Renderer Registry
public final class ElementRendererRegistry {
    public static func registerRenderer(
        for type: String,
        renderer: @escaping (CardElement, HostConfig) -> AnyView
    )
}

// View Model
@MainActor
public final class CardViewModel: ObservableObject {
    @Published public var actionLog: [ActionEntry] = []
    @Published public var inputValues: [String: Any] = [:]
}
```

**Element Views:**
- TextBlockView.swift - Text rendering with markdown support
- ImageView.swift - Image loading and caching
- ContainerView.swift - Container with styling
- ColumnSetView.swift - Multi-column layouts
- FactSetView.swift - Key-value pairs
- ImageSetView.swift - Image grids
- ActionSetView.swift - Button groups
- ListView.swift - Scrollable lists (NEW in Phase 2B)
- MediaView.swift, TableView.swift - Media and tables
- RichTextBlockView.swift - Rich text rendering
- AccordionView.swift - Expandable sections
- CarouselView.swift - Swipeable content
- CodeBlockView.swift - Code syntax display
- RatingDisplayView.swift - Star ratings
- ProgressBarView.swift, SpinnerView.swift - Progress indicators
- TabSetView.swift - Tabbed navigation

**Design Decisions:**
- Views are stateless and data-driven
- `@Environment` for HostConfig propagation
- `CardViewModel` for action/input state management
- Lazy loading for lists and carousels
- Conditional rendering based on `isVisible`

**Files:**
- `Views/`: All element view implementations
- `CardViewModel.swift`
- `ElementRendererRegistry.swift`

---

### ACInputs

**Purpose:** Input elements with validation and data collection.

**Key Components:**

```swift
// Input Views
public struct TextInputView: View
public struct NumberInputView: View
public struct DateInputView: View
public struct TimeInputView: View
public struct ToggleInputView: View
public struct ChoiceSetInputView: View
public struct RatingInputView: View

// Input Protocol
public protocol CardInputProtocol {
    var id: String { get }
    var value: Any? { get }
    var isValid: Bool { get }
}
```

**Input Types Supported:**
- Input.Text - Single/multi-line text with validation
- Input.Number - Numeric input with min/max
- Input.Date - Date picker
- Input.Time - Time picker
- Input.Toggle - Boolean switch
- Input.ChoiceSet - Single/multi-select with compact/expanded/filtered styles
- Input.Rating - Star rating (1-10 scale)

**Design Decisions:**
- Two-way binding with `@Binding` for real-time updates
- Validation rules enforced (required, min/max, regex)
- Error states with visual feedback
- Accessibility labels for all inputs

**Files:**
- `Views/`: TextInputView.swift, NumberInputView.swift, DateInputView.swift, TimeInputView.swift, ToggleInputView.swift, ChoiceSetInputView.swift, RatingInputView.swift
- `InputValidation.swift`

---

### ACActions

**Purpose:** Action handling and dispatching for user interactions.

**Key Components:**

```swift
// Action Views
public struct ActionButton: View
public struct ShowCardActionView: View

// Action Protocol
public protocol ActionDelegate: AnyObject {
    func handleAction(_ action: CardAction)
    func onSubmit(data: [String: Any])
    func onOpenUrl(url: URL)
    func onExecute(verb: String, data: [String: Any])
    func onToggleVisibility(targetElementIds: [String])
}
```

**Action Types Supported:**
- Action.Submit - Submit input values
- Action.OpenUrl - Open URL in browser
- Action.ShowCard - Expand card inline
- Action.Execute - Execute custom action
- Action.ToggleVisibility - Show/hide elements

**Design Decisions:**
- Delegate pattern for action callbacks
- Action logging in CardViewModel
- Async URL opening for non-blocking UI
- ShowCard state managed in CardViewModel

**Files:**
- `ActionButton.swift`
- `ShowCardActionView.swift`
- `ActionDelegate.swift`

---

### ACTemplating

**Purpose:** Template expansion engine with expression evaluation.

**Key Components:**

```swift
// Template Engine
public final class TemplateEngine {
    public func expand(template: String, data: [String: Any]) throws -> String
    public func expand(template: [String: Any], data: [String: Any]) throws -> [String: Any]
}

// Expression Parser
public final class ExpressionParser {
    public func parse(_ expression: String) throws -> Expression
}

public indirect enum Expression: Equatable {
    case literal(Any)
    case propertyAccess(String)
    case functionCall(name: String, arguments: [Expression])
    case binaryOp(operator: String, left: Expression, right: Expression)
    case unaryOp(operator: String, operand: Expression)
    case ternary(condition: Expression, trueValue: Expression, falseValue: Expression)
}

// Expression Evaluator
public final class ExpressionEvaluator {
    public func evaluate(_ expression: Expression) throws -> Any?
}

// Data Context
public final class DataContext {
    public func resolve(path: String) -> Any?
    public func createChild(data: Any?, index: Int?) -> DataContext
}
```

**Expression Features:**
- Property access: `${userName}`, `${user.email}`
- Operators: `+`, `-`, `*`, `/`, `%`, `==`, `!=`, `<`, `>`, `<=`, `>=`, `&&`, `||`, `!`
- Ternary: `${age >= 18 ? "Adult" : "Minor"}`
- Functions: 60 built-in functions across 5 categories
- Special variables: `$data`, `$root`, `$index`
- Conditional rendering: `$when`
- Array iteration: `$data`

**Built-in Functions:**

| Category | Functions (13) |
|----------|---------------|
| **String** | toLower, toUpper, substring, indexOf, length, replace, split, join, trim, startsWith, endsWith, contains, format |
| **Date** | formatDateTime, addDays, addHours, getYear, getMonth, getDay, dateDiff, utcNow |
| **Collection** | count, first, last, filter, sort, flatten, union, intersection |
| **Logic** | if, equals, not, and, or, greaterThan, lessThan, exists, empty, isMatch |
| **Math** | add, sub, mul, div, mod, min, max, round, floor, ceil, abs |

**Design Decisions:**
- AST-based parsing for correctness
- Type coercion for JavaScript-like behavior
- Caching of parsed expressions (future enhancement)
- Null-safe evaluation
- Descriptive error messages

**Files:**
- `TemplateEngine.swift`
- `ExpressionParser.swift`
- `ExpressionEvaluator.swift`
- `DataContext.swift`
- `Functions/`: StringFunctions.swift, DateFunctions.swift, CollectionFunctions.swift, LogicFunctions.swift, MathFunctions.swift

---

### ACMarkdown

**Purpose:** Markdown parsing and rendering for TextBlock elements.

**Key Components:**

```swift
// Markdown Parser
public final class MarkdownParser {
    public func parse(_ markdown: String) -> [MarkdownNode]
}

public enum MarkdownNode: Equatable {
    case text(String)
    case bold(String)
    case italic(String)
    case code(String)
    case link(text: String, url: String)
    case header(level: Int, text: String)
    case bulletList([String])
    case orderedList([String])
}

// Markdown Renderer
public final class MarkdownRenderer {
    public func render(_ nodes: [MarkdownNode]) -> AttributedString
}

// SwiftUI View
public struct MarkdownTextView: View {
    public init(markdown: String)
    public var body: some View { /* renders attributed text */ }
}
```

**Supported Markdown:**
- Bold: `**text**`
- Italic: `*text*`
- Inline code: `` `code` ``
- Links: `[text](url)` (clickable)
- Headers: `#` (H1), `##` (H2), `###` (H3)
- Bullet lists: `- item`
- Numbered lists: `1. item`

**Design Decisions:**
- NSCache for parsed markdown (100 entries max)
- AttributedString for proper SwiftUI integration
- Smart detection: Only parse if markdown syntax present
- Graceful degradation for malformed markdown
- Link tappability via `.environment(\.openURL)`

**Files:**
- `MarkdownParser.swift`
- `MarkdownRenderer.swift`
- `MarkdownTextView.swift`

---

## Data Flow

### Card Rendering Flow

```
JSON String
    │
    ▼
┌─────────────┐
│ CardParser  │ Parse JSON → AdaptiveCard model
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ AdaptiveCardView│ Create view hierarchy
└──────┬──────────┘
       │
       ▼
┌─────────────────────┐
│ Element Renderer    │ Match element type → view
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Specific View       │ TextBlockView, ImageView, etc.
│ (e.g., TextBlock)   │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ SwiftUI Layout      │ Render on screen
└─────────────────────┘
```

### Template Expansion Flow

```
Template JSON + Data
    │
    ▼
┌─────────────┐
│TemplateEngine│ Expand ${...} expressions
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ ExpressionParser│ Parse expressions → AST
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ DataContext  │ Resolve property paths
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ ExpressionEvaluator│ Evaluate AST → values
└──────┬──────┘
       │
       ▼
Expanded JSON → CardParser → AdaptiveCardView
```

### Action Flow

```
User Tap
    │
    ▼
┌─────────────┐
│ ActionButton│ Detect tap
└──────┬──────┘
       │
       ▼
┌─────────────┐
│CardViewModel│ Log action, update state
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ActionDelegate│ Notify host app
└─────────────┘
```

### Input Collection Flow

```
User Input
    │
    ▼
┌─────────────┐
│ Input View  │ Update @Binding
└──────┬──────┘
       │
       ▼
┌─────────────┐
│CardViewModel│ Store in inputValues[id]
└──────┬──────┘
       │
       ▼
Action.Submit → Collect all inputs → ActionDelegate
```

---

## Rendering Pipeline

### View Hierarchy Construction

1. **Parse**: JSON → `AdaptiveCard` model
2. **Validate**: Check schema, fallback handling
3. **Transform**: Apply templating if data provided
4. **Build**: Create SwiftUI view tree
5. **Layout**: Apply spacing, alignment, sizing
6. **Render**: Display on screen with accessibility

### Performance Optimizations

- **Lazy Loading**: Lists use `LazyVStack`, carousels use lazy rendering
- **Image Caching**: `URLCache` for remote images
- **Markdown Caching**: `NSCache` for parsed markdown (100 entries)
- **Conditional Rendering**: Skip invisible elements early
- **Minimal Recomposition**: Use `@State` and `@Binding` judiciously
- **Background Parsing**: Heavy parsing on background threads (future enhancement)

### Layout System

```swift
// Spacing applies between elements
VStack(spacing: hostConfig.spacing.default) {
    ForEach(elements) { element in
        renderElement(element)
            .padding(.horizontal, hostConfig.spacing.padding)
    }
}

// Separators between elements
if element.separator {
    Divider()
        .background(hostConfig.separator.lineColor)
        .padding(.vertical, hostConfig.separator.lineThickness)
}
```

---

## Extension Points

### Custom Element Renderers

```swift
// Register custom renderer
ElementRendererRegistry.registerRenderer(for: "MyCustomElement") { element, hostConfig in
    AnyView(MyCustomElementView(element: element))
}
```

### Custom Actions

```swift
// Implement ActionDelegate
class MyActionDelegate: ActionDelegate {
    func handleAction(_ action: CardAction) {
        // Custom action handling
    }
    
    func onExecute(verb: String, data: [String: Any]) {
        // Handle custom verbs
    }
}

// Attach to view
AdaptiveCardView(card: card)
    .environment(\.actionDelegate, myDelegate)
```

### Custom Template Functions

```swift
// Add custom function
TemplateEngine.registerFunction("myFunction") { args in
    // Custom logic
    return result
}
```

### Custom Host Config

```swift
let customConfig = HostConfig(
    spacing: SpacingConfig(small: 4, default: 8, medium: 12, large: 16),
    fontFamily: "CustomFont",
    containerStyles: ContainerStyleConfig(
        default: ContainerStyle(backgroundColor: .white, foregroundColor: .black),
        emphasis: ContainerStyle(backgroundColor: .blue, foregroundColor: .white)
    )
)

AdaptiveCardView(card: card, hostConfig: customConfig)
```

---

## Design Patterns

### Patterns Used

1. **Model-View-ViewModel (MVVM)**
   - Models: ACCore structs
   - Views: SwiftUI views
   - ViewModels: CardViewModel for state management

2. **Registry Pattern**
   - ElementRendererRegistry for dynamic element rendering
   - Allows runtime registration of custom renderers

3. **Delegate Pattern**
   - ActionDelegate for action callbacks
   - Decouples action handling from UI

4. **Builder Pattern**
   - HostConfig builder for configuration
   - Fluent API for setting properties

5. **Strategy Pattern**
   - Different rendering strategies per element type
   - Polymorphic through enum with associated values

6. **Observer Pattern**
   - `@Published` properties in CardViewModel
   - SwiftUI's automatic observation via `@ObservedObject`

7. **Factory Pattern**
   - CardParser creates models from JSON
   - TemplateEngine creates expanded templates

---

## Performance Considerations

### Memory Management

- **Value Types**: Structs prevent retain cycles
- **Weak References**: Parent context references are weak
- **Cache Limits**: NSCache with entry limits
- **Image Disposal**: URLCache automatic cleanup

### Rendering Performance

- **Target**: < 16ms per frame (60 FPS)
- **Lazy Loading**: Lists render only visible items
- **Minimal State**: Reduce `@State` and `@Published` usage
- **View Identity**: Stable `id` for ForEach loops
- **Background Work**: Parse JSON off main thread

### Profiling Tools

- **Instruments**: Time Profiler, Allocations, Leaks
- **SwiftUI Inspector**: View hierarchy debugging
- **Console Logging**: Performance metrics in debug builds

---

## Accessibility Architecture

### VoiceOver Support

Every interactive element includes:
- `.accessibilityLabel()`: What it is
- `.accessibilityHint()`: What it does
- `.accessibilityValue()`: Current state
- `.accessibilityAddTraits()`: Semantic traits

### Dynamic Type

- Font sizes scale with user preferences
- Uses `@ScaledMetric` for automatic scaling
- Minimum sizes preserved for readability

### Minimum Touch Targets

- All interactive elements: 44pt × 44pt minimum
- Applied via `.minimumTouchTarget()` modifier
- Enforced in buttons, inputs, and links

### Color Contrast

- Host config colors respect WCAG AA guidelines
- High contrast mode support via `.environment(\.colorScheme)`
- Semantic colors adapt to light/dark mode

---

## Testing Strategy

### Unit Tests

- **ACCoreTests**: Model parsing, serialization, round-trip tests
- **ACTemplatingTests**: Expression parsing, evaluation, function tests
- **ACRenderingTests**: View snapshot tests (future)
- **ACInputsTests**: Input validation, state management
- **ACMarkdownTests**: Markdown parsing and rendering

### Integration Tests

- End-to-end card rendering from JSON
- Template expansion with real data
- Action dispatch flow
- Input collection flow

### Test Cards

Located in `shared/test-cards/`:
- Simple cards for basic elements
- Complex cards for advanced scenarios
- Edge case cards for error handling
- Performance test cards (large lists, many elements)

### Code Coverage

- Target: 80%+ coverage
- Critical paths: 100% coverage (parsing, rendering)
- UI code: Snapshot testing

---

## Potential Improvements

- Background JSON parsing with Swift actors
- Expression caching in TemplateEngine
- Binary card format for faster parsing
- Custom animation support
- Video playback in Media element
- Offline card caching

---

## Sample Application Architecture

### Overview

The iOS Sample App (`ios/SampleApp/`) demonstrates best practices for integrating the Adaptive Cards SDK in a production SwiftUI application.

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│              ACVisualizer                     │
│                   (@main App)                           │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │    ContentView       │
         │     (TabView)        │
         └──────────┬───────────┘
                    │
        ┌───────────┼───────────┬───────────┐
        │           │           │           │
        ▼           ▼           ▼           ▼
   ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
   │Gallery │  │ Editor │  │ Teams  │  │  More  │
   │  View  │  │  View  │  │  View  │  │  View  │
   └────────┘  └────────┘  └────────┘  └────────┘
        │           │           │           │
        └───────────┴───────────┴───────────┘
                    │
        ┌───────────┴───────────────┐
        │                           │
        ▼                           ▼
   ┌────────────┐          ┌──────────────┐
   │ ACRendering│          │  ACCore      │
   │   Module   │          │  Module      │
   └────────────┘          └──────────────┘
```

### Key Components

#### State Management
- **ActionLogStore**: `ObservableObject` managing action history
- **AppSettings**: `ObservableObject` managing app preferences
- Uses `@EnvironmentObject` for global state sharing

```swift
@StateObject private var actionLog = ActionLogStore()
@StateObject private var settings = AppSettings()

ContentView()
    .environmentObject(actionLog)
    .environmentObject(settings)
```

#### Views

1. **CardGalleryView**
   - Lists all test cards with search/filter
   - Categories: Basic, Inputs, Actions, Containers, Advanced, Teams, Templating
   - Uses `NavigationStack` + `List` for efficient rendering

2. **CardDetailView**
   - Renders selected card
   - Shows JSON payload (toggleable)
   - Displays parse/render metrics
   - Lists recent actions

3. **CardEditorView**
   - Live JSON editor with validation
   - Real-time preview (split-view or tabs)
   - Format/sample loading utilities

4. **TeamsSimulatorView**
   - Teams-style chat UI
   - Message bubbles with cards
   - Pre-built card templates

5. **PerformanceDashboardView**
   - Parse/render metrics
   - Memory usage tracking
   - Recording controls

6. **ActionLogView**
   - Action history with search
   - Detailed action inspection
   - Export functionality

7. **SettingsView**
   - Theme selection
   - Font scale slider
   - Accessibility toggles

### Data Flow

```
User Interaction
     │
     ▼
CardGalleryView (select card)
     │
     ▼
CardDetailView (render card)
     │
     ▼
ACRendering (parse + render)
     │
     ▼
Action Executed
     │
     ▼
ActionLogStore (log action)
     │
     ▼
ActionLogView (display log)
```

### Best Practices Demonstrated

1. **Modular Design**: Clear separation between UI and SDK logic
2. **State Management**: Proper use of `@State`, `@StateObject`, `@EnvironmentObject`
3. **Navigation**: Modern `NavigationStack` with type-safe routing
4. **Performance**: Lazy loading, efficient list rendering
5. **Accessibility**: VoiceOver labels, Dynamic Type support
6. **Testing**: Structured for easy unit/UI testing

### Building the Sample App

See [ios/SampleApp/README.md](SampleApp/README.md) for detailed build instructions.

---

