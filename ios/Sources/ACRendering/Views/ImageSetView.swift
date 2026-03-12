import SwiftUI
import ACCore
import ACAccessibility

struct ImageSetView: View {
    let imageSet: ImageSet
    let hostConfig: HostConfig

    var body: some View {
        Group {
            if imageSet.style == .stacked {
                stackedLayout
            } else {
                gridLayout
            }
        }
        .spacing(imageSet.spacing, hostConfig: hostConfig)
        .separator(imageSet.separator, hostConfig: hostConfig)
        .accessibilityContainer(label: "Image Set")
    }

    // MARK: - Grid layout (default)

    private var gridLayout: some View {
        LazyVGrid(columns: gridColumns, spacing: CGFloat(hostConfig.spacing.default)) {
            ForEach(imageSet.images, id: \.stableId) { image in
                ImageView(image: image, hostConfig: hostConfig)
                    .frame(maxHeight: CGFloat(hostConfig.imageSet.maxImageHeight))
                    .clipped()
            }
        }
    }

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: imageSize, maximum: imageSize))]
    }

    // MARK: - Stacked layout (overlapping horizontal)

    private var stackedLayout: some View {
        let overlapOffset = CGFloat(imageSet.offset ?? -20)
        let size = imageSize

        return HStack(spacing: 0) {
            ForEach(Array(imageSet.images.enumerated()), id: \.offset) { index, image in
                AsyncImage(url: URL(string: image.url)) { phase in
                    switch phase {
                    case .success(let img):
                        img
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    case .failure:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: size, height: size)
                    default:
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: size, height: size)
                    }
                }
                .zIndex(Double(imageSet.images.count - index))
                .padding(.leading, index == 0 ? 0 : overlapOffset)
            }
        }
    }

    // MARK: - Helpers

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
