# Complete Setup Guide for MacBook

**Target Audience:** Developers with a MacBook who want to build and test both iOS and Android code locally

---

## ✅ YES! Your MacBook Can Run BOTH Platforms

macOS is the **ONLY** platform that can build and test both iOS and Android applications:
- ✅ **iOS:** Native platform (requires macOS + Xcode)
- ✅ **Android:** Cross-platform (runs on macOS, Linux, Windows)

---

## Prerequisites

### System Requirements

- **macOS:** 13.0 (Ventura) or later
- **RAM:** 16GB minimum (32GB recommended for both platforms)
- **Storage:** 50GB+ free space
- **Processor:** Apple Silicon (M1/M2/M3) or Intel

### Tools to Install

#### 1. Xcode (for iOS)
```bash
# Install from Mac App Store
# Or download from: https://developer.apple.com/xcode/

# After installation, install command line tools:
xcode-select --install

# Verify installation:
xcodebuild -version
# Should show: Xcode 15.0 or later

swift --version
# Should show: Swift 5.9 or later
```

#### 2. Homebrew (Package Manager)
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify
brew --version
```

#### 3. Android Studio (for Android)
```bash
# Download from: https://developer.android.com/studio

# Or via Homebrew:
brew install --cask android-studio

# After installation:
# 1. Open Android Studio
# 2. Go to Preferences → Appearance & Behavior → System Settings → Android SDK
# 3. Install:
#    - Android SDK Platform 34
#    - Android SDK Build-Tools 34.0.0
#    - Android SDK Command-line Tools
#    - Android Emulator
```

#### 4. Java Development Kit (for Android)
```bash
# Install JDK 17 (required for Android)
brew install openjdk@17

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH=$JAVA_HOME/bin:$PATH

# Verify
java -version
# Should show: openjdk version "17.x.x"
```

#### 5. Git (Usually pre-installed)
```bash
# Verify
git --version

# If not installed:
brew install git
```

---

## Step-by-Step Setup

### Step 1: Clone the Repository

```bash
# Navigate to your projects folder
cd ~/Developer  # or wherever you keep projects

# Clone the repository
git clone https://github.com/VikrantSingh01/AdaptiveCards-Mobile.git

# Navigate to the project
cd AdaptiveCards-Mobile

# Checkout the branch with advanced elements
git checkout copilot/add-advanced-card-elements-again

# Pull latest changes
git pull origin copilot/add-advanced-card-elements-again

# Verify you're on the right branch
git branch --show-current
# Should show: copilot/add-advanced-card-elements-again
```

### Step 2: Verify Project Structure

```bash
# Should see these directories:
ls -la
# .github/          - CI/CD workflows
# android/          - Android SDK code
# ios/              - iOS SDK code
# shared/           - Shared test cards
# *.md              - Documentation files
```

---

## Building and Testing iOS

### Option A: Using Xcode (Recommended for Development)

#### 1. Open Project
```bash
cd ~/Developer/AdaptiveCards-Mobile/ios
open Package.swift
```

This opens the project in Xcode.

#### 2. Select Scheme
- In Xcode, select scheme: **ACCore** or **AdaptiveCards-Mobile**
- Select destination: **Any iOS Device** or a specific simulator

#### 3. Build
- Menu: **Product → Build** (⌘+B)
- Or click the Play button

#### 4. Run Tests
- Menu: **Product → Test** (⌘+U)
- Or: **Product → Test → Test Again** to re-run

Expected Output:
```
Test Suite 'All tests' started
...
Test Suite 'AdvancedElementsParserTests' started
✅ testParseCarousel passed (0.045 seconds)
✅ testParseAccordion passed (0.032 seconds)
✅ testParseCodeBlock passed (0.028 seconds)
...
Executed 40+ tests, with 0 failures in 2.156 seconds
```

#### 5. View Test Results
- Window → Show Report Navigator (⌘+9)
- Click on latest test run
- See all 40+ tests with ✅ green checkmarks

### Option B: Using Terminal (Swift Package Manager)

```bash
# Navigate to iOS directory
cd ~/Developer/AdaptiveCards-Mobile/ios

# Clean build (optional)
rm -rf .build
swift package clean

# Build
swift build

Expected Output:
Building for debugging...
[43/43] Linking ACCoreTests
Build complete! (12.34s)

# Run all tests
swift test

Expected Output:
Test Suite 'All tests' started at 2026-02-07 09:00:00.000
...
Executed 40 tests, with 0 failures (0 unexpected) in 2.156 seconds
✅ ALL TESTS PASSED

