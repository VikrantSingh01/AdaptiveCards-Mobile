# Cross-Platform Naming Conventions

This document outlines the naming conventions used in the Adaptive Cards Mobile SDK to ensure consistency between iOS (SwiftUI) and Android (Jetpack Compose) implementations.

## Design Philosophy

Both platforms follow **modern declarative UI patterns**:
- iOS: SwiftUI
- Android: Jetpack Compose

The naming conventions prioritize:
1. Platform idioms (Swift for iOS, Kotlin for Android)
2. Cross-platform conceptual alignment
3. Modern architecture patterns (MVVM)

## Module Structure Alignment

### iOS (Swift Package)
```
AdaptiveCards-iOS/
├── Sources/
│   ├── AdaptiveCardsCore/       # Models & Parsing
│   ├── AdaptiveCardsUI/         # SwiftUI Views
│   ├── AdaptiveCardsInputs/     # Input Controls
│   ├── AdaptiveCardsActions/    # Action Handlers
│   └── AdaptiveCardsHostConfig/ # Theme & Config
```

### Android (Gradle Modules)
```
android/
├── ac-core/                      # Models & Parsing
├── ac-rendering/                 # Compose UI
├── ac-inputs/                    # Input Controls
├── ac-actions/                   # Action Handlers
└── ac-host-config/              # Theme & Config
```

**Alignment**: Module names map 1:1 conceptually, with platform naming (Swift uses `AdaptiveCards` prefix, Android uses `ac-` prefix per Gradle conventions).

## Core Model Naming

### Shared Conventions
Both platforms use the same model names from Adaptive Cards schema:

| Concept | iOS (Swift) | Android (Kotlin) |
|---------|-------------|------------------|
| Root card | `AdaptiveCard` | `AdaptiveCard` |
| Text element | `TextBlock` | `TextBlock` |
| Image element | `Image` | `Image` |
| Container | `Container` | `Container` |
| Actions | `ActionSubmit`, `ActionOpenUrl` | `ActionSubmit`, `ActionOpenUrl` |
| Inputs | `InputText`, `InputNumber` | `InputText`, `InputNumber` |

**Alignment**: ✅ Identical naming for all model classes

## View/Composable Naming

### iOS (SwiftUI)
```swift
// Views follow SwiftUI naming with 'View' suffix
struct AdaptiveCardView: View
struct TextBlockView: View
struct ImageView: View
struct ContainerView: View
```

### Android (Compose)
```kotlin
// Composables follow Compose naming with 'View' suffix
@Composable
fun AdaptiveCardView()
@Composable
fun TextBlockView()
@Composable
fun ImageView()
@Composable
fun ContainerView()
```

**Alignment**: ✅ Both use `View` suffix for UI components

## State Management

### iOS (SwiftUI)
```swift
// ObservableObject with @Published properties
class CardViewModel: ObservableObject {
    @Published var card: AdaptiveCard?
    @Published var inputValues: [String: Any]
    @Published var visibilityState: [String: Bool]
}
```

### Android (Compose)
```kotlin
// ViewModel with StateFlow
class CardViewModel : ViewModel() {
    val card: StateFlow<AdaptiveCard?>
    val inputValues: StateFlow<Map<String, Any>>
    val visibilityState: StateFlow<Map<String, Boolean>>
}
```

**Alignment**: ✅ Both use `ViewModel` class with reactive state

## Protocol/Interface Naming

### iOS (SwiftUI)
```swift
// Protocols use descriptive names
protocol ActionHandler {
    func onSubmit(data: [String: Any])
    func onOpenUrl(url: String)
    func onExecute(verb: String, data: [String: Any])
}

protocol ActionDelegate {
    // Host app integration
}
```

### Android (Compose)
```kotlin
// Interfaces use descriptive names
interface ActionHandler {
    fun onSubmit(data: Map<String, Any>)
    fun onOpenUrl(url: String)
    fun onExecute(verb: String, data: Map<String, Any>)
}

interface ActionDelegate {
    // Host app integration
}
```

**Alignment**: ✅ Identical interface names and method signatures (adjusted for language syntax)

## Modifier/Extension Naming

### iOS (SwiftUI)
```swift
// View modifiers
extension View {
    func adaptiveSpacing(_ spacing: Spacing?) -> some View
    func containerStyle(_ style: ContainerStyle?) -> some View
    func selectAction(_ action: CardAction?) -> some View
}
```

