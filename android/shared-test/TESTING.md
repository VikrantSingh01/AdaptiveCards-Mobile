# Adaptive Cards Android - Visual Regression & Performance Testing

## Overview

The `shared-test` module provides a comprehensive testing framework for validating the visual rendering and performance of Adaptive Cards on Android. It includes:

- **Visual regression tests** that capture screenshots of rendered cards and compare against baselines
- **Performance benchmarks** measuring parsing, rendering, and memory allocation
- **Multi-configuration testing** across devices, themes, font scales, and locales
- **Automated report generation** in JSON and HTML formats

## Directory Structure

```
shared-test/
  src/
    main/
      AndroidManifest.xml
      kotlin/com/microsoft/adaptivecards/test/
        TestModule.kt                       # Module marker
    androidTest/
      snapshots/                            # Baseline screenshot images
      kotlin/com/microsoft/adaptivecards/test/
        screenshot/
          BaseCardScreenshotTest.kt         # Base class for all screenshot tests
          CardScreenshotTest.kt             # Full visual regression suite (42 cards x 8 configs)
          SmokeScreenshotTest.kt            # Quick CI subset (8 cards x 16 configs)
          ThemeScreenshotTest.kt            # Theme-focused tests (9 cards x 4 configs)
          AccessibilityScreenshotTest.kt    # Font scale & RTL tests (11 cards x 10 configs)
        benchmark/
          CardParsingBenchmark.kt           # JSON parsing performance
          CardRenderingBenchmark.kt         # Compose rendering performance
          MemoryBenchmark.kt                # Memory allocation tracking
          PerformanceReportGenerator.kt     # Performance report generation & baselines
        utils/
          ComposeTestExtensions.kt          # Compose test rule extensions
          DeviceConfig.kt                   # Device/theme/font/locale configurations
          ScreenshotComparator.kt           # Pixel-by-pixel bitmap comparison
          ScreenshotStorage.kt              # Baseline/actual/diff file management
          TestReportGenerator.kt            # Visual regression report generation
```

## Running Tests

### Prerequisites

- Android emulator or device running API 26+
- `shared/test-cards/` directory with card JSON files (43 files)
- Connected device via ADB

### Run All Visual Regression Tests

```bash
./gradlew :shared-test:connectedAndroidTest \
  -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.CardScreenshotTest
```

### Run Smoke Tests (Quick CI)

```bash
./gradlew :shared-test:connectedAndroidTest \
  -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.SmokeScreenshotTest
```

### Run Theme Tests

```bash
./gradlew :shared-test:connectedAndroidTest \
  -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.ThemeScreenshotTest
```

### Run Accessibility Tests

```bash
./gradlew :shared-test:connectedAndroidTest \
  -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.AccessibilityScreenshotTest
```

### Run Performance Benchmarks

```bash
# Parsing benchmarks
./gradlew :shared-test:connectedAndroidTest \
  -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.benchmark.CardParsingBenchmark

# Rendering benchmarks
./gradlew :shared-test:connectedAndroidTest \
  -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.benchmark.CardRenderingBenchmark

# Memory benchmarks
./gradlew :shared-test:connectedAndroidTest \
  -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.benchmark.MemoryBenchmark
```

### Run Everything

```bash
./gradlew :shared-test:connectedAndroidTest
```

## Updating Baseline Screenshots

When visual changes are intentional (new features, design updates), update baselines:

```bash
./gradlew :shared-test:connectedAndroidTest \
  -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.CardScreenshotTest \
  -Pandroid.testInstrumentationRunnerArguments.updateBaselines=true
```

The updated baselines are saved to the device. To commit them:

```bash
# Pull baselines from device
adb pull /sdcard/Android/data/com.microsoft.adaptivecards.test/files/screenshots/baselines/ \
  android/shared-test/src/androidTest/snapshots/
```

## Test Configurations

### Device Configurations

