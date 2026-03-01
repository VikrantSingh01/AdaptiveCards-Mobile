# Agent Gate Playbook — Proxy Branch + CI Feedback Loop

> **Audience**: AI coding agents replicating this pattern in other repositories
> **Pattern origin**: `hggzm/AdaptiveCards-Mobile`, branch `proxy/integration`
> **Last validated**: 2026-02-28 (Agent Gate run 22536015609 — all required gates PASSED)

---

## 1. What This Pattern Is

A **proxy branch** paired with an **automated validation gate** that gives agents a stable, isolated environment to:
- Integrate multiple in-flight PRs ahead of mainline
- Iterate on cross-cutting changes without destabilizing `main`
- Get deterministic pass/fail feedback on every push (unit tests, visual regression, lint, parity)
- Build confidence before merging to production

The key insight: **agents need a tight feedback loop**. Without one, they accumulate errors silently. This pattern makes every push produce a clear PASS or FAIL verdict within minutes.

---

## 2. Architecture

```
upstream/main ◄─── individual PRs merged here after review
     │
     └── proxy/integration (fork, pushable)
              │
              ├── All PRs pre-merged here
              ├── Feature flags gate risky changes
              ├── agent-gate.yml runs on every push
              │     ├── Stage 1: Lint + JSON validation (parallel)
              │     ├── Stage 2: Unit tests iOS + Android (parallel)
              │     ├── Stage 3: Visual regression iOS + Android (parallel)
              │     ├── Stage 4: Cross-platform parity checks
              │     └── GATE VERDICT: pass/fail (single signal)
              │
              └── Draft PR → main (for eventual merge)
```

### Why a Fork, Not a Branch on Upstream

| Concern | Solution |
|---------|----------|
| CI costs on upstream | Fork runs its own Actions (free tier) |
| Permission model | Agent has admin on fork, not upstream |
| Branch protection | Fork has none — agent can push freely |
| Isolation | Upstream collaborators aren't impacted by agent iterations |

---

## 3. Setting Up the Pattern (Step-by-Step)

### 3.1 Fork Setup

```bash
# Create a fork with admin access
gh repo fork <upstream-repo> --clone=false --org <your-org-or-user>

# Clone and configure remotes
git clone <fork-url> && cd <repo>
git remote add upstream <upstream-url>
git remote rename origin myfork
git fetch --all
```

### 3.2 Create the Proxy Branch

```bash
git checkout -b proxy/integration upstream/main
git push myfork proxy/integration
```

### 3.3 Integrate Existing PRs

Merge each PR branch in dependency order:

```bash
git merge --no-ff <remote>/<pr-branch> -m "Merge PR #N: <description>"
```

Document each merge in a tracker file (see Section 5).

### 3.4 Add Feature Flags (If Needed)

For changes that alter visual/behavioral output:

1. Create `AdaptiveCardFeatureFlags.swift` / `.kt` with boolean flags defaulting to `false`
2. Guard affected views/logic with flag checks
3. Document flags in tracker

### 3.5 Create the Agent Validation Gate

Create `.github/workflows/agent-gate.yml` with this structure:

```yaml
name: Agent Validation Gate
on:
  push:
    branches: ['proxy/**', 'main']
  pull_request:
    branches: ['main', 'proxy/**']
  workflow_dispatch:
    inputs:
      record_baselines: { type: boolean, default: false }

jobs:
  # Stage 1: Fast checks (parallel, no dependencies)
  json-validation: ...
  lint-swift: ...
  lint-kotlin: ...

  # Stage 2: Unit tests (parallel, independent of stage 1)
  ios-unit-tests: ...
  android-unit-tests: ...

  # Stage 3: Visual regression (parallel, independent)
  ios-visual-tests: ...
  android-visual-tests: ...

  # Stage 4: Cross-platform parity
  parity-check: ...

  # Final: Single pass/fail verdict
  gate-verdict:
    needs: [json-validation, ios-unit-tests, android-unit-tests, parity-check,
            ios-visual-tests, android-visual-tests, lint-swift, lint-kotlin]
    if: always()
    steps:
      - name: Evaluate gate
        run: |
          # Required gates (must pass)
          REQUIRED_PASS=true
          [[ "${{ needs.json-validation.result }}" != "success" ]] && REQUIRED_PASS=false
          [[ "${{ needs.ios-unit-tests.result }}" != "success" ]] && REQUIRED_PASS=false
          [[ "${{ needs.android-unit-tests.result }}" != "success" ]] && REQUIRED_PASS=false
          [[ "${{ needs.parity-check.result }}" != "success" ]] && REQUIRED_PASS=false

          # Advisory gates (logged but don't block)
          echo "Advisory: ios-visual=${{ needs.ios-visual-tests.result }}"
          echo "Advisory: android-visual=${{ needs.android-visual-tests.result }}"

          if [[ "$REQUIRED_PASS" == "true" ]]; then
            echo "✅ GATE VERDICT: PASSED"
          else
            echo "❌ GATE VERDICT: FAILED"
            exit 1
          fi
```

**Key design decisions:**
- **Stages are independent** — visual tests don't wait for unit tests. Everything runs in parallel.
- **Required vs Advisory** — Separate genuinely blocking checks from informational ones. Don't let a flaky visual test block all progress.
- **Single verdict job** — Agents check one thing: did `gate-verdict` pass?

### 3.6 Enable Actions on Fork

