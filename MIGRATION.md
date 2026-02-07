# Migration Guide

This guide helps you migrate from the legacy Adaptive Cards SDK to the new mobile-optimized SDK.

## Overview

The new SDK provides:
- ✅ Modern UI frameworks (SwiftUI, Jetpack Compose)
- ✅ Modular architecture for smaller app size
- ✅ Enhanced performance and memory efficiency
- ✅ Better accessibility support
- ✅ Complete Adaptive Cards 1.5 support
- ✅ Improved developer experience

## Breaking Changes

### Architecture

#### Legacy SDK
- Monolithic UIKit/View-based rendering
- Tight coupling between parsing and rendering
- Limited customization options

#### New SDK
- Modular packages/libraries
- Clean separation of concerns
- Extensive customization via host config

### Platform Requirements

| Platform | Legacy SDK | New SDK |
|----------|-----------|---------|
| iOS | iOS 11+ | **iOS 16+** |
| Android | API 21+ | **API 26+** |
| Swift | 4.2+ | **5.9+** |
| Kotlin | 1.4+ | **1.9+** |

## Migration Steps

### iOS Migration

#### 1. Update Dependencies

**Before (CocoaPods)**:
```ruby
pod 'AdaptiveCards', '~> 2.8'
```

**After (Swift Package Manager)**:
```swift
dependencies: [
    .package(url: "https://github.com/VikrantSingh01/AdaptiveCards-Mobile", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "ACCore", package: "AdaptiveCards-Mobile"),
            .product(name: "ACRendering", package: "AdaptiveCards-Mobile"),
        ]
    )
]
```

#### 2. Update Imports

**Before**:
```swift
import AdaptiveCards
```

**After**:
```swift
import ACCore
import ACRendering
```

#### 3. Rendering Cards

**Before (UIKit)**:
```swift
let cardView = ACRView(frame: bounds, card: card, hostConfig: hostConfig, target: self)
view.addSubview(cardView)
```

**After (SwiftUI)**:
```swift
struct ContentView: View {
    let card: AdaptiveCard
    
    var body: some View {
        AdaptiveCardView(card: card, hostConfig: .default) { action in
            handleAction(action)
        }
    }
}
```

#### 4. Action Handling

**Before**:
```swift
extension MyViewController: ACRActionDelegate {
    func didFetchUserResponses(_ card: ACOAdaptiveCard!, 
                               action: ACOBaseActionElement!) {
        // Handle action
    }
}
```

**After**:
```swift
AdaptiveCardView(card: card) { action in
    switch action {
    case .submit(let data):
        handleSubmit(data)
    case .openUrl(let url):
        UIApplication.shared.open(url)
    default:
        break
    }
}
```

#### 5. Custom Styling

**Before**:
```swift
let hostConfig = ACOHostConfig()
hostConfig.setFontFamily(.body, fontFamily: "SF Pro")
hostConfig.setFontSize(.default, fontSize: 14)
```

**After**:
```swift
var hostConfig = HostConfig.default
hostConfig.fontFamily = "SF Pro"
hostConfig.fontSize = .medium
hostConfig.spacing = .default
```

### Android Migration

#### 1. Update Dependencies

**Before (Gradle)**:
```kotlin
dependencies {
    implementation("io.adaptivecards:adaptivecards-android:2.8.0")
}
```

**After (Gradle)**:
```kotlin
dependencies {
    implementation("com.microsoft.adaptivecards:ac-core:1.0.0")
    implementation("com.microsoft.adaptivecards:ac-rendering:1.0.0")
}
```

#### 2. Update Imports

**Before**:
```kotlin
import io.adaptivecards.objectmodel.AdaptiveCard
import io.adaptivecards.renderer.AdaptiveCardRenderer
```

**After**:
```kotlin
import com.microsoft.adaptivecards.core.AdaptiveCard
import com.microsoft.adaptivecards.rendering.AdaptiveCardComposable
```

#### 3. Rendering Cards

**Before (View-based)**:
```kotlin
val cardView = AdaptiveCardRenderer.getInstance().render(
    context,
    fragmentManager,
    adaptiveCard,
    cardActionHandler,
    hostConfig
)
linearLayout.addView(cardView)
```

**After (Jetpack Compose)**:
```kotlin
@Composable
fun CardScreen(card: AdaptiveCard) {
    AdaptiveCardComposable(
        card = card,
        hostConfig = HostConfig.Default,
        onAction = { action ->
            handleAction(action)
        }
    )
}
```

#### 4. Action Handling

**Before**:
```kotlin
val cardActionHandler = object : BaseCardElementRenderer() {
    override fun onAction(action: BaseActionElement, renderedCard: RenderedAdaptiveCard) {
        when (action) {
            is SubmitAction -> handleSubmit(action.getDataJson())
        }
    }
}
```

**After**:
```kotlin
AdaptiveCardComposable(
    card = card,
    onAction = { action ->
        when (action) {
            is Action.Submit -> handleSubmit(action.data)
            is Action.OpenUrl -> openUrl(action.url)
            else -> {}
        }
    }
)
```

#### 5. Custom Styling

**Before**:
```kotlin
val hostConfig = HostConfig().apply {
    setFontFamily(FontType.Default, "Roboto")
    setFontSize(FontSize.Default, 14)
}
```

**After**:
```kotlin
val hostConfig = HostConfig.Default.copy(
    fontFamily = "Roboto",
    fontSize = FontSize.Medium,
    spacing = Spacing.Default
)
```

## Feature Mapping

### Elements

