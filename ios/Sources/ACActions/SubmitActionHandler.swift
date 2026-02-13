import Foundation
import ACCore

public class SubmitActionHandler {
    private weak var delegate: ActionDelegate?
    private let gatherInputs: () -> [String: Any]

    public init(
        delegate: ActionDelegate?,
        gatherInputs: @escaping () -> [String: Any]
    ) {
        self.delegate = delegate
        self.gatherInputs = gatherInputs
    }

    public func handle(_ action: SubmitAction) {
        var submitData: [String: Any] = [:]

        // Add input values based on associatedInputs setting
        let associatedInputs = action.associatedInputs ?? .auto
        if associatedInputs == .auto {
            let inputs = gatherInputs()
            submitData.merge(inputs) { _, new in new }
        }

        // Add action data
        if let actionData = action.data {
            if let dataDict = actionData.value as? [String: Any] {
                // Data is a dictionary
                submitData.merge(dataDict) { _, new in new }
            } else if let dataString = actionData.value as? String {
                // Data is a string - add as a single value
                submitData["data"] = dataString
            } else {
                // Data is some other type - add as-is
                submitData["data"] = actionData.value
            }
        }

        delegate?.onSubmit(data: submitData, actionId: action.id)
    }
}