| Name              | Width (dp) | Height (dp) | Density (dpi) |
|-------------------|-----------|-------------|---------------|
| Phone Portrait    | 360       | 640         | 420           |
| Phone Landscape   | 640       | 360         | 420           |
| Tablet Portrait   | 600       | 960         | 320           |
| Tablet Landscape  | 960       | 600         | 320           |
| Foldable Unfolded | 840       | 900         | 420           |
| Foldable Folded   | 360       | 748         | 420           |
| Small Phone       | 320       | 568         | 320           |

### Theme Configurations

- **Light** -- Material 3 `lightColorScheme()`
- **Dark** -- Material 3 `darkColorScheme()`

### Font Scale Configurations

| Name         | Scale | Use Case                  |
|--------------|-------|---------------------------|
| Default      | 1.0x  | Standard display          |
| Large        | 1.3x  | Common accessibility      |
| Extra Large  | 1.5x  | High accessibility        |
| Maximum      | 2.0x  | Extreme accessibility     |

### Locale Configurations

| Name     | Locale | Direction | Use Case          |
|----------|--------|-----------|-------------------|
| English  | en     | LTR       | Default testing   |
| Arabic   | ar     | RTL       | RTL validation    |
| Hebrew   | he     | RTL       | RTL validation    |
| Japanese | ja     | LTR       | CJK support       |
| German   | de     | LTR       | European locale   |

### Configuration Matrices

| Matrix      | Configs | Description                               |
|-------------|---------|-------------------------------------------|
| Full        | 280     | 7 devices x 2 themes x 4 fonts x 5 locales |
| Core        | 8       | Key scenarios covering major dimensions     |
| Smoke       | 16      | 2 devices x 2 themes x 2 fonts x 2 locales |

## Screenshot Comparison

### Algorithm

The comparator performs pixel-by-pixel comparison with:

1. **Dimension check** -- Different sizes are always a failure
2. **Per-pixel threshold** -- Ignores channel differences below 10 (0-255 scale)
3. **Anti-aliasing tolerance** -- Detects edge pixels via neighbour gradient analysis
4. **Aggregate threshold** -- Allows up to 0.1% of pixels to differ

### Configuration

Override `comparisonConfig` in your test class:

```kotlin
override val comparisonConfig get() = ComparisonConfig(
    maxDiffPercentage = 0.5,     // Allow 0.5% pixel differences
    perPixelThreshold = 15,       // Higher threshold for noisy renders
    generateDiffImage = true,     // Generate visual diffs
    antiAliasingTolerance = 3     // More AA tolerance
)
```

### Diff Images

When a comparison fails, a diff image is generated highlighting mismatched pixels in red. These are saved to:

```
/sdcard/Android/data/<pkg>/files/screenshots/diffs/
```

## Performance Baselines

### Parsing Baselines

| Card                | Expected (ms) | Max Acceptable (ms) |
|---------------------|--------------|---------------------|
| Simple text         | 1.0          | 5.0                 |
| Containers          | 3.0          | 10.0                |
| All actions         | 3.0          | 10.0                |
| All inputs          | 5.0          | 15.0                |
| Table               | 3.0          | 10.0                |
| Advanced combined   | 10.0         | 30.0                |
| Charts              | 5.0          | 15.0                |
| Deeply nested       | 5.0          | 20.0                |
| Long text           | 2.0          | 10.0                |

### Rendering Baselines

| Card                | Expected (ms) | Max Acceptable (ms) |
|---------------------|--------------|---------------------|
| Simple text         | 50           | 150                 |
| Containers          | 80           | 250                 |
| All actions         | 80           | 250                 |
| All inputs          | 100          | 300                 |
| Table               | 80           | 250                 |
| Advanced combined   | 150          | 500                 |
| Carousel            | 100          | 300                 |
| Deeply nested       | 100          | 350                 |

### Memory Baselines

| Scenario                  | Expected     | Max Acceptable |
|---------------------------|-------------|----------------|
| Simple card parse         | < 50 KB     | 100 KB         |
| Complex card parse        | < 500 KB    | 1 MB           |
| 100 simple cards held     | < 5 MB      | 10 MB          |
| 100 complex cards held    | < 50 MB     | 100 MB         |

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Visual Regression Tests

