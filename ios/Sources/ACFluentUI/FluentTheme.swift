import SwiftUI

public struct FluentTheme: Equatable {
    public var colors: FluentColorTokens
    public var typography: FluentTypography
    public var spacing: FluentSpacing
    public var cornerRadii: FluentCornerRadii

    public init(
        colors: FluentColorTokens = FluentColorTokens(),
        typography: FluentTypography = FluentTypography(),
        spacing: FluentSpacing = FluentSpacing(),
        cornerRadii: FluentCornerRadii = FluentCornerRadii()
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.cornerRadii = cornerRadii
    }

    public static let `default` = FluentTheme()
}

struct FluentThemeKey: EnvironmentKey {
    static let defaultValue: FluentTheme = .default
}

extension EnvironmentValues {
    public var fluentTheme: FluentTheme {
        get { self[FluentThemeKey.self] }
        set { self[FluentThemeKey.self] = newValue }
    }
}

extension View {
    public func fluentTheme(_ theme: FluentTheme) -> some View {
        environment(\.fluentTheme, theme)
    }
}
