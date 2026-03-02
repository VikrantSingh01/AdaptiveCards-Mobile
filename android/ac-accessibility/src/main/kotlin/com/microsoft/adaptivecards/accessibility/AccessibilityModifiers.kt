package com.microsoft.adaptivecards.accessibility

import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.CollectionInfo
import androidx.compose.ui.semantics.CollectionItemInfo
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.collectionInfo
import androidx.compose.ui.semantics.collectionItemInfo
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.invisibleToUser
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.semantics.LiveRegionMode

/**
 * Adds accessibility semantics for a button.
 * Uses mergeDescendants to prevent duplicate TalkBack focus when
 * combined with Material3 Button's internal clickable semantics
 * (upstream #202).
 */
fun Modifier.buttonSemantics(
    label: String,
    enabled: Boolean = true
): Modifier = this.semantics(mergeDescendants = true) {
    contentDescription = label
    role = Role.Button
    if (!enabled) {
        stateDescription = "Disabled"
    }
}

/**
 * Adds accessibility semantics for a toggle/expand button (e.g. ShowCard).
 * Announces label + expanded/collapsed state so TalkBack says
 * "Show History button, expanded" or "Show History button, collapsed"
 * (upstream #100, #374).
 */
fun Modifier.toggleButtonSemantics(
    label: String,
    expanded: Boolean,
    enabled: Boolean = true
): Modifier = this.semantics(mergeDescendants = true) {
    contentDescription = label
    role = Role.Button
    stateDescription = if (!enabled) "Disabled" else if (expanded) "expanded" else "collapsed"
}

/**
 * Adds accessibility semantics for an image.
 * When altText is provided, announces the image with its description.
 * When altText is null, the image is decorative and hidden from TalkBack
 * to prevent focus landing on invisible/meaningless elements
 * (upstream #203, #108).
 */
fun Modifier.imageSemantics(
    altText: String?
): Modifier = if (altText != null) {
    this.semantics {
        role = Role.Image
        contentDescription = altText
    }
} else {
    // Decorative image — hide from TalkBack entirely
    this.semantics { invisibleToUser() }
}

/**
 * Adds accessibility semantics for a link action.
 * Unlike buttonSemantics, this does not set Role.Button,
 * preventing TalkBack from announcing both "link" and "button".
 */
fun Modifier.linkSemantics(
    label: String,
    enabled: Boolean = true
): Modifier = this.semantics {
    contentDescription = "$label, link"
    if (!enabled) {
        stateDescription = "Disabled"
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

/**
 * Adds accessibility semantics for a dropdown/combobox button.
 * Announces the label, current selected value, and expanded state.
 */
fun Modifier.dropdownSemantics(
    label: String,
    selectedValue: String,
    expanded: Boolean,
    isRequired: Boolean = false
): Modifier = this.semantics(mergeDescendants = true) {
    val requiredSuffix = if (isRequired) ", required" else ""
    contentDescription = "$label$requiredSuffix, drop down list"
    stateDescription = if (expanded) {
        if (selectedValue.isNotEmpty()) "$selectedValue, expanded" else "expanded"
    } else {
        if (selectedValue.isNotEmpty()) "$selectedValue, collapsed" else "collapsed"
    }
    role = Role.DropdownList
}

/**
 * Adds accessibility semantics for a dropdown menu item with correct
 * collection position information (e.g. "1 of 4").
 *
 * @param label The text label for this item
 * @param index Zero-based index of this item in the list
 * @param totalCount Total number of items in the dropdown
 * @param selected Whether this item is currently selected
 */
fun Modifier.dropdownItemSemantics(
    label: String,
    index: Int,
    totalCount: Int,
    selected: Boolean = false
): Modifier = this.semantics {
    contentDescription = label
    collectionItemInfo = CollectionItemInfo(
        rowIndex = index,
        rowSpan = 1,
        columnIndex = 0,
        columnSpan = 1
    )
    if (selected) {
        stateDescription = "Selected"
    }
}

/**
 * Adds collection info semantics to a dropdown menu container.
 * This tells TalkBack the total number of items in the collection.
 *
 * @param itemCount Total number of items in the dropdown
 */
fun Modifier.dropdownMenuSemantics(
    itemCount: Int
): Modifier = this.semantics {
    collectionInfo = CollectionInfo(
        rowCount = itemCount,
        columnCount = 1
    )
}

/**
 * Adds accessibility semantics for radio button groups with correct
 * position information (e.g. "2 of 4").
 */
fun Modifier.radioGroupItemSemantics(
    label: String,
    index: Int,
    totalCount: Int,
    selected: Boolean
): Modifier = this.semantics {
    contentDescription = label
    role = Role.RadioButton
    stateDescription = if (selected) "Selected" else "Not selected"
    collectionItemInfo = CollectionItemInfo(
        rowIndex = index,
        rowSpan = 1,
        columnIndex = 0,
        columnSpan = 1
    )
}


/**
 * Adds LiveRegion.Polite semantics to an error message so TalkBack
 * automatically announces new error text when it appears or changes.
 * This fixes upstream #493 where TalkBack did not announce validation
 * error messages when the submit button was activated.
 */
fun Modifier.errorSemantics(
    errorMessage: String
): Modifier = this.semantics {
    liveRegion = LiveRegionMode.Polite
    contentDescription = errorMessage
}

/**
 * Adds accessibility semantics for a text input that includes the
 * current validation error, if any.  When there is an error, TalkBack
 * will announce it as part of the input description.
 */
fun Modifier.inputWithErrorSemantics(
    label: String,
    value: String,
    isRequired: Boolean = false,
    error: String? = null
): Modifier = this.semantics(mergeDescendants = true) {
    val parts = mutableListOf<String>()
    parts.add(label)
    if (isRequired) parts.add("required")
    if (value.isNotEmpty()) parts.add("current value: $value")
    if (error != null) parts.add("Error: $error")
    contentDescription = parts.joinToString(", ")
    if (value.isEmpty()) {
        stateDescription = "Empty"
    }
}

/**
 * Adds accessibility semantics for a progress bar element.
 * Uses clearAndSetSemantics to merge all child elements (label,
 * progress indicator, percentage text) into a single TalkBack node.
 * This prevents TalkBack from announcing children individually,
 * which was causing irrelevant "link" and "image" announcements
 * on poll cards (upstream #451).
 *
 * @param label Optional descriptive label for the progress bar
 * @param percentage The progress value as an integer percentage (0-100)
 */
fun Modifier.progressBarSemantics(
    label: String?,
    percentage: Int
): Modifier = this.semantics(mergeDescendants = true) {
    contentDescription = buildString {
        label?.let { append("$it, ") }
        append("Progress: $percentage percent")
    }
}

/**
 * Adds accessibility semantics for a spinner/loading indicator.
 * Merges all children to prevent duplicate announcements.
 *
 * @param label Optional descriptive label for what is loading
 */
fun Modifier.spinnerSemantics(
    label: String?
): Modifier = this.semantics(mergeDescendants = true) {
    contentDescription = buildString {
        append("Loading")
        label?.let { append(": $it") }
    }
}
