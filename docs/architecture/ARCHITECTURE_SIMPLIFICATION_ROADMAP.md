# Architecture Simplification Roadmap

## Context

The AdaptiveCards-Mobile SDK needs to integrate into the Teams client (and other Microsoft hosts) with **minimal changes to Teams code**. Where changes are unavoidable, the SDK itself provides adapter code that maps the new API to patterns Teams already uses. Teams should not need to make breaking changes unless there is a clear architectural reason (e.g., the old pattern is fundamentally incompatible with SwiftUI/Compose).

This plan designs the best possible public API from first principles, then provides a **compatibility layer** shipped as part of the SDK so that Teams can adopt incrementally.

---

## Guiding Principles

1. **Progressive disclosure** — 1 line to render a card, 5 lines for production, 15 for full control
2. **SDK is a rendering engine** — host owns lifecycle, SDK owns pixels
3. **Platform-native idioms** — SwiftUI modifiers, Compose CompositionLocal
4. **Zero-breaking-change integration** for Teams — adapters bridge old patterns to new internals
5. **One concept, one type** — no parallel abstractions for the same concern
6. **Cross-platform naming parity** — identical type names where they appear in host code
7. **Testability without rendering** — all host-facing logic testable without a view hierarchy

---

## Architectural Pillars

These are not features or phases — they are **cross-cutting concerns** that every component of the SDK must satisfy. Every PR, every design decision, every API surface is evaluated against these pillars.

### Pillar 1: Performance

A chat app renders hundreds of cards in a scroll session. The SDK must be fast by default, without the host tuning anything.

**Budgets** (measured on iPhone 14 / Pixel 7, mid-range devices):

| Operation | Budget | Current | Notes |
|---|---|---|---|
| Parse (cold, simple card) | < 5 ms | ~3 ms | Must stay under 5 ms |
| Parse (cache hit) | < 0.1 ms | ~0 ms | NSCache/LruCache lookup |
| Template expansion | < 10 ms | ~5 ms | 60+ expression functions |
| First render (simple card) | < 16 ms (1 frame) | Not measured | Must not drop frames |
| First render (complex card, 50+ elements) | < 50 ms (3 frames) | Not measured | Graceful degradation |
| Image load (cache hit, memory) | < 1 ms | N/A (no image cache) | **Gap — must add** |
| Image load (cache hit, disk) | < 10 ms | N/A (no image cache) | **Gap — must add** |
| Scroll through 100 cards | 60 fps sustained | Not measured | No jank allowed |
| Memory per card (rendered) | < 2 MB | Not measured | Including images |

**Mechanisms** (built into the SDK, not opt-in):

- **Multi-layer caching**: Parse → Template → Image, all cached by default (see `CardCache`)
- **Prefetch API**: `AdaptiveCards.prefetch()` pre-parses and pre-warms image cache ahead of scroll
- **Rendering guardrails**: Element count cap, nesting depth limit, image concurrency throttle, parse timeout
- **Lazy rendering**: Elements below the fold are lazily composed (SwiftUI `LazyVStack` / Compose `LazyColumn`)
- **Image throttling**: Max 6 concurrent image loads per card, placeholder shown during load
- **Background parsing**: Parse and template expansion always on background thread, never block main

### Pillar 2: Reliability

Cards come from untrusted sources (bot developers, third-party connectors). The SDK must never crash, never hang, and always show something.

**Invariants**:

| Invariant | Mechanism |
|---|---|
| Never crash on malformed JSON | `CardElement.unknown(type:)` fallback, graceful decoder with `decodeIfPresent` everywhere |
| Never crash on unknown element types | Unknown types render as `EmptyView` (release) or debug placeholder |
| Never hang on pathological cards | Parse timeout (2s), element count cap (200), nesting depth limit (10) |
| Never hang on slow/unreachable images | Image timeout (10s), placeholder shown immediately, loads don't block rendering |
| Never leak memory | `NSCache` auto-evicts under memory pressure, `weak` references in async callbacks, image cache responds to `didReceiveMemoryWarning` |
| Never render unsafe URLs | Allowlist enforced at both render and click layers (`http`, `https`, `mailto`, `tel` only) |
| Always show something | `fallbackText` rendered when parse fails, error view with description in debug builds |
| Validation before submit | `validateAllInputs()` called before `Submit`/`Execute` events fire, invalid inputs highlighted |

**Error recovery chain**:

```
JSON → Parse error?
  → Yes: Show fallbackText if available, else error view, fire .parseFailed event
  → No: Parse succeeded
    → Unknown element types? → Render known elements, skip unknowns
    → Image load failed? → Show placeholder, card remains interactive
    → Action handler missing? → OpenUrl falls back to system browser; Submit/Execute logs warning
```

**Crash-free guarantee**: Every `public` entry point is wrapped in do/catch or Result. No force-unwraps in public API paths. All async callbacks use `[weak self]`. All caches respond to memory pressure.

### Pillar 3: Observability & Telemetry

The host needs to understand SDK behavior without instrumenting internals. The SDK reports what happened, how long it took, and what went wrong — automatically.

**Telemetry delivered via `CardLifecycleEvent.performanceReport`**:

```swift
public struct CardPerformanceMetrics: Sendable {
    // --- Timing ---
    public let parseTimeMs: Double              // JSON string → AdaptiveCard model
    public let templateExpansionTimeMs: Double   // Template + data → expanded JSON (0 if no template)
    public let firstRenderTimeMs: Double         // Card view appeared on screen
    public let fullyLoadedTimeMs: Double         // All images resolved, final layout settled
    public let totalImageLoadTimeMs: Double      // Sum of all image load durations

    // --- Counts ---
    public let elementCount: Int                 // Total rendered elements
    public let inputCount: Int                   // Input elements
    public let imageCount: Int                   // Image elements in card
    public let actionCount: Int                  // Actions in card

    // --- Cache effectiveness ---
    public let parseCacheHit: Bool               // Parse served from cache
    public let imagesCachedCount: Int            // Images served from memory/disk cache
    public let imagesLoadedCount: Int            // Images fetched from network/provider
    public let templateCacheHit: Bool            // Template expansion served from cache

    // --- Resource usage ---
    public let peakMemoryUsageMB: Double         // Peak memory during render
    public let imageTotalBytesFetched: Int       // Total bytes downloaded for images

    // --- Errors ---
    public let unknownElementTypes: [String]     // Element types that fell through to .unknown
    public let failedImageUrls: [String]         // Images that failed to load
    public let validationErrorCount: Int         // Input validation errors at render time
}
```

