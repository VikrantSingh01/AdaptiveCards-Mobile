import SwiftUI
import ACCore

struct RatingDisplayView: View {
    let rating: RatingDisplay
    let hostConfig: HostConfig
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }
    
    private var starSize: CGFloat {
        let baseSize: CGFloat
        switch rating.size {
        case .small:
            baseSize = 16
        case .large:
            baseSize = 32
        default:
            baseSize = 24
        }
        return isTablet ? baseSize + 4 : baseSize
    }
    
    private var maxStars: Int {
        rating.max ?? 5
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxStars, id: \.self) { index in
                starImage(for: index)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: starSize, height: starSize)
                    .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
            }
            
            if let count = rating.count {
                Text("(\(count))")
                    .font(isTablet ? .body : .caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rating")
        .accessibilityValue(ratingDescription)
    }
    
    private func starImage(for index: Int) -> Image {
        let position = Double(index) + 1.0
        if rating.value >= position {
            return Image(systemName: "star.fill")
        } else if rating.value > Double(index) {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }
    
    private var ratingDescription: String {
        var description = "\(rating.value) out of \(maxStars) stars"
        if let count = rating.count {
            description += ", \(count) reviews"
        }
        return description
    }
}
