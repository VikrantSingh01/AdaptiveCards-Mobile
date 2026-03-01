import SwiftUI
import ACCore
import ACAccessibility

struct FactSetView: View {
    let factSet: FactSet
    let hostConfig: HostConfig

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(hostConfig.factSet.spacing)) {
            ForEach(factSet.facts) { fact in
                HStack(alignment: .top, spacing: 8) {
                    Text(fact.title)
                        .font(.system(size: fontSize(for: hostConfig.factSet.title.size)))
                        .fontWeight(titleWeight)
                        .frame(width: titleMaxWidth > 0 ? CGFloat(titleMaxWidth) : nil, alignment: .leading)
                    Text(fact.value)
                        .font(.system(size: fontSize(for: hostConfig.factSet.value.size)))
                        .fontWeight(valueWeight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .spacing(factSet.spacing, hostConfig: hostConfig)
        .separator(factSet.separator, hostConfig: hostConfig)
        .accessibilityContainer(label: "Fact Set")
    }

    private var titleMaxWidth: Int {
        hostConfig.factSet.title.maxWidth
    }

    private var titleWeight: Font.Weight {
        hostConfig.factSet.title.weight == "Bolder" ? .bold : .regular
    }

    private var valueWeight: Font.Weight {
        hostConfig.factSet.value.weight == "Bolder" ? .bold : .regular
    }

    private func fontSize(for sizeString: String) -> CGFloat {
        switch sizeString.lowercased() {
        case "small": return CGFloat(hostConfig.fontSizes.small)
        case "medium": return CGFloat(hostConfig.fontSizes.medium)
        case "large": return CGFloat(hostConfig.fontSizes.large)
        case "extralarge": return CGFloat(hostConfig.fontSizes.extraLarge)
        default: return CGFloat(hostConfig.fontSizes.`default`)
        }
    }
}