```kotlin
// Android — identical fields
data class CardPerformanceMetrics(
    val parseTimeMs: Double,
    val templateExpansionTimeMs: Double,
    val firstRenderTimeMs: Double,
    val fullyLoadedTimeMs: Double,
    val totalImageLoadTimeMs: Double,
    val elementCount: Int,
    val inputCount: Int,
    val imageCount: Int,
    val actionCount: Int,
    val parseCacheHit: Boolean,
    val imagesCachedCount: Int,
    val imagesLoadedCount: Int,
    val templateCacheHit: Boolean,
    val peakMemoryUsageMB: Double,
    val imageTotalBytesFetched: Int,
    val unknownElementTypes: List<String>,
    val failedImageUrls: List<String>,
    val validationErrorCount: Int
)
```

**Host consumption**:

```swift
// Teams wires this into their telemetry pipeline — one callback, all data
AdaptiveCardView(card: myCard, configuration: config)
    .onCardLifecycle { event in
        if case .performanceReport(let m) = event {
            teamsTelemetry.trackCardRender(
                parseMs: m.parseTimeMs,
                renderMs: m.firstRenderTimeMs,
                fullyLoadedMs: m.fullyLoadedTimeMs,
                cacheHit: m.parseCacheHit,
                elements: m.elementCount,
                images: m.imageCount,
                imagesCached: m.imagesCachedCount,
                unknownTypes: m.unknownElementTypes,
                failedImages: m.failedImageUrls
            )
        }
    }
```

**Global cache diagnostics** (for health dashboards):

```swift
// Available at any time, not per-card
let stats = CardCache.shared.stats
print("Parse hit rate: \(stats.parseHitRate)")       // e.g., 0.85
print("Image memory: \(stats.imageMemoryUsage) bytes") // e.g., 42_000_000
print("Image disk: \(stats.imageDiskUsage) bytes")    // e.g., 150_000_000
```

### Pillar 4: Testability

Every host-facing behavior is testable without rendering a view.

| What to test | How to test |
|---|---|
| Parsing | `AdaptiveCards.parse(json)` → assert `ParseResult` fields |
| Template expansion | `AdaptiveCards.parse(json, data: ...)` → assert expanded card body |
| Action events | Create `CardHandle`, call `triggerAction(withId:)`, assert callback fires |
| Input validation | Create `CardHandle`, set inputs, call `validateInputs()`, assert `ValidationResult` |
| Image loading | Inject mock `ImageProvider`, assert `loadImage` called with expected URLs |
| Cache behavior | Parse same JSON twice, assert `metrics.parseCacheHit == true` |
| Guardrails | Parse card with 500 elements, assert only 200 rendered |
| Error recovery | Parse malformed JSON, assert `ParseResult.error` is set, `card` is nil |
| Adapter compat | Use `LegacyActionHandler`, assert `onAction` called with correct `CardAction` |

**Test utilities shipped by SDK**:

```swift
// ios/Sources/ACCore/Testing/AdaptiveCardsTestSupport.swift
#if DEBUG
public extension AdaptiveCards {
    /// Create a minimal valid card for testing
    static func testCard(body: [CardElement] = []) -> AdaptiveCard

    /// Create a card JSON string from elements
    static func testJSON(elements: [String]) -> String

    /// Mock ImageProvider that returns colored rectangles
    static var mockImageProvider: ImageProvider
}
#endif
```

### Pillar 5: Security

Cards arrive from untrusted sources. The SDK is a **defense boundary** between untrusted JSON and the user's device.

| Threat | Defense | Enforcement point |
|---|---|---|
| XSS via `javascript:` URLs | URL scheme allowlist (`http`, `https`, `mailto`, `tel`) | Render layer + click handler (defense in depth) |
| Phishing via `data:` URLs | Blocked by allowlist | Same as above |
| Local file access via `file:` | Blocked by allowlist | Same as above |
| Deep-link hijacking via custom schemes | Blocked by allowlist | Same as above |
| DoS via huge cards | Element count cap (200), nesting depth (10), parse timeout (2s) | Parsing + rendering |
| DoS via huge images | Image size limit, concurrent load throttle (6), timeout (10s) | Image loading layer |
| Memory exhaustion | Cache eviction on memory pressure, image memory + disk limits | `CardCache` |
| Input injection | Input values are raw data — SDK does not evaluate expressions in input values | Input collection |

**Allowlist expansion rule**: Adding a new allowed URL scheme requires updating **all 5 enforcement points** (see CLAUDE.md Security section) and adding tests for each.

---

## The New Public API (Target State)

Before the phased plan, here's the complete target API surface. Everything else is `internal`.

### Parsing (standalone, no view needed)

```swift
// iOS
public enum AdaptiveCards {
    static func parse(_ json: String) -> ParseResult
    static func parse(_ json: String, data: [String: Any]) -> ParseResult
    static func clearCache()
}

public struct ParseResult: Sendable {
    public let card: AdaptiveCard?
    public let warnings: [ParseWarning]
    public let error: ParseError?
    public var isValid: Bool { card != nil }
}
```

```kotlin
// Android
object AdaptiveCards {
    fun parse(json: String): ParseResult
    fun parse(json: String, data: Map<String, Any?>): ParseResult
    fun clearCache()
}
```

### Rendering

```swift
// iOS — SwiftUI
public struct AdaptiveCardView: View {
    public init(card: AdaptiveCard, configuration: CardConfiguration = .default)
    public init(json: String, data: [String: Any]? = nil, configuration: CardConfiguration = .default)

    // Modifiers
    func onCardAction(_ handler: @escaping (CardActionEvent) -> Void) -> some View
    func onCardLifecycle(_ handler: @escaping (CardLifecycleEvent) -> Void) -> some View
    func cardHandle(_ handle: CardHandle) -> some View
}
```

```kotlin
// Android — Compose
@Composable
fun AdaptiveCardView(
    card: AdaptiveCard,
    configuration: CardConfiguration = CardConfiguration.Default,
    onAction: ((CardActionEvent) -> Unit)? = null,
    onLifecycle: ((CardLifecycleEvent) -> Unit)? = null,
    handle: CardHandle? = null,
    modifier: Modifier = Modifier
)
```

### Configuration

```swift
// Both platforms — identical shape
public struct CardConfiguration {
    public var hostConfig: HostConfig
    public var imageProvider: ImageProvider?
    public var rendererOverrides: RendererOverrides
    public var featureFlags: FeatureFlags

    public static var `default`: CardConfiguration
    public static func teams(theme: TeamsTheme) -> CardConfiguration
}

public protocol ImageProvider: Sendable {
    func loadImage(from url: URL) async throws -> UIImage  // iOS
}

interface ImageProvider {
    suspend fun loadImage(url: String): ImageBitmap  // Android
}
```

### Events

