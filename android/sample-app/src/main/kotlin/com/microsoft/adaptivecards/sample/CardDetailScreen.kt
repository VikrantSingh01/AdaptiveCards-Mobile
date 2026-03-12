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
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.microsoft.adaptivecards.core.parsing.CardParser
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardDetailScreen(cardId: String, actionLogState: ActionLogState, bookmarkState: BookmarkState, navController: NavController, editorState: EditorState? = null, perfStore: PerformanceStore? = null) {
    var showJson by remember { mutableStateOf(false) }
    var parseTimeMs by remember { mutableStateOf(0.0) }
    var renderTimeMs by remember { mutableStateOf(0.0) }
    var refreshKey by remember { mutableStateOf(0) }

    val context = LocalContext.current
    val card = remember(cardId) {
        CardCache.getCards(context).find { it.filename == cardId }
    }
    val cardViewModel: CardViewModel = viewModel(key = "detail_${cardId}_$refreshKey")

    LaunchedEffect(card, refreshKey) {
        card?.let {
            // Clear cache so measurements reflect real work, not cache lookups
            CardViewModel.clearParseCache()

            // Parse: fresh JSON deserialization
            val parseStart = System.nanoTime()
            CardParser.parse(it.jsonString)
            parseTimeMs = (System.nanoTime() - parseStart) / 1_000_000.0

            // Render: ViewModel parse (cache-miss) + state initialization
            CardViewModel.clearParseCache()
            val renderStart = System.nanoTime()
            cardViewModel.parseCard(it.jsonString)
            renderTimeMs = (System.nanoTime() - renderStart) / 1_000_000.0

            // Persist to store (accumulates across sessions)
            perfStore?.recordParse(parseTimeMs)
            perfStore?.recordRender(renderTimeMs)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        card?.title ?: "Card Detail",
                        maxLines = 1
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
            // Card preview — scrollable, fills remaining space
            Column(
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
            ) {
                AdaptiveCardView(
                    cardJson = card?.jsonString ?: "",
                    hostConfig = com.microsoft.adaptivecards.core.hostconfig.TeamsHostConfig.createLight(),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 8.dp, vertical = 4.dp),
                    viewModel = cardViewModel
                )
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
                                modifier = Modifier.size(36.dp)
                            ) {
                                Icon(
                                    Icons.Default.Code,
                                    contentDescription = if (showJson) "Hide JSON" else "Show JSON",
                                    modifier = Modifier.size(18.dp)
                                )
                            }
                        }

                        Spacer(modifier = Modifier.weight(1f))

                        // Parse metric
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                "PARSE ",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                String.format("%.1f", parseTimeMs),
                                fontSize = 15.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                            Text(
                                "ms",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                modifier = Modifier.padding(start = 2.dp)
                            )
                        }

                        VerticalDivider(
                            modifier = Modifier
                                .height(20.dp)
                                .padding(horizontal = 12.dp)
                        )

                        // Render metric
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                "RENDER ",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                String.format("%.1f", renderTimeMs),
                                fontSize = 15.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                            Text(
                                "ms",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                modifier = Modifier.padding(start = 2.dp)
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
                                modifier = Modifier.size(36.dp)
                            ) {
                                Icon(
                                    Icons.Default.ContentCopy,
                                    contentDescription = "Copy JSON",
                                    modifier = Modifier.size(18.dp)
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
