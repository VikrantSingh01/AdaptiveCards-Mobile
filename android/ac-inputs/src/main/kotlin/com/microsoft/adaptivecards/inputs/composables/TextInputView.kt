package com.microsoft.adaptivecards.inputs.composables

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import com.microsoft.adaptivecards.core.models.InputText
import com.microsoft.adaptivecards.core.models.TextInputStyle
import com.microsoft.adaptivecards.inputs.validation.InputValidator
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders an Input.Text element
 */
@Composable
fun TextInputView(
    element: InputText,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    var textValue by remember { mutableStateOf(element.value ?: "") }
    val error = viewModel.getValidationError(element.id ?: "")
    
    LaunchedEffect(textValue) {
        element.id?.let { id ->
            viewModel.updateInputValue(id, textValue)
            
            // Validate
            val validationError = InputValidator.validateText(
                value = textValue,
                isRequired = element.isRequired,
                regex = element.regex,
                maxLength = element.maxLength,
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
            singleLine = element.isMultiline != true,
            maxLines = if (element.isMultiline == true) Int.MAX_VALUE else 1,
            keyboardOptions = getKeyboardOptions(element.style),
            visualTransformation = if (element.style == TextInputStyle.Password) 
                PasswordVisualTransformation() else VisualTransformation.None,
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

private fun getKeyboardOptions(style: TextInputStyle?): KeyboardOptions {
    return when (style) {
        TextInputStyle.Email -> KeyboardOptions(keyboardType = KeyboardType.Email)
        TextInputStyle.Tel -> KeyboardOptions(keyboardType = KeyboardType.Phone)
        TextInputStyle.Url -> KeyboardOptions(keyboardType = KeyboardType.Uri)
        TextInputStyle.Password -> KeyboardOptions(keyboardType = KeyboardType.Password)
        else -> KeyboardOptions(keyboardType = KeyboardType.Text)
    }
}
