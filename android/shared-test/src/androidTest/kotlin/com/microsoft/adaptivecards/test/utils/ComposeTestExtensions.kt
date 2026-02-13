package com.microsoft.adaptivecards.test.utils

import android.graphics.Bitmap
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asAndroidBitmap
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.test.SemanticsNodeInteraction
import androidx.compose.ui.test.captureToImage
import androidx.compose.ui.test.junit4.ComposeContentTestRule
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.hostconfig.HostConfig
import com.microsoft.adaptivecards.core.hostconfig.HostConfigParser
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import com.microsoft.adaptivecards.rendering.viewmodel.DefaultActionHandler

/**
 * Extension functions for Compose testing with Adaptive Cards.
 *
 * These helpers make it straightforward to set up the themed/configured
 * Compose tree for a card and capture screenshots of the result.
 */

// ------------------------------------------------------------------
// Compose rule extensions
// ------------------------------------------------------------------

/**
 * Set content for an Adaptive Card with the given test configuration.
 *
 * This sets up the full themed environment (dark/light, font scale,
 * layout direction) and renders the card JSON inside a constrained
 * [Surface] matching the device config width.
 */
fun ComposeContentTestRule.setCardContent(
    cardJson: String,
    config: TestConfiguration,
    hostConfig: HostConfig = HostConfigParser.default()
) {
    setContent {
        AdaptiveCardTestWrapper(
            cardJson = cardJson,
            config = config,
            hostConfig = hostConfig
        )
    }
    // Wait for composition and any LaunchedEffect to settle.
    waitForIdle()
}

/**
 * Capture a screenshot of the root composable.
 *
 * @return Bitmap of the rendered content.
 */
fun ComposeContentTestRule.captureRootScreenshot(): Bitmap {
    return onRoot()
        .captureToImage()
        .asAndroidBitmap()
        .copy(Bitmap.Config.ARGB_8888, false)
}

/**
 * Capture a screenshot of a specific semantics node.
 */
fun SemanticsNodeInteraction.captureScreenshot(): Bitmap {
    return captureToImage()
        .asAndroidBitmap()
        .copy(Bitmap.Config.ARGB_8888, false)
}

/**
 * Wait for an Adaptive Card to finish rendering, including any
 * asynchronous image loading or animation.
 */
fun ComposeContentTestRule.waitForCardRender(timeoutMs: Long = 5_000) {
    waitForIdle()
    // Allow time for LaunchedEffect + recomposition.
    Thread.sleep(minOf(timeoutMs, 500))
    waitForIdle()
}

// ------------------------------------------------------------------
// Composable wrappers
// ------------------------------------------------------------------

/**
 * Themed wrapper that configures the Compose environment to match
 * a [TestConfiguration].
 */
@Composable
fun AdaptiveCardTestWrapper(
    cardJson: String,
    config: TestConfiguration,
    hostConfig: HostConfig = HostConfigParser.default()
) {
    val colorScheme = when (config.theme) {
        ThemeConfig.LIGHT -> lightColorScheme()
        ThemeConfig.DARK -> darkColorScheme()
    }

    val layoutDirection = if (config.locale.isRtl) LayoutDirection.Rtl else LayoutDirection.Ltr
    val density = Density(
        density = LocalDensity.current.density,
        fontScale = config.fontScale.scale
    )

    CompositionLocalProvider(
        LocalLayoutDirection provides layoutDirection,
        LocalDensity provides density
    ) {
        MaterialTheme(colorScheme = colorScheme) {
            Surface(
                modifier = Modifier
                    .width(config.device.widthDp.dp)
                    .wrapContentHeight(),
                color = MaterialTheme.colorScheme.background
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(8.dp)
                ) {
                    AdaptiveCardView(
                        cardJson = cardJson,
                        hostConfig = hostConfig,
                        actionHandler = DefaultActionHandler(),
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }
        }
    }
}

/**
 * Render a card JSON string in a minimal unwrapped environment.
 * Useful for isolated element-level tests.
 */
@Composable
fun MinimalCardWrapper(
    cardJson: String,
    hostConfig: HostConfig = HostConfigParser.default()
) {
    MaterialTheme {
        Surface {
            AdaptiveCardView(
                cardJson = cardJson,
                hostConfig = hostConfig,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}
