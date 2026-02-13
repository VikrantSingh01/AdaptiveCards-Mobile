import SwiftUI
import ACCore
import ACAccessibility

struct ListView: View {
    let list: ListElement
    let hostConfig: HostConfig

    @EnvironmentObject var viewModel: CardViewModel

    // Layout constants for consistency
    private enum Layout {
        static let bulletWidth: CGFloat = 20
        static let numberWidth: CGFloat = 24
        static let itemSpacing: CGFloat = 8
        static let minTouchTarget: CGFloat = 44
        static let itemVerticalPadding: CGFloat = 4
    }

    var body: some View {
        let maxHeightValue = parseMaxHeight(list.maxHeight)
        let listStyle = list.style ?? "default"

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(list.items.enumerated()), id: \.element.id) { index, item in
                    HStack(alignment: .top, spacing: Layout.itemSpacing) {
                        // Render list item prefix based on style
                        if listStyle == "bulleted" {
                            Text("•")
                                .font(.system(size: 18))
                                .foregroundColor(.primary)
                                .frame(width: Layout.bulletWidth, alignment: .leading)
                                .accessibilityHidden(true)
                        } else if listStyle == "numbered" {
                            Text("\(index + 1).")
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .frame(width: Layout.numberWidth, alignment: .leading)
                                .accessibilityHidden(true)
                        }

                        // Render item content
                        ElementView(element: item, hostConfig: hostConfig)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: Layout.minTouchTarget) // Minimum touch target
                    .padding(.vertical, Layout.itemVerticalPadding)
                }
            }
            .padding(.horizontal, listStyle != "default" ? 0 : Layout.itemSpacing)
        }
        .frame(maxHeight: maxHeightValue)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("List with \(list.items.count) items")
    }

    /// Parse maxHeight string (e.g., "200px") to CGFloat
    private func parseMaxHeight(_ maxHeight: String?) -> CGFloat? {
        guard let maxHeight = maxHeight else { return nil }

        // Remove "px" suffix and convert to number
        let numberString = maxHeight.replacingOccurrences(of: "px", with: "")
            .trimmingCharacters(in: .whitespaces)

        if let value = Double(numberString), value > 0 {
            return CGFloat(value)
        }

        return nil
    }
}
