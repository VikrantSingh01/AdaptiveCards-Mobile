package com.microsoft.adaptivecards.sample

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import org.json.JSONObject

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardEditorScreen(actionLogState: ActionLogState) {
    var jsonText by remember { mutableStateOf(defaultCardJson) }
    var isValid by remember { mutableStateOf(true) }
    var errorMessage by remember { mutableStateOf("") }
    var showMenu by remember { mutableStateOf(false) }
    var selectedTab by remember { mutableStateOf(0) }

    // Validate JSON on change
    LaunchedEffect(jsonText) {
        try {
            JSONObject(jsonText)
            isValid = true
            errorMessage = ""
        } catch (e: Exception) {
            isValid = false
            errorMessage = e.message ?: "Invalid JSON"
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Card Editor") },
                actions = {
                    IconButton(onClick = { showMenu = true }) {
                        Icon(Icons.Default.MoreVert, "Menu")
                    }
                    DropdownMenu(
                        expanded = showMenu,
                        onDismissRequest = { showMenu = false }
                    ) {
                        DropdownMenuItem(
                            text = { Text("Load Sample") },
                            onClick = {
                                jsonText = defaultCardJson
                                showMenu = false
                            }
                        )
                        DropdownMenuItem(
                            text = { Text("Clear") },
                            onClick = {
                                jsonText = ""
                                showMenu = false
                            }
                        )
                        DropdownMenuItem(
                            text = { Text("Format JSON") },
                            onClick = {
                                try {
                                    val json = JSONObject(jsonText)
                                    jsonText = json.toString(2)
                                } catch (e: Exception) {
                                    // Keep original if formatting fails
                                }
                                showMenu = false
                            }
                        )
                    }
                }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding)) {
            TabRow(selectedTabIndex = selectedTab) {
                Tab(
                    selected = selectedTab == 0,
                    onClick = { selectedTab = 0 },
                    text = { Text("Editor") }
                )
                Tab(
                    selected = selectedTab == 1,
                    onClick = { selectedTab = 1 },
                    text = { Text("Preview") }
                )
            }

            when (selectedTab) {
                0 -> EditorPane(jsonText, isValid, errorMessage) { jsonText = it }
                1 -> PreviewPane(jsonText, isValid, errorMessage)
            }
        }
    }
}

@Composable
fun EditorPane(
    jsonText: String,
    isValid: Boolean,
    errorMessage: String,
    onTextChange: (String) -> Unit
) {
    Column(modifier = Modifier.fillMaxSize()) {
        // Status indicator
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("JSON Editor", style = MaterialTheme.typography.titleMedium)
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Icon(
                    imageVector = if (isValid) 
                        androidx.compose.material.icons.Icons.Default.CheckCircle 
                    else 
                        androidx.compose.material.icons.Icons.Default.Error,
                    contentDescription = if (isValid) "Valid" else "Invalid",
                    tint = if (isValid) 
                        MaterialTheme.colorScheme.primary 
                    else 
                        MaterialTheme.colorScheme.error
                )
                Text(
                    if (isValid) "Valid" else "Invalid",
                    color = if (isValid) 
                        MaterialTheme.colorScheme.primary 
                    else 
                        MaterialTheme.colorScheme.error
                )
            }
        }

        // Editor
        Surface(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp),
            color = MaterialTheme.colorScheme.surfaceVariant,
            shape = MaterialTheme.shapes.medium
        ) {
            BasicTextField(
                value = jsonText,
                onValueChange = onTextChange,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
                textStyle = androidx.compose.ui.text.TextStyle(
                    fontFamily = FontFamily.Monospace,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            )
        }

        if (!isValid) {
            Text(
                text = errorMessage,
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier.padding(16.dp),
                style = MaterialTheme.typography.bodySmall
            )
        }
    }
}

@Composable
fun PreviewPane(jsonText: String, isValid: Boolean, errorMessage: String) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        if (isValid) {
            CardPreviewPlaceholder(jsonText)
        } else {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.errorContainer
                )
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        "Invalid JSON",
                        style = MaterialTheme.typography.titleLarge,
                        color = MaterialTheme.colorScheme.onErrorContainer
                    )
                    Text(
                        errorMessage,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onErrorContainer
                    )
                }
            }
        }
    }
}

private const val defaultCardJson = """{
  "type": "AdaptiveCard",
  "version": "1.5",
  "body": [
    {
      "type": "TextBlock",
      "text": "Hello, World!",
      "size": "large",
      "weight": "bolder"
    },
    {
      "type": "TextBlock",
      "text": "Edit this JSON to see changes in the preview.",
      "wrap": true
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "Submit"
    }
  ]
}"""
