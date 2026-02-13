# Adaptive Cards iOS SDK

A modern, SwiftUI-based implementation of the Adaptive Cards SDK for iOS, designed for Microsoft Teams mobile integration and supporting **Adaptive Cards schema v1.6**.

## 🎯 v1.6 Parity Status

This SDK fully implements Adaptive Cards v1.6 with complete cross-platform parity. See [PARITY_MATRIX.md](../docs/architecture/PARITY_MATRIX.md) for detailed status.

**Highlights**:
- ✅ **41+ Element Types**: All v1.6 elements including Table, CompoundButton
- ✅ **5 Action Types**: Including Action.Execute with v1.6 enhancements (verb, associatedInputs)
- ✅ **60 Expression Functions**: Complete templating engine
- ✅ **Schema Validation**: Built-in v1.6 schema validator with round-trip serialization tests
- 🚧 **menuActions**: Tracked for future implementation with tests in place

## Features

- ✅ **SwiftUI + MVVM Architecture**: Modern declarative UI with clean separation of concerns
- ✅ **Full Schema v1.6 Support**: All element types, inputs, and actions
- ✅ **Microsoft Teams Ready**: Pre-configured Teams host config with Fluent UI tokens
- ✅ **Extensible**: Custom element and action renderers via registry pattern
- ✅ **Accessible**: Full VoiceOver support, Dynamic Type, and RTL languages
- ✅ **Type-Safe**: Leverages Swift's type system with enums and associated values
- ✅ **Modular**: Five independent SPM modules for flexible integration

## Installation

### Swift Package Manager

Add this package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/VikrantSingh01/AdaptiveCards-Mobile.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Packages...
2. Enter the repository URL
3. Select the modules you need

## Quick Start

### Basic Usage

```swift
import SwiftUI
import ACRendering
import ACCore
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
            {
                "type": "Action.Submit",
                "title": "Submit"
            }
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
        print("Submitted data: \(data)")
    }
    
    func onOpenUrl(url: URL, actionId: String?) {
        print("Open URL: \(url)")
    }
    
    func onExecute(verb: String?, data: [String: Any], actionId: String?) {
        print("Execute: \(verb ?? "nil") with data: \(data)")
    }
}
```

### Using Custom Host Config

```swift
import ACCore

let customConfig = HostConfig(
    spacing: SpacingConfig(
        small: 4,
        default: 8,
        medium: 12,
        large: 16,
        extraLarge: 24,
        padding: 16
    ),
    fontSizes: FontSizesConfig(
        small: 12,
        default: 14,
        medium: 16,
        large: 20,
        extraLarge: 26
    )
    // ... customize other properties
)

AdaptiveCardView(
    json: cardJSON,
    hostConfig: customConfig,
    actionDelegate: delegate
)
```

### Advanced Elements Examples

#### Carousel with Auto-Advance

```swift
let carouselJSON = """
{
    "type": "AdaptiveCard",
    "version": "1.6",
    "body": [
        {
            "type": "Carousel",
            "timer": 5000,
            "pages": [
                {
                    "items": [
                        {
                            "type": "Image",
                            "url": "https://example.com/image1.jpg",
                            "size": "Stretch"
                        },
                        {
                            "type": "TextBlock",
                            "text": "Slide 1",
                            "weight": "Bolder"
                        }
                    ]
                }
            ]
        }
    ]
}
"""
```

#### Accordion with Single-Expand Mode

```swift
let accordionJSON = """
{
    "type": "AdaptiveCard",
    "version": "1.6",
    "body": [
        {
            "type": "Accordion",
            "expandMode": "Single",
            "panels": [
                {
                    "title": "FAQ Item 1",
                    "isExpanded": true,
                    "content": [
                        {
                            "type": "TextBlock",
                            "text": "Answer goes here",
                            "wrap": true
                        }
                    ]
                }
            ]
        }
    ]
}
"""
```

#### Rating Input with Validation

```swift
let ratingJSON = """
{
    "type": "AdaptiveCard",
    "version": "1.6",
    "body": [
        {
            "type": "Input.Rating",
            "id": "userRating",
            "label": "Rate this product",
            "max": 5,
            "isRequired": true,
            "errorMessage": "Please provide a rating"
        }
    ],
    "actions": [
        {
            "type": "Action.Submit",
            "title": "Submit"
        }
    ]
}
"""
```

#### TabSet with Multiple Tabs

```swift
let tabSetJSON = """
{
    "type": "AdaptiveCard",
    "version": "1.6",
    "body": [
        {
            "type": "TabSet",
            "tabs": [
                {
                    "id": "tab1",
                    "title": "Overview",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "Tab 1 content"
                        }
                    ]
                },
                {
                    "id": "tab2",
                    "title": "Details",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "Tab 2 content"
                        }
                    ]
                }
            ]
        }
    ]
}
"""
```

For more examples, see the test cards in [shared/test-cards/](../shared/test-cards/).

