import SwiftUI
import ACCore

struct AccordionView: View {
    let accordion: Accordion
    let hostConfig: HostConfig
    
    @State private var expandedPanels: Set<Int>
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    init(accordion: Accordion, hostConfig: HostConfig) {
        self.accordion = accordion
        self.hostConfig = hostConfig
        
        var initialExpanded = Set<Int>()
        for (index, panel) in accordion.panels.enumerated() {
            if panel.isExpanded == true {
                initialExpanded.insert(index)
            }
        }
        _expandedPanels = State(initialValue: initialExpanded)
    }
    
    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }
    
    private var padding: CGFloat {
        isTablet ? 20 : 16
    }
    
    private var titleFont: Font {
        isTablet ? .title3 : .body
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(accordion.panels.enumerated()), id: \.offset) { index, panel in
                AccordionPanelView(
                    panel: panel,
                    index: index,
                    isExpanded: expandedPanels.contains(index),
                    hostConfig: hostConfig,
                    padding: padding,
                    titleFont: titleFont,
                    onToggle: {
                        togglePanel(at: index)
                    }
                )
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Accordion with \(accordion.panels.count) panels")
    }
    
    private func togglePanel(at index: Int) {
        if accordion.expandMode == .single {
            if expandedPanels.contains(index) {
                expandedPanels.remove(index)
            } else {
                expandedPanels.removeAll()
                expandedPanels.insert(index)
            }
        } else {
            if expandedPanels.contains(index) {
                expandedPanels.remove(index)
            } else {
                expandedPanels.insert(index)
            }
        }
    }
}

private struct AccordionPanelView: View {
    let panel: AccordionPanel
    let index: Int
    let isExpanded: Bool
    let hostConfig: HostConfig
    let padding: CGFloat
    let titleFont: Font
    let onToggle: () -> Void
    
    @EnvironmentObject var viewModel: CardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(panel.title)
                        .font(titleFont)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding(padding)
                .frame(minHeight: 44)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(panel.title)
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            .accessibilityHint("Double tap to \(isExpanded ? "collapse" : "expand")")
            .accessibilityAddTraits(.isButton)
            
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(Array(panel.content.enumerated()), id: \.offset) { _, item in
                        if item.isVisible {
                            ElementView(element: item, hostConfig: hostConfig)
                        }
                    }
                }
                .padding(.horizontal, padding)
                .padding(.bottom, padding)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}
