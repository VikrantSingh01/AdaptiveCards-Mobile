import SwiftUI
import ACCore

public extension View {
    /// Wraps element in a tap gesture for selectAction
    func selectAction(_ action: CardAction?, onTap: @escaping (CardAction) -> Void) -> some View {
        self.modifier(SelectActionModifier(action: action, onTap: onTap))
    }
}

struct SelectActionModifier: ViewModifier {
    let action: CardAction?
    let onTap: (CardAction) -> Void

    func body(content: Content) -> some View {
        if let action = action {
            content
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap(action)
                }
        } else {
            content
        }
    }
}
