import SwiftUI
import ACCore

/// Registry for custom element renderers
public class ElementRendererRegistry {
    public static let shared = ElementRendererRegistry()
    
    private var renderers: [String: (CardElement) -> AnyView] = [:]
    
    private init() {}
    
    /// Registers a custom renderer for an element type
    public func register<V: View>(
        _ type: String,
        renderer: @escaping (CardElement) -> V
    ) {
        renderers[type] = { element in
            AnyView(renderer(element))
        }
    }
    
    /// Gets a custom renderer for an element type
    public func getRenderer(for type: String) -> ((CardElement) -> AnyView)? {
        return renderers[type]
    }
    
    /// Checks if a custom renderer exists for an element type
    public func hasRenderer(for type: String) -> Bool {
        return renderers[type] != nil
    }
    
    /// Clears all custom renderers
    public func clearAll() {
        renderers.removeAll()
    }
}
