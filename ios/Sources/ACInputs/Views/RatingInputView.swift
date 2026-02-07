import SwiftUI
import ACCore
import ACAccessibility

public struct RatingInputView: View {
    let input: RatingInput
    let hostConfig: HostConfig
    @Binding var value: Double
    let validationState: ValidationState?
    
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
            }
            
            HStack(spacing: 8) {
                ForEach(1...maxStars, id: \.self) { starIndex in
                    Button(action: {
                        value = Double(starIndex)
                    }) {
                        starImage(for: starIndex)
                            .foregroundColor(starIndex <= Int(value.rounded(.up)) ? .yellow : .gray)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if let error = validationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .spacing(input.spacing, hostConfig: hostConfig)
        .separator(input.separator, hostConfig: hostConfig)
    }
    
    private var maxStars: Int {
        return input.max ?? 5
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
