// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.rendering.composables

import android.content.ClipData
import android.content.ClipboardManager
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
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import com.microsoft.adaptivecards.core.models.CodeBlock
import com.microsoft.adaptivecards.rendering.theme.LocalHostConfig

/**
 * Renders a CodeBlock element with syntax highlighting and copy functionality
 * Accessibility: Announces code block with language, provides copy feedback
 * Responsive: Adapts font size and padding for tablets
 */
@Composable
fun CodeBlockView(
    element: CodeBlock,
    modifier: Modifier = Modifier
) {
    val hostConfig = LocalHostConfig.current
    val context = LocalContext.current
    val configuration = LocalConfiguration.current
    val isTablet = configuration.screenWidthDp >= 600
    val snackbarHostState = remember { SnackbarHostState() }
    val coroutineScope = rememberCoroutineScope()

    val scrollState = rememberScrollState()
    val horizontalScrollState = rememberScrollState()
    
    val fontSize = if (isTablet) 16.sp else 14.sp
    val lineNumberFontSize = if (isTablet) 15.sp else 13.sp

    Box(modifier = modifier) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .semantics {
                    contentDescription = buildString {
                        append("Code block")
                        element.language?.let { append(" in $it") }
                        append(", ${element.code.split("\n").size} lines")
                    }
                },
            shape = RoundedCornerShape(if (isTablet) 10.dp else 8.dp),
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
                    .padding(
                        horizontal = if (isTablet) 16.dp else 12.dp,
                        vertical = if (isTablet) 10.dp else 8.dp
                    ),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                element.language?.let { lang ->
                    Text(
                        text = lang.uppercase(),
                        color = Color.White.copy(alpha = 0.7f),
                        fontSize = if (isTablet) 14.sp else 12.sp,
                        fontFamily = FontFamily.Monospace,
                        modifier = Modifier.semantics {
                            contentDescription = "Language: $lang"
                        }
                    )
                }

                IconButton(
                    onClick = {
                        val clipboard = context.getSystemService(ClipboardManager::class.java)
                        val clip = ClipData.newPlainText("code", element.code)
                        clipboard.setPrimaryClip(clip)

                        coroutineScope.launch {
                            snackbarHostState.currentSnackbarData?.dismiss()
                            snackbarHostState.showSnackbar(
                                message = "Code copied to clipboard",
                                duration = SnackbarDuration.Short
                            )
                        }
                    },
                    modifier = Modifier
                        .size(if (isTablet) 36.dp else 32.dp)
                        .semantics {
                            contentDescription = "Copy code to clipboard"
                        }
                ) {
                    Icon(
                        imageVector = Icons.Default.ContentCopy,
                        contentDescription = "Copy code",
                        tint = Color.White.copy(alpha = 0.7f),
                        modifier = Modifier.size(if (isTablet) 20.dp else 18.dp)
                    )
                }
            }

            // Code content — no verticalScroll here; the card is already inside
            // a vertically-scrollable parent, so nesting would crash with
            // infinite height constraints. Horizontal scroll is kept for
            // non-wrapping code.
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .then(
                        if (element.wrap == true) {
                            Modifier
                        } else {
                            Modifier.horizontalScroll(horizontalScrollState)
                        }
                    )
                    .padding(
                        all = if (isTablet) 16.dp else 12.dp
                    )
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
                                    fontSize = lineNumberFontSize,
                                    fontFamily = FontFamily.Monospace,
                                    modifier = Modifier.padding(end = if (isTablet) 12.dp else 8.dp)
                                )
                            }

                            // Code line
                            Text(
                                text = line.ifEmpty { " " },
                                color = Color(0xFFD4D4D4),
                                fontSize = fontSize,
                                fontFamily = FontFamily.Monospace,
                                softWrap = element.wrap == true
                            )
                        }
                    }
                }
            }
        }
        }

        SnackbarHost(
            hostState = snackbarHostState,
            modifier = Modifier.align(Alignment.BottomCenter)
        )
    }
}
