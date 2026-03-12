import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject var bookmarks: BookmarkStore
    private let allCards: [TestCard] = TestCardLoader.loadAllCards()

    var bookmarkedCards: [TestCard] {
        allCards.filter { bookmarks.isBookmarked($0.filename) }
    }

    var body: some View {
        Group {
            if bookmarkedCards.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "bookmark")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text("No Bookmarks")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Swipe right on a card in the Gallery\nor tap the bookmark icon to save favorites.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(bookmarkedCards) { card in
                        NavigationLink(destination: CardDetailView(card: card)) {
                            HStack(spacing: 14) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(card.category.color.gradient)
                                    .frame(width: 4, height: 36)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(card.title)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Text(card.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    bookmarks.toggle(card.filename)
                                }
                            } label: {
                                Label("Remove", systemImage: "bookmark.slash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Bookmarks")
    }
}
