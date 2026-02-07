package com.microsoft.adaptivecards.sample

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Send
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TeamsSimulatorScreen(actionLogState: ActionLogState) {
    val messages = remember { mutableStateListOf<ChatMessage>().apply {
        add(ChatMessage(
            sender = "Bot",
            content = MessageContent.Text("Welcome to Teams Simulator!"),
            isFromUser = false
        ))
    }}
    var messageText by remember { mutableStateOf("") }
    var showCardMenu by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Teams Simulator") },
                actions = {
                    TextButton(onClick = { messages.clear() }) {
                        Text("Clear")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
        ) {
            // Messages
            LazyColumn(
                modifier = Modifier.weight(1f),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(messages) { message ->
                    ChatBubble(message)
                }
            }

            Divider()

            // Input bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                OutlinedTextField(
                    value = messageText,
                    onValueChange = { messageText = it },
                    modifier = Modifier.weight(1f),
                    placeholder = { Text("Type a message...") },
                    singleLine = true
                )

                IconButton(
                    onClick = {
                        if (messageText.isNotEmpty()) {
                            messages.add(ChatMessage(
                                sender = "You",
                                content = MessageContent.Text(messageText),
                                isFromUser = true
                            ))
                            messageText = ""
                        }
                    },
                    enabled = messageText.isNotEmpty()
                ) {
                    Icon(
                        Icons.Default.Send,
                        "Send",
                        tint = if (messageText.isNotEmpty()) 
                            MaterialTheme.colorScheme.primary 
                        else 
                            MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f)
                    )
                }

                IconButton(onClick = { showCardMenu = true }) {
                    Icon(Icons.Default.Add, "Add Card")
                }

                DropdownMenu(
                    expanded = showCardMenu,
                    onDismissRequest = { showCardMenu = false }
                ) {
                    DropdownMenuItem(
                        text = { Text("Send Simple Card") },
                        onClick = {
                            messages.add(ChatMessage(
                                sender = "Bot",
                                content = MessageContent.Card(simpleCardJson),
                                isFromUser = false
                            ))
                            showCardMenu = false
                        }
                    )
                    DropdownMenuItem(
                        text = { Text("Send Form Card") },
                        onClick = {
                            messages.add(ChatMessage(
                                sender = "Bot",
                                content = MessageContent.Card(formCardJson),
                                isFromUser = false
                            ))
                            showCardMenu = false
                        }
                    )
                    DropdownMenuItem(
                        text = { Text("Send Chart Card") },
                        onClick = {
                            messages.add(ChatMessage(
                                sender = "Bot",
                                content = MessageContent.Card(chartCardJson),
                                isFromUser = false
                            ))
                            showCardMenu = false
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun ChatBubble(message: ChatMessage) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = if (message.isFromUser) 
            Arrangement.End 
        else 
            Arrangement.Start
    ) {
        Column(
            horizontalAlignment = if (message.isFromUser) 
                Alignment.End 
            else 
                Alignment.Start,
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                message.sender,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            when (message.content) {
                is MessageContent.Text -> {
                    Surface(
                        color = if (message.isFromUser) 
                            MaterialTheme.colorScheme.primary 
                        else 
                            MaterialTheme.colorScheme.surfaceVariant,
                        shape = RoundedCornerShape(16.dp)
                    ) {
                        Text(
                            message.content.text,
                            modifier = Modifier.padding(12.dp),
                            color = if (message.isFromUser) 
                                MaterialTheme.colorScheme.onPrimary 
                            else 
                                MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
                is MessageContent.Card -> {
                    Card(
                        modifier = Modifier.widthIn(max = 300.dp),
                        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                    ) {
                        CardPreviewPlaceholder(message.content.json)
                    }
                }
            }

            Text(
                formatTime(message.timestamp),
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

data class ChatMessage(
    val id: String = UUID.randomUUID().toString(),
    val sender: String,
    val content: MessageContent,
    val isFromUser: Boolean,
    val timestamp: Long = System.currentTimeMillis()
)

sealed class MessageContent {
    data class Text(val text: String) : MessageContent()
    data class Card(val json: String) : MessageContent()
}

private fun formatTime(timestamp: Long): String {
    val format = SimpleDateFormat("HH:mm", Locale.getDefault())
    return format.format(Date(timestamp))
}

private const val simpleCardJson = """{
  "type": "AdaptiveCard",
  "version": "1.5",
  "body": [
    {
      "type": "TextBlock",
      "text": "Quick Update",
      "weight": "bolder",
      "size": "large"
    },
    {
      "type": "TextBlock",
      "text": "This is a simple card for quick updates.",
      "wrap": true
    }
  ]
}"""

private const val formCardJson = """{
  "type": "AdaptiveCard",
  "version": "1.5",
  "body": [
    {
      "type": "TextBlock",
      "text": "Feedback Form",
      "weight": "bolder"
    },
    {
      "type": "Input.Text",
      "id": "name",
      "placeholder": "Your name"
    },
    {
      "type": "Input.Text",
      "id": "feedback",
      "placeholder": "Your feedback",
      "isMultiline": true
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "Submit"
    }
  ]
}"""

private const val chartCardJson = """{
  "type": "AdaptiveCard",
  "version": "1.5",
  "body": [
    {
      "type": "TextBlock",
      "text": "Sales Report",
      "weight": "bolder"
    },
    {
      "type": "TextBlock",
      "text": "Chart placeholder - shows performance metrics",
      "wrap": true
    }
  ]
}"""
