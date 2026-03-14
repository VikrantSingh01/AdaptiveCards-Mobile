// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore
import ACFluentUI

// MARK: - Progress Bar View

struct ProgressBarView: View {
    let progressBar: ProgressBar
    let hostConfig: HostConfig

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory

    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }

    private var barHeight: CGFloat {
        isTablet ? 10 : 8
    }

    private var labelFont: Font {
        isTablet ? .body : .subheadline
    }

    private var progressColor: Color {
        guard let colorString = progressBar.color else {
            return Color(hex: hostConfig.containerStyles.default.foregroundColors.accent.default)
        }
        let fg = hostConfig.containerStyles.default.foregroundColors
        switch colorString.lowercased() {
        case "default": return Color(hex: fg.default.default)
        case "dark": return Color(hex: fg.dark.default)
        case "light": return Color(hex: fg.light.default)
        case "accent": return Color(hex: fg.accent.default)
        case "good", "green": return Color(hex: fg.good.default)
        case "warning", "yellow": return Color(hex: fg.warning.default)
        case "attention", "red": return Color(hex: fg.attention.default)
        default: return Color(hex: colorString)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(hostConfig.spacing.small)) {
            if let label = progressBar.label {
                HStack {
                    Text(label)
                        .font(labelFont)
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(Int(progressBar.normalizedValue * 100))%")
                        .font(labelFont)
                        .foregroundColor(.secondary)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(hex: hostConfig.containerStyles.emphasis.backgroundColor))
                        .frame(height: barHeight)

                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * CGFloat(progressBar.normalizedValue), height: barHeight)
                }
            }
            .frame(height: barHeight)
            .cornerRadius(barHeight / 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(progressBar.label ?? "Progress")
        .accessibilityValue("\(Int(progressBar.normalizedValue * 100)) percent")
    }
}

// MARK: - Progress Ring View

struct ProgressRingView: View {
    let progressRing: ProgressRing
    let hostConfig: HostConfig

    @Environment(\.layoutDirection) var layoutDirection

    private var ringSize: CGFloat {
        switch progressRing.size?.lowercased() {
        case "tiny": return 16
        case "small": return 24
        case "large": return 48
        default: return 32
        }
    }

    private var lineWidth: CGFloat {
        switch progressRing.size?.lowercased() {
        case "tiny": return 2
        case "small": return 3
        case "large": return 5
        default: return 4
        }
    }

    private var ringColor: Color {
        guard let colorString = progressRing.color else {
            return Color(hex: hostConfig.containerStyles.default.foregroundColors.accent.default)
        }
        let fg = hostConfig.containerStyles.default.foregroundColors
        switch colorString.lowercased() {
        case "default": return Color(hex: fg.default.default)
        case "dark": return Color(hex: fg.dark.default)
        case "light": return Color(hex: fg.light.default)
        case "accent": return Color(hex: fg.accent.default)
        case "good", "green": return Color(hex: fg.good.default)
        case "warning", "yellow": return Color(hex: fg.warning.default)
        case "attention", "red": return Color(hex: fg.attention.default)
        default: return Color(hex: colorString)
        }
    }

    private var frameAlignment: Alignment {
        .from(
            horizontal: progressRing.horizontalAlignment,
            vertical: nil,
            layoutDirection: layoutDirection
        )
    }

    var body: some View {
        let labelPosition = progressRing.labelPosition?.lowercased() ?? "above"
        let ringContent = IndeterminateRing(color: ringColor, size: ringSize, lineWidth: lineWidth)

        Group {
            switch labelPosition {
            case "below":
                VStack(spacing: CGFloat(hostConfig.spacing.small)) {
                    ringContent
                    labelText
                }
            case "before":
                HStack(spacing: CGFloat(hostConfig.spacing.small)) {
                    labelText
                    ringContent
                }
            case "after":
                HStack(spacing: CGFloat(hostConfig.spacing.small)) {
                    ringContent
                    labelText
                }
            default:
                VStack(spacing: CGFloat(hostConfig.spacing.small)) {
                    labelText
                    ringContent
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: frameAlignment)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(progressRing.label ?? "Loading")
        .accessibilityValue("In progress")
    }

    @ViewBuilder
    private var labelText: some View {
        if let label = progressRing.label {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

private struct IndeterminateRing: View {
    let color: Color
    let size: CGFloat
    let lineWidth: CGFloat

    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.75)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear { isAnimating = true }
    }
}

// MARK: - Spinner View

struct SpinnerView: View {
    let spinner: Spinner
    let hostConfig: HostConfig

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory

    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }

    private var spinnerSize: CGFloat {
        let baseSize: CGFloat
        switch spinner.size {
        case .small:
            baseSize = 24
        case .large:
            baseSize = 56
        default:
            baseSize = 40
        }
        return isTablet ? baseSize + 8 : baseSize
    }

    private var labelFont: Font {
        isTablet ? .body : .subheadline
    }

    var body: some View {
        VStack(spacing: CGFloat(hostConfig.spacing.default)) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(spinnerSize / 20)
                .frame(width: spinnerSize, height: spinnerSize)

            if let label = spinner.label {
                Text(label)
                    .font(labelFont)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spinner.label ?? "Loading")
        .accessibilityValue("In progress")
    }
}
