package com.microsoft.adaptivecards.inputs.composables

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import com.microsoft.adaptivecards.core.models.InputNumber
import com.microsoft.adaptivecards.inputs.validation.InputValidator
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders an Input.Number element
 */
@Composable
fun NumberInputView(
    element: InputNumber,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    var textValue by remember { mutableStateOf(element.value?.toString() ?: "") }
    val error = viewModel.getValidationError(element.id ?: "")
    
    LaunchedEffect(textValue) {
        element.id?.let { id ->
            val numberValue = textValue.toDoubleOrNull()
            if (numberValue != null) {
                viewModel.updateInputValue(id, numberValue)
            }
            
            // Validate
            val validationError = InputValidator.validateNumber(
                value = numberValue,
                isRequired = element.isRequired,
                min = element.min,
                max = element.max,
                errorMessage = element.errorMessage
            )
            viewModel.setValidationError(id, validationError)
        }
    }
    
    Column(modifier = modifier.fillMaxWidth()) {
        // Label
        element.label?.let { label ->
            Text(
                text = if (element.isRequired) "$label *" else label
            )
        }
        
        // Input field
        OutlinedTextField(
            value = textValue,
            onValueChange = { textValue = it },
            placeholder = { element.placeholder?.let { Text(it) } },
            isError = error != null,
            singleLine = true,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            modifier = Modifier.fillMaxWidth()
        )
        
        // Error message
        error?.let { errorText ->
            Text(
                text = errorText,
                color = androidx.compose.material3.MaterialTheme.colorScheme.error
            )
        }
    }
}
