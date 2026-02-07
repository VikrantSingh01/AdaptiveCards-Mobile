# Android Adaptive Cards SDK - Architecture Documentation

**Version:** 1.0  
**Last Updated:** 2026-02-07  
**Platform:** Android API 26+, Kotlin 1.9+, Jetpack Compose

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

The Android Adaptive Cards SDK is a modular, Jetpack Compose-based framework for rendering Adaptive Cards on Android devices. The architecture emphasizes clean separation of concerns with distinct Gradle modules for parsing, rendering, actions, inputs, templating, and accessibility.

### Core Principles

- **Modularity**: Each concern isolated in its own Gradle module
- **Type Safety**: Kotlin data classes with Kotlinx Serialization
- **Declarative UI**: Pure Jetpack Compose with no View system dependencies
- **Performance**: Lazy loading, caching, and efficient recomposition
- **Accessibility**: TalkBack support built into every composable
- **Testability**: Interface-based design enables comprehensive unit testing

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
│               (Host App / Sample App Activity)               │
└────────────┬────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────┐
│                   ac-rendering Module                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ AdaptiveCard │  │   Element    │  │  Composable  │     │
│  │     View     │──│   Renderer   │──│    Views     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└───────┬──────────────────┬──────────────────┬──────────────┘
        │                  │                  │
        ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  ac-inputs   │  │  ac-actions  │  │ ac-markdown  │
│              │  │              │  │              │
│Input Compose │  │Action Handler│  │  Markdown    │
│& Validation  │  │& Dispatching │  │  Rendering   │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                  │                  │
       └──────────────────┴──────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │  ac-accessibility     │
              │  Accessibility Utils  │
              └───────────┬───────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │      ac-core          │
              │  ┌─────────────────┐  │
              │  │ Models (Data    │  │
              │  │      Classes)   │  │
              │  ├─────────────────┤  │
              │  │  Card Parser    │  │
              │  ├─────────────────┤  │
              │  │   HostConfig    │  │
              │  └─────────────────┘  │
              └───────────┬───────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │   ac-templating       │
              │  ┌─────────────────┐  │
              │  │ Template Engine │  │
              │  ├─────────────────┤  │
              │  │Expression Parser│  │
              │  ├─────────────────┤  │
              │  │   60 Functions  │  │
              │  └─────────────────┘  │
              └───────────────────────┘

              ┌───────────────────────┐
              │  ac-host-config       │
              │  Teams Preset Config  │
              └───────────────────────┘
```

---

## Module Architecture

### Module Dependency Graph

```
ac-rendering
  ├── ac-core
  ├── ac-inputs
  │   ├── ac-core
  │   └── ac-accessibility
  ├── ac-actions
  │   ├── ac-core
  │   └── ac-accessibility
  └── ac-accessibility
      └── ac-core

ac-markdown
  └── ac-core

ac-templating
  └── ac-core

ac-host-config
  └── ac-core
```

### Module Responsibilities

| Module | Responsibility | Public API Surface |
|--------|---------------|-------------------|
| **ac-core** | Data models, parsing, base configuration | Models, AdaptiveCard object, HostConfig |
| **ac-accessibility** | TalkBack support, font scaling, accessibility utilities | Semantics modifiers, helpers |
| **ac-rendering** | Compose views for all card elements | AdaptiveCardView, element composables |
| **ac-inputs** | Input elements (text, choice, date, etc.) | Input composables, validation |
| **ac-actions** | Action handling (submit, open URL, etc.) | Action composables, callbacks |
| **ac-templating** | Template expansion with expressions | TemplateEngine, functions |
| **ac-markdown** | Markdown parsing and rendering | MarkdownParser, MarkdownText |
| **ac-host-config** | Pre-configured host configs (Teams, etc.) | Preset configurations |

---

## Module Details

### ac-core

**Purpose:** Foundation module containing all data models, JSON parsing, and host configuration.

**Key Components:**

```kotlin
// Core Models
@Serializable
data class AdaptiveCard(
    val type: String,
    val version: String,
    val body: List<CardElement>,
    val actions: List<CardAction>? = null
)

@Serializable
sealed class CardElement {
    @Serializable @SerialName("TextBlock")
    data class TextBlock(...) : CardElement()
    
    @Serializable @SerialName("Image")
    data class Image(...) : CardElement()
    
