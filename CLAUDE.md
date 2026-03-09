# Claude Code Instructions

## Project Overview

Adaptive Cards Mobile SDK — cross-platform (iOS + Android) rendering library for Adaptive Cards v1.6. Strict feature parity between platforms is required.

- **Repo**: VikrantSingh01/AdaptiveCards-Mobile
- **Main branch**: `main`
- **Schema version**: Adaptive Cards v1.6
- **License**: MIT

## Project Structure

```
AdaptiveCards-Mobile/
├── android/          # Kotlin + Jetpack Compose (12 modules)
├── ios/              # Swift + SwiftUI (11 modules via SPM)
├── shared/           # Test cards, schema, scripts
├── docs/             # Architecture docs, guides
└── .github/          # CI workflows, PR template
```

### iOS Modules (Swift 5.9+, iOS 16+)

Build: `ios/Package.swift` (Swift Package Manager)

| Module | Purpose |
|---|---|
| ACCore | Card parsing, models, schema validation |
| ACRendering | SwiftUI views for card elements |
| ACInputs | Input element views |
| ACActions | Action handling |
| ACAccessibility | WCAG 2.1 AA helpers |
| ACTemplating | Template engine (60+ functions) |
| ACMarkdown | CommonMark rendering |
| ACCharts | Chart components |
| ACFluentUI | Fluent UI theming |
| ACCopilotExtensions | Copilot citations/streaming |
| ACTeams | Teams integration |

### Android Modules (Kotlin 1.9+, minSdk 26, compileSdk 34)

Build: `android/settings.gradle.kts` + `android/build.gradle.kts` (Gradle, JDK 17)

| Module | Purpose |
|---|---|
| ac-core | Card parsing, models, schema validation |
| ac-rendering | Compose composables |
| ac-inputs | Input composables |
| ac-actions | Action delegates |
| ac-host-config | Theme/config management |
| ac-accessibility | Accessibility semantics |
| ac-templating | Template engine (50+ functions) |
| ac-markdown | Markdown rendering |
| ac-charts | Chart components |
| ac-fluent-ui | Fluent UI theming |
| ac-copilot-extensions | Copilot features |
| ac-teams | Teams integration |

## Simulator / Emulator Rules

- **Never uninstall or remove** the sample app from simulators when restarting or killing them.
- When relaunching, only rebuild and install on top (preserves app data).
- Do **not** use `adb uninstall`, `xcrun simctl uninstall`, `adb shell pm clear`, or `simctl erase`.

### Simulator Targets

| Platform | Target | App ID |
|---|---|---|
| Android | AVD: `Medium_Phone_API_36.1` | `com.microsoft.adaptivecards.sample` (launch: `.MainActivity`) |
| iOS | Simulator: `iPhone 16e` | `com.microsoft.adaptivecards.sampleapp` |

## Build & Run Commands

### iOS

```bash
# Build library
cd ios && swift build

# Build sample app for simulator
xcodebuild -project ios/SampleApp.xcodeproj -scheme AdaptiveCardsSampleApp \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16e' build

# Install & launch sample app
xcrun simctl install "iPhone 16e" <derived-data-path>/AdaptiveCardsSampleApp.app
xcrun simctl launch "iPhone 16e" com.microsoft.adaptivecards.sampleapp
```

### Android

```bash
# Build & install sample app
cd android && ./gradlew :sample-app:installDebug

# Launch sample app
adb shell am start -n com.microsoft.adaptivecards.sample/.MainActivity
```

## Testing

### iOS

```bash
cd ios
swift test                              # All tests
swift test --filter ACCoreTests         # Single module
swift test --parallel --enable-code-coverage  # With coverage
```

Test targets: ACCoreTests, ACRenderingTests, ACInputsTests, ACTemplatingTests, ACMarkdownTests, ACChartsTests, IntegrationTests, VisualTests

### iOS Visual Snapshot Tests (REQUIRED for rendering changes)

