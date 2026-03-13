# Adaptive Cards Mobile SDK

Native [Adaptive Cards](https://adaptivecards.io/) rendering for iOS (SwiftUI) and Android (Jetpack Compose) with strict cross-platform feature parity.

[![iOS 16+](https://img.shields.io/badge/iOS-16%2B-blue.svg)](https://developer.apple.com/ios/)
[![Android API 24+](https://img.shields.io/badge/Android-API%2024%2B-green.svg)](https://developer.android.com/)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![Kotlin 1.9](https://img.shields.io/badge/Kotlin-1.9-purple.svg)](https://kotlinlang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Demo

https://github.com/user-attachments/assets/3a0e7ae5-8362-479a-a9e5-6b25d5f98c18

## Features

- **Native rendering** — SwiftUI on iOS, Jetpack Compose on Android. No web views.
- **Adaptive Cards v1.6** — Full schema support including advanced elements: Carousel, Accordion, CodeBlock, TabSet, Rating, Charts, and more.
- **Templating engine** — Data binding with 60+ expression functions (string, math, date, logic, collection).
- **Accessibility** — WCAG 2.1 AA compliant with VoiceOver and TalkBack support.
- **Responsive layout** — Adapts to phone/tablet, portrait/landscape, and Dynamic Type.
- **Theming** — Host-configurable styles with Fluent UI support and Figma design token alignment.
- **Security** — URL scheme allowlist prevents XSS and phishing from untrusted card JSON.

## Architecture

The SDK is organized into matching module sets across platforms:

| Module | iOS | Android | Purpose |
|--------|-----|---------|---------|
| Core | ACCore | ac-core | Card parsing, models, schema validation |
| Rendering | ACRendering | ac-rendering | UI views and composables |
| Inputs | ACInputs | ac-inputs | Input controls with validation |
| Actions | ACActions | ac-actions | Action handling and delegation |
| Accessibility | ACAccessibility | ac-accessibility | WCAG 2.1 AA helpers |
| Templating | ACTemplating | ac-templating | Template engine (60+ functions) |
| Markdown | ACMarkdown | ac-markdown | CommonMark rendering |
| Charts | ACCharts | ac-charts | Bar, Line, Pie, Donut charts |
| Fluent UI | ACFluentUI | ac-fluent-ui | Fluent UI theming |
| Copilot | ACCopilotExtensions | ac-copilot-extensions | Citations and streaming |
| Teams | ACTeams | ac-teams | Teams integration |

```
Host Application
  └─ Rendering ─┬─ Inputs ──┐
                 └─ Actions ─┤
                             └─ Core ── Templating
```

Cross-platform parity is enforced by CI — the parity gate fails if element type counts diverge by more than 2 between platforms.

## Quick Start

### iOS (SwiftUI)

Add via Swift Package Manager:

```
https://github.com/VikrantSingh01/AdaptiveCards-Mobile.git
```

```swift
import AdaptiveCards

// Parse + render
let result = AdaptiveCards.parse(cardJson)
if let card = result.card {
    AdaptiveCardView(card: card, configuration: .teams(theme: .dark))
        .onCardAction { event in
            switch event {
            case .submit(_, let inputs): sendToBackend(inputs)
            case .openUrl(_, let url): UIApplication.shared.open(url)
            case .execute(let action, let inputs): invokeBot(action.verb, inputs)
            default: break
            }
        }
}

// Or 1 line for quick rendering
AdaptiveCardView(json: cardJson)
```

For UIKit, use the bridge: `AdaptiveCardUIView(card: card, configuration: .default)`.

See [iOS Integration Guide](docs/guides/IOS_INTEGRATION_GUIDE.md) for full documentation.

### Android (Jetpack Compose)

Add the dependency via Gradle:

```kotlin
implementation("com.microsoft.adaptivecards:adaptive-cards:<version>")
```

```kotlin
import com.microsoft.adaptivecards.core.AdaptiveCards
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView

// Parse + render
val result = AdaptiveCards.parse(cardJson)
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
        }
    )
}

// Or 1 line for quick rendering
AdaptiveCardView(cardJson = cardJson)
```

For Android Views, use the bridge: `AdaptiveCardAndroidView(context)`.

See [Android Integration Guide](docs/guides/ANDROID_INTEGRATION_GUIDE.md) for full documentation.

### Templating

Cards support data binding with expressions:

```json
{
  "type": "AdaptiveCard",
  "body": [
    {
      "$when": "${showGreeting}",
      "type": "TextBlock",
      "text": "Hello, ${toUpper(userName)}!"
    },
    {
      "$data": "${items}",
      "type": "TextBlock",
      "text": "${name} - Item #${$index}"
    }
  ]
}
```

## Building from Source

### Prerequisites

| Platform | Requirements |
|----------|-------------|
| iOS | macOS 12+, Xcode 15+, Swift 5.9+ |
| Android | JDK 17, Android SDK API 34, Gradle 8.5+ (wrapper included) |

### Build and Test

**iOS**

```bash
cd ios
swift build          # Build all modules
swift test           # Run all tests
swift test --filter ACCoreTests  # Run specific module tests
```

**Android**

```bash
cd android
./gradlew build      # Build all modules
./gradlew test       # Run all tests
./gradlew :ac-core:test  # Run specific module tests
```

## Sample Applications

Both platforms include full-featured sample apps with a card gallery, live JSON editor, Teams simulator, performance dashboard, and bookmarks.

| Feature | iOS | Android |
|---------|-----|---------|
| Card Gallery | 333 cards by category | 333 cards by category |
| Live Editor | JSON with real-time preview | JSON with validation |
| Teams Simulator | Teams-style chat UI | Material Design chat UI |
| Deep Links | `adaptivecards://` scheme | `adaptivecards://` scheme |

**iOS** — Open `ios/SampleApp.xcodeproj`, select the ACVisualizer scheme, and run.

**Android** — `cd android && ./gradlew :sample-app:installDebug`

**Deep link routes** (both platforms):

```
adaptivecards://card/{category}/{name}   — open a specific card
adaptivecards://gallery                  — card gallery
adaptivecards://editor                   — JSON editor
adaptivecards://performance              — performance dashboard
```

## Testing

The SDK includes 333 shared test cards across 7 categories (element samples, official samples, Teams cards, templating, versioning, host configs, and parity tests) plus edge case cards for empty bodies, deep nesting, RTL content, and overflow scenarios.

```bash
# Validate all shared test cards
bash shared/scripts/validate-test-cards.sh

# Check cross-platform schema coverage
bash shared/scripts/compare-schema-coverage.sh
```

Visual snapshot tests verify rendering consistency:

```bash
# iOS visual snapshot tests
cd ios && xcodebuild test \
  -scheme AdaptiveCards-Package \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:VisualTests/CardElementSnapshotTests \
  CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

## CI/CD

GitHub Actions workflows run on every push and PR:

| Workflow | Purpose |
|----------|---------|
| Parity Gate | iOS + Android tests, schema validation, parity check |
| iOS Tests | Swift build + test with coverage |
| Android Tests | Gradle test with JUnit 5 |
| Lint | SwiftLint + ktlint |
| Visual Regression | Snapshot baseline comparison |
| Test Card Validation | JSON schema compliance |

## Documentation

| Document | Description |
|----------|-------------|
| [CHANGELOG](CHANGELOG.md) | Version history and release notes |
| [CONTRIBUTING](CONTRIBUTING.md) | Development setup and guidelines |
| [MIGRATION](MIGRATION.md) | Migration guide from legacy SDK |
| [Implementation Plan](docs/architecture/IMPLEMENTATION_PLAN.md) | Architecture and phased roadmap |
| [Parity Matrix](docs/architecture/PARITY_MATRIX.md) | Cross-platform feature status |
| [iOS README](ios/README.md) | iOS-specific documentation |
| [Android README](android/README.md) | Android-specific documentation |
| [VS Code Guide](docs/guides/VSCODE_COMPLETE_GUIDE.md) | VS Code development setup |

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Implement on **both** platforms (parity is required)
4. Write tests and update documentation
5. Submit a PR — CI will enforce parity, tests, and lint

See [CONTRIBUTING.md](CONTRIBUTING.md) for coding standards and detailed guidelines.

## License

[MIT](LICENSE)

## Author

[Vikrant Singh](https://github.com/VikrantSingh01)

## Links

- [Adaptive Cards Specification](https://adaptivecards.io/)
- [Adaptive Cards Designer](https://adaptivecards.io/designer/)
- [Schema Explorer](https://adaptivecards.io/explorer/)
- [GitHub Issues](https://github.com/VikrantSingh01/AdaptiveCards-Mobile/issues)
- [GitHub Discussions](https://github.com/VikrantSingh01/AdaptiveCards-Mobile/discussions)
