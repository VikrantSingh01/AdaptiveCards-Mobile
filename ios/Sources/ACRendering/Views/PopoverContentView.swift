// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore

/// Bottom sheet view that renders a single CardElement as popover content.
/// Used by Action.Popover to display contextual content without stealing focus.
struct PopoverContentView: View {
    let content: CardElement?
    let title: String?
    let hostConfig: HostConfig
    var depth: Int = 0

    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var contentHeight: CGFloat = 0

    var body: some View {
        NavigationView {
            Group {
                if let content = content {
                    ScrollView {
                        ElementView(element: content, hostConfig: hostConfig, depth: depth)
                            .environmentObject(viewModel)
                            .padding(CGFloat(hostConfig.spacing.padding))
                            .background(
                                GeometryReader { geo in
                                    Color.clear.onAppear {
                                        contentHeight = geo.size.height
                                    }
                                }
                            )
                    }
                } else {
                    Text("No content")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationTitle(title ?? "")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Dismiss")
                }
            }
        }
        #if canImport(UIKit)
        .presentationDetents(contentBasedDetents)
        .presentationDragIndicator(.visible)
        .modifier(PresentationContentInteractionModifier())
        #endif
    }

    /// Compute detents based on measured content height.
    /// Caps at 80% of screen height, with .large as a fallback for tall content.
    private var contentBasedDetents: Set<PresentationDetent> {
        #if canImport(UIKit)
        let screenHeight = UIScreen.main.bounds.height
        let navBarEstimate: CGFloat = 80
        let measuredHeight = contentHeight + navBarEstimate
        let cappedHeight = min(measuredHeight, screenHeight * 0.8)
        if contentHeight > 0 {
            return [.height(cappedHeight), .large]
        }
        #endif
        return [.medium, .large]
    }
}

/// Availability-safe wrapper for presentationContentInteraction(.scrolls).
private struct PresentationContentInteractionModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            content.presentationContentInteraction(.scrolls)
        } else {
            content
        }
    }
}
