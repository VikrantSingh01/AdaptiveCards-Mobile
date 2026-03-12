import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import ACCore
import ACAccessibility

struct CarouselView: View {
    let carousel: Carousel
    let hostConfig: HostConfig

    @State private var currentPage: Int
    @State private var timer: Timer?
    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.sizeCategory) var sizeCategory

    init(carousel: Carousel, hostConfig: HostConfig) {
        self.carousel = carousel
        self.hostConfig = hostConfig
        _currentPage = State(initialValue: carousel.initialPage ?? 0)
    }

    private var isTablet: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(carousel.pages.enumerated()), id: \.offset) { index, page in
                    CarouselPageView(page: page, hostConfig: hostConfig, isTablet: isTablet)
                        .tag(index)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Page \(index + 1) of \(carousel.pages.count)")
                }
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
            .frame(height: estimatedHeight)

            // Custom page indicators (matching Android accent-colored dots)
            if carousel.pages.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<carousel.pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? accentColor : Color.gray.opacity(0.5))
                            .frame(width: isTablet ? 10 : 8, height: isTablet ? 10 : 8)
                            .accessibilityLabel(index == currentPage ? "Current page \(index + 1)" : "Page \(index + 1)")
                    }
                }
                .padding(.vertical, isTablet ? 12 : 8)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Page indicator: \(currentPage + 1) of \(carousel.pages.count)")
            }
        }
        .spacing(carousel.spacing, hostConfig: hostConfig)
        .separator(carousel.separator, hostConfig: hostConfig)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Carousel")
        .accessibilityHint("Swipe left or right to navigate between pages")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                if currentPage < carousel.pages.count - 1 {
                    currentPage += 1
                }
            case .decrement:
                if currentPage > 0 {
                    currentPage -= 1
                }
            @unknown default:
                break
            }
        }
        .onAppear {
            // Ensure initialPage is applied after TabView renders
            let initialPage = carousel.initialPage ?? 0
            if initialPage > 0 && initialPage < carousel.pages.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // safe: struct View, no retain cycle
                    currentPage = initialPage
                }
            }
            setupAutoAdvance()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private var accentColor: Color {
        Color(hex: hostConfig.containerStyles.default.foregroundColors.accent.default)
    }

    /// Estimate the carousel height based on page content analysis.
    /// TabView with .page style doesn't intrinsically size to content, so we compute a
    /// reasonable height based on the element types present in each page.
    private var estimatedHeight: CGFloat {
        let pagePadding: CGFloat = isTablet ? 64 : 48 // inner + outer padding
        let maxPageContent = carousel.pages.map { page -> CGFloat in
            estimatePageContentHeight(page)
        }.max() ?? 0

        let estimated = maxPageContent + pagePadding
        let minimum: CGFloat = isTablet ? 300 : 200
        let result = max(estimated, minimum)

        if sizeCategory.isAccessibilityCategory {
            return result * 1.3
        }
        return result
    }

    /// Estimate content height for a single page based on element types.
    /// For images without explicit dimensions, assume square aspect ratio at full content
    /// width so the TabView frame is tall enough for the image to fill the page.
    private func estimatePageContentHeight(_ page: CarouselPage) -> CGFloat {
        var height: CGFloat = 0
        let lineHeight: CGFloat = 20
        // Full-width image height ≈ screen width minus horizontal padding (page + content)
        #if canImport(UIKit)
        let screenWidth = UIScreen.main.bounds.width
        #else
        let screenWidth: CGFloat = 375 // Fallback for non-UIKit platforms
        #endif
        let hPad: CGFloat = isTablet ? 80 : 48 // (8+16)*2 phone, (16+24)*2 tablet
        let fullWidthImageHeight = screenWidth - hPad

        for item in page.items {
            switch item {
            case .textBlock:
                height += lineHeight * 2
            case .image(let img):
                if let h = img.height, let px = Int(h.replacingOccurrences(of: "px", with: "")) {
                    height += CGFloat(px)
                } else if img.size == .small {
                    height += CGFloat(hostConfig.imageSizes.small)
                } else if img.size == .medium {
                    height += CGFloat(hostConfig.imageSizes.medium)
                } else if img.size == .large {
                    height += CGFloat(hostConfig.imageSizes.large)
                } else {
                    // No explicit size: image fills width → assume square aspect ratio
                    height += fullWidthImageHeight
                }
            case .columnSet:
                height += 150
            case .container:
                height += lineHeight * 6
            case .factSet(let fs):
                height += CGFloat(fs.facts.count) * lineHeight
            case .imageSet:
                height += fullWidthImageHeight * 0.5
            default:
                height += lineHeight * 2
            }
        }
        return height
    }

    private func setupAutoAdvance() {
        guard let timerInterval = carousel.timer, timerInterval > 0 else {
            return
        }

        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timerInterval) / 1000.0, repeats: true) { _ in
            withAnimation {
                currentPage = (currentPage + 1) % carousel.pages.count
            }
        }
    }
}

struct CarouselPageView: View {
    let page: CarouselPage
    let hostConfig: HostConfig
    let isTablet: Bool

    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate

    var body: some View {
        VStack(spacing: 0) {
            ForEach(page.items) { element in
                if viewModel.isElementVisible(elementId: element.elementId) {
                    ElementView(element: element, hostConfig: hostConfig)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .padding(.all, isTablet ? 24 : 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: hostConfig.containerStyles.emphasis.backgroundColor))
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, isTablet ? 16 : 8)
        .padding(.vertical, 8)
        .selectAction(page.selectAction) { action in
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
    }
}
