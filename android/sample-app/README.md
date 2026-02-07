# Adaptive Cards Android Sample App

A comprehensive Jetpack Compose sample application demonstrating the Adaptive Cards Mobile SDK for Android.

## Features

### 📱 Card Gallery
- Browse all test cards by category
- Search and filter functionality
- Categories: Basic, Inputs, Actions, Containers, Advanced, Teams, Templating
- Material Design 3 UI

### ✏️ Card Editor
- Live JSON editor with syntax validation
- Real-time preview
- Tab-based navigation (Editor/Preview)
- Format JSON with one tap
- Load sample cards
- Copy JSON functionality

### 💬 Teams Simulator
- Teams-style chat interface
- Send text messages and cards
- Multiple card templates (simple, form, chart)
- Material Design chat bubbles with timestamps
- Action handling within chat context

### 📊 Performance Dashboard
- Parse time metrics (avg, min, max)
- Render time metrics (avg, min, max)
- Memory usage tracking
- Action success rate monitoring
- Start/stop recording
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
- Android Studio Hedgehog (2023.1.1) or later
- Android SDK 26 (Oreo) or higher
- Kotlin 1.9+
- Gradle 8.0+

### Build Steps

1. **Open the Project**:
   ```bash
   cd android
   ./gradlew clean
   ```

2. **Sync Gradle**:
   - Open `android/` in Android Studio
   - Wait for Gradle sync to complete

3. **Build the Sample App**:
   ```bash
   ./gradlew :sample-app:assembleDebug
   ```

4. **Install on Device/Emulator**:
   ```bash
   ./gradlew :sample-app:installDebug
   ```

   Or use Android Studio's Run button

### Alternative: Command Line Only

```bash
# Build APK
./gradlew :sample-app:assembleDebug

# Install to connected device
adb install -r sample-app/build/outputs/apk/debug/sample-app-debug.apk
```

## Project Structure

```
android/sample-app/
├── build.gradle.kts           # App-level build configuration
├── src/main/
│   ├── kotlin/com/microsoft/adaptivecards/sample/
│   │   ├── MainActivity.kt                    # Main activity with navigation
│   │   ├── CardGalleryScreen.kt               # Card gallery UI
│   │   ├── CardDetailScreen.kt                # Card detail view
│   │   ├── CardEditorScreen.kt                # JSON editor
│   │   ├── TeamsSimulatorScreen.kt            # Teams chat UI
│   │   ├── ActionLogScreen.kt                 # Action log viewer
│   │   ├── SettingsScreen.kt                  # App settings
│   │   ├── PerformanceDashboardScreen.kt      # Performance metrics
│   │   └── ui/theme/Theme.kt                  # Material theme
│   └── assets/test-cards/                     # Test card JSON files
└── README.md                                  # This file
```

## Dependencies

The sample app depends on all SDK modules:

- `ac-core` - Core data models and parsing
- `ac-rendering` - Card rendering engine
- `ac-inputs` - Input elements
- `ac-actions` - Action handling
- `ac-accessibility` - Accessibility support
- `ac-templating` - Template binding
- `ac-markdown` - Markdown rendering
- `ac-charts` - Chart components
- `ac-fluent-ui` - Fluent UI theming
- `ac-copilot-extensions` - Copilot features
- `ac-teams` - Teams-specific features
- `ac-host-config` - Host configuration

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
3. Switch to preview tab to see results
4. Use menu to format JSON or load samples
5. Real-time validation shows errors

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

- **Jetpack Compose**: Modern declarative UI
- **Material Design 3**: Latest design system
- **State management**: `remember` and `mutableStateOf`
- **Navigation**: Navigation Compose
- **Performance**: Efficient rendering and memory usage

## Customization

### Adding Custom Cards

1. Add `.json` file to `src/main/assets/test-cards/`
2. Update `TestCardLoader.loadAllCards()` with card metadata
3. Rebuild and the card appears in the gallery

### Styling

Modify `Theme.kt` to customize:
- Color schemes (light/dark)
- Typography
- Shapes
- Component styles

### Action Handling

Extend `ActionLogState` to:
- Send actions to external APIs
- Trigger native behaviors
- Log to analytics

## Troubleshooting

### Build Errors

**"Could not resolve dependency"**
- Ensure all SDK modules are built first
- Run `./gradlew clean build` from android root
- Check `settings.gradle.kts` includes all modules

**"Resource not found"**
- Verify test cards are in assets folder
- Check `build.gradle.kts` includes assets

### Runtime Issues

**Cards not rendering**
- Check JSON validity in Editor tab
- View error messages in Action Log
- Enable Performance Metrics in Settings

**Slow performance**
- Check Performance Dashboard for bottlenecks
- Test on physical device vs. emulator
- Enable R8/ProGuard for release builds

## Testing

Run unit tests:
```bash
./gradlew :sample-app:testDebugUnitTest
```

Run instrumentation tests:
```bash
./gradlew :sample-app:connectedAndroidTest
```

## Contributing

To extend this sample app:

1. Follow Material Design 3 guidelines
2. Maintain Compose best practices
3. Add comprehensive error handling
4. Update this README with new features

## License

See the main repository LICENSE file.
