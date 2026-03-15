// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import ACCore
import ACAccessibility
import ACFluentUI

struct TabSetView: View {
    let tabSet: TabSet
    let hostConfig: HostConfig
    var depth: Int = 0

    @State private var selectedTabId: String
    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(tabSet: TabSet, hostConfig: HostConfig, depth: Int = 0) {
        self.tabSet = tabSet
        self.hostConfig = hostConfig
        self.depth = depth

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
                            hostConfig: hostConfig,
                            sizeCategory: sizeCategory
                        ) {
                            selectedTabId = tab.id
                            #if canImport(UIKit)
                            UIAccessibility.post(notification: .announcement, argument: "\(tab.title) tab selected")
                            #endif
                        }
                    }
                }
            }
            .frame(height: adaptiveTabBarHeight)
            .background(Color(hex: hostConfig.containerStyles.emphasis.backgroundColor))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Tab bar with \(tabSet.tabs.count) tabs")

            Divider()

            // Tab content
            if let selectedTab = tabSet.tabs.first(where: { $0.id == selectedTabId }) {
                TabContentView(tab: selectedTab, hostConfig: hostConfig, depth: depth)
            }
        }
        .spacing(tabSet.spacing, hostConfig: hostConfig)
        .separator(tabSet.separator, hostConfig: hostConfig)
    }

    private var adaptiveTabBarHeight: CGFloat {
        if sizeCategory.isAccessibilityCategory {
            return 60
        } else {
            return 44
        }
    }
}

struct TabButton: View {
    let tab: ACCore.Tab
    let isSelected: Bool
    let hostConfig: HostConfig
    let sizeCategory: ContentSizeCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if let iconName = tab.icon {
                    Image(systemName: iconName)
                        .font(adaptiveIconSize)
                        .accessibilityHidden(true)
                }

                Text(tab.title)
                    .font(adaptiveTextSize)
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? Color(hex: hostConfig.containerStyles.default.foregroundColors.accent.default) : Color(hex: hostConfig.containerStyles.default.foregroundColors.default.default))
            .padding(.horizontal, adaptiveHorizontalPadding)
            .padding(.vertical, adaptiveVerticalPadding)
            .frame(minWidth: 44, minHeight: 44)
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? Color(hex: hostConfig.containerStyles.default.foregroundColors.accent.default) : .clear),
                alignment: .bottom
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(tab.title)
        .accessibilityHint(isSelected ? "Selected tab" : "Double tap to select this tab")
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var adaptiveIconSize: Font {
        sizeCategory.isAccessibilityCategory ? .body : .caption
    }

    private var adaptiveTextSize: Font {
        sizeCategory.isAccessibilityCategory ? .body : .callout
    }

    private var adaptiveHorizontalPadding: CGFloat {
        sizeCategory.isAccessibilityCategory ? CGFloat(hostConfig.spacing.large) : CGFloat(hostConfig.spacing.medium)
    }

    private var adaptiveVerticalPadding: CGFloat {
        sizeCategory.isAccessibilityCategory ? CGFloat(hostConfig.spacing.large) : CGFloat(hostConfig.spacing.medium)
    }
}

struct TabContentView: View {
    let tab: ACCore.Tab
    let hostConfig: HostConfig
    var depth: Int = 0

    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(tab.items) { element in
                    if viewModel.isElementVisible(elementId: element.elementId) {
                        ElementView(element: element, hostConfig: hostConfig, depth: depth)
                    }
                }
            }
            .padding(adaptivePadding)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(tab.title) tab content")
    }

    private var adaptivePadding: CGFloat {
        if horizontalSizeClass == .regular {
            // iPad - more padding
            return CGFloat(hostConfig.spacing.padding) * 1.5
        } else {
            // iPhone
            return CGFloat(hostConfig.spacing.padding)
        }
    }
}
