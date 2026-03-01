# Proxy Integration Branch — Agent Workflow & Operating Manual

> **Audience**: AI coding agents (Copilot, Claude, etc.) operating on this repo
> **Branch**: `proxy/integration`
> **Canonical tracker**: `docs/PROXY_BRANCH_TRACKER.md`
> **Last updated**: 2025-07-22

---

## 1. Architecture Overview

This repo uses a **proxy branch pattern** to pre-integrate feature PRs before they land on `main`.

```
upstream/main (VikrantSingh01/AdaptiveCards-Mobile)
     │
     ├── PR #33 ──► main (individual review)
     ├── PR #34 ──► main (individual review)
     ├── ...
     │
     └── proxy/integration (hggzm/AdaptiveCards-Mobile)
              │
              ├── All PRs merged here first
              ├── Feature flags gate risky changes
              ├── Integration testing done here
              └── PR #42 (draft) ──► main
```

### Remotes

| Remote | URL | Purpose |
|--------|-----|---------|
| `upstream` | `VikrantSingh01/AdaptiveCards-Mobile` | The canonical upstream repo |
| `origin` | `hggz/AdaptiveCards-Mobile-1` | Original fork (read-only for `hggzm`) |
| `myfork` | `hggzm/AdaptiveCards-Mobile` | Pushable fork for `hggzm` |

### Golden Rule

> **All new PRs are opened against `upstream/main`** (for individual review), but **immediately integrated into `proxy/integration`** (for combined testing). The tracker doc is updated every time.

---

## 2. Adding a New PR

When a new feature branch is ready, follow this exact sequence:

### Step 1: Open the PR against main

```bash
# From the feature branch
gh pr create --repo VikrantSingh01/AdaptiveCards-Mobile \
  --head hggzm:<branch-name> --base main \
  --title "feat: <description>" --body "<PR body>"
```

### Step 2: Integrate into proxy/integration

```bash
cd ~/code/AdaptiveCards-Mobile
git checkout proxy/integration
git fetch --all

# Merge the new PR branch
git merge --no-ff <remote>/<branch-name> \
  -m "Merge PR #<N>: <branch-name> (<short description>)"
```

### Step 3: Handle conflicts (if any)

See Section 4 below for the conflict resolution protocol.

### Step 4: Update the tracker

Edit `docs/PROXY_BRANCH_TRACKER.md`:
1. Add a new row to the **Merge Order & Status** table
2. Record the PR number, branch name, SHA, and any conflicts
3. Update the **Dependency Graph** if the new PR overlaps existing ones
4. If the PR introduces visual/behavioral changes, assess whether it needs a **feature flag** (see Section 5)

### Step 5: Commit tracker update + push

```bash
git add docs/PROXY_BRANCH_TRACKER.md
git commit -m "docs: update proxy tracker — add PR #<N>"
git push myfork proxy/integration
```

### Step 6: Verify

Confirm the draft PR #42 on upstream shows the new commits.

---

## 3. Syncing with Upstream Main

When new PRs get merged directly into `upstream/main` (outside the proxy workflow), sync the proxy branch:

```bash
git fetch upstream
git checkout proxy/integration
git merge upstream/main -m "sync: merge upstream/main into proxy/integration"
# Resolve any conflicts (see Section 4)
git push myfork proxy/integration
```

**When to sync**:
- Before merging any new PR into proxy (always start from latest state)
- After any PR from the tracker gets merged into `main` directly
- Before running CI/test validation

**After sync**: Update `PROXY_BRANCH_TRACKER.md` base SHA if main has moved.

---

## 4. Conflict Resolution Protocol

Conflicts are expected when multiple PRs touch the same files. Here's the procedure:

### 4.1 Identify the conflict

```bash
# After a failed merge:
git diff --name-only --diff-filter=U   # List conflicted files
grep -n '<<<<<<\|======\|>>>>>>' <file>  # Find conflict markers
```

### 4.2 Determine resolution strategy

| Scenario | Strategy |
|----------|----------|
| Both sides add independent code to same file | Keep both (concatenate) |
| One side has a superset of the other | Keep the superset |
| Structural conflict (same function modified differently) | Analyze intent, merge manually |
| One PR expands an API, the other simplifies it | Keep the expanded version (more complete) |

### 4.3 Document the resolution

**Every conflict resolution MUST be documented** in `PROXY_BRANCH_TRACKER.md` under the merge entry and in the commit message. Use this format:

```
Conflict resolution: <filename>
- PR #A: <what it did>
- PR #B: <what it did>
- Resolution: <what was kept and why>
```

