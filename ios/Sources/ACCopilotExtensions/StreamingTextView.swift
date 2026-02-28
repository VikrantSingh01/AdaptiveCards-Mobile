import SwiftUI
import ACCore

// MARK: - StreamingTextView

/// A SwiftUI view that renders streaming text with a typing animation effect.
///
/// Ported from production Teams-AdaptiveCards-Mobile SDK's StreamingTextView.
/// Progressively reveals text character by character with a blinking cursor,
/// supporting configurable typing speed and cursor styles.
@available(iOS 15.0, *)
public struct StreamingTextView: View {
    public let content: StreamingContent
    public var onStopStreaming: (() -> Void)?
    public var hostConfig: HostConfig?

    @State private var displayedCharacterCount: Int = 0
    @State private var isAnimating: Bool = false
    @State private var cursorVisible: Bool = true

    /// Characters per second for typing animation
    private var charsPerSecond: Double {
        content.typingSpeed ?? 40.0
    }

    public init(
        content: StreamingContent,
        onStopStreaming: (() -> Void)? = nil,
        hostConfig: HostConfig? = nil
    ) {
        self.content = content
        self.onStopStreaming = onStopStreaming
        self.hostConfig = hostConfig
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Streaming text with cursor
            textContent

            // Controls
            if content.streamingPhase == .streaming {
                streamingControls
            }
        }
        .onAppear {
            startTypingAnimation()
        }
        .onChange(of: content.content) { _ in
            startTypingAnimation()
        }
    }

    // MARK: - Text Content

    @ViewBuilder
    private var textContent: some View {
        let visibleText = String(content.content.prefix(displayedCharacterCount))
        let isStreaming = !content.isComplete && content.streamingPhase == .streaming

        HStack(alignment: .bottom, spacing: 0) {
            Text(visibleText)
                .font(textFont)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Blinking cursor
            if isStreaming && displayedCharacterCount < content.content.count {
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 2, height: 16)
                    .opacity(cursorVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: cursorVisible)
                    .onAppear { cursorVisible.toggle() }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Streaming Controls

    @ViewBuilder
    private var streamingControls: some View {
        HStack(spacing: 12) {
            if content.showProgressIndicator ?? true {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.8)
            }

            if content.showStopButton ?? false, let onStop = onStopStreaming {
                Button(action: onStop) {
                    HStack(spacing: 4) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 14))
                        Text("Stop")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
    }

    // MARK: - Animation

    private func startTypingAnimation() {
        guard !isAnimating else { return }
        isAnimating = true

        let totalChars = content.content.count
        let initialCount = displayedCharacterCount

        guard initialCount < totalChars else {
            isAnimating = false
            return
        }

        Timer.scheduledTimer(withTimeInterval: 1.0 / charsPerSecond, repeats: true) { timer in
            if displayedCharacterCount < totalChars {
                displayedCharacterCount += 1
            } else {
                timer.invalidate()
                isAnimating = false
            }
        }
    }

    private var textFont: Font {
        if let config = hostConfig {
            let size = CGFloat(config.fontTypes.defaultFont.fontSizes?.default ?? 14)
            return .system(size: size)
        }
        return .body
    }
}
