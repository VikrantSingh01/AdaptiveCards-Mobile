package com.microsoft.adaptivecards.accessibility

import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/**
 * Tests that button semantics do not cause duplicate role announcements.
 * Validates the fix for upstream #176 where TalkBack announced "Button Button".
 */
@RunWith(RobolectricTestRunner::class)
class ButtonDuplicateRoleTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun `buttonSemantics should set single Button role`() {
        composeTestRule.setContent {
            Button(
                onClick = {},
                modifier = Modifier.buttonSemantics(label = "Submit")
            ) {
                Text("Submit")
            }
        }

        // There should be exactly one node with Button role
        composeTestRule
            .onNode(
                SemanticsMatcher.expectValue(SemanticsProperties.Role, Role.Button)
            )
            .assertExists()
    }

    @Test
    fun `toggleButtonSemantics should announce expanded state`() {
        composeTestRule.setContent {
            Button(
                onClick = {},
                modifier = Modifier.toggleButtonSemantics(
                    label = "More Info",
                    expanded = true
                )
            ) {
                Text("More Info")
            }
        }

        composeTestRule
            .onNode(
                SemanticsMatcher.expectValue(
                    SemanticsProperties.StateDescription,
                    "expanded"
                )
            )
            .assertExists()
    }

    @Test
    fun `toggleButtonSemantics should announce collapsed state`() {
        composeTestRule.setContent {
            Button(
                onClick = {},
                modifier = Modifier.toggleButtonSemantics(
                    label = "More Info",
                    expanded = false
                )
            ) {
                Text("More Info")
            }
        }

        composeTestRule
            .onNode(
                SemanticsMatcher.expectValue(
                    SemanticsProperties.StateDescription,
                    "collapsed"
                )
            )
            .assertExists()
    }
}
