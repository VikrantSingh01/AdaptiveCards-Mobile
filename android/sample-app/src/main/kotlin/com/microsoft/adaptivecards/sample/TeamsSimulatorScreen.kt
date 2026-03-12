package com.microsoft.adaptivecards.sample

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TeamsSimulatorScreen(actionLogState: ActionLogState) {
    val messages = remember { mutableStateListOf<ChatMessage>().apply {
        add(ChatMessage(
            sender = "Bot",
            content = MessageContent.Text("Welcome to Teams Simulator! Send messages or cards to test the chat experience."),
            isFromUser = false
        ))
    }}
    var messageText by remember { mutableStateOf("") }
    var showCardMenu by remember { mutableStateOf(false) }
    val listState = rememberLazyListState()
    val scope = rememberCoroutineScope()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Teams Simulator") },
                actions = {
                    IconButton(
                        onClick = { messages.clear() },
                        enabled = messages.isNotEmpty()
                    ) {
                        Icon(Icons.Default.Delete, "Clear")
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
                state = listState,
                modifier = Modifier.weight(1f),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                items(messages, key = { it.id }) { message ->
                    ChatBubble(message)
                }
            }

            // Input bar
            Surface(
                tonalElevation = 2.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Column {
                    HorizontalDivider()
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 12.dp, vertical = 10.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box {
                            IconButton(onClick = { showCardMenu = true }) {
                                Icon(
                                    Icons.Default.Add,
                                    "Add Card",
                                    tint = MaterialTheme.colorScheme.primary
                                )
                            }
                            DropdownMenu(
                                expanded = showCardMenu,
                                onDismissRequest = { showCardMenu = false }
                            ) {
                                DropdownMenuItem(
                                    text = { Text("Simple Card") },
                                    onClick = {
                                        messages.add(ChatMessage(
                                            sender = "Bot",
                                            content = MessageContent.Card(simpleCardJson),
                                            isFromUser = false
                                        ))
                                        showCardMenu = false
                                        scope.launch { listState.animateScrollToItem(messages.size - 1) }
                                    }
                                )
                                DropdownMenuItem(
                                    text = { Text("Form Card") },
                                    onClick = {
                                        messages.add(ChatMessage(
                                            sender = "Bot",
                                            content = MessageContent.Card(formCardJson),
                                            isFromUser = false
                                        ))
                                        showCardMenu = false
                                        scope.launch { listState.animateScrollToItem(messages.size - 1) }
                                    }
                                )
                                DropdownMenuItem(
                                    text = { Text("Chart Card") },
                                    onClick = {
                                        messages.add(ChatMessage(
                                            sender = "Bot",
                                            content = MessageContent.Card(chartCardJson),
                                            isFromUser = false
                                        ))
                                        showCardMenu = false
                                        scope.launch { listState.animateScrollToItem(messages.size - 1) }
                                    }
                                )
                            }
                        }

                        OutlinedTextField(
                            value = messageText,
                            onValueChange = { messageText = it },
                            modifier = Modifier.weight(1f),
                            placeholder = { Text("Message...") },
                            singleLine = true,
                            shape = RoundedCornerShape(24.dp)
                        )

                        FilledIconButton(
                            onClick = {
                                if (messageText.isNotEmpty()) {
                                    messages.add(ChatMessage(
                                        sender = "You",
                                        content = MessageContent.Text(messageText),
                                        isFromUser = true
                                    ))
                                    messageText = ""
                                    scope.launch { listState.animateScrollToItem(messages.size - 1) }
                                }
                            },
                            enabled = messageText.isNotEmpty(),
                            modifier = Modifier.size(40.dp)
                        ) {
                            Icon(
                                Icons.Default.ArrowUpward,
                                "Send",
                                modifier = Modifier.size(20.dp)
                            )
                        }
                    }
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
        if (!message.isFromUser) {
            // Bot avatar
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(
                            colors = listOf(Color(0xFF0078D4), Color(0xFF3399FF))
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    message.sender.firstOrNull()?.toString() ?: "?",
                    color = Color.White,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            Spacer(modifier = Modifier.width(8.dp))
        }

        Column(
            horizontalAlignment = if (message.isFromUser)
                Alignment.End
            else
                Alignment.Start,
            modifier = Modifier.widthIn(max = 300.dp)
        ) {
            Text(
                message.sender,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(modifier = Modifier.height(3.dp))

            when (message.content) {
                is MessageContent.Text -> {
                    Surface(
                        color = if (message.isFromUser)
                            MaterialTheme.colorScheme.primary
                        else
                            MaterialTheme.colorScheme.surfaceVariant,
                        shape = RoundedCornerShape(18.dp)
                    ) {
                        Text(
                            message.content.text,
                            modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp),
                            color = if (message.isFromUser)
                                MaterialTheme.colorScheme.onPrimary
                            else
                                MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
                is MessageContent.Card -> {
                    val msgViewModel: CardViewModel = viewModel(key = "chat_${message.id}")
                    Card(
                        shape = RoundedCornerShape(14.dp),
                        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                    ) {
                        AdaptiveCardView(
                            cardJson = message.content.json,
                            modifier = Modifier.padding(8.dp),
                            viewModel = msgViewModel
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(2.dp))
            Text(
                formatTime(message.timestamp),
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f)
            )
        }

        if (message.isFromUser) {
            Spacer(modifier = Modifier.width(8.dp))
            // User avatar
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.surfaceVariant),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    "Y",
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }
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
