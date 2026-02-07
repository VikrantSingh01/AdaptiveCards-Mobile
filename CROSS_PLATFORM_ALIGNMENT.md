# Cross-Platform Alignment Notes

## Naming and Design Convention Alignment

The iOS and Android SDKs maintain naming and design conventions as close as possible to ensure consistency across platforms while respecting platform idioms.

## Current Status (Updated: February 7, 2026)

- **iOS SDK**: ✅ Fully implemented with Swift/SwiftUI (including advanced elements)
- **Android SDK**: ✅ Fully implemented with Kotlin/Jetpack Compose (including advanced elements)
- **Alignment Status**: ✅ COMPLETE - Both platforms have feature parity

## Alignment Verification

Both platforms have been implemented and verified for alignment:

### 1. Module Names
- iOS uses: `ACCore`, `ACRendering`, `ACInputs`, `ACActions`, `ACAccessibility`
- Android should use equivalent naming (e.g., `ac-core`, `ac-rendering`, etc.)

### 2. Class/Type Names
- Model classes (AdaptiveCard, CardElement, etc.)
- View/Composable names
- Handler and delegate patterns

### 3. API Surface
- Public methods and their signatures
- Initialization patterns
- Callback/delegate naming

### 4. Architecture Patterns
- iOS uses: MVVM with SwiftUI
- Android should use: MVVM/MVI with Jetpack Compose
- Ensure ViewModel concepts align where possible

### 5. Package Structure
```
iOS:                          Android (proposed):
ACCore/                       ac-core/
  Models/                       models/
  Parsing/                      parsing/
  HostConfig/                   hostconfig/
ACRendering/                  ac-rendering/
  Views/                        composables/
  ViewModel/                    viewmodel/
  ...                           ...
```

## Platform-Specific Differences to Accept

Some differences are acceptable due to platform idioms:

1. **Language Conventions**:
   - Swift: camelCase, PascalCase
   - Kotlin: camelCase, PascalCase (similar)

2. **UI Frameworks**:
   - iOS: SwiftUI Views with `View` protocol
   - Android: Jetpack Compose with `@Composable` functions

3. **Dependency Injection**:
   - iOS: Environment objects, property wrappers
   - Android: Hilt/Koin or similar

4. **Async Patterns**:
   - iOS: Combine, async/await
   - Android: Coroutines, Flow

## Completed Alignment Items

Both platforms implemented and aligned:

- [x] ✅ Reviewed module structure - Both aligned (ACCore/ac-core, ACRendering/ac-rendering, etc.)
- [x] ✅ Model classes have identical property names (e.g., `pages`, `timer`, `expandMode`, `code`)
- [x] ✅ ViewModel interfaces aligned (parseCard, setInputValue, gatherInputValues, etc.)
- [x] ✅ Rendering pipeline concepts match (ElementView/RenderElement)
- [x] ✅ Host config property names synchronized
- [x] ✅ Test card structures identical (7 shared test cards in shared/test-cards/)
- [x] ✅ Documented intentional divergences (see Cross-Platform Implementation Review)

## Advanced Elements Alignment (NEW)

**8 Advanced Elements Implemented on Both Platforms:**

| Element | Android Type | iOS Type | Property Alignment | Status |
|---------|--------------|----------|-------------------|--------|
| Carousel | `Carousel` | `Carousel` | ✅ Perfect match | ✅ Complete |
| Accordion | `Accordion` | `Accordion` | ✅ Perfect match | ✅ Complete |
| CodeBlock | `CodeBlock` | `CodeBlock` | ✅ Perfect match | ✅ Complete |
| RatingDisplay | `RatingDisplay` | `RatingDisplay` | ✅ Perfect match | ✅ Complete |
| RatingInput | `RatingInput` | `RatingInput` | ✅ Perfect match | ✅ Complete |
| ProgressBar | `ProgressBar` | `ProgressBar` | ✅ Perfect match | ✅ Complete |
| Spinner | `Spinner` | `Spinner` | ✅ Perfect match | ✅ Complete |
| TabSet | `TabSet` | `TabSet` | ✅ Perfect match | ✅ Complete |

All advanced elements share:
- Identical JSON schema
- Identical property names
- Equivalent functionality
- Same accessibility features
- Responsive design patterns
- Comprehensive test coverage

## References

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
- [Android Jetpack Compose Guidelines](https://developer.android.com/jetpack/compose)
