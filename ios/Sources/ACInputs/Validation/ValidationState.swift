// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation
import Combine

public class ValidationState: ObservableObject {
    @Published public var errors: [String: String] = [:]
    @Published public var isValidating: Bool = false

    public init() {}

    public func setError(for inputId: String, message: String?) {
        if let message = message {
            errors[inputId] = message
        } else {
            errors.removeValue(forKey: inputId)
        }
    }

    public func getError(for inputId: String) -> String? {
        return errors[inputId]
    }

    public func clearError(for inputId: String) {
        errors.removeValue(forKey: inputId)
    }

    public func clearAllErrors() {
        errors.removeAll()
    }

    public var hasErrors: Bool {
        !errors.isEmpty
    }
}
