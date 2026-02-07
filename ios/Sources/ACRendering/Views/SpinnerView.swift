import SwiftUI
import ACCore
import ACAccessibility

struct SpinnerView: View {
    let spinner: Spinner
    let hostConfig: HostConfig
    
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(spinnerScale)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityDescription)
                .accessibilityAddTraits(.updatesFrequently)
            
            if let label = spinner.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(adaptivePadding)
        .spacing(spinner.spacing, hostConfig: hostConfig)
        .separator(spinner.separator, hostConfig: hostConfig)
    }
    
    private var spinnerScale: CGFloat {
        let baseScale: CGFloat
        switch spinner.size {
        case .small:
            baseScale = 0.8
        case .large:
            baseScale = 1.5
        default:
            baseScale = 1.0
        }
        
        // Adjust for accessibility
        if sizeCategory.isAccessibilityCategory {
            return baseScale * 1.2
        }
        return baseScale
    }
    
    private var adaptivePadding: CGFloat {
        sizeCategory.isAccessibilityCategory ? 16 : 8
    }
    
    private var accessibilityDescription: String {
        if let label = spinner.label {
            return "Loading. \(label)"
        }
        return "Loading"
    }
}
