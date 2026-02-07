import SwiftUI
import ACCore
import ACAccessibility

struct AccordionView: View {
    let accordion: Accordion
    let hostConfig: HostConfig
    
    @State private var expandedPanels: Set<Int>
    @EnvironmentObject var viewModel: CardViewModel
    
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
                    hostConfig: hostConfig,
                    onToggle: {
                        togglePanel(at: index)
                    }
                )
            }
        }
        .spacing(accordion.spacing, hostConfig: hostConfig)
        .separator(accordion.separator, hostConfig: hostConfig)
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
    let hostConfig: HostConfig
    let onToggle: () -> Void
    
    @EnvironmentObject var viewModel: CardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(panel.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding(CGFloat(hostConfig.spacing.padding))
                .background(Color.gray.opacity(0.1))
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(panel.content.enumerated()), id: \.offset) { index, element in
                        if viewModel.isElementVisible(elementId: element.id) {
                            ElementView(element: element, hostConfig: hostConfig)
                        }
                    }
                }
                .padding(CGFloat(hostConfig.spacing.padding))
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
}
