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
                        .font(.system(size: CGFloat(resolveFontSize(hostConfig.factSet.title.size))))
                        .fontWeight(titleWeight)
                        .frame(width: titleMaxWidth > 0 ? CGFloat(titleMaxWidth) : nil, alignment: .leading)
                    Text(fact.value)
                        .font(.system(size: CGFloat(resolveFontSize(hostConfig.factSet.value.size))))
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

    private func resolveFontSize(_ sizeString: String) -> Int {
        switch sizeString.lowercased() {
        case "small": return hostConfig.fontSizes.small
        case "medium": return hostConfig.fontSizes.medium
        case "large": return hostConfig.fontSizes.large
        case "extralarge": return hostConfig.fontSizes.extraLarge
        default: return hostConfig.fontSizes.`default`
        }
    }
}
