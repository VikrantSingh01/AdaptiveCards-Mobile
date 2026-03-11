import SwiftUI
import ACCore
import ACRendering

struct TeamsSimulatorView: View {
    @State private var messages: [ChatMessage] = ChatMessage.sampleMessages
    @State private var messageText: String = ""
    @EnvironmentObject var actionLog: ActionLogStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Input bar
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 10) {
                        Menu {
                            Button { sendCard(.simple) } label: {
                                Label("Simple Card", systemImage: "doc.text")
                            }
                            Button { sendCard(.form) } label: {
                                Label("Form Card", systemImage: "list.clipboard")
                            }
                            Button { sendCard(.chart) } label: {
                                Label("Chart Card", systemImage: "chart.bar")
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }

                        TextField("Message...", text: $messageText)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(Color(.tertiarySystemFill))
                            )

                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundStyle(messageText.isEmpty ? Color(.tertiaryLabel) : .blue)
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Teams Simulator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { withAnimation { messages = [] } }) {
                        Image(systemName: "trash")
                            .font(.subheadline)
                    }
                    .disabled(messages.isEmpty)
                }
            }
        }
    }

    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        let message = ChatMessage(
            sender: "You",
            content: .text(messageText),
            isFromUser: true
        )
        withAnimation(.easeOut(duration: 0.2)) {
            messages.append(message)
        }
        messageText = ""
    }

    private func sendCard(_ type: CardType) {
        let message = ChatMessage(
            sender: "Bot",
            content: .card(type.json),
            isFromUser: false
        )
        withAnimation(.easeOut(duration: 0.2)) {
            messages.append(message)
        }
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    @EnvironmentObject var actionLog: ActionLogStore

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isFromUser { Spacer(minLength: 48) }

            if !message.isFromUser {
                // Avatar
                Circle()
                    .fill(Color.blue.gradient)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(message.sender.prefix(1)))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 3) {
                Text(message.sender)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                switch message.content {
                case .text(let text):
                    Text(text)
                        .font(.body)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            message.isFromUser
                                ? AnyShapeStyle(Color.blue.gradient)
                                : AnyShapeStyle(Color(.tertiarySystemFill))
                        )
                        .foregroundColor(message.isFromUser ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                case .card(let json):
                    AdaptiveCardView(cardJson: json, hostConfig: TeamsHostConfig.create())
                        .frame(maxWidth: 300)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                }

                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if message.isFromUser {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("Y")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    )
            }

            if !message.isFromUser { Spacer(minLength: 48) }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender: String
    let content: MessageContent
    let isFromUser: Bool
    let timestamp = Date()

    enum MessageContent {
        case text(String)
        case card(String)
    }

    static let sampleMessages: [ChatMessage] = [
        ChatMessage(sender: "Bot", content: .text("Welcome to Teams Simulator! Send messages or cards to test the chat experience."), isFromUser: false),
        ChatMessage(sender: "You", content: .text("Hello!"), isFromUser: true),
        ChatMessage(sender: "Bot", content: .card("""
            {
              "type": "AdaptiveCard",
              "version": "1.5",
              "body": [
                {
                  "type": "TextBlock",
                  "text": "Sample Card",
                  "size": "large",
                  "weight": "bolder"
                },
                {
                  "type": "TextBlock",
                  "text": "This is a sample adaptive card in a Teams-style chat.",
                  "wrap": true
                }
              ],
              "actions": [
                {
                  "type": "Action.Submit",
                  "title": "View Details"
                }
              ]
            }
            """), isFromUser: false)
    ]
}

enum CardType {
    case simple
    case form
    case chart

    var json: String {
        switch self {
        case .simple:
            return """
            {
              "type": "AdaptiveCard",
              "version": "1.5",
              "body": [
                {
                  "type": "TextBlock",
                  "text": "Quick Update",
                  "weight": "bolder",
                  "size": "large"
                },
                {
                  "type": "TextBlock",
                  "text": "This is a simple card for quick updates.",
                  "wrap": true
                }
              ]
            }
            """
        case .form:
            return """
            {
              "type": "AdaptiveCard",
              "version": "1.5",
              "body": [
                {
                  "type": "TextBlock",
                  "text": "Feedback Form",
                  "weight": "bolder"
                },
                {
                  "type": "Input.Text",
                  "id": "name",
                  "placeholder": "Your name"
                },
                {
                  "type": "Input.Text",
                  "id": "feedback",
                  "placeholder": "Your feedback",
                  "isMultiline": true
                }
              ],
              "actions": [
                {
                  "type": "Action.Submit",
                  "title": "Submit"
                }
              ]
            }
            """
        case .chart:
            return """
            {
              "type": "AdaptiveCard",
              "version": "1.5",
              "body": [
                {
                  "type": "TextBlock",
                  "text": "Sales Report",
                  "weight": "bolder"
                },
                {
                  "type": "TextBlock",
                  "text": "Chart placeholder - shows performance metrics",
                  "wrap": true
                }
              ]
            }
            """
        }
    }
}
