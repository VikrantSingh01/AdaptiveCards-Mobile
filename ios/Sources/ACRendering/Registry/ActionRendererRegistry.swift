import SwiftUI
import ACCore

/// Registry for custom action renderers
public class ActionRendererRegistry {
    public static let shared = ActionRendererRegistry()

    private var renderers: [String: (CardAction) -> AnyView] = [:]

    private init() {}

    /// Registers a custom renderer for an action type
    public func register<V: View>(
        _ type: String,
        renderer: @escaping (CardAction) -> V
    ) {
        renderers[type] = { action in
            AnyView(renderer(action))
        }
    }

    /// Gets a custom renderer for an action type
    public func getRenderer(for type: String) -> ((CardAction) -> AnyView)? {
        return renderers[type]
    }

    /// Checks if a custom renderer exists for an action type
    public func hasRenderer(for type: String) -> Bool {
        return renderers[type] != nil
    }

    /// Clears all custom renderers
    public func clearAll() {
        renderers.removeAll()
    }
}
