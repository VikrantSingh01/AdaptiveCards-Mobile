import SwiftUI
import WebKit

public class TaskModulePresenter: NSObject, ObservableObject {
    @Published public var isPresented = false
    public var url: URL?
    public var title: String?

    public override init() {
        super.init()
    }

    public func present(url: URL, title: String?) {
        self.url = url
        self.title = title
        self.isPresented = true
    }

    public func dismiss() {
        self.isPresented = false
    }
}

public struct TaskModuleView: View {
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
                .navigationTitle(title ?? "Task Module")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            onDismiss()
                        }
                    }
                }
        }
    }
}

#if os(iOS)
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
#elseif os(macOS)
struct WebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
#endif
