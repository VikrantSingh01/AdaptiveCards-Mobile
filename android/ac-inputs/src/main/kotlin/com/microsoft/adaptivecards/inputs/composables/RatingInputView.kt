package com.microsoft.adaptivecards.inputs.composables

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.StarOutline
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.RatingInput
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders an Input.Rating element (interactive star picker)
 */
@Composable
fun RatingInputView(
    element: RatingInput,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    var ratingValue by remember { mutableStateOf(element.value ?: 0.0) }
    val error = viewModel.getValidationError(element.id ?: "")
    val maxStars = element.max ?: 5
    val starColor = Color(0xFFFFC107) // Amber color for stars

    LaunchedEffect(ratingValue) {
        element.id?.let { id ->
            viewModel.updateInputValue(id, ratingValue)
            
            // Validate
            val validationError = if (element.isRequired && ratingValue == 0.0) {
                element.errorMessage ?: "Rating is required"
            } else {
                null
            }
            viewModel.setValidationError(id, validationError)
        }
    }

    Column(modifier = modifier.fillMaxWidth()) {
        // Label
        element.label?.let { label ->
            Text(
                text = if (element.isRequired) "$label *" else label,
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.padding(bottom = 8.dp)
            )
        }

        // Star Rating Input
        Row(
            verticalAlignment = Alignment.CenterVertically
        ) {
            for (i in 1..maxStars) {
                Icon(
                    imageVector = if (i <= ratingValue.toInt()) {
                        Icons.Filled.Star
                    } else {
                        Icons.Outlined.StarOutline
                    },
                    contentDescription = "Rate $i stars",
                    tint = if (i <= ratingValue.toInt()) starColor else Color.Gray,
                    modifier = Modifier
                        .size(32.dp)
                        .clickable {
                            ratingValue = i.toDouble()
                        }
                        .padding(2.dp)
                )
            }

            // Display rating value
            if (ratingValue > 0) {
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "${ratingValue.toInt()}/$maxStars",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                )
            }
        }

        // Error message
        error?.let { errorMessage ->
            Text(
                text = errorMessage,
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(top = 4.dp)
            )
        }
    }
}
