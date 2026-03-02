# Agent Handoff: Apply Gate Pattern to AdaptiveCards-Mobile Fork

> **From**: DevBox agent (Hugo's dev environment)
> **To**: Next agent picking up AC Mobile work
> **Date**: 2026-02-28
> **Pattern reference**: `docs/AGENT_GATE_PLAYBOOK.md`

---

## Your Mission

Apply the **proxy branch + agent validation gate** pattern to continue development on `hggzm/AdaptiveCards-Mobile` (a fork of `VikrantSingh01/AdaptiveCards-Mobile`). The infrastructure is already built and passing. Your job is to **use it as your feedback loop** while implementing new features or fixes.

---

## What Already Exists

### Repository State

| Item | Value |
|------|-------|
| **Fork** | `hggzm/AdaptiveCards-Mobile` |
| **Upstream** | `VikrantSingh01/AdaptiveCards-Mobile` |
| **Branch** | `proxy/integration` |
| **HEAD** | `cb62f61` |
| **Draft PR** | #42 (`hggzm:proxy/integration` → `VikrantSingh01:main`) |
| **Gate workflow** | `.github/workflows/agent-gate.yml` |
| **Gate status** | ✅ All required gates PASSING |

### Remotes (in local clone `~/code/AdaptiveCards-Mobile`)

| Remote | URL | Access |
|--------|-----|--------|
| `upstream` | `VikrantSingh01/AdaptiveCards-Mobile` | Read |
| `origin` | `hggz/AdaptiveCards-Mobile-1` | Read-only for hggzm |
| `myfork` | `hggzm/AdaptiveCards-Mobile` | **Push (admin)** |

### PRs Already Integrated

| PR | Branch | Description |
|----|--------|-------------|
| #33 | test-cards-expansion | 481 test card JSONs |
| #35 | expression-engine-hardening | ExpressionCache, ExpressionEngine |
| #37 | copilot-streaming-enhancements | ChainOfThought + Streaming (flagged) |
| #34 | hostconfig-full-parity | HostConfig expansion |
| #36 | advanced-layouts | FlowLayout + AreaGridLayout |
| #40 | action-overflow-parity | Action overflow menu |
| #39 | visual-parity-improvements | Superset of #38 (flagged) |

### Feature Flags (all default `false`)

| Flag | Scope |
|------|-------|
| `enableCopilotStreamingExtensions` | ChainOfThought + Streaming views |
| `useParityFontMetrics` | TextBlockView, RichTextBlockView |
| `useParityLayoutFixes` | ContainerView, ColumnView, ColumnSetView |
| `useParityImageBehavior` | ImageView |
| `useParityElementStyling` | FactSetView, TableView, ActionButton |

---

## How to Work

### 1. Clone and Verify

```bash
cd ~/code/AdaptiveCards-Mobile
git checkout proxy/integration
git fetch --all
git log --oneline -5

# Verify remotes
git remote -v
# Should show: upstream, origin, myfork
```

### 2. Verify Gate is Passing

```bash
gh run list --repo hggzm/AdaptiveCards-Mobile --workflow agent-gate.yml --limit 1 --json conclusion
# Must show: [{"conclusion":"success"}]
```

If the gate is NOT passing, fix it before starting new work. The gate is your baseline.

### 3. Make Changes

Work directly on `proxy/integration`. For each logical change:

```bash
# Edit files
# ...

# Commit
git add -A
git commit -m "feat: <description>"

# Push
git push myfork proxy/integration
```

### 4. Wait for Gate (~5 minutes)

```bash
# Poll for completion
sleep 300
gh run list --repo hggzm/AdaptiveCards-Mobile --workflow agent-gate.yml --limit 1

# If failed, read the logs
RUN_ID=$(gh run list --repo hggzm/AdaptiveCards-Mobile --workflow agent-gate.yml --limit 1 --json databaseId --jq '.[0].databaseId')
gh run view $RUN_ID --repo hggzm/AdaptiveCards-Mobile --log-failed 2>&1 | tail -50
```

### 5. Fix Until Green

If the gate fails:
1. Read the failed job logs
2. Identify the error (compile error, test failure, lint issue)
3. Fix it
4. Commit + push
5. Wait for gate again
6. Repeat until PASS

### 6. Update Tracking

After your changes pass the gate:

```bash
# Update docs/PROXY_BRANCH_TRACKER.md with your changes
# Update CHANGELOG.md
git add docs/ CHANGELOG.md
git commit -m "docs: update tracker with <your changes>"
git push myfork proxy/integration
```

---

## Gate Details

### Required Gates (must pass for verdict = PASS)

| Gate | What It Checks |
|------|----------------|
| `json-validation` | All JSON files in `shared/test-cards/` parse correctly |
| `ios-unit-tests` | `xcodebuild test` for ACCore, ACRendering, ACInputs, ACTemplating, ACMarkdown, ACCharts, IntegrationTests |
| `android-unit-tests` | `./gradlew testDebugUnitTest` |
| `parity-check` | Schema coverage, feature flag parity, test card symlinks |

### Advisory Gates (logged but don't block)

| Gate | What It Checks | Why Advisory |
|------|----------------|--------------|
| `ios-parse-validation` | AllCardsDiscoveryTests | Known `fatalError` in some card types |
| `ios-visual-tests` | 732 snapshot baseline comparisons | Environment-sensitive |
| `android-visual-tests` | Paparazzi verify | No recorded baselines yet |
| `lint-swift` | SwiftLint warnings | Warnings only, not errors |
| `lint-kotlin` | Android lint | Warnings only, not errors |

### Typical Gate Runtime

| Stage | Time |
|-------|------|
| Stage 1 (lint + JSON) | ~30s–4min |
| Stage 2 (unit tests) | ~1–3.5min |
| Stage 3 (visual) | ~1–4.5min |
| Stage 4 (parity) | ~7s |
| **Total** (parallel) | **~5 min** |

---

## Files to Read First

Read these before starting work (in order):

1. `docs/PROXY_BRANCH_TRACKER.md` — current merge state, CI results, bug fix log
2. `docs/AGENT_PROXY_WORKFLOW.md` — operating procedures (adding PRs, syncing, conflict resolution)
3. `docs/AGENT_GATE_PLAYBOOK.md` — how the gate was built, how to replicate
4. `CLAUDE.md` or `.github/copilot-instructions.md` — build commands, module layout, test commands
5. `CHANGELOG.md` — recent change history

---

## Common Pitfalls

| Pitfall | How to Avoid |
|---------|--------------|
| Pushing to `origin` instead of `myfork` | Always `git push myfork proxy/integration` |
| Not checking gate before starting work | Always verify gate is green first |
| Editing files via shell heredocs on WSL | Use Python scripts instead |
| Building only one platform | Gate checks both iOS AND Android |
| Forgetting to update tracker | Always commit tracker updates after gate passes |
| Adding a feature flag on one platform only | Flags MUST exist on both iOS (Swift) and Android (Kotlin) |
| `xcodebuild` builds ALL targets | Even with `--only-testing`, compile errors in any target cause failure |

---

## Extending the Gate

To add a new gate stage:

1. Add a new job to `.github/workflows/agent-gate.yml`
2. Decide if it's **required** or **advisory**
3. If required, add it to the `gate-verdict` job's `needs` list AND add a pass check in the verdict script
4. If advisory, add it to `needs` but only log its result (don't fail)
5. Push and verify the gate still passes

---

## Creating a New Proxy Branch for Different Work

If you need a separate proxy branch (e.g., for a different feature set):

```bash
git checkout -b proxy/<your-work-name> upstream/main
# Integrate relevant PRs
git push myfork proxy/<your-work-name>
```

The `agent-gate.yml` already triggers on all `proxy/**` branches.

---

## Handing Off to the Next Agent

When you're done, update this checklist and include it in your handoff:

- [ ] Current `proxy/integration` HEAD SHA: `________`
- [ ] Gate status: PASS / FAIL (run ID: `________`)
- [ ] New PRs added to proxy: (list)
- [ ] New feature flags added: (list)
- [ ] Pending issues or known failures: (list)
- [ ] `PROXY_BRANCH_TRACKER.md` up to date: YES / NO
- [ ] `CHANGELOG.md` up to date: YES / NO
