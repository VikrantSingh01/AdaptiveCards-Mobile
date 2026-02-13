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
            // Check custom renderer registry first
            if let customRenderer = ElementRendererRegistry.shared.getRenderer(for: element.typeString) {
                customRenderer(element)
            } else {
                // Fall back to built-in renderers
                builtInRenderer
            }
        }
    }
    
    @ViewBuilder
    private var builtInRenderer: some View {
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
        case .carousel(let carousel):
            CarouselView(carousel: carousel, hostConfig: hostConfig)
        case .accordion(let accordion):
            AccordionView(accordion: accordion, hostConfig: hostConfig)
        case .codeBlock(let codeBlock):
            CodeBlockView(codeBlock: codeBlock, hostConfig: hostConfig)
        case .ratingDisplay(let rating):
            RatingDisplayView(rating: rating, hostConfig: hostConfig)
        case .ratingInput(let input):
            RatingInputView(
                input: input,
                hostConfig: hostConfig,
                value: binding(for: input.id, defaultValue: input.value ?? 0.0),
                validationState: validationState
            )
        case .progressBar(let progressBar):
            ProgressBarView(progressBar: progressBar, hostConfig: hostConfig)
        case .spinner(let spinner):
            SpinnerView(spinner: spinner, hostConfig: hostConfig)
        case .tabSet(let tabSet):
            TabSetView(tabSet: tabSet, hostConfig: hostConfig)
        case .list(let list):
            ListView(list: list, hostConfig: hostConfig)
        case .compoundButton(let button):
            CompoundButtonView(button: button, hostConfig: hostConfig)
        case .donutChart, .barChart, .lineChart, .pieChart:
            // Chart rendering not yet implemented
            Text("Chart element")
                .font(.caption)
                .foregroundColor(.gray)
        case .unknown(let type):
            // Skip rendering unknown elements, or show placeholder in debug mode
            #if DEBUG
            Text("Unknown element type: \(type)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
            #else
            EmptyView()
            #endif
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
                viewModel.setInputValue(id: inputId, value: newValue)
            }
        )
    }
}
