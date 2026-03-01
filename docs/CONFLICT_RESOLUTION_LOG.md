# Proxy Branch — Conflict Resolution Log

> **Purpose**: Running log of every merge conflict encountered on `proxy/integration` and how it was resolved.
> **Why separate**: Agents should append here on every conflict. Keeps `PROXY_BRANCH_TRACKER.md` clean for status overview, while this file preserves the full forensic trail.

---

## Format

Each entry follows this structure:

```
### <Date> — PR #<N> merge conflict

**File**: `<path>`
**Conflicting PRs**: #<A> vs #<B>
**Conflict type**: <structural | additive | superset | divergent>
**Resolution**: <what was kept and why>
**Verified**: <yes/no — did it compile/test after resolution>
```

---

## Entries

### 2025-07-22 — PR #39 merge into proxy/integration

**File**: `ios/Sources/ACCore/HostConfig/HostConfig.swift`
**Conflicting PRs**: PR #34 (hostconfig-full-parity) vs PR #39 (visual-parity-improvements)
**Conflict type**: Divergent — both PRs modified `FactSetTextConfig` struct differently

**PR #34 version** (already in proxy):
```swift
public struct FactSetTextConfig: Codable {
    public var weight: String
    public var size: String
    public var color: String
    public var isSubtle: Bool
    public var fontType: String
    public var wrap: Bool
    public var maxWidth: Int
    // + custom init(from decoder:) with defaults
}
```

**PR #39 version** (incoming):
```swift
public struct FactSetTextConfig: Codable {
    public var weight: String
    public var maxWidth: Int
    public var size: Int  // Note: Int not String
    // simplified 3-field version
}
```

**Resolution**: Kept PR #34's expanded version (7 fields + custom decoder). Rationale:
1. PR #34 is the "full HostConfig parity" PR — its expanded type is the correct target
2. PR #39's simplified version was a snapshot from earlier development
3. The expanded version is backward-compatible (all fields have defaults)

**Verified**: Yes — merge committed successfully, no compile errors from other changes in PR #39.

---

<!-- NEW ENTRIES GO BELOW THIS LINE -->
