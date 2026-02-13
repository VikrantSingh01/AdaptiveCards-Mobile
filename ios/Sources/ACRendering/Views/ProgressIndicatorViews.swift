import SwiftUI
import ACCore
import ACFluentUI

// MARK: - Progress Bar View

struct ProgressBarView: View {
    let progressBar: ProgressBar
    let hostConfig: HostConfig
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }
    
    private var barHeight: CGFloat {
        isTablet ? 10 : 8
    }
    
    private var labelFont: Font {
        isTablet ? .body : .subheadline
    }
    
    private var progressColor: Color {
        if let colorString = progressBar.color {
            return Color(hex: colorString)
        }
        return .accentColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label = progressBar.label {
                HStack {
                    Text(label)
                        .font(labelFont)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(progressBar.value * 100))%")
                        .font(labelFont)
                        .foregroundColor(.secondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: barHeight)
                    
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * CGFloat(min(max(progressBar.value, 0), 1)), height: barHeight)
                }
            }
            .frame(height: barHeight)
            .cornerRadius(barHeight / 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(progressBar.label ?? "Progress")
        .accessibilityValue("\(Int(progressBar.value * 100)) percent")
    }
}

// MARK: - Spinner View

struct SpinnerView: View {
    let spinner: Spinner
    let hostConfig: HostConfig
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }
    
    private var spinnerSize: CGFloat {
        let baseSize: CGFloat
        switch spinner.size {
        case .small:
            baseSize = 24
        case .large:
            baseSize = 56
        default:
            baseSize = 40
        }
        return isTablet ? baseSize + 8 : baseSize
    }
    
    private var labelFont: Font {
        isTablet ? .body : .subheadline
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(spinnerSize / 20)
                .frame(width: spinnerSize, height: spinnerSize)
            
            if let label = spinner.label {
                Text(label)
                    .font(labelFont)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spinner.label ?? "Loading")
        .accessibilityValue("In progress")
    }
}
