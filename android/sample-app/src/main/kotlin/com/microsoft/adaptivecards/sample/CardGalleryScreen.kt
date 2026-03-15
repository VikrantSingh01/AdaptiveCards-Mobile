// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

package com.microsoft.adaptivecards.sample

import android.content.Context
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.BookmarkBorder
import androidx.compose.material.icons.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController

/// Maps deep link filter slugs to CardCategory values
private val filterSlugMap = mapOf(
    "all" to CardCategory.ALL, "basic" to CardCategory.BASIC,
    "inputs" to CardCategory.INPUTS, "actions" to CardCategory.ACTIONS,
    "containers" to CardCategory.CONTAINERS, "advanced" to CardCategory.ADVANCED,
    "teams" to CardCategory.TEAMS, "templating" to CardCategory.TEMPLATING,
    "official" to CardCategory.OFFICIAL, "elements" to CardCategory.ELEMENT,
    "teams-templated" to CardCategory.TEAMS_TEMPLATED,
    "teams-official" to CardCategory.TEAMS_OFFICIAL,
    "edge-cases" to CardCategory.EDGE_CASES
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardGalleryScreen(
    navController: NavController,
    bookmarkState: BookmarkState,
    listState: LazyListState,
    pendingFilter: String? = null,
    onFilterConsumed: () -> Unit = {}
) {
    var searchQuery by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf(CardCategory.ALL) }

    // Apply deep link filter
    LaunchedEffect(pendingFilter) {
        pendingFilter?.let { slug ->
            filterSlugMap[slug]?.let { selectedCategory = it }
            onFilterConsumed()
        }
    }

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
                title = { Text("Gallery") }
            )
        }
    ) { padding ->
        LazyColumn(
            state = listState,
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            contentPadding = PaddingValues(bottom = 16.dp)
        ) {
            // Hero header
            if (searchQuery.isEmpty() && selectedCategory == CardCategory.ALL) {
                item(key = "hero") {
                    HeroHeader(cards, bookmarkState)
                }
            }

            // Search bar
            item(key = "search") {
                OutlinedTextField(
                    value = searchQuery,
                    onValueChange = { searchQuery = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                    placeholder = { Text("Search ${cards.size} cards...") },
                    leadingIcon = { Icon(Icons.Default.Search, null) },
                    singleLine = true,
                    shape = RoundedCornerShape(14.dp)
                )
            }

            // Category chips
            item(key = "chips") {
                Row(
                    modifier = Modifier
                        .horizontalScroll(rememberScrollState())
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    CardCategory.values().forEach { category ->
                        val count = if (category == CardCategory.ALL) cards.size
                            else cards.count { it.category == category }
                        if (count > 0 || category == CardCategory.ALL) {
                            CategoryChip(
                                category = category,
                                count = count,
                                isSelected = selectedCategory == category,
                                onClick = { selectedCategory = category }
                            )
                        }
                    }
                }
            }

            // Results count when filtered
            if (selectedCategory != CardCategory.ALL || searchQuery.isNotEmpty()) {
                item(key = "count") {
                    Text(
                        "${filteredCards.size} results",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(horizontal = 20.dp, vertical = 4.dp)
                    )
                }
            }

            // Card items
            items(filteredCards, key = { it.filename }) { card ->
                CardItem(card, bookmarkState) {
                    navController.navigate("card_detail/${Uri.encode(card.filename)}")
                }
            }
        }
    }
}

@Composable
fun HeroHeader(cards: List<TestCard>, bookmarkState: BookmarkState) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
        )
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(
                            Brush.linearGradient(
                                colors = listOf(Color(0xFF0078D4), Color(0xFF3399FF))
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Default.List,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(28.dp)
                    )
                }
                Column {
                    Text(
                        "AC Visualizer",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        "v1.6 Mobile SDK",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                StatBadge("${cards.size}", "Cards", Color(0xFF0078D4))
                StatBadge(
                    "${CardCategory.values().count { cat -> cat != CardCategory.ALL && cards.any { it.category == cat } }}",
                    "Categories",
                    Color(0xFF7B1FA2)
                )
                StatBadge("${cards.count { it.isAdvanced }}", "Advanced", Color(0xFFFF9800))
                StatBadge("${bookmarkState.bookmarkedFilenames.size}", "Saved", Color(0xFFE91E63))
            }
        }
    }
}