```bash
cd ios && xcodebuild test \
  -scheme AdaptiveCards-Package \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16e' \
  -only-testing:VisualTests/CardElementSnapshotTests \
  CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

**Expected**: 10/10 tests pass. All baselines match within tolerance.

**Critical rules for snapshot rendering code:**
- Do NOT use `ScrollView` or `LazyVStack` in `PreParsedCardView` — they defeat `layer.render` snapshot capture
- Do NOT use `@StateObject` in snapshot views — SwiftUI lifecycle doesn't fire during `layer.render`
- Use `VStack` with synchronous `CardViewModel` property assignment
- `drawHierarchy` returns `false` in SPM XCTest — this is expected; `layer.render` fallback works
- Always include CodeSign flags: `CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`

**Recording baselines** (after rendering changes):
1. `touch ios/Tests/VisualTests/Snapshots/.record`
2. Run snapshot tests → records new baselines
3. `rm ios/Tests/VisualTests/Snapshots/.record`
4. Run again → verify mode (compare against baselines)
5. Commit updated `.png` baselines

### Android

```bash
cd android
./gradlew test                         # All tests
./gradlew :ac-core:test               # Single module
./gradlew testDebugUnitTest --stacktrace  # With stack traces
```

Test framework: JUnit 5 (Jupiter) with `useJUnitPlatform()`.

### Validation Scripts

```bash
bash shared/scripts/validate-test-cards.sh       # Validate test card JSON
bash shared/scripts/compare-schema-coverage.sh   # Check iOS/Android parity
```

### Test Cards

35+ JSON test cards in `shared/test-cards/` covering all element types, edge cases, templating, and actions. Both platforms use these as shared test fixtures.

## Linting

### iOS — SwiftLint

- Config: `ios/.swiftlint.yml`
- Run: `cd ios && swiftlint lint`
- CI: `swiftlint lint --strict --reporter github-actions-logging`
- Key limits: line 250/350, file 1000/1500, function body 300/500

### Android — ktlint

- Run: `cd android && ./gradlew ktlintCheck` or `./gradlew ktlintFormat`
- CI: not yet fully integrated

## Cross-Platform Parity

This is a core project requirement. When modifying rendering or schema support:

1. Implement on **both** iOS and Android
2. Update `SchemaValidator.swift` (iOS) and `SchemaValidator.kt` (Android) if adding element/action types
3. Add shared test card to `shared/test-cards/`
4. Update `docs/architecture/PARITY_MATRIX.md`
5. CI parity gate fails if element type count differs by > 2

### Adding a New Element/Action

- **iOS model**: `ios/Sources/ACCore/Models/`
- **iOS view**: `ios/Sources/ACRendering/Views/`
- **Android model**: `android/ac-core/src/main/kotlin/.../models/`
- **Android composable**: `android/ac-rendering/src/main/kotlin/.../composables/`
- **Schema**: `shared/schema/adaptive-card-schema-1.6.json`

## Git Conventions

### Branches

- `main` — stable release
- `feature/*` — new features
- `bugfix/*` — bug fixes
- `hotfix/*` — critical fixes
- `copilot/*` — AI-generated branches

### Commit Messages (Conventional Commits)

```
<type>(<scope>): <subject>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
Scopes: `ios`, `android`, `shared`, `ci`

## CI Workflows (`.github/workflows/`)

| Workflow | Trigger | Purpose |
|---|---|---|
| `parity-gate.yml` | Push/PR to main | iOS tests + Android tests + schema validation + parity check |
| `android-tests.yml` | Changes to `android/**` | Android unit tests + lint |
| `ios-tests.yml` | Changes to `ios/**` | iOS build + test with coverage |
| `lint.yml` | Push/PR | SwiftLint (iOS) + ktlint (Android) |
| `validate-test-cards.yml` | Push/PR | Validate shared test card JSON |
| `pr-checks.yml` | PR | Combined PR validation |

## Code Style

### Swift (iOS)

- Follow Swift API Design Guidelines
- Use `guard` for early exits, handle errors explicitly
- Document public APIs with `///` (DocC)
- Naming: PascalCase types, camelCase members

### Kotlin (Android)

- Follow Kotlin Coding Conventions
- Prefer `val` over `var`, use `Result` for error handling
- Document public APIs with KDoc (`/** */`)
- Packages: `com.microsoft.adaptivecards.<module>`

## Key File Paths (avoid searching for these)

### iOS Source Layout

```
ios/Sources/<Module>/          # e.g., ios/Sources/ACCore/
  ├── Models/                  # Data models
  ├── HostConfig/              # (ACCore only) host config
  ├── Parsing/                 # JSON parsing
  ├── Views/                   # (ACRendering) SwiftUI views
  └── SchemaValidator.swift    # (ACCore only)
