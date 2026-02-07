import SwiftUI

public struct FluentTypography: Equatable {
    // Caption sizes
    public var caption2: FluentFont
    public var caption1: FluentFont
    
    // Body sizes
    public var body1: FluentFont
    public var body2: FluentFont
    
    // Subtitle sizes
    public var subtitle2: FluentFont
    public var subtitle1: FluentFont
    
    // Title sizes
    public var title3: FluentFont
    public var title2: FluentFont
    public var title1: FluentFont
    
    // Display sizes
    public var largeTitle: FluentFont
    public var display: FluentFont
    
    public init(
        caption2: FluentFont = FluentFont(size: 10, weight: .regular, lineHeight: 12),
        caption1: FluentFont = FluentFont(size: 12, weight: .regular, lineHeight: 16),
        body1: FluentFont = FluentFont(size: 14, weight: .regular, lineHeight: 20),
        body2: FluentFont = FluentFont(size: 14, weight: .semibold, lineHeight: 20),
        subtitle2: FluentFont = FluentFont(size: 16, weight: .regular, lineHeight: 22),
        subtitle1: FluentFont = FluentFont(size: 16, weight: .semibold, lineHeight: 22),
        title3: FluentFont = FluentFont(size: 20, weight: .semibold, lineHeight: 26),
        title2: FluentFont = FluentFont(size: 24, weight: .semibold, lineHeight: 32),
        title1: FluentFont = FluentFont(size: 28, weight: .semibold, lineHeight: 36),
        largeTitle: FluentFont = FluentFont(size: 32, weight: .semibold, lineHeight: 40),
        display: FluentFont = FluentFont(size: 40, weight: .semibold, lineHeight: 52)
    ) {
        self.caption2 = caption2
        self.caption1 = caption1
        self.body1 = body1
        self.body2 = body2
        self.subtitle2 = subtitle2
        self.subtitle1 = subtitle1
        self.title3 = title3
        self.title2 = title2
        self.title1 = title1
        self.largeTitle = largeTitle
        self.display = display
    }
}

public struct FluentFont: Equatable {
    public var size: CGFloat
    public var weight: Font.Weight
    public var lineHeight: CGFloat
    
    public init(size: CGFloat, weight: Font.Weight, lineHeight: CGFloat) {
        self.size = size
        self.weight = weight
        self.lineHeight = lineHeight
    }
    
    public var font: Font {
        .system(size: size, weight: weight)
    }
}
