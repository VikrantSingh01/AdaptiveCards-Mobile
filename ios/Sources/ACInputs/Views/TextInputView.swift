import SwiftUI
import ACCore
import ACAccessibility

public struct TextInputView: View {
    let input: TextInput
    let hostConfig: HostConfig
    @Binding var value: String
    @ObservedObject var validationState: ValidationState
    @Environment(\.layoutDirection) var layoutDirection
    
    public init(
        input: TextInput,
        hostConfig: HostConfig,
        value: Binding<String>,
        validationState: ValidationState
    ) {
        self.input = input
        self.hostConfig = hostConfig
        self._value = value
        self.validationState = validationState
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = input.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if input.isMultiline == true {
                TextEditor(text: $value)
                    .frame(minHeight: 80)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(borderColor, lineWidth: 1)
                    )
                    .onChange(of: value) { _ in
                        validateIfNeeded()
                    }
            } else {
                TextField(input.placeholder ?? "", text: $value)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .autocapitalization(autocapitalization)
                    .onChange(of: value) { _ in
                        validateIfNeeded()
                    }
            }
            
            if let error = validationState.getError(for: input.id) {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .accessibilityInput(
            label: input.label ?? input.placeholder,
            value: value,
            isRequired: input.isRequired ?? false
        )
    }
    
    private var borderColor: Color {
        if validationState.getError(for: input.id) != nil {
            return .red
        }
        return Color.gray.opacity(0.3)
    }
    
    private var keyboardType: UIKeyboardType {
        guard let style = input.style else { return .default }
        
        switch style {
        case .text:
            return .default
        case .tel:
            return .phonePad
        case .url:
            return .URL
        case .email:
            return .emailAddress
        case .password:
            return .default
        }
    }
    
    private var textContentType: UITextContentType? {
        guard let style = input.style else { return nil }
        
        switch style {
        case .email:
            return .emailAddress
        case .tel:
            return .telephoneNumber
        case .url:
            return .URL
        case .password:
            return .password
        default:
            return nil
        }
    }
    
    private var autocapitalization: TextInputAutocapitalization {
        guard let style = input.style else { return .sentences }
        
        switch style {
        case .text:
            return .sentences
        case .email, .url, .password:
            return .never
        case .tel:
            return .never
        }
    }
    
    private func validateIfNeeded() {
        let error = InputValidator.validateText(value: value.isEmpty ? nil : value, input: input)
        validationState.setError(for: input.id, message: error)
    }
}
