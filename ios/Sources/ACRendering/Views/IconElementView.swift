import SwiftUI
import ACCore

/// Renders a Fluent UI Icon element as an SF Symbol.
struct IconElementView: View {
    let icon: IconElement
    let hostConfig: HostConfig

    var body: some View {
        let symbol = sfSymbolName(for: icon.name)
        let size = iconSize(icon.size)
        let color = iconColor(icon.color)

        Image(systemName: symbol)
            .font(.system(size: size))
            .foregroundColor(color)
            .frame(
                maxWidth: icon.horizontalAlignment == nil ? nil : .infinity,
                alignment: alignment(icon.horizontalAlignment)
            )
    }

    private func iconSize(_ size: String?) -> CGFloat {
        switch size?.lowercased() {
        case "xxsmall": return 12
        case "xsmall": return 14
        case "small": return 16
        case "medium": return 20
        case "large": return 28
        case "xlarge": return 36
        case "xxlarge": return 48
        default: return 20
        }
    }

    private func iconColor(_ color: String?) -> Color {
        switch color?.lowercased() {
        case "accent": return Color(hex: hostConfig.containerStyles.default.foregroundColors.accent.default)
        case "good": return Color(hex: hostConfig.containerStyles.default.foregroundColors.good.default)
        case "warning": return Color(hex: hostConfig.containerStyles.default.foregroundColors.warning.default)
        case "attention": return Color(hex: hostConfig.containerStyles.default.foregroundColors.attention.default)
        case "light": return Color(hex: hostConfig.containerStyles.default.foregroundColors.light.default)
        case "dark": return Color(hex: hostConfig.containerStyles.default.foregroundColors.dark.default)
        default: return Color(hex: hostConfig.containerStyles.default.foregroundColors.default.default)
        }
    }

    private func alignment(_ value: String?) -> Alignment {
        switch value?.lowercased() {
        case "center": return .center
        case "right": return .trailing
        default: return .leading
        }
    }

    /// Maps Fluent UI icon names to SF Symbols.
    private func sfSymbolName(for fluentName: String) -> String {
        let map: [String: String] = [
            "calendar": "calendar",
            "clock": "clock",
            "accesstime": "clock",
            "people": "person.2",
            "person": "person",
            "mail": "envelope",
            "comment": "bubble.left",
            "chat": "bubble.left",
            "call": "phone",
            "video": "video",
            "location": "mappin.and.ellipse",
            "link": "link",
            "attach": "paperclip",
            "image": "photo",
            "document": "doc",
            "folder": "folder",
            "star": "star",
            "heart": "heart",
            "flag": "flag",
            "bookmark": "bookmark",
            "checkmark": "checkmark",
            "checkmarkcircle": "checkmark.circle",
            "alert": "exclamationmark.triangle",
            "info": "info.circle",
            "settings": "gearshape",
            "search": "magnifyingglass",
            "add": "plus.circle",
            "edit": "pencil",
            "delete": "trash",
            "share": "square.and.arrow.up",
            "download": "arrow.down.circle",
            "upload": "arrow.up.circle",
            "refresh": "arrow.clockwise",
            "arrowsync": "arrow.clockwise",
            "home": "house",
            "list": "list.bullet",
            "grid": "square.grid.2x2",
            "notification": "bell",
            "lock": "lock",
            "unlock": "lock.open",
            "eye": "eye",
            "gift": "gift",
            "airplane": "airplane",
            "beach": "sun.max",
            "crown": "crown",
            "bug": "ladybug",
            "branch": "arrow.triangle.branch",
            "arrowcircleright": "arrow.right.circle",
            "arrowexport": "arrow.up.forward.square",
            "chevrondown": "chevron.down",
            "chevronup": "chevron.up",
            "chevronleft": "chevron.left",
            "chevronright": "chevron.right",
            "circle": "circle",
            "circlesmall": "circle.fill",
            "dismiss": "xmark",
            "open": "arrow.up.forward.square",
            "save": "square.and.arrow.down",
            "copy": "doc.on.doc",
            "more": "ellipsis",
            "morehorizontal": "ellipsis",
            "morevertical": "ellipsis",
            "warning": "exclamationmark.triangle",
            "error": "xmark.circle",
            "success": "checkmark.circle",
            "thumblike": "hand.thumbsup",
            "thumbdislike": "hand.thumbsdown",
            "send": "paperplane",
            "microphone": "mic",
            "camera": "camera",
            "play": "play",
            "pause": "pause",
            "stop": "stop",
            "speaker": "speaker.wave.2",
            "wifi": "wifi",
            "bluetooth": "wave.3.right",
            "battery": "battery.100",
            "flash": "bolt",
            "map": "map",
            "navigation": "location.north",
            "compass": "safari",
            "filter": "line.3.horizontal.decrease",
            "sort": "arrow.up.arrow.down",
            "tag": "tag",
            "key": "key",
            "shield": "shield",
            "lightbulb": "lightbulb",
            "code": "chevron.left.forwardslash.chevron.right",
            "terminal": "terminal",
            "database": "cylinder",
            "cloud": "cloud",
            "server": "server.rack",
        ]

        let lowered = fluentName.lowercased()
        return map[lowered] ?? "questionmark.square"
    }
}
