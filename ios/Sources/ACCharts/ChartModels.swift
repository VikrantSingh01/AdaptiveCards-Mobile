import SwiftUI
import ACFluentUI

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
