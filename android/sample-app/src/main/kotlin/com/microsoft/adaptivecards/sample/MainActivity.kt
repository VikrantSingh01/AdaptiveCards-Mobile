package com.microsoft.adaptivecards.sample

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.microsoft.adaptivecards.sample.ui.theme.AdaptiveCardsSampleTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AdaptiveCardsSampleTheme {
                MainScreen()
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen() {
    val navController = rememberNavController()
    val actionLogState = remember { ActionLogState() }
    val settingsState = remember { SettingsState() }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            NavigationBar {
                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentDestination = navBackStackEntry?.destination

                val items = listOf(
                    Screen.Gallery,
                    Screen.Editor,
                    Screen.Teams,
                    Screen.More
                )

                items.forEach { screen ->
                    NavigationBarItem(
                        icon = { Icon(screen.icon, contentDescription = screen.label) },
                        label = { Text(screen.label) },
                        selected = currentDestination?.hierarchy?.any { it.route == screen.route } == true,
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
                CardGalleryScreen(navController)
            }
            composable(Screen.Editor.route) {
                CardEditorScreen(actionLogState)
            }
            composable(Screen.Teams.route) {
                TeamsSimulatorScreen(actionLogState)
            }
            composable(Screen.More.route) {
                MoreScreen(navController, actionLogState, settingsState)
            }
            composable("card_detail/{cardId}") { backStackEntry ->
                val cardId = backStackEntry.arguments?.getString("cardId") ?: ""
                CardDetailScreen(cardId, actionLogState)
            }
            composable("action_log") {
                ActionLogScreen(actionLogState)
            }
            composable("settings") {
                SettingsScreen(settingsState)
            }
            composable("performance") {
                PerformanceDashboardScreen()
            }
        }
    }
}

sealed class Screen(val route: String, val label: String, val icon: androidx.compose.ui.graphics.vector.ImageVector) {
    object Gallery : Screen("gallery", "Gallery", Icons.Default.GridView)
    object Editor : Screen("editor", "Editor", Icons.Default.Edit)
    object Teams : Screen("teams", "Teams", Icons.Default.Message)
    object More : Screen("more", "More", Icons.Default.MoreHoriz)
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

class SettingsState {
    var theme by mutableStateOf(Theme.SYSTEM)
    var fontScale by mutableFloatStateOf(1.0f)
    var enableAccessibility by mutableStateOf(true)
    var enablePerformanceMetrics by mutableStateOf(false)

    enum class Theme {
        LIGHT, DARK, SYSTEM
    }
}

@Composable
fun MoreScreen(
    navController: androidx.navigation.NavController,
    actionLogState: ActionLogState,
    settingsState: SettingsState
) {
    Surface(modifier = Modifier.fillMaxSize()) {
        Column {
            Text(
                "More",
                style = MaterialTheme.typography.headlineMedium,
                modifier = Modifier.padding(16.dp)
            )

            ListItem(
                headlineContent = { Text("Action Log") },
                leadingContent = { Icon(Icons.Default.Menu, null) },
                modifier = Modifier.clickable { navController.navigate("action_log") }
            )

            ListItem(
                headlineContent = { Text("Performance") },
                leadingContent = { Icon(Icons.Default.Speed, null) },
                modifier = Modifier.clickable { navController.navigate("performance") }
            )

            ListItem(
                headlineContent = { Text("Settings") },
                leadingContent = { Icon(Icons.Default.Settings, null) },
                modifier = Modifier.clickable { navController.navigate("settings") }
            )
        }
    }
}
