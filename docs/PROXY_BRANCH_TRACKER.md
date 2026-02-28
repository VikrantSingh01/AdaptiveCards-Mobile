# Proxy Integration Branch — PR Merge Tracker

> **Branch**: `proxy/integration`  
> **Base**: `upstream/main` @ `fdd0e30` (includes merged PR #41: SDK integration readiness)  
> **Purpose**: Pre-merge integration branch that combines all open feature PRs for unified testing before merging to upstream `main`.  
> **Owner**: hggz  
> **Created**: 2025-07-22

---

## Merge Order & Status

| Order | PR # | Branch | Description | SHA | Status | Conflicts |
|-------|------|--------|-------------|-----|--------|-----------|
| 1 | #33 | `feature/test-cards-expansion` | 481 test card JSONs corpus | `19b14ce` | Merged | None |
| 2 | #35 | `feature/expression-engine-hardening` | ExpressionCache, ExpressionEngine, ConversionFunctions | `d6d3068` | Merged | None |
| 3 | #37 | `feature/copilot-streaming-enhancements` | ChainOfThought + Streaming models/views | `ccb0a67` | Merged | None |
| 4 | #34 | `feature/hostconfig-full-parity` | HostConfig expansion (333 to 743 lines) | `0591002` | Merged | None |
| 5 | #36 | `feature/advanced-layouts` | FlowLayout + AreaGridLayout | `8ff220c` | Merged | None |
| 6 | #40 | `feat/action-overflow-parity` | Action overflow menu | `e33caf1` | Merged | None (auto-resolved) |
| 7 | #39 | `feature/visual-parity-improvements` | Visual testing + parity fixes (superset of #38) | `1e8c7fd` | Merged | HostConfig.swift |

> **Conflict resolution (PR #39)**: `ios/Sources/ACCore/HostConfig/HostConfig.swift` — PR #34 expanded `FactSetTextConfig` to 7 fields with custom decoder; PR #39 had simplified 3-field version. Kept PR #34's expanded version as it provides full HostConfig parity.

---

## Dependency Graph

```
upstream/main (fdd0e30)
  └── proxy/integration
        ├── PR #33 (test-cards) ─────── INDEPENDENT
        ├── PR #35 (expression) ─────── INDEPENDENT
        ├── PR #37 (copilot/CoT) ────── INDEPENDENT  ⚑ Feature-flagged
        ├── PR #34 (hostconfig) ─────── overlaps #39 on HostConfig.swift
        ├── PR #36 (layouts) ────────── overlaps #39 on ContainerTypes.swift
        ├── PR #40 (action-overflow) ── overlaps #39 on ActionSetView.swift
        └── PR #39 (visual-parity) ──── SUPERSET of #38  ⚑ Feature-flagged
```

**PR #38 note**: Not merged separately. PR #39 contains all 6 commits from PR #38 plus 2 additional visual parity fix commits.

---

## Feature Flags

Two categories of changes are gated behind feature flags (all `false` by default):

### 1. Copilot Streaming Extensions (`enableCopilotStreamingExtensions`)
- **Scope**: PR #37 — ChainOfThought + Streaming models/views
- **iOS files**: ChainOfThoughtModels.swift, ChainOfThoughtView.swift, StreamingModels.swift, StreamingTextView.swift
- **Android files**: ChainOfThoughtModels.kt, ChainOfThoughtView.kt, StreamingModels.kt, StreamingTextView.kt
- **CopilotExtensionTypes**: Swift and Kotlin updated with new type registrations

### 2. Visual Parity Flags (PR #39 delta over #38)
- `useParityFontMetrics` — TextBlockView, RichTextBlockView font sizing/line-height
- `useParityLayoutFixes` — ContainerView, ColumnView, ColumnSetView padding/spacing
- `useParityImageBehavior` — ImageView sizing/aspect-ratio behavior
- `useParityElementStyling` — FactSetView, TableView, ActionButton, RichTextBlockView styling

---

## Syncing with Upstream

```bash
# Merge latest upstream/main into proxy branch
git fetch upstream
git checkout proxy/integration
git merge upstream/main

# Or rebase (cleaner history, but rewrites SHAs)
git rebase upstream/main
```

---

## CI/Test Strategy (Planned)

1. **Build verification**: iOS (xcodebuild) + Android (Gradle) compile checks
2. **Unit tests**: Feature flags OFF (baseline) and ON (new behavior)
3. **Visual regression**: Snapshot tests from PR #38/#39 infra (flags ON)
4. **Integration**: Test card corpus from PR #33 renders without crash
5. **Flag matrix**: CI should test both flags-OFF and flags-ON configurations
