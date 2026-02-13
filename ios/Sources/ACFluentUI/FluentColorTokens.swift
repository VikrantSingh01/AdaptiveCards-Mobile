import SwiftUI

public struct FluentColorTokens: Equatable {
    // Brand colors
    public var brand: Color
    public var brandBackground: Color
    public var brandForeground: Color
    
    // Surface colors (light mode defaults)
    public var surface: Color
    public var surfaceSecondary: Color
    public var surfaceTertiary: Color
    
    // Text colors
    public var foreground: Color
    public var foregroundSecondary: Color
    public var foregroundDisabled: Color
    
    // Border colors
    public var stroke: Color
    public var strokeSecondary: Color
    
    // Semantic colors
    public var success: Color
    public var warning: Color
    public var danger: Color
    public var info: Color
    
    // Dark mode variants
    public var darkModeSurface: Color
    public var darkModeSurfaceSecondary: Color
    public var darkModeForeground: Color
    
    public init(
        brand: Color = Color(hex: "#6264A7"),
        brandBackground: Color = Color(hex: "#464775"),
        brandForeground: Color = .white,
        surface: Color = .white,
        surfaceSecondary: Color = Color(hex: "#F5F5F5"),
        surfaceTertiary: Color = Color(hex: "#E8E8E8"),
        foreground: Color = Color(hex: "#242424"),
        foregroundSecondary: Color = Color(hex: "#616161"),
        foregroundDisabled: Color = Color(hex: "#C7C7C7"),
        stroke: Color = Color(hex: "#D1D1D1"),
        strokeSecondary: Color = Color(hex: "#E0E0E0"),
        success: Color = Color(hex: "#13A10E"),
        warning: Color = Color(hex: "#FFC83D"),
        danger: Color = Color(hex: "#D13438"),
        info: Color = Color(hex: "#0078D4"),
        darkModeSurface: Color = Color(hex: "#292929"),
        darkModeSurfaceSecondary: Color = Color(hex: "#1F1F1F"),
        darkModeForeground: Color = Color(hex: "#FFFFFF")
    ) {
        self.brand = brand
        self.brandBackground = brandBackground
        self.brandForeground = brandForeground
        self.surface = surface
        self.surfaceSecondary = surfaceSecondary
        self.surfaceTertiary = surfaceTertiary
        self.foreground = foreground
        self.foregroundSecondary = foregroundSecondary
        self.foregroundDisabled = foregroundDisabled
        self.stroke = stroke
        self.strokeSecondary = strokeSecondary
        self.success = success
        self.warning = warning
        self.danger = danger
        self.info = info
        self.darkModeSurface = darkModeSurface
        self.darkModeSurfaceSecondary = darkModeSurfaceSecondary
        self.darkModeForeground = darkModeForeground
    }
}

extension Color {
    public init(hex: String) {
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
