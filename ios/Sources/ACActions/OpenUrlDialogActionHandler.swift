import SwiftUI
import SafariServices
import ACCore

@MainActor
public class OpenUrlDialogActionHandler {
    public static func handle(action: OpenUrlDialogAction, delegate: ActionDelegate?) {
        guard let url = URL(string: action.url) else { return }
        delegate?.didTriggerAction(action)
    }
}