### 4.4 Historical conflict log

| PR Merge | File | Resolution |
|----------|------|------------|
| PR #39 (over #34) | `HostConfig.swift` | Kept PR #34's expanded `FactSetTextConfig` (7 fields + decoder) over PR #39's simplified 3-field version |

> **Always append to this table** when resolving new conflicts. This log is critical for agents picking up future work.

### 4.5 If conflict is too complex

If you cannot confidently resolve a conflict:
1. Abort the merge: `git merge --abort`
2. Document the blocker in the tracker with `⚠️ BLOCKED`
3. Flag it for human review in the PR body

---

## 5. Feature Flag Decision Framework

Not every change needs a flag. Use this rubric:

### Needs a feature flag ✅

- Visual/rendering behavior changes (might break existing UX)
- New Copilot extension types (streaming, CoT — not yet battle-tested)
- HostConfig interpretation changes (affects theming across all cards)
- Changes to action handling or input validation

### Does NOT need a feature flag ❌

- New test cards or test infrastructure (no runtime impact)
- Documentation or CI changes
- New independent utility types that aren't wired into rendering
- Schema additions that only affect parsing (not rendering)

### Adding a new flag

1. Add to `ios/Sources/ACCore/AdaptiveCardFeatureFlags.swift`
2. Add matching flag to `android/ac-core/.../core/AdaptiveCardFeatureFlags.kt`
3. Default to `false`
4. Wire guard into the affected view/type
5. Document in `PROXY_BRANCH_TRACKER.md` under Feature Flags
6. Add to the tracking table with the PR that introduced it

### Current flag inventory

| Flag | Scope | Source PR |
|------|-------|-----------|
| `enableCopilotStreamingExtensions` | ChainOfThought + Streaming views | PR #37 |
| `useParityFontMetrics` | TextBlockView, RichTextBlockView | PR #39 |
| `useParityLayoutFixes` | ContainerView, ColumnView, ColumnSetView | PR #39 |
| `useParityImageBehavior` | ImageView | PR #39 |
| `useParityElementStyling` | FactSetView, TableView, ActionButton | PR #39 |

---

## 6. Mainline Merge Strategy

When PRs from the proxy branch are ready to merge into `main`, follow this order:

### 6.1 Individual PR merge (preferred)

The cleanest path: merge individual PRs into main one at a time, in dependency order.

```
Tier 1 (no dependencies): #33, #35, #37  ← merge these first
Tier 2 (minor overlaps):  #34, #36, #40  ← merge after Tier 1
Tier 3 (superset):        #39            ← merge last (contains #38)
```

After each individual merge:
1. Mark it as "Merged to main" in `PROXY_BRANCH_TRACKER.md`
2. Sync proxy/integration with the updated main
3. Verify no regressions

### 6.2 Bulk merge via proxy PR #42

If individual merges aren't feasible, the proxy branch itself can be merged as a single PR. The draft PR #42 already exists for this purpose.

**Before bulk merge**:
1. All feature flags tested in both ON and OFF states
2. CI passes on the proxy branch
3. All conflict resolutions reviewed by a human
4. Update PR #42 from draft to ready

### 6.3 After a PR merges to main

When any tracked PR gets merged to `main` (either individually or via proxy):

```bash
# 1. Sync
git fetch upstream
git checkout proxy/integration
git merge upstream/main

# 2. Update tracker
# Mark PR as "Merged to main" in the table
# Update base SHA

# 3. Push
git push myfork proxy/integration
```

---

## 7. PR Iteration Protocol

When an existing PR gets review feedback and needs updates:

### 7.1 The PR author pushes new commits to the feature branch

```bash
# On the feature branch
git commit -m "fix: address review feedback on PR #<N>"
git push
```

### 7.2 Re-integrate into proxy

```bash
git checkout proxy/integration
git fetch --all

# Merge the updated branch (may need conflict resolution again)
git merge --no-ff <remote>/<updated-branch> \
  -m "Re-merge PR #<N>: <branch-name> (iteration 2 — review fixes)"
```

### 7.3 Update tracker

Add an entry like:
```
| 8 | #<N> | `<branch>` | Iteration 2: review fixes | `<new-sha>` | Re-merged | None |
```

### 7.4 If the iteration changes conflict with proxy state

Sometimes a re-merge will fail because the proxy branch has diverged:
1. Try the merge — often git handles it
2. If conflicts, resolve following Section 4
3. If the conflict is from a structural change, consider **resetting the proxy** (Section 8)

---

## 8. Proxy Branch Reset (Nuclear Option)

