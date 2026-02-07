import SwiftUI

public struct TeamsFluentTheme {
    public let colorScheme: ColorScheme
    public let primaryColor: Color
    public let backgroundColor: Color
    public let surfaceColor: Color
    public let textColor: Color
    
    public init(teamsTheme: TeamsTheme) {
        switch teamsTheme {
        case .light:
            self.colorScheme = .light
            self.primaryColor = Color(red: 0.38, green: 0.47, blue: 0.91)
            self.backgroundColor = .white
            self.surfaceColor = Color(white: 0.98)
            self.textColor = .black
        case .dark:
            self.colorScheme = .dark
            self.primaryColor = Color(red: 0.52, green: 0.60, blue: 0.95)
            self.backgroundColor = Color(white: 0.12)
            self.surfaceColor = Color(white: 0.18)
            self.textColor = .white
        case .highContrast:
            self.colorScheme = .dark
            self.primaryColor = .yellow
            self.backgroundColor = .black
            self.surfaceColor = Color(white: 0.05)
            self.textColor = .white
        }
    }
    
    public func apply() -> some View {
        Color.clear
            .preferredColorScheme(colorScheme)
    }
}