    @Serializable @SerialName("Container")
    data class Container(...) : CardElement()
    
    @Serializable @SerialName("List")
    data class ListElement(...) : CardElement()
    // ... more elements
}

// Parser
object AdaptiveCard {
    fun parse(json: String): AdaptiveCard {
        return Json.decodeFromString(json)
    }
}

// Host Configuration
@Serializable
data class HostConfig(
    val spacing: SpacingConfig = SpacingConfig(),
    val fontFamily: String? = null,
    val fontSizes: FontSizeConfig = FontSizeConfig(),
    val fontWeights: FontWeightConfig = FontWeightConfig(),
    val containerStyles: ContainerStyleConfig = ContainerStyleConfig()
)
```

**Design Decisions:**
- All models are `data class` for value semantics and immutability
- Kotlinx Serialization for JSON with `@Serializable` annotation
- Sealed classes for type-safe polymorphism
- Default values for optional properties
- `@SerialName` for JSON property name mapping

**File Structure:**
```
ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/
  ├── models/
  │   ├── AdaptiveCard.kt
  │   ├── CardElement.kt
  │   ├── CardAction.kt
  │   ├── CardInput.kt
  │   ├── ContainerTypes.kt
  │   ├── AdvancedElements.kt
  │   ├── Enums.kt
  │   └── Metadata.kt
  ├── parser/
  │   └── CardParser.kt
  └── config/
      └── HostConfig.kt
```

---

### ac-accessibility

**Purpose:** Centralized accessibility utilities and Compose modifiers for TalkBack support.

**Key Components:**

```kotlin
// Accessibility Extensions
fun Modifier.cardAccessibility(
    label: String?,
    role: Role? = null,
    stateDescription: String? = null
): Modifier = this.semantics {
    contentDescription = label ?: ""
    role?.let { this.role = it }
    stateDescription?.let { this.stateDescription = it }
}

// Minimum Touch Target
fun Modifier.minimumTouchTarget(
    minSize: Dp = 44.dp
): Modifier = this.sizeIn(minWidth = minSize, minHeight = minSize)

// Font Scaling Support
object FontScaling {
    fun scaleFontSize(baseSize: TextUnit, configuration: Configuration): TextUnit {
        val fontScale = configuration.fontScale
        return baseSize * fontScale
    }
}
```

**Design Decisions:**
- Extension functions for consistent accessibility patterns
- Minimum 44dp touch targets enforced via modifiers
- Font scaling support using `LocalConfiguration`
- TalkBack announcements via `LiveRegion`

**File Structure:**
```
ac-accessibility/src/main/kotlin/com/microsoft/adaptivecards/accessibility/
  ├── AccessibilityExtensions.kt
  └── FontScaling.kt
```

---

### ac-rendering

**Purpose:** Jetpack Compose views for rendering all Adaptive Card elements.

**Key Components:**

```kotlin
// Main Composable
@Composable
fun AdaptiveCardView(
    card: AdaptiveCard,
    hostConfig: HostConfig = HostConfig.default(),
    modifier: Modifier = Modifier,
    onAction: (CardAction) -> Unit = {}
) {
    val viewModel = remember { CardViewModel() }
    
    Column(modifier = modifier) {
        card.body.forEach { element ->
            RenderElement(element, hostConfig, viewModel)
        }
    }
}

// View Model
class CardViewModel {
    val actionLog = mutableStateListOf<ActionEntry>()
    val inputValues = mutableStateMapOf<String, Any?>()
}

