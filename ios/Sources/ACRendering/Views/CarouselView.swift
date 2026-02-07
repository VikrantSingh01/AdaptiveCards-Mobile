import SwiftUI
import ACCore

struct CarouselView: View {
    let carousel: Carousel
    let hostConfig: HostConfig
    
    @State private var currentPage: Int
    @State private var timer: Timer?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    init(carousel: Carousel, hostConfig: HostConfig) {
        self.carousel = carousel
        self.hostConfig = hostConfig
        _currentPage = State(initialValue: carousel.initialPage ?? 0)
    }
    
    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }
    
    private var padding: CGFloat {
        isTablet ? 12 : 8
    }
    
    private var indicatorSize: CGFloat {
        isTablet ? 10 : 8
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(0..<carousel.pages.count, id: \.self) { index in
                    CarouselPageView(
                        page: carousel.pages[index],
                        hostConfig: hostConfig
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(minHeight: 200)
            
            HStack(spacing: padding) {
                ForEach(0..<carousel.pages.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.accentColor : Color.gray.opacity(0.4))
                        .frame(width: indicatorSize, height: indicatorSize)
                        .onTapGesture {
                            currentPage = index
                        }
                        .accessibilityHidden(true)
                }
            }
            .padding(.top, padding)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Carousel with \(carousel.pages.count) pages")
        .accessibilityValue("Page \(currentPage + 1) of \(carousel.pages.count)")
        .accessibilityHint("Swipe left or right to navigate between pages")
        .onAppear {
            startAutoAdvanceTimer()
        }
        .onDisappear {
            stopAutoAdvanceTimer()
        }
        .onChange(of: currentPage) { _ in
            restartAutoAdvanceTimer()
        }
    }
    
    private func startAutoAdvanceTimer() {
        guard let timerInterval = carousel.timer, timerInterval > 0 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timerInterval) / 1000.0, repeats: true) { _ in
            withAnimation {
                currentPage = (currentPage + 1) % carousel.pages.count
            }
        }
    }
    
    private func stopAutoAdvanceTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func restartAutoAdvanceTimer() {
        stopAutoAdvanceTimer()
        startAutoAdvanceTimer()
    }
}

private struct CarouselPageView: View {
    let page: CarouselPage
    let hostConfig: HostConfig
    
    @EnvironmentObject var viewModel: CardViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(page.items.enumerated()), id: \.offset) { _, item in
                if item.isVisible {
                    ElementView(element: item, hostConfig: hostConfig)
                }
            }
        }
    }
}
