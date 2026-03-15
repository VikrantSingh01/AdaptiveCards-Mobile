// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore

/// Renders a Badge element as a styled pill/chip with optional icon and text.
struct BadgeView: View {
    let badge: Badge
    let hostConfig: HostConfig

    var body: some View {
        HStack(spacing: 4) {
            if badge.iconPosition?.lowercased() != "after", let iconName = badge.icon {
                Image(systemName: sfSymbolName(for: iconName))
                    .font(.system(size: fontSize))
            }
            if let text = badge.text, !text.isEmpty {
                Text(text)
                    .font(.system(size: fontSize, weight: .medium))
            }
            if badge.iconPosition?.lowercased() == "after", let iconName = badge.icon {
                Image(systemName: sfSymbolName(for: iconName))
                    .font(.system(size: fontSize))
            }
        }
        .foregroundColor(foregroundColor)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(backgroundColor)
        .clipShape(badgeShape)
        .overlay(
            badgeShape
                .stroke(strokeColor, lineWidth: isTint ? 1 : 0)
        )
        .fixedSize()
        .frame(
            maxWidth: badge.horizontalAlignment == nil ? nil : .infinity,
            alignment: alignment
        )
    }

    private var badgeShape: AnyShape {
        switch badge.shape?.lowercased() {
        case "square":
            return AnyShape(RoundedRectangle(cornerRadius: 4))
        case "rounded":
            return AnyShape(RoundedRectangle(cornerRadius: 8))
        default:
            return AnyShape(Capsule())
        }
    }

    private var isTint: Bool {
        badge.appearance?.lowercased() == "tint"
    }

    private var fontSize: CGFloat {
        switch badge.size?.lowercased() {
        case "small": return 10
        case "medium": return 12
        case "large": return 13
        default: return 12
        }
    }

    private var horizontalPadding: CGFloat {
        switch badge.size?.lowercased() {
        case "small": return 6
        case "large": return 10
        default: return 8
        }
    }

    private var verticalPadding: CGFloat {
        switch badge.size?.lowercased() {
        case "small": return 2
        case "large": return 5
        default: return 3
        }
    }

    private var badgeStyleVariants: BadgeStyleVariants {
        let styles = hostConfig.badgeStyles
        switch badge.style?.lowercased() {
        case "accent": return styles.accent
        case "attention": return styles.attention
        case "good": return styles.good
        case "informative": return styles.informative
        case "subtle": return styles.subtle
        case "warning": return styles.warning
        default: return styles.default
        }
    }

    private var badgeStyleDef: BadgeStyleDef {
        isTint ? badgeStyleVariants.tint : badgeStyleVariants.filled
    }

    private var foregroundColor: Color {
        Color(hex: badgeStyleDef.textColor)
    }

    private var backgroundColor: Color {
        Color(hex: badgeStyleDef.backgroundColor)
    }

    private var strokeColor: Color {
        Color(hex: badgeStyleDef.strokeColor)
    }

    private var alignment: Alignment {
        switch badge.horizontalAlignment?.lowercased() {
        case "center": return .center
        case "right": return .trailing
        default: return .leading
        }
    }

    private func sfSymbolName(for fluentName: String) -> String {
        let map: [String: String] = [
            "calendar": "calendar",
            "checkmarkcircle": "checkmark.circle",
            "errorcircle": "xmark.circle",
            "imagecircle": "photo.circle",
            "important": "exclamationmark.circle",
            "tag": "tag",
            "tooltipquote": "text.bubble",
            "warning": "exclamationmark.triangle",
            "clock": "clock",
            "people": "person.2",
            "arrowsync": "arrow.clockwise",
            "info": "info.circle",
            "flag": "flag",
            "star": "star",
            "heart": "heart",
            "error": "xmark.circle",
            "megaphone": "megaphone",
            "receipt": "doc.plaintext",
            "cart": "cart",
            "design": "pencil.and.ruler",
        ]
        return map[fluentName.lowercased()] ?? "circle.fill"
    }
}
