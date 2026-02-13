package com.microsoft.adaptivecards.test

/**
 * Marker class for the shared-test module.
 *
 * This module provides:
 * - Visual regression testing for Adaptive Card rendering
 * - Screenshot comparison utilities
 * - Performance benchmarks for card parsing and rendering
 * - Compose test extensions for card testing
 *
 * Run instrumented tests:
 *   ./gradlew :shared-test:connectedAndroidTest
 *
 * Run with specific test class:
 *   ./gradlew :shared-test:connectedAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.microsoft.adaptivecards.test.screenshot.CardScreenshotTest
 */
object TestModule {
    const val VERSION = "1.0.0"
    const val MODULE_NAME = "shared-test"
}
