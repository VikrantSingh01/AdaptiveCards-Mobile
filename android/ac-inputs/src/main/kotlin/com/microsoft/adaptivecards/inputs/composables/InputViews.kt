package com.microsoft.adaptivecards.inputs.composables

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.inputs.validation.InputValidator
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders an Input.Date element (stub - uses text field)
 */
@Composable
fun DateInputView(
    element: InputDate,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    var dateValue by remember { mutableStateOf(element.value ?: "") }
    
    LaunchedEffect(dateValue) {
        element.id?.let { id ->
            viewModel.updateInputValue(id, dateValue)
        }
    }
    
    Column(modifier = modifier.fillMaxWidth()) {
        element.label?.let { label ->
            Text(text = if (element.isRequired) "$label *" else label)
        }
        
        OutlinedTextField(
            value = dateValue,
            onValueChange = { dateValue = it },
            placeholder = { element.placeholder?.let { Text(it) } },
            modifier = Modifier.fillMaxWidth()
        )
    }
}

/**
 * Renders an Input.Time element (stub - uses text field)
 */
@Composable
fun TimeInputView(
    element: InputTime,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    var timeValue by remember { mutableStateOf(element.value ?: "") }
    
    LaunchedEffect(timeValue) {
        element.id?.let { id ->
            viewModel.updateInputValue(id, timeValue)
        }
    }
    
    Column(modifier = modifier.fillMaxWidth()) {
        element.label?.let { label ->
            Text(text = if (element.isRequired) "$label *" else label)
        }
        
        OutlinedTextField(
            value = timeValue,
            onValueChange = { timeValue = it },
            placeholder = { element.placeholder?.let { Text(it) } },
            modifier = Modifier.fillMaxWidth()
        )
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
    
    LaunchedEffect(checked) {
        element.id?.let { id ->
            val value = if (checked) (element.valueOn ?: "true") else (element.valueOff ?: "false")
            viewModel.updateInputValue(id, value)
        }
    }
    
    Row(
        modifier = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column(modifier = Modifier.weight(1f)) {
            element.label?.let { label ->
                Text(text = if (element.isRequired) "$label *" else label)
            }
            Text(text = element.title)
        }
        
        Switch(
            checked = checked,
            onCheckedChange = { checked = it }
        )
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
    
    LaunchedEffect(selectedValue) {
        element.id?.let { id ->
            viewModel.updateInputValue(id, selectedValue)
        }
    }
    
    Column(modifier = modifier.fillMaxWidth()) {
        element.label?.let { label ->
            Text(text = if (element.isRequired) "$label *" else label)
        }
        
        when (element.style) {
            ChoiceInputStyle.Compact -> {
                // Dropdown
                var expanded by remember { mutableStateOf(false) }
                
                OutlinedButton(
                    onClick = { expanded = true },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(element.choices.find { it.value == selectedValue }?.title ?: element.placeholder ?: "Select...")
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
                // Radio buttons
                element.choices.forEach { choice ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        RadioButton(
                            selected = selectedValue == choice.value,
                            onClick = { selectedValue = choice.value }
                        )
                        Text(choice.title)
                    }
                }
            }
            else -> {
                // Default to compact
                Text("Choice set: ${element.choices.size} choices")
            }
        }
    }
}
