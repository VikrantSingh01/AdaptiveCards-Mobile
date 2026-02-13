import SwiftUI

public struct FluentCornerRadii: Equatable {
    public var none: CGFloat
    public var small: CGFloat
    public var medium: CGFloat
    public var large: CGFloat
    public var xLarge: CGFloat
    public var circular: CGFloat

    public init(
        none: CGFloat = 0,
        small: CGFloat = 2,
        medium: CGFloat = 4,
        large: CGFloat = 8,
        xLarge: CGFloat = 12,
        circular: CGFloat = 9999
    ) {
        self.none = none
        self.small = small
        self.medium = medium
        self.large = large
        self.xLarge = xLarge
        self.circular = circular
    }
}
