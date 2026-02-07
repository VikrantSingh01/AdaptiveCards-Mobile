import SwiftUI

public struct ChartColors {
    public static let defaultPalette: [Color] = [
        Color(hex: "#0078D4"), // Blue
        Color(hex: "#00BCF2"), // Cyan
        Color(hex: "#8764B8"), // Purple
        Color(hex: "#00B7C3"), // Teal
        Color(hex: "#FFB900"), // Yellow
        Color(hex: "#D83B01"), // Orange
        Color(hex: "#E74856"), // Red
        Color(hex: "#00CC6A")  // Green
    ]
    
    public static func colors(from hexColors: [String]?) -> [Color] {
        if let hexColors = hexColors, !hexColors.isEmpty {
            return hexColors.map { Color(hex: $0) }
        }
        return defaultPalette
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

public enum ChartSize {
    case small
    case medium
    case large
    case auto
    
    public var height: CGFloat {
        switch self {
        case .small: return 150
        case .medium: return 250
        case .large: return 350
        case .auto: return 250
        }
    }
    
    public static func from(_ string: String?) -> ChartSize {
        guard let string = string else { return .auto }
        switch string.lowercased() {
        case "small": return .small
        case "medium": return .medium
        case "large": return .large
        default: return .auto
        }
    }
}
