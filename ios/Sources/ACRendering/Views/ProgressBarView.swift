import Foundation
import SwiftUI
import ACCore
import ACAccessibility

struct ProgressBarView: View {
    let progressBar: ProgressBar
    let hostConfig: HostConfig
    
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = progressBar.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
            
            ProgressView(value: clampedValue, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .frame(height: adaptiveHeight)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityDescription)
                .accessibilityValue("\(Int(clampedValue * 100)) percent")
                .accessibilityAddTraits(.updatesFrequently)
        }
        .spacing(progressBar.spacing, hostConfig: hostConfig)
        .separator(progressBar.separator, hostConfig: hostConfig)
    }
    
    private var clampedValue: Double {
        return min(max(progressBar.value, 0.0), 1.0)
    }
    
    private var adaptiveHeight: CGFloat {
        sizeCategory.isAccessibilityCategory ? 12 : 8
    }
    
    private var progressColor: Color {
        if let colorString = progressBar.color {
            // Try to parse hex color
            if colorString.hasPrefix("#") {
                return Color(hex: colorString) ?? .blue
            }
            // Try to parse named color
            switch colorString.lowercased() {
            case "blue": return .blue
            case "green": return .green
            case "red": return .red
            case "yellow": return .yellow
            case "orange": return .orange
            case "purple": return .purple
            default: return .blue
            }
        }
        return .blue
    }
    
    private var accessibilityDescription: String {
        if let label = progressBar.label {
            return "\(label) progress bar"
        }
        return "Progress bar"
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let length = hexSanitized.count
        let r, g, b, a: Double
        
        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            a = Double(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
