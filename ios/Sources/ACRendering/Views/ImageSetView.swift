import SwiftUI
import ACCore
import ACAccessibility

struct ImageSetView: View {
    let imageSet: ImageSet
    let hostConfig: HostConfig

    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: CGFloat(hostConfig.spacing.small)) {
            ForEach(imageSet.images, id: \.stableId) { image in
                ImageView(image: image, hostConfig: hostConfig)
            }
        }
        .spacing(imageSet.spacing, hostConfig: hostConfig)
        .separator(imageSet.separator, hostConfig: hostConfig)
        .accessibilityContainer(label: "Image Set")
    }

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: imageSize, maximum: imageSize))]
    }

    private var imageSize: CGFloat {
        let sizeEnum = imageSet.imageSize ?? .medium

        switch sizeEnum {
        case .auto, .stretch:
            return CGFloat(hostConfig.imageSizes.medium)
        case .small:
            return CGFloat(hostConfig.imageSizes.small)
        case .medium:
            return CGFloat(hostConfig.imageSizes.medium)
        case .large:
            return CGFloat(hostConfig.imageSizes.large)
        }
    }
}
