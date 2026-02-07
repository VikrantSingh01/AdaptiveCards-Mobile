import SwiftUI
import ACCore
import ACAccessibility

public struct ToggleInputView: View {
    let input: ToggleInput
    let hostConfig: HostConfig
    @Binding var value: Bool
    
    public init(
        input: ToggleInput,
        hostConfig: HostConfig,
        value: Binding<Bool>
    ) {
        self.input = input
        self.hostConfig = hostConfig
        self._value = value
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = input.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Toggle(input.title, isOn: $value)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .accessibilityInput(
            label: input.label ?? input.title,
            value: value ? "On" : "Off",
            isRequired: false
        )
    }
}
