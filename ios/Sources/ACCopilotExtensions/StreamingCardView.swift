import SwiftUI
import ACCore

public struct StreamingCardView: View {
    public let streamingState: StreamingState
    public let partialContent: [CardElement]
    
    public init(streamingState: StreamingState, partialContent: [CardElement]) {
        self.streamingState = streamingState
        self.partialContent = partialContent
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(partialContent.enumerated()), id: \.offset) { _, element in
                Text("Element: \(element.type)")
                    .font(.body)
            }
            
            switch streamingState {
            case .idle:
                EmptyView()
            case .streaming:
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            case .complete:
                EmptyView()
            case .error(let error):
                Text("Error: \(error.localizedDescription)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
