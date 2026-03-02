import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Accessibility Labels and Hints

public extension View {
    /// Adds accessibility label and hint based on element properties
    func accessibilityElement(
        label: String?,
        hint: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self.modifier(AccessibilityElementModifier(label: label, hint: hint, traits: traits))
    }

    /// Adds accessibility for input fields
    func accessibilityInput(
        label: String?,
        value: String?,
        isRequired: Bool = false,
        error: String? = nil
    ) -> some View {
        self.modifier(AccessibilityInputModifier(label: label, value: value, isRequired: isRequired, error: error))
    }

    /// Adds accessibility for action buttons
    func accessibilityAction(
        label: String?,
        hint: String? = nil
    ) -> some View {
        self.modifier(AccessibilityActionModifier(label: label, hint: hint))
    }
}

private struct AccessibilityElementModifier: ViewModifier {
    let label: String?
    let hint: String?
    let traits: AccessibilityTraits

    func body(content: Content) -> some View {
        if let label = label {
            content
                .accessibilityLabel(label)
                .accessibilityHint(hint ?? "")
                .accessibilityAddTraits(traits)
        } else {
            content
        }
    }
}

private struct AccessibilityInputModifier: ViewModifier {
    let label: String?
    let value: String?
    let isRequired: Bool
    let error: String?

    init(label: String?, value: String?, isRequired: Bool, error: String? = nil) {
        self.label = label
        self.value = value
        self.isRequired = isRequired
        self.error = error
    }

    func body(content: Content) -> some View {
        var accessibilityLabel = label ?? "Input field"
        if isRequired {
            accessibilityLabel += ", required"
        }
        if let value = value, !value.isEmpty {
            accessibilityLabel += ", current value: \(value)"
        }
        if let error = error {
            accessibilityLabel += ", Error: \(error)"
        }

        return content
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(.isButton)
    }
}

private struct AccessibilityActionModifier: ViewModifier {
    let label: String?
    let hint: String?

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label ?? "Action")
            .accessibilityHint(hint ?? "Double tap to activate")
            // Note: do NOT add .isButton here — the SwiftUI Button wrapper
            // in ActionButton already provides this trait. Adding it again
            // causes VoiceOver to announce "Button" twice (upstream #176).
    }
}

// MARK: - Accessibility Container

public extension View {
    /// Groups related elements into an accessibility container
    func accessibilityContainer(label: String? = nil) -> some View {
        Group {
            if let label = label {
                self.accessibilityElement(children: .contain)
                    .accessibilityLabel(label)
            } else {
                self.accessibilityElement(children: .contain)
            }
        }
    }
}

// MARK: - ChoiceSet / Dropdown Accessibility

public extension View {
    /// Adds accessibility for a dropdown/picker button showing its state.
    func accessibilityDropdown(
        label: String,
        selectedValue: String?,
        isRequired: Bool = false
    ) -> some View {
        let req = isRequired ? ", required" : ""
        let val = (selectedValue != nil && !selectedValue!.isEmpty) ? ", \(selectedValue!)" : ""
        return self
            .accessibilityLabel("\(label)\(req), popup button\(val)")
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Double tap to open dropdown")
    }

    /// Adds accessibility for a choice item in a radio group or choice list,
    /// providing correct "X of Y" position info for VoiceOver.
    func accessibilityChoiceItem(
        label: String,
        index: Int,
        totalCount: Int,
        selected: Bool
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityValue(selected ? "selected" : "")
            .accessibilityHint("\(index + 1) of \(totalCount)")
            .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    /// Marks this view as a list container for accessibility with the given
    /// item count.  VoiceOver uses this to announce "list, N items".
    func accessibilityChoiceList(label: String, count: Int) -> some View {
        self
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(label), \(count) options")
    }
}


// MARK: - Error Announcement

public extension View {
    /// Posts a VoiceOver announcement when an error message appears or changes.
    /// This ensures screen reader users are notified of validation errors
    /// without needing to manually navigate to them (upstream #493).
    func accessibilityAnnounceError(_ error: String?) -> some View {
        self.onChange(of: error) { newError in
            #if canImport(UIKit)
            if let message = newError {
                UIAccessibility.post(notification: .announcement, argument: message)
            }
            #endif
        }
    }
}
