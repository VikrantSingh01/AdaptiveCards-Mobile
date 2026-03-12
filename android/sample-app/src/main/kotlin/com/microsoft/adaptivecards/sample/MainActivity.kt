package com.microsoft.adaptivecards.sample

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
// Icons.Default.* used for bottom nav
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.navigation.compose.rememberNavController
import com.microsoft.adaptivecards.sample.ui.theme.AdaptiveCardsSampleTheme
import kotlinx.coroutines.channels.Channel

class MainActivity : ComponentActivity() {
    val deepLinkChannel = Channel<Uri>(capacity = Channel.BUFFERED)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        registerInputRenderers()
        intent?.data?.let { deepLinkChannel.trySend(it) }
        setContent {
            AdaptiveCardsSampleTheme {
                MainScreen()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.data?.let { deepLinkChannel.trySend(it) }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen() {
    val navController = rememberNavController()
    val context = androidx.compose.ui.platform.LocalContext.current
    val actionLogState = remember { ActionLogState() }
    val settingsState = remember { SettingsState() }
    val bookmarkState = remember { BookmarkState(context) }
    val editorState = remember { EditorState() }
    val perfStore = remember { PerformanceStore(context) }
    val galleryListState = rememberLazyListState()
    var pendingGalleryFilter by remember { mutableStateOf<String?>(null) }

    val activity = context as? MainActivity
    LaunchedEffect(Unit) {
        val channel = activity?.deepLinkChannel ?: return@LaunchedEffect
        for (uri in channel) {
            try {
                // Extract gallery filter before navigation
                if (uri.host == "gallery" && uri.pathSegments.isNotEmpty()) {
                    pendingGalleryFilter = uri.pathSegments.first()
                }
                handleDeepLink(uri, navController)
            } catch (e: Exception) {
                android.util.Log.e("DeepLink", "Failed to handle deep link: $uri", e)
            }
        }
    }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            NavigationBar(
                tonalElevation = 2.dp
            ) {
                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentDestination = navBackStackEntry?.destination

                val items = listOf(
                    Screen.Gallery,
                    Screen.Editor,
                    Screen.Teams,
                    Screen.More
                )

                items.forEach { screen ->
                    val selected = currentDestination?.hierarchy?.any { it.route == screen.route } == true
                    NavigationBarItem(
                        icon = {
                            Icon(
                                if (selected) screen.selectedIcon else screen.icon,
                                contentDescription = screen.label
                            )
                        },
                        label = { Text(screen.label) },
                        selected = selected,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Gallery.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Gallery.route) {
                CardGalleryScreen(navController, bookmarkState, galleryListState, pendingGalleryFilter) {
                    pendingGalleryFilter = null
                }
            }
            composable(Screen.Editor.route) {
                CardEditorScreen(actionLogState, editorState)
            }
            composable(Screen.Teams.route) {
                TeamsSimulatorScreen(actionLogState)
            }
            composable(Screen.More.route) {
                MoreScreen(navController, actionLogState, settingsState, bookmarkState)
            }
            composable("card_detail/{cardId}") { backStackEntry ->
                val cardId = backStackEntry.arguments?.getString("cardId") ?: ""
                CardDetailScreen(cardId, actionLogState, bookmarkState, navController, editorState, perfStore)
            }
            composable("bookmarks") {
                BookmarksScreen(bookmarkState, navController)
            }
            composable("action_log") {
                ActionLogScreen(actionLogState, navController)
            }
            composable("settings") {
                SettingsScreen(settingsState, navController)
            }
            composable("performance") {
                PerformanceDashboardScreen(navController, perfStore, actionLogState)
            }
        }
    }
}

sealed class Screen(
    val route: String,
    val label: String,
    val icon: ImageVector,
    val selectedIcon: ImageVector
) {
    object Gallery : Screen("gallery", "Gallery", Icons.Default.GridView, Icons.Default.GridView)
    object Editor : Screen("editor", "Editor", Icons.Default.Edit, Icons.Default.Edit)
    object Teams : Screen("teams", "Teams", Icons.Default.Message, Icons.Default.Message)
    object More : Screen("more", "More", Icons.Default.MoreHoriz, Icons.Default.MoreHoriz)
}

// State management classes
class ActionLogState {
    private val _actions = mutableStateListOf<ActionLogEntry>()
    val actions: List<ActionLogEntry> get() = _actions

    fun log(actionType: String, data: Map<String, Any>) {
        _actions.add(0, ActionLogEntry(
            timestamp = System.currentTimeMillis(),
            actionType = actionType,
            data = data
        ))
    }

    fun clear() {
        _actions.clear()
    }
}

data class ActionLogEntry(
    val id: String = java.util.UUID.randomUUID().toString(),
    val timestamp: Long,
    val actionType: String,
    val data: Map<String, Any>
)

class BookmarkState(context: Context) {
    private val prefs = context.getSharedPreferences("bookmarks", Context.MODE_PRIVATE)
    private val _bookmarkedFilenames = mutableStateListOf<String>().also {
        it.addAll(prefs.getStringSet("filenames", emptySet()) ?: emptySet())
    }
    val bookmarkedFilenames: List<String> get() = _bookmarkedFilenames

    fun toggle(filename: String) {
        if (_bookmarkedFilenames.contains(filename)) {
            _bookmarkedFilenames.remove(filename)
        } else {
            _bookmarkedFilenames.add(filename)
        }
        persist()
    }

    fun isBookmarked(filename: String): Boolean = _bookmarkedFilenames.contains(filename)

    private fun persist() {
        prefs.edit().putStringSet("filenames", _bookmarkedFilenames.toSet()).apply()
    }
}

class SettingsState {
    var theme by mutableStateOf(Theme.SYSTEM)
    var fontScale by mutableFloatStateOf(1.0f)
    var enableAccessibility by mutableStateOf(true)
    var enablePerformanceMetrics by mutableStateOf(false)

    enum class Theme {
        LIGHT, DARK, SYSTEM
    }
}

class EditorState {
    var pendingJson by mutableStateOf<String?>(null)
}

class PerformanceStore(context: Context) {
    private val prefs = context.getSharedPreferences("perf_store_v1", Context.MODE_PRIVATE)

    private val _parseTimes = mutableStateListOf<Double>()
    private val _renderTimes = mutableStateListOf<Double>()
    var peakMemoryMB by mutableStateOf(0.0)
        private set

    init { load() }

    val parseTimes: List<Double> get() = _parseTimes
    val renderTimes: List<Double> get() = _renderTimes

    fun recordParse(durationMs: Double) {
        _parseTimes.add(durationMs)
        save()
    }

    fun recordRender(durationMs: Double) {
        _renderTimes.add(durationMs)
        updateMemory()
        save()
    }

    fun reset() {
        _parseTimes.clear()
        _renderTimes.clear()
        peakMemoryMB = 0.0
        save()
    }

    // Computed metrics (times stored in ms)
    val cardsParsed: Int get() = _parseTimes.size
    val cardsRendered: Int get() = _renderTimes.size

    val avgParseTimeMs: Double get() = if (_parseTimes.isEmpty()) 0.0 else _parseTimes.average()
    val minParseTimeMs: Double get() = _parseTimes.minOrNull() ?: 0.0
    val maxParseTimeMs: Double get() = _parseTimes.maxOrNull() ?: 0.0

    val avgRenderTimeMs: Double get() = if (_renderTimes.isEmpty()) 0.0 else _renderTimes.average()
    val minRenderTimeMs: Double get() = _renderTimes.minOrNull() ?: 0.0
    val maxRenderTimeMs: Double get() = _renderTimes.maxOrNull() ?: 0.0

    val currentMemoryMB: Double get() {
        val runtime = Runtime.getRuntime()
        return (runtime.totalMemory() - runtime.freeMemory()) / (1024.0 * 1024.0)
    }

    private fun updateMemory() {
        val mem = currentMemoryMB
        if (mem > peakMemoryMB) peakMemoryMB = mem
    }

    private fun save() {
        prefs.edit()
            .putString("parseTimes", _parseTimes.joinToString(","))
            .putString("renderTimes", _renderTimes.joinToString(","))
            .putFloat("peakMemoryMB", peakMemoryMB.toFloat())
            .apply()
    }

    private fun load() {
        prefs.getString("parseTimes", null)?.takeIf { it.isNotEmpty() }?.let { s ->
            _parseTimes.addAll(s.split(",").mapNotNull { it.toDoubleOrNull() })
        }
        prefs.getString("renderTimes", null)?.takeIf { it.isNotEmpty() }?.let { s ->
            _renderTimes.addAll(s.split(",").mapNotNull { it.toDoubleOrNull() })
        }
        peakMemoryMB = prefs.getFloat("peakMemoryMB", 0f).toDouble()
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MoreScreen(
    navController: NavController,
    actionLogState: ActionLogState,
    settingsState: SettingsState,
    bookmarkState: BookmarkState
) {
    Scaffold(
        topBar = {
            TopAppBar(title = { Text("More") })
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Bookmarks
            MoreMenuCard(
                icon = Icons.Default.Bookmark,
                iconColor = Color(0xFFFF9800),
                title = "Bookmarks",
                subtitle = "${bookmarkState.bookmarkedFilenames.size} saved cards",
                onClick = { navController.navigate("bookmarks") }
            )

            // Developer Tools section
            Text(
                "Developer Tools",
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(start = 4.dp, top = 8.dp)
            )

            MoreMenuCard(
                icon = Icons.Default.ListAlt,
                iconColor = Color(0xFF1976D2),
                title = "Action Log",
                subtitle = "View dispatched card actions",
                onClick = { navController.navigate("action_log") }
            )

            MoreMenuCard(
                icon = Icons.Default.Speed,
                iconColor = Color(0xFF388E3C),
                title = "Performance",
                subtitle = "Parse & render metrics",
                onClick = { navController.navigate("performance") }
            )

            MoreMenuCard(
                icon = Icons.Default.Settings,
                iconColor = Color(0xFF757575),
                title = "Settings",
                subtitle = "Theme, accessibility, developer",
                onClick = { navController.navigate("settings") }
            )

            Spacer(modifier = Modifier.height(16.dp))

            // App info footer
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .clip(RoundedCornerShape(10.dp))
                        .background(
                            Brush.linearGradient(
                                colors = listOf(Color(0xFF0078D4), Color(0xFF3399FF))
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Default.Layers,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(20.dp)
                    )
                }
                Column {
                    Text(
                        "Adaptive Cards Mobile SDK",
                        style = MaterialTheme.typography.labelMedium
                    )
                    Text(
                        "v1.0.0 (Build 1) \u00B7 Schema v1.6",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // Footnote
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "New Mobile AC Visualizer - Built with ❤️ by Vikrant Singh",
                style = MaterialTheme.typography.bodySmall,
                color = Color(0xFF0078D4),
                textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable {
                        val intent = android.content.Intent(
                            android.content.Intent.ACTION_VIEW,
                            Uri.parse("https://github.com/VikrantSingh01/")
                        )
                        navController.context.startActivity(intent)
                    }
            )
        }
    }
}

@Composable
fun MoreMenuCard(
    icon: ImageVector,
    iconColor: Color,
    title: String,
    subtitle: String,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(iconColor.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    icon,
                    contentDescription = null,
                    tint = iconColor,
                    modifier = Modifier.size(22.dp)
                )
            }
            Column(modifier = Modifier.weight(1f)) {
                Text(title, style = MaterialTheme.typography.titleSmall)
                Text(
                    subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Icon(
                Icons.Default.ChevronRight,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                modifier = Modifier.size(20.dp)
            )
        }
    }
}

private fun handleDeepLink(uri: Uri, navController: NavController) {
    when (uri.host) {
        "card" -> {
            val segments = uri.pathSegments
            if (segments.size >= 2) {
                val cardFilename = "${segments[0]}/${segments[1]}.json"
                navController.navigate("card_detail/${Uri.encode(cardFilename)}") {
                    launchSingleTop = true
                }
            } else if (segments.size == 1) {
                val cardFilename = "${segments[0]}.json"
                navController.navigate("card_detail/${Uri.encode(cardFilename)}") {
                    launchSingleTop = true
                }
            }
        }
        "gallery" -> {
            navController.popBackStack(Screen.Gallery.route, inclusive = false)
        }
        "editor" -> {
            navController.navigate(Screen.Editor.route) {
                launchSingleTop = true
            }
        }
        "performance" -> {
            navController.navigate("performance") {
                launchSingleTop = true
            }
        }
        "bookmarks" -> {
            navController.navigate("bookmarks") {
                launchSingleTop = true
            }
        }
        "settings" -> {
            navController.navigate("settings") {
                launchSingleTop = true
            }
        }
        "more" -> {
            navController.navigate(Screen.More.route) {
                popUpTo(navController.graph.findStartDestination().id) {
                    saveState = true
                }
                launchSingleTop = true
                restoreState = true
            }
        }
    }
}