```

### Android Source Layout

All Kotlin sources follow: `android/<module>/src/main/kotlin/com/microsoft/adaptivecards/<package>/`

```
android/ac-core/.../core/       → models/, parsing/, hostconfig/, viewmodel/
android/ac-rendering/.../rendering/ → composables/, modifiers/, registry/, viewmodel/
android/ac-inputs/.../inputs/   → composables/, validation/
```

### Schema Validators (update both when adding types)

- iOS: `ios/Sources/ACCore/SchemaValidator.swift`
- Android: `android/ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/SchemaValidator.kt`

### Local Environment Paths

- **Android SDK**: `$ANDROID_HOME` (typically `~/Library/Android/sdk` on macOS)
- **adb**: `$ANDROID_HOME/platform-tools/adb`
- **emulator**: `$ANDROID_HOME/emulator/emulator`
- **iOS DerivedData**: `~/Library/Developer/Xcode/DerivedData/SampleApp-*`
- **Gradle wrapper**: v8.5 (`android/gradle/wrapper/gradle-wrapper.properties`)

## Do Not Edit (generated / managed files)

- `android/**/build/` — Gradle build outputs
- `android/.gradle/` — Gradle cache
- `ios/.build/` — SPM build artifacts
- `ios/.swiftpm/` — SPM workspace state
- `*.xcodeproj/project.pbxproj` — managed by Xcode, avoid manual edits
- `DerivedData/` — Xcode build artifacts
- `docs/session-artifacts/` — generated session reports (gitignored)

## Module Dependency Graph

Understanding this avoids breaking imports:

```
ACCore (no deps)                  ac-core (no deps)
├─ ACTemplating                   ├─ ac-templating
├─ ACAccessibility                ├─ ac-accessibility
├─ ACMarkdown (no deps)           ├─ ac-markdown (no deps)
├─ ACFluentUI (no deps)           ├─ ac-fluent-ui (no deps)
├─ ACCharts → Core, FluentUI      ├─ ac-charts → core, fluent-ui
├─ ACInputs → Core, Accessibility ├─ ac-inputs → core, accessibility
├─ ACActions → Core, Accessibility├─ ac-actions → core, accessibility
├─ ACRendering → all above        ├─ ac-rendering → all above
├─ ACCopilotExtensions → Core     ├─ ac-copilot-extensions → core
└─ ACTeams → Core, Rendering      └─ ac-teams → core, rendering
```

## Common Pitfalls

- **Android tests use JUnit 5** — use `@Test` from `org.junit.jupiter.api`, not `org.junit`. All test tasks need `useJUnitPlatform()`.
- **iOS SampleApp excluded from SwiftLint** — `ios/.swiftlint.yml` excludes `SampleApp/`. Don't expect lint errors from sample app code.
- **Parity script uses grep on source** — `compare-schema-coverage.sh` greps `CardElement` enum (iOS) and `sealed interface` (Android) to count types. Renaming these breaks CI.
- **Shared test cards are bundled as assets** — Android `sample-app/build.gradle.kts` includes `../../shared/test-cards` as an asset source dir. Moving test cards breaks the Android build.
- **kotlinx-serialization** — Android models use `@Serializable` from kotlinx. iOS uses `Codable`. Don't mix up serialization approaches.
- **Compose + SwiftUI parity** — when adding UI, implement the Compose composable and SwiftUI view side-by-side. Don't finish one platform before starting the other.

## Security — URL Scheme Allowlist

All user-facing URLs (markdown links, OpenUrl actions, citations) are validated against an allowlist before rendering or opening. This prevents XSS, phishing, and open-redirect attacks from untrusted Adaptive Card JSON (GHSA-r5qq-54gp-7gcx).

### Allowed schemes

| Scheme | Purpose | Example |
|---|---|---|
| `http` | Standard web URL | `http://example.com` |
| `https` | Secure web URL | `https://example.com` |
| `mailto` | Email composition | `mailto:user@example.com` |
| `tel` | Phone dialer | `tel:+1234567890` |

### Blocked schemes (any scheme not in the allowlist)

| Scheme | Risk |
|---|---|
| `javascript:` | XSS — script execution in web view contexts |
| `data:` | XSS — inline HTML/script execution |
| `vbscript:` | Script execution (legacy) |
| `file:` | Local filesystem access |
| `ftp:` | Unencrypted file transfer |
| Custom app schemes | Unintended app launches, deep-link hijacking |

### Where validation is enforced

Validation happens at **both** the rendering layer (links are not made clickable) and the click handler (defense in depth):

| File | Layer |
|---|---|
| `ios/Sources/ACMarkdown/MarkdownRenderer.swift` | Rendering — `isSafeUrl()` |
| `android/.../markdown/MarkdownRenderer.kt` | Rendering — `isSafeUrl()` |
| `ios/Sources/ACActions/OpenUrlActionHandler.swift` | Action handler |
| `android/.../actions/ActionHandlers.kt` | Action handler |
| `android/.../markdown/MarkdownText.kt` | Click handler (defense in depth) |
| `android/.../rendering/composables/TextBlockView.kt` | Click handler (defense in depth) |
| `ios/Sources/ACCopilotExtensions/CitationView.swift` | Citation link rendering |

### Adding a new allowed scheme

If a new scheme needs to be supported, update **all 5 locations** where `allowedSchemes` / `ALLOWED_SCHEMES` is defined (grep for `allowedSchemes` or `ALLOWED_SCHEMES`) and add corresponding tests.
