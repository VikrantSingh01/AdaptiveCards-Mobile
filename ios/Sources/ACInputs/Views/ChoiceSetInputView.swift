import SwiftUI
import ACCore
import ACAccessibility

public struct ChoiceSetInputView: View {
    let input: ChoiceSetInput
    let hostConfig: HostConfig
    @Binding var value: String?
    @ObservedObject var validationState: ValidationState
    @State private var selectedValues: Set<String> = []
    @State private var filterText: String = ""
    @State private var isFilterExpanded: Bool = false

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
                let suffix = (input.isRequired == true) ? (hostConfig.inputs.label.requiredInputs.suffix) : ""
                Text(label + suffix)
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
        VStack(alignment: .leading, spacing: 0) {
            TextField(input.placeholder ?? "Type to filter...", text: Binding(
                get: {
                    if isFilterExpanded {
                        return filterText
                    }
                    // Show selected choice title when not editing
                    if let val = value, !val.isEmpty {
                        return input.choices.first(where: { $0.value == val })?.title ?? val
                    }
                    return filterText
                },
                set: { newValue in
                    filterText = newValue
                    isFilterExpanded = true
                }
            ))
            .textFieldStyle(.roundedBorder)
            .onTapGesture {
                isFilterExpanded = true
                filterText = ""
            }

            if isFilterExpanded && !filterText.isEmpty {
                let filtered = input.choices.filter {
                    $0.title.localizedCaseInsensitiveContains(filterText)
                }
                if !filtered.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(filtered.prefix(10), id: \.value) { choice in
                            Button(action: {
                                value = choice.value
                                filterText = choice.title
                                isFilterExpanded = false
                                validateIfNeeded()
                            }) {
                                Text(choice.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.primary)

                            if choice.value != filtered.prefix(10).last?.value {
                                Divider()
                            }
                        }
                    }
                    .background(Color(white: 0.95))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
        }
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
