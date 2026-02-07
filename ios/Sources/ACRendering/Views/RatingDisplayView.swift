import SwiftUI
import ACCore
import ACAccessibility

struct RatingDisplayView: View {
    let rating: RatingDisplay
    let hostConfig: HostConfig
    
    var body: some View {
        HStack(spacing: 4) {
            // Star icons
            HStack(spacing: 2) {
                ForEach(0..<maxStars, id: \.self) { index in
                    starImage(for: index)
                        .foregroundColor(.yellow)
                        .font(starSize)
                }
            }
            
            // Value text
            Text(String(format: "%.1f", rating.value))
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Count if provided
            if let count = rating.count {
                Text("(\(count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .spacing(rating.spacing, hostConfig: hostConfig)
        .separator(rating.separator, hostConfig: hostConfig)
    }
    
    private var maxStars: Int {
        return rating.max ?? 5
    }
    
    private var starSize: Font {
        switch rating.size {
        case .small:
            return .caption
        case .large:
            return .title3
        default:
            return .body
        }
    }
    
    private func starImage(for index: Int) -> Image {
        let starValue = Double(index + 1)
        
        if rating.value >= starValue {
            return Image(systemName: "star.fill")
        } else if rating.value >= starValue - 0.5 {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }
}
