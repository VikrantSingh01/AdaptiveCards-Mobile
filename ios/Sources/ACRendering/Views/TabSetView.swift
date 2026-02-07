import SwiftUI
import ACCore

struct TabSetView: View {
    let tabSet: TabSet
    let hostConfig: HostConfig
    
    @State private var selectedTabIndex: Int
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    init(tabSet: TabSet, hostConfig: HostConfig) {
        self.tabSet = tabSet
        self.hostConfig = hostConfig
        
        var initialIndex = 0
        if let selectedId = tabSet.selectedTabId,
           let foundIndex = tabSet.tabs.firstIndex(where: { $0.id == selectedId }) {
            initialIndex = foundIndex
        }
        _selectedTabIndex = State(initialValue: initialIndex)
    }
    
    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }
    
    private var edgePadding: CGFloat {
        isTablet ? 8 : 0
    }
    
    private var contentPadding: CGFloat {
        isTablet ? 24 : 16
    }
    
    private var tabFont: Font {
        isTablet ? .body : .subheadline
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(tabSet.tabs.enumerated()), id: \.offset) { index, tab in
                        TabButton(
                            tab: tab,
                            isSelected: selectedTabIndex == index,
                            font: tabFont,
                            onTap: {
                                selectedTabIndex = index
                            }
                        )
                    }
                }
                .padding(.horizontal, edgePadding)
            }
            .frame(height: 48)
            
            Divider()
            
            TabView(selection: $selectedTabIndex) {
                ForEach(Array(tabSet.tabs.enumerated()), id: \.offset) { index, tab in
                    TabContentView(tab: tab, hostConfig: hostConfig)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tab set with \(tabSet.tabs.count) tabs")
        .accessibilityValue("Selected: \(tabSet.tabs[selectedTabIndex].title)")
    }
}

private struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let font: Font
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    if let icon = tab.icon {
                        Text(icon)
                            .font(.body)
                    }
                    
                    Text(tab.title)
                        .font(font)
                        .fontWeight(isSelected ? .semibold : .regular)
                }
                .foregroundColor(isSelected ? .accentColor : .primary)
                
                Rectangle()
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(tab.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to select this tab")
        .accessibilityAddTraits(.isButton)
    }
}

private struct TabContentView: View {
    let tab: Tab
    let hostConfig: HostConfig
    
    @EnvironmentObject var viewModel: CardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(Array(tab.items.enumerated()), id: \.offset) { _, item in
                    if item.isVisible {
                        ElementView(element: item, hostConfig: hostConfig)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}