If the proxy branch gets too tangled (many conflict resolutions that don't apply cleanly), rebuild it:

```bash
git checkout -B proxy/integration upstream/main

# Re-merge all PRs in order (from tracker table)
git merge --no-ff <remote>/branch1 -m "Merge PR #X: ..."
git merge --no-ff <remote>/branch2 -m "Merge PR #Y: ..."
# ... etc

# Re-apply feature flag commit
# Update tracker
git push myfork proxy/integration --force-with-lease
```

**When to reset**:
- More than 3 conflict resolutions have accumulated and a new upstream/main merge creates cascading issues
- A tracked PR was force-pushed with a fundamentally different approach
- The proxy branch has diverged so far that `git merge upstream/main` produces >5 conflicts

**After reset**: Force-push and note the reset in the tracker with the new base SHA.

---

## 9. Agent Handoff Checklist

When handing off proxy branch work to another agent:

### Required context to provide:
- [ ] Current `proxy/integration` HEAD SHA
- [ ] Which PRs are in the proxy (reference `PROXY_BRANCH_TRACKER.md`)
- [ ] Any pending conflicts or blocked merges
- [ ] Feature flag state (which are wired, which are infra-only)
- [ ] Whether any PRs have been merged to main since last sync
- [ ] The engine job IDs tracking this repo's work state

### Files to read first:
1. `docs/PROXY_BRANCH_TRACKER.md` — current merge state
2. `docs/AGENT_PROXY_WORKFLOW.md` — this document (procedures)
3. `.github/copilot-instructions.md` — build/test/style rules
4. `ios/Sources/ACCore/AdaptiveCardFeatureFlags.swift` — current flags
5. `android/ac-core/.../core/AdaptiveCardFeatureFlags.kt` — matching flags

### Engine integration:
- The unified dashboard engine at `localhost:5060` has a `github-work-state-tracker` job monitoring this repo
- PR state is synced as work items in `~/.autonomy/work/`
- Trigger a manual sync: `curl -X POST http://localhost:5060/api/jobs/github-work-state-tracker/trigger`

---

## 10. Quick Reference Commands

```bash
# === Setup ===
cd ~/code/AdaptiveCards-Mobile
git remote -v                              # Verify remotes

# === Status ===
git log --oneline proxy/integration        # Full proxy history
git log --oneline proxy/integration ^upstream/main  # Proxy-only commits
git diff upstream/main..proxy/integration --stat   # Files changed vs main

# === New PR integration ===
git checkout proxy/integration
git fetch --all
git merge --no-ff <remote>/<branch> -m "Merge PR #N: ..."
# Edit docs/PROXY_BRANCH_TRACKER.md
git add -A && git commit -m "docs: update proxy tracker — add PR #N"
git push myfork proxy/integration

# === Sync with upstream ===
git fetch upstream
git merge upstream/main -m "sync: merge upstream/main"
git push myfork proxy/integration

# === Check for divergence ===
git rev-list --left-right --count upstream/main...proxy/integration
# Output: <behind> <ahead>

# === Feature flags ===
grep -n 'var.*Bool.*=' ios/Sources/ACCore/AdaptiveCardFeatureFlags.swift
grep -n 'var.*Boolean.*=' android/ac-core/src/main/kotlin/com/microsoft/adaptivecards/core/AdaptiveCardFeatureFlags.kt
```

---

## 11. Known Gotchas

1. **`hggzm` vs `hggz`**: The `hggzm` account pushes to `hggzm/AdaptiveCards-Mobile` (remote `myfork`). The `hggz` fork at `hggz/AdaptiveCards-Mobile-1` is read-only for `hggzm`. Always push to `myfork`.

2. **PR #38 is a subset of #39**: Never merge #38 separately. PR #39 contains all of #38's commits. If #38 gets merged to main first, #39's merge will auto-resolve (the shared commits are already in).

3. **PR branches live on the fork**: All `feature/*` branches are on `origin` (hggz fork) or `upstream` (for #40). They are cross-repo PRs to `upstream/main`.

4. **Feature flags are infra-only for visual parity**: The visual parity flags (`useParityFontMetrics`, etc.) are defined but not yet wired into every view's rendering path. The infra is ready; per-view conditional logic needs implementation during testing.

5. **Upstream main may receive direct merges**: PR #41 was merged directly to main outside this proxy workflow. Always sync before integrating new PRs.

6. **Shell escaping**: When running git commands through `wsl -d Ubuntu-22.04`, heredocs and complex string escaping often fail. Use Python scripts for file creation instead of shell heredocs.