```swift
// Actions — what the host MUST handle
public enum CardActionEvent {
    case submit(action: SubmitAction, inputValues: [String: Any])
    case openUrl(action: OpenUrlAction, url: URL)
    case execute(action: ExecuteAction, inputValues: [String: Any])
    case refreshRequested(userIds: [String]?)
    case authRequired(AuthRequest)
}

// Lifecycle — what the host MAY observe
public enum CardLifecycleEvent {
    case rendered
    case sizeChanged(CGSize)
    case inputChanged(id: String, value: Any)
    case parseFailed(ParseError)
}
```

### Host-Facing State

```swift
// iOS
@Observable
public final class CardHandle {
    public private(set) var card: AdaptiveCard?
    public private(set) var isRendered: Bool
    public private(set) var contentSize: CGSize
    public var inputValues: [String: Any] { get }

    public func refreshData(_ newData: [String: Any])
    public func validateInputs() -> ValidationResult
    public func triggerAction(withId actionId: String)
    public func reset()
}
```

---

## Phase 1: Decouple Parse from Render (Additive)

**Why**: Teams needs to pre-parse cards for caching, inspection, and conditional rendering. Parsing should not be locked inside `onAppear`.

**Files**:
- New: `ios/Sources/ACCore/AdaptiveCards.swift`
- New: `android/ac-core/.../AdaptiveCards.kt`
- New: `ios/Sources/ACCore/ParseResult.swift`
- New: `android/ac-core/.../ParseResult.kt`

**What changes**: Add `AdaptiveCards.parse()` as a standalone API. The existing `CardParser` becomes an internal implementation detail. Move the LRU cache from `CardViewModel` static to `AdaptiveCards` namespace.

**What doesn't change**: The existing `AdaptiveCardView(cardJson:...)` init continues to work. The JSON convenience init calls `AdaptiveCards.parse()` internally.

**Teams impact**: None. Additive. Teams can start using pre-parsed cards whenever ready.

---

## Phase 2: CardConfiguration + ImageProvider (Additive)

**Why**: Teams routes images through its authenticated CDN. The SDK has no image loading hook — this is a **production blocker**. Also, 8 init parameters need consolidation.

**Files**:
- New: `ios/Sources/ACCore/CardConfiguration.swift`
- New: `ios/Sources/ACCore/ImageProvider.swift`
- New: `android/ac-core/.../CardConfiguration.kt`
- New: `android/ac-core/.../ImageProvider.kt`
- Modify: `ios/Sources/ACRendering/Views/AdaptiveCardView.swift` (add new init, keep old)
- Modify: `android/ac-rendering/.../composables/AdaptiveCardView.kt` (add new overload)

**What changes**: New `CardConfiguration` value type bundles `HostConfig`, `ImageProvider`, `RendererOverrides`, and `FeatureFlags`. New `AdaptiveCardView(card:configuration:)` init.

**What doesn't change**: The existing 8-param init stays as `@available(*, deprecated, message: "Use init(card:configuration:)")`. No code breaks.

**Instance-based RendererOverrides**: Replaces the singleton `ElementRendererRegistry.shared`. The singleton is kept but deprecated — internally it delegates to a shared `RendererOverrides`. Per-card overrides via `CardConfiguration` take precedence.

**Teams impact**: None until they opt in. Teams adds `imageProvider` to config when ready — this unblocks authenticated image loading.

---

## Phase 3: Unified Action Events + Adapter (Breaking internally, Adapter for Teams)

**Why**: Two protocols (`ActionDelegate` + `ActionHandler`) for the same concern. Teams implements one callback for all actions.

**New API**: `onCardAction` modifier / lambda with typed `CardActionEvent`.

**The critical design decision**: `ShowCard`, `ToggleVisibility`, `Popover` are NOT exposed as action events. They are internal state transitions. The host never sees them.

### Adapter for Teams

The SDK ships an adapter that bridges the new event model to the old delegate pattern:

```swift
// iOS — shipped in ACTeams module
// ios/Sources/ACTeams/Adapters/LegacyActionAdapter.swift

/// Adapter that converts the new CardActionEvent to the legacy ACRActionDelegate pattern.
/// Teams implements this protocol (same shape as old ObjC delegate) and the adapter
/// translates new events to old callbacks.
public protocol LegacyActionHandler: AnyObject {
    /// Called when any action is triggered. Mirrors the legacy
    /// `didFetchUserResponses(card:action:)` pattern.
    func onAction(card: AdaptiveCard, action: CardAction, inputValues: [String: Any])
}

public extension AdaptiveCardView {
    /// Bridges a LegacyActionHandler to the new onCardAction system.
    /// Teams uses this instead of onCardAction during migration.
    func legacyActionHandler(_ handler: LegacyActionHandler) -> some View {
        self.onCardAction { event in
            switch event {
            case .submit(let action, let inputs):
                handler.onAction(card: ..., action: .submit(action), inputValues: inputs)
            case .openUrl(let action, _):
                handler.onAction(card: ..., action: .openUrl(action), inputValues: [:])
            case .execute(let action, let inputs):
                handler.onAction(card: ..., action: .execute(action), inputValues: inputs)
            default: break
            }
        }
    }
}
```

```kotlin
// Android — shipped in ac-teams module
// android/ac-teams/.../adapters/LegacyActionAdapter.kt

interface LegacyActionHandler {
    fun onAction(card: AdaptiveCard, action: CardAction, inputValues: Map<String, Any>)
}

fun AdaptiveCardView(
    card: AdaptiveCard,
    configuration: CardConfiguration,
    legacyHandler: LegacyActionHandler,
    // ... other params
)
```

**Teams impact**: Teams replaces `class TeamsActionDelegate: ACRActionDelegate` (ObjC) with `class TeamsActionHandler: LegacyActionHandler` (Swift/Kotlin). The method signature is nearly identical — single callback, action + inputs. **The switch-on-action-type logic Teams already has stays the same.**

When Teams is ready (future milestone), they migrate from `legacyActionHandler` to `onCardAction` with typed pattern matching. No rush.

---

## Phase 4: Lifecycle Events (Additive)

**Why**: Teams needs `sizeChanged` for chat bubble sizing, `rendered` for loading indicators, `inputChanged` for send-button enable/disable.

**Files**:
- New: `ios/Sources/ACRendering/Events/CardLifecycleEvent.swift`
- New: `android/ac-rendering/.../events/CardLifecycleEvent.kt`
- Modify: `AdaptiveCardView` on both platforms (add GeometryReader preference, input observation)

**Implementation**:
- `rendered`: Fire after first layout pass completes (SwiftUI `onAppear` of the card body, Compose `LaunchedEffect` after composition)
- `sizeChanged`: SwiftUI `GeometryReader` + preference key. Compose `onGloballyPositioned`.
- `inputChanged`: Internal `CardViewModel` observation, forwarded through event channel