@Composable
fun StatBadge(value: String, label: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            value,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            label,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun CategoryChip(
    category: CardCategory,
    count: Int,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val chipColor = categoryColor(category)
    FilterChip(
        selected = isSelected,
        onClick = onClick,
        label = {
            Row(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(category.displayName)
                if (category != CardCategory.ALL) {
                    Text(
                        "$count",
                        style = MaterialTheme.typography.labelSmall,
                        modifier = Modifier
                            .background(
                                if (isSelected) Color.White.copy(alpha = 0.25f)
                                else chipColor.copy(alpha = 0.12f),
                                CircleShape
                            )
                            .padding(horizontal = 5.dp, vertical = 1.dp)
                    )
                }
            }
        },
        colors = FilterChipDefaults.filterChipColors(
            selectedContainerColor = chipColor,
            selectedLabelColor = Color.White
        )
    )
}

@Composable
fun CardItem(card: TestCard, bookmarkState: BookmarkState, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 10.dp),
        horizontalArrangement = Arrangement.spacedBy(14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Category color indicator
        Box(
            modifier = Modifier
                .width(4.dp)
                .height(44.dp)
                .clip(RoundedCornerShape(4.dp))
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            categoryColor(card.category),
                            categoryColor(card.category).copy(alpha = 0.6f)
                        )
                    )
                )
        )

        Column(modifier = Modifier.weight(1f)) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    card.title,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Medium,
                    maxLines = 1
                )
                if (card.isAdvanced) {
                    Text(
                        "Advanced",
                        style = MaterialTheme.typography.labelSmall,
                        color = Color(0xFF7B1FA2),
                        modifier = Modifier
                            .background(
                                Color(0xFF7B1FA2).copy(alpha = 0.1f),
                                RoundedCornerShape(50)
                            )
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    )
                }
                if (TestCardLoader.hasTemplateData(card.filename)) {
                    Text(
                        "Templated",
                        style = MaterialTheme.typography.labelSmall,
                        color = Color(0xFF00897B),
                        modifier = Modifier
                            .background(
                                Color(0xFF00897B).copy(alpha = 0.1f),
                                RoundedCornerShape(50)
                            )
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    )
                }
            }
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                card.description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                maxLines = 1
            )
        }

        if (bookmarkState.isBookmarked(card.filename)) {
            Icon(
                Icons.Default.Bookmark,
                contentDescription = null,
                tint = Color(0xFFFF9800),
                modifier = Modifier.size(18.dp)
            )
        }

        Icon(
            Icons.Default.KeyboardArrowRight,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.3f),
            modifier = Modifier.size(16.dp)
        )
    }
}

