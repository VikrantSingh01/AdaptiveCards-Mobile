import SwiftUI
import ACCore
import ACRendering

public struct TeamsCardHost<Content: View>: View {
    let card: AdaptiveCard
    let theme: TeamsTheme
    let tokenProvider: AuthTokenProvider?
    let deepLinkHandler: DeepLinkHandler
    let content: () -> Content
    
    @StateObject private var taskModulePresenter = TaskModulePresenter()
    @StateObject private var stageViewPresenter = StageViewPresenter()
    
    public init(
        card: AdaptiveCard,
        theme: TeamsTheme = .light,
        tokenProvider: AuthTokenProvider? = nil,
        deepLinkHandler: DeepLinkHandler = DeepLinkHandler(),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.card = card
        self.theme = theme
        self.tokenProvider = tokenProvider
        self.deepLinkHandler = deepLinkHandler
        self.content = content
    }
    
    public var body: some View {
        content()
            .preferredColorScheme(colorScheme)
            .sheet(isPresented: $taskModulePresenter.isPresented) {
                if let url = taskModulePresenter.url {
                    TaskModuleView(
                        url: url,
                        title: taskModulePresenter.title,
                        onDismiss: { taskModulePresenter.dismiss() }
                    )
                }
            }
            .fullScreenCover(isPresented: $stageViewPresenter.isPresented) {
                if let url = stageViewPresenter.url {
                    StageView(
                        url: url,
                        title: stageViewPresenter.title,
                        onDismiss: { stageViewPresenter.dismiss() }
                    )
                }
            }
    }
    
    private var colorScheme: ColorScheme? {
        switch theme {
        case .light:
            return .light
        case .dark, .highContrast:
            return .dark
        }
    }
}
