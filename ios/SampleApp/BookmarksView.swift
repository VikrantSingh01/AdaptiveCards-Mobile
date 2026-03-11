import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject var bookmarks: BookmarkStore
    private let allCards: [TestCard] = TestCardLoader.loadAllCards()

    var bookmarkedCards: [TestCard] {
        allCards.filter { bookmarks.isBookmarked($0.filename) }
    }

    var body: some View {
        List {
            if bookmarkedCards.isEmpty {
                ContentUnavailableView(
                    "No Bookmarks",
                    systemImage: "bookmark",
                    description: Text("Swipe right on a card in the Gallery or tap the bookmark icon in the detail view to add favorites.")
                )
            } else {
                ForEach(bookmarkedCards) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.title)
                                .font(.headline)
                            Text(card.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            bookmarks.toggle(card.filename)
                        } label: {
                            Label("Remove", systemImage: "bookmark.slash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Bookmarks")
    }
}
