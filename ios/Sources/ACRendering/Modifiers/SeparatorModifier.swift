import SwiftUI
import ACCore

public extension View {
    /// Adds a separator line if separator property is true
    func separator(_ separator: Bool?, hostConfig: HostConfig) -> some View {
        self.modifier(SeparatorModifier(separator: separator, hostConfig: hostConfig))
    }
}

struct SeparatorModifier: ViewModifier {
    let separator: Bool?
    let hostConfig: HostConfig
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if separator == true {
                separatorLine
            }
            content
        }
    }
    
    private var separatorLine: some View {
        let color = Color(hex: hostConfig.separator.lineColor)
        return Rectangle()
            .fill(color)
            .frame(height: CGFloat(hostConfig.separator.lineThickness))
    }
}

