import SwiftUI

public struct FluentSpacing: Equatable {
    public var xxs: CGFloat
    public var xs: CGFloat
    public var s: CGFloat
    public var sPlus: CGFloat
    public var m: CGFloat
    public var mPlus: CGFloat
    public var l: CGFloat
    public var xl: CGFloat
    public var xxl: CGFloat
    public var xxxl: CGFloat
    
    public init(
        xxs: CGFloat = 2,
        xs: CGFloat = 4,
        s: CGFloat = 8,
        sPlus: CGFloat = 12,
        m: CGFloat = 16,
        mPlus: CGFloat = 20,
        l: CGFloat = 24,
        xl: CGFloat = 32,
        xxl: CGFloat = 40,
        xxxl: CGFloat = 48
    ) {
        self.xxs = xxs
        self.xs = xs
        self.s = s
        self.sPlus = sPlus
        self.m = m
        self.mPlus = mPlus
        self.l = l
        self.xl = xl
        self.xxl = xxl
        self.xxxl = xxxl
    }
}
