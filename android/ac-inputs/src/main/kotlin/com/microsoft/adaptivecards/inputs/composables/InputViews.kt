package com.microsoft.adaptivecards.inputs.composables

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarToday
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import java.time.LocalDate
import java.time.LocalTime
import java.time.format.DateTimeFormatter

/**
 * Renders an Input.Date element with a native DatePickerDialog.
 * Displays selected date in ISO format (yyyy-MM-dd).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DateInputView(
    element: InputDate,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    var dateValue by remember { mutableStateOf(element.value ?: "") }
    var showPicker by remember { mutableStateOf(false) }
    var hasInteracted by remember { mutableStateOf(false) }
    val error = viewModel.getValidationError(element.id ?: "")

    LaunchedEffect(dateValue) {
        element.id?.let { id ->
            viewModel.updateInputValue(id, dateValue)
            if (hasInteracted) {
                val validationError = if (element.isRequired && dateValue.isBlank()) {
                    element.errorMessage ?: "Date is required"
                } else {
                    null
                }
                viewModel.setValidationError(id, validationError)
            }
        }
    }

    Column(modifier = modifier.fillMaxWidth()) {
        element.label?.let { label ->
            Text(
                text = if (element.isRequired) "$label *" else label,
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.padding(bottom = 4.dp)
            )
        }

        OutlinedTextField(
            value = if (dateValue.isNotBlank()) formatDateForDisplay(dateValue) else "",
            onValueChange = {},
            readOnly = true,
            placeholder = { element.placeholder?.let { Text(it) } ?: Text("Select date") },
            trailingIcon = {
                Icon(Icons.Default.CalendarToday, "Select date")
            },
            isError = error != null,
            supportingText = error?.let { { Text(it, color = MaterialTheme.colorScheme.error) } },
            modifier = Modifier
                .fillMaxWidth()
                .clickable { showPicker = true }
        )

        if (showPicker) {
            val initialMillis = parseDateToMillis(dateValue)
            val datePickerState = rememberDatePickerState(
                initialSelectedDateMillis = initialMillis
            )

            DatePickerDialog(
                onDismissRequest = { showPicker = false },
                confirmButton = {
                    TextButton(onClick = {
                        hasInteracted = true
                        datePickerState.selectedDateMillis?.let { millis ->
                            val date = java.time.Instant.ofEpochMilli(millis)
                                .atZone(java.time.ZoneId.of("UTC"))
                                .toLocalDate()
                            dateValue = date.format(DateTimeFormatter.ISO_LOCAL_DATE)
                        }
                        showPicker = false
                    }) {
                        Text("OK")
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showPicker = false }) {
                        Text("Cancel")
                    }
                }
            ) {
                DatePicker(state = datePickerState)
            }
        }
    }
}

/**
 * Renders an Input.Time element with a native TimePickerDialog.
 * Displays time in HH:mm format.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TimeInputView(
    element: InputTime,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    var timeValue by remember { mutableStateOf(element.value ?: "") }
    var showPicker by remember { mutableStateOf(false) }
    var hasInteracted by remember { mutableStateOf(false) }
    val error = viewModel.getValidationError(element.id ?: "")

    val initialHour = parseTimeHour(timeValue)
    val initialMinute = parseTimeMinute(timeValue)

    LaunchedEffect(timeValue) {
        element.id?.let { id ->
            viewModel.updateInputValue(id, timeValue)
            if (hasInteracted) {
                val validationError = if (element.isRequired && timeValue.isBlank()) {
                    element.errorMessage ?: "Time is required"
                } else {
                    null
                }
                viewModel.setValidationError(id, validationError)
            }
        }
    }

    Column(modifier = modifier.fillMaxWidth()) {
        element.label?.let { label ->
            Text(
                text = if (element.isRequired) "$label *" else label,
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.padding(bottom = 4.dp)
            )
        }

        OutlinedTextField(
            value = if (timeValue.isNotBlank()) formatTimeForDisplay(timeValue) else "",
            onValueChange = {},
            readOnly = true,
            placeholder = { element.placeholder?.let { Text(it) } ?: Text("Select time") },
            trailingIcon = {
                Icon(Icons.Default.Schedule, "Select time")
            },
            isError = error != null,
            supportingText = error?.let { { Text(it, color = MaterialTheme.colorScheme.error) } },
            modifier = Modifier
                .fillMaxWidth()
                .clickable { showPicker = true }
        )

        if (showPicker) {
            val timePickerState = rememberTimePickerState(
                initialHour = initialHour,
                initialMinute = initialMinute,
                is24Hour = true
            )

            AlertDialog(
                onDismissRequest = { showPicker = false },
                title = { Text("Select time") },
                text = { TimePicker(state = timePickerState) },
                confirmButton = {
                    TextButton(onClick = {
                        hasInteracted = true
                        timeValue = String.format("%02d:%02d", timePickerState.hour, timePickerState.minute)
                        showPicker = false
                    }) {
                        Text("OK")
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showPicker = false }) {
                        Text("Cancel")
                    }
                }
            )
        }
    }
}

/**
 * Renders an Input.Toggle element
 */
