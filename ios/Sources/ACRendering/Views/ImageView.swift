// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
#if canImport(UIKit)
import UIKit
import WebKit
#endif
import ACCore
import ACAccessibility
import ACFluentUI

#if canImport(UIKit)
/// A SwiftUI wrapper that renders SVG content via WKWebView
private struct SVGWebView: UIViewRepresentable {
    let svgSource: String
    let width: CGFloat?
    let height: CGFloat?

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = UIColor.clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let w = width.map { "\(Int($0))px" } ?? "100%"
        let h = height.map { "\(Int($0))px" } ?? "auto"
        let bodyContent: String
        if svgSource.hasPrefix("data:image/svg+xml") {
            // For data URIs, decode and embed SVG inline for better rendering
            if let svgMarkup = decodeSVGDataURI(svgSource) {
                bodyContent = "<div style=\"width:\(w);height:\(h);max-width:100%\">\(svgMarkup)</div>"
            } else {
                bodyContent = "<img src=\"\(svgSource)\" style=\"width:\(w);height:\(h);max-width:100%\">"
            }
        } else {
            bodyContent = "<img src=\"\(svgSource)\" style=\"width:\(w);height:\(h);max-width:100%\">"
        }
        let html = """
        <html><head><meta name="viewport" content="width=device-width,initial-scale=1">
        <style>body{margin:0;padding:0;background:transparent;display:flex;align-items:center;justify-content:center}svg{max-width:100%;height:auto}</style></head>
        <body>\(bodyContent)</body></html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    private func decodeSVGDataURI(_ uri: String) -> String? {
        if uri.contains("base64,"), let base64Part = uri.components(separatedBy: "base64,").last {
            guard let data = Data(base64Encoded: base64Part),
                  let svg = String(data: data, encoding: .utf8) else { return nil }
            return svg
        }
        // URL-encoded SVG
        if uri.contains(","), let encodedPart = uri.components(separatedBy: ",").last {
            return encodedPart.removingPercentEncoding
        }
        return nil
    }
}
#endif

struct ImageView: View {
    let image: ACCore.Image
    let hostConfig: HostConfig

    @Environment(\.layoutDirection) var layoutDirection
    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        Group {
            if isSymbolUrl {
                // symbol: URLs are platform-specific; render as placeholder
                Color.clear.frame(width: imageWidth ?? 40, height: imageHeight ?? 40)
            } else if isSVG {
                svgView
            } else {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        if let w = imageWidth, let h = imageHeight {
                            ProgressView()
                                .frame(width: w, height: h)
                        } else if shouldFillWidth {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: 1)
                        } else if let w = imageWidth {
                            // Width known but height unknown: reserve space for loading
                            ProgressView()
                                .frame(width: w, height: w)
                        } else {
                            Color.clear
                                .frame(width: 0, height: 0)
                        }
                    case .success(let img):
                        if shouldFillWidth {
                            img
                                .resizable()
                                .aspectRatio(contentMode: fitModeContentMode ?? .fit)
                                .frame(maxWidth: .infinity, alignment: frameAlignment)
                                .clipped()
                                .clipShape(imageShape)
                        } else if let fitMode = fitModeContentMode, fitMode == .fill {
                            // Cover/fill: scale to fill the frame and clip overflow.
                            // Use medium image size as default when no explicit dimensions.
                            let w = imageWidth ?? CGFloat(hostConfig.imageSizes.medium)
                            let h = imageHeight ?? CGFloat(hostConfig.imageSizes.medium)
                            if isCoverMode {
                                // Cover: maintain aspect ratio, clip overflow (like Android Crop)
                                img
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: w, height: h)
                                    .clipped()
                                    .clipShape(imageShape)
                            } else {
                                // Fill: stretch to fill bounds (like Android FillBounds)
                                img
                                    .resizable()
                                    .frame(width: w, height: h)
                                    .clipShape(imageShape)
                            }
                        } else {
                            img
                                .resizable()
                                .aspectRatio(contentMode: aspectRatio)
                                .frame(width: imageWidth, height: imageHeight)
                                .clipShape(imageShape)
                        }
                    case .failure:
                        Color.clear
                            .frame(width: 0, height: 0)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .background(backgroundColorValue)
        .selectAction(image.selectAction) { action in
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
        .frame(maxWidth: shouldFillWidth ? .infinity : nil, alignment: frameAlignment)
        .spacing(image.spacing, hostConfig: hostConfig)
        .separator(image.separator, hostConfig: hostConfig)
        .accessibilityElement(label: image.altText ?? "Image")
    }

    // MARK: - SVG Detection & Rendering

    /// True if the URL is SVG content (data URI or .svg URL)
    private var isSVG: Bool {
        image.url.hasPrefix("data:image/svg+xml") || {
            guard let url = URL(string: image.url) else { return false }
            return url.pathExtension.lowercased() == "svg"
        }()
    }

    /// True if the URL uses the symbol: scheme
    private var isSymbolUrl: Bool {
        image.url.hasPrefix("symbol:")
    }

    @ViewBuilder
    private var svgView: some View {
        #if canImport(UIKit)
        SVGWebView(
            svgSource: image.url,
            width: imageWidth,
            height: imageHeight
        )
        .frame(
            width: imageWidth ?? (shouldFillWidth ? nil : 100),
            height: imageHeight ?? (shouldFillWidth ? 200 : 100)
        )
        .frame(maxWidth: shouldFillWidth ? .infinity : nil)
        .clipShape(imageShape)
        #else
        // Fallback for non-UIKit platforms: show placeholder
        Color.clear.frame(width: imageWidth ?? 100, height: imageHeight ?? 100)
        #endif
    }

    // MARK: - Sizing

    private var imageURL: URL? {
        guard let url = URL(string: image.url) else { return nil }
        if image.forceLoad == true {
            // Append cache-busting parameter to bypass URL cache
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            var queryItems = components?.queryItems ?? []
            queryItems.append(URLQueryItem(name: "_t", value: "\(Date().timeIntervalSince1970)"))
            components?.queryItems = queryItems
            return components?.url ?? url
        }
        return url
    }

    private var backgroundColorValue: Color {
        if let bgColor = image.backgroundColor, !bgColor.isEmpty {
            return Color(hex: bgColor)
        }
        return .clear
    }

    /// Whether the image should fill available width (matching Android FillWidth behavior)
    private var shouldFillWidth: Bool {
        // Fill container width when no explicit size/width/height AND no fitMode.
        // Images with fitMode (cover/fill) should respect their explicit or default
        // dimensions rather than expanding to fill the entire viewport.
        image.size == nil && image.width == nil && image.height == nil && image.fitMode == nil
    }

    /// Maps fitMode JSON string to SwiftUI ContentMode
    /// "cover" scales to fill frame (maintaining aspect ratio, clipping overflow)
    /// "fill" stretches to fill frame (may distort aspect ratio)
    /// "contain" scales to fit within frame (maintaining aspect ratio)
    private var fitModeContentMode: ContentMode? {
        guard let fitMode = image.fitMode?.lowercased() else { return nil }
        switch fitMode {
        case "cover", "fill":
            return .fill
        case "contain":
            return .fit
        default:
            return nil
        }
    }

    /// Whether this image has a cover fitMode (needs clipping, not stretching)
    private var isCoverMode: Bool {
        image.fitMode?.lowercased() == "cover"
    }

    private var imageWidth: CGFloat? {
        if let width = image.width {
            if width.lowercased() == "auto" { return nil }
            let stripped = width.replacingOccurrences(of: "px", with: "")
            if let value = Int(stripped), value > 0 { return CGFloat(value) }
            return nil
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
            // "auto" means let the image determine its natural height
            if height.lowercased() == "auto" { return nil }
            let stripped = height.replacingOccurrences(of: "px", with: "")
            if let value = Int(stripped), value > 0 { return CGFloat(value) }
            return nil
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
        switch image.style {
        case .person:
            return AnyShape(Circle())
        case .roundedCorners:
            return AnyShape(RoundedRectangle(cornerRadius: 8))
        default:
            let radius = CGFloat(hostConfig.cornerRadius["image"] ?? 0)
            return AnyShape(RoundedRectangle(cornerRadius: radius))
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
