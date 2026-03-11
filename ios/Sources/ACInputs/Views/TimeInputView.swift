import SwiftUI
import ACCore
import ACAccessibility

public struct TimeInputView: View {
    let input: TimeInput
    let hostConfig: HostConfig
    @Binding var value: String?
    @ObservedObject var validationState: ValidationState
    @State private var date: Date = Date()
    @State private var hasSelection: Bool = false

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    public init(
        input: TimeInput,
        hostConfig: HostConfig,
        value: Binding<String?>,
        validationState: ValidationState
    ) {
        self.input = input
        self.hostConfig = hostConfig
        self._value = value
        self.validationState = validationState

        if let value = value.wrappedValue,
           let time = timeFormatter.date(from: value) {
            _date = State(initialValue: time)
            _hasSelection = State(initialValue: true)
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = input.label {
                let suffix = (input.isRequired == true) ? (hostConfig.inputs.label.requiredInputs.suffix) : ""
                Text(label + suffix)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if hasSelection {
                DatePicker(
                    input.placeholder ?? "Select time",
                    selection: $date,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.compact)
                .tint(.blue)
                .onChange(of: date) { newDate in
                    updateValue(from: newDate)
                }
            } else {
                Button {
                    hasSelection = true
                    updateValue(from: date)
                } label: {
                    HStack {
                        Text(input.placeholder ?? "Select time")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
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

    private func updateValue(from date: Date) {
        value = timeFormatter.string(from: date)

        let error = InputValidator.validateTime(value: value, input: input)
        validationState.setError(for: input.id, message: error)
    }
}
