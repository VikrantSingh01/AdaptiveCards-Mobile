import SwiftUI
import ACCore
import ACAccessibility

public struct DateInputView: View {
    let input: DateInput
    let hostConfig: HostConfig
    @Binding var value: String?
    @ObservedObject var validationState: ValidationState
    @State private var date: Date = Date()

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    public init(
        input: DateInput,
        hostConfig: HostConfig,
        value: Binding<String?>,
        validationState: ValidationState
    ) {
        self.input = input
        self.hostConfig = hostConfig
        self._value = value
        self.validationState = validationState

        if let value = value.wrappedValue,
           let date = dateFormatter.date(from: value) {
            _date = State(initialValue: date)
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = input.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            DatePicker(
                input.placeholder ?? "Select date",
                selection: $date,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .tint(.blue)
            .onChange(of: date) { newDate in
                updateValue(from: newDate)
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

    private func updateValue(from date: Date) {
        value = dateFormatter.string(from: date)

        let error = InputValidator.validateDate(value: value, input: input)
        validationState.setError(for: input.id, message: error)
    }
}
