# Adaptive Cards iOS Sample App

A comprehensive SwiftUI sample application demonstrating the Adaptive Cards Mobile SDK for iOS.

## Features

### 📱 Card Gallery
- Browse all test cards by category
- Search and filter functionality
- Categories: Basic, Inputs, Actions, Containers, Advanced, Teams, Templating
- Visual category badges

### ✏️ Card Editor
- Live JSON editor with syntax validation
- Real-time preview
- Split-view and single-view modes
- Format JSON with one tap
- Load sample cards
- Copy JSON to clipboard

### 💬 Teams Simulator
- Teams-style chat interface
- Send text messages and cards
- Multiple card templates (simple, form, chart)
- Chat bubble UI with timestamps
- Action handling within chat context

### 📊 Performance Dashboard
- Parse time metrics (avg, min, max)
- Render time metrics (avg, min, max)
- Memory usage tracking
- Action success rate monitoring
- Export performance reports

### 🎨 Settings
- Theme selection (Light, Dark, System)
- Font scale adjustment (80% - 150%)
- Accessibility toggles
- Developer options
- SDK version info

### 📝 Action Log
- Complete history of all dispatched actions
- Search and filter actions
- Detailed action inspection
- Export action log
- JSON payload viewing

## Building the App

### Prerequisites
- Xcode 15.0 or later
- iOS 16.0+ target device or simulator
- Swift 5.9+

### Build Steps

1. **Open the Package**:
   ```bash
   cd ios
   open Package.swift
   ```

2. **Add Sample App Target to Xcode**:
   - In Xcode, add a new target for the sample app
   - Select "iOS App" template
   - Name: "AdaptiveCardsSample"
   - Interface: SwiftUI
   - Language: Swift

3. **Link SDK Modules**:
   Add the following dependencies to your app target:
   - ACCore
   - ACRendering
   - ACInputs
   - ACActions
   - ACMarkdown
   - ACCharts
   - ACFluentUI
   - ACCopilotExtensions
   - ACTeams

4. **Copy Sample App Files**:
   Copy all `.swift` files from `ios/SampleApp/` to your Xcode project

5. **Add Test Cards as Resources**:
   - Add `shared/test-cards/` folder to your app target
   - Ensure "Copy Bundle Resources" includes all `.json` files

6. **Build and Run**:
   - Select your target device or simulator
   - Press ⌘R or click Run

### Alternative: Using Swift Package Manager

Create a standalone app:

```swift
// Package.swift
let package = Package(
    name: "AdaptiveCardsSample",
    platforms: [.iOS(.v16)],
    dependencies: [
        .package(path: "../")
    ],
    targets: [
        .executableTarget(
            name: "AdaptiveCardsSample",
            dependencies: [
                .product(name: "ACCore", package: "AdaptiveCards"),
                .product(name: "ACRendering", package: "AdaptiveCards"),
                // ... other modules
            ],
            resources: [.copy("Resources/test-cards")]
        )
    ]
)
```

## Usage

### Exploring Cards

1. Launch the app
2. Navigate to the **Gallery** tab
3. Browse cards by category or use search
4. Tap any card to view details
5. View JSON payload and action log
6. Check parse/render performance metrics

### Editing Cards

1. Navigate to the **Editor** tab
2. Type or paste JSON in the editor pane
3. See live preview update automatically
4. Toggle between split-view and tab view
5. Use "Format JSON" to prettify
6. Load sample cards from the menu

### Testing in Teams Context

1. Navigate to the **Teams** tab
2. Send text messages or cards
3. Use the + button to send pre-built cards
4. Interact with cards in chat bubbles
5. View action results in the Action Log

### Monitoring Performance

1. Navigate to **More** → **Performance**
2. View real-time metrics
3. Start/stop recording for detailed analysis
4. Export reports for sharing

## Architecture

The sample app demonstrates:

- **SwiftUI best practices**: Modern declarative UI
- **MVVM pattern**: Clear separation of concerns
- **State management**: `@StateObject` and `@EnvironmentObject`
- **Navigation**: NavigationStack and TabView
- **Performance**: Efficient rendering and memory usage

## Customization

### Adding Custom Cards

1. Add `.json` file to `shared/test-cards/`
2. Update `TestCardLoader.loadAllCards()` with card metadata
3. Rebuild and the card appears in the gallery

### Styling

Modify `AppSettings` to add:
- Custom color schemes
- Font families
- Layout options
- Animation preferences

### Action Handling

Extend `ActionLogStore` to:
- Send actions to external APIs
- Trigger native behaviors
- Log to analytics

## Troubleshooting

### Build Errors

**"Cannot find module 'ACCore'"**
- Ensure all SDK modules are properly linked
- Clean build folder (⌘⇧K) and rebuild

**"Resource not found"**
- Verify test cards are in app bundle
- Check "Copy Bundle Resources" build phase

### Runtime Issues

**Cards not rendering**
- Check JSON validity in Editor tab
- View error messages in Action Log
- Enable Performance Metrics in Settings

**Slow performance**
- Check Performance Dashboard for bottlenecks
- Reduce font scale in Settings
- Test on physical device vs. simulator

## Contributing

To extend this sample app:

1. Follow SwiftUI and iOS best practices
2. Maintain accessibility support
3. Add comprehensive error handling
4. Update this README with new features

## License

See the main repository LICENSE file.
