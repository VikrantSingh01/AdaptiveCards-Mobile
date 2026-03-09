import SwiftUI

public struct CopilotReferenceView: View {
    public let reference: Reference

    public init(reference: Reference) {
        self.reference = reference
    }

    public var body: some View {
        HStack(spacing: 12) {
            if let iconUrl = reference.iconUrl {
                AsyncImage(url: URL(string: iconUrl)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: iconName)
                        .foregroundColor(.secondary)
                }
                .frame(width: 24, height: 24)
            } else {
                Image(systemName: iconName)
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(reference.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let snippet = reference.snippet {
                    Text(snippet)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                if let url = reference.url {
                    Text(url)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }

    private var iconName: String {
        switch reference.type {
        case .file:
            return "doc.fill"
        case .url:
            return "link"
        case .document:
            return "doc.text.fill"
        case .email:
            return "envelope.fill"
        case .meeting:
            return "calendar"
        case .person:
            return "person.fill"
        case .message:
            return "message.fill"
        }
    }
}