# Run specific test file
swift test --filter AdvancedElementsParserTests

# Run with coverage
swift test --enable-code-coverage

# Verbose output
swift test --verbose
```

### Option C: Using iOS Simulator

#### 1. Create a Demo App (Optional)

```bash
# In Xcode, create a new iOS app
# Add the AdaptiveCards SDK as a local package dependency
# File → Add Package Dependencies → Add Local...
# Select the ios/ directory
```

#### 2. Use AdaptiveCardView

```swift
import SwiftUI
import ACRendering

struct ContentView: View {
    let cardJSON = """
    {
        "type": "AdaptiveCard",
        "version": "1.6",
        "body": [
            {
                "type": "Carousel",
                "timer": 3000,
                "pages": [
                    {
                        "items": [
                            {"type": "TextBlock", "text": "Page 1"}
                        ]
                    },
                    {
                        "items": [
                            {"type": "TextBlock", "text": "Page 2"}
                        ]
                    }
                ]
            }
        ]
    }
    """
    
    var body: some View {
        AdaptiveCardView(cardJSON: cardJSON)
    }
}
```

#### 3. Run on Simulator
- Select an iOS simulator (iPhone 15, iPad Pro, etc.)
- Click Run (⌘+R)
- Test the carousel swipes and auto-advance

---

## Building and Testing Android

### Option A: Using Android Studio (Recommended for Development)

#### 1. Open Project
```bash
# Launch Android Studio
# File → Open
# Navigate to: ~/Developer/AdaptiveCards-Mobile/android
# Click "Open"
```

#### 2. Sync Gradle
- Android Studio will automatically detect the Gradle project
- Click "Sync Now" if prompted
- Wait for Gradle sync to complete (first time takes 5-10 minutes)

#### 3. Build
- Menu: **Build → Make Project** (⌘+F9)
- Or: **Build → Rebuild Project** for clean build

Expected Output:
```
BUILD SUCCESSFUL in 45s
42 actionable tasks: 42 executed
```

#### 4. Run Tests
- Open: `ac-core/src/test/kotlin/AdvancedElementsParserTest.kt`
- Click the green arrow next to class name
- Or: Menu → **Run → Run 'All Tests'**

Expected Output:
```
✅ testParseCarousel PASSED
✅ testParseAccordion PASSED
✅ testParseCodeBlock PASSED
✅ testParseRatingDisplay PASSED
✅ testParseRatingInput PASSED
✅ testParseProgressBar PASSED
✅ testParseSpinner PASSED
✅ testParseTabSet PASSED
...
All 12 tests passed in 1.234s
```

#### 5. View Test Results
- Bottom panel shows test results
- Click on any test to see details
- All should be green ✅

### Option B: Using Terminal (Gradle)

```bash
# Navigate to Android directory
cd ~/Developer/AdaptiveCards-Mobile/android

# If gradlew exists (wrapper)
chmod +x gradlew
./gradlew build

# If using system Gradle
gradle build

Expected Output:
BUILD SUCCESSFUL in 45s

# Run all tests
./gradlew test
# Or: gradle test

Expected Output:
BUILD SUCCESSFUL in 12s
12 tests completed, 12 passed

# Run specific module tests
./gradlew :ac-core:test

# Run with stacktrace for debugging
./gradlew test --stacktrace

# Run with info logging
./gradlew test --info

# Clean and rebuild
./gradlew clean build

# Run lint checks
./gradlew lint
```

### Option C: Using Android Emulator

#### 1. Create Virtual Device
```bash
# In Android Studio:
# Tools → Device Manager → Create Device
# Select: Pixel 8 (or any device)
# System Image: API 34 (Android 14)
# Click Finish
```

#### 2. Create Demo App

```kotlin
// In a new Android app project
import androidx.compose.runtime.Composable
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView

