import SwiftUI
import ACCore

/// Registry for custom element renderers with thread-safe access
public class ElementRendererRegistry {
    public static let shared = ElementRendererRegistry()

    private var renderers: [String: (CardElement) -> AnyView] = [:]
    private let lock = NSLock()

    private init() {}

    /// Registers a custom renderer for an element type
    public func register<V: View>(
        _ type: String,
        renderer: @escaping (CardElement) -> V
    ) {
        lock.lock()
        defer { lock.unlock() }
        renderers[type] = { element in
            AnyView(renderer(element))
        }
    }

    /// Gets a custom renderer for an element type
    public func getRenderer(for type: String) -> ((CardElement) -> AnyView)? {
        lock.lock()
        defer { lock.unlock() }
        return renderers[type]
    }

    /// Checks if a custom renderer exists for an element type
    public func hasRenderer(for type: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return renderers[type] != nil
    }

    /// Clears all custom renderers
    public func clearAll() {
        lock.lock()
        defer { lock.unlock() }
        renderers.removeAll()
    }
}
