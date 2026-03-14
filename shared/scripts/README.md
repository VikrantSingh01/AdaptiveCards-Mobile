# Shared Scripts

## Testing & Validation

| Script | Purpose |
|---|---|
| [validate-test-cards.sh](validate-test-cards.sh) | Validates all test card JSON files for correct format and required AdaptiveCard fields |
| [test-card-parsing.swift](test-card-parsing.swift) | Swift utility that parses all shared test card JSONs, catching decoding errors and tracking element counts |
| [compare-schema-coverage.sh](compare-schema-coverage.sh) | Parity check — compares element/action types between iOS and Android SchemaValidators to detect gaps |

## iOS-Specific Testing

| Script | Purpose |
|---|---|
| [test-ios-cards-ui.sh](test-ios-cards-ui.sh) | iOS UI smoke test — screenshots cards and checks for parse failures or unknown element types |
| [test-ios-cards-visual.sh](test-ios-cards-visual.sh) | iOS visual smoke test — navigates cards via deep links, screenshots, and analyzes for rendering failures |
| [auto-test-ios-cards.sh](auto-test-ios-cards.sh) | Fully automated iOS visual test using osascript to navigate cards without manual interaction |
| [visual-test-loop.sh](visual-test-loop.sh) | Self-healing iOS visual test loop with deep links, screenshots, and category filtering |

## Template Testing

| Script | Purpose |
|---|---|
| [test-template-cards.sh](test-template-cards.sh) | Comprehensive iOS template test — data binding, `$data`, `$when`, template functions (select, sum, formatDateTime, etc.) |
| [test-template-cards-dual.sh](test-template-cards-dual.sh) | Dual-platform template test — runs templated cards on both iOS and Android simultaneously |

## Action Testing

| Script | Purpose |
|---|---|
| [action-test-loop.sh](action-test-loop.sh) | Dual-platform action rendering/crash test — navigates every action card to verify no fatal errors |
| [action-invoke-test.sh](action-invoke-test.sh) | Dual-platform action invocation test — taps action buttons and verifies correct behavior (ShowCard, ToggleVisibility, Popover) |

## Self-Healing Test Loops

| Script | Purpose |
|---|---|
| [self-heal-ios.sh](self-heal-ios.sh) | iOS self-healing loop with crash/hang detection, parse regression testing, memory profiling, and auto-retry recovery |
| [self-heal-android.sh](self-heal-android.sh) | Android self-healing loop with logcat crash detection, ANR monitoring, memory profiling, and auto-retry recovery |
| [self-heal-dual.sh](self-heal-dual.sh) | Synchronized dual-platform testing — navigates same card on both platforms simultaneously and screenshots both |

## Design Review

**Live Catalog**: https://vikrantsingh01.github.io/AdaptiveCards-Mobile/

| Script | Purpose |
|---|---|
| [design-pass.sh](design-pass.sh) | End-to-end design review: captures all card + app screenshots on both platforms, generates an HTML catalog with side-by-side comparison |
| [generate-design-catalog.sh](generate-design-catalog.sh) | Generates a self-contained `index.html` from a screenshot directory with category filters, search, and lightbox |
| [deploy-catalog.sh](deploy-catalog.sh) | Deploys the latest (or specified) design catalog to GitHub Pages (`gh-pages` branch) |

### Quick Start

```bash
# Full refresh: re-capture all 286 cards + 6 app screens (~25 min)
bash shared/scripts/design-pass.sh

# Deploy to GitHub Pages (~10 sec)
bash shared/scripts/deploy-catalog.sh

# Or deploy a specific catalog
bash shared/scripts/deploy-catalog.sh shared/test-results/design-catalog-20260313-161006
```

### Regenerate HTML only (no re-capture)

```bash
bash shared/scripts/generate-design-catalog.sh shared/test-results/design-catalog-20260313-161006
bash shared/scripts/deploy-catalog.sh
```

## Utilities

| Script | Purpose |
|---|---|
| [check-screenshot-text.sh](check-screenshot-text.sh) | OCR helper using macOS Vision framework — detects unresolved `{}` template markers or "fail" text in screenshots |
| [compare-screenshots.py](compare-screenshots.py) | Cross-platform screenshot comparator — crops chrome, resizes, and computes structural similarity for rendering parity |
| [demo-bookmarks.sh](demo-bookmarks.sh) | Dual-platform demo script — warm-boots both apps and runs an 8-step side-by-side navigation demo |
