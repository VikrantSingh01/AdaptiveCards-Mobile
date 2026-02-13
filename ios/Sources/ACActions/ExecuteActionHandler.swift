import Foundation
import ACCore

public class ExecuteActionHandler {
    private weak var delegate: ActionDelegate?
    private let gatherInputs: () -> [String: Any]
    
    public init(
        delegate: ActionDelegate?,
        gatherInputs: @escaping () -> [String: Any]
    ) {
        self.delegate = delegate
        self.gatherInputs = gatherInputs
    }
    
    public func handle(_ action: ExecuteAction) {
        var executeData: [String: Any] = [:]
        
        // Add input values based on associatedInputs setting
        let associatedInputs = action.associatedInputs ?? .auto
        if associatedInputs == .auto {
            let inputs = gatherInputs()
            executeData.merge(inputs) { _, new in new }
        }
        
        // Add action data
        if let actionData = action.data {
            if let dataDict = actionData.value as? [String: Any] {
                // Data is a dictionary
                executeData.merge(dataDict) { _, new in new }
            } else if let dataString = actionData.value as? String {
                // Data is a string - add as a single value
                executeData["data"] = dataString
            } else {
                // Data is some other type - add as-is
                executeData["data"] = actionData.value
            }
        }
        
        delegate?.onExecute(verb: action.verb, data: executeData, actionId: action.id)
    }
}
