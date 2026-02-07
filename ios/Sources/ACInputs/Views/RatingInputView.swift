import SwiftUI
import ACCore
import ACAccessibility

public struct RatingInputView: View {
    let input: RatingInput
    let hostConfig: HostConfig
    @Binding var value: Double
    let validationState: ValidationState?
    
    @Environment(\.sizeCategory) var sizeCategory
    
    public init(
        input: RatingInput,
        hostConfig: HostConfig,
        value: Binding<Double>,
        validationState: ValidationState?
    ) {
        self.input = input
        self.hostConfig = hostConfig
        self._value = value
        self.validationState = validationState
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label = input.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
            
            HStack(spacing: adaptiveSpacing) {
                ForEach(1...maxStars, id: \.self) { starIndex in
                    Button(action: {
                        value = Double(starIndex)
                        UIAccessibility.post(notification: .announcement, argument: "\(starIndex) stars selected")
                    }) {
                        starImage(for: starIndex)
                            .foregroundColor(starIndex <= Int(value.rounded(.up)) ? .yellow : .gray)
                            .font(adaptiveStarSize)
                    }
                    .buttonStyle(.plain)
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(starIndex) star\(starIndex == 1 ? "" : "s")")
                    .accessibilityHint(starIndex <= Int(value.rounded(.up)) ? "Selected" : "Not selected. Double tap to select")
                    .accessibilityAddTraits(.isButton)
                }
            }
            
            if let error = validationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .accessibilityAddTraits(.isStaticText)
            }
        }
        .spacing(input.spacing, hostConfig: hostConfig)
        .separator(input.separator, hostConfig: hostConfig)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(input.label ?? "Rating input")
        .accessibilityValue("\(Int(value.rounded(.up))) out of \(maxStars) stars selected")
    }
    
    private var maxStars: Int {
        return input.max ?? 5
    }
    
    private var adaptiveSpacing: CGFloat {
        sizeCategory.isAccessibilityCategory ? 16 : 8
    }
    
    private var adaptiveStarSize: Font {
        if sizeCategory.isAccessibilityCategory {
            return .title
        } else {
            return .title2
        }
    }
    
    private func starImage(for index: Int) -> Image {
        let starValue = Double(index)
        
        if value >= starValue {
            return Image(systemName: "star.fill")
        } else if value >= starValue - 0.5 {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }
    
    private var validationError: String? {
        guard let state = validationState else { return nil }
        
        if input.isRequired == true, value == 0 {
            return input.errorMessage ?? "Rating is required"
        }
        
        return nil
    }
}
