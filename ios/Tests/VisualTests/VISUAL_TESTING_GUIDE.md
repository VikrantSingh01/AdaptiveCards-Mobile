# Visual Regression Testing Guide

## Overview

The Visual Regression Testing Framework for iOS Adaptive Cards provides automated
snapshot-based testing to detect unintended visual changes across card renderings.
It captures screenshots of rendered cards in multiple device configurations and
compares them against stored baseline images.

## Architecture

```
Tests/VisualTests/
├── SnapshotTesting/
│   └── SnapshotTestCase.swift          # Core snapshot engine (render, compare, diff)
├── Utilities/
│   ├── CardSnapshotTestCase.swift      # Base class for card-specific tests
│   ├── SnapshotTestReporter.swift      # HTML/JSON report generation
│   └── PerformanceTestUtilities.swift  # Performance measurement and thresholds
├── CardVisualRegressionTests.swift     # Per-card visual regression tests
├── EdgeCaseVisualTests.swift           # Edge case and stress tests
├── AppearanceVisualTests.swift         # Theme, accessibility, host config tests
├── DeviceSizeVisualTests.swift         # Multi-device and orientation tests
├── ComprehensiveSnapshotTests.swift    # Full matrix tests (all cards x all configs)
├── CardPerformanceTests.swift          # Performance benchmarks with thresholds
└── Snapshots/
    ├── Baselines/                      # Reference images (checked into Git)
    ├── Failures/                       # Actual images when tests fail (gitignored)
    ├── Diffs/                          # Visual diff images (gitignored)
    └── Reports/                        # HTML/JSON reports (gitignored)
```

## How to Run Visual Tests

### Prerequisites

- Xcode 15+ with iOS 16+ simulator
- The project must build successfully: `swift build` from the `ios/` directory

### Running All Visual Tests

```bash
# From the ios/ directory
swift test --filter VisualTests
```

### Running Specific Test Categories

```bash
# Visual regression tests for individual cards
swift test --filter CardVisualRegressionTests

# Edge case tests
swift test --filter EdgeCaseVisualTests

# Appearance (dark mode, accessibility) tests
swift test --filter AppearanceVisualTests

# Device size and orientation tests
swift test --filter DeviceSizeVisualTests

# Full matrix (comprehensive) tests
swift test --filter ComprehensiveSnapshotTests

# Performance tests only
swift test --filter CardPerformanceTests
```

### Running a Single Test

```bash
swift test --filter "CardVisualRegressionTests/testSimpleTextCard_allDevices"
```

## How to Record/Update Baseline Snapshots

When running tests for the first time, or after intentional visual changes,
you need to record new baseline images.

### Record All Baselines

```bash
RECORD_SNAPSHOTS=1 swift test --filter VisualTests
```

### Record Baselines for Specific Tests

```bash
RECORD_SNAPSHOTS=1 swift test --filter "CardVisualRegressionTests/testSimpleTextCard_allDevices"
```

### After Recording

1. Review the new baselines in `Tests/VisualTests/Snapshots/Baselines/`
2. Verify they look correct
3. Commit the new PNG files to version control
4. Re-run tests without RECORD_SNAPSHOTS to verify they pass

## How to Interpret Test Results

### Test Pass

The rendered card matches the baseline within the configured tolerance
(default: 1% pixel difference). No action needed.

### Test Failure: No Baseline

```
No baseline found for 'simple-text_iPhone_15_Pro'.
Run with RECORD_SNAPSHOTS=1 to create baselines.
```

This means baselines have not been recorded yet. Record them as described above.

### Test Failure: Visual Difference

```
Snapshot 'simple-text_iPhone_15_Pro' differs from baseline by 5.23% (tolerance: 1.00%).
Diff saved to: .../Snapshots/Diffs/simple-text_iPhone_15_Pro_diff.png
```

When this happens:

1. **Check the diff image** in `Snapshots/Diffs/` - red pixels show changed areas
2. **Check the actual image** in `Snapshots/Failures/` - what the card looks like now
3. **Compare with baseline** in `Snapshots/Baselines/` - what it should look like
4. **If the change is intentional**: Re-record baselines with RECORD_SNAPSHOTS=1
5. **If the change is a regression**: Fix the rendering code and re-run tests

### HTML Report

After running `ComprehensiveSnapshotTests/testAllCards_comprehensiveConfigurations`,
an HTML report is generated at:

```
Tests/VisualTests/Snapshots/Reports/visual-regression-report.html
```

Open it in a browser to see a visual summary with pass/fail status, diff images,
and configuration details for every card.

