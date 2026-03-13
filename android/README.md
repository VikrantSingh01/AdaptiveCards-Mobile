# Adaptive Cards Android SDK

Jetpack Compose rendering library for [Adaptive Cards](https://adaptivecards.io/) v1.6, designed for Microsoft Teams mobile integration.

> This SDK maintains strict feature parity with its [iOS SwiftUI counterpart](../ios/README.md). See [NAMING_CONVENTIONS.md](NAMING_CONVENTIONS.md) for cross-platform alignment details.

## Installation

Add to your `build.gradle.kts`:

```kotlin
dependencies {
    implementation(project(":ac-core"))
    implementation(project(":ac-rendering"))
    implementation(project(":ac-inputs"))
    implementation(project(":ac-actions"))
    implementation(project(":ac-host-config"))
    implementation(project(":ac-accessibility"))
}
```

## Quick Start

```kotlin
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import com.microsoft.adaptivecards.hostconfig.TeamsTheme
import com.microsoft.adaptivecards.rendering.viewmodel.ActionHandler

@Composable
fun MyScreen() {
    val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Hello, Adaptive Cards!",
                    "size": "large",
                    "weight": "bolder"
                }
            ]
        }
    """.trimIndent()

    TeamsTheme {
        AdaptiveCardView(
            cardJson = cardJson,
            actionHandler = MyActionHandler()
        )
    }
}

class MyActionHandler : ActionHandler {
    override fun onSubmit(data: Map<String, Any>) { println("Submit: $data") }
    override fun onOpenUrl(url: String) { /* Open URL */ }
    override fun onExecute(verb: String, data: Map<String, Any>) { println("Execute $verb: $data") }
    override fun onShowCard(cardAction: CardAction) { /* Handle show card */ }
    override fun onToggleVisibility(targetElementIds: List<String>) { /* Toggle visibility */ }
}
```

## Modules

| Module | Purpose |
|--------|---------|
| **ac-core** | Card parsing, models, host configuration, schema validation |
| **ac-rendering** | Compose composables for all card elements |
| **ac-inputs** | Input controls with validation |
| **ac-actions** | Action handling and delegation |
| **ac-host-config** | Theme and configuration providers (Teams preset) |
| **ac-accessibility** | TalkBack support and font scaling helpers |
| **ac-templating** | Template engine with 60+ expression functions |
| **ac-markdown** | Markdown rendering via `AnnotatedString` |
| **ac-charts** | Bar, Line, Pie, and Donut chart components |
| **ac-fluent-ui** | Fluent UI theming |
| **ac-copilot-extensions** | Copilot features |
| **ac-teams** | Teams integration |

## Supported Elements

### Display

TextBlock, Image, RichTextBlock, Media

### Containers

Container, ColumnSet, Column, FactSet, ImageSet, ActionSet, Table

### Inputs

Input.Text, Input.Number, Input.Date, Input.Time, Input.Toggle, Input.ChoiceSet, Input.Rating

All inputs support validation (`isRequired`, `regex`, `min`/`max`, `errorMessage`).

### Advanced Elements

Carousel, Accordion, CodeBlock, RatingDisplay, ProgressBar, Spinner, TabSet

### Actions

Action.Submit, Action.OpenUrl, Action.ShowCard, Action.Execute, Action.ToggleVisibility

## Customization

### Custom Host Config

```kotlin
val config = HostConfig(
    spacing = SpacingConfig(small = 2, default = 4, medium = 8, large = 16, extraLarge = 32, padding = 12)
)

HostConfigProvider(hostConfig = config) {
    AdaptiveCardView(cardJson = cardJson)
}
```

### Custom Element Renderer

```kotlin
GlobalElementRendererRegistry.register("CustomElement") { element, modifier ->
    Text("Custom: ${element.type}", modifier = modifier)
}
```

### Input Validation

```kotlin
val error = InputValidator.validateText(
    value = "user@example.com",
    isRequired = true,
    regex = "^[A-Za-z0-9+_.-]+@(.+)$",
    errorMessage = "Invalid email format"
)
```

## Building

```bash
cd android
./gradlew build                  # Build all modules
./gradlew :ac-core:build         # Build specific module
./gradlew test                   # Run all tests
./gradlew :ac-core:test          # Run specific module tests
./gradlew lint                   # Run lint checks
./gradlew clean                  # Clean build artifacts
```

Test reports are generated at `android/<module>/build/reports/tests/testDebugUnitTest/index.html`.

### Sample App

```bash
cd android
./gradlew :sample-app:installDebug
```

Or open the `android/` folder in Android Studio, select the sample-app configuration, and run.

The sample app includes a card gallery (333 cards), live JSON editor, Teams simulator, performance dashboard, and deep link support (`adaptivecards://` URL scheme).

## Requirements

- minSdk 24 (Android 7.0)
- targetSdk 34 (Android 14)
- Kotlin 1.9+
- Jetpack Compose BOM 2024.01+
- JDK 17
- Gradle 8.5+ (wrapper included)

## Documentation

- [Architecture](ARCHITECTURE.md) — Module architecture, data flow, design patterns
- [Naming Conventions](NAMING_CONVENTIONS.md) — Cross-platform naming alignment
- [Sample App](sample-app/README.md) — Sample app build instructions
- [Testing](shared-test/TESTING.md) — Test utilities and shared test infrastructure
- [Parity Matrix](../docs/architecture/PARITY_MATRIX.md) — Cross-platform feature status
- [Test Cards](../shared/test-cards/) — 333 shared test cards

## License

MIT — see [LICENSE](../LICENSE) for details.
