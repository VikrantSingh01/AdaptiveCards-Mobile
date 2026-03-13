# iOS Integration Guide

## Quick Start

```swift
import AdaptiveCards

// 1 line — render a card from JSON
AdaptiveCardView(json: cardJsonString)
```

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/AzureAD/AdaptiveCards-Mobile", from: "2.0.0")
]

// Use the umbrella product — one import, everything included
.product(name: "AdaptiveCards", package: "AdaptiveCards-Mobile")

// Optional: Teams-specific adapters and configuration
.product(name: "AdaptiveCardsTeams", package: "AdaptiveCards-Mobile")

// Optional: Copilot streaming/citations
.product(name: "AdaptiveCardsCopilot", package: "AdaptiveCards-Mobile")
```

## Usage Tiers

### Tier 1: Minimal (1 line)

```swift
import AdaptiveCards

AdaptiveCardView(json: cardJsonString)
```

### Tier 2: Production (SwiftUI)

```swift
import AdaptiveCards

let result = AdaptiveCards.parse(jsonString)

if let card = result.card {
    AdaptiveCardView(card: card, configuration: .teams(theme: .dark))
        .onCardAction { event in
            switch event {
            case .submit(_, let inputs):
                sendToBackend(inputs)
            case .openUrl(_, let url):
                UIApplication.shared.open(url)
            case .execute(let action, let inputs):
                invokeBot(action.verb, inputs)
            default:
                break
            }
        }
        .onCardLifecycle { event in
            switch event {
            case .rendered:
                isLoading = false
            case .sizeChanged(let size):
                cardHeight = size.height
            case .inputChanged(let id, _):
                isSendEnabled = true
            default:
                break
            }
        }
}
```

### Tier 3: Full Control (with CardHandle)

```swift
import AdaptiveCards

let result = AdaptiveCards.parse(jsonString, data: templateData)
guard let card = result.card else {
    handleError(result.error)
    return
}

@State var handle = CardHandle()

var config = CardConfiguration.teams(theme: .dark)
config.imageProvider = MyAuthenticatedImageProvider(token: authToken)
config.rendererOverrides.registerElement("CustomWidget") { element in
    MyCustomWidgetView(element: element)
}

AdaptiveCardView(card: card, configuration: config)
    .cardHandle(handle)
    .onCardAction { event in ... }
    .onCardLifecycle { event in ... }

// Query state from outside the card:
let inputs = handle.inputValues
let result = handle.validateInputs()
handle.refreshData(newTemplateData)
```

## UIKit Integration

For UIKit-based view hierarchies, use `AdaptiveCardUIView` — a drop-in `UIView` that wraps the SwiftUI renderer.

```swift
import AdaptiveCards

let cardView = AdaptiveCardUIView(
    card: parsedCard,
    configuration: .teams(theme: .dark)
)

// Action callback
cardView.onAction = { [weak self] event in
    switch event {
    case .submit(_, let inputs):
        self?.sendToBackend(inputs)
    case .openUrl(_, let url):
        UIApplication.shared.open(url)
    default:
        break
    }
}

// Lifecycle callback (e.g., for chat bubble sizing)
cardView.onLifecycle = { [weak self] event in
    if case .sizeChanged(let size) = event {
        self?.updateBubbleHeight(size.height)
    }
}

// Add to view hierarchy
view.addSubview(cardView)
cardView.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    cardView.topAnchor.constraint(equalTo: view.topAnchor)
])

// Query inputs / validate
let inputs = cardView.inputValues
let validation = cardView.validateInputs()

// Update card dynamically
cardView.updateCard(newParsedCard)
cardView.refreshData(newTemplateData)
```

## Parsing

Parsing is standalone — no view required. Use it for pre-parsing, caching, or inspection.

```swift
// Simple parse
let result = AdaptiveCards.parse(jsonString)
if result.isValid {
    let card = result.card!
    print("Card version: \(card.version)")
    print("Parse time: \(result.parseTimeMs)ms")
    print("Cache hit: \(result.cacheHit)")
}

// Parse with template data
let result = AdaptiveCards.parse(jsonString, data: ["name": "Alice", "count": 42])

// Check warnings
for warning in result.warnings {
    print("Warning [\(warning.code)]: \(warning.message)")
}

