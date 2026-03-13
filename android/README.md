# Adaptive Cards Android SDK

Jetpack Compose rendering library for [Adaptive Cards](https://adaptivecards.io/) v1.6, designed for Microsoft Teams mobile integration.

> This SDK maintains strict feature parity with its [iOS SwiftUI counterpart](../ios/README.md). See [NAMING_CONVENTIONS.md](NAMING_CONVENTIONS.md) for cross-platform alignment details.

## Installation

### Gradle (Maven Central)

Add to your `build.gradle.kts`:

```kotlin
dependencies {
    // Core + Rendering (minimum for card display)
    implementation("com.microsoft.adaptivecards:ac-core:2.0.0")
    implementation("com.microsoft.adaptivecards:ac-rendering:2.0.0")

    // Optional modules
    implementation("com.microsoft.adaptivecards:ac-teams:2.0.0")        // Teams integration
    implementation("com.microsoft.adaptivecards:ac-inputs:2.0.0")       // Input controls
    implementation("com.microsoft.adaptivecards:ac-actions:2.0.0")      // Action handling
    implementation("com.microsoft.adaptivecards:ac-templating:2.0.0")   // Template engine
    implementation("com.microsoft.adaptivecards:ac-charts:2.0.0")       // Chart components
}
```

For local/project-level builds:

```kotlin
dependencies {
    implementation(project(":ac-core"))
    implementation(project(":ac-rendering"))
}
```

## Quick Start

### 1 line — render a card

```kotlin
AdaptiveCardView(cardJson = cardJSON)
```

### 5 lines — production usage

```kotlin
val result = AdaptiveCards.parse(cardJSON)
result.card?.let { card ->
    AdaptiveCardView(
        card = card,
        configuration = CardConfiguration.teams(TeamsTheme.Dark)
    )
}
```

### Full example

```kotlin
import com.microsoft.adaptivecards.core.AdaptiveCards
import com.microsoft.adaptivecards.core.CardConfiguration
import com.microsoft.adaptivecards.core.TeamsTheme
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView

@Composable
fun MyScreen() {
    val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                { "type": "TextBlock", "text": "Hello, Adaptive Cards!", "size": "large", "weight": "bolder" }
            ],
            "actions": [
                { "type": "Action.Submit", "title": "Submit" }
            ]
        }
    """.trimIndent()

    // Option A: Direct JSON rendering (parses internally)
    AdaptiveCardView(cardJson = cardJson)

    // Option B: Pre-parsed card (for caching, inspection, or conditional rendering)
    val result = AdaptiveCards.parse(cardJson)
    result.card?.let { card ->
        AdaptiveCardView(card = card, configuration = CardConfiguration.Default)
    }
}
```

## New Architecture (v2.0)

### Standalone Parsing

Parse cards independently of rendering — useful for pre-parsing, caching, and inspection:

```kotlin
import com.microsoft.adaptivecards.core.AdaptiveCards

// Parse once, render many times
val result = AdaptiveCards.parse(jsonString)
println("Valid: ${result.isValid}")
println("Parse time: ${result.parseTimeMs} ms")
println("Cache hit: ${result.cacheHit}")
println("Warnings: ${result.warnings}")

result.card?.let { card ->
    println("Elements: ${card.body?.size ?: 0}")
    println("Actions: ${card.actions?.size ?: 0}")
}
```

### CardConfiguration

Consolidates all rendering options into a single value type:

```kotlin
// Minimal
val config = CardConfiguration.Default

// Teams production
val config = CardConfiguration.teams(TeamsTheme.Dark).copy(
    imageProvider = MyAuthenticatedImageProvider(),
    guardrails = PerformanceGuardrails(maxElementCount = 300)
)

AdaptiveCardView(card = parsedCard, configuration = config)
```

### Custom Image Loading

Route images through your authenticated CDN:

```kotlin
class TeamsImageProvider(private val authService: AuthService) : ImageProvider {
    override suspend fun loadImage(url: String): Bitmap {
        val request = Request.Builder()
            .url(url)
            .header("Authorization", "Bearer ${authService.getToken()}")
            .build()
        val response = client.newCall(request).await()
        return BitmapFactory.decodeStream(response.body?.byteStream())
    }
}

val config = CardConfiguration.teams(TeamsTheme.Dark).copy(
    imageProvider = TeamsImageProvider(authService)
)
```

### Built-in Caching

Multi-layer caching (parse + template + image) with automatic memory pressure handling:

```kotlin
// Cache stats for monitoring
val stats = CardCache.shared.stats
println("Parse hit rate: ${stats.parseHitRate}")
println("Image cache: ${stats.imageMemoryUsage} bytes")

// Custom cache configuration
val config = CardConfiguration.Default.copy(
    cache = CardCache(CacheConfiguration.Aggressive)
)

// Disable caching (e.g., for testing)
val config = CardConfiguration.Default.copy(cache = null)
```

### Performance Guardrails

Protect against pathological cards:

```kotlin
val config = CardConfiguration.Default.copy(
    guardrails = PerformanceGuardrails(
        maxElementCount = 200,       // Cap elements per card
        maxNestingDepth = 10,        // Cap container nesting
        maxConcurrentImageLoads = 6, // Throttle image fetches
        parseTimeoutSeconds = 2.0    // Abort slow parses
    )
)
```

## Teams Integration

### Option A: Standalone Compose (recommended for new code)

```kotlin
import com.microsoft.adaptivecards.core.AdaptiveCards
import com.microsoft.adaptivecards.core.CardConfiguration
import com.microsoft.adaptivecards.core.TeamsTheme

// 1. Create Teams configuration
val config = CardConfiguration.teams(TeamsTheme.Dark).copy(
    imageProvider = TeamsImageProvider(authService)
)

// 2. Parse card
val result = AdaptiveCards.parse(cardJSON)
result.card?.let { card ->
    // 3. Compose rendering
    AdaptiveCardView(card = card, configuration = config)
}
```

### Option B: Android View Bridge (for existing View-based codebases)

Coming in a future release — `AdaptiveCardAndroidView` will provide a drop-in `AbstractComposeView` replacement:

```kotlin
// Android Views embedding (planned)
val cardView = AdaptiveCardAndroidView(context)
cardView.card = parsedCard
cardView.configuration = CardConfiguration.teams(TeamsTheme.Dark)
cardView.onAction = { event -> handleAction(event) }
layout.addView(cardView)
```

### Option C: Legacy Adapter (for migration from v1.x)

```kotlin
// Use the existing JSON-based entry point during migration
AdaptiveCardView(
    cardJson = json,
    actionHandler = myOldActionHandler
)
```

## Modules

| Module | Purpose |
|--------|---------|
| **ac-core** | Card parsing (`AdaptiveCards.parse()`), models, `CardConfiguration`, `CardCache`, `ImageProvider`, host config |
| **ac-rendering** | Compose composables for all card elements |
| **ac-inputs** | Input controls with validation |
| **ac-actions** | Action handling and delegation |
| **ac-accessibility** | TalkBack support and font scaling helpers |
| **ac-templating** | Template engine with 60+ expression functions |
| **ac-markdown** | Markdown rendering via `AnnotatedString` |
| **ac-charts** | Bar, Line, Pie, and Donut chart components |
| **ac-fluent-ui** | Fluent UI theming |
| **ac-copilot-extensions** | Copilot features |
| **ac-teams** | Teams integration with adapters for legacy migration |

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

## Publishing

### Maven Local (for local testing)

```bash
./gradlew publishToMavenLocal
```

### Maven Central

Publishing to Maven Central is handled via CI. To publish manually:

```bash
./gradlew publish \
    -Pversion=2.0.0 \
    -PsigningKeyId=$GPG_KEY_ID \
    -PsigningPassword=$GPG_PASSWORD \
    -PossrhUsername=$SONATYPE_USER \
    -PossrhPassword=$SONATYPE_PASS
```

Group ID: `com.microsoft.adaptivecards`

## Requirements

- minSdk 26 (Android 8.0)
- targetSdk 34 (Android 14)
- Kotlin 2.0+
- Jetpack Compose BOM 2024.10+
- JDK 17
- Gradle 8.5+ (wrapper included)

## Documentation

- [Architecture Roadmap](../docs/architecture/ARCHITECTURE_SIMPLIFICATION_ROADMAP.md) — New API design and migration plan
- [Naming Conventions](NAMING_CONVENTIONS.md) — Cross-platform naming alignment
- [Parity Matrix](../docs/architecture/PARITY_MATRIX.md) — Cross-platform feature status
- [Test Cards](../shared/test-cards/) — 333 shared test cards

## License

MIT — see [LICENSE](../LICENSE) for details.