## Snapshot Configurations

The framework tests across these configurations:

### Devices
| Configuration | Size | Size Class |
|---|---|---|
| iPhone SE | 375x667 | Compact/Regular |
| iPhone 15 Pro | 393x852 | Compact/Regular |
| iPad Portrait | 810x1080 | Regular/Regular |

### Appearance
| Configuration | Interface Style |
|---|---|
| Light mode | `.light` |
| Dark mode | `.dark` |

### Orientations
| Configuration | Size |
|---|---|
| iPhone 15 Pro Portrait | 393x852 |
| iPhone 15 Pro Landscape | 852x393 |
| iPad Portrait | 810x1080 |
| iPad Landscape | 1080x810 |

### Accessibility Font Scales
| Configuration | Content Size Category |
|---|---|
| Extra Small | `.extraSmall` |
| Default (Large) | `.large` |
| Extra Extra Large | `.extraExtraLarge` |
| Accessibility XXXL | `.accessibilityExtraExtraExtraLarge` |

### Preset Groups

- **Core** (4 configs): iPhone 15 Pro light, iPhone 15 Pro dark, iPad, Accessibility XXXL
- **All Device Sizes** (3 configs): iPhone SE, iPhone 15 Pro, iPad
- **All Appearances** (2 configs): Light, Dark
- **All Orientations** (2 configs): Portrait, Landscape
- **Comprehensive** (12 configs): All devices x appearances x orientations + accessibility

## Performance Benchmarks

### Thresholds

| Metric | Default | Complex Cards | Strict |
|---|---|---|---|
| Parse time | < 100ms | < 250ms | < 50ms |
| Render time | < 500ms | < 1000ms | < 200ms |
| Memory delta | < 50MB | < 100MB | < 20MB |
| Total time | < 600ms | < 1250ms | < 250ms |

"Complex" thresholds apply to cards with prefixes `edge-`, `advanced-combined`, and `datagrid`.

### Running Performance Tests

```bash
# Run all performance tests
swift test --filter CardPerformanceTests

# Run XCTest measure benchmarks (for Xcode performance tracking)
swift test --filter "CardPerformanceTests/testMeasure"
```

### Performance Report

After running `testPerformance_allCards`, a JSON report is generated at:

```
Tests/VisualTests/Snapshots/Reports/performance-report.json
```

## Adding New Test Cards

When adding a new test card to `shared/test-cards/`:

1. Add the JSON file to `shared/test-cards/`
2. The card will automatically be included in:
   - `ComprehensiveSnapshotTests.testAllCards_coreConfigurations`
   - `EdgeCaseVisualTests.testAllCardsRenderWithoutCrash`
   - `CardPerformanceTests.testPerformance_allCards`
3. Add specific test methods in `CardVisualRegressionTests.swift` for targeted testing
4. Record baselines: `RECORD_SNAPSHOTS=1 swift test --filter VisualTests`
5. Commit the new baseline images

## Adjusting Tolerance

The default pixel difference tolerance is 1%. To adjust:

Override `snapshotTolerance` in your test class:

```swift
final class MyTests: CardSnapshotTestCase {
    override var snapshotTolerance: Double { 0.02 }  // 2% tolerance
}
```

## CI Integration

### GitHub Actions Example

```yaml
- name: Run Visual Regression Tests
  run: |
    cd ios
    swift test --filter VisualTests 2>&1 | tee test-output.log

- name: Upload Failure Artifacts
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: snapshot-failures
    path: |
      ios/Tests/VisualTests/Snapshots/Failures/
      ios/Tests/VisualTests/Snapshots/Diffs/
      ios/Tests/VisualTests/Snapshots/Reports/
```

### Recording Baselines in CI

```yaml
- name: Record Baseline Snapshots
  if: github.event_name == 'workflow_dispatch'
  env:
    RECORD_SNAPSHOTS: "1"
  run: |
    cd ios
    swift test --filter ComprehensiveSnapshotTests/testAllCards_coreConfigurations
```

## Troubleshooting

### Tests fail with "No baseline found"
Record baselines first: `RECORD_SNAPSHOTS=1 swift test --filter VisualTests`

### All tests show tiny differences (< 1%)
This can happen due to font rendering differences across macOS/Xcode versions.
Increase tolerance or re-record baselines on the target CI machine.

### Tests pass locally but fail in CI
Ensure CI uses the same Xcode version and simulator runtime. Font rendering
can vary between environments.

### Performance tests are flaky
Performance measurements can vary by machine load. Run performance tests
on a quiet machine or increase thresholds for CI.
