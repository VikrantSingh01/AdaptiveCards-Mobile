import SwiftUI
import UIKit
import ACCore

struct CodeBlockView: View {
    let codeBlock: CodeBlock
    let hostConfig: HostConfig
    
    @State private var copySuccess = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }
    
    private var padding: CGFloat {
        isTablet ? 16 : 12
    }
    
    private var fontSize: CGFloat {
        isTablet ? 16 : 14
    }
    
    private var copyButtonSize: CGFloat {
        isTablet ? 36 : 32
    }
    
    private var lines: [String] {
        codeBlock.code.components(separatedBy: .newlines)
    }
    
    private var lineCount: Int {
        lines.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if let language = codeBlock.language {
                    Text(language.uppercased())
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: copyToClipboard) {
                    Image(systemName: copySuccess ? "checkmark" : "doc.on.doc")
                        .foregroundColor(.white)
                        .frame(width: copyButtonSize, height: copyButtonSize)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(6)
                }
                .accessibilityLabel("Copy code")
                .accessibilityHint("Double tap to copy code to clipboard")
                .accessibilityAddTraits(.isButton)
                .frame(minWidth: 44, minHeight: 44)
            }
            .padding(.horizontal, padding)
            .padding(.top, padding)
            
            ScrollView(.horizontal, showsIndicators: codeBlock.wrap != true) {
                HStack(alignment: .top, spacing: padding) {
                    if let startLine = codeBlock.startLineNumber {
                        VStack(alignment: .trailing, spacing: 2) {
                            ForEach(0..<lineCount, id: \.self) { index in
                                Text("\(startLine + index)")
                                    .font(.system(size: fontSize, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(.trailing, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(0..<lineCount, id: \.self) { index in
                            Text(lines[index])
                                .font(.system(size: fontSize, design: .monospaced))
                                .foregroundColor(.white)
                                .lineLimit(codeBlock.wrap == true ? nil : 1)
                        }
                    }
                }
                .padding(padding)
            }
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(codeBlock.language != nil ? "\(codeBlock.language!) code block" : "Code block")
        .accessibilityValue("\(lineCount) lines")
        .accessibilityHint("Contains code that can be copied")
    }
    
    private func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = codeBlock.code
        // Announce to VoiceOver
        UIAccessibility.post(notification: .announcement, argument: "Code copied to clipboard")
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(codeBlock.code, forType: .string)
        #endif
        
        copySuccess = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copySuccess = false
        }
    }
}
