import SwiftUI
import ACCore
import ACAccessibility

struct ListView: View {
    let list: ListElement
    let hostConfig: HostConfig
    
    @EnvironmentObject var viewModel: CardViewModel
    
    var body: some View {
        let maxHeightValue = parseMaxHeight(list.maxHeight)
        let listStyle = list.style ?? "default"
        
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(list.items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 8) {
                        // Render list item prefix based on style
                        if listStyle == "bulleted" {
                            Text("•")
                                .font(.system(size: 18))
                                .foregroundColor(.primary)
                                .frame(width: 20, alignment: .leading)
                                .accessibilityHidden(true)
                        } else if listStyle == "numbered" {
                            Text("\(index + 1).")
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .frame(width: 24, alignment: .leading)
                                .accessibilityHidden(true)
                        }
                        
                        // Render item content
                        ElementView(element: item, hostConfig: hostConfig)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 44) // Minimum touch target
                    .padding(.vertical, 4)
                }
            }
            .padding(.horizontal, listStyle != "default" ? 0 : 8)
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