**Teams impact**: None until opt-in. Teams adds `.onCardLifecycle` when ready.

---

## Phase 5: CardHandle — Host-Facing State (Additive)

**Why**: Teams needs to query input values, validate before submit, refresh card data, and programmatically trigger actions (test automation). Currently impossible because `CardViewModel` is private to the view.

**Files**:
- New: `ios/Sources/ACRendering/State/CardHandle.swift`
- New: `android/ac-rendering/.../state/CardHandle.kt`
- Modify: `AdaptiveCardView` (wire CardHandle to internal ViewModel)

**CardHandle** is a thin facade over the internal `CardViewModel`:
- Read-only access to `card`, `isRendered`, `contentSize`, `inputValues`
- Write access limited to host-facing operations: `refreshData`, `validateInputs`, `triggerAction`, `reset`
- Internal state (`visibility`, `showCards`, `popoverState`) is **not** exposed

### Adapter for legacy input collection

```swift
// ios/Sources/ACTeams/Adapters/LegacyInputAdapter.swift

public extension CardHandle {
    /// Returns inputs in the legacy format: [String: String] (all values stringified).
    /// Mirrors `renderedCard.getInputs()` from the Java SDK.
    func legacyInputs() -> [String: String] {
        inputValues.mapValues { "\($0)" }
    }
}
```

**Teams impact**: None until opt-in. Replaces the `pendingActionTitle` Binding hack for test automation with `handle.triggerAction(withId:)`.

---

## Phase 6: Make Internal State Internal (Breaking, with deprecation path)

**Why**: `CardViewModel`'s `@Published public var visibility/showCards/popoverState` leak internal rendering state. `ValidationState` duplicates validation logic.

**Changes**:
- `CardViewModel` access → `internal` (was `public`)
- `ValidationState` access → `internal`, merged into `CardViewModel`
- `ActionDelegate` protocol → `internal`, replaced by `onCardAction`
- `ActionHandler` protocol → `internal`, renamed to `ActionDispatcher`
- `ElementRendererRegistry.shared` → `@available(*, deprecated)`, internally delegates to config-based overrides

**Deprecation strategy**: Before removing, mark old APIs `@available(*, deprecated, renamed: "...")` for one release cycle. This gives Teams time to migrate to `onCardAction` / `CardHandle` / `CardConfiguration`.

**Teams impact**: If Teams has already adopted the adapters from Phases 3 and 5, this is invisible. If not, they get deprecation warnings pointing to the new APIs.

---

## Phase 7: Umbrella Products (Additive)

**Files**: `ios/Package.swift`, `android/settings.gradle.kts`

Add 3 umbrella products that re-export all necessary modules:

```swift
// iOS
.library(name: "AdaptiveCards",
         targets: ["ACCore", "ACRendering", "ACInputs", "ACActions",
                   "ACAccessibility", "ACMarkdown", "ACCharts",
                   "ACFluentUI", "ACTemplating"]),
.library(name: "AdaptiveCardsTeams",
         targets: ["ACTeams"]),
.library(name: "AdaptiveCardsCopilot",
         targets: ["ACCopilotExtensions"]),
```

Consumer code: `import AdaptiveCards` — one import, everything works.

Existing per-module imports continue to work. No breaking change.

---

## Phase 8: UIKit / Android View Bridge (Additive, Critical for Teams)

**Why**: Teams' iOS codebase is UIKit. Teams' Android codebase uses Android Views + some Compose. The new SDK is SwiftUI/Compose. Teams cannot rewrite all screens at once.

### iOS: AdaptiveCardUIView

```swift
// ios/Sources/ACRendering/Bridge/AdaptiveCardUIView.swift

/// Drop-in UIView replacement for legacy ACRRenderResult.view
public final class AdaptiveCardUIView: UIView {
    // The minimal API Teams needs — mirrors legacy RenderedAdaptiveCard
    public init(card: AdaptiveCard, configuration: CardConfiguration = .default)
    public init(json: String, configuration: CardConfiguration = .default)

    public var onAction: ((CardActionEvent) -> Void)?
    public var onLifecycle: ((CardLifecycleEvent) -> Void)?

    // Mirrors renderedCard.getInputs()
    public var inputValues: [String: Any] { get }
    public func validateInputs() -> ValidationResult
    public func refreshData(_ newData: [String: Any])
    public func updateCard(_ card: AdaptiveCard)
    public override var intrinsicContentSize: CGSize { get }
}
```

Internally wraps `UIHostingController` + `AdaptiveCardView`. Teams replaces:

```objc
// Before (ObjC)
ACRRenderResult *result = [ACRRenderer render:card config:config widthConstraint:w delegate:self theme:t];
[self.view addSubview:result.view];
```

```swift
// After (Swift, still UIKit)
let cardView = AdaptiveCardUIView(card: parsedCard, configuration: .teams(theme: .dark))
cardView.onAction = { [weak self] event in self?.handleAction(event) }
self.view.addSubview(cardView)
```

**Teams impact**: Mechanical replacement. Same UIView-based embedding. Same action callback shape (via `LegacyActionHandler` adapter or direct `onAction`).

### Android: AdaptiveCardAndroidView

```kotlin
// android/ac-rendering/.../bridge/AdaptiveCardAndroidView.kt

class AdaptiveCardAndroidView(context: Context) : AbstractComposeView(context) {
    var card: AdaptiveCard? = null
    var configuration: CardConfiguration = CardConfiguration.Default
    var onAction: ((CardActionEvent) -> Unit)? = null
    var onLifecycle: ((CardLifecycleEvent) -> Unit)? = null

    fun setCardJson(json: String, data: Map<String, Any?>? = null)
    fun getInputValues(): Map<String, Any>
    fun validateInputs(): ValidationResult
    fun refreshData(newData: Map<String, Any?>)
}
```

Replaces:
```java
// Before (Java)
RenderedAdaptiveCard rendered = AdaptiveCardRenderer.getInstance().render(ctx, fm, card, handler, hc);
layout.addView(rendered.getView());
```

```kotlin
// After (Kotlin, still Android Views)
val cardView = AdaptiveCardAndroidView(context)
cardView.card = parsedCard
cardView.configuration = CardConfiguration.teams(TeamsTheme.Dark)
cardView.onAction = { event -> handleAction(event) }
layout.addView(cardView)
```

---

## Phase 9: Cross-Platform Naming Parity (Mechanical)

Align names for all types that appear in host code:

