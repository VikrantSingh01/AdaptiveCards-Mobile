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
    TEMPLATING("Templating"),
    OFFICIAL("Official Samples"),
    ELEMENT("Element Samples"),
    TEAMS_TEMPLATED("Teams Templated")
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
        // --- Existing test cards ---
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

        // --- Official samples (from shared/test-cards/official-samples/) ---
        Triple("official-samples/activity-update.json", "Activity Update", CardCategory.OFFICIAL),
        Triple("official-samples/agenda.json", "Agenda", CardCategory.OFFICIAL),
        Triple("official-samples/application-login.json", "Application Login", CardCategory.OFFICIAL),
        Triple("official-samples/calendar-reminder.json", "Calendar Reminder", CardCategory.OFFICIAL),
        Triple("official-samples/expense-report.json", "Expense Report", CardCategory.OFFICIAL),
        Triple("official-samples/flight-details.json", "Flight Details", CardCategory.OFFICIAL),
        Triple("official-samples/flight-itinerary.json", "Flight Itinerary", CardCategory.OFFICIAL),
        Triple("official-samples/flight-update.json", "Flight Update", CardCategory.OFFICIAL),
        Triple("official-samples/flight-update-table.json", "Flight Update Table", CardCategory.OFFICIAL),
        Triple("official-samples/food-order.json", "Food Order", CardCategory.OFFICIAL),
        Triple("official-samples/image-gallery.json", "Image Gallery", CardCategory.OFFICIAL),
        Triple("official-samples/input-form-official.json", "Input Form (Official)", CardCategory.OFFICIAL),
        Triple("official-samples/input-form-rtl.json", "Input Form RTL", CardCategory.OFFICIAL),
        Triple("official-samples/inputs-with-validation.json", "Inputs with Validation", CardCategory.OFFICIAL),
        Triple("official-samples/order-confirmation.json", "Order Confirmation", CardCategory.OFFICIAL),
        Triple("official-samples/order-delivery.json", "Order Delivery", CardCategory.OFFICIAL),
        Triple("official-samples/restaurant.json", "Restaurant", CardCategory.OFFICIAL),
        Triple("official-samples/restaurant-order.json", "Restaurant Order", CardCategory.OFFICIAL),
        Triple("official-samples/show-card-wizard.json", "Show Card Wizard", CardCategory.OFFICIAL),
        Triple("official-samples/sporting-event.json", "Sporting Event", CardCategory.OFFICIAL),
        Triple("official-samples/stock-update.json", "Stock Update", CardCategory.OFFICIAL),
        Triple("official-samples/weather-compact.json", "Weather Compact", CardCategory.OFFICIAL),
        Triple("official-samples/weather-large.json", "Weather Large", CardCategory.OFFICIAL),
        Triple("official-samples/product-video.json", "Product Video", CardCategory.OFFICIAL),

        // --- Element samples (from shared/test-cards/element-samples/) ---
        Triple("element-samples/action-execute-is-enabled.json", "Action Execute isEnabled", CardCategory.ELEMENT),
        Triple("element-samples/action-execute-mode.json", "Action Execute Mode", CardCategory.ELEMENT),
        Triple("element-samples/action-execute-tooltip.json", "Action Execute Tooltip", CardCategory.ELEMENT),
        Triple("element-samples/action-openurl-is-enabled.json", "Action OpenUrl isEnabled", CardCategory.ELEMENT),
        Triple("element-samples/action-openurl-mode.json", "Action OpenUrl Mode", CardCategory.ELEMENT),
        Triple("element-samples/action-openurl-tooltip.json", "Action OpenUrl Tooltip", CardCategory.ELEMENT),
        Triple("element-samples/action-showcard-is-enabled.json", "Action ShowCard isEnabled", CardCategory.ELEMENT),
        Triple("element-samples/action-showcard-mode.json", "Action ShowCard Mode", CardCategory.ELEMENT),
        Triple("element-samples/action-showcard-tooltip.json", "Action ShowCard Tooltip", CardCategory.ELEMENT),
        Triple("element-samples/action-submit-is-enabled.json", "Action Submit isEnabled", CardCategory.ELEMENT),
        Triple("element-samples/action-submit-mode.json", "Action Submit Mode", CardCategory.ELEMENT),
        Triple("element-samples/action-submit-tooltip.json", "Action Submit Tooltip", CardCategory.ELEMENT),
        Triple("element-samples/action-role.json", "Action Role", CardCategory.ELEMENT),
        Triple("element-samples/adaptive-card-rtl.json", "Adaptive Card RTL", CardCategory.ELEMENT),
        Triple("element-samples/column-rtl.json", "Column RTL", CardCategory.ELEMENT),
        Triple("element-samples/container-rtl.json", "Container RTL", CardCategory.ELEMENT),
        Triple("element-samples/image-select-action.json", "Image Select Action", CardCategory.ELEMENT),
        Triple("element-samples/image-force-load.json", "Image Force Load", CardCategory.ELEMENT),
        Triple("element-samples/imageset-stacked-style.json", "ImageSet Stacked Style", CardCategory.ELEMENT),
        Triple("element-samples/input-choiceset-filtered.json", "Input ChoiceSet Filtered", CardCategory.ELEMENT),
        Triple("element-samples/input-choiceset-dynamic-typeahead.json", "Input ChoiceSet Dynamic", CardCategory.ELEMENT),
        Triple("element-samples/input-text-password-style.json", "Input Text Password", CardCategory.ELEMENT),
        Triple("element-samples/input-label-position.json", "Input Label Position", CardCategory.ELEMENT),
        Triple("element-samples/input-style.json", "Input Style", CardCategory.ELEMENT),
        Triple("element-samples/input-toggle-consolidated.json", "Input Toggle Consolidated", CardCategory.ELEMENT),
        Triple("element-samples/table-basic.json", "Table Basic", CardCategory.ELEMENT),
        Triple("element-samples/table-first-row-headers.json", "Table First Row Headers", CardCategory.ELEMENT),
        Triple("element-samples/table-grid-style.json", "Table Grid Style", CardCategory.ELEMENT),
        Triple("element-samples/table-horizontal-alignment.json", "Table Horizontal Alignment", CardCategory.ELEMENT),
        Triple("element-samples/table-show-grid-lines.json", "Table Show Grid Lines", CardCategory.ELEMENT),
        Triple("element-samples/table-vertical-alignment.json", "Table Vertical Alignment", CardCategory.ELEMENT),
        Triple("element-samples/textblock-style.json", "TextBlock Style", CardCategory.ELEMENT),
        Triple("element-samples/carousel-basic.json", "Carousel Basic", CardCategory.ELEMENT),
        Triple("element-samples/carousel-header.json", "Carousel Header", CardCategory.ELEMENT),
        Triple("element-samples/carousel-height.json", "Carousel Height", CardCategory.ELEMENT),
        Triple("element-samples/carousel-height-pixels.json", "Carousel Height Pixels", CardCategory.ELEMENT),
        Triple("element-samples/carousel-height-vertical.json", "Carousel Height Vertical", CardCategory.ELEMENT),
        Triple("element-samples/carousel-initial-page.json", "Carousel Initial Page", CardCategory.ELEMENT),
        Triple("element-samples/carousel-loop.json", "Carousel Loop", CardCategory.ELEMENT),
        Triple("element-samples/carousel-scenario-cards.json", "Carousel Scenario Cards", CardCategory.ELEMENT),
        Triple("element-samples/carousel-scenario-timer.json", "Carousel Scenario Timer", CardCategory.ELEMENT),
        Triple("element-samples/carousel-styles.json", "Carousel Styles", CardCategory.ELEMENT),
        Triple("element-samples/carousel-vertical.json", "Carousel Vertical", CardCategory.ELEMENT),
        Triple("element-samples/media-basic.json", "Media Basic", CardCategory.ELEMENT),
        Triple("element-samples/media-sources.json", "Media Sources", CardCategory.ELEMENT),

        // --- Teams templated samples (template + data pairs from shared/test-cards/teams-samples/) ---
        Triple("teams-samples/activity-update-template.json", "Teams: Activity Update", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/weather-large-template.json", "Teams: Weather Large", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/stock-update-template.json", "Teams: Stock Update", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/flight-details-template.json", "Teams: Flight Details", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/flight-itinerary-template.json", "Teams: Flight Itinerary", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/food-order-template.json", "Teams: Food Order", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/expense-report-template.json", "Teams: Expense Report", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/calendar-reminder-template.json", "Teams: Calendar Reminder", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/sporting-event-template.json", "Teams: Sporting Event", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/restaurant-template.json", "Teams: Restaurant", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/input-form-template.json", "Teams: Input Form", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/agenda-template.json", "Teams: Agenda", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/solitaire-template.json", "Teams: Solitaire", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/simple-fallback-template.json", "Teams: Simple Fallback", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/carousel-templated-pages-template.json", "Teams: Carousel Pages", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/carousel-when-show-template.json", "Teams: Carousel When/Show", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/product-video-template.json", "Teams: Product Video", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/image-gallery-template.json", "Teams: Image Gallery", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/flight-update-template.json", "Teams: Flight Update", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/order-confirmation-template.json", "Teams: Order Confirmation", CardCategory.TEAMS_TEMPLATED),
        Triple("teams-samples/restaurant-order-template.json", "Teams: Restaurant Order", CardCategory.TEAMS_TEMPLATED),
    )

    /**
     * Map of template filenames to their corresponding data filenames
     * for teams-samples that use templating.
     */
    private val templateDataMap = mapOf(
        "teams-samples/activity-update-template.json" to "teams-samples/activity-update-data.json",
        "teams-samples/weather-large-template.json" to "teams-samples/weather-large-data.json",
        "teams-samples/stock-update-template.json" to "teams-samples/stock-update-data.json",
        "teams-samples/flight-details-template.json" to "teams-samples/flight-details-data.json",
        "teams-samples/flight-itinerary-template.json" to "teams-samples/flight-itinerary-data.json",
        "teams-samples/food-order-template.json" to "teams-samples/food-order-data.json",
        "teams-samples/expense-report-template.json" to "teams-samples/expense-report-data.json",
        "teams-samples/calendar-reminder-template.json" to "teams-samples/calendar-reminder-data.json",
        "teams-samples/sporting-event-template.json" to "teams-samples/sporting-event-data.json",
        "teams-samples/restaurant-template.json" to "teams-samples/restaurant-data.json",
        "teams-samples/input-form-template.json" to "teams-samples/input-form-data.json",
        "teams-samples/agenda-template.json" to "teams-samples/agenda-data.json",
        "teams-samples/solitaire-template.json" to "teams-samples/solitaire-data.json",
        "teams-samples/simple-fallback-template.json" to "teams-samples/simple-fallback-data.json",
        "teams-samples/carousel-templated-pages-template.json" to "teams-samples/carousel-templated-pages-data.json",
        "teams-samples/carousel-when-show-template.json" to "teams-samples/carousel-when-show-data.json",
        "teams-samples/product-video-template.json" to "teams-samples/product-video-data.json",
        "teams-samples/image-gallery-template.json" to "teams-samples/image-gallery-data.json",
        "teams-samples/flight-update-template.json" to "teams-samples/flight-update-data.json",
        "teams-samples/order-confirmation-template.json" to "teams-samples/order-confirmation-data.json",
        "teams-samples/restaurant-order-template.json" to "teams-samples/restaurant-order-data.json",
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

    /**
     * Load the data JSON for a teams-samples template file, if available.
     * Returns null if no data file exists for the given template.
     */
    fun loadTemplateData(context: Context, templateFilename: String): String? {
        val dataFilename = templateDataMap[templateFilename] ?: return null
        return try {
            context.assets.open(dataFilename).bufferedReader().use { it.readText() }
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Check if a card filename has an associated data file for templating.
     */
    fun hasTemplateData(filename: String): Boolean {
        return templateDataMap.containsKey(filename)
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
            CardCategory.OFFICIAL -> "Official sample: $title"
            CardCategory.ELEMENT -> "Element test: $title"
            CardCategory.TEAMS_TEMPLATED -> "Teams templated: $title"
            CardCategory.ALL -> "Test card: $title"
        }
    }
}
