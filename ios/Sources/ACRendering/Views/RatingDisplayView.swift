import SwiftUI
import ACCore
import ACAccessibility

struct RatingDisplayView: View {
    let rating: RatingDisplay
    let hostConfig: HostConfig

    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        HStack(spacing: 4) {
            // Star icons
            HStack(spacing: 2) {
                ForEach(0..<maxStars, id: \.self) { index in
                    starImage(for: index)
                        .foregroundColor(.yellow)
                        .font(starSize)
                        .accessibilityHidden(true)
                }
            }

            // Value text
            Text(String(format: "%.1f", rating.value))
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            // Count if provided
            if let count = rating.count {
                Text("(\(count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
        }
        .spacing(rating.spacing, hostConfig: hostConfig)
        .separator(rating.separator, hostConfig: hostConfig)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isStaticText)
    }

    private var maxStars: Int {
        return rating.max ?? 5
    }

    private var starSize: Font {
        let baseSize: Font
        switch rating.size {
        case .small:
            baseSize = .caption
        case .large:
            baseSize = .title3
        default:
            baseSize = .body
        }

        // Scale for accessibility
        if sizeCategory.isAccessibilityCategory {
            return .title3
        }
        return baseSize
    }

    private func starImage(for index: Int) -> SwiftUI.Image {
        let starValue = Double(index + 1)

        if rating.value >= starValue {
            return SwiftUI.Image(systemName: "star.fill")
        } else if rating.value >= starValue - 0.5 {
            return SwiftUI.Image(systemName: "star.leadinghalf.filled")
        } else {
            return SwiftUI.Image(systemName: "star")
        }
    }

    private var accessibilityDescription: String {
        var description = "Rating: \(String(format: "%.1f", rating.value)) out of \(maxStars) stars"
        if let count = rating.count {
            description += ", based on \(count) reviews"
        }
        return description
    }
}