## Supported Elements

### Display Elements
- **TextBlock**: Rich text with markdown support
- **Image**: Images with sizing, styling (default/person), and async loading
- **Media**: Video/audio with poster image
- **RichTextBlock**: Inline formatted text with TextRun elements

### Container Elements
- **Container**: Groups elements with styling, padding, and vertical alignment
- **ColumnSet**: Multi-column layouts with flexible/weighted/fixed widths
- **Column**: Individual columns within ColumnSet
- **ImageSet**: Grid of images
- **FactSet**: Key-value pair display
- **ActionSet**: Button grouping
- **Table**: Tabular data with headers and grid lines

### Input Elements
- **Input.Text**: Single/multi-line text with validation (required, regex, maxLength)
- **Input.Number**: Numeric input with min/max constraints
- **Input.Date**: Date picker
- **Input.Time**: Time picker
- **Input.Toggle**: Boolean switch
- **Input.ChoiceSet**: Dropdown/radio/checkbox with compact/expanded/filtered styles
- **Input.Rating**: Interactive star picker with validation

### Advanced Elements
- **Carousel**: Swipeable pages with auto-advance timer, page indicators, and per-page actions
- **Accordion**: Collapsible panels with single or multi-expand modes
- **CodeBlock**: Code display with syntax highlighting, line numbers, and copy-to-clipboard
- **Rating**: Read-only star rating display with half-star support and review counts
- **ProgressBar**: Linear progress indicator with custom colors (hex or named)
- **Spinner**: Circular loading indicator with three sizes (small, medium, large)
- **TabSet**: Tab navigation with scrollable tab bar, icons, and multi-content areas

> **Note**: All advanced elements are fully accessible (VoiceOver, Dynamic Type) and responsive (iPhone/iPad). See [ACCESSIBILITY.md](ACCESSIBILITY.md) for details.

### Actions
- **Action.Submit**: Gather inputs and submit to delegate
- **Action.OpenUrl**: Open URL in browser
- **Action.ShowCard**: Toggle inline card visibility
- **Action.Execute**: Custom action with verb and data
- **Action.ToggleVisibility**: Show/hide elements by ID

## Architecture

### Module Structure

```
ACCore
├── Models (Codable data structures)
├── Parsing (JSON → AdaptiveCard)
└── HostConfig (Styling and theming)

ACAccessibility
├── VoiceOver support
├── Dynamic Type scaling
└── RTL layout mirroring

ACInputs
├── Input views (Text, Number, Date, Time, Toggle, ChoiceSet)
└── Validation (Required, regex, min/max)

ACActions
├── Action handlers (Submit, OpenUrl, Execute, etc.)
└── ActionDelegate protocol

ACRendering
├── Views (Element renderers)
├── Modifiers (Spacing, separator, containerStyle)
├── Registry (Custom renderers)
└── ViewModel (Card state management)
```

### Data Flow

```
JSON → CardParser → AdaptiveCard
                         ↓
              CardViewModel (ObservableObject)
                         ↓
              AdaptiveCardView (SwiftUI)
                         ↓
          Element/Input/Action Views
                         ↓
              ActionDelegate (Host app)
```

## Customization

### Registering Custom Element Renderers

```swift
import ACRendering
import ACCore

ElementRendererRegistry.shared.register("MyCustomType") { element in
    VStack {
        Text("Custom Element")
        // Your custom rendering logic
    }
}
```

### Registering Custom Action Renderers

```swift
ActionRendererRegistry.shared.register("MyCustomAction") { action in
    Button("Custom Action") {
        // Your custom action logic
    }
}
```

### Creating a Custom Action Handler

```swift
class CustomActionHandler: ActionHandler {
    func handle(
        _ action: CardAction,
        delegate: ActionDelegate?,
        viewModel: CardViewModel
    ) {
        switch action {
        case .submit(let submitAction):
            // Custom submit handling
            break
        default:
            // Fallback to default handler
            DefaultActionHandler().handle(action, delegate: delegate, viewModel: viewModel)
        }
    }
}

AdaptiveCardView(
    json: cardJSON,
    hostConfig: hostConfig,
    actionDelegate: delegate,
    actionHandler: CustomActionHandler()
)
```

## Input Validation

The SDK provides built-in validation for all input types:

- **Required fields**: `isRequired` property
- **Text validation**: `regex` and `maxLength`
- **Number validation**: `min` and `max`
- **Date/Time validation**: `min` and `max` ranges
- **Custom error messages**: `errorMessage` property

Example:

```json
{
    "type": "Input.Text",
    "id": "email",
    "label": "Email",
    "isRequired": true,
    "regex": "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$",
    "errorMessage": "Please enter a valid email address"
}
```

## Accessibility

### VoiceOver

All elements have appropriate accessibility labels and traits:

```swift
// Automatically applied by the SDK
.accessibilityElement(label: "Submit button")
.accessibilityAddTraits(.isButton)
```

