// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore

/// Streaming card view with fade-in animation for each element.
///
/// By default renders element type labels. Hosts should provide a custom
/// `elementRenderer` view builder that delegates to `ElementView` from ACRendering
/// for full card element rendering.
public struct StreamingCardView: View {
    public let streamingState: StreamingState
    public let partialContent: [CardElement]
    public let elementRenderer: ((CardElement) -> AnyView)?

    public init(
        streamingState: StreamingState,
        partialContent: [CardElement],
        elementRenderer: ((CardElement) -> AnyView)? = nil
    ) {
        self.streamingState = streamingState
        self.partialContent = partialContent
        self.elementRenderer = elementRenderer
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(partialContent) { element in
                Group {
                    if let renderer = elementRenderer {
                        renderer(element)
                    } else {
                        Text("Element: \(element.typeString)")
                            .font(.body)
                    }
                }
                .transition(.opacity)
            }
            .animation(.easeIn(duration: 0.3), value: partialContent.count)

            switch streamingState {
            case .idle:
                EmptyView()
            case .streaming:
                HStack(spacing: 6) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.7)
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .transition(.opacity)
            case .complete:
                EmptyView()
            case .error(let message):
                Text("Error: \(message)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
