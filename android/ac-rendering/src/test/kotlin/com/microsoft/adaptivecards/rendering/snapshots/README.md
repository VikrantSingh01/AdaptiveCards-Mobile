# Android Snapshot Testing Guide

This directory contains snapshot (visual regression) testing infrastructure for the AdaptiveCards Android SDK using Jetpack Compose.

## Overview

Snapshot testing allows us to verify that UI components render correctly and detect unintended visual changes. This is particularly important for ensuring cross-platform visual parity with iOS.

## Framework: Paparazzi

We use **Paparazzi** for snapshot testing:
- GitHub: https://github.com/cashapp/paparazzi
- Runs on JVM without emulator (fast!)
- Easy CI integration

## Setup

### 1. Add Dependency

Add to `android/ac-rendering/build.gradle.kts`:

```kotlin
plugins {
    id("app.cash.paparazzi") version "1.3.1"
}

dependencies {
    testImplementation("app.cash.paparazzi:paparazzi:1.3.1")
}
```

### 2. Run Tests

```bash
cd android
./gradlew :ac-rendering:testDebug
```

### 3. Record New Snapshots

```bash
./gradlew :ac-rendering:recordPaparazziDebug
```

### 4. Verify Snapshots

```bash
./gradlew :ac-rendering:verifyPaparazziDebug
```

## Sample Test Implementation

See `CardElementSnapshotTests.kt` for a complete example.

## Status

**Current Status**: 🚧 Scaffolding in place

**Next Steps**:
1. Add Paparazzi dependency to build.gradle.kts
2. Implement snapshot tests for core elements
3. Enable in CI pipeline

---

**Maintained by**: AdaptiveCards-Mobile Team  
**Last Updated**: February 13, 2026