### Dynamic Type

Text automatically scales with user's preferred text size:

```swift
// SDK handles Dynamic Type automatically
.dynamicTypeSize(for: .default, hostConfig: hostConfig)
```

### RTL Support

Layouts automatically mirror for right-to-left languages:

```swift
// Applied automatically based on environment
.environment(\.layoutDirection, .rightToLeft)
```

## Testing

### Running Tests

```bash
cd ios

# Run all tests
swift test

# Run specific test suite
swift test --filter ACTemplatingTests

# Run with verbose output
swift test --verbose
```

### Build from Command Line

```bash
cd ios

# Build all modules (debug)
swift build

# Build release configuration
swift build -c release

# Clean build artifacts
swift package clean
```

### Test Coverage

- **ACCore**: Parsing all 8 test cards, host config, round-trip encoding
- **ACInputs**: Validation for all input types
- **ACRendering**: Custom renderer registration
- **ACTemplating**: 40+ tests covering expression parsing, evaluation, and all 60 built-in functions

### Running the Sample App

1. Open `ios/Package.swift` in Xcode
2. Select the `AdaptiveCardsSample` scheme
3. Choose iPhone 17 Pro Simulator (or any iOS 16+ simulator)
4. Press Cmd+R to build and run
5. The app will display a card gallery with live rendering of Adaptive Cards

## Example Cards

See `/shared/test-cards/` for example cards:

- `simple-card.json`: Basic text and actions
- `input-form.json`: Form with various input types
- `container-columnset.json`: Layout examples
- `actions.json`: All action types
- `rich-content.json`: RichTextBlock, FactSet, ImageSet
- `all-inputs.json`: Every input type
- `table.json`: Table with headers and grid lines
- `media.json`: Video/audio media element

## Build Status (Verified 2026-02-12)

| Item | Status |
|------|--------|
| **Modules Built** | 11/11 |
| **Tests** | All passing |
| **Sample App** | Running on iPhone 17 Pro Simulator (iOS 26) |
| **Card Rendering** | Actual Adaptive Card content (not placeholders) |

### Recent Fixes
- **Rendering placeholder bug**: `ElementView`, `ImageView`, `CompoundButtonView`, `ProgressIndicatorViews`, `RatingDisplayView`, `TabSetView`, and `TableView` were displaying static placeholder text instead of actual card content. Fixed to render real data from parsed Adaptive Card JSON.
- **Access control**: Added `public` access modifiers to types, initializers, and methods across `ACActions`, `ACCore`, `ACRendering`, `ACMarkdown`, `ACCharts`, `ACFluentUI`, `ACInputs`, and `ACAccessibility` modules so the sample app can access SDK APIs.
- **ProgressBarView/SpinnerView consolidation**: Removed standalone `ProgressBarView.swift` and `SpinnerView.swift` in favor of the unified `ProgressIndicatorViews.swift`.
- **ExpressionEvaluator**: Updated expression evaluation logic in `ACTemplating`.
- **Package.swift**: Updated package manifest for module configuration.

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+ (Xcode 26 recommended)

## Performance

- Lazy loading for images via `AsyncImage`
- Efficient state management with `@Published` and `Combine`
- Minimal view re-renders with targeted `@State` updates

## Troubleshooting

### Card doesn't parse

Check the JSON format and schema version. Use `CardParser` error messages:

```swift
do {
    let card = try parser.parse(json)
} catch let error as CardParserError {
    print(error.errorDescription ?? "Unknown error")
}
```

### Actions not firing

Ensure you've implemented `ActionDelegate` and passed it to `AdaptiveCardView`.

### Inputs not validating

Validation runs on value change and on submit. Check `ValidationState` for errors:

```swift
@Environment(\.validationState) var validationState
if let error = validationState.getError(for: inputId) {
    Text(error).foregroundColor(.red)
}
```

### Cards show placeholder text instead of content

If you see generic text like "TextBlock element" or "Image element" instead of actual card content, ensure you are using the latest version of the rendering views. This was a known issue fixed in v1.1.0-dev where `ElementView` and related views were updated to render real data from parsed card JSON rather than static placeholder strings.

### "Cannot find type in scope" or access control errors

Ensure all SDK module types you reference have `public` access. If building a separate app target that imports the SDK modules, the types, initializers, and methods must be marked `public`. This was addressed in the v1.1.0-dev access control fixes.

## Contributing

Contributions are welcome! Please follow the existing code style and add tests for new features.

## License

MIT License - see LICENSE file for details.

## Resources

- [Adaptive Cards Documentation](https://adaptivecards.io)
- [Schema Explorer](https://adaptivecards.io/explorer/)
- [Designer Tool](https://adaptivecards.io/designer/)
- [Microsoft Teams Integration](https://docs.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-reference)

## Support

For issues and feature requests, please use the GitHub issue tracker.
