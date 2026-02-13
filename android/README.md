# Adaptive Cards Android SDK

Modern Android SDK for rendering [Adaptive Cards](https://adaptivecards.io/) using Jetpack Compose and MVVM architecture.

> **Cross-Platform Design**: This SDK is designed as a companion to the iOS SwiftUI implementation, with aligned naming conventions and API design. See [NAMING_CONVENTIONS.md](NAMING_CONVENTIONS.md) for details on iOS/Android alignment.

## Features

- 🎨 **Jetpack Compose UI** - Modern declarative UI with Material3
- 🏗️ **MVVM Architecture** - Clean separation with ViewModel state management
- 📦 **Multi-module Design** - Modular architecture for flexibility
- 🎯 **Kotlin-first** - 100% Kotlin with kotlinx.serialization
- ♿ **Accessibility** - Built-in TalkBack support and font scaling
- 🌍 **RTL Support** - Right-to-left layout support
- 🎨 **Customizable** - Extensible renderer registry and host config
- 🔄 **Teams Integration** - Pre-configured Teams theme with Fluent UI tokens

## Build Status (Verified 2026-02-12)

| Item | Status |
|------|--------|
| **Modules Built** | 12/12 |
| **Tests** | 150 passed (100% pass rate) |
| **Sample App** | Running on Android Emulator API 36 |
| **Card Rendering** | Actual Adaptive Card content via `AdaptiveCardView` composable |

### Recent Fixes
- **Sample app 9 compilation errors**: Fixed type mismatches, missing imports, incorrect API usage, and parameter errors across `CardDetailScreen.kt`, `CardEditorScreen.kt`, `CardGalleryScreen.kt`, `TeamsSimulatorScreen.kt`, and `MainActivity.kt`.
- **Rendering placeholder bug**: Replaced placeholder `Text()` composables in `CardDetailScreen` and `CardEditorScreen` with actual `AdaptiveCardView` rendering that parses and displays real card content.
- **Assets configuration**: Added `assets` source directory configuration in `sample-app/build.gradle.kts` so test card JSON files are bundled and loadable at runtime.
- **SchemaValidator**: Updated `SchemaValidator.kt` for compatibility.
- **Markdown build config**: Updated `ac-markdown/build.gradle.kts` and `gradle/libs.versions.toml` for dependency alignment.
- **minSdk 24 compatibility**: Ensured `DateFunctions` API 24 compatibility, parser support for negative numbers.

## Modules

- **ac-core** - Core models, parsing, and host configuration
- **ac-rendering** - Compose UI renderers and view models
- **ac-inputs** - Input controls and validation
- **ac-actions** - Action handlers and delegates
- **ac-host-config** - Theme and configuration providers
- **ac-accessibility** - Accessibility helpers and modifiers
- **ac-templating** - Template binding with 50+ expression functions
- **ac-markdown** - Markdown rendering
- **ac-charts** - Chart components (Bar, Line, Pie, Donut)
- **ac-fluent-ui** - Fluent UI theming
- **ac-copilot-extensions** - Copilot features
- **ac-teams** - Teams integration

## Quick Start

### 1. Add Dependencies

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

### 2. Basic Usage

```kotlin
import androidx.compose.runtime.Composable
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
    override fun onSubmit(data: Map<String, Any>) {
        println("Submit: $data")
    }
    
    override fun onOpenUrl(url: String) {
        // Open URL
    }
    
    override fun onExecute(verb: String, data: Map<String, Any>) {
        println("Execute $verb: $data")
    }
    
    override fun onShowCard(cardAction: com.microsoft.adaptivecards.core.models.CardAction) {
        // Handle show card
    }
    
    override fun onToggleVisibility(targetElementIds: List<String>) {
        // Handle toggle visibility
    }
}
```

## Advanced Usage

### Custom Host Configuration

```kotlin
import com.microsoft.adaptivecards.core.hostconfig.HostConfig
import com.microsoft.adaptivecards.core.hostconfig.SpacingConfig
import com.microsoft.adaptivecards.hostconfig.HostConfigProvider

val customHostConfig = HostConfig(
    spacing = SpacingConfig(
        small = 2,
        default = 4,
        medium = 8,
        large = 16,
        extraLarge = 32,
        padding = 12
    ),
    // ... other customizations
)

HostConfigProvider(hostConfig = customHostConfig) {
    AdaptiveCardView(cardJson = cardJson)
}
```

### Custom Renderer Registration

```kotlin
import com.microsoft.adaptivecards.rendering.registry.GlobalElementRendererRegistry

// Register a custom element renderer
GlobalElementRendererRegistry.register("CustomElement") { element, modifier ->
    // Your custom composable
    Text("Custom element: ${element.type}", modifier = modifier)
}
```

### Input Validation

```kotlin
import com.microsoft.adaptivecards.inputs.validation.InputValidator

val error = InputValidator.validateText(
    value = "user@example.com",
    isRequired = true,
    regex = "^[A-Za-z0-9+_.-]+@(.+)$",
    errorMessage = "Invalid email format"
)
```

## Card Examples

### Simple Text Card

```json
{
    "type": "AdaptiveCard",
    "version": "1.6",
    "body": [
        {
            "type": "TextBlock",
            "text": "Welcome!",
            "size": "large",
            "weight": "bolder"
        }
    ]
}
```

### Form with Inputs

```json
{
    "type": "AdaptiveCard",
    "version": "1.6",
    "body": [
        {
            "type": "Input.Text",
            "id": "name",
            "label": "Name",
            "isRequired": true
        },
        {
            "type": "Input.Number",
            "id": "age",
            "label": "Age",
            "min": 0,
            "max": 120
        }
    ],
    "actions": [
        {
            "type": "Action.Submit",
            "title": "Submit"
        }
    ]
}
```

### Container with Image

```json
{
    "type": "AdaptiveCard",
    "version": "1.6",
    "body": [
        {
            "type": "Container",
            "style": "emphasis",
            "items": [
                {
                    "type": "Image",
                    "url": "https://example.com/image.png",
                    "size": "medium"
                },
                {
                    "type": "TextBlock",
                    "text": "Image description"
                }
            ]
        }
    ]
}
```

## Architecture

### MVVM Pattern

The SDK follows the MVVM (Model-View-ViewModel) architecture:

- **Model** (`ac-core`): Data classes with kotlinx.serialization
- **View** (`ac-rendering`, `ac-inputs`): Composable functions
- **ViewModel** (`CardViewModel`): State management with StateFlow

### State Management

```kotlin
class CardViewModel : ViewModel() {
    val card: StateFlow<AdaptiveCard?>
    val inputValues: StateFlow<Map<String, Any>>
    val visibilityState: StateFlow<Map<String, Boolean>>
    
    fun updateInputValue(id: String, value: Any)
    fun toggleVisibility(elementId: String)
    fun validateAllInputs(): Boolean
}
```

### Supported Elements

- ✅ TextBlock
- ✅ Image
- ✅ Container
- ✅ ColumnSet / Column
- ✅ FactSet
- ✅ ImageSet
- ✅ ActionSet
- ✅ RichTextBlock
- ✅ Table (basic)
- ✅ Media (basic)
- ✅ Input.Text
- ✅ Input.Number
- ✅ Input.Date
- ✅ Input.Time
- ✅ Input.Toggle
- ✅ Input.ChoiceSet

### Supported Actions

- ✅ Action.Submit
- ✅ Action.OpenUrl
- ✅ Action.ShowCard
- ✅ Action.Execute
- ✅ Action.ToggleVisibility

## Testing

Run tests for each module:

```bash
# All tests (150 tests, 100% pass rate as of 2026-02-12)
./gradlew test

# Core module tests
./gradlew :ac-core:test

# Templating module tests
./gradlew :ac-templating:test

# Run with detailed output
./gradlew test --info

# View HTML test reports
# android/<module>/build/reports/tests/testDebugUnitTest/index.html
```

### Running the Sample App

```bash
cd android

# Build the sample app
./gradlew :sample-app:assembleDebug

# Install on connected emulator/device
./gradlew :sample-app:installDebug

# Or use Android Studio: open android/ folder, select sample-app configuration, click Run
```

The sample app displays a card gallery with live rendering. Cards are loaded from `assets/test-cards/` and rendered using the `AdaptiveCardView` composable.

## Requirements

- minSdk 24 (Android 7.0)
- targetSdk 34 (Android 14)
- Kotlin 1.9+
- Jetpack Compose BOM 2024.01+
- Gradle 8.5+ (wrapper included in repository)
- JDK 17

## License

Copyright (c) Microsoft Corporation. All rights reserved.

## Contributing

This project welcomes contributions and suggestions. Please see [CONTRIBUTING.md](../CONTRIBUTING.md) for details.

## Troubleshooting

### Cards show placeholder text instead of content

If `CardDetailScreen` or `CardEditorScreen` display generic `Text()` composables instead of actual card content, ensure you are using the latest version that includes `AdaptiveCardView` rendering. This was a known issue fixed in v1.1.0-dev.

### Test card JSON files not loading

Ensure `src/main/assets/test-cards/` directory exists and is configured as an assets source in `build.gradle.kts`:
```kotlin
android {
    sourceSets {
        getByName("main") {
            assets.srcDirs("src/main/assets")
        }
    }
}
```

### Gradle sync fails

- Verify JDK 17 is installed and configured
- Run `./gradlew clean` then retry
- Check that `gradle/libs.versions.toml` has correct dependency versions

### Build errors in sample-app

If you encounter compilation errors in sample app screens, ensure all SDK module dependencies are correctly declared in `sample-app/build.gradle.kts` and that Gradle sync has completed successfully.

## Cross-Platform Alignment

This SDK is designed to work seamlessly with its iOS SwiftUI counterpart. Key alignments:

- ✅ **Identical model names**: `AdaptiveCard`, `TextBlock`, `ActionSubmit`, etc.
- ✅ **Identical view names**: `AdaptiveCardView`, `TextBlockView`, etc.
- ✅ **Identical API patterns**: Both use MVVM with reactive state management
- ✅ **Same method signatures**: `onSubmit(data)`, `validateText(value)`, etc.

See [NAMING_CONVENTIONS.md](NAMING_CONVENTIONS.md) for complete cross-platform naming guide.

## Resources

- [Adaptive Cards Documentation](https://docs.microsoft.com/en-us/adaptive-cards/)
- [Adaptive Cards Schema](https://adaptivecards.io/explorer/)
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- [Material Design 3](https://m3.material.io/)
- [Cross-Platform Naming Guide](NAMING_CONVENTIONS.md)
