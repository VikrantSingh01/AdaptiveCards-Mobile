import SwiftUI
import UIKit
import ACCore

public struct RatingInputView: View {
    let input: RatingInput
    let hostConfig: HostConfig
    
    @Binding var value: Double
    @State private var showError = false
    
    let validationState: ValidationState?
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }
    
    private var starSize: CGFloat {
        isTablet ? 40 : 32
    }
    
    private var padding: CGFloat {
        isTablet ? 4 : 2
    }
    
    private var labelFont: Font {
        isTablet ? .body : .subheadline
    }
    
    private var maxStars: Int {
        input.max ?? 5
    }
    
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
                HStack {
                    Text(label)
                        .font(labelFont)
                        .foregroundColor(.primary)
                    
                    if input.isRequired == true {
                        Text("*")
                            .foregroundColor(.red)
                    }
                }
            }
            
            HStack(spacing: padding) {
                ForEach(1...maxStars, id: \.self) { index in
                    starButton(for: index)
                }
            }
            
            if showError, let errorMessage = input.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(input.label ?? "Rating input")
        .accessibilityValue("\(Int(value)) out of \(maxStars) stars selected")
        .accessibilityHint("Tap a star to rate from 1 to \(maxStars)")
        .onChange(of: validationState?.validationErrors ?? []) { errors in
            showError = errors.contains { $0.inputId == input.id }
        }
    }
    
    private func starButton(for index: Int) -> some View {
        Button(action: {
            value = Double(index)
            // Announce selection to VoiceOver
            UIAccessibility.post(notification: .announcement, argument: "\(index) star\(index == 1 ? "" : "s") selected")
        }) {
            Image(systemName: value >= Double(index) ? "star.fill" : "star")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: starSize, height: starSize)
                .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                .padding(padding)
        }
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityLabel("Star \(index)")
        .accessibilityValue(value >= Double(index) ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to rate \(index) stars")
        .accessibilityAddTraits(.isButton)
    }
}
