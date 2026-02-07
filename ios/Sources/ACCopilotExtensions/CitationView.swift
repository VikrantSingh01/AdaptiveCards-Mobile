import SwiftUI

public struct CitationView: View {
    public let citation: Citation
    public let onTap: (() -> Void)?
    @State private var isExpanded = false
    
    public init(citation: Citation, onTap: (() -> Void)? = nil) {
        self.citation = citation
        self.onTap = onTap
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
                onTap?()
            }) {
                Text("[\(citation.index)]")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Text(citation.title)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    if let snippet = citation.snippet {
                        Text(snippet)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                    
                    if let url = citation.url {
                        Link(url, destination: URL(string: url)!)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)
            }
        }
    }
}
