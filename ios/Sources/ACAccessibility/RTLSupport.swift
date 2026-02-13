import SwiftUI
import ACCore

// MARK: - RTL Support

public extension View {
    /// Ensures proper mirroring for RTL languages
    func adaptiveRTL() -> some View {
        self.modifier(RTLSupportModifier())
    }
    
    /// Conditionally flips horizontal alignment for RTL
    func mirrorForRTL() -> some View {
        self.modifier(MirrorForRTLModifier())
    }
}

private struct RTLSupportModifier: ViewModifier {
    @Environment(\.layoutDirection) var layoutDirection
    
    func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, layoutDirection)
    }
}

private struct MirrorForRTLModifier: ViewModifier {
    @Environment(\.layoutDirection) var layoutDirection
    
    func body(content: Content) -> some View {
        if layoutDirection == .rightToLeft {
            content.scaleEffect(x: -1, y: 1)
        } else {
            content
        }
    }
}

// MARK: - Alignment Helpers

public extension SwiftUI.HorizontalAlignment {
    /// Converts Adaptive Card HorizontalAlignment to SwiftUI alignment, respecting RTL
    static func from(_ alignment: ACCore.HorizontalAlignment?, layoutDirection: LayoutDirection) -> SwiftUI.HorizontalAlignment {
        guard let alignment = alignment else { return .leading }

        switch alignment {
        case .left:
            return layoutDirection == .leftToRight ? .leading : .trailing
        case .center:
            return .center
        case .right:
            return layoutDirection == .leftToRight ? .trailing : .leading
        }
    }
}

public extension Alignment {
    /// Converts Adaptive Card alignments to SwiftUI Alignment
    static func from(
        horizontal: ACCore.HorizontalAlignment?,
        vertical: ACCore.VerticalAlignment?,
        layoutDirection: LayoutDirection
    ) -> Alignment {
        let h = SwiftUI.HorizontalAlignment.from(horizontal, layoutDirection: layoutDirection)
        let v = verticalAlignment(from: vertical)

        return Alignment(horizontal: h, vertical: v)
    }
    
    private static func verticalAlignment(from alignment: ACCore.VerticalAlignment?) -> SwiftUI.VerticalAlignment {
        guard let alignment = alignment else { return .center }

        switch alignment {
        case .top:
            return .top
        case .center:
            return .center
        case .bottom:
            return .bottom
        }
    }
}

// MARK: - Text Alignment

public extension TextAlignment {
    /// Converts Adaptive Card HorizontalAlignment to SwiftUI TextAlignment
    static func from(_ alignment: ACCore.HorizontalAlignment?) -> TextAlignment {
        guard let alignment = alignment else { return .leading }
        
        switch alignment {
        case .left:
            return .leading
        case .center:
            return .center
        case .right:
            return .trailing
        }
    }
}
