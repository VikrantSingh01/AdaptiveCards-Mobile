import XCTest
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
// MARK: - Snapshot Configuration

/// Configuration for a snapshot test defining device and environment parameters
public struct SnapshotConfiguration: CustomStringConvertible {
    public let name: String
    public let size: CGSize
    public let traits: UITraitCollection
    public let interfaceStyle: UIUserInterfaceStyle
    public let contentSizeCategory: UIContentSizeCategory

    public var description: String { name }

    public init(
        name: String,
        size: CGSize,
        interfaceStyle: UIUserInterfaceStyle = .light,
        contentSizeCategory: UIContentSizeCategory = .large,
        horizontalSizeClass: UIUserInterfaceSizeClass = .compact,
        verticalSizeClass: UIUserInterfaceSizeClass = .regular
    ) {
        self.name = name
        self.size = size
        self.interfaceStyle = interfaceStyle
        self.contentSizeCategory = contentSizeCategory
        self.traits = UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: interfaceStyle),
            UITraitCollection(preferredContentSizeCategory: contentSizeCategory),
            UITraitCollection(horizontalSizeClass: horizontalSizeClass),
            UITraitCollection(verticalSizeClass: verticalSizeClass),
        ])
    }
}

// MARK: - Predefined Configurations

public extension SnapshotConfiguration {
    // Device size presets
    static let iPhoneSE = SnapshotConfiguration(
        name: "iPhone_SE",
        size: CGSize(width: 375, height: 667),
        horizontalSizeClass: .compact,
        verticalSizeClass: .regular
    )

    static let iPhone15Pro = SnapshotConfiguration(
        name: "iPhone_15_Pro",
        size: CGSize(width: 393, height: 852),
        horizontalSizeClass: .compact,
        verticalSizeClass: .regular
    )

    static let iPadPortrait = SnapshotConfiguration(
        name: "iPad_Portrait",
        size: CGSize(width: 810, height: 1080),
        horizontalSizeClass: .regular,
        verticalSizeClass: .regular
    )

    // Dark mode variants
    static let iPhoneSEDark = SnapshotConfiguration(
        name: "iPhone_SE_Dark",
        size: CGSize(width: 375, height: 667),
        interfaceStyle: .dark,
        horizontalSizeClass: .compact,
        verticalSizeClass: .regular
    )

    static let iPhone15ProDark = SnapshotConfiguration(
        name: "iPhone_15_Pro_Dark",
        size: CGSize(width: 393, height: 852),
        interfaceStyle: .dark,
        horizontalSizeClass: .compact,
        verticalSizeClass: .regular
    )

    static let iPadPortraitDark = SnapshotConfiguration(
        name: "iPad_Portrait_Dark",
        size: CGSize(width: 810, height: 1080),
        interfaceStyle: .dark,
        horizontalSizeClass: .regular,
        verticalSizeClass: .regular
    )

    // Landscape variants
    static let iPhoneSELandscape = SnapshotConfiguration(
        name: "iPhone_SE_Landscape",
        size: CGSize(width: 667, height: 375),
        horizontalSizeClass: .compact,
        verticalSizeClass: .compact
    )

    static let iPhone15ProLandscape = SnapshotConfiguration(
        name: "iPhone_15_Pro_Landscape",
        size: CGSize(width: 852, height: 393),
        horizontalSizeClass: .compact,
        verticalSizeClass: .compact
    )

    static let iPadLandscape = SnapshotConfiguration(
        name: "iPad_Landscape",
        size: CGSize(width: 1080, height: 810),
        interfaceStyle: .light,
        horizontalSizeClass: .regular,
        verticalSizeClass: .regular
    )

    // Accessibility size variants
    static let iPhoneAccessibilitySmall = SnapshotConfiguration(
        name: "iPhone_15_Pro_A11y_XS",
        size: CGSize(width: 393, height: 852),
        contentSizeCategory: .extraSmall,
        horizontalSizeClass: .compact,
        verticalSizeClass: .regular
    )

    static let iPhoneAccessibilityLarge = SnapshotConfiguration(
        name: "iPhone_15_Pro_A11y_XXXL",
        size: CGSize(width: 393, height: 852),
        contentSizeCategory: .accessibilityExtraExtraExtraLarge,
        horizontalSizeClass: .compact,
        verticalSizeClass: .regular
    )