| Type | iOS | Android | Notes |
|---|---|---|---|
| `AdaptiveCards` | `enum` | `object` | Static parse API |
| `ParseResult` | `struct` | `data class` | Same fields |
| `CardConfiguration` | `struct` | `data class` | Same fields |
| `CardActionEvent` | `enum` | `sealed interface` | Same cases |
| `CardLifecycleEvent` | `enum` | `sealed interface` | Same cases |
| `CardHandle` | `@Observable class` | `class` with `StateFlow` | Same methods |
| `ImageProvider` | `protocol` | `interface` | Same method |
| `RendererOverrides` | `struct` | `class` | Same methods |
| `ValidationResult` | `struct` | `data class` | Same fields |
| `AdaptiveCardUIView` | UIView subclass | N/A | iOS only |
| `AdaptiveCardAndroidView` | N/A | AbstractComposeView | Android only |

Action model types (`SubmitAction` vs `ActionSubmit`) follow platform conventions internally but expose the same `CardActionEvent` shape to hosts.

---

## Phase 10: Caching, Performance & Reliability Infrastructure (Additive, P0/P1)

**Implements**: Pillar 1 (Performance), Pillar 2 (Reliability), Pillar 3 (Observability)

### Current State

| Layer | iOS | Android | Gap |
|---|---|---|---|
| Parse cache | `NSCache` (32) in `CardViewModel` | `LruCache` (32) in `CardViewModel` | Trapped in ViewModel, should be in `AdaptiveCards` namespace |
| Expression cache | `ExpressionCache` (256, LRU, TTL) | Not yet | Android parity missing |
| Markdown cache | `NSCache` in `MarkdownParser` | Not yet | Android parity missing |
| HostConfig cache | Lazy singleton | Lazy singleton | Good |
| Image cache | **None** | **None** | **Production blocker** |
| Template expansion cache | **None** | **None** | Perf opportunity |
| Memory pressure | **None** | **None** | OOM risk in Teams |
| Guardrails | **None** | **None** | Pathological card risk |
| Telemetry | `lastParseTimeMs` only | `lastParseTimeMs` only | Minimal, needs full metrics |
| Prefetch | **None** | **None** | Scroll perf opportunity |

### 10a. Unified Cache Layer — `CardCache`

Move all caching behind a single configurable API. The host can tune capacity, eviction, and memory pressure responses.

```swift
// iOS — ios/Sources/ACCore/Caching/CardCache.swift
public final class CardCache: Sendable {
    public static let shared = CardCache()

    public init(configuration: CacheConfiguration = .default)

    // --- Parse cache ---
    public func cachedCard(for json: String) -> AdaptiveCard?
    public func cacheCard(_ card: AdaptiveCard, for json: String)

    // --- Template expansion cache ---
    public func cachedExpansion(template: String, dataHash: Int) -> String?
    public func cacheExpansion(_ result: String, template: String, dataHash: Int)

    // --- Image cache ---
    public func cachedImage(for url: URL) -> UIImage?
    public func cacheImage(_ image: UIImage, for url: URL)

    // --- Bulk operations ---
    public func clearAll()
    public func clearImages()
    public func clearParseCache()
    public func trimToMemoryLimit()

    // --- Diagnostics ---
    public var stats: CacheStats { get }
}

public struct CacheConfiguration {
    public var parseCapacity: Int           // Default: 64
    public var templateCapacity: Int        // Default: 128
    public var imageMemoryLimit: Int        // Default: 50 MB
    public var imageDiskLimit: Int          // Default: 200 MB
    public var imageDiskPath: URL?          // Default: system temp
    public var evictionPolicy: EvictionPolicy  // .lru (default), .fifo, .ttl(seconds:)
    public var respondsToMemoryPressure: Bool  // Default: true (auto-trim on didReceiveMemoryWarning)

    public static let `default` = CacheConfiguration()
    public static let aggressive = CacheConfiguration(parseCapacity: 128, imageMemoryLimit: 100_000_000)
    public static let minimal = CacheConfiguration(parseCapacity: 16, imageMemoryLimit: 10_000_000)
}

public struct CacheStats {
    public let parseHits: Int
    public let parseMisses: Int
    public let parseHitRate: Double
    public let templateHits: Int
    public let templateMisses: Int
    public let imageMemoryUsage: Int        // Bytes
    public let imageDiskUsage: Int          // Bytes
    public let imageHits: Int
    public let imageMisses: Int
}
```

```kotlin
// Android — android/ac-core/.../caching/CardCache.kt
class CardCache(configuration: CacheConfiguration = CacheConfiguration.Default) {
    companion object {
        val shared = CardCache()
    }

    fun cachedCard(json: String): AdaptiveCard?
    fun cacheCard(card: AdaptiveCard, json: String)
    fun cachedImage(url: String): ImageBitmap?
    fun cacheImage(image: ImageBitmap, url: String)
    fun clearAll()
    fun trimToMemoryLimit()
    val stats: CacheStats
}
```

**Wire to CardConfiguration:**
```swift
var config = CardConfiguration.teams(theme: .dark)
config.cache = CardCache.shared                      // Use global shared cache (default)
config.cache = CardCache(configuration: .aggressive) // Or per-config cache
config.cache = nil                                   // Disable all caching
```

### 10b. Built-in Image Caching (Two-Tier: Memory + Disk)

When no custom `ImageProvider` is set, the SDK provides a default image loader with two-tier caching. When a custom `ImageProvider` IS set (Teams scenario), the SDK wraps it with caching — the host's provider is the fetch layer, the SDK handles caching.

```swift
// iOS — ios/Sources/ACRendering/Caching/CachingImageProvider.swift

/// Wraps any ImageProvider with memory + disk caching.
/// SDK uses this internally — hosts don't need to implement caching themselves.
internal final class CachingImageProvider: ImageProvider {
    let upstream: ImageProvider  // The actual loader (default URLSession or Teams' custom one)
    let cache: CardCache

    func loadImage(from url: URL) async throws -> UIImage {
        // 1. Check memory cache
        if let cached = cache.cachedImage(for: url) { return cached }

        // 2. Check disk cache
        if let diskCached = loadFromDisk(url) {
            cache.cacheImage(diskCached, for: url)  // Promote to memory
            return diskCached
        }

        // 3. Fetch from upstream (network or host-provided)
        let image = try await upstream.loadImage(from: url)

        // 4. Cache in memory + disk
        cache.cacheImage(image, for: url)
        saveToDisk(image, for: url)

        return image
    }
}
```

```kotlin
// Android — same pattern
internal class CachingImageProvider(
    private val upstream: ImageProvider,
    private val cache: CardCache
) : ImageProvider {
    override suspend fun loadImage(url: String): ImageBitmap { ... }
}
```

**Key**: The host's `ImageProvider` only handles **fetching**. Caching is always SDK-managed. Even Teams' auth'd image provider gets free caching.

### 10c. Template Expansion Caching

Same template + same data = same output. Cache the expanded JSON to avoid re-evaluating expressions.

