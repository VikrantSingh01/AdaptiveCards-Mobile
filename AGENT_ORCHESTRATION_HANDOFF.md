# Agent Orchestration Handoff — AdaptiveCards-Mobile

## Your Mission

You are taking over the **agent orchestration loop** for the `VikrantSingh01/AdaptiveCards-Mobile` repository. Your job is to:

1. **Create GitHub issues** assigned to Copilot and Claude coding agents
2. **Monitor PRs** the agents create in response
3. **Enforce test requirements** — comment on agent PRs that don't pass tests
4. **Iterate** — provide feedback until agent PRs are mergeable
5. **Report status** back periodically

The human developer (Hugo / `hggz`) focuses on coding and opening PRs directly. You handle the agent coordination.

---

## Repository Details

| Field | Value |
|---|---|
| **Upstream repo** | `VikrantSingh01/AdaptiveCards-Mobile` |
| **Fork** | `hggz/AdaptiveCards-Mobile-1` |
| **Local path** | `/Users/hugogonzalez/Documents/code/work/microsoft/hggz-AdaptiveCards-Mobile` |
| **Branch with orchestrator** | `feature/visual-testing-activation` (PR #38) |
| **GitHub CLI auth** | `gh` authenticated as `hggz` (active account) |
| **SSH key** | `~/.ssh/id_github_hggz` (for git push, warning about missing file is benign — default SSH key works) |

### Agents Available

| Agent | How to assign | How to mention | Branch prefix |
|---|---|---|---|
| **GitHub Copilot SWE Agent** | Label issue `copilot` | `@copilot` in issue body | `copilot/*` |
| **Claude Code** | Label issue `claude` | `@claude` in issue body | (varies) |
| **Copilot PR Reviewer** | Automatic on PRs | N/A | N/A |

Both agents read instruction files:
- Copilot reads `.github/copilot-instructions.md`
- Claude reads `CLAUDE.md`

Both files now include **Visual Snapshot Test Requirements** with critical rules.

### GitHub Permissions

- `hggz` has **pull** access on upstream (can create issues, comment on PRs, but NOT push)
- `hggz` has **admin** on fork `hggz/AdaptiveCards-Mobile-1`
- Issues are enabled on upstream (currently 6 open issues)
- PRs target upstream `main` from fork branches

---

## The Orchestrator Tool

**Location**: `scripts/agent_orchestrator.py` (in the repo, on `feature/visual-testing-activation` branch)

### Commands Reference

```bash
cd /Users/hugogonzalez/Documents/code/work/microsoft/hggz-AdaptiveCards-Mobile

# === STATUS ===
python3 scripts/agent_orchestrator.py status
# Shows: open issues by agent, PR list, CI health

# === CREATE ISSUES ===
# Single issue
python3 scripts/agent_orchestrator.py create-issue \
  --agent copilot \
  --title "fix(ci): Add CodeSign flags to CI" \
  --body "Description here..." \
  --platform ci \
  --acceptance "Tests pass in CI" "No regressions"

# Batch create from task file
python3 scripts/agent_orchestrator.py batch-create --file scripts/agent_tasks.json

# Dry-run first (always recommended)
python3 scripts/agent_orchestrator.py --dry-run batch-create --file scripts/agent_tasks.json

# === MONITOR PRs ===
python3 scripts/agent_orchestrator.py list-prs
python3 scripts/agent_orchestrator.py check-pr --pr 39

# === ENFORCE TESTS ===
# Check all agent PRs and comment on failing ones
python3 scripts/agent_orchestrator.py enforce-tests

# Enforce on a specific PR
python3 scripts/agent_orchestrator.py enforce-tests --pr 39

# === COMMENT ON PRs ===
python3 scripts/agent_orchestrator.py comment-pr --pr 39 --body "Please fix X"
python3 scripts/agent_orchestrator.py comment-pr --pr 39 --enforce  # Posts test requirements
```

### Task File

**Location**: `scripts/agent_tasks.json`

Contains 5 pre-built tasks ready to be created as issues. Here's the summary:

| # | Agent | Title | Platform |
|---|---|---|---|
| 1 | copilot | fix(ci): Add CODE_SIGNING_ALLOWED=NO flags to visual-regression.yml | ci |
| 2 | claude | fix(ios): Fix ColumnSet rendering in snapshot tests | ios |
| 3 | copilot | fix(ios): Investigate and fix full VisualTests suite timeout | ios |
| 4 | claude | fix(android): Investigate Android Paparazzi screenshot quality | android |
| 5 | copilot | feat(ios): Commit remaining 692 baseline PNGs | ios |

---

## Test Requirements (What You Must Enforce)

Every agent PR that touches rendering or test code **must** pass:

### iOS Snapshot Tests (Critical)
```bash
cd ios && xcodebuild test \
  -scheme AdaptiveCards-Package \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16e' \
  -only-testing:VisualTests/CardElementSnapshotTests \
  CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```
**Expected**: 10/10 pass. Baselines match within tolerance.

### iOS Unit Tests
```bash
cd ios && swift test
```

### Android Unit Tests
```bash
cd android && ./gradlew test
```

### Hard Rules for Snapshot Code
These were discovered through painful debugging. If an agent violates them, the snapshots will be blank:

1. **NO `ScrollView`** in `PreParsedCardView` — defeats `systemLayoutSizeFitting` (returns 0 height)
2. **NO `LazyVStack`** — defers rendering, content not in layer tree during capture
3. **NO `@StateObject`** — SwiftUI lifecycle doesn't fire during `layer.render`
4. **MUST use `VStack`** with synchronous `CardViewModel` property
5. **MUST include CodeSign flags** — `CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`
6. **`drawHierarchy` returns `false`** in SPM XCTest — this is expected, `layer.render` fallback works

### Baseline Recording Workflow
If rendering code changes:
1. `touch ios/Tests/VisualTests/Snapshots/.record`
2. Run snapshot tests → records new baselines
3. `rm ios/Tests/VisualTests/Snapshots/.record`
4. Run again → verify mode (compare)
5. Commit `.png` baselines

---

## Your Workflow Loop

### Phase 1: Create Issues
```bash
# First, dry-run to preview
python3 scripts/agent_orchestrator.py --dry-run batch-create --file scripts/agent_tasks.json

# If everything looks good, create for real
python3 scripts/agent_orchestrator.py batch-create --file scripts/agent_tasks.json
```

### Phase 2: Monitor (run periodically)
```bash
# Check status
python3 scripts/agent_orchestrator.py status

# See if agents have created PRs
python3 scripts/agent_orchestrator.py list-prs

# Check specific agent PR
python3 scripts/agent_orchestrator.py check-pr --pr <N>
```

### Phase 3: Enforce & Iterate
```bash
# Auto-enforce on all agent PRs
python3 scripts/agent_orchestrator.py enforce-tests

# If an agent PR needs specific feedback
python3 scripts/agent_orchestrator.py comment-pr --pr <N> \
  --body "The ColumnSet fix looks good but you broke testDarkModeRendering. The baseline shows no dark background — check that you're setting .colorScheme(.dark) in the environment modifier."
```

### Phase 4: Report
After each iteration, report back to the human with:
- Which issues were created (issue numbers + URLs)
- Which PRs the agents opened (PR numbers)
- CI/test status per PR
- What feedback was given
- What's still pending

---

## Current State (as of 2026-02-14)

### What's Done
- PR #38 (`feature/visual-testing-activation`) — visual testing pipeline with working iOS snapshots
  - 3 commits: initial pipeline, rendering fix, orchestrator + enforcement
  - 10/10 CardElementSnapshotTests pass (iOS)
  - 23/27 baselines have visible content (4 empty: 3 ColumnSet, 1 Image)
  - Orchestrator script + task file committed and pushed

### Open PRs (all from hggz)
| PR | Branch | Description |
|---|---|---|
| #33 | feature/test-cards-expansion | 481 production test cards |
| #34 | feature/hostconfig-full-parity | Full HostConfig parity |
| #35 | feature/expression-engine-hardening | Expression engine caching + protection |
| #36 | feature/advanced-layouts | FlowLayout + AreaGridLayout |
| #37 | feature/copilot-streaming-enhancements | CoT + typing indicators |
| #38 | feature/visual-testing-activation | Visual regression pipeline + orchestrator |

### What's Needed From Agents
The 5 tasks in `agent_tasks.json` (described above). Priority order:
1. **CI fix** (CodeSign flags) — unlocks CI for all future PRs
2. **ColumnSet rendering** — fixes blank baselines
3. **VisualTests timeout** — makes full test suite usable
4. **Android Paparazzi** — validates Android screenshot quality
5. **Commit baselines** — completes the baseline set

---

## Troubleshooting

### "Must have push access to view repository collaborators" (403)
Normal — `hggz` only has pull access on upstream. We can create issues and comment on PRs but can't manage collaborators.

### Agent doesn't respond to issue
- Verify the issue has the correct label (`copilot` or `claude`)
- Verify the issue body contains the agent mention (`@copilot` or `@claude`)
- The agent may take minutes to hours to pick up an issue
- Try commenting on the issue with the mention again

### Agent PR has no CI checks
The upstream repo may not have GitHub Actions runners configured for fork PRs. This is common. Use `enforce-tests` to post manual test instructions.

### Python version
The system Python from Xcode may be 3.9. The orchestrator uses `from __future__ import annotations` for compatibility. Don't add `str | None` style hints without this import.

### SSH key warning
`Warning: Identity file ~/.ssh/id_github_hggz not accessible` appears on push but is benign — the default SSH key works fine.
