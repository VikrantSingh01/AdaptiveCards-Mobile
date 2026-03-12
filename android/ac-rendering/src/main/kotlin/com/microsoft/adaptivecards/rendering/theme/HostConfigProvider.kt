// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.theme

import androidx.compose.runtime.staticCompositionLocalOf
import com.microsoft.adaptivecards.core.hostconfig.HostConfig
import com.microsoft.adaptivecards.core.hostconfig.HostConfigParser

/**
 * CompositionLocal for providing HostConfig throughout the composition
 */
val LocalHostConfig = staticCompositionLocalOf<HostConfig> {
    HostConfigParser.default()
}

/**
 * Provider for HostConfig in the composition tree
 *
 * Usage:
 * ```
 * HostConfigProvider(hostConfig = TeamsHostConfig.create()) {
 *     AdaptiveCardView(cardJson)
 * }
 * ```
 */
@androidx.compose.runtime.Composable
fun HostConfigProvider(
    hostConfig: HostConfig = HostConfigParser.default(),
    content: @androidx.compose.runtime.Composable () -> Unit
) {
    androidx.compose.runtime.CompositionLocalProvider(
        LocalHostConfig provides hostConfig,
        content = content
    )
}
