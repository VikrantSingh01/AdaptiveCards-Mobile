import SwiftUI
import ACCore
import ACAccessibility

struct AccordionView: View {
    let accordion: Accordion
    let hostConfig: HostConfig

    @State private var expandedPanels: Set<Int>
    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.sizeCategory) var sizeCategory

    init(accordion: Accordion, hostConfig: HostConfig) {
        self.accordion = accordion
        self.hostConfig = hostConfig

        // Initialize expanded panels based on isExpanded property
        var initialExpanded = Set<Int>()
        for (index, panel) in accordion.panels.enumerated() {
            if panel.isExpanded == true {
                initialExpanded.insert(index)
            }
        }
        _expandedPanels = State(initialValue: initialExpanded)
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(accordion.panels.enumerated()), id: \.offset) { index, panel in
                AccordionPanelView(
                    panel: panel,
                    isExpanded: expandedPanels.contains(index),
                    panelNumber: index + 1,
                    totalPanels: accordion.panels.count,
                    hostConfig: hostConfig,
                    onToggle: {
                        togglePanel(at: index)
                    }
                )
            }
        }
        .spacing(accordion.spacing, hostConfig: hostConfig)
        .separator(accordion.separator, hostConfig: hostConfig)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Accordion with \(accordion.panels.count) panels")
    }

    private func togglePanel(at index: Int) {
        let expandMode = accordion.expandMode ?? .single

        withAnimation {
            if expandedPanels.contains(index) {
                expandedPanels.remove(index)
            } else {
                if expandMode == .single {
                    expandedPanels.removeAll()
                }
                expandedPanels.insert(index)
            }
        }
    }
}

struct AccordionPanelView: View {
    let panel: AccordionPanel
    let isExpanded: Bool
    let panelNumber: Int
    let totalPanels: Int
    let hostConfig: HostConfig
    let onToggle: () -> Void

    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: adaptiveSpacing) {
                    Text(panel.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .imageScale(.medium)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .padding(adaptivePadding)
                .background(Color.gray.opacity(0.1))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(panel.title), panel \(panelNumber) of \(totalPanels)")
            .accessibilityHint(isExpanded ? "Expanded. Double tap to collapse" : "Collapsed. Double tap to expand")
            .accessibilityAddTraits(.isButton)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(panel.content) { element in
                        if viewModel.isElementVisible(elementId: element.elementId) {
                            ElementView(element: element, hostConfig: hostConfig)
                        }
                    }
                }
                .padding(adaptivePadding)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3)),
            alignment: .bottom
        )
    }

    private var adaptiveSpacing: CGFloat {
        sizeCategory.isAccessibilityCategory ? 12 : 8
    }

    private var adaptivePadding: CGFloat {
        sizeCategory.isAccessibilityCategory ? CGFloat(hostConfig.spacing.padding) * 1.5 : CGFloat(hostConfig.spacing.padding)
    }
}
