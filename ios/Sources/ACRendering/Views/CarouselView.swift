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
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .frame(minHeight: 200)
        .spacing(carousel.spacing, hostConfig: hostConfig)
        .separator(carousel.separator, hostConfig: hostConfig)
        .onAppear {
            setupAutoAdvance()
        }
        .onDisappear {
            timer?.invalidate()
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
