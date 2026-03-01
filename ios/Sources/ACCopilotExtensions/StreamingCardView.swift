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
            ForEach(partialContent) { element in
                Text("Element: \(element.typeString)")
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
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
