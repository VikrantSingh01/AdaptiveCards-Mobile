import SwiftUI
import ACCore

/// Bottom sheet view that renders a single CardElement as popover content.
/// Used by Action.Popover to display contextual content without stealing focus.
struct PopoverContentView: View {
    let content: CardElement?
    let title: String?
    let hostConfig: HostConfig

    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Group {
                if let content = content {
                    ScrollView {
                        ElementView(element: content, hostConfig: hostConfig)
                            .environmentObject(viewModel)
                            .padding(CGFloat(hostConfig.spacing.padding))
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #endif
    }
}
