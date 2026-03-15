// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Protocol for providing dynamic choices for ChoiceSet inputs with `choices.data` (Data.Query).
///
/// Host apps implement this protocol to supply search-as-you-type results for
/// ChoiceSet inputs that use dynamic typeahead instead of static `choices` arrays.
///
/// ```swift
/// class MyDataQueryProvider: DataQueryProvider {
///     func fetchChoices(dataset: String, filter: String, count: Int?) async throws -> [ChoiceSetInput.Choice] {
///         let results = try await api.search(dataset: dataset, query: filter, limit: count)
///         return results.map { ChoiceSetInput.Choice(title: $0.name, value: $0.id) }
///     }
/// }
///
/// var config = CardConfiguration.default
/// config.dataQueryProvider = MyDataQueryProvider()
/// ```
public protocol DataQueryProvider: Sendable {
    /// Fetch choices matching the given filter text.
    /// - Parameters:
    ///   - dataset: The dataset identifier from the card's `choices.data.dataset`
    ///   - filter: The current search text typed by the user
    ///   - count: Optional maximum number of results to return
    /// - Returns: An array of choices to display in the typeahead dropdown
    func fetchChoices(dataset: String, filter: String, count: Int?) async throws -> [ChoiceSetInput.Choice]
}
