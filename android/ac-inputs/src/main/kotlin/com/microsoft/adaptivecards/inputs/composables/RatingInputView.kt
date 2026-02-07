package com.microsoft.adaptivecards.inputs.composables

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.StarBorder
import androidx.compose.material.ripple.rememberRipple
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.microsoft.adaptivecards.core.models.RatingInput
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

/**
 * Renders an Input.Rating element (interactive star picker)
 * Accessibility: Announces current rating and max rating, keyboard navigable
 * Responsive: Adapts star size and spacing for tablets
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
    
    val configuration = LocalConfiguration.current
    val isTablet = configuration.screenWidthDp >= 600
    val starSize = if (isTablet) 40.dp else 32.dp
    val starPadding = if (isTablet) 4.dp else 2.dp

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

    Column(
        modifier = modifier
            .fillMaxWidth()
            .semantics {
                contentDescription = buildString {
                    element.label?.let { append("$it, ") }
                    append("Rating input, ")
                    if (ratingValue > 0) {
                        append("current rating: ${ratingValue.toInt()} out of $maxStars stars")
                    } else {
                        append("no rating selected, select 1 to $maxStars stars")
                    }
                    if (element.isRequired) {
                        append(", required")
                    }
                }
            }
    ) {
        // Label
        element.label?.let { label ->
            Text(
                text = if (element.isRequired) "$label *" else label,
                style = if (isTablet) {
                    MaterialTheme.typography.bodyLarge
                } else {
                    MaterialTheme.typography.bodyMedium
                },
                modifier = Modifier.padding(bottom = if (isTablet) 12.dp else 8.dp)
            )
        }

        // Star Rating Input
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.semantics {
                contentDescription = "Select rating from 1 to $maxStars stars"
            }
        ) {
            for (i in 1..maxStars) {
                val isSelected = i <= ratingValue.toInt()
                val interactionSource = remember { MutableInteractionSource() }
                
                Icon(
                    imageVector = if (isSelected) {
                        Icons.Filled.Star
                    } else {
                        Icons.Outlined.StarBorder
                    },
                    contentDescription = if (isSelected) {
                        "Star $i, selected"
                    } else {
                        "Star $i, not selected"
                    },
                    tint = if (isSelected) starColor else Color.Gray,
                    modifier = Modifier
                        .size(starSize)
                        .clickable(
                            interactionSource = interactionSource,
                            indication = rememberRipple(bounded = false, radius = starSize / 2),
                            role = Role.RadioButton,
                            onClickLabel = "Rate $i stars"
                        ) {
                            ratingValue = i.toDouble()
                        }
                        .padding(starPadding)
                        .semantics {
                            contentDescription = "Rate $i stars"
                        }
                )
            }

            // Display rating value
            if (ratingValue > 0) {
                Spacer(modifier = Modifier.width(if (isTablet) 12.dp else 8.dp))
                Text(
                    text = "${ratingValue.toInt()}/$maxStars",
                    style = if (isTablet) {
                        MaterialTheme.typography.bodyLarge
                    } else {
                        MaterialTheme.typography.bodyMedium
                    },
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                )
            }
        }

        // Error message
        error?.let { errorMessage ->
            Text(
                text = errorMessage,
                color = MaterialTheme.colorScheme.error,
                style = if (isTablet) {
                    MaterialTheme.typography.bodyMedium
                } else {
                    MaterialTheme.typography.bodySmall
                },
                modifier = Modifier
                    .padding(top = if (isTablet) 6.dp else 4.dp)
                    .semantics {
                        contentDescription = "Error: $errorMessage"
                    }
            )
        }
    }
}
