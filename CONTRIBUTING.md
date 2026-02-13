# Contributing to Adaptive Cards Mobile SDK

Thank you for your interest in contributing to the Adaptive Cards Mobile SDK! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Cross-Platform Parity Requirements](#cross-platform-parity-requirements)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Style Guidelines](#style-guidelines)
- [Documentation](#documentation)

## Code of Conduct

This project follows the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). Be respectful and inclusive in all interactions.

## Getting Started

### Prerequisites

**For iOS Development**:
- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later
- CocoaPods or Swift Package Manager
- Git

**For Android Development**:
- Android Studio Hedgehog (2023.1.1) or later
- JDK 17 or later
- Kotlin 1.9 or later
- Android SDK 26+ (Oreo)
- Git

### Finding Issues to Work On

- Check the [issue tracker](https://github.com/VikrantSingh01/AdaptiveCards-Mobile/issues)
- Look for issues labeled `good first issue` for beginner-friendly tasks
- Issues labeled `help wanted` are great for contributors
- Comment on an issue to indicate you're working on it

## Development Setup

### iOS Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/VikrantSingh01/AdaptiveCards-Mobile.git
   cd AdaptiveCards-Mobile/ios
   ```

2. **Open in Xcode**:
   ```bash
   open Package.swift
   ```

3. **Build the project**:
   ```bash
   swift build
   ```

4. **Run tests**:
   ```bash
   swift test
   ```

### Android Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/VikrantSingh01/AdaptiveCards-Mobile.git
   cd AdaptiveCards-Mobile/android
   ```

2. **Open in Android Studio**:
   - Open Android Studio
   - Select "Open an Existing Project"
   - Navigate to `android/` directory

3. **Build the project**:
   ```bash
   ./gradlew build
   ```

4. **Run tests**:
   ```bash
   ./gradlew test
   ```

## Cross-Platform Parity Requirements

**The Adaptive Cards Mobile SDK maintains strict cross-platform parity.** All features must work identically on both iOS and Android.

### Key Principles

1. **Simultaneous Implementation**: New elements, actions, or features must be implemented on **both platforms** in the same PR or coordinated PRs.

2. **Schema Compliance**: All changes must comply with [Adaptive Cards v1.6 specification](https://adaptivecards.io/). See `docs/architecture/PARITY_TARGET.md` for details.

3. **Shared Test Cards**: Use test cards from `shared/test-cards/` to ensure consistent testing across platforms.

4. **Documentation**: Update `docs/architecture/PARITY_MATRIX.md` to track implementation status.

### Adding New Elements or Actions

When adding a new card element or action:

1. **iOS Implementation**:
   - Add model to `ios/Sources/ACCore/Models/`
   - Add view to `ios/Sources/ACRendering/Views/`
   - Update `SchemaValidator.swift` to include new type
   - Add tests to `ios/Tests/`

2. **Android Implementation**:
   - Add model to `android/ac-core/src/main/kotlin/.../models/`
   - Add composable to `android/ac-rendering/src/main/kotlin/.../composables/`
   - Update `SchemaValidator.kt` to include new type
   - Add tests to `android/ac-core/src/test/` and `android/ac-rendering/src/test/`

3. **Shared Test Card**:
   - Create JSON test card in `shared/test-cards/`
   - Validate with `shared/scripts/validate-test-cards.sh`

4. **Schema Update**:
   - Update `shared/schema/adaptive-card-schema-1.6.json` (if v1.6 feature)
   - Add round-trip serialization tests on both platforms

5. **Documentation**:
   - Update `docs/architecture/PARITY_MATRIX.md`
   - Update `shared/RENDERING_PARITY_CHECKLIST.md`
   - Add implementation notes

### Parity Validation

Before submitting a PR:

```bash
# Run schema coverage comparison
bash shared/scripts/compare-schema-coverage.sh

# This script checks:
# - Element types match between iOS and Android
# - Action types match between iOS and Android
# - No significant parity gaps (difference > 2)
```

### CI Parity Gate

The CI pipeline includes a parity gate that:
- Runs iOS tests
- Runs Android tests
- Validates test cards against v1.6 schema
- Compares schema coverage between platforms
- **Fails if either platform fails or significant gaps exist**

See `.github/workflows/parity-gate.yml` for details.

### Exceptions

In rare cases, platform-specific limitations may prevent exact parity:
- Document in `docs/architecture/PARITY_MATRIX.md`
- Add tests that demonstrate the limitation
- Mark status as ⚠️ Partial with notes

## Making Changes

### Branching Strategy

- `main` - Stable release branch
- `develop` - Active development branch
- `feature/*` - New feature branches
- `bugfix/*` - Bug fix branches
- `hotfix/*` - Critical production fixes

### Creating a Feature Branch

```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, etc.)
- `refactor` - Code refactoring
- `perf` - Performance improvements
- `test` - Test additions or changes
- `chore` - Build process or auxiliary tool changes

**Examples**:
```
feat(ios): add carousel element support

Implement carousel container with swipe gestures and
pagination indicators for iOS platform.

Closes #123
```

```
fix(android): resolve memory leak in card rendering

Fixed memory leak caused by retained references in
CompositionLocal providers.

Fixes #456
```

## Testing

### iOS Testing

**Run all tests**:
```bash
cd ios
swift test
```

**Run specific test**:
```bash
swift test --filter ACCoreTests
```

**Run with coverage**:
```bash
swift test --enable-code-coverage
```

**Run performance tests**:
```bash
swift test --filter PerformanceTests
```

### Android Testing

**Run all tests**:
```bash
cd android
./gradlew test
```

**Run specific module tests**:
```bash
./gradlew :ac-core:test
```

**Run with coverage**:
```bash
./gradlew testDebugUnitTestCoverage
```

### Test Requirements

- All new features must include unit tests
- Bug fixes should include regression tests
- Aim for >80% code coverage
- All tests must pass before submitting PR

## Submitting Changes

### Pull Request Process

1. **Update your branch**:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout your-branch
   git rebase develop
   ```

2. **Push your changes**:
   ```bash
   git push origin your-branch
   ```

3. **Create Pull Request**:
   - Go to GitHub repository
   - Click "New Pull Request"
   - Select `develop` as base branch
   - Fill out PR template completely

### PR Requirements

1. **Cross-Platform Parity** (for schema/rendering changes):
   - [ ] Changes implemented on both iOS and Android
   - [ ] Tests added for both platforms
   - [ ] SchemaValidator updated on both platforms (if new elements/actions)
   - [ ] PARITY_MATRIX.md updated to reflect current status
   - [ ] Shared test card added/updated in `shared/test-cards/` (if applicable)
   
2. **Code Quality**:
   - [ ] All tests pass (iOS: `swift test`, Android: `./gradlew test`)
   - [ ] Code follows style guidelines (see below)
   - [ ] No compiler warnings
   - [ ] Code review feedback addressed
   
3. **Documentation**:
   - [ ] Documentation is updated
   - [ ] CHANGELOG.md is updated (for significant changes)
   - [ ] Code comments added for complex logic
   
4. **CI Checks**:
   - [ ] Parity gate passes (both iOS and Android tests)
   - [ ] Lint checks pass
   - [ ] No merge conflicts
   
5. **Schema Compliance** (if adding new elements/actions):
   - [ ] Complies with Adaptive Cards v1.6 specification
   - [ ] Schema file updated (`shared/schema/adaptive-card-schema-1.6.json`)
   - [ ] Round-trip serialization tests pass
   - [ ] Unknown elements handled gracefully
   
6. **Optional but Recommended**:
   - [ ] Signed commits
   - [ ] Performance tested with large cards
   - [ ] Accessibility verified (VoiceOver/TalkBack)

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] Tested on iOS 16+
- [ ] Tested on Android API 26+

## Screenshots (if applicable)
Add screenshots of UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests pass locally
```

## Style Guidelines

### iOS (Swift)

Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

```swift
// Good
func parseCard(from json: String) throws -> AdaptiveCard {
    guard let data = json.data(using: .utf8) else {
        throw ParsingError.invalidJSON
    }
    return try JSONDecoder().decode(AdaptiveCard.self, from: data)
}

// Bad
func ParseCard(json: String) -> AdaptiveCard? {
    let data = json.data(using: .utf8)
    return try? JSONDecoder().decode(AdaptiveCard.self, from: data!)
}
```

**Key Points**:
- Use descriptive names
- Prefer clarity over brevity
- Use `guard` for early exits
- Handle errors explicitly
- Document public APIs with `///`

### Android (Kotlin)

Follow [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html):

```kotlin
// Good
fun parseCard(json: String): Result<AdaptiveCard> {
    return runCatching {
        Json.decodeFromString<AdaptiveCard>(json)
    }
}

// Bad
fun parseCard(json: String): AdaptiveCard? {
    return try {
        Json.decodeFromString<AdaptiveCard>(json)
    } catch (e: Exception) {
        null
    }
}
```

**Key Points**:
- Use meaningful names
- Prefer immutability (`val` over `var`)
- Use `Result` for error handling
- Leverage Kotlin idioms
- Document public APIs with KDoc

### Code Formatting

**iOS**: Use SwiftLint
```bash
cd ios
swiftlint lint
swiftlint autocorrect
```

**Android**: Use ktlint
```bash
cd android
./gradlew ktlintFormat
```

## Documentation

### Code Documentation

**iOS (Swift)**:
```swift
/// Parses an Adaptive Card from JSON string.
///
/// - Parameter json: The JSON string representing the card
/// - Returns: A parsed `AdaptiveCard` instance
/// - Throws: `ParsingError` if JSON is invalid
public func parseCard(from json: String) throws -> AdaptiveCard {
    // Implementation
}
```

**Android (Kotlin)**:
```kotlin
/**
 * Parses an Adaptive Card from JSON string.
 *
 * @param json The JSON string representing the card
 * @return A parsed AdaptiveCard instance
 * @throws JsonException if JSON is invalid
 */
fun parseCard(json: String): AdaptiveCard {
    // Implementation
}
```

### Markdown Documentation

- Update relevant README files
- Add examples for new features
- Update architecture docs if structure changes
- Keep documentation in sync with code

## Project Structure

### iOS
```
ios/
├── Package.swift           # SPM manifest
├── Sources/
│   ├── ACCore/            # Core models
│   ├── ACRendering/       # SwiftUI rendering
│   ├── ACInputs/          # Input elements
│   └── ...
├── Tests/
│   ├── ACCoreTests/       # Unit tests
│   └── ...
└── README.md
```

### Android
```
android/
├── settings.gradle.kts     # Module configuration
├── ac-core/               # Core models
├── ac-rendering/          # Compose rendering
├── ac-inputs/             # Input elements
└── ...
```

## Release Process

1. Update version in `Package.swift` (iOS) and `gradle.properties` (Android)
2. Update `CHANGELOG.md`
3. Create release branch: `release/v1.x.x`
4. Run full test suite
5. Create and push tag: `git tag v1.x.x`
6. GitHub Actions will build and publish artifacts

## Getting Help

- **Questions**: Open a [Discussion](https://github.com/VikrantSingh01/AdaptiveCards-Mobile/discussions)
- **Bugs**: Open an [Issue](https://github.com/VikrantSingh01/AdaptiveCards-Mobile/issues)
- **Security**: See [SECURITY.md](SECURITY.md)

## Recognition

Contributors will be acknowledged in:
- Release notes
- CHANGELOG.md
- GitHub contributors page

Thank you for contributing! 🎉
