import SwiftUI
import ACCore
import ACInputs

/// Routes to the appropriate view for each element type
struct ElementView: View {
    let element: CardElement
    let hostConfig: HostConfig
    
    @Environment(\.validationState) var validationState
    @EnvironmentObject var viewModel: CardViewModel
    
    var body: some View {
        Group {
            switch element {
            case .textBlock(let textBlock):
                TextBlockView(textBlock: textBlock, hostConfig: hostConfig)
            case .image(let image):
                ImageView(image: image, hostConfig: hostConfig)
            case .media(let media):
                MediaView(media: media, hostConfig: hostConfig)
            case .richTextBlock(let richTextBlock):
                RichTextBlockView(richTextBlock: richTextBlock, hostConfig: hostConfig)
            case .container(let container):
                ContainerView(container: container, hostConfig: hostConfig)
            case .columnSet(let columnSet):
                ColumnSetView(columnSet: columnSet, hostConfig: hostConfig)
            case .imageSet(let imageSet):
                ImageSetView(imageSet: imageSet, hostConfig: hostConfig)
            case .factSet(let factSet):
                FactSetView(factSet: factSet, hostConfig: hostConfig)
            case .actionSet(let actionSet):
                ActionSetView(actions: actionSet.actions, hostConfig: hostConfig)
            case .table(let table):
                TableView(table: table, hostConfig: hostConfig)
            case .textInput(let input):
                TextInputView(
                    input: input,
                    hostConfig: hostConfig,
                    value: binding(for: input.id, defaultValue: input.value ?? ""),
                    validationState: validationState
                )
            case .numberInput(let input):
                NumberInputView(
                    input: input,
                    hostConfig: hostConfig,
                    value: binding(for: input.id, defaultValue: input.value),
                    validationState: validationState
                )
            case .dateInput(let input):
                DateInputView(
                    input: input,
                    hostConfig: hostConfig,
                    value: binding(for: input.id, defaultValue: input.value),
                    validationState: validationState
                )
            case .timeInput(let input):
                TimeInputView(
                    input: input,
                    hostConfig: hostConfig,
                    value: binding(for: input.id, defaultValue: input.value),
                    validationState: validationState
                )
            case .toggleInput(let input):
                let valueOn = input.valueOn ?? "true"
                let valueOff = input.valueOff ?? "false"
                let initialValue = input.value == valueOn
                ToggleInputView(
                    input: input,
                    hostConfig: hostConfig,
                    value: binding(for: input.id, defaultValue: initialValue)
                )
            case .choiceSetInput(let input):
                ChoiceSetInputView(
                    input: input,
                    hostConfig: hostConfig,
                    value: binding(for: input.id, defaultValue: input.value),
                    validationState: validationState
                )
            }
        }
    }
    
    private func binding<T>(for inputId: String, defaultValue: T) -> Binding<T> {
        Binding(
            get: {
                if let value = viewModel.getInputValue(forId: inputId) as? T {
                    return value
                }
                return defaultValue
            },
            set: { newValue in
                viewModel.setInputValue(newValue, forId: inputId)
            }
        )
    }
}
