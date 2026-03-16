// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
#if canImport(UIKit)
#if canImport(UIKit)
import UIKit
#endif
#endif
#if canImport(AppKit)
import AppKit
#endif
import ACCore
import ACAccessibility
import ACFluentUI

struct CodeBlockView: View {
    let codeBlock: CodeBlock
    let hostConfig: HostConfig

    @State private var showCopied = false
    @Environment(\.sizeCategory) var sizeCategory

    private static let darkBackground = Color(red: 0x1E / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0)
    private static let darkHeaderBackground = Color(red: 0x2D / 255.0, green: 0x2D / 255.0, blue: 0x30 / 255.0)
    private static let codeTextColor = Color(red: 0xD4 / 255.0, green: 0xD4 / 255.0, blue: 0xD4 / 255.0)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            codeContentView
        }
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(hostConfig.cornerRadius["container"] ?? 8)))
        .spacing(codeBlock.spacing, hostConfig: hostConfig)
        .separator(codeBlock.separator, hostConfig: hostConfig)
    }

    private var headerView: some View {
        HStack {
            if let language = codeBlock.language {
                Text(language.uppercased())
                    .font(.system(size: adaptiveFontSize, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .accessibilityLabel("Programming language: \(language)")
            }

            Spacer()

            Button(action: copyToClipboard) {
                Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                    .foregroundColor(.white.opacity(0.7))
                    .frame(minWidth: 32, minHeight: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(showCopied ? "Code copied to clipboard" : "Copy code to clipboard")
            .accessibilityHint("Double tap to copy code")
            .accessibilityAddTraits(.isButton)
        }
        .padding(.horizontal, CGFloat(hostConfig.spacing.small))
        .padding(.vertical, CGFloat(hostConfig.spacing.small))
        .background(Self.darkHeaderBackground)
    }

    private var codeContentView: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(codeLines.enumerated()), id: \.element) { index, line in
                    codeLineView(index: index, line: line)
                }
            }
            .padding(CGFloat(hostConfig.spacing.small))
        }
        .background(Self.darkBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Code block")
        .accessibilityValue(codeBlock.code)
        .accessibilityHint("Swipe right to scroll through code")
    }

    private func codeLineView(index: Int, line: String) -> some View {
        HStack(spacing: 8) {
            if let startLine = codeBlock.startLineNumber {
                Text("\(startLine + index)")
                    .font(.system(size: adaptiveFontSize, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(minWidth: 30, alignment: .trailing)
                    .accessibilityHidden(true)
            }

            highlightedText(line)
                .font(.system(size: adaptiveFontSize, design: .monospaced))
                .lineLimit(codeBlock.wrap == true ? nil : 1)
        }
    }

    private func highlightedText(_ line: String) -> Text {
        let tokens = SyntaxHighlighter.highlight(line: line, language: codeBlock.language)
        var result = Text("")
        for token in tokens {
            result = result + Text(token.text).foregroundColor(SyntaxColors.color(for: token.type))
        }
        return result
    }

    private var codeLines: [String] {
        return codeBlock.code.components(separatedBy: .newlines)
    }

    private var adaptiveFontSize: CGFloat {
        if sizeCategory.isAccessibilityCategory {
            return CGFloat(hostConfig.fontSizes.large)
        } else {
            switch sizeCategory {
            case .extraSmall, .small:
                return CGFloat(hostConfig.fontSizes.small)
            case .large, .extraLarge:
                return CGFloat(hostConfig.fontSizes.large)
            default:
                return CGFloat(hostConfig.fontSizes.default)
            }
        }
    }

    private func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = codeBlock.code
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(codeBlock.code, forType: .string)
        #endif

        showCopied = true

        // Announce to VoiceOver
        #if canImport(UIKit)
        UIAccessibility.post(notification: .announcement, argument: "Code copied to clipboard")
        #endif

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopied = false
        }
    }
}
