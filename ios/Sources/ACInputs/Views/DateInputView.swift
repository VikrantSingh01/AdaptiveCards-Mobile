// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore
import ACAccessibility

public struct DateInputView: View {
    let input: DateInput
    let hostConfig: HostConfig
    @Binding var value: String?
    @ObservedObject var validationState: ValidationState
    @State private var date: Date = Date()
    @State private var hasSelection: Bool = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
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
           let date = dateFormatter.date(from: value) ?? ISO8601DateFormatter().date(from: value) {
            _date = State(initialValue: date)
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
                    input.placeholder ?? "Select date",
                    selection: $date,
                    displayedComponents: [.date]
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
                        Text(input.placeholder ?? "Select date")
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
        value = dateFormatter.string(from: date)

        let error = InputValidator.validateDate(value: value, input: input)
        validationState.setError(for: input.id, message: error)
    }
}