    static let iPhoneAccessibilityMedium = SnapshotConfiguration(
        name: "iPhone_15_Pro_A11y_XL",
        size: CGSize(width: 393, height: 852),
        contentSizeCategory: .extraExtraLarge,
        horizontalSizeClass: .compact,
        verticalSizeClass: .regular
    )

    // Preset groups
    static let allDeviceSizes: [SnapshotConfiguration] = [
        .iPhoneSE, .iPhone15Pro, .iPadPortrait
    ]

    static let allAppearances: [SnapshotConfiguration] = [
        .iPhone15Pro, .iPhone15ProDark
    ]

    static let allOrientations: [SnapshotConfiguration] = [
        .iPhone15Pro, .iPhone15ProLandscape
    ]

    static let allAccessibilitySizes: [SnapshotConfiguration] = [
        .iPhoneAccessibilitySmall, .iPhone15Pro, .iPhoneAccessibilityMedium, .iPhoneAccessibilityLarge
    ]

    static let comprehensive: [SnapshotConfiguration] = [
        .iPhoneSE, .iPhone15Pro, .iPadPortrait,
        .iPhoneSEDark, .iPhone15ProDark, .iPadPortraitDark,
        .iPhoneSELandscape, .iPhone15ProLandscape, .iPadLandscape,
        .iPhoneAccessibilitySmall, .iPhoneAccessibilityMedium, .iPhoneAccessibilityLarge
    ]

    /// Core configurations: light/dark on iPhone 15 Pro, plus iPad and accessibility
    static let core: [SnapshotConfiguration] = [
        .iPhone15Pro, .iPhone15ProDark,
        .iPadPortrait,
        .iPhoneAccessibilityLarge
    ]
}

// MARK: - Snapshot Diff Result

/// Result of comparing two snapshots
public struct SnapshotDiffResult {
    public let passed: Bool
    public let diffPercentage: Double
    public let baselinePath: String?
    public let actualPath: String?
    public let diffPath: String?
    public let message: String
}

// MARK: - Snapshot Test Case

/// Base class for visual regression tests. Provides infrastructure for capturing
/// SwiftUI view snapshots and comparing them against baseline images.
open class SnapshotTestCase: XCTestCase {

    /// Tolerance for pixel-level comparison (0.0 = exact, 1.0 = no comparison)
    open var snapshotTolerance: Double { 0.01 }

    /// Whether to record new baselines instead of comparing
    open var recordMode: Bool {
        ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"
    }

    /// Root directory for snapshot storage
    private var snapshotDirectory: String {
        let testsDir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // SnapshotTesting/
            .deletingLastPathComponent()  // VisualTests/
        return testsDir.appendingPathComponent("Snapshots").path
    }

    private var baselinesDirectory: String {
        "\(snapshotDirectory)/Baselines"
    }

    private var failuresDirectory: String {
        "\(snapshotDirectory)/Failures"
    }

    private var diffsDirectory: String {
        "\(snapshotDirectory)/Diffs"
    }

    // MARK: - Public API

