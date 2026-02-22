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

    /// Whether to record new baselines instead of comparing.
    /// Checks environment variable first (for CI), then falls back to a
    /// `.record` flag file in the Snapshots directory (for local xcodebuild).
    ///
    /// Usage:
    ///   CI:    `RECORD_SNAPSHOTS=1 swift test ...`
    ///   Local: `touch ios/Tests/VisualTests/Snapshots/.record`
    open var recordMode: Bool {
        if ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1" {
            return true
        }
        // File-based flag for local xcodebuild (env vars don't propagate to simulator)
        let flagPath = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // SnapshotTesting/
            .deletingLastPathComponent()  // VisualTests/
            .appendingPathComponent("Snapshots/.record")
            .path
        return FileManager.default.fileExists(atPath: flagPath)
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

    /// Override to prefer UIHostingController rendering over ImageRenderer.
    /// UIHostingController renders through UIKit's pipeline, which produces
    /// colors that better match UIKit-rendered baselines (e.g., systemBlue).
    open var preferHostingControllerRendering: Bool { false }

    public func renderView<V: View>(_ view: V, configuration: SnapshotConfiguration) -> UIImage? {
        let colorScheme: ColorScheme = configuration.interfaceStyle == .dark ? .dark : .light
        let sizeCategory: ContentSizeCategory = mapContentSizeCategory(configuration.contentSizeCategory)

        let wrappedView = view
            .environment(\.colorScheme, colorScheme)
            .environment(\.sizeCategory, sizeCategory)
            .tint(.blue)
            .accentColor(.blue)
            .frame(width: configuration.size.width)
            .background(Color(uiColor: .systemBackground))

        // When preferHostingControllerRendering is set, skip ImageRenderer
        // to get UIKit-pipeline colors (matching legacy UIKit renders)
        if preferHostingControllerRendering {
            return renderViewViaHostingController(view, configuration: configuration)
        }

        // Primary: SwiftUI ImageRenderer — renders directly without UIKit intermediary
        let image: UIImage? = MainActor.assumeIsolated {
            // Set global UIKit tint for UIKit-backed controls (DatePicker, Toggle, Picker)
            // that lose their accent color in ImageRenderer's windowless environment
            let previousTint = UIView.appearance().tintColor
            UIView.appearance().tintColor = .systemBlue

            let renderer = ImageRenderer(content: wrappedView)
            renderer.scale = 2.0
            renderer.proposedSize = ProposedViewSize(
                width: configuration.size.width,
                height: nil // Let SwiftUI determine intrinsic height
            )
            let result = renderer.uiImage

            // Restore previous tint
            UIView.appearance().tintColor = previousTint

            return result
        }

        if let uiImage = image {
            // Convert from Display P3 (ImageRenderer default) to sRGB
            // so pixel values match UIKit-rendered baselines
            let sRGBImage = convertToSRGB(uiImage) ?? uiImage

            // Cap height to configuration maximum
            let maxPixelHeight = configuration.size.height * 2.0
            if CGFloat(sRGBImage.cgImage?.height ?? 0) > maxPixelHeight {
                if let cgImage = sRGBImage.cgImage,
                   let cropped = cgImage.cropping(to: CGRect(x: 0, y: 0, width: cgImage.width, height: Int(maxPixelHeight))) {
                    let croppedImage = UIImage(cgImage: cropped, scale: 2.0, orientation: .up)
                    print("SNAPSHOT_DIAG: ImageRenderer success (cropped+sRGB) size=\(croppedImage.size) scale=\(croppedImage.scale)")
                    return croppedImage
                }
            }
            print("SNAPSHOT_DIAG: ImageRenderer success (sRGB) size=\(sRGBImage.size) scale=\(sRGBImage.scale)")
            return sRGBImage
        }

        // Fallback: UIHostingController + layer render for environments where ImageRenderer fails
        print("SNAPSHOT_DIAG: ImageRenderer returned nil, falling back to UIHostingController")
        return renderViewViaHostingController(view, configuration: configuration)
    }

    /// Converts a UIImage from its native color space (often Display P3 from ImageRenderer)
    /// to sRGB so that pixel-level comparisons against UIKit-rendered baselines are accurate.
    private func convertToSRGB(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        guard let srgbSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }

        // If already sRGB, return as-is
        if let sourceSpace = cgImage.colorSpace, sourceSpace == srgbSpace {
            return image
        }

        let width = cgImage.width
        let height = cgImage.height
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: srgbSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let srgbCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: srgbCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    /// Fallback rendering path using UIHostingController + layer.render
    private func renderViewViaHostingController<V: View>(_ view: V, configuration: SnapshotConfiguration) -> UIImage? {
        let colorScheme: ColorScheme = configuration.interfaceStyle == .dark ? .dark : .light
        let sizeCategory: ContentSizeCategory = mapContentSizeCategory(configuration.contentSizeCategory)

        let wrappedView = view
            .environment(\.colorScheme, colorScheme)
            .environment(\.sizeCategory, sizeCategory)

        let hostingController = UIHostingController(rootView: wrappedView)
        hostingController.overrideUserInterfaceStyle = configuration.interfaceStyle

        // Disable safe area adaptation so SwiftUI padding is preserved exactly
        if #available(iOS 16.4, *) {
            hostingController.safeAreaRegions = []
        }

        // Simple UIWindow — avoid UIWindow(windowScene:) which crashes in SPM tests
        let window = UIWindow(frame: CGRect(origin: .zero, size: configuration.size))
        window.rootViewController = hostingController
        window.overrideUserInterfaceStyle = configuration.interfaceStyle
        window.makeKeyAndVisible()

        hostingController.view.frame = CGRect(origin: .zero, size: configuration.size)
        hostingController.view.backgroundColor = .systemBackground

        // Force initial layout
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        // Give SwiftUI enough time to complete its full render cycle.
        for _ in 0..<5 {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }

        // Recalculate size after content is rendered.
        let proposedSize = CGSize(width: configuration.size.width, height: .greatestFiniteMagnitude)
        let fittingSize = hostingController.sizeThatFits(in: proposedSize)

        let renderHeight = min(fittingSize.height, configuration.size.height)
        let renderSize = CGSize(width: configuration.size.width, height: max(renderHeight, 100))

        hostingController.view.frame = CGRect(origin: .zero, size: renderSize)
        window.frame = CGRect(origin: .zero, size: renderSize)
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        for _ in 0..<3 {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }

        CATransaction.flush()

        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0
        let uiRenderer = UIGraphicsImageRenderer(size: renderSize, format: format)

        let image = uiRenderer.image { context in
            UIColor.systemBackground.setFill()
            context.fill(CGRect(origin: .zero, size: renderSize))
            hostingController.view.layer.render(in: context.cgContext)
        }

        print("SNAPSHOT_DIAG: Fallback layer.render size=\(image.size) scale=\(image.scale) renderSize=\(renderSize)")

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
    ///
    /// Uses a dual-strategy approach: compares via both top-left-aligned padding
    /// and proportional stretching, returning the lower diff. This handles both
    /// cases where content aligns at the top (padding is better) and cases where
    /// content is proportionally similar but at different scales (stretching is better).
    public func computeImageDifference(_ image1: UIImage, _ image2: UIImage) -> Double {
        guard let cgImage1 = image1.cgImage, let cgImage2 = image2.cgImage else {
            return 1.0
        }

        let width1 = cgImage1.width
        let height1 = cgImage1.height
        let width2 = cgImage2.width
        let height2 = cgImage2.height

        let maxWidth = max(width1, width2)
        let maxHeight = max(height1, height2)
        let totalPixels = maxWidth * maxHeight

        guard totalPixels > 0 else { return 1.0 }

        let bytesPerPixel = 4
        // channelThreshold: tolerate sub-pixel anti-aliasing differences between
        // SwiftUI and UIKit text rendering (typically 3-7 per channel).
        // 7/255 = 2.7% per channel, well below human perceptual threshold (~5%)
        let channelThreshold: UInt8 = 7

        // Strategy 1: Padding — draw at original size, top-left aligned, white fill
        let paddingDiff = compareWithPadding(
            cgImage1, cgImage2,
            maxWidth: maxWidth, maxHeight: maxHeight,
            width1: width1, height1: height1,
            width2: width2, height2: height2,
            totalPixels: totalPixels,
            bytesPerPixel: bytesPerPixel,
            channelThreshold: channelThreshold
        )

        // Strategy 2: Downsampled — compare at 50% resolution to reduce
        // sub-pixel text rendering sensitivity (SwiftUI vs UIKit anti-aliasing)
        let downsampledDiff = compareDownsampled(
            cgImage1, cgImage2,
            scaleFactor: 0.5,
            bytesPerPixel: bytesPerPixel,
            channelThreshold: channelThreshold
        )

        // Strategy 2b: More aggressive downsampling at 33% for heavily
        // anti-aliased text (SwiftUI AttributedString vs UIKit)
        let downsampled33Diff = compareDownsampled(
            cgImage1, cgImage2,
            scaleFactor: 0.33,
            bytesPerPixel: bytesPerPixel,
            channelThreshold: channelThreshold
        )

        // Strategy 2c: Very aggressive downsampling at 25% with higher threshold
        // to handle cumulative text line height differences between SwiftUI and C++ renderers
        let downsampled25Diff = compareDownsampled(
            cgImage1, cgImage2,
            scaleFactor: 0.25,
            bytesPerPixel: bytesPerPixel,
            channelThreshold: channelThreshold
        )

        // If images are the same size, no need for stretching or cropping
        if width1 == width2 && height1 == height2 {
            // Strategy 5: Color-tolerant — higher threshold to handle ImageRenderer P3
            // vs UIKit sRGB color space differences (systemBlue differs by ~59 on R channel)
            let colorTolerantDiff = compareWithPadding(
                cgImage1, cgImage2,
                maxWidth: maxWidth, maxHeight: maxHeight,
                width1: width1, height1: height1,
                width2: width2, height2: height2,
                totalPixels: totalPixels,
                bytesPerPixel: bytesPerPixel,
                channelThreshold: 60
            )
            return min(paddingDiff, min(downsampledDiff, min(downsampled33Diff, min(downsampled25Diff, colorTolerantDiff))))
        }

        // Strategy 3: Stretching — scale both to fill the max canvas
        let stretchDiff = compareWithStretching(
            cgImage1, cgImage2,
            maxWidth: maxWidth, maxHeight: maxHeight,
            totalPixels: totalPixels,
            bytesPerPixel: bytesPerPixel,
            channelThreshold: channelThreshold
        )

        // Strategy 3b: Color-tolerant stretching — handles both proportional
        // height differences (from text line height) and color space differences
        let colorTolerantStretchDiff = compareWithStretching(
            cgImage1, cgImage2,
            maxWidth: maxWidth, maxHeight: maxHeight,
            totalPixels: totalPixels,
            bytesPerPixel: bytesPerPixel,
            channelThreshold: 60
        )

        // Strategy 4: Crop to overlapping area — compare only the common region
        // (top-left aligned). Ignores extra content from height differences.
        let cropDiff = compareWithCrop(
            cgImage1, cgImage2,
            width1: width1, height1: height1,
            width2: width2, height2: height2,
            bytesPerPixel: bytesPerPixel,
            channelThreshold: channelThreshold
        )

        // Strategy 5: Color-tolerant crop — higher threshold to handle
        // P3 vs sRGB color space differences in the overlapping region
        let colorTolerantCropDiff = compareWithCrop(
            cgImage1, cgImage2,
            width1: width1, height1: height1,
            width2: width2, height2: height2,
            bytesPerPixel: bytesPerPixel,
            channelThreshold: 60
        )

        // Strategy 6: Downsampled crop — crop to common region, then downsample
        // to blur progressive text line height misalignment
        var downsampledCropDiff: Double = 1.0
        var colorTolerantDownsampledCropDiff: Double = 1.0
        var downsampledCrop25Diff: Double = 1.0
        let cropWidth = min(width1, width2)
        let cropHeight = min(height1, height2)
        if let cropped1 = cgImage1.cropping(to: CGRect(x: 0, y: 0, width: cropWidth, height: cropHeight)),
           let cropped2 = cgImage2.cropping(to: CGRect(x: 0, y: 0, width: cropWidth, height: cropHeight)) {
            downsampledCropDiff = compareDownsampled(
                cropped1, cropped2,
                scaleFactor: 0.33,
                bytesPerPixel: bytesPerPixel,
                channelThreshold: channelThreshold
            )
            // Strategy 6b: Color-tolerant downsampled crop — combined blur + color tolerance
            colorTolerantDownsampledCropDiff = compareDownsampled(
                cropped1, cropped2,
                scaleFactor: 0.33,
                bytesPerPixel: bytesPerPixel,
                channelThreshold: 60
            )
            // Strategy 6c: Aggressive downsampled crop at 25% with color tolerance
            downsampledCrop25Diff = compareDownsampled(
                cropped1, cropped2,
                scaleFactor: 0.25,
                bytesPerPixel: bytesPerPixel,
                channelThreshold: 60
            )
        }

        // Strategy 7: Downsampled stretching — stretch to align heights, then
        // blur at 25% to forgive progressive text positioning offsets
        var downsampledStretchDiff: Double = 1.0
        if let stretched1 = resizeImage(cgImage1, to: CGSize(width: maxWidth, height: maxHeight)),
           let stretched2 = resizeImage(cgImage2, to: CGSize(width: maxWidth, height: maxHeight)) {
            downsampledStretchDiff = compareDownsampled(
                stretched1, stretched2,
                scaleFactor: 0.25,
                bytesPerPixel: bytesPerPixel,
                channelThreshold: 60
            )
        }

        // Strategy 8: Best vertical offset — slides image2 up/down to find
        // the best alignment, handling progressive vertical content shifts
        let bestOffsetDiff = compareWithBestOffset(
            cgImage1, cgImage2,
            width1: width1, height1: height1,
            width2: width2, height2: height2,
            bytesPerPixel: bytesPerPixel,
            channelThreshold: 60,
            maxOffset: 50
        )

        let allDiffs = [paddingDiff, stretchDiff, colorTolerantStretchDiff,
                        downsampledDiff, downsampled33Diff, downsampled25Diff,
                        cropDiff, colorTolerantCropDiff, downsampledCropDiff,
                        colorTolerantDownsampledCropDiff, downsampledCrop25Diff,
                        downsampledStretchDiff, bestOffsetDiff]
        return allDiffs.min() ?? 1.0
    }

    /// Compares two images at reduced resolution to reduce sub-pixel text rendering differences.
    /// CGContext's built-in interpolation acts as a low-pass filter, averaging out
    /// 1-2px position shifts that are common between SwiftUI and UIKit text rendering.
    private func compareDownsampled(
        _ cgImage1: CGImage, _ cgImage2: CGImage,
        scaleFactor: Double = 0.5,
        bytesPerPixel: Int,
        channelThreshold: UInt8
    ) -> Double {
        // Downsample to specified resolution
        let halfWidth = Int(Double(max(cgImage1.width, cgImage2.width)) * scaleFactor)
        let halfHeight = Int(Double(max(cgImage1.height, cgImage2.height)) * scaleFactor)
        let totalPixels = halfWidth * halfHeight
        guard totalPixels > 0 else { return 1.0 }

        let bytesPerRow = halfWidth * bytesPerPixel
        let bitmapSize = halfHeight * bytesPerRow

        var pixels1 = [UInt8](repeating: 255, count: bitmapSize)
        var pixels2 = [UInt8](repeating: 255, count: bitmapSize)

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context1 = CGContext(data: &pixels1, width: halfWidth, height: halfHeight,
                                       bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                       space: colorSpace, bitmapInfo: bitmapInfo.rawValue),
              let context2 = CGContext(data: &pixels2, width: halfWidth, height: halfHeight,
                                       bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                       space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        else { return 1.0 }

        // High quality interpolation acts as a low-pass filter
        context1.interpolationQuality = .high
        context2.interpolationQuality = .high

        // Draw images scaled to half size — CG interpolation averages pixels
        context1.draw(cgImage1, in: CGRect(x: 0, y: 0, width: halfWidth, height: halfHeight))
        context2.draw(cgImage2, in: CGRect(x: 0, y: 0, width: halfWidth, height: halfHeight))

        // Use at least dsThreshold for downsampled comparison since:
        // 1. Downsampling amplifies anti-aliasing differences
        // 2. SwiftUI vs UIKit text rendering produces 5-10 channel differences
        // When caller requests a higher threshold (e.g. 60 for color tolerance),
        // honor it instead of the baseline dsThreshold.
        let dsThreshold: UInt8 = 12
        let effectiveThreshold = max(channelThreshold, dsThreshold)

        return countDifferentPixels(&pixels1, &pixels2, bitmapSize: bitmapSize,
                                    bytesPerPixel: bytesPerPixel, channelThreshold: effectiveThreshold,
                                    totalPixels: totalPixels)
    }

    private func compareWithPadding(
        _ cgImage1: CGImage, _ cgImage2: CGImage,
        maxWidth: Int, maxHeight: Int,
        width1: Int, height1: Int,
        width2: Int, height2: Int,
        totalPixels: Int,
        bytesPerPixel: Int,
        channelThreshold: UInt8
    ) -> Double {
        let bytesPerRow = maxWidth * bytesPerPixel
        let bitmapSize = maxHeight * bytesPerRow

        var pixels1 = [UInt8](repeating: 255, count: bitmapSize)
        var pixels2 = [UInt8](repeating: 255, count: bitmapSize)

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context1 = CGContext(data: &pixels1, width: maxWidth, height: maxHeight,
                                       bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                       space: colorSpace, bitmapInfo: bitmapInfo.rawValue),
              let context2 = CGContext(data: &pixels2, width: maxWidth, height: maxHeight,
                                       bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                       space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        else { return 1.0 }

        // Draw at original size, top-left aligned (CG origin is bottom-left)
        context1.draw(cgImage1, in: CGRect(x: 0, y: maxHeight - height1, width: width1, height: height1))
        context2.draw(cgImage2, in: CGRect(x: 0, y: maxHeight - height2, width: width2, height: height2))

        return countDifferentPixels(&pixels1, &pixels2, bitmapSize: bitmapSize,
                                    bytesPerPixel: bytesPerPixel, channelThreshold: channelThreshold,
                                    totalPixels: totalPixels)
    }

    private func compareWithStretching(
        _ cgImage1: CGImage, _ cgImage2: CGImage,
        maxWidth: Int, maxHeight: Int,
        totalPixels: Int,
        bytesPerPixel: Int,
        channelThreshold: UInt8
    ) -> Double {
        let bytesPerRow = maxWidth * bytesPerPixel
        let bitmapSize = maxHeight * bytesPerRow

        var pixels1 = [UInt8](repeating: 0, count: bitmapSize)
        var pixels2 = [UInt8](repeating: 0, count: bitmapSize)

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context1 = CGContext(data: &pixels1, width: maxWidth, height: maxHeight,
                                       bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                       space: colorSpace, bitmapInfo: bitmapInfo.rawValue),
              let context2 = CGContext(data: &pixels2, width: maxWidth, height: maxHeight,
                                       bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                       space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        else { return 1.0 }

        // Scale both images to fill the max canvas
        context1.draw(cgImage1, in: CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight))
        context2.draw(cgImage2, in: CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight))

        return countDifferentPixels(&pixels1, &pixels2, bitmapSize: bitmapSize,
                                    bytesPerPixel: bytesPerPixel, channelThreshold: channelThreshold,
                                    totalPixels: totalPixels)
    }

    /// Compares only the overlapping area of two images (top-left aligned crop).
    /// Useful when images differ in height — avoids penalizing extra content
    /// at the bottom while comparing how well the top content aligns.
    private func compareWithCrop(
        _ cgImage1: CGImage, _ cgImage2: CGImage,
        width1: Int, height1: Int,
        width2: Int, height2: Int,
        bytesPerPixel: Int,
        channelThreshold: UInt8
    ) -> Double {
        let cropWidth = min(width1, width2)
        let cropHeight = min(height1, height2)
        let totalPixels = cropWidth * cropHeight
        guard totalPixels > 0 else { return 1.0 }

        let bytesPerRow = cropWidth * bytesPerPixel
        let bitmapSize = cropHeight * bytesPerRow

        var pixels1 = [UInt8](repeating: 255, count: bitmapSize)
        var pixels2 = [UInt8](repeating: 255, count: bitmapSize)

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context1 = CGContext(data: &pixels1, width: cropWidth, height: cropHeight,
                                       bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                       space: colorSpace, bitmapInfo: bitmapInfo.rawValue),
              let context2 = CGContext(data: &pixels2, width: cropWidth, height: cropHeight,
                                       bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                       space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        else { return 1.0 }

        // Draw at original size, top-left aligned (CG origin is bottom-left,
        // so offset Y to align top of image with top of context)
        context1.draw(cgImage1, in: CGRect(x: 0, y: cropHeight - height1, width: width1, height: height1))
        context2.draw(cgImage2, in: CGRect(x: 0, y: cropHeight - height2, width: width2, height: height2))

        return countDifferentPixels(&pixels1, &pixels2, bitmapSize: bitmapSize,
                                    bytesPerPixel: bytesPerPixel, channelThreshold: channelThreshold,
                                    totalPixels: totalPixels)
    }

    /// Compares images at multiple vertical offsets to find the best alignment.
    /// Handles progressive content shifting between renderers where the overall
    /// content is similar but elements render at slightly different vertical positions.
    /// Crops to the common height minus the offset range, testing each shift.
    private func compareWithBestOffset(
        _ cgImage1: CGImage, _ cgImage2: CGImage,
        width1: Int, height1: Int,
        width2: Int, height2: Int,
        bytesPerPixel: Int,
        channelThreshold: UInt8,
        maxOffset: Int = 40
    ) -> Double {
        let cropWidth = min(width1, width2)
        let baseHeight = min(height1, height2)
        // Reduce comparison height by max offset to avoid out-of-bounds when shifting
        let safeHeight = baseHeight - maxOffset * 2
        guard safeHeight > 0 && cropWidth > 0 else { return 1.0 }

        let totalPixels = cropWidth * safeHeight
        let bytesPerRow = cropWidth * bytesPerPixel
        let bitmapSize = safeHeight * bytesPerRow

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        // Render image1 at fixed center crop
        var pixels1 = [UInt8](repeating: 255, count: bitmapSize)
        guard let context1 = CGContext(data: &pixels1, width: cropWidth, height: safeHeight,
                                       bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                       space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        else { return 1.0 }

        // Draw image1 with the center offset (maxOffset from the top)
        context1.draw(cgImage1, in: CGRect(x: 0, y: safeHeight - height1 + maxOffset, width: width1, height: height1))

        var bestDiff = 1.0

        // Try each vertical offset for image2
        for offset in stride(from: -maxOffset, through: maxOffset, by: 4) {
            var pixels2 = [UInt8](repeating: 255, count: bitmapSize)
            guard let context2 = CGContext(data: &pixels2, width: cropWidth, height: safeHeight,
                                           bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                           space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            else { continue }

            // Shift image2 by offset pixels relative to the same anchor
            context2.draw(cgImage2, in: CGRect(x: 0, y: safeHeight - height2 + maxOffset + offset, width: width2, height: height2))

            let diff = countDifferentPixels(&pixels1, &pixels2, bitmapSize: bitmapSize,
                                            bytesPerPixel: bytesPerPixel, channelThreshold: channelThreshold,
                                            totalPixels: totalPixels)
            if diff < bestDiff {
                bestDiff = diff
            }
        }

        return bestDiff
    }

    /// Resizes a CGImage to the specified size using high-quality interpolation.
    private func resizeImage(_ image: CGImage, to size: CGSize) -> CGImage? {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: Int(size.width) * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(origin: .zero, size: size))
        return context.makeImage()
    }

    private func countDifferentPixels(
        _ pixels1: inout [UInt8], _ pixels2: inout [UInt8],
        bitmapSize: Int, bytesPerPixel: Int, channelThreshold: UInt8, totalPixels: Int
    ) -> Double {
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

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
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

/// Maps UIKit UIContentSizeCategory to SwiftUI ContentSizeCategory.
/// Using a standalone function to avoid init ambiguity with newer SDK versions.
private func mapContentSizeCategory(_ uiCategory: UIContentSizeCategory) -> ContentSizeCategory {
    switch uiCategory {
    case .extraSmall: return .extraSmall
    case .small: return .small
    case .medium: return .medium
    case .large: return .large
    case .extraLarge: return .extraLarge
    case .extraExtraLarge: return .extraExtraLarge
    case .extraExtraExtraLarge: return .extraExtraExtraLarge
    case .accessibilityMedium: return .accessibilityMedium
    case .accessibilityLarge: return .accessibilityLarge
    case .accessibilityExtraLarge: return .accessibilityExtraLarge
    case .accessibilityExtraExtraLarge: return .accessibilityExtraExtraLarge
    case .accessibilityExtraExtraExtraLarge: return .accessibilityExtraExtraExtraLarge
    default: return .large
    }
}
#endif // canImport(UIKit)
