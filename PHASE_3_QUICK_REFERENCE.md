# Phase 3 Quick Reference

## Module Structure

### iOS Modules
```
ios/Sources/
├── ACCopilotExtensions/
│   ├── CopilotExtensionTypes.swift
│   ├── CitationView.swift
│   ├── CopilotReferenceView.swift
│   └── StreamingCardView.swift
└── ACTeams/
    ├── TeamsTypes.swift
    ├── DeepLinkHandler.swift
    ├── TaskModulePresenter.swift
    ├── StageViewPresenter.swift
    ├── TeamsCardHost.swift
    └── TeamsFluentTheme.swift
```

### Android Modules
```
android/
├── ac-copilot-extensions/
│   ├── build.gradle.kts
│   └── src/main/kotlin/com/microsoft/adaptivecards/copilot/
│       ├── CopilotExtensionTypes.kt
│       ├── CitationView.kt
│       ├── CopilotReferenceView.kt
│       └── StreamingCardView.kt
└── ac-teams/
    ├── build.gradle.kts
    └── src/main/kotlin/com/microsoft/adaptivecards/teams/
        ├── TeamsTypes.kt
        ├── DeepLinkHandler.kt
        ├── TaskModulePresenter.kt
        ├── StageViewPresenter.kt
        ├── TeamsCardHost.kt
        └── TeamsFluentTheme.kt
```

## New Action Types

### 1. Action.Popover
```json
{
  "type": "Action.Popover",
  "title": "Show Details",
  "popoverTitle": "More Information",
  "popoverBody": [...],
  "dismissBehavior": "manual"
}
```

### 2. Action.RunCommands
```json
{
  "type": "Action.RunCommands",
  "title": "Execute",
  "commands": [
    {"type": "navigate", "id": "nav1", "data": {...}},
    {"type": "refresh", "id": "refresh1"}
  ]
}
```

### 3. Action.OpenUrlDialog
```json
{
  "type": "Action.OpenUrlDialog",
  "title": "Open in Browser",
  "url": "https://example.com",
  "dialogTitle": "Browser"
}
```

## ActionSet Overflow Mode

```json
{
  "type": "ActionSet",
  "mode": "overflow",
  "actions": [...]
}
```

- `mode: "default"` - Traditional button layout
- `mode: "overflow"` - Dropdown menu

## Copilot Extensions Usage

### iOS
```swift
import ACCopilotExtensions

// Citation
CitationView(
    citation: Citation(id: "1", title: "Source", url: "...", snippet: "...", index: 1),
    onTap: { /* handle tap */ }
)

// Reference
CopilotReferenceView(
    reference: Reference(id: "1", title: "Doc", type: .file)
)

// Streaming
StreamingCardView(
    streamingState: .streaming,
    partialContent: [...]
)
```

### Android
```kotlin
import com.microsoft.adaptivecards.copilot.*

// Citation
CitationView(
    citation = Citation(id = "1", title = "Source", index = 1),
    onTap = { /* handle tap */ }
)

// Reference
CopilotReferenceView(
    reference = Reference(id = "1", title = "Doc", type = ReferenceType.FILE)
)

// Streaming
StreamingCardView(
    streamingState = StreamingState.Streaming,
    partialContent = listOf(...)
)
```

## Teams Integration Usage

### iOS
```swift
import ACTeams

TeamsCardHost(
    card: adaptiveCard,
    theme: .light,
    tokenProvider: myTokenProvider,
    deepLinkHandler: DeepLinkHandler()
) {
    AdaptiveCardView(card: card)
}

// Deep link handling
let handler = DeepLinkHandler()
if let deepLink = handler.parseDeepLink(url) {
    handler.handleNavigation(deepLink)
}

// Task module
let presenter = TaskModulePresenter()
presenter.present(url: url, title: "Task")
```

### Android
```kotlin
import com.microsoft.adaptivecards.teams.*

TeamsCardHost(
    card = adaptiveCard,
    theme = TeamsTheme.LIGHT,
    tokenProvider = myTokenProvider,
    deepLinkHandler = DeepLinkHandler()
) {
    AdaptiveCardView(card = card)
}

// Deep link handling
val handler = DeepLinkHandler()
val deepLink = handler.parseDeepLink(uri)
deepLink?.let { handler.handleNavigation(it) }

// Task module
val presenter = TaskModulePresenter(activity)
presenter.present(url = url, title = "Task")
```

## Test Cards

All test cards are in `shared/test-cards/`:

1. **popover-action.json** - Demonstrates 3 new action types
2. **split-buttons.json** - Shows default and overflow ActionSet modes
3. **copilot-citations.json** - Citation examples
4. **streaming-card.json** - Progressive rendering demo
5. **teams-task-module.json** - Teams integration examples

## Build Configuration

### iOS Package.swift
```swift
.library(name: "ACCopilotExtensions", targets: ["ACCopilotExtensions"]),
.library(name: "ACTeams", targets: ["ACTeams"]),
```

### Android settings.gradle.kts
```kotlin
include(":ac-copilot-extensions")
include(":ac-teams")
```

## Key Features

### Advanced Actions
- Popover modals for contextual content
- Multi-command execution
- In-app browser dialogs

### Menu Actions
- Overflow dropdown for action lists
- Split button foundation
- Responsive action layouts

### Copilot Extensions
- Citation markers with expandable details
- File/URL reference cards
- Progressive streaming support

### Teams Integration
- SSO token injection
- Deep link parsing (msteams://)
- Task module presentation
- Stage view (full screen)
- Theme synchronization (light/dark/HC)

## Documentation

See **PHASE_3_COMPLETION_REPORT.md** for:
- Complete implementation details
- Cross-platform consistency
- Integration guidelines
- Architecture notes
