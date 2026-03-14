// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import ACCore
import ACAccessibility

struct CarouselView: View {
    let carousel: Carousel
    let hostConfig: HostConfig
    var depth: Int = 0

    @State private var currentPage: Int
    @State private var timer: Timer?
    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.sizeCategory) var sizeCategory

    init(carousel: Carousel, hostConfig: HostConfig, depth: Int = 0) {
        self.carousel = carousel
        self.hostConfig = hostConfig
        self.depth = depth
        _currentPage = State(initialValue: carousel.initialPage ?? 0)
    }

    private var isTablet: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }

    private var visiblePages: [CarouselPage] {
        carousel.pages.filter { !$0.items.isEmpty }
    }

    var body: some View {
        let pages = visiblePages
        VStack(spacing: 0) {
            if !pages.isEmpty {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        CarouselPageView(page: page, hostConfig: hostConfig, isTablet: isTablet, depth: depth)
                            .tag(index)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Page \(index + 1) of \(pages.count)")
                    }
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                .frame(height: estimatedHeight)
            }

            // Custom page indicators — show when total carousel pages > 1
            if carousel.pages.count > 1 && !pages.isEmpty {
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? accentColor : Color.gray.opacity(0.5))
                            .frame(width: isTablet ? 10 : 8, height: isTablet ? 10 : 8)
                            .accessibilityLabel(index == currentPage ? "Current page \(index + 1)" : "Page \(index + 1)")
                    }
                }
                .padding(.vertical, isTablet ? 12 : 8)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Page indicator: \(currentPage + 1) of \(pages.count)")
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
            let clampedInitial = min(carousel.initialPage ?? 0, max(visiblePages.count - 1, 0))
            if clampedInitial > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    currentPage = clampedInitial
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
        // If carousel specifies heightInPixels, use it directly
        if let hpx = carousel.heightInPixels,
           let px = Int(hpx.replacingOccurrences(of: "px", with: "")) {
            let result = CGFloat(px)
            return sizeCategory.isAccessibilityCategory ? result * 1.3 : result
        }

        let pagePadding: CGFloat = isTablet ? 48 : 32 // inner + outer padding
        let maxPageContent = visiblePages.map { page -> CGFloat in
            estimatePageContentHeight(page)
        }.max() ?? 0

        let estimated = maxPageContent + pagePadding
        // Compact minimum — avoid excessive whitespace for small content
        let minimum: CGFloat = isTablet ? 160 : 100
        // Cap to prevent carousel from consuming all vertical space (leaves room for actions)
        #if canImport(UIKit)
        let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.65
        #else
        let maxHeight: CGFloat = 500
        #endif
        let result = min(max(estimated, minimum), maxHeight)

        if sizeCategory.isAccessibilityCategory {
            return result * 1.3
        }
        return result
    }

    /// Estimate content height for a single page based on element types.
    /// Uses conservative estimates to avoid excessive vertical whitespace.
    private func estimatePageContentHeight(_ page: CarouselPage) -> CGFloat {
        var height: CGFloat = 0
        let lineHeight: CGFloat = 20
        #if canImport(UIKit)
        let screenWidth = UIScreen.main.bounds.width
        #else
        let screenWidth: CGFloat = 375 // Fallback for non-UIKit platforms
        #endif
        let hPad: CGFloat = isTablet ? 80 : 48
        let contentWidth = screenWidth - hPad

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
                    // No explicit size: assume landscape 4:3 aspect ratio (not square)
                    height += contentWidth * 0.75
                }
            case .columnSet:
                height += 150
            case .container:
                height += lineHeight * 6
            case .factSet(let fs):
                height += CGFloat(fs.facts.count) * lineHeight
            case .imageSet:
                height += contentWidth * 0.4
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

        let pageCount = visiblePages.count
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timerInterval) / 1000.0, repeats: true) { _ in
            withAnimation {
                currentPage = (currentPage + 1) % pageCount
            }
        }
    }
}

struct CarouselPageView: View {
    let page: CarouselPage
    let hostConfig: HostConfig
    let isTablet: Bool
    var depth: Int = 0

    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.actionHandler) var actionHandler
    @Environment(\.actionDelegate) var actionDelegate

    var body: some View {
        VStack(spacing: 0) {
            ForEach(page.items) { element in
                if viewModel.isElementVisible(elementId: element.elementId) {
                    ElementView(element: element, hostConfig: hostConfig, depth: depth)
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
