package com.microsoft.adaptivecards.rendering.composables

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.microsoft.adaptivecards.core.models.CodeBlock
import com.microsoft.adaptivecards.hostconfig.LocalHostConfig

/**
 * Renders a CodeBlock element with syntax highlighting and copy functionality
 */
@Composable
fun CodeBlockView(
    element: CodeBlock,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val context = LocalContext.current
    val scrollState = rememberScrollState()
    val horizontalScrollState = rememberScrollState()

    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(8.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color(0xFF1E1E1E)
        )
    ) {
        Column {
            // Header with language and copy button
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color(0xFF2D2D30))
                    .padding(horizontal = 12.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                element.language?.let { lang ->
                    Text(
                        text = lang.uppercase(),
                        color = Color.White.copy(alpha = 0.7f),
                        fontSize = 12.sp,
                        fontFamily = FontFamily.Monospace
                    )
                }

                IconButton(
                    onClick = {
                        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        val clip = ClipData.newPlainText("code", element.code)
                        clipboard.setPrimaryClip(clip)
                    },
                    modifier = Modifier.size(32.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.ContentCopy,
                        contentDescription = "Copy code",
                        tint = Color.White.copy(alpha = 0.7f),
                        modifier = Modifier.size(18.dp)
                    )
                }
            }

            // Code content
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .then(
                        if (element.wrap == true) {
                            Modifier.verticalScroll(scrollState)
                        } else {
                            Modifier
                                .horizontalScroll(horizontalScrollState)
                                .verticalScroll(scrollState)
                        }
                    )
                    .padding(12.dp)
            ) {
                val lines = element.code.split("\n")
                val startLineNumber = element.startLineNumber ?: 1

                Column {
                    lines.forEachIndexed { index, line ->
                        Row {
                            // Line number
                            if (element.startLineNumber != null) {
                                Text(
                                    text = "${startLineNumber + index}  ",
                                    color = Color.White.copy(alpha = 0.4f),
                                    fontSize = 14.sp,
                                    fontFamily = FontFamily.Monospace,
                                    modifier = Modifier.padding(end = 8.dp)
                                )
                            }

                            // Code line
                            Text(
                                text = line.ifEmpty { " " },
                                color = Color(0xFFD4D4D4),
                                fontSize = 14.sp,
                                fontFamily = FontFamily.Monospace,
                                softWrap = element.wrap == true
                            )
                        }
                    }
                }
            }
        }
    }
}