    /// Captures a snapshot of a SwiftUI view and compares against the baseline.
    ///
    /// - Parameters:
    ///   - view: The SwiftUI view to snapshot
    ///   - name: Name for the snapshot file (typically the test card name)
    ///   - configuration: Device/environment configuration
    ///   - file: Source file (auto-filled)
    ///   - line: Source line (auto-filled)
    /// - Returns: The diff result
    @discardableResult
    public func assertSnapshot<V: View>(
        of view: V,
        named name: String,
        configuration: SnapshotConfiguration,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> SnapshotDiffResult {
        let snapshotName = "\(name)_\(configuration.name)"

        // Render the view to an image
        guard let actualImage = renderView(view, configuration: configuration) else {
            let result = SnapshotDiffResult(
                passed: false,
                diffPercentage: 1.0,
                baselinePath: nil,
                actualPath: nil,
                diffPath: nil,
                message: "Failed to render view for snapshot: \(snapshotName)"
            )
            XCTFail(result.message, file: file, line: line)
            return result
        }

        let baselinePath = "\(baselinesDirectory)/\(snapshotName).png"

        if recordMode {
            // Save as new baseline
            return saveBaseline(actualImage, path: baselinePath, name: snapshotName, file: file, line: line)
        } else {
            // Compare against existing baseline
            return compareSnapshot(actualImage, baselinePath: baselinePath, name: snapshotName, file: file, line: line)
        }
    }

    /// Captures snapshots across multiple configurations
    ///
    /// - Parameters:
    ///   - view: The SwiftUI view to snapshot
    ///   - name: Name for the snapshot files
    ///   - configurations: Array of device/environment configurations
    ///   - file: Source file (auto-filled)
    ///   - line: Source line (auto-filled)
    /// - Returns: Array of diff results
    @discardableResult
    public func assertSnapshots<V: View>(
        of view: V,
        named name: String,
        configurations: [SnapshotConfiguration],
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> [SnapshotDiffResult] {
        var results: [SnapshotDiffResult] = []
        for config in configurations {
            let result = assertSnapshot(
                of: view,
                named: name,
                configuration: config,
                file: file,
                line: line
            )
            results.append(result)
        }
        return results
    }

    // MARK: - View Rendering

    /// Renders a SwiftUI view to a UIImage with the given configuration
    public func renderView<V: View>(_ view: V, configuration: SnapshotConfiguration) -> UIImage? {
        let wrappedView = view
            .environment(\.colorScheme, configuration.interfaceStyle == .dark ? .dark : .light)
            .environment(\.sizeCategory, ContentSizeCategory(configuration.contentSizeCategory))

        let hostingController = UIHostingController(rootView: wrappedView)
        hostingController.overrideUserInterfaceStyle = configuration.interfaceStyle

        let window = UIWindow(frame: CGRect(origin: .zero, size: configuration.size))
        window.rootViewController = hostingController
        window.overrideUserInterfaceStyle = configuration.interfaceStyle
        window.makeKeyAndVisible()

        hostingController.view.frame = CGRect(origin: .zero, size: configuration.size)
        hostingController.view.backgroundColor = configuration.interfaceStyle == .dark
            ? UIColor.systemBackground
            : UIColor.systemBackground

        // Force layout
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        // Calculate the intrinsic content height
        let targetSize = CGSize(
            width: configuration.size.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let fittingSize = hostingController.view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        // Use the fitted height but cap at the configured height
        let renderHeight = min(fittingSize.height, configuration.size.height)
        let renderSize = CGSize(width: configuration.size.width, height: max(renderHeight, 100))

        hostingController.view.frame = CGRect(origin: .zero, size: renderSize)
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        // Render to image
        let renderer = UIGraphicsImageRenderer(size: renderSize, format: .init(for: configuration.traits))
        let image = renderer.image { context in
            hostingController.view.drawHierarchy(in: CGRect(origin: .zero, size: renderSize), afterScreenUpdates: true)
        }

        // Clean up
        window.isHidden = true

        return image
    }

    // MARK: - Comparison

    private func compareSnapshot(
        _ actualImage: UIImage,
        baselinePath: String,
        name: String,
        file: StaticString,
        line: UInt
    ) -> SnapshotDiffResult {
        // Check if baseline exists
        guard FileManager.default.fileExists(atPath: baselinePath),
              let baselineData = try? Data(contentsOf: URL(fileURLWithPath: baselinePath)),
              let baselineImage = UIImage(data: baselineData) else {
            // No baseline - save current and fail
            let failurePath = "\(failuresDirectory)/\(name)_actual.png"
            saveImage(actualImage, to: failurePath)

            let result = SnapshotDiffResult(
                passed: false,
                diffPercentage: 1.0,
                baselinePath: nil,
                actualPath: failurePath,
                diffPath: nil,
                message: "No baseline found for '\(name)'. Run with RECORD_SNAPSHOTS=1 to create baselines. Actual image saved to: \(failurePath)"
            )
            XCTFail(result.message, file: file, line: line)
            return result
        }

        // Compare images
        let diffPercentage = computeImageDifference(baselineImage, actualImage)

        if diffPercentage <= snapshotTolerance {
            return SnapshotDiffResult(
                passed: true,
                diffPercentage: diffPercentage,
                baselinePath: baselinePath,
                actualPath: nil,
                diffPath: nil,
                message: "Snapshot '\(name)' matches baseline (diff: \(String(format: "%.4f%%", diffPercentage * 100)))"
            )
        } else {
            // Save failure artifacts
            let actualPath = "\(failuresDirectory)/\(name)_actual.png"
            let diffPath = "\(diffsDirectory)/\(name)_diff.png"

            saveImage(actualImage, to: actualPath)

            if let diffImage = generateDiffImage(baselineImage, actualImage) {
                saveImage(diffImage, to: diffPath)
            }

            let result = SnapshotDiffResult(
                passed: false,
                diffPercentage: diffPercentage,
                baselinePath: baselinePath,
                actualPath: actualPath,
                diffPath: diffPath,
                message: "Snapshot '\(name)' differs from baseline by \(String(format: "%.2f%%", diffPercentage * 100)) (tolerance: \(String(format: "%.2f%%", snapshotTolerance * 100))). Diff saved to: \(diffPath)"
            )
            XCTFail(result.message, file: file, line: line)
            return result
        }
    }

    private func saveBaseline(
        _ image: UIImage,
        path: String,
        name: String,
        file: StaticString,
        line: UInt
    ) -> SnapshotDiffResult {
        saveImage(image, to: path)

        let result = SnapshotDiffResult(
            passed: true,
            diffPercentage: 0,
            baselinePath: path,
            actualPath: nil,
            diffPath: nil,
            message: "Recorded baseline snapshot for '\(name)' at: \(path)"
        )

        // In record mode we still want to see what was recorded but not fail
        print("SNAPSHOT RECORDED: \(result.message)")
        return result
    }

    // MARK: - Image Comparison Engine

    /// Computes the percentage of pixels that differ between two images.
    /// Returns a value between 0.0 (identical) and 1.0 (completely different).
    public func computeImageDifference(_ image1: UIImage, _ image2: UIImage) -> Double {
        guard let cgImage1 = image1.cgImage, let cgImage2 = image2.cgImage else {
            return 1.0
        }

        let width1 = cgImage1.width
        let height1 = cgImage1.height
        let width2 = cgImage2.width
        let height2 = cgImage2.height

        // If sizes differ, use the max dimensions and consider size difference
        let maxWidth = max(width1, width2)
        let maxHeight = max(height1, height2)
        let totalPixels = maxWidth * maxHeight

        guard totalPixels > 0 else { return 1.0 }

        // Render both images to the same size RGBA bitmap
        let bytesPerPixel = 4
        let bytesPerRow = maxWidth * bytesPerPixel
        let bitmapSize = maxHeight * bytesPerRow

        var pixels1 = [UInt8](repeating: 0, count: bitmapSize)
        var pixels2 = [UInt8](repeating: 0, count: bitmapSize)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context1 = CGContext(
            data: &pixels1,
            width: maxWidth,
            height: maxHeight,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return 1.0 }

        guard let context2 = CGContext(
            data: &pixels2,
            width: maxWidth,
            height: maxHeight,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return 1.0 }

        context1.draw(cgImage1, in: CGRect(x: 0, y: 0, width: width1, height: height1))
        context2.draw(cgImage2, in: CGRect(x: 0, y: 0, width: width2, height: height2))

        // Count differing pixels (with per-channel threshold to handle anti-aliasing)
        let channelThreshold: UInt8 = 3
        var differentPixels = 0

        for i in stride(from: 0, to: bitmapSize, by: bytesPerPixel) {
            let rDiff = abs(Int(pixels1[i]) - Int(pixels2[i]))
            let gDiff = abs(Int(pixels1[i+1]) - Int(pixels2[i+1]))
            let bDiff = abs(Int(pixels1[i+2]) - Int(pixels2[i+2]))
            let aDiff = abs(Int(pixels1[i+3]) - Int(pixels2[i+3]))

            if rDiff > Int(channelThreshold) ||
               gDiff > Int(channelThreshold) ||
               bDiff > Int(channelThreshold) ||
               aDiff > Int(channelThreshold) {
                differentPixels += 1
            }
        }

        return Double(differentPixels) / Double(totalPixels)
    }

    /// Generates a visual diff image highlighting the differences in red
    public func generateDiffImage(_ baseline: UIImage, _ actual: UIImage) -> UIImage? {
        guard let cgBaseline = baseline.cgImage, let cgActual = actual.cgImage else {
            return nil
        }

        let maxWidth = max(cgBaseline.width, cgActual.width)
        let maxHeight = max(cgBaseline.height, cgActual.height)

        let bytesPerPixel = 4
        let bytesPerRow = maxWidth * bytesPerPixel
        let bitmapSize = maxHeight * bytesPerRow

        var pixels1 = [UInt8](repeating: 0, count: bitmapSize)
        var pixels2 = [UInt8](repeating: 0, count: bitmapSize)
        var diffPixels = [UInt8](repeating: 0, count: bitmapSize)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context1 = CGContext(
            data: &pixels1,
            width: maxWidth, height: maxHeight,
            bitsPerComponent: 8, bytesPerRow: bytesPerRow,
            space: colorSpace, bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }

        guard let context2 = CGContext(
            data: &pixels2,
            width: maxWidth, height: maxHeight,
            bitsPerComponent: 8, bytesPerRow: bytesPerRow,
            space: colorSpace, bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }

        context1.draw(cgBaseline, in: CGRect(x: 0, y: 0, width: cgBaseline.width, height: cgBaseline.height))
        context2.draw(cgActual, in: CGRect(x: 0, y: 0, width: cgActual.width, height: cgActual.height))

        let channelThreshold: UInt8 = 3

        for i in stride(from: 0, to: bitmapSize, by: bytesPerPixel) {
            let rDiff = abs(Int(pixels1[i]) - Int(pixels2[i]))
            let gDiff = abs(Int(pixels1[i+1]) - Int(pixels2[i+1]))
            let bDiff = abs(Int(pixels1[i+2]) - Int(pixels2[i+2]))
            let aDiff = abs(Int(pixels1[i+3]) - Int(pixels2[i+3]))

            if rDiff > Int(channelThreshold) ||
               gDiff > Int(channelThreshold) ||
               bDiff > Int(channelThreshold) ||
               aDiff > Int(channelThreshold) {
                // Highlight difference in red
                diffPixels[i] = 255      // R
                diffPixels[i+1] = 0      // G
                diffPixels[i+2] = 0      // B
                diffPixels[i+3] = 200    // A
            } else {
                // Show baseline dimmed
                diffPixels[i] = UInt8(min(Int(pixels1[i]) / 3 + 170, 255))
                diffPixels[i+1] = UInt8(min(Int(pixels1[i+1]) / 3 + 170, 255))
                diffPixels[i+2] = UInt8(min(Int(pixels1[i+2]) / 3 + 170, 255))
                diffPixels[i+3] = pixels1[i+3]
            }
        }

        guard let diffContext = CGContext(
            data: &diffPixels,
            width: maxWidth, height: maxHeight,
            bitsPerComponent: 8, bytesPerRow: bytesPerRow,
            space: colorSpace, bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }

        guard let diffCGImage = diffContext.makeImage() else { return nil }
        return UIImage(cgImage: diffCGImage)
    }

    // MARK: - File I/O

    private func saveImage(_ image: UIImage, to path: String) {
        let url = URL(fileURLWithPath: path)
        let directory = url.deletingLastPathComponent()

        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        if let data = image.pngData() {
            try? data.write(to: url)
        }
    }
}

// MARK: - ContentSizeCategory Conversion

extension ContentSizeCategory {
    init(_ uiContentSizeCategory: UIContentSizeCategory) {
        switch uiContentSizeCategory {
        case .extraSmall: self = .extraSmall
        case .small: self = .small
        case .medium: self = .medium
        case .large: self = .large
        case .extraLarge: self = .extraLarge
        case .extraExtraLarge: self = .extraExtraLarge
        case .extraExtraExtraLarge: self = .extraExtraExtraLarge
        case .accessibilityMedium: self = .accessibilityMedium
        case .accessibilityLarge: self = .accessibilityLarge
        case .accessibilityExtraLarge: self = .accessibilityExtraLarge
        case .accessibilityExtraExtraLarge: self = .accessibilityExtraExtraLarge
        case .accessibilityExtraExtraExtraLarge: self = .accessibilityExtraExtraExtraLarge
        default: self = .large
        }
    }
}
#endif // canImport(UIKit)