// Composition Locals
val LocalHostConfig = compositionLocalOf { HostConfig.default() }
val LocalCardViewModel = compositionLocalOf<CardViewModel> { error("No CardViewModel") }
```

**Element Composables:**
- TextBlockView.kt - Text rendering with markdown support
- ImageView.kt - Image loading with Coil
- ContainerView.kt - Container with styling
- ColumnSetView.kt - Multi-column layouts
- FactSetView.kt - Key-value pairs
- ImageSetView.kt - Image grids
- ActionSetView.kt - Button groups
- ListView.kt - Scrollable lists (NEW in Phase 2B)
- MediaAndTableViews.kt - Media and tables
- RichTextBlockView.kt - Rich text rendering
- AccordionView.kt - Expandable sections
- CarouselView.kt - Swipeable content
- CodeBlockView.kt - Code syntax display
- RatingDisplayView.kt - Star ratings
- ProgressIndicatorViews.kt - Progress bars and spinners
- TabSetView.kt - Tabbed navigation

**Design Decisions:**
- Composables are stateless and data-driven
- `CompositionLocalProvider` for HostConfig and ViewModel propagation
- `remember` for view state management
- Lazy composables (LazyColumn, LazyRow) for performance
- Conditional rendering based on `isVisible`

**File Structure:**
```
ac-rendering/src/main/kotlin/com/microsoft/adaptivecards/rendering/
  ├── composables/
  │   ├── AdaptiveCardView.kt
  │   └── [Element]View.kt files
  ├── CardViewModel.kt
  └── CompositionLocals.kt
```

---

### ac-inputs

**Purpose:** Input elements with validation and data collection.

**Key Components:**

```kotlin
// Input Composables
@Composable
fun TextInputView(input: TextInput, ...)

@Composable
fun NumberInputView(input: NumberInput, ...)

@Composable
fun DateInputView(input: DateInput, ...)

@Composable
fun TimeInputView(input: TimeInput, ...)

@Composable
fun ToggleInputView(input: ToggleInput, ...)

@Composable
fun ChoiceSetInputView(input: ChoiceSetInput, ...)

@Composable
fun RatingInputView(input: RatingInput, ...)
```

**Input Types Supported:**
- Input.Text - Single/multi-line text with validation
- Input.Number - Numeric input with min/max
- Input.Date - Date picker dialog
- Input.Time - Time picker dialog
- Input.Toggle - Boolean switch
- Input.ChoiceSet - Single/multi-select with compact/expanded/filtered styles
- Input.Rating - Star rating (1-10 scale)

**Design Decisions:**
- State hoisting with `onValueChange` callbacks
- Validation rules enforced (required, min/max, regex)
- Error states with visual feedback via OutlinedTextField
- Accessibility via semantics modifiers

**File Structure:**
```
ac-inputs/src/main/kotlin/com/microsoft/adaptivecards/inputs/
  ├── TextInputView.kt
  ├── NumberInputView.kt
  ├── DateInputView.kt
  ├── TimeInputView.kt
  ├── ToggleInputView.kt
  ├── ChoiceSetInputView.kt
  ├── RatingInputView.kt
  └── InputValidation.kt
```

---

### ac-actions

**Purpose:** Action handling and dispatching for user interactions.

**Key Components:**

```kotlin
// Action Composables
@Composable
fun ActionButton(
    action: CardAction,
    modifier: Modifier = Modifier,
    onClick: (CardAction) -> Unit
)

@Composable
fun ShowCardActionView(
    action: ShowCardAction,
    ...
)

// Action Callback
typealias OnActionCallback = (CardAction) -> Unit

// Action Types
sealed class CardAction {
    data class Submit(val data: Map<String, Any?>? = null) : CardAction()
    data class OpenUrl(val url: String) : CardAction()
    data class ShowCard(val card: AdaptiveCard) : CardAction()
    data class Execute(val verb: String, val data: Map<String, Any?>? = null) : CardAction()
    data class ToggleVisibility(val targetElements: List<String>) : CardAction()
}
```

**Action Types Supported:**
- Action.Submit - Submit input values
- Action.OpenUrl - Open URL in browser (Custom Chrome Tab)
- Action.ShowCard - Expand card inline
- Action.Execute - Execute custom action
- Action.ToggleVisibility - Show/hide elements

**Design Decisions:**
- Callback pattern for action handling
- Action logging in CardViewModel
- Async URL opening via Intent
- ShowCard state managed in ViewModel with mutableState

**File Structure:**
```
ac-actions/src/main/kotlin/com/microsoft/adaptivecards/actions/
  ├── ActionButton.kt
  ├── ShowCardActionView.kt
  └── ActionCallbacks.kt
```

---

### ac-templating

**Purpose:** Template expansion engine with expression evaluation.

**Key Components:**

```kotlin
// Template Engine
class TemplateEngine {
    fun expand(template: String, data: Map<String, Any?>): String
    fun expand(template: Map<String, Any?>, data: Map<String, Any?>): Map<String, Any?>
}