fun categoryColor(category: CardCategory): Color {
    return when (category) {
        CardCategory.ALL -> Color(0xFF0078D4)
        CardCategory.BASIC -> Color(0xFF1976D2)
        CardCategory.INPUTS -> Color(0xFF388E3C)
        CardCategory.ACTIONS -> Color(0xFFFF9800)
        CardCategory.CONTAINERS -> Color(0xFF7B1FA2)
        CardCategory.ADVANCED -> Color(0xFFD32F2F)
        CardCategory.TEAMS -> Color(0xFF3F51B5)
        CardCategory.TEMPLATING -> Color(0xFF00897B)
        CardCategory.OFFICIAL -> Color(0xFF26A69A)
        CardCategory.ELEMENT -> Color(0xFF00ACC1)
        CardCategory.TEAMS_TEMPLATED -> Color(0xFFEC407A)
        CardCategory.TEAMS_OFFICIAL -> Color(0xFF5C6BC0)
        CardCategory.EDGE_CASES -> Color(0xFFFF9800)
        CardCategory.VERSIONED -> Color(0xFF757575)
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
    TEAMS_TEMPLATED("Teams Templated"),
    TEAMS_OFFICIAL("Teams Official"),
    EDGE_CASES("Edge Cases"),
    VERSIONED("Versioned")
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
        Triple("action-overflow.json", "Action Overflow", CardCategory.ACTIONS),
        Triple("teams-connector.json", "Teams Connector", CardCategory.TEAMS),
        Triple("copilot-citations.json", "Copilot Citations", CardCategory.ADVANCED),
        Triple("templating-basic.json", "Basic Templating", CardCategory.TEMPLATING),
        Triple("templating-conditional.json", "Conditional Templating", CardCategory.TEMPLATING),
        Triple("templating-expressions.json", "Expression Templating", CardCategory.TEMPLATING),
        Triple("templating-iteration.json", "Iteration Templating", CardCategory.TEMPLATING),
        Triple("templating-nested.json", "Nested Templating", CardCategory.TEMPLATING),
        Triple("advanced-combined.json", "Advanced Combined", CardCategory.ADVANCED),
        Triple("split-buttons.json", "Split Buttons", CardCategory.ACTIONS),
        Triple("popover-action.json", "Popover Action", CardCategory.ACTIONS),
        Triple("streaming-card.json", "Streaming Card", CardCategory.ADVANCED),
        Triple("themed-images.json", "Themed Images", CardCategory.BASIC),
        Triple("teams-task-module.json", "Teams Task Module", CardCategory.TEAMS),
        Triple("sample-catalog.json", "Sample Catalog", CardCategory.BASIC),
        Triple("edge-all-unknown-types.json", "Edge: Unknown Types", CardCategory.EDGE_CASES),
        Triple("edge-deeply-nested.json", "Edge: Deeply Nested", CardCategory.EDGE_CASES),
        Triple("edge-empty-card.json", "Edge: Empty Card", CardCategory.EDGE_CASES),
        Triple("edge-empty-containers.json", "Edge: Empty Containers", CardCategory.EDGE_CASES),
        Triple("edge-long-text.json", "Edge: Long Text", CardCategory.EDGE_CASES),
        Triple("edge-max-actions.json", "Edge: Max Actions", CardCategory.EDGE_CASES),
        Triple("edge-action-crashes.json", "Edge: Action Crashes", CardCategory.EDGE_CASES),
        Triple("edge-mixed-inputs.json", "Edge: Mixed Inputs", CardCategory.EDGE_CASES),
        Triple("edge-rtl-content.json", "Edge: RTL Content", CardCategory.EDGE_CASES),
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
        Triple("element-samples/container-scrollable.json", "Container Scrollable", CardCategory.ELEMENT),
        Triple("element-samples/media-basic.json", "Media Basic", CardCategory.ELEMENT),
        Triple("element-samples/media-sources.json", "Media Sources", CardCategory.ELEMENT),
        Triple("templates/ActivityUpdate.template.json", "Teams: Activity Update", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/WeatherLarge.template.json", "Teams: Weather Large", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/StockUpdate.template.json", "Teams: Stock Update", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/FlightDetails.template.json", "Teams: Flight Details", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/FlightItinerary.template.json", "Teams: Flight Itinerary", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/FoodOrder.template.json", "Teams: Food Order", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/ExpenseReport.template.json", "Teams: Expense Report", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/CalendarReminder.template.json", "Teams: Calendar Reminder", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/SportingEvent.template.json", "Teams: Sporting Event", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/Restaurant.template.json", "Teams: Restaurant", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/InputForm.template.json", "Teams: Input Form", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/Agenda.template.json", "Teams: Agenda", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/Solitaire.template.json", "Teams: Solitaire", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/SimpleFallback.template.json", "Teams: Simple Fallback", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/CarouselTemplatedPages.template.json", "Teams: Carousel Pages", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/CarouselWhenShowCarousel.template.json", "Teams: Carousel When/Show", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/ProductVideo.template.json", "Teams: Product Video", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/ImageGallery.template.json", "Teams: Image Gallery", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/FlightUpdate.template.json", "Teams: Flight Update", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/OrderConfirmation.template.json", "Teams: Order Confirmation", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/RestaurantOrder.template.json", "Teams: Restaurant Order", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/WeatherCompact.template.json", "Teams: Weather Compact", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/FlightUpdateTable.template.json", "Teams: Flight Update Table", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/OrderDelivery.template.json", "Teams: Order Delivery", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/ApplicationLogin.template.json", "Teams: Application Login", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/InputFormWithRTL.template.json", "Teams: Input Form RTL", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/InputsWithValidation.template.json", "Teams: Inputs Validation", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/ShowCardWizard.template.json", "Teams: ShowCard Wizard", CardCategory.TEAMS_TEMPLATED),
        Triple("templates/Template.Functions.Number.json", "Template: Number Functions", CardCategory.TEMPLATING),
        Triple("templates/Template.Functions.String.json", "Template: String Functions", CardCategory.TEMPLATING),
        Triple("templates/Template.Functions.LogicalComparison.json", "Template: Logic Functions", CardCategory.TEMPLATING),
        Triple("templates/Template.Functions.DateFunctions.json", "Template: Date Functions", CardCategory.TEMPLATING),
        Triple("templates/Template.Functions.DataManipulation.json", "Template: Data Manipulation", CardCategory.TEMPLATING),
        Triple("templates/Template.DataBinding.json", "Template: Data Binding", CardCategory.TEMPLATING),
        Triple("templates/Template.DataBinding.Inline.json", "Template: Inline Binding", CardCategory.TEMPLATING),
        Triple("templates/Template.ConditionalLayout.json", "Template: Conditional Layout", CardCategory.TEMPLATING),
        Triple("templates/Template.Keywords.json", "Template: Keywords", CardCategory.TEMPLATING),
        Triple("templates/Template.RepeatingItems.json", "Template: Repeating Items", CardCategory.TEMPLATING),
        Triple("teams-official-samples/account.json", "Teams: Account", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/author-highlight-video.json", "Teams: Author Highlight Video", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/book-a-room.json", "Teams: Book a Room", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/cafe-menu.json", "Teams: Cafe Menu", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/communication.json", "Teams: Communication", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/course-video.json", "Teams: Course Video", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/editorial.json", "Teams: Editorial", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/expense-report.json", "Teams: Expense Report", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/insights.json", "Teams: Insights", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/issue.json", "Teams: Issue", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/list.json", "Teams: List", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/project-dashboard.json", "Teams: Project Dashboard", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/recipe.json", "Teams: Recipe", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/simple-event.json", "Teams: Simple Event", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/simple-time-off-request.json", "Teams: Simple Time Off Request", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/standard-video.json", "Teams: Standard Video", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/team-standup-summary.json", "Teams: Team Standup Summary", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/time-off-request.json", "Teams: Time Off Request", CardCategory.TEAMS_OFFICIAL),
        Triple("teams-official-samples/work-item.json", "Teams: Work Item", CardCategory.TEAMS_OFFICIAL),
    )

    private val templateDataMap = mapOf(
        "templates/ActivityUpdate.template.json" to "templates/ActivityUpdate.data.json",
        "templates/WeatherLarge.template.json" to "templates/WeatherLarge.data.json",
        "templates/StockUpdate.template.json" to "templates/StockUpdate.data.json",
        "templates/FlightDetails.template.json" to "templates/FlightDetails.data.json",
        "templates/FlightItinerary.template.json" to "templates/FlightItinerary.data.json",
        "templates/FoodOrder.template.json" to "templates/FoodOrder.data.json",
        "templates/ExpenseReport.template.json" to "templates/ExpenseReport.data.json",
        "templates/CalendarReminder.template.json" to "templates/CalendarReminder.data.json",
        "templates/SportingEvent.template.json" to "templates/SportingEvent.data.json",
        "templates/Restaurant.template.json" to "templates/Restaurant.data.json",
        "templates/InputForm.template.json" to "templates/InputForm.data.json",
        "templates/Agenda.template.json" to "templates/Agenda.data.json",
        "templates/Solitaire.template.json" to "templates/Solitaire.data.json",
        "templates/SimpleFallback.template.json" to "templates/SimpleFallback.data.json",
        "templates/CarouselTemplatedPages.template.json" to "templates/CarouselTemplatedPages.data.json",
        "templates/CarouselWhenShowCarousel.template.json" to "templates/CarouselWhenShowCarousel.data.json",
        "templates/ProductVideo.template.json" to "templates/ProductVideo.data.json",
        "templates/ImageGallery.template.json" to "templates/ImageGallery.data.json",
        "templates/FlightUpdate.template.json" to "templates/FlightUpdate.data.json",
        "templates/OrderConfirmation.template.json" to "templates/OrderConfirmation.data.json",
        "templates/RestaurantOrder.template.json" to "templates/RestaurantOrder.data.json",
        "templates/WeatherCompact.template.json" to "templates/WeatherCompact.data.json",
        "templates/FlightUpdateTable.template.json" to "templates/FlightUpdateTable.data.json",
        "templates/OrderDelivery.template.json" to "templates/OrderDelivery.data.json",
        "templates/ApplicationLogin.template.json" to "templates/ApplicationLogin.data.json",
        "templates/InputFormWithRTL.template.json" to "templates/InputFormWithRTL.data.json",
        "templates/InputsWithValidation.template.json" to "templates/InputsWithValidation.data.json",
        "templates/ShowCardWizard.template.json" to "templates/ShowCardWizard.data.json",
        "templates/Template.Functions.Number.json" to "templates/Template.data.json",
        "templates/Template.Functions.String.json" to "templates/Template.data.json",
        "templates/Template.Functions.LogicalComparison.json" to "templates/Template.data.json",
        "templates/Template.Functions.DateFunctions.json" to "templates/Template.data.json",
        "templates/Template.Functions.DataManipulation.json" to "templates/Template.data.json",
        "templates/Template.DataBinding.json" to "templates/Template.data.json",
        "templates/Template.DataBinding.Inline.json" to "templates/Template.data.json",
        "templates/Template.ConditionalLayout.json" to "templates/Template.data.json",
        "templates/Template.Keywords.json" to "templates/Template.data.json",
        "templates/Template.RepeatingItems.json" to "templates/Template.data.json",
        "templating-basic.json" to "templating-basic.data.json",
        "templating-conditional.json" to "templating-conditional.data.json",
        "templating-expressions.json" to "templating-expressions.data.json",
        "templating-iteration.json" to "templating-iteration.data.json",
        "templating-nested.json" to "templating-nested.data.json",
    )

    fun loadAllCards(context: Context): List<TestCard> {
        val cards = cardDefinitions.map { (filename, title, category) ->
            val jsonString = loadCardJson(context, filename)
            TestCard(
                title = title,
                description = descriptionFor(title, category),
                filename = filename,
                category = category,
                isAdvanced = category == CardCategory.ADVANCED,
                jsonString = jsonString
            )
        }.toMutableList()

        // Dynamically discover versioned cards from assets
        cards.addAll(loadVersionedCards(context))

        return cards
    }

    fun loadCardJson(context: Context, filename: String): String {
        return try {
            context.assets.open(filename).bufferedReader().use { it.readText() }
        } catch (e: Exception) {
            """{"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Could not load: $filename","wrap":true,"color":"Attention"}]}"""
        }
    }

    fun loadTemplateData(context: Context, templateFilename: String): String? {
        val dataFilename = templateDataMap[templateFilename] ?: return null
        return try {
            context.assets.open(dataFilename).bufferedReader().use { it.readText() }
        } catch (e: Exception) {
            null
        }
    }

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
            CardCategory.TEAMS_OFFICIAL -> "Teams official sample: $title"
            CardCategory.EDGE_CASES -> "Edge case: $title"
            CardCategory.VERSIONED -> "Versioned card: $title"
            CardCategory.ALL -> "Test card: $title"
        }
    }

    // Dynamically discover versioned cards from assets versioned subdirectories
    private fun loadVersionedCards(context: Context): List<TestCard> {
        val cards = mutableListOf<TestCard>()
        val versions = try {
            context.assets.list("versioned")?.sorted() ?: emptyList()
        } catch (e: Exception) {
            emptyList()
        }
        for (version in versions) {
            val files = try {
                context.assets.list("versioned/$version")?.sorted() ?: emptyList()
            } catch (e: Exception) {
                emptyList()
            }
            for (file in files) {
                if (!file.endsWith(".json")) continue
                val relativePath = "versioned/$version/$file"
                val name = file.removeSuffix(".json")
                val jsonString = loadCardJson(context, relativePath)
                cards.add(
                    TestCard(
                        title = "$version: $name",
                        description = "Versioned card: $name ($version)",
                        filename = relativePath,
                        category = CardCategory.VERSIONED,
                        isAdvanced = false,
                        jsonString = jsonString
                    )
                )
            }
        }
        return cards
    }
}
