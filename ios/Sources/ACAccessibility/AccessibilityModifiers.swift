import SwiftUI

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
        isRequired: Bool = false
    ) -> some View {
        self.modifier(AccessibilityInputModifier(label: label, value: value, isRequired: isRequired))
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

    func body(content: Content) -> some View {
        var accessibilityLabel = label ?? "Input field"
        if isRequired {
            accessibilityLabel += ", required"
        }
        if let value = value, !value.isEmpty {
            accessibilityLabel += ", current value: \(value)"
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
            .accessibilityAddTraits(.isButton)
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
