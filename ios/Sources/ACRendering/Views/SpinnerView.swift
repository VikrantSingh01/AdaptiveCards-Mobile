import SwiftUI
import ACCore
import ACAccessibility

struct SpinnerView: View {
    let spinner: Spinner
    let hostConfig: HostConfig
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(spinnerScale)
            
            if let label = spinner.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .spacing(spinner.spacing, hostConfig: hostConfig)
        .separator(spinner.separator, hostConfig: hostConfig)
    }
    
    private var spinnerScale: CGFloat {
        switch spinner.size {
        case .small:
            return 0.8
        case .large:
            return 1.5
        default:
            return 1.0
        }
    }
}
