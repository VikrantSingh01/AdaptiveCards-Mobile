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
    
    init(carousel: Carousel, hostConfig: HostConfig) {
        self.carousel = carousel
        self.hostConfig = hostConfig
        _currentPage = State(initialValue: carousel.initialPage ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(carousel.pages.enumerated()), id: \.offset) { index, page in
                    CarouselPageView(page: page, hostConfig: hostConfig)
                        .tag(index)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Page \(index + 1) of \(carousel.pages.count)")
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(minHeight: adaptiveMinHeight)
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
            setupAutoAdvance()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var adaptiveMinHeight: CGFloat {
        // Adjust height based on device size class
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            // iPad
            return 300
        } else {
            // iPhone
            return 200
        }
    }
    
    private func setupAutoAdvance() {
        guard let timerInterval = carousel.timer, timerInterval > 0 else {
            return
        }
        
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
    
    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(page.items.enumerated()), id: \.offset) { index, element in
                if viewModel.isElementVisible(elementId: element.id) {
                    ElementView(element: element, hostConfig: hostConfig)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .selectAction(page.selectAction) { action in
            actionHandler.handle(action, delegate: actionDelegate, viewModel: viewModel)
        }
    }
}