```swift
// Inside AdaptiveCards.parse(_:data:)
let dataHash = stableHash(data)
if let cached = cache.cachedExpansion(template: json, dataHash: dataHash) {
    return parseExpanded(cached)  // Skip template expansion, just parse
}
let expanded = templateEngine.expand(template: json, data: data)
cache.cacheExpansion(expanded, template: json, dataHash: dataHash)
return parseExpanded(expanded)
```

### 10d. Memory Pressure Handling

The SDK automatically responds to system memory pressure events:

```swift
// iOS — registered in CardCache.init
NotificationCenter.default.addObserver(
    forName: UIApplication.didReceiveMemoryWarningNotification, ...
) { [weak self] _ in
    self?.trimToMemoryLimit()  // Evict images first, then templates, then parsed cards
}
```

```kotlin
// Android — registered in CardCache.init
class CardCache(...) {
    init {
        // ComponentCallbacks2 for onTrimMemory
        val callback = object : ComponentCallbacks2 {
            override fun onTrimMemory(level: Int) {
                when {
                    level >= TRIM_MEMORY_COMPLETE -> clearAll()
                    level >= TRIM_MEMORY_MODERATE -> clearImages()
                    level >= TRIM_MEMORY_BACKGROUND -> trimToMemoryLimit()
                }
            }
        }
    }
}
```

### 10e. Performance Telemetry

Implements `CardPerformanceMetrics` as defined in **Pillar 3: Observability**. Delivered via `CardLifecycleEvent.performanceReport` after the card is fully loaded (all images resolved, layout settled).

**Files**:
- New: `ios/Sources/ACRendering/Telemetry/CardPerformanceMetrics.swift`
- New: `android/ac-rendering/.../telemetry/CardPerformanceMetrics.kt`
- Modify: `AdaptiveCardView` on both platforms (instrument parse, render, image load timing)

**Instrumentation points** (internal, zero overhead when no `.onCardLifecycle` handler is set):
- Parse start/end → `parseTimeMs`
- Template expansion start/end → `templateExpansionTimeMs`
- First `onAppear` / `LaunchedEffect` → `firstRenderTimeMs`
- Last image loaded → `fullyLoadedTimeMs`, `totalImageLoadTimeMs`
- Cache lookups → `parseCacheHit`, `templateCacheHit`, `imagesCachedCount`
- Element tree walk → `elementCount`, `inputCount`, `imageCount`, `actionCount`
- Failed loads → `failedImageUrls`, `unknownElementTypes`

### 10f. Prefetch API

For scroll performance in lists (Teams chat), the SDK provides a prefetch API that pre-parses and pre-warms image caches before the card scrolls into view.

```swift
// iOS
public extension AdaptiveCards {
    /// Pre-parse and optionally prefetch images for cards that are about to appear.
    /// Call from UICollectionView/UITableView prefetch delegate or List .onAppear.
    static func prefetch(_ jsons: [String], configuration: CardConfiguration = .default) {
        // Background: parse each JSON, cache result
        // Background: extract image URLs from parsed cards, start image downloads
    }

    static func prefetch(_ cards: [AdaptiveCard], configuration: CardConfiguration = .default) {
        // Background: extract image URLs, start image downloads
    }

    /// Cancel prefetch for cards that scrolled out of range
    static func cancelPrefetch(_ jsons: [String])
}
```

```kotlin
// Android
object AdaptiveCards {
    fun prefetch(jsons: List<String>, configuration: CardConfiguration = CardConfiguration.Default)
    fun prefetch(cards: List<AdaptiveCard>, configuration: CardConfiguration = CardConfiguration.Default)
    fun cancelPrefetch(jsons: List<String>)
}
```

Teams usage in a chat list:
```swift
// UICollectionViewDataSourcePrefetching
func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    let jsons = indexPaths.compactMap { cardJsonForIndexPath($0) }
    AdaptiveCards.prefetch(jsons, configuration: teamsConfig)
}

func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    let jsons = indexPaths.compactMap { cardJsonForIndexPath($0) }
    AdaptiveCards.cancelPrefetch(jsons)
}
```

### 10g. Rendering Performance Guardrails

The SDK protects against pathological cards that could freeze the UI:

```swift
public struct PerformanceGuardrails {
    /// Maximum number of elements rendered per card (default: 200)
    public var maxElementCount: Int = 200

    /// Maximum nesting depth for containers (default: 10)
    public var maxNestingDepth: Int = 10

    /// Maximum number of images loaded concurrently (default: 6)
    public var maxConcurrentImageLoads: Int = 6

    /// Timeout for image loading before showing placeholder (default: 10s)
    public var imageTimeoutSeconds: Double = 10.0

    /// Parse timeout — abort and show fallbackText if exceeded (default: 2s)
    public var parseTimeoutSeconds: Double = 2.0
}

// Part of CardConfiguration
public struct CardConfiguration {
    // ...existing fields...
    public var guardrails: PerformanceGuardrails
}
```

### Implementation Priority Within Phase 10

| Sub-phase | Priority | Why |
|---|---|---|
| 10a. Unified CardCache | P0 | Foundation for all caching |
| 10b. Image caching (memory + disk) | P0 | Teams blocker — images must cache through auth pipeline |
| 10d. Memory pressure handling | P0 | Crashes in Teams if cache grows unbounded |
| 10g. Rendering guardrails | P0 | Prevents pathological cards from freezing chat |
| 10c. Template expansion caching | P1 | Nice perf win for repeated template patterns |
| 10f. Prefetch API | P1 | Scroll performance for chat lists |
| 10e. Performance telemetry | P2 | Diagnostics, not blocking |

---

## SDK-Shipped Adapter Catalog (ACTeams Module)

All adapter code ships inside the `ACTeams` module (iOS) and `ac-teams` module (Android). Teams imports `AdaptiveCardsTeams` and gets all adapters. **No adapter code lives in the Teams codebase — it's all SDK-provided.**

### Adapter 1: LegacyActionHandler — Action Delegate Bridge

**What it replaces**: `ACRActionDelegate.didFetchUserResponses(card:action:)` (iOS) / `ICardActionHandler.onAction(element, renderedCard)` (Android)

**Why Teams needs it**: Teams has a single action callback that switches on action type. The new `CardActionEvent` enum is structurally different. This adapter preserves the existing switch-on-type pattern.

```swift
// iOS — ios/Sources/ACTeams/Adapters/LegacyActionHandler.swift
public protocol LegacyActionHandler: AnyObject {
    func onAction(card: AdaptiveCard, action: CardAction, inputValues: [String: Any])
    func onMediaPlay(elementId: String)?  // optional
    func onMediaStop(elementId: String)?  // optional
}

// Extension on AdaptiveCardView — use as modifier
public extension AdaptiveCardView {
    func legacyActionHandler(_ handler: LegacyActionHandler) -> some View
}

// Extension on AdaptiveCardUIView — use as property
public extension AdaptiveCardUIView {
    var legacyActionHandler: LegacyActionHandler? { get set }
}
```

