# Cross-Platform Alignment Notes

## Naming and Design Convention Alignment

The iOS SDK should maintain naming and design conventions as close as possible to the Android SDK to ensure consistency across platforms.

## Current Status

- **iOS SDK**: Completed with Swift/SwiftUI implementation
- **Android SDK**: Not yet implemented

## Alignment Strategy

Once the Android SDK is implemented, review and align the following:

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

## Action Items

When Android SDK is implemented:

- [ ] Review Android module structure and align iOS if needed
- [ ] Ensure model classes have identical property names (accounting for language conventions)
- [ ] Align ViewModel interfaces and methods
- [ ] Match rendering pipeline concepts
- [ ] Synchronize host config property names
- [ ] Ensure test card structures are identical
- [ ] Document any intentional divergences with justification

## References

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
- [Android Jetpack Compose Guidelines](https://developer.android.com/jetpack/compose)
