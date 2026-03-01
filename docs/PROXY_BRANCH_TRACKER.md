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

## CI/Test Strategy — Agent Validation Gate ✅

> **Workflow**: `.github/workflows/agent-gate.yml`
> **Fork**: `hggzm/AdaptiveCards-Mobile` (Actions enabled, admin access)
> **Status**: All required gates PASSING as of commit `2bf219e`
> **Run**: [22536015609](https://github.com/hggzm/AdaptiveCards-Mobile/actions/runs/22536015609)

### Gate Architecture (4 Stages, parallel)

| Stage | Job | Status | Time | Required |
|-------|-----|--------|------|----------|
| 1a | Validate Test Card JSON | ✅ Pass | ~26s | Yes |
| 1b | SwiftLint | ✅ Pass | ~15s | Advisory |
| 1c | Kotlin Lint | ✅ Pass | ~4m20s | Advisory |
| 2a | iOS Unit Tests (xcodebuild) | ✅ Pass | ~3m21s | **Yes** |
| 2b | iOS Parse Validation | ⚠️ Advisory | ~33s | No (known fatalError) |
| 2c | Android Unit Tests | ✅ Pass | ~1m6s | **Yes** |
| 3a | iOS Visual Regression (732 baselines) | ✅ Pass | ~4m25s | Advisory |
| 3b | Android Visual Regression (Paparazzi) | ✅ Pass | ~50s | Advisory |
| 4 | Cross-Platform Parity | ✅ Pass | ~7s | **Yes** |
| — | **GATE VERDICT** | ✅ **PASSED** | ~2s | — |

### Agent Usage
```bash
# Check gate status for latest push
gh run list --repo hggzm/AdaptiveCards-Mobile --workflow agent-gate.yml --limit 1 --json conclusion
# → {"conclusion": "success"} means gate PASSED

# Trigger manual run (e.g., to record new baselines)
gh workflow run agent-gate.yml --repo hggzm/AdaptiveCards-Mobile -f record_baselines=true
```

### Workflow Triggers
- Push to `proxy/**` or `main`
- Pull requests to `main` or `proxy/**`
- Manual dispatch with optional `record_baselines` flag

### Bug Fixes Required to Pass Gate

The following pre-existing bugs were fixed to get the gate passing:

| File | Fix | Commit |
|------|-----|--------|
| `ios-tests.yml` | YAML indentation in embedded Python block | `7123e14` |
| `Action.Execute.With.RegexValidation.json` | Invalid JSON escape `\.` | `cb3292f` |
| `HostConfig.swift` (InputLabelConfig) | Remove non-existent `maxWidth` property | `cb3292f` |
| `HostConfig.swift` (FactSetTextConfig) | Restore accidentally removed `maxWidth` init | `8658d13` |
| `CopilotExtensionTypes.kt` | Move import from line 55 to file header | `cb3292f` |
| `ChainOfThoughtView.swift` | Missing closing brace for else block | `3324f86` |
| `StreamingTextView.swift` | Missing closing brace + `fontTypes.defaultFont` fix | `3324f86`, `c8c4a7a` |
| `CopilotReferenceView.swift` | Non-exhaustive switch (4 missing cases) | `3324f86` |
| `StreamingCardView.swift` | `error.localizedDescription` on String type | `3324f86` |
| `AreaGridLayoutView.swift` | Missing `import ACCore` + `defaultSpacing` fix | `6a16dda`, `ba9c259` |
| `FlowLayoutView.swift` | Missing `import ACCore` + `HorizontalAlignment` ambiguity + `defaultSpacing` | `6a16dda`, `ba9c259` |
| `ColumnSetView.swift` | `Layout` protocol ambiguity → `SwiftUI.Layout` | `6a16dda` |
| `FactSetView.swift` | `CGFloat(String)` → fontSize resolver helper | `ba9c259` |
| `SnapshotTestCase.swift` | `MainActor.assumeIsolated` iOS 17 availability | `aedbb36` |
| `HostConfig.swift` (FontSizesConfig) | Default font size 12 → 14 | `2bf219e` |
