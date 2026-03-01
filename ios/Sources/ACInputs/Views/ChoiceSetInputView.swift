import SwiftUI
import ACCore
import ACAccessibility

public struct ChoiceSetInputView: View {
    let input: ChoiceSetInput
    let hostConfig: HostConfig
    @Binding var value: String?
    @ObservedObject var validationState: ValidationState
    @State private var selectedValues: Set<String> = []

    public init(
        input: ChoiceSetInput,
        hostConfig: HostConfig,
        value: Binding<String?>,
        validationState: ValidationState
    ) {
        self.input = input
        self.hostConfig = hostConfig
        self._value = value
        self.validationState = validationState

        if let value = value.wrappedValue {
            if input.isMultiSelect == true {
                _selectedValues = State(initialValue: Set(value.split(separator: ",").map { String($0) }))
            } else {
                _selectedValues = State(initialValue: [value])
            }
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = input.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            switch input.style ?? .compact {
            case .compact:
                compactView
            case .expanded:
                expandedView
            case .filtered:
                filteredView
            }

            if let error = validationState.getError(for: input.id) {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .accessibilityInput(
            label: input.label ?? "Choice set",
            value: value,
            isRequired: input.isRequired ?? false
        )
    }

    private var compactView: some View {
        Group {
            if input.isMultiSelect == true {
                multiSelectCompactView
            } else {
                singleSelectCompactView
            }
        }
    }

    private var singleSelectCompactView: some View {
        Picker(input.placeholder ?? "Select", selection: Binding(
            get: { value ?? "" },
            set: { newValue in
                value = newValue
                validateIfNeeded()
            }
        )) {
            Text(input.placeholder ?? "Select").tag("")
            ForEach(input.choices, id: \.value) { choice in
                Text(choice.title).tag(choice.value)
            }
        }
        .pickerStyle(.menu)
        .tint(.blue)
    }

    private var multiSelectCompactView: some View {
        VStack(alignment: .leading) {
            ForEach(input.choices, id: \.value) { choice in
                Toggle(choice.title, isOn: Binding(
                    get: { selectedValues.contains(choice.value) },
                    set: { isSelected in
                        if isSelected {
                            selectedValues.insert(choice.value)
                        } else {
                            selectedValues.remove(choice.value)
                        }
                        updateMultiSelectValue()
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
        }
    }

    private var expandedView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(input.choices, id: \.value) { choice in
                if input.isMultiSelect == true {
                    Toggle(choice.title, isOn: Binding(
                        get: { selectedValues.contains(choice.value) },
                        set: { isSelected in
                            if isSelected {
                                selectedValues.insert(choice.value)
                            } else {
                                selectedValues.remove(choice.value)
                            }
                            updateMultiSelectValue()
                        }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                } else {
                    Button(action: {
                        value = choice.value
                        validateIfNeeded()
                    }) {
                        HStack {
                            Image(systemName: value == choice.value ? "circle.fill" : "circle")
                            Text(choice.title)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.primary)
                }
            }
        }
    }

    private var filteredView: some View {
        // Filtered view with search - simplified for now
        expandedView
    }

    private func updateMultiSelectValue() {
        value = selectedValues.sorted().joined(separator: ",")
        validateIfNeeded()
    }

    private func validateIfNeeded() {
        let error = InputValidator.validateChoiceSet(value: value, input: input)
        validationState.setError(for: input.id, message: error)
    }
}