```bash
# Ensure Actions are enabled with all actions allowed
gh api repos/<owner>/<repo>/actions/permissions -X PUT \
  -f enabled=true -f allowed_actions=all
```

### 3.7 Update All Existing Workflows

Add `proxy/**` to branch triggers in every existing workflow:

```yaml
on:
  push:
    branches: ['main', 'proxy/**']   # ← add proxy/**
  pull_request:
    branches: ['main', 'proxy/**']   # ← add proxy/**
```

### 3.8 Open Draft PR

```bash
gh pr create --repo <upstream-repo> \
  --head <fork-owner>:proxy/integration --base main \
  --title "Proxy Integration Branch" --draft \
  --body "See docs/PROXY_BRANCH_TRACKER.md for merge order and status."
```

---

## 4. The Iteration Cycle

This is the day-to-day workflow an agent follows:

```
┌──────────────────────────────────────────────────────────────┐
│  1. Make changes on proxy/integration                       │
│  2. Commit + push to myfork                                 │
│  3. Wait for agent-gate.yml to complete (~5-10 min)         │
│  4. Check verdict:                                          │
│     gh run list --repo <fork> --workflow agent-gate.yml     │
│       --limit 1 --json conclusion                           │
│  5a. PASSED → commit docs, move on                          │
│  5b. FAILED → read logs, fix, go to step 2                  │
└──────────────────────────────────────────────────────────────┘
```

### Checking Gate Status (Agent Commands)

```bash
# Quick check: did the last run pass?
gh run list --repo <fork> --workflow agent-gate.yml --limit 1 --json conclusion
# → [{"conclusion":"success"}] means PASSED

# Get the run ID for detailed inspection
gh run list --repo <fork> --workflow agent-gate.yml --limit 1 --json databaseId

# View failed job logs
gh run view <run-id> --repo <fork> --log-failed 2>&1 | tail -50

# View specific job logs
gh run view <run-id> --repo <fork> --log --job <job-id> 2>&1 | grep 'error:' | head -10
```

### Common Fix Patterns

| Error Type | Diagnosis | Fix |
|------------|-----------|-----|
| `error: no such module 'X'` | Missing import | Add `import X` to file |
| Type ambiguity (`X is ambiguous`) | Same name in two modules | Qualify: `ModuleName.X` |
| Non-exhaustive switch | Missing enum cases | Add missing cases |
| Test assertion failure | Config/default mismatch | Check expected values in source |
| `#available` errors | API too new for deployment target | Wrap in `#available` check |
| JSON parse errors | Invalid escape sequences | Fix `\.` → `\\.` etc. |

---

## 5. Tracking Documentation

Maintain two tracking files:

### 5.1 PROXY_BRANCH_TRACKER.md

```markdown
# Proxy Branch Tracker

## Merge Order & Status
| # | PR | Branch | Description | SHA | Status | Conflicts |
|---|---|----|-------------|-----|--------|-----------|
| 1 | #33 | test-cards | Test card expansion | abc1234 | Merged | None |
...

## Feature Flags
| Flag | Scope | Source PR |
|------|-------|-----------|

## CI/Test Strategy
(Updated after gate is built — captures architecture, status, and bug fixes)
```

### 5.2 CHANGELOG.md

Standard keep-a-changelog format. Update after each significant commit batch.

---

## 6. Lessons Learned

### 6.1 Pre-existing bugs will surface

When you build a CI gate on a codebase that never had one, **expect to fix bugs that were always there**. In our case, 15 pre-existing compile and test errors had to be fixed before the gate could pass. This is normal and valuable — you're establishing a clean baseline.

### 6.2 `xcodebuild -scheme X` builds ALL targets

Even with `--only-testing`, the scheme builds every target in the package. If any target has compile errors, the entire build fails. Fix all targets, or restructure the scheme.

### 6.3 Visual tests as advisory, not blocking

Visual regression tests catch real issues but are sensitive to environment differences (OS version, font rendering, etc.). Start them as advisory and promote to required once baselines are stable.

### 6.4 Parallel stages are critical for speed

Our gate runs in ~5 minutes because all stages are independent/parallel. If stages were sequential, it would take ~15 minutes. Agents lose context and patience with long waits.

### 6.5 Feature flags prevent all-or-nothing

Without flags, a single broken PR blocks the entire proxy branch. Flags let you merge early and gate activation separately from integration.

### 6.6 Use Python scripts for file edits in WSL

Shell heredocs and complex `sed` commands are fragile through WSL. Python scripts on the Windows side executed via `wsl -- python3 /mnt/c/...` are far more reliable.

---

## 7. Replication Checklist

To apply this pattern to a new repository:

- [ ] Fork the repo (or identify an existing fork with push access)
- [ ] Enable GitHub Actions on the fork
- [ ] Create `proxy/integration` branch from upstream/main
- [ ] Identify all in-flight PRs to integrate
- [ ] Merge PRs in dependency order
- [ ] Add feature flags if any PR changes visual/behavioral output
- [ ] Create `docs/PROXY_BRANCH_TRACKER.md` with merge table
- [ ] Create `.github/workflows/agent-gate.yml` tailored to the repo's tech stack
- [ ] Update existing workflow triggers to include `proxy/**`
- [ ] Fix all pre-existing compile/test errors until gate passes
- [ ] Open draft PR from fork to upstream
- [ ] Update CHANGELOG.md
- [ ] Document the iteration cycle for future agents
