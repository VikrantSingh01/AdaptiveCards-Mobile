# iOS Snapshot Testing Guide

This directory contains snapshot (visual regression) testing infrastructure for the AdaptiveCards iOS SDK using SwiftUI.

## Overview

Snapshot testing allows us to verify that UI components render correctly and detect unintended visual changes. This is particularly important for ensuring cross-platform visual parity.

## Framework

We use **swift-snapshot-testing** library by Point-Free for snapshot testing:
- GitHub: https://github.com/pointfreeco/swift-snapshot-testing
- Documentation: https://pointfreeco.github.io/swift-snapshot-testing/

## Setup

### 1. Add Dependency

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0")
],
targets: [
    .testTarget(
        name: "SnapshotTests",
        dependencies: [
            "ACCore",
            "ACRendering",
            .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
        ]
    )
]
```

### 2. Run Tests

```bash
cd ios
swift test --filter SnapshotTests
```

### 3. Update Snapshots

When you intentionally change UI, update snapshots:

```bash
# Set environment variable to record new snapshots
export RECORD_SNAPSHOTS=1
swift test --filter SnapshotTests
unset RECORD_SNAPSHOTS
```

## Directory Structure

```
SnapshotTests/
├── README.md                          # This file
├── __Snapshots__/                     # Generated snapshot images
│   └── SnapshotTests/
│       ├── testTextBlockSnapshot.png
│       ├── testImageSnapshot.png
│       └── ...
├── CardElementSnapshotTests.swift     # Core element snapshots
├── InputSnapshotTests.swift           # Input element snapshots
└── AdvancedSnapshotTests.swift        # Advanced element snapshots
```

## Writing Snapshot Tests

### Basic Example

```swift
import XCTest
import SwiftUI
import SnapshotTesting
@testable import ACCore
@testable import ACRendering

final class CardElementSnapshotTests: XCTestCase {
    
    func testTextBlockSnapshot() {
        let textBlock = TextBlock(
            text: "Hello World",
            size: .large,
            weight: .bolder
        )
        
        let view = TextBlockView(textBlock: textBlock, hostConfig: HostConfig())
            .frame(width: 320, height: 100)
        
        assertSnapshot(matching: view, as: .image)
    }
    
    func testContainerSnapshot() {
        let container = Container(
            items: [
                .textBlock(TextBlock(text: "Title", size: .large)),
                .textBlock(TextBlock(text: "Subtitle", color: .accent))
            ]
        )
        
        let view = ContainerView(container: container, hostConfig: HostConfig())
            .frame(width: 320)
        
        assertSnapshot(matching: view, as: .image)
    }
}
```

### Testing Different Configurations

```swift
func testTextBlockAllSizes() {
    let sizes: [TextSize] = [.small, .default, .medium, .large, .extraLarge]
    
    for size in sizes {
        let textBlock = TextBlock(text: "Sample Text", size: size)
        let view = TextBlockView(textBlock: textBlock, hostConfig: HostConfig())
            .frame(width: 320, height: 50)
        
        assertSnapshot(
            matching: view,
            as: .image,
            named: "size-\(size)"
        )
    }
}
```

### Testing Dark Mode

```swift
func testTextBlockDarkMode() {
    let textBlock = TextBlock(text: "Dark Mode Text")
    let view = TextBlockView(textBlock: textBlock, hostConfig: HostConfig())
        .frame(width: 320, height: 50)
        .environment(\.colorScheme, .dark)
    
    assertSnapshot(matching: view, as: .image)
}
```

### Testing Different Device Sizes

```swift
func testResponsiveLayout() {
    let card = // ... create card
    
    // iPhone
    assertSnapshot(
        matching: cardView,
        as: .image(layout: .device(config: .iPhone13)),
        named: "iphone"
    )
    
    // iPad
    assertSnapshot(
        matching: cardView,
        as: .image(layout: .device(config: .iPadPro11)),
        named: "ipad"
    )
}
```

## Best Practices

### 1. Test Key UI States

- Default rendering
- Empty states
- Error states
- Loading states
- Different data scenarios

### 2. Keep Snapshots Focused

- Test individual components, not entire screens
- Use fixed frame sizes for consistency
- Test one variation per test method

### 3. Naming Conventions

```swift
func testElementName_StateOrVariant() {
    // e.g., testTextBlock_LargeSize()
    // e.g., testContainer_WithBackgroundImage()
}
```

### 4. Use Named Snapshots for Variations

```swift
assertSnapshot(matching: view, as: .image, named: "variant-name")
```

### 5. Precision Threshold

For views with slight rendering variations:

```swift
assertSnapshot(
    matching: view,
    as: .image(precision: 0.99),  // 99% match required
    named: "optional-name"
)
```

## CI Integration

### GitHub Actions

The parity gate workflow includes snapshot testing support (currently disabled by default):

```yaml
- name: Run Snapshot Tests
  working-directory: ios
  run: swift test --filter SnapshotTests
  
- name: Upload Snapshot Failures
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: snapshot-test-failures
    path: ios/Tests/SnapshotTests/__Snapshots__/
```

To enable in CI, uncomment the snapshot test steps in `.github/workflows/parity-gate.yml`.

## Cross-Platform Visual Parity

To ensure iOS and Android render cards identically:

1. **Shared Test Cards**: Use the same JSON cards from `shared/test-cards/`
2. **Snapshot Both Platforms**: Generate snapshots for iOS and Android
3. **Visual Comparison**: Manually or programmatically compare snapshots
4. **Document Differences**: Any platform-specific differences should be documented in `PARITY_MATRIX.md`

## Troubleshooting

### Snapshots Don't Match After No Code Changes

This can happen due to:
- Different macOS/Xcode versions
- Different device simulators
- Font rendering differences

**Solution**: Record new snapshots on the same environment used in CI.

### Snapshots Are Too Large

**Solution**: Use smaller fixed frame sizes:

```swift
.frame(width: 320, height: 200)  // Standard iPhone width
```

### Async Content (Images, Network)

For components that load content asynchronously:

```swift
func testAsyncContent() async {
    let view = AsyncImageView(url: URL(string: "...")!)
    
    // Wait for content to load
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    
    assertSnapshot(matching: view, as: .image)
}
```

## Sample Test File

See `CardElementSnapshotTests.swift` for a complete example of testing various card elements.

## Additional Resources

- [Point-Free Snapshot Testing Tutorial](https://www.pointfree.co/collections/testing/snapshot-testing)
- [SwiftUI Testing Best Practices](https://developer.apple.com/documentation/swiftui/testing-swiftui-views)
- [Cross-Platform Visual Parity Guide](../../docs/architecture/PARITY_MATRIX.md)

## Status

**Current Status**: 🚧 Scaffolding in place

**Next Steps**:
1. Add swift-snapshot-testing dependency to Package.swift
2. Implement snapshot tests for core elements
3. Enable in CI pipeline
4. Create baseline snapshots for all elements

---

**Maintained by**: AdaptiveCards-Mobile Team  
**Last Updated**: February 13, 2026
