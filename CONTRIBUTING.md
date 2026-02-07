# Contributing to Adaptive Cards Mobile SDK

Thank you for your interest in contributing to the Adaptive Cards Mobile SDK! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
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

4. **PR Requirements**:
   - [ ] All tests pass
   - [ ] Code follows style guidelines
   - [ ] Documentation is updated
   - [ ] CHANGELOG.md is updated (for significant changes)
   - [ ] No merge conflicts
   - [ ] Signed commits (optional but recommended)

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
