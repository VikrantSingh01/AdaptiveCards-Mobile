# Android Integration Guide

## Quick Start

```kotlin
import com.microsoft.adaptivecards.core.AdaptiveCards
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView

// 1 line — render a card from JSON
AdaptiveCardView(cardJson = jsonString)
```

## Installation

### Gradle

```kotlin
// settings.gradle.kts
dependencyResolutionManagement {
    repositories {
        mavenCentral()
    }
}

// app/build.gradle.kts
dependencies {
    // Core SDK — everything you need
    implementation("com.microsoft.adaptivecards:adaptive-cards:2.0.0")

    // Optional: Teams-specific adapters
    implementation("com.microsoft.adaptivecards:adaptive-cards-teams:2.0.0")

    // Optional: Copilot streaming/citations
    implementation("com.microsoft.adaptivecards:adaptive-cards-copilot:2.0.0")
}
```

## Usage Tiers

### Tier 1: Minimal (1 line)

```kotlin
AdaptiveCardView(cardJson = jsonString)
```

### Tier 2: Production (Compose)

```kotlin
val result = AdaptiveCards.parse(jsonString)

result.card?.let { card ->
    AdaptiveCardView(
        card = card,
        configuration = CardConfiguration.teams(TeamsTheme.Dark),
        onAction = { event ->
            when (event) {
                is CardActionEvent.Submit -> sendToBackend(event.inputValues)
                is CardActionEvent.OpenUrl -> openBrowser(event.url)
                is CardActionEvent.Execute -> invokeBot(event.action.verb, event.inputValues)
                else -> {}
            }
        },
        onLifecycle = { event ->
            when (event) {
                is CardLifecycleEvent.Rendered -> isLoading = false
                is CardLifecycleEvent.SizeChanged -> cardHeight = event.height
                is CardLifecycleEvent.InputChanged -> isSendEnabled = true
                else -> {}
            }
        }
    )
}
```

### Tier 3: Full Control (with CardHandle)

```kotlin
val result = AdaptiveCards.parse(jsonString)
val card = result.card ?: run { handleError(result.error); return }

val handle = remember { CardHandle() }

var config = CardConfiguration.teams(TeamsTheme.Dark).copy(
    imageProvider = MyAuthenticatedImageProvider(authService)
)

AdaptiveCardView(
    card = card,
    configuration = config,
    handle = handle,
    onAction = { event -> ... },
    onLifecycle = { event -> ... }
)

// Query state from outside the card:
val inputs by handle.inputValues.collectAsState()
val result = handle.validateInputs()
handle.refreshData(newTemplateData)
```

## Android View Integration

For View-based layouts (Activities, Fragments, RecyclerViews), use `AdaptiveCardAndroidView` — a drop-in `View` that wraps the Compose renderer.

```kotlin
import com.microsoft.adaptivecards.rendering.bridge.AdaptiveCardAndroidView

// In Activity/Fragment
val cardView = AdaptiveCardAndroidView(context)
cardView.card = parsedCard
cardView.configuration = CardConfiguration.teams(TeamsTheme.Dark)

// Action callback
cardView.onAction = { event ->
    when (event) {
        is CardActionEvent.Submit -> sendToBackend(event.inputValues)
        is CardActionEvent.OpenUrl -> openBrowser(event.url)
        else -> {}
    }
}

// Lifecycle callback
cardView.onLifecycle = { event ->
    if (event is CardLifecycleEvent.SizeChanged) {
        updateBubbleHeight(event.height)
    }
}

// Add to layout
linearLayout.addView(cardView)

// Or from JSON directly
cardView.setCardJson(jsonString)

// Query inputs / validate
val inputs = cardView.getInputValues()
val result = cardView.validateInputs()

// Refresh with new data
cardView.refreshData(mapOf("count" to 42))
```

### RecyclerView Adapter

```kotlin
class CardViewHolder(val cardView: AdaptiveCardAndroidView) :
    RecyclerView.ViewHolder(cardView) {

    fun bind(cardJson: String, config: CardConfiguration) {
        cardView.setCardJson(cardJson)
        cardView.configuration = config
        cardView.onAction = { event -> handleAction(event) }
    }
}
```

## Parsing

Parsing is standalone — no Composable context required.

```kotlin
// Simple parse
val result = AdaptiveCards.parse(jsonString)
if (result.isValid) {
    val card = result.card!!
    println("Card version: ${card.version}")
    println("Parse time: ${result.parseTimeMs}ms")
    println("Cache hit: ${result.cacheHit}")
}

// Check warnings
for (warning in result.warnings) {
    Log.w("AdaptiveCards", "[${warning.code}] ${warning.message}")
}

// Handle errors
result.error?.let { error ->
    when (error) {
        is ParseError.InvalidJSON -> Log.e(TAG, "Bad JSON: ${error.message}")
        is ParseError.DecodingFailed -> Log.e(TAG, "Decode error: ${error.message}")
        is ParseError.Timeout -> Log.e(TAG, "Parse timed out")
        is ParseError.Empty -> Log.e(TAG, "Empty JSON")
    }
}
```

