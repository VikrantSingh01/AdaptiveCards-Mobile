import SwiftUI
import ACCore
import ACAccessibility

struct TabSetView: View {
    let tabSet: TabSet
    let hostConfig: HostConfig
    
    @State private var selectedTabId: String
    @EnvironmentObject var viewModel: CardViewModel
    
    init(tabSet: TabSet, hostConfig: HostConfig) {
        self.tabSet = tabSet
        self.hostConfig = hostConfig
        
        // Initialize selected tab
        let initialTabId = tabSet.selectedTabId ?? tabSet.tabs.first?.id ?? ""
        _selectedTabId = State(initialValue: initialTabId)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(tabSet.tabs, id: \.id) { tab in
                        TabButton(
                            tab: tab,
                            isSelected: selectedTabId == tab.id,
                            hostConfig: hostConfig
                        ) {
                            selectedTabId = tab.id
                        }
                    }
                }
            }
            .frame(height: 44)
            .background(Color.gray.opacity(0.1))
            
            Divider()
            
            // Tab content
            if let selectedTab = tabSet.tabs.first(where: { $0.id == selectedTabId }) {
                TabContentView(tab: selectedTab, hostConfig: hostConfig)
            }
        }
        .spacing(tabSet.spacing, hostConfig: hostConfig)
        .separator(tabSet.separator, hostConfig: hostConfig)
    }
}

struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let hostConfig: HostConfig
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let iconName = tab.icon {
                    Image(systemName: iconName)
                        .font(.caption)
                }
                
                Text(tab.title)
                    .font(.subheadline)
            }
            .foregroundColor(isSelected ? .blue : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected ? Color.blue.opacity(0.1) : Color.clear
            )
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? .blue : .clear),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
    }
}

struct TabContentView: View {
    let tab: Tab
    let hostConfig: HostConfig
    
    @EnvironmentObject var viewModel: CardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(tab.items.enumerated()), id: \.offset) { index, element in
                    if viewModel.isElementVisible(elementId: element.id) {
                        ElementView(element: element, hostConfig: hostConfig)
                    }
                }
            }
            .padding(CGFloat(hostConfig.spacing.padding))
        }
    }
}
