import SwiftUI
import ACCore
import ACAccessibility

struct FactSetView: View {
    let factSet: FactSet
    let hostConfig: HostConfig
    
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(hostConfig.factSet.spacing)) {
            ForEach(Array(factSet.facts.enumerated()), id: \.offset) { index, fact in
                HStack(alignment: .top, spacing: 8) {
                    Text(fact.title)
                        .fontWeight(titleWeight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(fact.value)
                        .fontWeight(valueWeight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .spacing(factSet.spacing, hostConfig: hostConfig)
        .separator(factSet.separator, hostConfig: hostConfig)
        .accessibilityContainer(label: "Fact Set")
    }
    
    private var titleWeight: Font.Weight {
        hostConfig.factSet.title.weight == "Bolder" ? .bold : .regular
    }
    
    private var valueWeight: Font.Weight {
        hostConfig.factSet.value.weight == "Bolder" ? .bold : .regular
    }
}