// Handle errors
if let error = result.error {
    switch error {
    case .invalidJSON(let msg): print("Bad JSON: \(msg)")
    case .decodingFailed(let msg): print("Decode error: \(msg)")
    case .timeout: print("Parse timed out")
    case .empty: print("Empty JSON")
    }
}
```

## Configuration

```swift
// Default
let config = CardConfiguration.default

// Teams themed
let config = CardConfiguration.teams(theme: .dark)

// Custom
var config = CardConfiguration(hostConfig: myHostConfig)
config.imageProvider = MyImageProvider()
config.guardrails = PerformanceGuardrails(
    maxElementCount: 300,
    maxConcurrentImageLoads: 8,
    imageTimeoutSeconds: 15.0
)
config.cache = CardCache(configuration: .aggressive)
```

### Custom Image Provider

Implement `ImageProvider` to route images through your auth pipeline:

```swift
class TeamsImageProvider: ImageProvider {
    let authService: AuthService

    func loadImage(from url: URL) async throws -> UIImage {
        var request = URLRequest(url: url)
        let token = try await authService.getToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let image = UIImage(data: data) else {
            throw ImageProviderError.invalidData
        }
        return image
    }
}
```

The SDK wraps your provider with caching automatically — you only handle fetching.

### Custom Element Renderer

```swift
var config = CardConfiguration.default
config.rendererOverrides.registerElement("MyWidget") { element in
    MyCustomWidgetView(element: element)
}
```

## Prefetch (Scroll Performance)

For lists with many cards, prefetch to avoid parse-time jank:

```swift
// UICollectionView prefetch delegate
func collectionView(_ collectionView: UICollectionView,
                    prefetchItemsAt indexPaths: [IndexPath]) {
    let jsons = indexPaths.compactMap { cardJSON(for: $0) }
    AdaptiveCards.prefetch(jsons, configuration: teamsConfig)
}

func collectionView(_ collectionView: UICollectionView,
                    cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    let jsons = indexPaths.compactMap { cardJSON(for: $0) }
    AdaptiveCards.cancelPrefetch(jsons)
}
```

## Cache Management

```swift
// Check cache stats
let stats = CardCache.shared.stats
print("Parse hit rate: \(stats.parseHitRate)")

// Clear on memory warning (SDK does this automatically by default)
CardCache.shared.clearAll()

// Custom cache with different limits
let cache = CardCache(configuration: CacheConfiguration(
    parseCapacity: 128,
    imageMemoryLimit: 100_000_000  // 100 MB
))
var config = CardConfiguration.default
config.cache = cache
```

## Performance Telemetry

```swift
AdaptiveCardView(card: card, configuration: config)
    .onCardLifecycle { event in
        if case .performanceReport(let m) = event {
            analytics.track("card_render", [
                "parse_ms": m.parseTimeMs,
                "render_ms": m.firstRenderTimeMs,
                "elements": m.elementCount,
                "cache_hit": m.parseCacheHit,
                "images_cached": m.imagesCachedCount,
                "unknown_types": m.unknownElementTypes
            ])
        }
    }
```

## Action Events Reference

| Event | When | Payload |
|---|---|---|
| `.submit(action, inputValues)` | User taps Submit button | Action data + all validated inputs |
| `.openUrl(action, url)` | User taps OpenUrl button | Pre-validated URL (safe schemes only) |
| `.execute(action, inputValues)` | User taps Execute button | Verb + action data + validated inputs |
| `.refreshRequested(userIds)` | Card has refresh metadata | User IDs that should refresh |
| `.authRequired(scheme, name)` | Card needs authentication | Auth scheme and connection name |

`ShowCard`, `ToggleVisibility`, and `Popover` are handled internally by the SDK.

## Lifecycle Events Reference

| Event | When | Use case |
|---|---|---|
| `.rendered` | Card body layout complete | Hide loading indicator |
| `.sizeChanged(CGSize)` | Card height changed | Chat bubble sizing |
| `.inputChanged(id, value)` | User modified an input | Enable send button |
| `.parseFailed(ParseError)` | Parse failed (json: init) | Show error state |
| `.performanceReport(metrics)` | Card fully loaded | Telemetry pipeline |

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+
