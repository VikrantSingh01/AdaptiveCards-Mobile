import XCTest
import SwiftUI
@testable import ACRendering
@testable import ACCore

final class RegistryTests: XCTestCase {

    func testElementRendererRegistration() {
        let registry = ElementRendererRegistry.shared
        registry.clearAll()

        // Verify no custom renderer exists initially
        XCTAssertFalse(registry.hasRenderer(for: "CustomType"))

        // Register a custom renderer
        registry.register("CustomType") { element in
            Text("Custom Element")
        }

        // Verify renderer is registered
        XCTAssertTrue(registry.hasRenderer(for: "CustomType"))

        // Clean up
        registry.clearAll()
    }

    func testActionRendererRegistration() {
        let registry = ActionRendererRegistry.shared
        registry.clearAll()

        // Verify no custom renderer exists initially
        XCTAssertFalse(registry.hasRenderer(for: "CustomAction"))

        // Register a custom renderer
        registry.register("CustomAction") { action in
            Text("Custom Action")
        }

        // Verify renderer is registered
        XCTAssertTrue(registry.hasRenderer(for: "CustomAction"))

        // Clean up
        registry.clearAll()
    }
}
