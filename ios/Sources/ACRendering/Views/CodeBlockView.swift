import SwiftUI
import UIKit
import ACCore
import ACAccessibility

struct CodeBlockView: View {
    let codeBlock: CodeBlock
    let hostConfig: HostConfig
    
    @State private var showCopied = false
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with language and copy button
            HStack {
                if let language = codeBlock.language {
                    Text(language)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Programming language: \(language)")
                }
                
                Spacer()
                
                Button(action: copyToClipboard) {
                    HStack(spacing: 4) {
                        Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        Text(showCopied ? "Copied" : "Copy")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(showCopied ? "Code copied to clipboard" : "Copy code to clipboard")
                .accessibilityHint("Double tap to copy code")
                .accessibilityAddTraits(.isButton)
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            
            // Code content
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
<<<<<<< HEAD
                    ForEach(Array(codeLines.enumerated()), id: \.offset) { index, line in
=======
                    ForEach(Array(codeLines.enumerated()), id: \.element) { index, line in
>>>>>>> main
                        HStack(spacing: 8) {
                            if let startLine = codeBlock.startLineNumber {
                                Text("\(startLine + index)")
                                    .font(.system(adaptiveFontSize, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(minWidth: 30, alignment: .trailing)
                                    .accessibilityHidden(true)
                            }
                            
                            Text(line)
                                .font(.system(adaptiveFontSize, design: .monospaced))
                                .foregroundColor(.primary)
                                .lineLimit(codeBlock.wrap == true ? nil : 1)
                        }
                    }
                }
                .padding(8)
            }
            .background(backgroundColor)
            .cornerRadius(8)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Code block")
            .accessibilityValue(codeBlock.code)
            .accessibilityHint("Swipe right to scroll through code")
        }
        .spacing(codeBlock.spacing, hostConfig: hostConfig)
        .separator(codeBlock.separator, hostConfig: hostConfig)
    }
    
    private var codeLines: [String] {
        return codeBlock.code.components(separatedBy: .newlines)
    }
    
    private var backgroundColor: Color {
        return Color.gray.opacity(0.1)
    }
    
    private var adaptiveFontSize: CGFloat {
        if sizeCategory.isAccessibilityCategory {
            return 17  // Body size
        } else {
            switch sizeCategory {
            case .extraSmall, .small:
                return 12  // Caption size
            case .large, .extraLarge:
                return 17  // Body size
            default:
                return 15  // Callout size
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
        UIAccessibility.post(notification: .announcement, argument: "Code copied to clipboard")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopied = false
        }
    }
}
