import SwiftUI
import ACCore
import ACAccessibility

public struct NumberInputView: View {
    let input: NumberInput
    let hostConfig: HostConfig
    @Binding var value: Double?
    @ObservedObject var validationState: ValidationState
    @State private var textValue: String = ""
    
    public init(
        input: NumberInput,
        hostConfig: HostConfig,
        value: Binding<Double?>,
        validationState: ValidationState
    ) {
        self.input = input
        self.hostConfig = hostConfig
        self._value = value
        self.validationState = validationState
        
        if let value = value.wrappedValue {
            _textValue = State(initialValue: String(value))
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = input.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            numberTextField
            
            if let error = validationState.getError(for: input.id) {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .accessibilityInput(
            label: input.label ?? input.placeholder,
            value: textValue,
            isRequired: input.isRequired ?? false
        )
    }
    
    @ViewBuilder
    private var numberTextField: some View {
        let field = TextField(input.placeholder ?? "Enter number", text: $textValue)
            .textFieldStyle(.roundedBorder)
            .onChange(of: textValue) { newValue in
                updateValue(from: newValue)
            }
        #if os(iOS)
        field.keyboardType(.decimalPad)
        #else
        field
        #endif
    }

    private func updateValue(from text: String) {
        if text.isEmpty {
            value = nil
        } else if let doubleValue = Double(text) {
            value = doubleValue
        }
        
        let error = InputValidator.validateNumber(value: value, input: input)
        validationState.setError(for: input.id, message: error)
    }
}
