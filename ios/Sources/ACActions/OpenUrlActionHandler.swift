import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
import ACCore

public class OpenUrlActionHandler {
    private weak var delegate: ActionDelegate?
    
    public init(delegate: ActionDelegate?) {
        self.delegate = delegate
    }
    
    public func handle(_ action: OpenUrlAction) {
        guard let url = URL(string: action.url) else {
            print("Invalid URL: \(action.url)")
            return
        }
        
        // Notify delegate
        delegate?.onOpenUrl(url: url, actionId: action.id)
        
        // Attempt to open URL
        #if os(iOS)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot open URL: \(url)")
        }
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}
