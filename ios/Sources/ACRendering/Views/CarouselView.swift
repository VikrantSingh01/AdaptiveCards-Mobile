import SwiftUI
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
            .frame(minHeight: adaptiveMinHeight)

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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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

    private var adaptiveMinHeight: CGFloat {
        let baseHeight: CGFloat
        if isTablet {
            baseHeight = 300
        } else {
            baseHeight = 200
        }

        if sizeCategory.isAccessibilityCategory {
            return baseHeight * 1.3
        }
        return baseHeight
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
        .frame(maxWidth: .infinity)
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
