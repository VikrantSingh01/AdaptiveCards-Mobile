// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.sample

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.BookmarkBorder
import androidx.compose.material.icons.filled.Code
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Refresh
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.microsoft.adaptivecards.core.parsing.CardParser
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import org.json.JSONObject
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardDetailScreen(cardId: String, actionLogState: ActionLogState, bookmarkState: BookmarkState, navController: NavController, editorState: EditorState? = null, perfStore: PerformanceStore? = null, pendingActionTitle: MutableState<String?>? = null) {
    var showJson by remember { mutableStateOf(false) }
    var parseTimeMs by remember { mutableStateOf(0.0) }
    var renderTimeMs by remember { mutableStateOf(0.0) }
    var refreshKey by remember { mutableStateOf(0) }
    var parseError by remember { mutableStateOf<String?>(null) }

    val context = LocalContext.current
    // URI-decode the cardId since navigation encodes slashes in paths like "versioned/v1.6/file.json"
    val decodedCardId = remember(cardId) { java.net.URLDecoder.decode(cardId, "UTF-8") }
    val card = remember(decodedCardId) {
        val allCards = CardCache.getCards(context)
        allCards.find { it.filename == decodedCardId }
            ?: allCards.find { it.filename == "$decodedCardId.json" }
            ?: allCards.find { it.filename.removeSuffix(".json") == decodedCardId }
    }
    // Load template data for .template.json cards
    val templateData: Map<String, Any?>? = remember(cardId) {
        if (card != null && TestCardLoader.hasTemplateData(card.filename)) {
            val dataJson = TestCardLoader.loadTemplateData(context, card.filename)
            if (dataJson != null) {
                try {
                    jsonToMap(JSONObject(dataJson))
                } catch (_: Exception) {
                    null
                }
            } else null
        } else null
    }
    val cardViewModel: CardViewModel = viewModel(key = "detail_${cardId}_$refreshKey")
    val actionHandler = remember(actionLogState) { LoggingActionHandler(actionLogState) }

    // Handle pending action trigger (for test automation deep links)
    val pendingTitle = pendingActionTitle?.value
    val parsedCard by cardViewModel.card.collectAsState()
    LaunchedEffect(pendingTitle, parsedCard) {
        if (pendingTitle != null && parsedCard != null) {
            val allActions = com.microsoft.adaptivecards.rendering.composables.collectAllActionsForCard(parsedCard!!)
            val matchingAction = allActions.firstOrNull { it.title == pendingTitle }
            if (matchingAction != null) {
                com.microsoft.adaptivecards.rendering.composables.handleAction(matchingAction, actionHandler, cardViewModel)
            }
            pendingActionTitle?.value = null
        }
    }

    LaunchedEffect(card, refreshKey) {
        card?.let {
            try {
                // Expand templates before benchmarking (templates need data to produce valid JSON)
                val templateEngine = com.microsoft.adaptivecards.templating.TemplateEngine()
                var cardJson = templateEngine.resolveStringResources(it.jsonString)
                if (templateData != null) {
                    cardJson = templateEngine.expand(cardJson, templateData)
                }

                // Clear cache so measurements reflect real work, not cache lookups
                CardViewModel.clearParseCache()

                // Parse: fresh JSON deserialization
                val parseStart = System.nanoTime()
                CardParser.parse(cardJson)
                parseTimeMs = (System.nanoTime() - parseStart) / 1_000_000.0

                // Render: ViewModel parse (cache-miss) + state initialization
                CardViewModel.clearParseCache()
                val renderStart = System.nanoTime()
                cardViewModel.parseCard(it.jsonString, templateData)
                renderTimeMs = (System.nanoTime() - renderStart) / 1_000_000.0

                // Persist to store (accumulates across sessions)
                perfStore?.recordParse(parseTimeMs)
                perfStore?.recordRender(renderTimeMs)
            } catch (e: Exception) {
                parseError = "Failed to render card: ${e.message}\nJSON input: ${it.jsonString.take(200)}"
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        card?.title ?: "Card Detail",
                        maxLines = 2,
                        softWrap = true,
                        style = MaterialTheme.typography.titleSmall
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                },
                actions = {
                    // Edit in Editor
                    IconButton(onClick = {
                        editorState?.pendingJson = card?.jsonString
                        navController.navigate(Screen.Editor.route) {
                            popUpTo(navController.graph.findStartDestination().id) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }) {
                        Icon(Icons.Default.Edit, "Edit in Editor")
                    }
                    IconButton(onClick = { bookmarkState.toggle(cardId) }) {
                        Icon(
                            if (bookmarkState.isBookmarked(cardId)) Icons.Default.Bookmark
                            else Icons.Default.BookmarkBorder,
                            "Bookmark",
                            tint = if (bookmarkState.isBookmarked(cardId))
                                MaterialTheme.colorScheme.primary
                            else
                                MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    IconButton(onClick = { refreshKey++ }) {
                        Icon(Icons.Default.Refresh, "Reload")
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
            // Card preview — fills remaining space (AdaptiveCardView handles scrolling internally)
            Column(
                modifier = Modifier
                    .weight(1f)
            ) {
                if (parseError != null) {
                    Text(
                        text = parseError ?: "",
                        color = MaterialTheme.colorScheme.error,
                        modifier = Modifier.padding(16.dp)
                    )
                } else {
                    AdaptiveCardView(
                        cardJson = card?.jsonString ?: "",
                        templateData = templateData,
                        hostConfig = com.microsoft.adaptivecards.core.hostconfig.TeamsHostConfig.createLight(),
                        actionHandler = actionHandler,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 8.dp, vertical = 4.dp),
                        viewModel = cardViewModel,
                        pendingActionTitle = pendingActionTitle
                    )
                }
            }

            // Bottom bar — single row: JSON | Parse | Render | Copy
            Surface(
                tonalElevation = 2.dp,
                shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp)
            ) {
                Column(modifier = Modifier.fillMaxWidth()) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 12.dp, vertical = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // JSON toggle
                        TooltipBox(
                            positionProvider = TooltipDefaults.rememberPlainTooltipPositionProvider(),
                            tooltip = { PlainTooltip { Text(if (showJson) "Hide JSON" else "Show JSON") } },
                            state = rememberTooltipState()
                        ) {
                            FilledTonalIconButton(
                                onClick = { showJson = !showJson },
                                modifier = Modifier.size(32.dp)
                            ) {
                                Icon(
                                    Icons.Default.Code,
                                    contentDescription = if (showJson) "Hide JSON" else "Show JSON",
                                    modifier = Modifier.size(16.dp)
                                )
                            }
                        }

                        Spacer(modifier = Modifier.weight(1f))

                        // Parse metric
                        Row(
                            verticalAlignment = Alignment.Bottom,
                            horizontalArrangement = Arrangement.spacedBy(3.dp)
                        ) {
                            Text(
                                "PARSE",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                String.format("%.1f", parseTimeMs),
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = perfColor(parseTimeMs),
                                fontFamily = FontFamily.Monospace
                            )
                            Text(
                                "ms",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }

                        VerticalDivider(
                            modifier = Modifier
                                .height(20.dp)
                                .padding(horizontal = 10.dp)
                        )

                        // Render metric
                        Row(
                            verticalAlignment = Alignment.Bottom,
                            horizontalArrangement = Arrangement.spacedBy(3.dp)
                        ) {
                            Text(
                                "RENDER",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                String.format("%.1f", renderTimeMs),
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = perfColor(renderTimeMs),
                                fontFamily = FontFamily.Monospace
                            )
                            Text(
                                "ms",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }

                        Spacer(modifier = Modifier.weight(1f))

                        // Copy button
                        TooltipBox(
                            positionProvider = TooltipDefaults.rememberPlainTooltipPositionProvider(),
                            tooltip = { PlainTooltip { Text("Copy JSON") } },
                            state = rememberTooltipState()
                        ) {
                            FilledTonalIconButton(
                                onClick = {
                                    val clipboard = context.getSystemService(android.content.ClipboardManager::class.java)
                                    clipboard?.setPrimaryClip(
                                        android.content.ClipData.newPlainText("Card JSON", card?.jsonString ?: "")
                                    )
                                },
                                modifier = Modifier.size(32.dp)
                            ) {
                                Icon(
                                    Icons.Default.ContentCopy,
                                    contentDescription = "Copy JSON",
                                    modifier = Modifier.size(16.dp)
                                )
                            }
                        }
                    }

                    // JSON viewer
                    AnimatedVisibility(
                        visible = showJson,
                        enter = expandVertically(),
                        exit = shrinkVertically()
                    ) {
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .heightIn(max = 200.dp)
                                .padding(horizontal = 16.dp)
                                .padding(bottom = 8.dp),
                            shape = RoundedCornerShape(12.dp),
                            colors = CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.surfaceContainerHigh
                            )
                        ) {
                            Text(
                                text = card?.jsonString ?: "",
                                modifier = Modifier
                                    .padding(12.dp)
                                    .verticalScroll(rememberScrollState()),
                                fontFamily = FontFamily.Monospace,
                                style = MaterialTheme.typography.bodySmall
                            )
                        }
                    }
                }
            }
        }
    }
}

/** Recursively converts a JSONObject to a Map<String, Any?> for template data binding. */
private fun jsonToMap(json: JSONObject): Map<String, Any?> {
    val map = mutableMapOf<String, Any?>()
    for (key in json.keys()) {
        map[key] = jsonToAny(json.get(key))
    }
    return map
}

private fun jsonToAny(value: Any?): Any? = when (value) {
    is JSONObject -> jsonToMap(value)
    is org.json.JSONArray -> (0 until value.length()).map { jsonToAny(value.get(it)) }
    JSONObject.NULL -> null
    else -> value
}

/** Maps a performance metric (ms) to a color: green < 10, blue < 20, orange < 40, red >= 40. */
private fun perfColor(ms: Double): Color = when {
    ms < 10 -> Color(0xFF34C759)  // Green — excellent
    ms < 20 -> Color(0xFF0078D4)  // Blue — good
    ms < 40 -> Color(0xFFFF9500)  // Orange — moderate
    else    -> Color(0xFFFF3B30)  // Red — slow
}

/**
 * In-memory card cache to avoid re-loading all cards on each detail navigation.
 */
object CardCache {
    @Volatile
    private var cached: List<TestCard>? = null

    @Synchronized
    fun getCards(context: android.content.Context): List<TestCard> {
        return cached ?: TestCardLoader.loadAllCards(context).also { cached = it }
    }
}
