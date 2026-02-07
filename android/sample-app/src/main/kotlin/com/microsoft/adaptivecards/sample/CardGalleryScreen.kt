package com.microsoft.adaptivecards.sample

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
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardGalleryScreen(navController: NavController) {
    var searchQuery by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf(CardCategory.ALL) }
    var showFilterMenu by remember { mutableStateOf(false) }
    
    val cards = remember { TestCardLoader.loadAllCards() }
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
                items(filteredCards) { card ->
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
    fun loadAllCards(): List<TestCard> {
        val cardDefinitions = listOf(
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

        return cardDefinitions.map { (filename, title, category) ->
            TestCard(
                title = title,
                description = "Test card: $title",
                filename = filename,
                category = category,
                isAdvanced = category == CardCategory.ADVANCED,
                jsonString = """{"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"$title"}]}"""
            )
        }
    }
}
