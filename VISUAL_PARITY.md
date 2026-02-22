# Visual Parity Testing

> Cross-renderer visual comparison between legacy (ObjC/C++ UIKit) and
> greenfield (SwiftUI) Adaptive Cards renderers.

## Quick Start

```bash
# Run parity tests
cd ios
xcodebuild test -scheme AdaptiveCards-Package \
  -destination 'platform=iOS Simulator,name=iPhone 16e' \
  -only-testing:VisualTests/LegacyParityTests \
  CODE_SIGNING_ALLOWED=NO

# Record new greenfield baselines (after render changes)
touch ios/Tests/VisualTests/Snapshots/.record
# Run tests again (same command)
rm ios/Tests/VisualTests/Snapshots/.record
```

## Architecture

```
                ┌─────────────────────────────────┐
                │  shared/parity-cards/*.json      │  ← Same 12 card JSONs
                │  (canonical Adaptive Card input) │
                └──────────┬──────────────────┬────┘
                           │                  │
                ┌──────────▼──────────┐  ┌────▼─────────────────┐
                │  Legacy Renderer    │  │  Greenfield Renderer │
                │  (ObjC/C++ + UIKit) │  │  (SwiftUI)           │
                │  ACRRenderer        │  │  AdaptiveCardView    │
                └──────────┬──────────┘  └────┬────────────────┘
                           │                  │
                ┌──────────▼──────────┐  ┌────▼─────────────────┐
                │  Golden Baselines   │  │  Greenfield Baselines │
                │  shared/golden-     │  │  Snapshots/Baselines/ │
                │  baselines/legacy/  │  │  parity_*.png         │
                └──────────┬──────────┘  └────┬────────────────┘
                           │                  │
                     ┌─────▼──────────────────▼─────┐
                     │  LegacyParityTests.swift      │
                     │  • Greenfield regression (1%) │
                     │  • Cross-renderer diff report  │
                     │  • Diff images + JSON report   │
                     └───────────────────────────────┘
```

## What the Tests Do

Each of the 12 `testParity_*` methods in `LegacyParityTests.swift` performs:

1. **Load** — Parses the parity card JSON from `shared/parity-cards/`
2. **Render** — Creates a SwiftUI `AdaptiveCardView` and captures a bitmap
3. **Greenfield regression** — Compares against the greenfield baseline PNG
   (1% tolerance, **this assertion fails on regressions**)
4. **Cross-renderer parity** — Computes pixel diff against the legacy golden
   PNG, saves diff image, and logs the result (**reporting-only, does not fail**)

The `testAllLegacyParity` master test runs all 12 cards and generates a summary
report at `Snapshots/ParityResults/parity_report.json`.

## Test Behavior

| Check | Tolerance | Fails on mismatch? | Purpose |
|-------|-----------|---------------------|---------|
| Greenfield regression | 1% | **Yes** | Catch SwiftUI render regressions |
| Cross-renderer parity | 10% (aspirational) | **No** (log only) | Track convergence over time |

The cross-renderer comparison is intentionally non-failing because UIKit/ObjC
and SwiftUI produce structurally different output. The parity metric is a
north-star tracking number that should decrease as the greenfield renderer matures.

## File Layout

```
ios/
├── Tests/VisualTests/
│   ├── LegacyParityTests.swift          # Parity test suite (12 tests + master)
│   ├── SnapshotTesting/
│   │   ├── SnapshotTestCase.swift        # Base snapshot infrastructure
│   │   └── CardSnapshotTestCase.swift    # Card rendering + assertSnapshot
│   └── Snapshots/
│       ├── Baselines/                    # Greenfield regression baselines
│       │   ├── parity_parity-actions_iPhone_15_Pro_iPhone_15_Pro.png
│       │   └── ... (12 PNGs)
│       ├── ParityResults/                # Generated each run (gitignored)
│       │   ├── parity_report.json        # Machine-readable summary
│       │   ├── *_greenfield.png          # Greenfield renders
│       │   ├── *_legacy.png              # Legacy baselines (copy)
│       │   └── *_diff.png               # Visual diff images
│       └── .record                       # Touch to enable recording mode
shared/
├── parity-cards/                         # 12 canonical JSON definitions
│   └── parity-*.json
├── golden-baselines/legacy/              # Legacy renderer golden PNGs
│   └── parity-*.png                      # (12 PNGs, committed)
└── README.md
```

