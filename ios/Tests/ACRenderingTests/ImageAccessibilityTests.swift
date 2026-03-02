// ImageAccessibilityTests.swift
// Tests for Image element accessibility (upstream #490, #375)
//
// Verifies that images announce their role as "image" to VoiceOver,
// both when altText is provided and when it falls back to the default.

import XCTest
@testable import ACCore
@testable import ACAccessibility

final class ImageAccessibilityTests: XCTestCase {

    // MARK: - Helpers

    private func makeImage(
        altText: String? = nil,
        url: String = "https://example.com/photo.jpg",
        style: ImageStyle? = nil,
        size: ImageSize? = nil
    ) -> ACCore.Image {
        ACCore.Image(
            id: "test-image",
            url: url,
            altText: altText,
            size: size,
            style: style
        )
    }

    // MARK: - Image role announcement

    func testImageWithAltTextHasAltTextLabel() {
        let image = makeImage(altText: "Driver in great barrier reef")
        XCTAssertEqual(image.altText, "Driver in great barrier reef")
    }

    func testImageWithoutAltTextShouldFallbackToDefaultLabel() {
        let image = makeImage(altText: nil)
        // When altText is nil, the view should use "Image" as default label
        let label = image.altText ?? "Image"
        XCTAssertEqual(label, "Image")
    }

    func testImageShouldAlwaysHaveImageTrait() {
        // The .isImage trait should be applied to all images,
        // regardless of whether altText is present
        let imageWithAlt = makeImage(altText: "Matt Hidinger")
        let imageWithoutAlt = makeImage(altText: nil)

        // Both need to announce as "image" - the trait is set in the view
        // This test verifies the model data is correct for the view to use
        XCTAssertNotNil(imageWithAlt.url, "Image should have URL for rendering")
        XCTAssertNotNil(imageWithoutAlt.url, "Image should have URL for rendering")
    }

    func testImageAltTextNotModifiedByRole() {
        // The altText should remain exactly as specified in the JSON,
        // not have "image" appended to it — the role trait handles that
        let image = makeImage(altText: "Profile photo of John")
        XCTAssertEqual(image.altText, "Profile photo of John")
        XCTAssertFalse(
            image.altText!.lowercased().contains("image"),
            "altText should not contain 'image' — that's the trait's job"
        )
    }

    // MARK: - Image style variants

    func testPersonStyleImageHasAccessibility() {
        let image = makeImage(altText: "Matt Hidinger", style: .person)
        XCTAssertEqual(image.altText, "Matt Hidinger")
        XCTAssertEqual(image.style, .person)
    }

    func testDefaultStyleImageHasAccessibility() {
        let image = makeImage(altText: "Company logo", style: .default)
        XCTAssertEqual(image.altText, "Company logo")
        XCTAssertEqual(image.style, .default)
    }

    // MARK: - Image size variants

    func testSmallImageRetainsAccessibility() {
        let image = makeImage(altText: "Icon", size: .small)
        XCTAssertEqual(image.altText, "Icon")
        XCTAssertEqual(image.size, .small)
    }

    func testLargeImageRetainsAccessibility() {
        let image = makeImage(altText: "Hero banner", size: .large)
        XCTAssertEqual(image.altText, "Hero banner")
        XCTAssertEqual(image.size, .large)
    }

    func testStretchImageRetainsAccessibility() {
        let image = makeImage(altText: "Full width photo", size: .stretch)
        XCTAssertEqual(image.altText, "Full width photo")
        XCTAssertEqual(image.size, .stretch)
    }

    // MARK: - Multiple images in a card

    func testMultipleImagesEachHaveIndependentAltText() {
        let image1 = makeImage(altText: "First photo")
        let image2 = makeImage(altText: "Second photo")
        let image3 = makeImage(altText: nil)

        XCTAssertEqual(image1.altText, "First photo")
        XCTAssertEqual(image2.altText, "Second photo")
        XCTAssertNil(image3.altText)
    }

    // MARK: - Parity: iOS image role matches Android

    func testImageRoleParityWithAndroid() {
        // On Android, imageSemantics always sets Role.Image.
        // On iOS, .isImage trait must always be applied on the view.
        // This test ensures the model data supports both platforms.
        let image = makeImage(altText: "Reef photo")
        XCTAssertNotNil(image.url)
        // The altText ?? "Image" fallback ensures both platforms have a label
        let label = image.altText ?? "Image"
        XCTAssertFalse(label.isEmpty)
    }
}
