# Adaptive Cards iOS SDK

SwiftUI-based rendering library for [Adaptive Cards](https://adaptivecards.io/) v1.6, designed for Microsoft Teams mobile integration.

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AzureAD/AdaptiveCards-Mobile.git", from: "2.0.0")
]

// Then add the products you need:
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "ACCore", package: "AdaptiveCards-Mobile"),
        .product(name: "ACRendering", package: "AdaptiveCards-Mobile"),
        .product(name: "ACTeams", package: "AdaptiveCards-Mobile"),  // Optional: Teams integration
    ])
]
```

Or in Xcode: File > Add Packages > enter the repository URL > select the modules you need.

### CocoaPods

```ruby
# Core + Rendering (minimum for card display)
pod 'AdaptiveCards-Mobile/ACCore',      '~> 2.0'
pod 'AdaptiveCards-Mobile/ACRendering', '~> 2.0'

# Optional modules
pod 'AdaptiveCards-Mobile/ACTeams',     '~> 2.0'   # Teams integration + adapters
pod 'AdaptiveCards-Mobile/ACTemplating','~> 2.0'   # Template engine
pod 'AdaptiveCards-Mobile/ACCharts',    '~> 2.0'   # Chart components
```

## Quick Start

### 1 line — render a card

```swift
AdaptiveCardView(json: cardJSON)
```

### 5 lines — production usage

```swift
let result = AdaptiveCards.parse(cardJSON)
if let card = result.card {
    AdaptiveCardView(card: card, configuration: .teams(theme: .dark))
        .onCardAction { event in handleAction(event) }
}
```

### Full example

```swift
import ACCore
import ACRendering

struct ContentView: View {
    let cardJSON = """
    {
        "type": "AdaptiveCard",
        "version": "1.6",
        "body": [
            { "type": "TextBlock", "text": "Hello, Adaptive Cards!", "size": "Large", "weight": "Bolder" }
        ],
        "actions": [
            { "type": "Action.Submit", "title": "Submit" }
        ]
    }
    """

    var body: some View {
        // Option A: Direct JSON rendering (parses internally)
        AdaptiveCardView(json: cardJSON, configuration: .teams(theme: .light))

        // Option B: Pre-parsed card (for caching, inspection, or conditional rendering)
        let result = AdaptiveCards.parse(cardJSON)
        if let card = result.card {
            AdaptiveCardView(card: card, configuration: .default)
        }
    }
}
```

## New Architecture (v2.0)

### Standalone Parsing

Parse cards independently of rendering — useful for pre-parsing, caching, and inspection:

```swift
import ACCore

// Parse once, render many times
let result = AdaptiveCards.parse(jsonString)
print("Valid: \(result.isValid)")
print("Parse time: \(result.parseTimeMs) ms")
print("Cache hit: \(result.cacheHit)")
print("Warnings: \(result.warnings)")

if let card = result.card {
    // Inspect the card
    print("Elements: \(card.body?.count ?? 0)")
    print("Actions: \(card.actions?.count ?? 0)")
}
```

### CardConfiguration

Consolidates all rendering options into a single value type:

```swift
// Minimal
let config = CardConfiguration.default

// Teams production
var config = CardConfiguration.teams(theme: .dark)
config.imageProvider = MyAuthenticatedImageProvider()
config.featureFlags.register(name: "myFeature", version: "1.0")
config.guardrails.maxElementCount = 300  // Override default (200)

AdaptiveCardView(card: parsedCard, configuration: config)
```

### Custom Image Loading

Route images through your authenticated CDN:

```swift
class TeamsImageProvider: ImageProvider {
    let authService: AuthService

    func loadImage(from url: URL) async throws -> UIImage {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(try await authService.getToken())",
                        forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let image = UIImage(data: data) else {
            throw ImageProviderError.invalidData
        }
        return image
    }
}

