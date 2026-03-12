// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.teams

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import com.microsoft.adaptivecards.core.models.AdaptiveCard

@Composable
fun TeamsCardHost(
    card: AdaptiveCard,
    theme: TeamsTheme = TeamsTheme.LIGHT,
    tokenProvider: AuthTokenProvider? = null,
    deepLinkHandler: DeepLinkHandler = DeepLinkHandler(),
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = TeamsFluentTheme.getColorScheme(theme)
    ) {
        content()
    }
}
