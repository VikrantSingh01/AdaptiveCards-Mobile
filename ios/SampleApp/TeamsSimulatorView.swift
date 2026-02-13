import SwiftUI

struct TeamsSimulatorView: View {
    @State private var messages: [ChatMessage] = ChatMessage.sampleMessages
    @State private var messageText: String = ""
    @EnvironmentObject var actionLog: ActionLogStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat messages
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubbleView(message: message)
                        }
                    }
                    .padding()
                }

                Divider()

                // Input bar
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(Color.blue))
                    }
                    .disabled(messageText.isEmpty)

                    Menu {
                        Button("Send Simple Card") {
                            sendCard(.simple)
                        }
                        Button("Send Form Card") {
                            sendCard(.form)
                        }
                        Button("Send Chart Card") {
                            sendCard(.chart)
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
                .padding()
            }
            .navigationTitle("Teams Simulator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        messages = []
                    }
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
        messages.append(message)
        messageText = ""
    }

    private func sendCard(_ type: CardType) {
        let message = ChatMessage(
            sender: "Bot",
            content: .card(type.json),
            isFromUser: false
        )
        messages.append(message)
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    @EnvironmentObject var actionLog: ActionLogStore

    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.sender)
                    .font(.caption)
                    .foregroundColor(.secondary)

                switch message.content {
                case .text(let text):
                    Text(text)
                        .padding(12)
                        .background(message.isFromUser ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(message.isFromUser ? .white : .primary)
                        .cornerRadius(16)

                case .card(let json):
                    CardPreviewPlaceholder(json: json)
                        .frame(maxWidth: 300)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }

                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !message.isFromUser { Spacer() }
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
