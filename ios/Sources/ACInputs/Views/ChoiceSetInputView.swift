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
        let isExpanded = (input.style ?? .compact) == .expanded

        VStack(alignment: .leading, spacing: 4) {
            if let label = input.label {
                if isExpanded {
                    // For expanded style, the label is a standalone accessible
                    // text element. Required state goes here instead of the
                    // parent container so it is not repeated per item (#483).
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel(
                            (input.isRequired == true)
                                ? "\(label), required"
                                : label
                        )
                } else {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
        // For expanded style, do NOT apply accessibilityInput to the outer
        // container — it causes VoiceOver to repeat the group label with
        // every radio button / checkbox (upstream #483).  The label Text
        // carries the required state and accessibilityChoiceList provides
        // the group "N options" announcement.
        .conditionalAccessibilityInput(
            apply: !isExpanded,
            label: input.label ?? "Choice set",
            value: input.displayText(forValue: value),
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
            ForEach(Array(input.choices.enumerated()), id: \.element.value) { index, choice in
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
                    .accessibilityChoiceItem(
                        label: choice.title,
                        index: index,
                        totalCount: input.choices.count,
                        selected: selectedValues.contains(choice.value)
                    )
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
                    .accessibilityChoiceItem(
                        label: choice.title,
                        index: index,
                        totalCount: input.choices.count,
                        selected: value == choice.value
                    )
                }
            }
        }
        .accessibilityChoiceList(label: input.label ?? "Choices", count: input.choices.count)
    }

    private var filteredView: some View {
        FilteredChoiceSetView(
            input: input,
            value: $value,
            selectedValues: $selectedValues,
            onValidate: { validateIfNeeded() },
            onUpdateMultiSelect: { updateMultiSelectValue() }
        )
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

// MARK: - Conditional Accessibility Input
/// Applies accessibilityInput only when the condition is true, preventing
/// VoiceOver from repeating the group label on every child in expanded mode.
private extension View {
    @ViewBuilder
    func conditionalAccessibilityInput(
        apply: Bool,
        label: String,
        value: String?,
        isRequired: Bool
    ) -> some View {
        if apply {
            self.accessibilityInput(label: label, value: value, isRequired: isRequired)
        } else {
            self
        }
    }
}

// MARK: - Filtered ChoiceSet View
/// Provides a searchable/filtered choice set that always displays titles (not values).
struct FilteredChoiceSetView: View {
    let input: ChoiceSetInput
    @Binding var value: String?
    @Binding var selectedValues: Set<String>
    let onValidate: () -> Void
    let onUpdateMultiSelect: () -> Void
    @State private var searchText: String = ""

    private var filteredChoices: [ChoiceSetInput.Choice] {
        if searchText.isEmpty {
            return input.choices
        }
        return input.choices.filter { choice in
            choice.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField(input.placeholder ?? "Type to filter", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // Filtered results
            if filteredChoices.isEmpty {
                Text("No matching options")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding(.vertical, 4)
            } else {
                ForEach(filteredChoices, id: \.value) { choice in
                    if input.isMultiSelect == true {
                        Toggle(choice.title, isOn: Binding(
                            get: { selectedValues.contains(choice.value) },
                            set: { isSelected in
                                if isSelected {
                                    selectedValues.insert(choice.value)
                                } else {
                                    selectedValues.remove(choice.value)
                                }
                                onUpdateMultiSelect()
                            }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    } else {
                        Button(action: {
                            value = choice.value
                            onValidate()
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
    }
}