## Configuration

```kotlin
// Default
val config = CardConfiguration.Default

// Teams themed
val config = CardConfiguration.teams(TeamsTheme.Dark)

// Custom
val config = CardConfiguration(
    hostConfig = myHostConfig,
    imageProvider = MyImageProvider(),
    guardrails = PerformanceGuardrails(
        maxElementCount = 300,
        maxConcurrentImageLoads = 8,
        imageTimeoutSeconds = 15.0
    ),
    cache = CardCache(CacheConfiguration.Aggressive)
)
```

### Custom Image Provider

Implement `ImageProvider` to route images through your auth pipeline:

```kotlin
class TeamsImageProvider(private val authService: AuthService) : ImageProvider {
    override suspend fun loadImage(url: String): ImageBitmap {
        val token = authService.getToken()
        val connection = URL(url).openConnection() as HttpURLConnection
        connection.setRequestProperty("Authorization", "Bearer $token")
        val bitmap = BitmapFactory.decodeStream(connection.inputStream)
        return bitmap.asImageBitmap()
    }
}
```

The SDK wraps your provider with caching automatically — you only handle fetching.

### Custom Element Renderer

```kotlin
val overrides = RendererOverrides()
overrides.registerElement("MyWidget") { element, modifier ->
    MyCustomWidgetComposable(element, modifier)
}
val config = CardConfiguration(rendererOverrides = overrides)
```

## Prefetch (Scroll Performance)

For lists with many cards, prefetch to avoid parse-time jank:

```kotlin
// In RecyclerView.Adapter
override fun onBindViewHolder(holder: CardViewHolder, position: Int) {
    // Prefetch next 5 cards
    val prefetchRange = (position + 1..minOf(position + 5, itemCount - 1))
    val jsons = prefetchRange.map { getCardJson(it) }
    AdaptiveCards.prefetch(jsons, configuration)
}

// In LazyColumn
LazyColumn {
    items(cards) { cardJson ->
        LaunchedEffect(cardJson) {
            // Prefetch on first composition
            AdaptiveCards.prefetch(listOf(cardJson), config)
        }
        AdaptiveCardView(cardJson = cardJson, configuration = config)
    }
}
```

## Cache Management

```kotlin
// Check cache stats
val stats = CardCache.shared.stats
println("Parse hit rate: ${stats.parseHitRate}")

// Clear on low memory (SDK does this automatically via ComponentCallbacks2)
CardCache.shared.clearAll()

// Custom cache with different limits
val cache = CardCache(CacheConfiguration(
    parseCapacity = 128,
    imageMemoryLimit = 100_000_000  // 100 MB
))
val config = CardConfiguration(cache = cache)
```

## Performance Telemetry

```kotlin
AdaptiveCardView(
    card = card,
    configuration = config,
    onLifecycle = { event ->
        if (event is CardLifecycleEvent.PerformanceReport) {
            val m = event.metrics
            analytics.track("card_render", mapOf(
                "parse_ms" to m.parseTimeMs,
                "render_ms" to m.firstRenderTimeMs,
                "elements" to m.elementCount,
                "cache_hit" to m.parseCacheHit,
                "images_cached" to m.imagesCachedCount,
                "unknown_types" to m.unknownElementTypes
            ))
        }
    }
)
```

## Action Events Reference

| Event | When | Payload |
|---|---|---|
| `Submit(action, inputValues)` | User taps Submit button | Action data + all validated inputs |
| `OpenUrl(action, url)` | User taps OpenUrl button | Pre-validated URL (safe schemes only) |
| `Execute(action, inputValues)` | User taps Execute button | Verb + action data + validated inputs |
| `RefreshRequested(userIds)` | Card has refresh metadata | User IDs that should refresh |
| `AuthRequired(scheme, name)` | Card needs authentication | Auth scheme and connection name |

`ShowCard`, `ToggleVisibility`, and `Popover` are handled internally by the SDK.

## Lifecycle Events Reference

| Event | When | Use case |
|---|---|---|
| `Rendered` | Card body layout complete | Hide loading indicator |
| `SizeChanged(width, height)` | Card dimensions changed | Chat bubble sizing |
| `InputChanged(id, value)` | User modified an input | Enable send button |
| `ParseFailed(error)` | Parse failed (json overload) | Show error state |
| `PerformanceReport(metrics)` | Card fully loaded | Telemetry pipeline |

## Requirements

- minSdk 26
- compileSdk 34
- Kotlin 1.9+
- Jetpack Compose BOM 2024.x
- JDK 17
