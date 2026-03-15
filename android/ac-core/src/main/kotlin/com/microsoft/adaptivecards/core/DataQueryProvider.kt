// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.core

import com.microsoft.adaptivecards.core.models.Choice

/**
 * Interface for providing dynamic choices for ChoiceSet inputs with `choices.data` (Data.Query).
 *
 * Host apps implement this interface to supply search-as-you-type results for
 * ChoiceSet inputs that use dynamic typeahead instead of static `choices` arrays.
 *
 * ```kotlin
 * class MyDataQueryProvider : DataQueryProvider {
 *     override suspend fun fetchChoices(dataset: String, filter: String, count: Int?): List<Choice> {
 *         val results = api.search(dataset = dataset, query = filter, limit = count)
 *         return results.map { Choice(title = it.name, value = it.id) }
 *     }
 * }
 *
 * val config = CardConfiguration(dataQueryProvider = MyDataQueryProvider())
 * ```
 */
interface DataQueryProvider {
    /**
     * Fetch choices matching the given filter text.
     * @param dataset The dataset identifier from the card's `choices.data.dataset`
     * @param filter The current search text typed by the user
     * @param count Optional maximum number of results to return
     * @return A list of choices to display in the typeahead dropdown
     */
    suspend fun fetchChoices(dataset: String, filter: String, count: Int?): List<Choice>
}