on:
  pull_request:
    paths:
      - 'android/**'
      - 'shared/test-cards/**'

jobs:
  visual-regression:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: Start emulator
        uses: ReactiveCircus/android-emulator-runner@v2
        with:
          api-level: 34
          arch: x86_64
          profile: pixel_6
          script: |
            cd android
            # Run smoke tests for quick CI feedback
            ./gradlew :shared-test:connectedAndroidTest \
              -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.SmokeScreenshotTest

      - name: Pull reports
        if: always()
        run: |
          adb pull /sdcard/Android/data/com.microsoft.adaptivecards.test/files/screenshots/reports/ \
            android/shared-test/build/reports/screenshots/ || true

      - name: Upload reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: visual-regression-reports
          path: android/shared-test/build/reports/screenshots/

  performance-benchmarks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: Start emulator
        uses: ReactiveCircus/android-emulator-runner@v2
        with:
          api-level: 34
          arch: x86_64
          profile: pixel_6
          script: |
            cd android
            ./gradlew :shared-test:connectedAndroidTest \
              -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.benchmark.CardParsingBenchmark

      - name: Pull benchmark results
        if: always()
        run: |
          adb pull /sdcard/Android/data/com.microsoft.adaptivecards.test/files/performance-reports/ \
            android/shared-test/build/reports/benchmarks/ || true

      - name: Upload benchmark results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: performance-benchmarks
          path: android/shared-test/build/reports/benchmarks/
```

### Azure DevOps Pipeline Example

```yaml
trigger:
  paths:
    include:
      - android/**
      - shared/test-cards/**

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: JavaToolInstaller@0
    inputs:
      versionSpec: '17'
      jdkArchitectureOption: 'x64'

  - script: |
      cd android
      ./gradlew :shared-test:connectedAndroidTest \
        -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.SmokeScreenshotTest
    displayName: 'Run Visual Regression Smoke Tests'

  - task: PublishTestResults@2
    inputs:
      testResultsFormat: 'JUnit'
      testResultsFiles: '**/TEST-*.xml'
    condition: always()
```

## Test Case Count Summary

| Test Suite                  | Cards | Configs | Total Cases |
|-----------------------------|-------|---------|-------------|
| CardScreenshotTest (Full)   | 42    | 8       | 336         |
| SmokeScreenshotTest         | 8     | 16      | 128         |
| ThemeScreenshotTest          | 9     | 4       | 36          |
| AccessibilityScreenshotTest | 11    | 10      | 110         |
| CardParsingBenchmark         | -     | -       | 12          |
| CardRenderingBenchmark       | -     | -       | 11          |
| MemoryBenchmark              | -     | -       | 8           |
| **TOTAL**                    |       |         | **641**     |

## Troubleshooting

### No baseline found

On the first run, all tests will pass and save the current render as the new baseline. Subsequent runs will compare against these baselines.

### Screenshot size mismatch

If the device or emulator configuration changes, screenshots may have different dimensions. Re-generate baselines on the new device.

### Flaky anti-aliasing differences

Increase the `antiAliasingTolerance` in `ComparisonConfig` or raise `perPixelThreshold`.

### Benchmark instability

- Run benchmarks on a physical device (not emulator) for stable results
- Ensure the device is plugged in and the screen is off
- Disable battery optimization for the test app
- Close other apps to reduce contention

### Report location

Reports are stored on-device at:
```
/sdcard/Android/data/com.microsoft.adaptivecards.test/files/
  screenshots/
    baselines/     # Reference images
    actuals/       # Current run captures
    diffs/         # Visual diff highlights
    reports/       # JSON and HTML reports
  performance-reports/
    performance_report.json
    performance_summary.txt
```

Pull them with:
```bash
adb pull /sdcard/Android/data/com.microsoft.adaptivecards.test/files/ ./test-output/
```
