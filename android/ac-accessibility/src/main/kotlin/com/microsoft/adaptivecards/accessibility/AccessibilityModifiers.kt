package com.microsoft.adaptivecards.accessibility

import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription

/**
 * Adds accessibility semantics for a button
 */
fun Modifier.buttonSemantics(
    label: String,
    enabled: Boolean = true
): Modifier = this.semantics {
    contentDescription = label
    role = Role.Button
    if (!enabled) {
        stateDescription = "Disabled"
    }
}

/**
 * Adds accessibility semantics for an image
 */
fun Modifier.imageSemantics(
    altText: String?
): Modifier = this.semantics {
    if (altText != null) {
        contentDescription = altText
        role = Role.Image
    }
}

/**
 * Adds accessibility semantics for a text input
 */
fun Modifier.inputSemantics(
    label: String,
    value: String,
    isRequired: Boolean = false
): Modifier = this.semantics {
    contentDescription = if (isRequired) "$label (required)" else label
    stateDescription = if (value.isEmpty()) "Empty" else "Has value: $value"
}

/**
 * Adds accessibility semantics for a checkbox
 */
fun Modifier.checkboxSemantics(
    label: String,
    checked: Boolean
): Modifier = this.semantics {
    contentDescription = label
    role = Role.Checkbox
    stateDescription = if (checked) "Checked" else "Unchecked"
}

/**
 * Adds accessibility semantics for a radio button
 */
fun Modifier.radioButtonSemantics(
    label: String,
    selected: Boolean
): Modifier = this.semantics {
    contentDescription = label
    role = Role.RadioButton
    stateDescription = if (selected) "Selected" else "Not selected"
}

/**
 * Adds accessibility semantics for a switch/toggle
 */
fun Modifier.switchSemantics(
    label: String,
    checked: Boolean
): Modifier = this.semantics {
    contentDescription = label
    role = Role.Switch
    stateDescription = if (checked) "On" else "Off"
}

/**
 * Adds accessibility semantics for a container
 */
fun Modifier.containerSemantics(
    label: String? = null
): Modifier = this.semantics(mergeDescendants = false) {
    if (label != null) {
        contentDescription = label
    }
}

/**
 * Adds accessibility semantics for a heading/title
 */
fun Modifier.headingSemantics(
    text: String,
    level: Int = 1
): Modifier = this.semantics {
    contentDescription = text
    // In Compose, we use contentDescription to convey the heading
    // Screen readers will announce this based on text styling
}
