// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore
import ACInputs
import ACCharts

/// Maximum nesting depth for card elements.
/// Device main thread stack is ~1MB; each SwiftUI view body cycle uses
/// ~12 stack frames. Depth 10 keeps total well under stack limit.
let elementViewMaxNestingDepth = 10

/// Routes to the appropriate view for each element type.
///
/// Uses `AnyView` to type-erase the 30+ branch `@ViewBuilder` result.
/// Without this, Swift allocates a single stack frame large enough for the
/// *union* of every branch (~50-80 KB), and just 13 nested ElementViews
/// overflow the 1 MB main-thread stack on physical devices.
/// `AnyView` collapses each branch to a fixed-size existential, keeping
/// the per-frame cost constant regardless of branch count.
struct ElementView: View {
    let element: CardElement
    let hostConfig: HostConfig
    var depth: Int = 0

    @Environment(\.validationState) var validationState
    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @EnvironmentObject var viewModel: CardViewModel

    @Environment(\.widthCategory) var widthCategory

    var body: some View {
        if depth >= elementViewMaxNestingDepth {
            EmptyView()
        } else if shouldShowForTargetWidth(element.targetWidth, currentCategory: widthCategory) {
            if let customRenderer = ElementRendererRegistry.shared.getRenderer(for: element.typeString) {
                customRenderer(element)
            } else {
                builtInRenderer
            }
        }
    }

    /// Type-erased renderer to keep per-frame stack usage constant.
    private var builtInRenderer: AnyView {
        let childDepth = depth + 1
        switch element {
        case .textBlock(let textBlock):
            return AnyView(TextBlockView(textBlock: textBlock, hostConfig: hostConfig))
        case .image(let image):
            return AnyView(ImageView(image: image, hostConfig: hostConfig))
        case .media(let media):
            return AnyView(MediaView(media: media, hostConfig: hostConfig))
        case .richTextBlock(let richTextBlock):
            return AnyView(RichTextBlockView(richTextBlock: richTextBlock, hostConfig: hostConfig))
        case .container(let container):
            return AnyView(ContainerView(container: container, hostConfig: hostConfig, depth: childDepth))
        case .columnSet(let columnSet):
            return AnyView(ColumnSetView(columnSet: columnSet, hostConfig: hostConfig, depth: childDepth))
        case .imageSet(let imageSet):
            return AnyView(ImageSetView(imageSet: imageSet, hostConfig: hostConfig))
        case .factSet(let factSet):
            return AnyView(FactSetView(factSet: factSet, hostConfig: hostConfig))
        case .actionSet(let actionSet):
            return AnyView(
                ActionSetView(actions: actionSet.actions, hostConfig: hostConfig)
                    .spacing(actionSet.spacing, hostConfig: hostConfig)
                    .separator(actionSet.separator, hostConfig: hostConfig)
            )
        case .table(let table):
            return AnyView(TableView(table: table, hostConfig: hostConfig, depth: childDepth))
        case .textInput(let input):
            return AnyView(TextInputView(
                input: input,
                hostConfig: hostConfig,
                value: binding(for: input.id, defaultValue: input.value ?? ""),
                validationState: validationState,
                onInlineAction: input.inlineAction != nil ? { action in
                    actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
                } : nil
            ))
        case .numberInput(let input):
            return AnyView(NumberInputView(
                input: input,
                hostConfig: hostConfig,
                value: binding(for: input.id, defaultValue: input.value),
                validationState: validationState
            ))
        case .dateInput(let input):
            return AnyView(DateInputView(
                input: input,
                hostConfig: hostConfig,
                value: binding(for: input.id, defaultValue: input.value),
                validationState: validationState
            ))
        case .timeInput(let input):
            return AnyView(TimeInputView(
                input: input,
                hostConfig: hostConfig,
                value: binding(for: input.id, defaultValue: input.value),
                validationState: validationState
            ))
        case .toggleInput(let input):
            let valueOn = input.valueOn ?? "true"
            let valueOff = input.valueOff ?? "false"
            let initialValue = input.value == valueOn
            return AnyView(ToggleInputView(
                input: input,
                hostConfig: hostConfig,
                value: binding(for: input.id, defaultValue: initialValue)
            ))
        case .choiceSetInput(let input):
            return AnyView(ChoiceSetInputView(
                input: input,
                hostConfig: hostConfig,
                value: binding(for: input.id, defaultValue: input.value),
                validationState: validationState
            ))
        case .dataGridInput(let input):
            return AnyView(DataGridInputView(
                input: input,
                gridData: gridDataBinding(for: input)
            ))
        case .carousel(let carousel):
            return AnyView(CarouselView(carousel: carousel, hostConfig: hostConfig, depth: childDepth))
        case .accordion(let accordion):
            return AnyView(AccordionView(accordion: accordion, hostConfig: hostConfig, depth: childDepth))
        case .codeBlock(let codeBlock):
            return AnyView(CodeBlockView(codeBlock: codeBlock, hostConfig: hostConfig))
        case .ratingDisplay(let rating):
            return AnyView(RatingDisplayView(rating: rating, hostConfig: hostConfig))
        case .ratingInput(let input):
            return AnyView(RatingInputView(
                input: input,
                hostConfig: hostConfig,
                value: binding(for: input.id, defaultValue: input.value ?? 0.0),
                validationState: validationState
            ))
        case .progressBar(let progressBar):
            return AnyView(ProgressBarView(progressBar: progressBar, hostConfig: hostConfig))
        case .spinner(let spinner):
            return AnyView(SpinnerView(spinner: spinner, hostConfig: hostConfig))
        case .tabSet(let tabSet):
            return AnyView(TabSetView(tabSet: tabSet, hostConfig: hostConfig, depth: childDepth))
        case .list(let list):
            return AnyView(ListView(list: list, hostConfig: hostConfig, depth: childDepth))
        case .compoundButton(let button):
            return AnyView(CompoundButtonView(button: button, hostConfig: hostConfig))
        case .donutChart(let chart):
            return AnyView(DonutChartView(chart: chart))
        case .barChart(let chart):
            return AnyView(BarChartView(chart: chart))
        case .lineChart(let chart):
            return AnyView(LineChartView(chart: chart))
        case .pieChart(let chart):
            return AnyView(PieChartView(chart: chart))
        case .icon(let icon):
            return AnyView(IconElementView(icon: icon, hostConfig: hostConfig))
        case .badge(let badge):
            return AnyView(BadgeView(badge: badge, hostConfig: hostConfig))
        case .unknown(let type):
            #if DEBUG
            return AnyView(
                Text("Unknown element type: \(type)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
            )
            #else
            return AnyView(EmptyView())
            #endif
        }
    }

    private func gridDataBinding(for input: DataGridInput) -> Binding<[[DataGridCellValue]]> {
        let defaultRows = input.rows ?? []
        return Binding(
            get: {
                if let value = viewModel.getInputValue(forId: input.id) as? [[DataGridCellValue]] {
                    return value
                }
                return defaultRows
            },
            set: { newValue in
                viewModel.setInputValue(id: input.id, value: newValue)
            }
        )
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
