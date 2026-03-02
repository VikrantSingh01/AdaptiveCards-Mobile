package com.microsoft.adaptivecards.accessibility

import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.foundation.layout.Box
import androidx.compose.material3.Text
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.assertIsDisplayed
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/**
 * Tests for image accessibility semantics, covering:
 * - Decorative images (no alt text) are hidden from TalkBack (#30, #11)
 * - Images with alt text are announced correctly
 */
@RunWith(RobolectricTestRunner::class)
class ImageAccessibilityTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun `image with altText should be announced by TalkBack`() {
        composeTestRule.setContent {
            Box(modifier = Modifier.imageSemantics("Weather icon showing sun")) {
                Text("img")
            }
        }

        composeTestRule
            .onNodeWithContentDescription("Weather icon showing sun")
            .assertExists()
    }

    @Test
    fun `decorative image without altText should be hidden from TalkBack`() {
        composeTestRule.setContent {
            Box(modifier = Modifier.imageSemantics(null)) {
                Text("decorative")
            }
        }

        // Decorative image should NOT have a content description
        composeTestRule
            .onNodeWithContentDescription("decorative")
            .assertDoesNotExist()

        // The node should exist but have invisibleToUser semantics
        composeTestRule
            .onNode(SemanticsMatcher.keyIsDefined(SemanticsProperties.InvisibleToUser))
            .assertExists()
    }

    @Test
    fun `image with empty altText should be treated as decorative`() {
        // Note: The modifier receives null for empty alt text since
        // the model layer converts empty strings to null.
        composeTestRule.setContent {
            Box(modifier = Modifier.imageSemantics(null)) {
                Text("empty-alt")
            }
        }

        composeTestRule
            .onNode(SemanticsMatcher.keyIsDefined(SemanticsProperties.InvisibleToUser))
            .assertExists()
    }

    @Test
    fun `image with altText should have Image role`() {
        composeTestRule.setContent {
            Box(modifier = Modifier.imageSemantics("Mountain landscape")) {
                Text("img")
            }
        }

        composeTestRule
            .onNode(
                SemanticsMatcher.expectValue(SemanticsProperties.Role, Role.Image)
            )
            .assertExists()
    }
}
