package com.microsoft.adaptivecards.sample

import android.content.Context
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.FilterList
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.microsoft.adaptivecards.rendering.composables.AdaptiveCardView
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardGalleryScreen(navController: NavController) {
    var searchQuery by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf(CardCategory.ALL) }
    var showFilterMenu by remember { mutableStateOf(false) }

    val context = LocalContext.current
    val cards = remember { TestCardLoader.loadAllCards(context) }
    val filteredCards = remember(searchQuery, selectedCategory) {
        cards.filter { card ->
            val matchesCategory = selectedCategory == CardCategory.ALL || card.category == selectedCategory
            val matchesSearch = searchQuery.isEmpty() ||
                card.title.contains(searchQuery, ignoreCase = true) ||
                card.description.contains(searchQuery, ignoreCase = true)
            matchesCategory && matchesSearch
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Card Gallery") },
                actions = {
                    IconButton(onClick = { showFilterMenu = true }) {
                        Icon(Icons.Default.FilterList, "Filter")
                    }
                    DropdownMenu(
                        expanded = showFilterMenu,
                        onDismissRequest = { showFilterMenu = false }
                    ) {
                        CardCategory.values().forEach { category ->
                            DropdownMenuItem(
                                text = { Text(category.displayName) },
                                onClick = {
                                    selectedCategory = category
                                    showFilterMenu = false
                                }
                            )
                        }
                    }
                }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding)) {
            // Search bar
            OutlinedTextField(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                placeholder = { Text("Search cards...") },
                leadingIcon = { Icon(Icons.Default.Search, null) },
                singleLine = true
            )

            // Cards list
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(filteredCards, key = { it.filename }) { card ->
                    CardItem(card) {
                        navController.navigate("card_detail/${card.filename}")
                    }
                }
            }
        }
    }
}

@Composable
fun CardItem(card: TestCard, onClick: () -> Unit) {
    val cardViewModel: CardViewModel = viewModel(key = "gallery_${card.filename}")

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = card.title,
                style = MaterialTheme.typography.titleMedium
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = card.description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(modifier = Modifier.height(8.dp))

            // Render actual card preview
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(max = 200.dp)
                    .clipToBounds(),
                color = MaterialTheme.colorScheme.surface,
                tonalElevation = 1.dp,
                shape = MaterialTheme.shapes.small
            ) {
                AdaptiveCardView(
                    cardJson = card.jsonString,
                    modifier = Modifier.padding(8.dp),
                    viewModel = cardViewModel
                )
            }

            Spacer(modifier = Modifier.height(8.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                AssistChip(
                    onClick = {},
                    label = { Text(card.category.displayName) }
                )
                if (card.isAdvanced) {
                    AssistChip(
                        onClick = {},
                        label = { Text("Advanced") }
                    )
                }
            }
        }
    }
}

enum class CardCategory(val displayName: String) {
    ALL("All"),
    BASIC("Basic"),
    INPUTS("Inputs"),
    ACTIONS("Actions"),
    CONTAINERS("Containers"),
    ADVANCED("Advanced"),
    TEAMS("Teams"),
    TEMPLATING("Templating")
}

data class TestCard(
    val title: String,
    val description: String,
    val filename: String,
    val category: CardCategory,
    val isAdvanced: Boolean,
    val jsonString: String
)

object TestCardLoader {

    private val cardDefinitions = listOf(
        Triple("simple-text.json", "Simple Text", CardCategory.BASIC),
        Triple("rich-text.json", "Rich Text", CardCategory.BASIC),
        Triple("containers.json", "Containers", CardCategory.CONTAINERS),
        Triple("all-inputs.json", "All Input Types", CardCategory.INPUTS),
        Triple("input-form.json", "Input Form", CardCategory.INPUTS),
        Triple("all-actions.json", "All Action Types", CardCategory.ACTIONS),
        Triple("markdown.json", "Markdown", CardCategory.BASIC),
        Triple("charts.json", "Charts", CardCategory.ADVANCED),
        Triple("datagrid.json", "DataGrid", CardCategory.ADVANCED),
        Triple("list.json", "List", CardCategory.CONTAINERS),
        Triple("carousel.json", "Carousel", CardCategory.CONTAINERS),
        Triple("accordion.json", "Accordion", CardCategory.CONTAINERS),
        Triple("tab-set.json", "Tab Set", CardCategory.CONTAINERS),
        Triple("table.json", "Table", CardCategory.CONTAINERS),
        Triple("media.json", "Media", CardCategory.BASIC),
        Triple("progress-indicators.json", "Progress Indicators", CardCategory.BASIC),
        Triple("rating.json", "Rating", CardCategory.BASIC),
        Triple("code-block.json", "Code Block", CardCategory.ADVANCED),
        Triple("fluent-theming.json", "Fluent Theming", CardCategory.ADVANCED),
        Triple("responsive-layout.json", "Responsive Layout", CardCategory.ADVANCED),
        Triple("compound-buttons.json", "Compound Buttons", CardCategory.ACTIONS),
        Triple("teams-connector.json", "Teams Connector", CardCategory.TEAMS),
        Triple("copilot-citations.json", "Copilot Citations", CardCategory.ADVANCED),
        Triple("templating-basic.json", "Basic Templating", CardCategory.TEMPLATING),
    )

    /**
     * Load all test cards with their actual JSON content from the assets directory.
     */
    fun loadAllCards(context: Context): List<TestCard> {
        return cardDefinitions.map { (filename, title, category) ->
            val jsonString = loadCardJson(context, filename)
            TestCard(
                title = title,
                description = descriptionFor(title, category),
                filename = filename,
                category = category,
                isAdvanced = category == CardCategory.ADVANCED,
                jsonString = jsonString
            )
        }
    }

    /**
     * Load a single card's JSON by filename.
     */
    fun loadCardJson(context: Context, filename: String): String {
        return try {
            context.assets.open(filename).bufferedReader().use { it.readText() }
        } catch (e: Exception) {
            // Fallback: return a minimal card with the filename as the title
            """{"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Could not load: $filename","wrap":true,"color":"Attention"}]}"""
        }
    }

    private fun descriptionFor(title: String, category: CardCategory): String {
        return when (category) {
            CardCategory.BASIC -> "Basic card demonstrating $title rendering"
            CardCategory.INPUTS -> "Input elements: $title"
            CardCategory.ACTIONS -> "Action types: $title"
            CardCategory.CONTAINERS -> "Container layout: $title"
            CardCategory.ADVANCED -> "Advanced feature: $title"
            CardCategory.TEAMS -> "Teams integration: $title"
            CardCategory.TEMPLATING -> "Data binding: $title"
            CardCategory.ALL -> "Test card: $title"
        }
    }
}
