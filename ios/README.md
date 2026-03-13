# Adaptive Cards iOS SDK

SwiftUI-based rendering library for [Adaptive Cards](https://adaptivecards.io/) v1.6, designed for Microsoft Teams mobile integration.

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/VikrantSingh01/AdaptiveCards-Mobile.git", from: "1.0.0")
]
```

Or in Xcode: File > Add Packages > enter the repository URL > select the modules you need.

## Quick Start

```swift
import ACCore
import ACRendering
import ACActions

struct ContentView: View {
    let cardJSON = """
    {
        "type": "AdaptiveCard",
        "version": "1.6",
        "body": [
            {
                "type": "TextBlock",
                "text": "Hello, Adaptive Cards!",
                "size": "Large",
                "weight": "Bolder"
            }
        ],
        "actions": [
            { "type": "Action.Submit", "title": "Submit" }
        ]
    }
    """

    var body: some View {
        AdaptiveCardView(
            json: cardJSON,
            hostConfig: TeamsHostConfig.create(),
            actionDelegate: MyActionDelegate()
        )
    }
}

class MyActionDelegate: ActionDelegate {
    func onSubmit(data: [String: Any], actionId: String?) {
        print("Submitted: \(data)")
    }
    func onOpenUrl(url: URL, actionId: String?) {
        print("Open URL: \(url)")
    }
    func onExecute(verb: String?, data: [String: Any], actionId: String?) {
        print("Execute: \(verb ?? "nil")")
    }
}
```

## Modules

| Module | Purpose |
|--------|---------|
| **ACCore** | Card parsing, models, host configuration, schema validation |
| **ACRendering** | SwiftUI views for all card elements |
| **ACInputs** | Input controls (text, number, date, time, toggle, choice, rating) with validation |
| **ACActions** | Action handling (submit, open URL, show card, execute, toggle visibility) |
| **ACAccessibility** | VoiceOver, Dynamic Type, and RTL layout helpers |
| **ACTemplating** | Template engine with 60+ expression functions |
| **ACMarkdown** | CommonMark rendering via `AttributedString` |
| **ACCharts** | Bar, Line, Pie, and Donut chart components |
| **ACFluentUI** | Fluent UI theming with platform-specific design tokens |
| **ACCopilotExtensions** | Copilot citation and streaming support |
| **ACTeams** | Teams integration with pre-configured host config |

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

```swift
let config = HostConfig(
    spacing: SpacingConfig(small: 4, default: 8, medium: 12, large: 16, extraLarge: 24, padding: 16),
    fontSizes: FontSizesConfig(small: 12, default: 14, medium: 16, large: 20, extraLarge: 26)
)

AdaptiveCardView(json: cardJSON, hostConfig: config, actionDelegate: delegate)
```

### Custom Element Renderer

```swift
ElementRendererRegistry.shared.register("MyCustomType") { element in
    VStack { Text("Custom Element") }
}
```

### Custom Action Handler

```swift
class CustomActionHandler: ActionHandler {
    func handle(_ action: CardAction, delegate: ActionDelegate?, viewModel: CardViewModel) {
        switch action {
        case .submit(let submitAction):
            // Custom submit handling
            break
        default:
            DefaultActionHandler().handle(action, delegate: delegate, viewModel: viewModel)
        }
    }
}
```

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

- [Architecture](ARCHITECTURE.md) — Module architecture, data flow, design patterns
- [Accessibility](ACCESSIBILITY.md) — WCAG 2.1 AA compliance details
- [Sample App](SampleApp/README.md) — Sample app build instructions
- [Visual Testing Guide](Tests/VisualTests/VISUAL_TESTING_GUIDE.md) — Snapshot test setup
- [Parity Matrix](../docs/architecture/PARITY_MATRIX.md) — Cross-platform feature status
- [Test Cards](../shared/test-cards/) — 333 shared test cards

## License

MIT — see [LICENSE](../LICENSE) for details.
