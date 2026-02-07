import SwiftUI

public class StageViewPresenter: ObservableObject {
    @Published public var isPresented = false
    public var url: URL?
    public var title: String?
    
    public init() {}
    
    public func present(url: URL, title: String?) {
        self.url = url
        self.title = title
        self.isPresented = true
    }
    
    public func dismiss() {
        self.isPresented = false
    }
}

public struct StageView: View {
    let url: URL
    let title: String?
    let onDismiss: () -> Void
    
    public init(url: URL, title: String?, onDismiss: @escaping () -> Void) {
        self.url = url
        self.title = title
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        NavigationView {
            WebView(url: url)
                .navigationTitle(title ?? "Stage View")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            onDismiss()
                        }
                    }
                }
        }
    }
}