```kotlin
// Android — android/ac-teams/.../adapters/LegacyActionHandler.kt
interface LegacyActionHandler {
    fun onAction(card: AdaptiveCard, action: CardAction, inputValues: Map<String, Any>)
    fun onMediaPlay(elementId: String) {}
    fun onMediaStop(elementId: String) {}
}

// Extension function for Compose
@Composable
fun AdaptiveCardView(
    card: AdaptiveCard,
    configuration: CardConfiguration,
    legacyHandler: LegacyActionHandler,
    modifier: Modifier = Modifier
)

// Property on the View bridge
class AdaptiveCardAndroidView {
    var legacyActionHandler: LegacyActionHandler?
}
```

**Teams code change**: Replace `class X: ACRActionDelegate` with `class X: LegacyActionHandler`. Method body (the switch statement) stays identical.

### Adapter 2: LegacyImageResolver — Resource Resolver Bridge

**What it replaces**: `ACOIResourceResolver` (iOS, per-scheme) / `IResourceResolver` + `IOnlineImageLoader` (Android)

**Why Teams needs it**: Teams has existing per-scheme resolvers (http, package, data). The new `ImageProvider` is a single protocol. This adapter wraps multiple scheme-based resolvers into one `ImageProvider`.

```swift
// iOS — ios/Sources/ACTeams/Adapters/LegacyImageResolver.swift
public final class SchemeBasedImageProvider: ImageProvider {
    public init()

    /// Register a resolver for a URL scheme (mirrors legacy ACOResourceResolvers pattern)
    public func register(scheme: String, resolver: @escaping (URL) async throws -> UIImage)

    /// Convenience: wrap a synchronous resolver (legacy pattern)
    public func register(scheme: String, syncResolver: @escaping (URL) -> UIImage?)

    // ImageProvider conformance
    public func loadImage(from url: URL) async throws -> UIImage
}
```

```kotlin
// Android — android/ac-teams/.../adapters/SchemeBasedImageProvider.kt
class SchemeBasedImageProvider : ImageProvider {
    fun register(scheme: String, resolver: suspend (String) -> ImageBitmap)
    fun registerSync(scheme: String, resolver: (String) -> Bitmap?)
    override suspend fun loadImage(url: String): ImageBitmap
}
```

**Teams code change**: Wrap existing resolvers:
```swift
let imageProvider = SchemeBasedImageProvider()
imageProvider.register(scheme: "https") { url in
    // Exact same code Teams already has in ACOIResourceResolver.resolveImageResource
    return try await teamsImageService.load(url)
}
config.imageProvider = imageProvider
```

### Adapter 3: LegacyRendererRegistration — Singleton Registry Bridge

**What it replaces**: `ACRRegistration.getInstance().setBaseCardElementRenderer(r, t)` (iOS) / `CardRendererRegistration.getInstance().registerRenderer(type, r)` (Android)

**Why Teams needs it**: Teams registers custom renderers at app startup via a global singleton. The new API uses instance-based `RendererOverrides` per `CardConfiguration`. This adapter maps singleton registrations to config-based overrides.

```swift
// iOS — ios/Sources/ACTeams/Adapters/LegacyRendererRegistration.swift
public final class LegacyRendererRegistration {
    public static let shared = LegacyRendererRegistration()

    /// Register a custom element renderer (mirrors legacy ACRRegistration pattern)
    public func registerElement<V: View>(_ type: String, renderer: @escaping (CardElement) -> V)

    /// Register a custom action renderer
    public func registerAction<V: View>(_ type: String, renderer: @escaping (CardAction) -> V)

    /// Apply all registered overrides to a CardConfiguration.
    /// Called internally by CardConfiguration.teams() factory.
    public func applyTo(_ configuration: inout CardConfiguration)
}
```

**Teams code change**: Replace `ACRRegistration.getInstance()` calls with `LegacyRendererRegistration.shared` calls (same pattern, different class name). Or better — register overrides directly on `CardConfiguration` and skip the singleton.

### Adapter 4: LegacyInputCollection — Input String Map Bridge

**What it replaces**: `renderedCard.getInputs()` → `Map<String, String>` (Android) / `card.inputs` → `NSData` (iOS)

**Why Teams needs it**: Legacy SDK returns all input values as `[String: String]` (stringified). New SDK uses `[String: Any]` (typed). Teams' backend expects string values.

```swift
// iOS — ios/Sources/ACTeams/Adapters/LegacyInputAdapter.swift
public extension CardHandle {
    /// Returns inputs as [String: String], matching legacy renderedCard.getInputs() format.
    func legacyInputs() -> [String: String] {
        inputValues.mapValues { String(describing: $0) }
    }
}

public extension AdaptiveCardUIView {
    /// Returns inputs as [String: String], matching legacy format.
    func legacyInputValues() -> [String: String] {
        inputValues.mapValues { String(describing: $0) }
    }
}
```

```kotlin
// Android
fun CardHandle.legacyInputs(): Map<String, String> =
    inputValues.value.mapValues { it.value.toString() }

fun AdaptiveCardAndroidView.legacyInputValues(): Map<String, String> =
    getInputValues().mapValues { it.value.toString() }
```

### Adapter 5: LegacyFeatureFlags — Feature Registration Bridge

**What it replaces**: `ACOFeatureRegistration.addFeature(name, version)` (iOS) / `FeatureRegistration` (Android)

```swift
// iOS — ios/Sources/ACTeams/Adapters/LegacyFeatureAdapter.swift
public extension FeatureFlags {
    /// Bulk-register features matching legacy ACOFeatureRegistration pattern.
    mutating func registerLegacy(_ features: [String: String]) {
        for (name, version) in features {
            register(name: name, version: version)
        }
    }
}
```

### Adapter 6: LegacyLifecycleAdapter — Delegate Method Bridge

**What it replaces**: `ACRActionDelegate.didLoadElements` / `didChangeViewLayout:newFrame:` (iOS)

```swift
// iOS — ios/Sources/ACTeams/Adapters/LegacyLifecycleAdapter.swift
public protocol LegacyCardLifecycleDelegate: AnyObject {
    func didLoadElements()
    func didChangeViewLayout(oldFrame: CGRect, newFrame: CGRect)
    func didChangeVisibility(elementId: String, isVisible: Bool)
}

public extension AdaptiveCardUIView {
    /// Set a legacy lifecycle delegate. Internally maps from CardLifecycleEvent.
    var legacyLifecycleDelegate: LegacyCardLifecycleDelegate? { get set }
}
```