| Legacy Name | New Name | Notes |
|-------------|----------|-------|
| `TextBlock` | `TextBlock` | Same, enhanced styling options |
| `Image` | `Image` | Added themed variants support |
| `Container` | `Container` | Same |
| `ColumnSet` | `ColumnSet` | Same |
| `FactSet` | `FactSet` | Same |
| N/A | `List` | ✨ New: Advanced list container |
| N/A | `Carousel` | ✨ New: Image carousel |
| N/A | `Accordion` | ✨ New: Collapsible sections |
| N/A | `TabSet` | ✨ New: Tabbed content |
| N/A | `Table` | ✨ New: Data tables |
| N/A | `DataGrid` | ✨ New: Advanced data grid |

### Inputs

| Legacy Name | New Name | Changes |
|-------------|----------|---------|
| `Input.Text` | `Input.Text` | Enhanced validation |
| `Input.Number` | `Input.Number` | Same |
| `Input.Date` | `Input.Date` | Same |
| `Input.Time` | `Input.Time` | Same |
| `Input.Toggle` | `Input.Toggle` | Same |
| `Input.ChoiceSet` | `Input.ChoiceSet` | Enhanced styling |

### Actions

| Legacy Name | New Name | Changes |
|-------------|----------|---------|
| `Action.OpenUrl` | `Action.OpenUrl` | Same |
| `Action.Submit` | `Action.Submit` | Enhanced data collection |
| `Action.ShowCard` | `Action.ShowCard` | Same |
| `Action.ToggleVisibility` | `Action.ToggleVisibility` | Same |
| N/A | `Action.Execute` | ✨ New: Custom command execution |
| N/A | `CompoundButton` | ✨ New: Multi-action buttons |
| N/A | `SplitButton` | ✨ New: Split action buttons |
| N/A | `PopoverAction` | ✨ New: Popover menus |

## Common Migration Issues

### Issue 1: Card Not Rendering

**Problem**: Card appears blank or doesn't render

**Solution**: Ensure you're using the correct rendering method for your UI framework
```swift
// iOS - Use SwiftUI View
AdaptiveCardView(card: card, hostConfig: .default)

// Android - Use Composable
AdaptiveCardComposable(card = card, hostConfig = HostConfig.Default)
```

### Issue 2: Actions Not Firing

**Problem**: Button actions don't trigger callbacks

**Solution**: Ensure action handler is properly connected
```swift
// iOS
AdaptiveCardView(card: card) { action in
    print("Action: \(action)")  // Add logging
    handleAction(action)
}

// Android
AdaptiveCardComposable(
    card = card,
    onAction = { action ->
        Log.d("Card", "Action: $action")  // Add logging
        handleAction(action)
    }
)
```

### Issue 3: Styling Not Applied

**Problem**: Custom host config doesn't affect card appearance

**Solution**: Verify host config is passed correctly and uses new API
```swift
// iOS
var config = HostConfig.default
config.fontFamily = "CustomFont"
config.accentColor = .blue

AdaptiveCardView(card: card, hostConfig: config)

// Android
val config = HostConfig.Default.copy(
    fontFamily = "CustomFont",
    accentColor = Color.Blue
)
AdaptiveCardComposable(card = card, hostConfig = config)
```

### Issue 4: Performance Issues

**Problem**: Slow rendering or high memory usage

**Solution**:
1. Use modular imports (import only what you need)
2. Enable caching for repeated cards
3. Profile with the built-in performance dashboard

```swift
// iOS - Use specific modules
import ACCore  // Just core models
import ACRendering  // Just rendering

// Android - Use specific dependencies
implementation("com.microsoft.adaptivecards:ac-core:1.0.0")
implementation("com.microsoft.adaptivecards:ac-rendering:1.0.0")
```

## Testing Your Migration

### Validation Checklist

- [ ] All cards render correctly in light mode
- [ ] All cards render correctly in dark mode
- [ ] All input elements are functional
- [ ] All actions trigger expected behavior
- [ ] Custom styling is applied correctly
- [ ] Accessibility features work (VoiceOver/TalkBack)
- [ ] Performance is acceptable (parse < 5ms, render < 10ms)
- [ ] Memory usage is within limits
- [ ] Error handling works for invalid cards
- [ ] Network images load correctly

### Test Cards

Use the included test cards in `shared/test-cards/` to validate:
- `simple-text.json` - Basic rendering
- `all-inputs.json` - Input validation
- `all-actions.json` - Action handling
- `containers.json` - Layout
- `advanced-combined.json` - Complex scenarios

## Getting Help

### Resources
- 📖 [iOS Documentation](ios/README.md)
- 📖 [Android Documentation](android/README.md)
- 📖 [API Reference](CONTRIBUTING.md)
- 💬 [GitHub Discussions](https://github.com/VikrantSingh01/AdaptiveCards-Mobile/discussions)
- 🐛 [Issue Tracker](https://github.com/VikrantSingh01/AdaptiveCards-Mobile/issues)

### Support

If you encounter issues during migration:
1. Check this guide for solutions
2. Review the sample apps for working examples
3. Search existing GitHub issues
4. Create a new issue with:
   - Legacy SDK version
   - New SDK version
   - Minimal reproduction code
   - Error messages/logs

## Timeline Recommendations

| App Complexity | Estimated Migration Time |
|----------------|-------------------------|
| Simple (1-5 card types) | 1-2 days |
| Medium (6-15 card types) | 3-5 days |
| Complex (15+ card types, custom elements) | 1-2 weeks |

Plan for additional time to test thoroughly across devices and OS versions.
