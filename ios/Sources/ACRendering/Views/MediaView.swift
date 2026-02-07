import SwiftUI
import ACCore
import ACAccessibility

struct MediaView: View {
    let media: Media
    let hostConfig: HostConfig
    
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            if let posterUrl = media.poster, let url = URL(string: posterUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            
            Button(action: {
                isPlaying = true
                // In a real implementation, this would play the media
            }) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
            }
        }
        .frame(height: 200)
        .spacing(media.spacing, hostConfig: hostConfig)
        .separator(media.separator, hostConfig: hostConfig)
        .accessibilityElement(label: media.altText ?? "Media")
        .accessibilityAddTraits(.startsMediaSession)
    }
}
