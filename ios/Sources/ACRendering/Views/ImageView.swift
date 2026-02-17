import SwiftUI
import ACCore
import ACAccessibility
import ACFluentUI

struct ImageView: View {
    let image: ACCore.Image
    let hostConfig: HostConfig

    @Environment(\.layoutDirection) var layoutDirection
    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        AsyncImage(url: URL(string: image.url)) { phase in
            switch phase {
            case .empty:
                Color.clear
                    .frame(width: imageWidth ?? 0, height: imageHeight ?? 0)
            case .success(let img):
                img
                    .resizable()
                    .aspectRatio(contentMode: aspectRatio)
                    .frame(width: imageWidth, height: imageHeight)
                    .clipShape(imageShape)
            case .failure:
                Image(systemName: "photo")
                    .frame(width: imageWidth, height: imageHeight)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
        .background(backgroundColorValue)
        .frame(maxWidth: .infinity, alignment: frameAlignment)
        .spacing(image.spacing, hostConfig: hostConfig)
        .separator(image.separator, hostConfig: hostConfig)
        .selectAction(image.selectAction) { action in
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
        .accessibilityElement(label: image.altText ?? "Image")
    }

    private var backgroundColorValue: Color {
        if let bgColor = image.backgroundColor, !bgColor.isEmpty {
            return Color(hex: bgColor)
        }
        return .clear
    }

    private var imageWidth: CGFloat? {
        if let width = image.width {
            return CGFloat(Int(width) ?? 0)
        }

        if let size = image.size {
            switch size {
            case .auto:
                return nil
            case .stretch:
                return nil
            case .small:
                return CGFloat(hostConfig.imageSizes.small)
            case .medium:
                return CGFloat(hostConfig.imageSizes.medium)
            case .large:
                return CGFloat(hostConfig.imageSizes.large)
            }
        }

        return nil
    }

    private var imageHeight: CGFloat? {
        if let height = image.height {
            return CGFloat(Int(height) ?? 0)
        }
        return nil
    }

    private var aspectRatio: ContentMode {
        if let size = image.size {
            return size == .stretch ? .fill : .fit
        }
        return .fit
    }

    private var imageShape: AnyShape {
        if image.style == .person {
            return AnyShape(Circle())
        } else {
            return AnyShape(Rectangle())
        }
    }

    private var frameAlignment: Alignment {
        .from(
            horizontal: image.horizontalAlignment,
            vertical: nil,
            layoutDirection: layoutDirection
        )
    }
}
