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
            let convertedData = actionData.mapValues { $0.value }
            submitData.merge(convertedData) { _, new in new }
        }
        
        delegate?.onSubmit(data: submitData, actionId: action.id)
    }
}