@Composable
fun ToggleInputView(
    element: InputToggle,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    var checked by remember { mutableStateOf(element.value == (element.valueOn ?: "true")) }
    val error = viewModel.getValidationError(element.id ?: "")

    LaunchedEffect(checked) {
        element.id?.let { id ->
            val value = if (checked) (element.valueOn ?: "true") else (element.valueOff ?: "false")
            viewModel.updateInputValue(id, value)
        }
    }

    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                element.label?.let { label ->
                    Text(
                        text = if (element.isRequired) "$label *" else label,
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
                Text(text = element.title)
            }

            Switch(
                checked = checked,
                onCheckedChange = { checked = it }
            )
        }

        error?.let {
            Text(
                text = it,
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(top = 4.dp)
            )
        }
    }
}

/**
 * Renders an Input.ChoiceSet element
 */
@Composable
fun ChoiceSetInputView(
    element: InputChoiceSet,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    var selectedValue by remember { mutableStateOf(element.value ?: "") }
    val error = viewModel.getValidationError(element.id ?: "")

    LaunchedEffect(selectedValue) {
        element.id?.let { id ->
            viewModel.updateInputValue(id, selectedValue)
        }
    }

    Column(modifier = modifier.fillMaxWidth()) {
        element.label?.let { label ->
            Text(
                text = if (element.isRequired) "$label *" else label,
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.padding(bottom = 4.dp)
            )
        }

        when (element.style) {
            ChoiceInputStyle.Compact -> {
                // Dropdown
                var expanded by remember { mutableStateOf(false) }

                OutlinedButton(
                    onClick = { expanded = true },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        element.choices.find { it.value == selectedValue }?.title
                            ?: element.placeholder ?: "Select..."
                    )
                }

                DropdownMenu(
                    expanded = expanded,
                    onDismissRequest = { expanded = false }
                ) {
                    element.choices.forEach { choice ->
                        DropdownMenuItem(
                            text = { Text(choice.title) },
                            onClick = {
                                selectedValue = choice.value
                                expanded = false
                            }
                        )
                    }
                }
            }
            ChoiceInputStyle.Expanded -> {
                // Radio buttons or checkboxes
                if (element.isMultiSelect == true) {
                    val selectedValues = remember {
                        mutableStateListOf<String>().apply {
                            addAll(selectedValue.split(",").filter { it.isNotBlank() })
                        }
                    }

                    element.choices.forEach { choice ->
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable {
                                    if (selectedValues.contains(choice.value)) {
                                        selectedValues.remove(choice.value)
                                    } else {
                                        selectedValues.add(choice.value)
                                    }
                                    selectedValue = selectedValues.joinToString(",")
                                }
                                .padding(vertical = 4.dp)
                        ) {
                            Checkbox(
                                checked = selectedValues.contains(choice.value),
                                onCheckedChange = {
                                    if (it) selectedValues.add(choice.value) else selectedValues.remove(choice.value)
                                    selectedValue = selectedValues.joinToString(",")
                                }
                            )
                            Text(choice.title, modifier = Modifier.padding(start = 8.dp))
                        }
                    }
                } else {
                    element.choices.forEach { choice ->
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { selectedValue = choice.value }
                                .padding(vertical = 4.dp)
                        ) {
                            RadioButton(
                                selected = selectedValue == choice.value,
                                onClick = { selectedValue = choice.value }
                            )
                            Text(choice.title, modifier = Modifier.padding(start = 8.dp))
                        }
                    }
                }
            }
            else -> {
                // Filtered style — use dropdown with search (simplified to compact for now)
                var expanded by remember { mutableStateOf(false) }
                var filterText by remember { mutableStateOf("") }

                OutlinedTextField(
                    value = filterText.ifBlank {
                        element.choices.find { it.value == selectedValue }?.title ?: ""
                    },
                    onValueChange = { filterText = it; expanded = true },
                    placeholder = { Text(element.placeholder ?: "Type to filter...") },
                    modifier = Modifier.fillMaxWidth()
                )

                DropdownMenu(
                    expanded = expanded && filterText.isNotBlank(),
                    onDismissRequest = { expanded = false }
                ) {
                    element.choices
                        .filter { it.title.contains(filterText, ignoreCase = true) }
                        .forEach { choice ->
                            DropdownMenuItem(
                                text = { Text(choice.title) },
                                onClick = {
                                    selectedValue = choice.value
                                    filterText = choice.title
                                    expanded = false
                                }
                            )
                        }
                }
            }
        }

        error?.let {
            Text(
                text = it,
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(top = 4.dp)
            )
        }
    }
}

// --- Helper functions ---

private fun formatDateForDisplay(isoDate: String): String {
    return try {
        val date = LocalDate.parse(isoDate)
        date.format(DateTimeFormatter.ofPattern("MMM d, yyyy"))
    } catch (_: Exception) {
        isoDate
    }
}

private fun parseDateToMillis(isoDate: String): Long? {
    return try {
        val date = LocalDate.parse(isoDate)
        date.atStartOfDay(java.time.ZoneId.of("UTC")).toInstant().toEpochMilli()
    } catch (_: Exception) {
        null
    }
}

private fun formatTimeForDisplay(time: String): String {
    return try {
        val t = LocalTime.parse(time)
        t.format(DateTimeFormatter.ofPattern("HH:mm"))
    } catch (_: Exception) {
        time
    }
}

private fun parseTimeHour(time: String): Int {
    return try {
        LocalTime.parse(time).hour
    } catch (_: Exception) {
        12
    }
}

private fun parseTimeMinute(time: String): Int {
    return try {
        LocalTime.parse(time).minute
    } catch (_: Exception) {
        0
    }
}
