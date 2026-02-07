import SwiftUI
import ACCore
import ACAccessibility

struct CodeBlockView: View {
    let codeBlock: CodeBlock
    let hostConfig: HostConfig
    
    @State private var showCopied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with language and copy button
            HStack {
                if let language = codeBlock.language {
                    Text(language)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: copyToClipboard) {
                    HStack(spacing: 4) {
                        Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        Text(showCopied ? "Copied" : "Copy")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            
            // Code content
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(codeLines.enumerated()), id: \.offset) { index, line in
                        HStack(spacing: 8) {
                            if let startLine = codeBlock.startLineNumber {
                                Text("\(startLine + index)")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(minWidth: 30, alignment: .trailing)
                            }
                            
                            Text(line)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(8)
            }
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .spacing(codeBlock.spacing, hostConfig: hostConfig)
        .separator(codeBlock.separator, hostConfig: hostConfig)
    }
    
    private var codeLines: [String] {
        if codeBlock.wrap == true {
            // For wrapped code, we still split by lines but let SwiftUI handle wrapping
            return codeBlock.code.components(separatedBy: .newlines)
        } else {
            return codeBlock.code.components(separatedBy: .newlines)
        }
    }
    
    private var backgroundColor: Color {
        return Color.gray.opacity(0.1)
    }
    
    private func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = codeBlock.code
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(codeBlock.code, forType: .string)
        #endif
        
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopied = false
        }
    }
}