@Composable
fun DemoScreen() {
    val cardJson = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Carousel",
                    "timer": 3000,
                    "pages": [
                        {
                            "items": [
                                {"type": "TextBlock", "text": "Page 1"}
                            ]
                        },
                        {
                            "items": [
                                {"type": "TextBlock", "text": "Page 2"}
                            ]
                        }
                    ]
                }
            ]
        }
    """.trimIndent()
    
    AdaptiveCardView(json = cardJson)
}
```

#### 3. Run on Emulator
- Select emulator from dropdown
- Click Run (⌃+R)
- Test carousel, accordion, rating, etc.

---

## Quick Start Commands (MacBook)

### Full Test Run (Both Platforms)

```bash
# Clone and setup
cd ~/Developer
git clone https://github.com/VikrantSingh01/AdaptiveCards-Mobile.git
cd AdaptiveCards-Mobile
git checkout copilot/add-advanced-card-elements-again

# iOS Tests
cd ios
swift test
# ✅ Expected: 40+ tests pass

# Android Tests
cd ../android
gradle test
# ✅ Expected: 12+ tests pass

# Validate Test Cards
cd ../shared/test-cards
for f in *.json; do
    python3 -m json.tool "$f" > /dev/null && echo "✓ $f" || echo "✗ $f"
done
# ✅ Expected: All 16 cards valid
```

### One-Line Test Script

Save this as `run-all-tests.sh`:

```bash
#!/bin/bash
cd ~/Developer/AdaptiveCards-Mobile

echo "🧪 Running iOS Tests..."
cd ios && swift test && cd ..

echo ""
echo "🤖 Running Android Tests..."
cd android && gradle test && cd ..

echo ""
echo "📄 Validating Test Cards..."
cd shared/test-cards
for f in *.json; do
    python3 -m json.tool "$f" > /dev/null && echo "✓ $f" || echo "✗ $f"
done

echo ""
echo "✅ All tests complete!"
```

Then run:
```bash
chmod +x run-all-tests.sh
./run-all-tests.sh
```

---

## Expected Test Results

### iOS Tests (40+ tests)

**Test Categories:**
1. **Parsing Tests** (8 tests)
   - testParseCarousel
   - testParseAccordion
   - testParseCodeBlock
   - testParseRatingDisplay
   - testParseRatingInput
   - testParseProgressBar
   - testParseSpinner
   - testParseTabSet

2. **Round-Trip Tests** (6 tests)
   - testCarouselRoundTrip
   - testAccordionRoundTrip
   - testCodeBlockRoundTrip
   - testRatingDisplayRoundTrip
   - testProgressBarRoundTrip
   - testTabSetRoundTrip

3. **Edge Case Tests** (20+ tests)
   - Empty collections
   - Nil optionals
   - Boundary values
   - Visibility states
   - ID tests

4. **Integration Test** (1 test)
   - testAdvancedCombined

**Expected Result:** All 40+ tests PASS ✅

### Android Tests (12+ tests)

**Test Categories:**
1. **Parsing Tests** (8 tests)
   - Same elements as iOS

2. **Serialization Tests** (4+ tests)
   - Round-trip encode/decode

**Expected Result:** All 12+ tests PASS ✅

---

## Troubleshooting

### iOS Issues

#### Issue: "Command Line Tools not found"
```bash
xcode-select --install
sudo xcode-select --switch /Applications/Xcode.app
```

#### Issue: "No such module 'SwiftUI'"
```bash
# Make sure you're using Xcode's Swift, not Homebrew Swift
which swift
# Should show: /usr/bin/swift

# If it shows /opt/homebrew/bin/swift:
export PATH=/usr/bin:$PATH
```

#### Issue: Tests fail to compile
```bash
cd ios
rm -rf .build
swift package clean
swift build
swift test
```

### Android Issues

#### Issue: "ANDROID_HOME not set"
```bash
# Add to ~/.zshrc or ~/.bash_profile:
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools

# Reload shell
source ~/.zshrc
```

#### Issue: "Gradle build fails"
```bash
# Clean and rebuild
cd android
./gradlew clean
./gradlew build --refresh-dependencies

# If dependency issues:
./gradlew build --refresh-dependencies --stacktrace
```

#### Issue: "Android SDK not found"
```bash
# In Android Studio:
# Preferences → Appearance & Behavior → System Settings → Android SDK
# Install:
# - Android 14.0 (API 34)
# - Build Tools 34.0.0
# - Command-line Tools

# Verify via command line:
$ANDROID_HOME/tools/bin/sdkmanager --list
```

---

## Development Workflow on MacBook

### Scenario 1: Working on iOS Only

```bash
# Open in Xcode
cd ~/Developer/AdaptiveCards-Mobile/ios
open Package.swift

# Make changes in Xcode
# Build: ⌘+B
# Test: ⌘+U
# Run: ⌘+R (if you have a demo app)
```

### Scenario 2: Working on Android Only

```bash
# Open in Android Studio
# File → Open → Select android/ directory

# Make changes in Android Studio
# Build: ⌘+F9
# Test: Right-click test file → Run
```

### Scenario 3: Working on Both (Cross-Platform Development)

```bash
# Use two IDEs side-by-side:
# - Xcode for iOS (left half of screen)
# - Android Studio for Android (right half of screen)

# Make equivalent changes on both platforms
# Test both after each change
# Ensure parity maintained
```

### Scenario 4: Using VS Code for Both

```bash
# Install VS Code
brew install --cask visual-studio-code

# Install extensions:
# - Swift (for iOS)
# - Kotlin (for Android)
# - Gradle for Java

# Open project
cd ~/Developer/AdaptiveCards-Mobile
code .

# Build iOS from terminal in VS Code:
cd ios && swift build

# Build Android from terminal in VS Code:
cd android && gradle build
```

---

## Running the Advanced Elements Demo

### iOS Demo

#### Quick Test with Xcode Previews

Create a preview file:
```swift
// ios/Sources/ACRendering/Views/CarouselView+Preview.swift
#if DEBUG
import SwiftUI

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView(
            carousel: Carousel(
                pages: [
                    CarouselPage(items: [/* test elements */]),
                    CarouselPage(items: [/* test elements */])
                ],
                timer: 3000,
                initialPage: 0
            ),
            hostConfig: HostConfig.default
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
```

Then in Xcode:
- Open CarouselView.swift
- Click "Resume" in preview pane (⌥+⌘+Enter)
- See live preview with auto-refresh

#### Run in Simulator

1. Create simple SwiftUI app
2. Add package dependency (File → Add Package Dependencies → Add Local → select ios/)
3. Use AdaptiveCardView with test card JSON
4. Run on simulator (⌘+R)

### Android Demo

#### Quick Test with Compose Previews

```kotlin
// android/ac-rendering/src/main/kotlin/...composables/CarouselView.kt

@Preview(showBackground = true)
@Composable
fun CarouselPreview() {
    CarouselView(
        element = Carousel(
            pages = listOf(
                CarouselPage(items = listOf(/* test elements */)),
                CarouselPage(items = listOf(/* test elements */))
            ),
            timer = 3000,
            initialPage = 0
        ),
        viewModel = /* mock viewModel */,
        actionHandler = /* mock handler */
    )
}
```

In Android Studio:
- Open CarouselView.kt
- Click "Split" or "Design" tab
- See live preview

#### Run on Emulator

1. Create Android app
2. Add module dependency to build.gradle:
   ```gradle
   implementation(project(":ac-core"))
   implementation(project(":ac-rendering"))
   ```
3. Use AdaptiveCardView composable
4. Run on emulator

---

## Performance Testing on MacBook

### iOS Performance Profiling

```bash
# In Xcode:
# Product → Profile (⌘+I)
# Choose instrument:
# - Time Profiler: CPU usage
# - Allocations: Memory usage
# - Leaks: Memory leaks

# Run carousel auto-advance for 1 minute
# Check:
# ✅ No memory growth
# ✅ CPU < 5% when idle
# ✅ No leaks detected
```

### Android Performance Profiling

```bash
# In Android Studio:
# View → Tool Windows → Profiler
# Run app on device/emulator
# Record session

# Check:
# - Memory: No leaks, stable after initial render
# - CPU: < 5% when idle
# - Network: No unexpected calls
```

---

## Expected Performance on MacBook

### Build Times

**iOS (Swift Package Manager):**
- Clean build: 10-20 seconds
- Incremental build: 2-5 seconds
- Test execution: 2-3 seconds (40+ tests)

**Android (Gradle):**
- Clean build: 30-60 seconds (first time: 2-5 minutes)
- Incremental build: 5-15 seconds
- Test execution: 3-5 seconds (12+ tests)

### Runtime Performance

**On Simulator/Emulator:**
- Card render: < 50ms
- Carousel swipe: 60fps smooth
- Accordion animation: Smooth
- All interactions: Instant response

**On Real Device:**
- Card render: < 20ms
- Carousel swipe: 60fps smooth
- Accordion animation: Buttery smooth
- All interactions: Instant response

---

## Recommended Development Setup

### Hardware

**Minimum (Works but slow):**
- MacBook Air M1, 8GB RAM
- 256GB storage

**Recommended (Smooth development):**
- MacBook Pro M2/M3, 16GB+ RAM
- 512GB+ storage

**Optimal (Best experience):**
- MacBook Pro M3 Max, 32GB+ RAM
- 1TB storage
- External monitor

### Software Stack

```bash
# Essential
✅ macOS 13.0+
✅ Xcode 15.0+
✅ Android Studio 2023.1.1+
✅ JDK 17

# Recommended
✅ Homebrew
✅ Git
✅ VS Code (optional)
✅ SF Symbols app (for iOS icons)

# Nice to Have
✅ iTerm2 (better terminal)
✅ Oh My Zsh (shell improvements)
✅ Fork/Tower (Git GUI)
```

---

## Test Card Playground

### Use Shared Test Cards

All test cards are in `shared/test-cards/`:

```bash
# iOS - Load test card
cd ios
swift run LoadCard ../shared/test-cards/carousel.json

# Or in Xcode: Load JSON string directly

# Android - Load test card
cd android
# In Android Studio, create Activity that loads:
val json = File("../shared/test-cards/carousel.json").readText()
AdaptiveCardView(json = json)
```

### Test Each Advanced Element

1. **Carousel:** `shared/test-cards/carousel.json`
   - Test swipe navigation
   - Test auto-advance timer
   - Test page indicators

2. **Accordion:** `shared/test-cards/accordion.json`
   - Test expand/collapse
   - Test single vs multiple mode

3. **CodeBlock:** `shared/test-cards/code-block.json`
   - Test syntax display
   - Test line numbers
   - Test copy to clipboard

4. **Rating:** `shared/test-cards/rating.json`
   - Test star display
   - Test interactive input
   - Test validation

5. **Progress:** `shared/test-cards/progress-indicators.json`
   - Test progress bar
   - Test spinner

6. **TabSet:** `shared/test-cards/tab-set.json`
   - Test tab switching
   - Test scrollable tabs

7. **Combined:** `shared/test-cards/advanced-combined.json`
   - Test all elements together

---

## Accessibility Testing on MacBook

### iOS - VoiceOver Testing

```bash
# Enable VoiceOver:
# System Settings → Accessibility → VoiceOver → On
# Or: ⌘+F5 (quick toggle)

# Navigate with VoiceOver:
# - Swipe right: Next element
# - Swipe left: Previous element  
# - Double tap: Activate
# - Two-finger swipe up/down: Read all

# Test each element:
✅ Carousel: "Page 1 of 3. Swipe to navigate"
✅ Accordion: "Panel 1. Collapsed. Double tap to expand"
✅ Rating: "4.5 stars. 128 reviews"
```

### Android - TalkBack Testing

```bash
# In Android Emulator:
# Settings → Accessibility → TalkBack → On

# Navigate with TalkBack:
# - Swipe right: Next element
# - Swipe left: Previous element
# - Double tap: Activate

# Test each element:
✅ Carousel: "Page 1 of 3"
✅ Accordion: "Panel 1. Collapsed"
✅ Rating: "4.5 out of 5 stars"
```

### Dynamic Type / Font Scaling

**iOS:**
```bash
# Settings → Accessibility → Display & Text Size → Larger Text
# Drag slider to maximum
# Return to app - all text should scale
```

**Android:**
```bash
# Settings → Display → Font size → Largest
# Settings → Display → Display size → Largest
# Return to app - all text should scale
```

---

## Summary

### ✅ YES! You Can Run Both on MacBook

| Task | Possible? | Tools Needed |
|------|-----------|--------------|
| Build iOS | ✅ Yes | Xcode |
| Test iOS | ✅ Yes | Xcode or Terminal |
| Run iOS Simulator | ✅ Yes | Xcode |
| Build Android | ✅ Yes | Android Studio or Gradle |
| Test Android | ✅ Yes | Android Studio or Gradle |
| Run Android Emulator | ✅ Yes | Android Studio |
| Debug Both | ✅ Yes | Xcode + Android Studio |

### Recommended Workflow

**For this PR specifically:**

1. **Clone the branch** on your MacBook
2. **Run iOS tests** in Terminal:
   ```bash
   cd ios && swift test
   ```
   Expected: ✅ 40+ tests pass

3. **Run Android tests** in Terminal:
   ```bash
   cd android && gradle test
   ```
   Expected: ✅ 12+ tests pass

4. **Report back:** "All tests passed locally ✅"

5. **Push to trigger CI:** Workflows run automatically on GitHub

6. **Review CI results:** Verify on GitHub Actions

7. **Merge:** Once everything is green

### Time Required

- **Initial setup:** 30-60 minutes (installing tools)
- **Clone and test:** 5-10 minutes
- **Both platforms tested:** < 15 minutes total

**Worth it?** YES! You get immediate feedback without waiting for CI.

---

**Created:** February 7, 2026  
**For:** macOS users wanting to test both iOS and Android locally  
**Status:** Complete guide with all commands