### Adapter 7: TypeaheadSearchAdapter — Dynamic Choice Set Bridge

**What it replaces**: `ACRActionDelegate.onChoiceSetQueryChange(searchRequest:elem:completion:)` (iOS) / custom `ICardActionHandler` typeahead support (Android)

```swift
// iOS — ios/Sources/ACTeams/Adapters/TypeaheadSearchAdapter.swift
public protocol TypeaheadSearchProvider: AnyObject {
    func search(
        query: String,
        datasetId: String,
        completion: @escaping ([TypeaheadChoice]) -> Void
    )
}

public struct TypeaheadChoice {
    public let title: String
    public let value: String
}
```

Wired via `CardConfiguration`:
```swift
var config = CardConfiguration.teams(theme: .dark)
config.typeaheadProvider = myTeamsTypeaheadProvider
```

---

## Teams Integration Path (Zero-to-Shipped)

### Step 1: Add SDK dependency (no code changes)
```swift
// iOS: Package.swift
.package(url: "https://github.com/AzureAD/AdaptiveCards-Mobile", from: "2.0.0")
// dependency: "AdaptiveCardsTeams"
```

### Step 2: Create Teams configuration (one-time setup)
```swift
// TeamsCardConfig.swift — new file in Teams codebase
let teamsCardConfig = CardConfiguration.teams(theme: currentTheme)
teamsCardConfig.imageProvider = TeamsImageProvider(authService: authService)
```

### Step 3: Replace rendering call sites (mechanical, per-screen)

**UIKit screens** (majority of Teams iOS):
```swift
// Replace: ACRRenderResult.view
// With:    AdaptiveCardUIView
let cardView = AdaptiveCardUIView(card: parsedCard, configuration: teamsCardConfig)
cardView.onAction = { [weak self] event in self?.handleAction(event) }
parentView.addSubview(cardView)
```

**SwiftUI screens** (new Teams features):
```swift
AdaptiveCardView(card: parsedCard, configuration: teamsCardConfig)
    .onCardAction { event in handleAction(event) }
    .onCardLifecycle { event in
        if case .sizeChanged(let size) = event { updateBubbleHeight(size.height) }
    }
```

### Step 4: Migrate action handler (one-time)

**Option A: Use adapter (zero behavior change)**
```swift
class TeamsActionHandler: LegacyActionHandler {
    func onAction(card: AdaptiveCard, action: CardAction, inputValues: [String: Any]) {
        // Exact same switch-on-action-type logic Teams already has
        switch action {
        case .submit(let a): teamsBot.submit(a.data, inputs: inputValues)
        case .openUrl(let a): teamsNav.open(a.url)
        case .execute(let a): teamsBot.execute(a.verb, data: inputValues)
        default: break
        }
    }
}
```

**Option B: Use typed events directly (recommended long-term)**
```swift
.onCardAction { event in
    switch event {
    case .submit(let action, let inputs): teamsBot.submit(action.data, inputs: inputs)
    case .openUrl(_, let url): teamsNav.open(url)
    case .execute(let action, let inputs): teamsBot.execute(action.verb, data: inputs)
    default: break
    }
}
```

### Step 5: Migrate resource resolver (one-time)

```swift
// Before: ACOIResourceResolver (ObjC protocol, per-scheme)
class TeamsImageResolver: NSObject, ACOIResourceResolver { ... }

// After: ImageProvider (Swift protocol, single implementation)
class TeamsImageProvider: ImageProvider {
    let authService: AuthService

    func loadImage(from url: URL) async throws -> UIImage {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(try await authService.getToken())", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        return UIImage(data: data)!
    }
}
```

### What Teams Does NOT Need to Change

- **Card JSON format** — identical, same schema
- **HostConfig JSON format** — identical, same keys and structure
- **Action routing logic** — same switch-on-type, adapter preserves the pattern
- **Backend API calls** — same inputs/data payloads
- **Test card fixtures** — shared, unchanged

---

## Implementation Order

| Phase | Breaking? | Teams effort | Priority |
|---|---|---|---|
| 1. Parse decoupling | No | Zero | P0 — enables pre-parse |
| 2. CardConfiguration + ImageProvider | No | Zero | P0 — unblocks production |
| 10a-b. Unified cache + image caching | No | Zero | P0 — perf foundation |
| 10d. Memory pressure handling | No | Zero | P0 — prevents OOM |
| 10g. Rendering guardrails | No | Zero | P0 — prevents UI freeze |
| 8. UIKit/View bridges | No | Low (swap call sites) | P0 — enables integration |
| 3. Action events + adapter | Internal only | Low (adopt adapter) | P1 |
| 4. Lifecycle events | No | Zero | P1 — enables chat sizing |
| 5. CardHandle | No | Zero until opt-in | P1 |
| 10c. Template expansion cache | No | Zero | P1 — perf win |
| 10f. Prefetch API | No | Zero | P1 — scroll perf |
| 7. Umbrella products | No | Zero | P2 |
| 6. Internalize state | Deprecations | Low (follow deprecation) | P2 |
| 9. Naming parity | Mechanical | Zero | P2 |
| 10e. Performance telemetry | No | Zero | P2 — diagnostics |

**P0 phases** must ship before Teams can integrate at all. They are all additive.
**P1 phases** improve the integration but Teams can ship without them.
**P2 phases** are cleanup that follows naturally.

---

## Verification

1. **Compile**: `cd ios && swift build` and `cd android && ./gradlew build` after each phase
2. **Tests**: `cd ios && swift test` and `cd android && ./gradlew test` — all existing tests pass
3. **Snapshot tests**: `xcodebuild test -only-testing:VisualTests/CardElementSnapshotTests`
4. **Sample app migration**: Port sample app to new API to validate ergonomics
5. **UIKit bridge test**: Embed `AdaptiveCardUIView` in a UIKit ViewController, verify rendering + actions + input collection
6. **Android View bridge test**: Embed `AdaptiveCardAndroidView` in a Fragment, verify rendering + actions
7. **Adapter test**: Use `LegacyActionHandler` adapter, verify all action types route correctly
8. **ImageProvider test**: Inject a mock `ImageProvider`, verify images load through it instead of default
9. **Cache test**: Parse same card twice, verify second is a cache hit (parseTimeMs == 0). Load same image twice, verify single network fetch.
10. **Prefetch test**: Call `AdaptiveCards.prefetch([json1, json2])`, then render — verify zero parse time and cached images
11. **Memory pressure test**: Fill image cache to limit, simulate memory warning, verify cache trimmed and no crash
12. **Guardrail test**: Render a card with 500 elements, verify it's capped at `maxElementCount` and doesn't freeze the UI
13. **Performance telemetry test**: Render a card with images, verify `.performanceReport` event fires with accurate metrics