var config = CardConfiguration.teams(theme: .dark)
config.imageProvider = TeamsImageProvider(authService: authService)
```

### Built-in Caching

Multi-layer caching (parse + template + image) with automatic memory pressure handling:

```swift
// Cache stats for monitoring
let stats = CardCache.shared.stats
print("Parse hit rate: \(stats.parseHitRate)")
print("Image cache: \(stats.imageMemoryUsage) bytes")

// Custom cache configuration
var config = CardConfiguration.default
config.cache = CardCache(configuration: .aggressive)  // 128 cards, 100 MB images

// Disable caching (e.g., for testing)
config.cache = nil
```

### Performance Guardrails

Protect against pathological cards:

```swift
var config = CardConfiguration.default
config.guardrails.maxElementCount = 200       // Cap elements per card
config.guardrails.maxNestingDepth = 10        // Cap container nesting
config.guardrails.maxConcurrentImageLoads = 6 // Throttle image fetches
config.guardrails.parseTimeoutSeconds = 2.0   // Abort slow parses
```

## Teams Integration

### Option A: Standalone (recommended for new code)

```swift
import ACCore
import ACRendering

// 1. Create Teams configuration
var config = CardConfiguration.teams(theme: .dark)
config.imageProvider = TeamsImageProvider(authService: authService)

// 2. Parse card
let result = AdaptiveCards.parse(cardJSON)
guard let card = result.card else { return }

// 3. SwiftUI rendering
AdaptiveCardView(card: card, configuration: config)
```

### Option B: UIKit Bridge (for existing UIKit codebases)

Coming in a future release — `AdaptiveCardUIView` will provide a drop-in `UIView` replacement:

```swift
// UIKit embedding (planned)
let cardView = AdaptiveCardUIView(card: parsedCard, configuration: .teams(theme: .dark))
cardView.onAction = { [weak self] event in self?.handleAction(event) }
self.view.addSubview(cardView)
```

### Option C: Legacy Adapter (for migration from v1.x)

```swift
import ACTeams

// Use the legacy action handler adapter for zero-behavior-change migration
let cardView = AdaptiveCardView(cardJson: json, actionDelegate: myOldDelegate)
```

## Modules

| Module | Purpose |
|--------|---------|
| **ACCore** | Card parsing (`AdaptiveCards.parse()`), models, `CardConfiguration`, `CardCache`, `ImageProvider`, host config |
| **ACRendering** | SwiftUI views for all card elements |
| **ACInputs** | Input controls (text, number, date, time, toggle, choice, rating) with validation |
| **ACActions** | Action handling (submit, open URL, show card, execute, toggle visibility) |
| **ACAccessibility** | VoiceOver, Dynamic Type, and RTL layout helpers |
| **ACTemplating** | Template engine with 60+ expression functions |
| **ACMarkdown** | CommonMark rendering via `AttributedString` |
| **ACCharts** | Bar, Line, Pie, and Donut chart components |
| **ACFluentUI** | Fluent UI theming with platform-specific design tokens |
| **ACCopilotExtensions** | Copilot citation and streaming support |
| **ACTeams** | Teams integration with adapters for legacy migration |

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
cd ios
swift build                          # Build all modules
swift build -c release               # Release build
swift test                           # Run all tests
swift test --filter ACTemplatingTests  # Run specific test suite
swift package clean                  # Clean build artifacts
```

### Sample App

Open `ios/SampleApp.xcodeproj` in Xcode, select the **ACVisualizer** scheme, and run on an iOS 16+ simulator.

The sample app includes a card gallery (333 cards), live JSON editor, Teams simulator, performance dashboard, and deep link support (`adaptivecards://` URL scheme).

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+

## Documentation

- [Architecture Roadmap](../docs/architecture/ARCHITECTURE_SIMPLIFICATION_ROADMAP.md) — New API design and migration plan
- [Parity Matrix](../docs/architecture/PARITY_MATRIX.md) — Cross-platform feature status
- [Test Cards](../shared/test-cards/) — 333 shared test cards

## License

MIT — see [LICENSE](../LICENSE) for details.
