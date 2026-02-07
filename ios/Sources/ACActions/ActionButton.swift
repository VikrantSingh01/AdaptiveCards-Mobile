import SwiftUI
import ACCore
import ACAccessibility

public struct ActionButton: View {
    let action: CardAction
    let hostConfig: HostConfig
    let onTap: () -> Void
    
    public init(
        action: CardAction,
        hostConfig: HostConfig,
        onTap: @escaping () -> Void
    ) {
        self.action = action
        self.hostConfig = hostConfig
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                if let iconUrl = iconUrl {
                    AsyncImage(url: URL(string: iconUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                    } placeholder: {
                        EmptyView()
                    }
                }
                
                if let title = title {
                    Text(title)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(4)
        }
        .disabled(!(isEnabled ?? true))
        .accessibilityAction(label: title, hint: tooltip)
    }
    
    private var title: String? {
        switch action {
        case .submit(let a): return a.title
        case .openUrl(let a): return a.title
        case .showCard(let a): return a.title
        case .execute(let a): return a.title
        case .toggleVisibility(let a): return a.title
        }
    }
    
    private var iconUrl: String? {
        switch action {
        case .submit(let a): return a.iconUrl
        case .openUrl(let a): return a.iconUrl
        case .showCard(let a): return a.iconUrl
        case .execute(let a): return a.iconUrl
        case .toggleVisibility(let a): return a.iconUrl
        }
    }
    
    private var style: ActionStyle? {
        switch action {
        case .submit(let a): return a.style
        case .openUrl(let a): return a.style
        case .showCard(let a): return a.style
        case .execute(let a): return a.style
        case .toggleVisibility(let a): return a.style
        }
    }
    
    private var tooltip: String? {
        switch action {
        case .submit(let a): return a.tooltip
        case .openUrl(let a): return a.tooltip
        case .showCard(let a): return a.tooltip
        case .execute(let a): return a.tooltip
        case .toggleVisibility(let a): return a.tooltip
        }
    }
    
    private var isEnabled: Bool? {
        switch action {
        case .submit(let a): return a.isEnabled
        case .openUrl(let a): return a.isEnabled
        case .showCard(let a): return a.isEnabled
        case .execute(let a): return a.isEnabled
        case .toggleVisibility(let a): return a.isEnabled
        }
    }
    
    private var backgroundColor: Color {
        let actionStyle = style ?? .default
        
        switch actionStyle {
        case .default:
            return Color.blue
        case .positive:
            return Color.green
        case .destructive:
            return Color.red
        }
    }
    
    private var foregroundColor: Color {
        return .white
    }
}