## Current Parity Baseline (February 2026)

| Card | Diff % | Notes |
|------|--------|-------|
| table | 60.5% | Closest structural match |
| inputs | 63.7% | |
| textblock-basic | 68.0% | Font rendering differences |
| image-sizes | 78.0% | |
| imageset | 78.4% | |
| factset | 78.7% | |
| actions | 79.8% | |
| richtext | 79.1% | |
| activity-update | 80.0% | Composite card |
| columnset-layouts | 80.9% | |
| nested-containers | 90.3% | Deep nesting sensitivity |
| container-styles | 92.2% | Background/padding differences |
| **Average** | **77.5%** | |

## Recording Greenfield Baselines

When greenfield rendering changes (new features, bug fixes), re-record baselines:

```bash
# Option 1: Flag file (works with xcodebuild → simulator)
touch ios/Tests/VisualTests/Snapshots/.record
xcodebuild test -scheme AdaptiveCards-Package \
  -destination 'platform=iOS Simulator,name=iPhone 16e' \
  -only-testing:VisualTests/LegacyParityTests \
  CODE_SIGNING_ALLOWED=NO
rm ios/Tests/VisualTests/Snapshots/.record

# Option 2: Environment variable (works with swift test)
RECORD_SNAPSHOTS=1 swift test --filter LegacyParityTests
```

> **Note**: `RECORD_SNAPSHOTS=1` does not propagate through `xcodebuild` to the
> simulator process. Use the `.record` flag file when running via `xcodebuild`.

After recording, commit the updated baseline PNGs in `Snapshots/Baselines/`.

## Updating Legacy Baselines

When the legacy ObjC/C++ renderer changes:

1. In `microsoft/Teams-AdaptiveCards-Mobile`, run `ACRParityBaselineTests/testGenerateAllParityBaselines`
2. Copy updated `shared/golden-baselines/legacy/*.png` to this repo
3. Re-record greenfield baselines (they won't change, but the parity diff % will)
4. Commit both updated golden baselines and the new parity report

## Adding New Parity Cards

1. Create `shared/parity-cards/parity-<element>.json`
2. In legacy repo, add to `ACRParityBaselineTests` in `ADCIOSVisualizerTests.mm`:
   ```objc
   - (void)testBaseline_newElement { [self generateBaseline:@"parity-new-element"]; }
   ```
3. Run tests → generates `shared/golden-baselines/legacy/parity-new-element.png`
4. Copy `shared/` changes here
5. Add test in `LegacyParityTests.swift`:
   ```swift
   func testParity_newElement() { assertLegacyParity(cardName: "parity-new-element") }
   ```
6. Record greenfield baselines (`.record` flag)

## CI Integration

The parity tests run as part of the `VisualTests` target. In CI:

- **Greenfield regression snapshots**: Will fail on unexpected render changes (1% tolerance)
- **Parity comparisons**: Always pass (reporting-only), metrics captured in `parity_report.json`

To surface parity metrics in CI, parse `parity_report.json` and post a summary
comment on the PR with the diff percentages.

## Related

- Legacy repo: [`microsoft/Teams-AdaptiveCards-Mobile`](https://dev.azure.com/nicktalk/nicktalk/_git/Teams-AdaptiveCards-Mobile) branch `feature/hggz/visual-parity-baselines`
- Shared infrastructure docs: [shared/README.md](shared/README.md)