// Expression Parser
class ExpressionParser {
    fun parse(expression: String): Expression
}

sealed class Expression {
    data class Literal(val value: Any?) : Expression()
    data class PropertyAccess(val path: String) : Expression()
    data class FunctionCall(val name: String, val arguments: List<Expression>) : Expression()
    data class BinaryOp(val operator: String, val left: Expression, val right: Expression) : Expression()
    data class UnaryOp(val operator: String, val operand: Expression) : Expression()
    data class Ternary(val condition: Expression, val trueValue: Expression, val falseValue: Expression) : Expression()
}

// Expression Evaluator
class ExpressionEvaluator(private val context: DataContext) {
    fun evaluate(expression: Expression): Any?
}

// Data Context
class DataContext(
    val data: Any?,
    val root: Any? = null,
    val index: Int? = null,
    val parent: DataContext? = null
) {
    fun resolve(path: String): Any?
    fun createChild(data: Any?, index: Int? = null): DataContext
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

| Category | Functions |
|----------|-----------|
| **String** | toLower, toUpper, substring, indexOf, length, replace, split, join, trim, startsWith, endsWith, contains, format |
| **Date** | formatDateTime, addDays, addHours, getYear, getMonth, getDay, dateDiff, utcNow |
| **Collection** | count, first, last, filter, sort, flatten, union, intersection |
| **Logic** | if, equals, not, and, or, greaterThan, lessThan, exists, empty, isMatch |
| **Math** | add, sub, mul, div, mod, min, max, round, floor, ceil, abs |

**Design Decisions:**
- AST-based parsing for correctness
- Type coercion for JavaScript-like behavior
- LruCache for parsed expressions (100 entries)
- Null-safe evaluation
- Descriptive error messages with context

**File Structure:**
```
ac-templating/src/main/kotlin/com/microsoft/adaptivecards/templating/
  ├── TemplateEngine.kt
  ├── ExpressionParser.kt
  ├── ExpressionEvaluator.kt
  ├── DataContext.kt
  └── functions/
      ├── StringFunctions.kt
      ├── DateFunctions.kt
      ├── CollectionFunctions.kt
      ├── LogicFunctions.kt
      └── MathFunctions.kt
```

---

### ac-markdown

**Purpose:** Markdown parsing and rendering for TextBlock elements.

**Key Components:**

```kotlin
// Markdown Parser
class MarkdownParser {
    fun parse(markdown: String): List<MarkdownNode>
}

sealed class MarkdownNode {
    data class Text(val content: String) : MarkdownNode()
    data class Bold(val text: String) : MarkdownNode()
    data class Italic(val text: String) : MarkdownNode()
    data class Code(val code: String) : MarkdownNode()
    data class Link(val text: String, val url: String) : MarkdownNode()
    data class Header(val level: Int, val text: String) : MarkdownNode()
    data class BulletList(val items: List<String>) : MarkdownNode()
    data class OrderedList(val items: List<String>) : MarkdownNode()
}

// Markdown Renderer
class MarkdownRenderer {
    fun render(nodes: List<MarkdownNode>): AnnotatedString
}

// Composable
@Composable
fun MarkdownText(
    markdown: String,
    modifier: Modifier = Modifier,
    style: TextStyle = LocalTextStyle.current
)
```

**Supported Markdown:**
- Bold: `**text**`
- Italic: `*text*`
- Inline code: `` `code` ``
- Links: `[text](url)` (clickable with UriHandler)
- Headers: `#` (H1), `##` (H2), `###` (H3)
- Bullet lists: `- item`
- Numbered lists: `1. item`

**Design Decisions:**
- LruCache for parsed markdown (100 entries, 1MB max size)
- AnnotatedString for proper Compose integration
- Smart detection: Only parse if markdown syntax present
- Graceful degradation for malformed markdown
- Link clickability via `UriHandler` and `ClickableText`

**File Structure:**
```
ac-markdown/src/main/kotlin/com/microsoft/adaptivecards/markdown/
  ├── MarkdownParser.kt
  ├── MarkdownRenderer.kt
  └── MarkdownText.kt
```

---

### ac-host-config

**Purpose:** Pre-configured host configurations for common scenarios.

**Key Components:**

```kotlin
object HostConfigPresets {
    fun teams(): HostConfig = HostConfig(
        spacing = SpacingConfig(
            small = 4,
            default = 8,
            medium = 12,
            large = 16,
            extraLarge = 24,
            padding = 16
        ),
        fontFamily = "Segoe UI",
        fontSizes = FontSizeConfig(
            small = 12.sp,
            default = 14.sp,
            medium = 16.sp,
            large = 20.sp,
            extraLarge = 24.sp
        )
        // ... Teams-specific styling
    )
    
    fun default(): HostConfig = HostConfig()
}
```

**File Structure:**
```
ac-host-config/src/main/kotlin/com/microsoft/adaptivecards/hostconfig/
  └── HostConfigPresets.kt
```

---

## Data Flow

### Card Rendering Flow

```
JSON String
    │
    ▼
┌─────────────┐
│AdaptiveCard │ Parse JSON → AdaptiveCard model
│   .parse()  │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│AdaptiveCardView │ Create composable hierarchy
└──────┬──────────┘
       │
       ▼
┌─────────────────────┐
│ when (element) {    │ Match element type → composable
│   TextBlock → ...   │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Specific Composable │ TextBlockView, ImageView, etc.
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Compose Layout      │ Render on screen
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
│ExpressionParser│ Parse expressions → AST
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ DataContext  │ Resolve property paths
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ExpressionEvaluator│ Evaluate AST → values
└──────┬──────┘
       │
       ▼
Expanded JSON → AdaptiveCard.parse() → AdaptiveCardView
```

### Action Flow

```
User Tap
    │
    ▼
┌─────────────┐
│ActionButton │ Detect click
└──────┬──────┘
       │
       ▼
┌─────────────┐
│CardViewModel│ Log action, update state
└──────┬──────┘
       │
       ▼
┌─────────────┐
│onAction     │ Notify host activity
│ callback    │
└─────────────┘
```

### Input Collection Flow

```
User Input
    │
    ▼
┌─────────────┐
│ Input View  │ Call onValueChange
└──────┬──────┘
       │
       ▼
┌─────────────┐
│CardViewModel│ Store in inputValues[id]
└──────┬──────┘
       │
       ▼
Action.Submit → Collect all inputs → onAction callback
```

---

## Rendering Pipeline

### Composable Hierarchy Construction

1. **Parse**: JSON → `AdaptiveCard` data class
2. **Validate**: Check schema, fallback handling
3. **Transform**: Apply templating if data provided
4. **Compose**: Create composable tree
5. **Layout**: Apply spacing, alignment, sizing via Modifiers
6. **Recompose**: Display on screen with accessibility

### Performance Optimizations

- **Lazy Loading**: LazyColumn/LazyRow for lists and carousels
- **Image Loading**: Coil library with disk/memory caching
- **Markdown Caching**: LruCache for parsed markdown (100 entries)
- **Conditional Composition**: Skip invisible elements via `if (element.isVisible != false)`
- **Minimal Recomposition**: Use `remember`, `derivedStateOf`, stable parameters
- **Background Parsing**: Coroutines for heavy parsing (future enhancement)

### Layout System

```kotlin
Column(
    modifier = Modifier.padding(hostConfig.spacing.padding.dp),
    verticalArrangement = Arrangement.spacedBy(hostConfig.spacing.default.dp)
) {
    card.body.forEach { element ->
        if (element.isVisible != false) {
            RenderElement(element, hostConfig)
            
            if (element.separator == true) {
                HorizontalDivider(
                    thickness = hostConfig.separator.lineThickness.dp,
                    color = hostConfig.separator.lineColor
                )
            }
        }
    }
}
```

---

## Extension Points

### Custom Element Renderers

```kotlin
// Register custom renderer
@Composable
fun CustomAdaptiveCardView(card: AdaptiveCard) {
    CompositionLocalProvider(
        LocalCustomRenderer provides { element ->
            when (element) {
                is MyCustomElement -> MyCustomElementView(element)
                else -> DefaultRenderElement(element)
            }
        }
    ) {
        AdaptiveCardView(card)
    }
}
```

### Custom Actions

```kotlin
// Implement action callback
val onAction: (CardAction) -> Unit = { action ->
    when (action) {
        is CardAction.Execute -> {
            if (action.verb == "myCustomAction") {
                // Handle custom action
            }
        }
        else -> handleDefaultAction(action)
    }
}

AdaptiveCardView(
    card = card,
    onAction = onAction
)
```

### Custom Template Functions

```kotlin
// Add custom function
TemplateEngine.registerFunction("myFunction") { args ->
    // Custom logic
    result
}
```

### Custom Host Config

```kotlin
val customConfig = HostConfig(
    spacing = SpacingConfig(small = 4, default = 8, medium = 12, large = 16),
    fontFamily = "CustomFont",
    containerStyles = ContainerStyleConfig(
        default = ContainerStyle(
            backgroundColor = Color.White,
            foregroundColor = Color.Black
        ),
        emphasis = ContainerStyle(
            backgroundColor = Color.Blue,
            foregroundColor = Color.White
        )
    )
)

CompositionLocalProvider(LocalHostConfig provides customConfig) {
    AdaptiveCardView(card)
}
```

---

## Design Patterns

### Patterns Used

1. **Model-View-ViewModel (MVVM)**
   - Models: ac-core data classes
   - Views: Jetpack Compose composables
   - ViewModels: CardViewModel for state management

2. **Composition Local Pattern**
   - LocalHostConfig for configuration propagation
   - LocalCardViewModel for state access
   - Allows dependency injection down the tree

3. **Callback Pattern**
   - onAction for action callbacks
   - onValueChange for input updates
   - Decouples UI from business logic

4. **Builder Pattern**
   - HostConfig with default values
   - Fluent API via copy() for modifications

5. **Strategy Pattern**
   - Different rendering strategies per element type
   - Polymorphic through sealed classes

6. **Observer Pattern**
   - mutableStateOf for reactive state
   - StateFlow for async data streams

7. **Factory Pattern**
   - AdaptiveCard.parse() creates models from JSON
   - TemplateEngine creates expanded templates

---

## Performance Considerations

### Memory Management

- **Immutable Data**: Data classes prevent shared mutable state issues
- **Weak References**: Not needed in Kotlin (GC handles it)
- **Cache Limits**: LruCache with size limits (100 entries, 1MB)
- **Image Disposal**: Coil automatic cleanup

### Rendering Performance

- **Target**: < 16ms per frame (60 FPS)
- **Lazy Composition**: LazyColumn renders only visible items
- **Minimal State**: Reduce mutableStateOf usage
- **Key Stability**: Stable keys in lists for recomposition optimization
- **Background Work**: Use coroutines for heavy operations

### Profiling Tools

- **Android Profiler**: CPU, Memory, Network profiling
- **Layout Inspector**: Compose hierarchy debugging
- **Logcat**: Performance metrics in debug builds
- **Macrobenchmark**: App startup and jank metrics

---

## Accessibility Architecture

### TalkBack Support

Every interactive composable includes:
- `Modifier.semantics { contentDescription }`: What it is
- `role`: Semantic role (Button, Checkbox, etc.)
- `stateDescription`: Current state
- `onClick`: Action label

### Font Scaling

- Font sizes scale with `LocalConfiguration.current.fontScale`
- Uses Material3 TextStyle with sp units
- Minimum sizes preserved for readability

### Minimum Touch Targets

- All interactive elements: 44dp × 44dp minimum
- Applied via `.minimumTouchTarget()` modifier
- Enforced in buttons, inputs, and links

### Color Contrast

- Host config colors respect WCAG AA guidelines
- Material3 dynamic color system for light/dark mode
- `isSystemInDarkTheme()` for theme detection

---

## Testing Strategy

### Unit Tests

- **ac-core tests**: Model parsing, serialization, round-trip tests
- **ac-templating tests**: Expression parsing, evaluation, function tests
- **ac-rendering tests**: Composable screenshot tests (future)
- **ac-inputs tests**: Input validation, state management
- **ac-markdown tests**: Markdown parsing and rendering

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
- UI code: Screenshot testing with Paparazzi

---

## Future Enhancements

### Planned Additions

- **ac-charts**: Chart rendering module (Phase 2E)
- **ac-fluent-ui**: Fluent Design System theming (Phase 2F)
- **ac-copilot-extensions**: Copilot-specific features (Phase 3C)
- **ac-teams**: Teams integration module (Phase 3D)

### Performance Improvements

- Background JSON parsing with coroutines
- Expression caching in TemplateEngine
- Composable skipping optimization
- Binary card format for faster parsing

### Additional Features

- Custom animation support
- Video playback in Media element
- PDF rendering
- Offline card caching
- Card versioning and migration

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-07 | Initial architecture document with Phase 1 & 2A-2B complete |

---

**Document Maintained By:** Android SDK Team  
**Contact:** See CONTRIBUTING.md for contribution guidelines

---

## Sample Application Architecture

### Overview

The Android Sample App (`android/sample-app/`) demonstrates best practices for integrating the Adaptive Cards SDK in a production Jetpack Compose application.

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│               MainActivity                              │
│           (ComponentActivity)                           │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │    MainScreen        │
         │  (Scaffold+NavHost)  │
         └──────────┬───────────┘
                    │
        ┌───────────┼───────────┬───────────┐
        │           │           │           │
        ▼           ▼           ▼           ▼
   ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
   │Gallery │  │ Editor │  │ Teams  │  │  More  │
   │ Screen │  │ Screen │  │ Screen │  │ Screen │
   └────────┘  └────────┘  └────────┘  └────────┘
        │           │           │           │
        └───────────┴───────────┴───────────┘
                    │
        ┌───────────┴───────────────┐
        │                           │
        ▼                           ▼
   ┌─────────────┐         ┌──────────────┐
   │ ac-rendering│         │   ac-core    │
   │    Module   │         │   Module     │
   └─────────────┘         └──────────────┘
```

### Key Components

#### State Management
- **ActionLogState**: Mutable state managing action history
- **SettingsState**: Mutable state managing app preferences
- Uses Compose `remember` and `mutableStateOf` for reactivity

```kotlin
val actionLogState = remember { ActionLogState() }
val settingsState = remember { SettingsState() }
```

#### Screens

1. **CardGalleryScreen**
   - LazyColumn of test cards
   - Search/filter by category
   - Material Design 3 Cards

2. **CardDetailScreen**
   - Card preview
   - JSON toggle
   - Parse/render metrics
   - Action history

3. **CardEditorScreen**
   - JSON editor with validation
   - Tab-based navigation (Editor/Preview)
   - Format/sample utilities

4. **TeamsSimulatorScreen**
   - Material chat UI
   - Message bubbles with cards
   - Pre-built templates

5. **PerformanceDashboardScreen**
   - Parse/render metrics
   - Memory tracking
   - Recording controls

6. **ActionLogScreen**
   - LazyColumn of actions
   - Search/filter
   - Detail dialog

7. **SettingsScreen**
   - Material preferences UI
   - Theme/font settings
   - Accessibility options

### Data Flow

```
User Interaction
     │
     ▼
CardGalleryScreen (select card)
     │
     ▼
CardDetailScreen (render card)
     │
     ▼
ac-rendering (parse + render)
     │
     ▼
Action Executed
     │
     ▼
ActionLogState (log action)
     │
     ▼
ActionLogScreen (display log)
```

### Best Practices Demonstrated

1. **Compose Architecture**: Modern declarative UI patterns
2. **State Management**: `remember`, `mutableStateOf`, state hoisting
3. **Navigation**: Navigation Compose with type-safe routes
4. **Material Design 3**: Latest design system components
5. **Performance**: LazyColumn, efficient recomposition
6. **Accessibility**: Semantic properties, TalkBack support
7. **Testing**: Structured for Compose testing

### Module Structure

```
sample-app/
├── build.gradle.kts              # Dependencies
├── src/main/
│   ├── kotlin/.../sample/
│   │   ├── MainActivity.kt       # Entry point
│   │   ├── CardGalleryScreen.kt
│   │   ├── CardDetailScreen.kt
│   │   ├── CardEditorScreen.kt
│   │   ├── TeamsSimulatorScreen.kt
│   │   ├── ActionLogScreen.kt
│   │   ├── SettingsScreen.kt
│   │   ├── PerformanceDashboardScreen.kt
│   │   └── ui/theme/Theme.kt
│   └── assets/test-cards/        # Test card JSON files
└── README.md
```

### Building the Sample App

See [android/sample-app/README.md](sample-app/README.md) for detailed build instructions.

---

**Document Version**: 1.0.1  
**Last Updated**: 2024-02-07  
**Next Review**: 2024-03-07
