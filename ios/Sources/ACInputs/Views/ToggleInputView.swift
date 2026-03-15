// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

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
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                if let label = input.label {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(input.title)
                    .font(.system(size: CGFloat(hostConfig.fontSizes.default)))
            }
            Spacer()
            Toggle("", isOn: $value)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .accessibilityInput(
            label: input.label ?? input.title,
            value: value ? "On" : "Off",
            isRequired: false
        )
        .onAppear {
            let valueOn = input.valueOn ?? "true"
            let shouldBeOn = input.value == valueOn
            if value != shouldBeOn {
                value = shouldBeOn
            }
        }
    }
}