### Android (Compose)
```kotlin
// Modifier extensions
fun Modifier.adaptiveSpacing(spacing: Spacing?): Modifier
fun Modifier.containerStyle(style: ContainerStyle?): Modifier
fun Modifier.selectAction(action: CardAction?): Modifier
```

**Alignment**: ✅ Same modifier names with platform-appropriate syntax

## Configuration/HostConfig

### iOS (SwiftUI)
```swift
// Environment values
struct HostConfigKey: EnvironmentKey {
    static let defaultValue: HostConfig = .default
}

extension EnvironmentValues {
    var hostConfig: HostConfig
}

// Theme
struct TeamsTheme: View {
    var body: some View {
        content
            .environment(\.hostConfig, TeamsHostConfig.create())
    }
}
```

### Android (Compose)
```kotlin
// CompositionLocal
val LocalHostConfig = staticCompositionLocalOf<HostConfig> {
    HostConfigParser.default()
}

// Theme
@Composable
fun TeamsTheme(content: @Composable () -> Unit) {
    CompositionLocalProvider(LocalHostConfig provides TeamsHostConfig.create()) {
        content()
    }
}
```

**Alignment**: ✅ Both use environment/composition-local pattern with same naming

## Validation & Input Handling

### iOS (SwiftUI)
```swift
// Validator utility
struct InputValidator {
    static func validateText(value: String, isRequired: Bool) -> String?
    static func validateNumber(value: Double?, min: Double?, max: Double?) -> String?
}

// Validation state
class ValidationState: ObservableObject {
    @Published var errors: [String: String] = [:]
}
```

### Android (Compose)
```kotlin
// Validator object
object InputValidator {
    fun validateText(value: String, isRequired: Boolean): String?
    fun validateNumber(value: Double?, min: Double?, max: Double?): String?
}

// Validation state
class ValidationState {
    val errors: StateFlow<Map<String, String>>
}
```

**Alignment**: ✅ Same class names and method signatures

## Registry Pattern

### iOS (SwiftUI)
```swift
// Custom renderer registration
class ElementRendererRegistry {
    func register(_ type: String, renderer: @escaping (CardElement) -> AnyView)
    func getRenderer(for type: String) -> ((CardElement) -> AnyView)?
}

// Global registry
ElementRendererRegistry.shared.register("CustomType") { element in
    CustomElementView(element: element)
}
```

### Android (Compose)
```kotlin
// Custom renderer registration
class ElementRendererRegistry {
    fun register(type: String, renderer: @Composable (CardElement, Modifier) -> Unit)
    fun getRenderer(type: String): ElementRenderer?
}

// Global registry
GlobalElementRendererRegistry.register("CustomType") { element, modifier ->
    CustomElementView(element, modifier)
}
```

**Alignment**: ✅ Same registry pattern and method names

## Naming Differences (Platform-Specific)

| Concept | iOS | Android | Reason |
|---------|-----|---------|--------|
| Package/Module prefix | `AdaptiveCards` | `com.microsoft.adaptivecards` | Platform convention |
| File extensions | `.swift` | `.kt` | Language |
| View protocol | `: View` | `@Composable` | Framework |
| State wrapper | `@Published`, `@State` | `StateFlow`, `MutableStateFlow` | Framework |
| Async image | `AsyncImage` | `AsyncImage` (Coil) | ✅ Same name, different libs |

## Code Example Comparison

### Card Rendering

**iOS (SwiftUI):**
```swift
struct ContentView: View {
    let cardJson: String
    
    var body: some View {
        TeamsTheme {
            AdaptiveCardView(
                cardJson: cardJson,
                actionHandler: MyActionHandler()
            )
        }
    }
}
```

**Android (Compose):**
```kotlin
@Composable
fun ContentView(cardJson: String) {
    TeamsTheme {
        AdaptiveCardView(
            cardJson = cardJson,
            actionHandler = MyActionHandler()
        )
    }
}
```

**Alignment**: ✅ Nearly identical API surface

## Summary

The naming conventions prioritize:
1. ✅ **Identical model names** (AdaptiveCard, TextBlock, etc.)
2. ✅ **Identical view names** (AdaptiveCardView, TextBlockView, etc.)
3. ✅ **Identical interface names** (ActionHandler, ActionDelegate, etc.)
4. ✅ **Identical method names** (onSubmit, validateText, etc.)
5. ✅ **Platform idioms** where necessary (StateFlow vs @Published)

This ensures developers can easily switch between platforms while maintaining conceptual consistency.
