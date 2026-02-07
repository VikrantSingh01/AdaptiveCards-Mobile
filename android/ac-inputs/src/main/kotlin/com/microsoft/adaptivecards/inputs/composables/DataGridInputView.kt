package com.microsoft.adaptivecards.inputs.composables

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.microsoft.adaptivecards.core.models.InputDataGrid
import com.microsoft.adaptivecards.core.models.DataGridColumn
import com.microsoft.adaptivecards.rendering.viewmodel.CardViewModel
import kotlinx.serialization.json.*
import java.text.SimpleDateFormat
import java.util.*

/**
 * Renders an Input.DataGrid element (editable data grid)
 * Features: Editable cells, sorting, add/remove rows, horizontal scroll
 * Accessibility: TalkBack support with row/column announcements
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DataGridInputView(
    element: InputDataGrid,
    viewModel: CardViewModel,
    modifier: Modifier = Modifier
) {
    var gridData by remember {
        mutableStateOf(
            element.rows?.map { it.toMutableList() }?.toMutableList()
                ?: mutableListOf()
        )
    }
    
    var sortColumn by remember { mutableStateOf<String?>(null) }
    var sortAscending by remember { mutableStateOf(true) }
    var showDatePicker by remember { mutableStateOf(false) }
    var selectedDateCell by remember { mutableStateOf<Pair<Int, Int>?>(null) }
    var tempDate by remember { mutableStateOf(Date()) }
    
    val error = viewModel.getValidationError(element.id ?: "")
    val configuration = LocalConfiguration.current
    val isTablet = configuration.screenWidthDp >= 600
    
    // Update viewModel with grid data
    LaunchedEffect(gridData) {
        element.id?.let { id ->
            viewModel.updateInputValue(id, gridData)
            
            val validationError = if (element.isRequired && gridData.isEmpty()) {
                element.errorMessage ?: "Data grid cannot be empty"
            } else {
                null
            }
            viewModel.setValidationError(id, validationError)
        }
    }
    
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(8.dp)
    ) {
        // Label
        element.label?.let { label ->
            Text(
                text = label + if (element.isRequired) " *" else "",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(bottom = 4.dp)
            )
        }
        
        // Grid Container
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = 400.dp),
            tonalElevation = 1.dp
        ) {
            Column {
                // Header Row
                Row(
                    modifier = Modifier
                        .horizontalScroll(rememberScrollState())
                        .background(MaterialTheme.colorScheme.surfaceVariant)
                ) {
                    element.columns.forEachIndexed { colIndex, column ->
                        HeaderCell(
                            column = column,
                            sortColumn = sortColumn,
                            sortAscending = sortAscending,
                            onSort = {
                                if (column.isSortable != false) {
                                    if (sortColumn == column.id) {
                                        sortAscending = !sortAscending
                                    } else {
                                        sortColumn = column.id
                                        sortAscending = true
                                    }
                                    sortGridData(gridData, colIndex, sortAscending)
                                }
                            },
                            modifier = Modifier.width(columnWidth(column, isTablet))
                        )
                    }
                    
                    // Delete column header
                    Box(
                        modifier = Modifier
                            .width(60.dp)
                            .height(48.dp)
                            .background(MaterialTheme.colorScheme.surfaceVariant)
                    )
                }
                
                // Data Rows
                LazyColumn(
                    modifier = Modifier.weight(1f, fill = false)
                ) {
                    itemsIndexed(gridData) { rowIndex, row ->
                        DataRow(
                            rowIndex = rowIndex,
                            row = row,
                            columns = element.columns,
                            isTablet = isTablet,
                            onCellChange = { colIndex, newValue ->
                                gridData[rowIndex][colIndex] = newValue
                                gridData = gridData.toMutableList()
                            },
                            onDateCellClick = { colIndex ->
                                selectedDateCell = Pair(rowIndex, colIndex)
                                val cellValue = row[colIndex]
                                tempDate = parseDateFromJson(cellValue) ?: Date()
                                showDatePicker = true
                            },
                            onDeleteRow = {
                                gridData.removeAt(rowIndex)
                                gridData = gridData.toMutableList()
                            }
                        )
                    }
                }
            }
        }
        
        // Add Row Button and Counter
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Button(
                onClick = {
                    if (element.maxRows == null || gridData.size < element.maxRows) {
                        val newRow = element.columns.map { column ->
                            when (column.type) {
                                "toggle" -> JsonPrimitive(false)
                                "number" -> JsonPrimitive(0)
                                else -> JsonPrimitive("")
                            }
                        }.toMutableList()
                        gridData.add(newRow)
                        gridData = gridData.toMutableList()
                    }
                },
                enabled = element.maxRows == null || gridData.size < element.maxRows,
                modifier = Modifier
                    .height(48.dp)
                    .semantics {
                        contentDescription = "Add new row to data grid"
                    }
            ) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text("Add Row")
            }
            
            Text(
                text = "${gridData.size}${element.maxRows?.let { " / $it" } ?: ""}",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        
        // Error Message
        error?.let { errorMsg ->
            Text(
                text = errorMsg,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier.padding(top = 4.dp)
            )
        }
    }
    
    // Date Picker Dialog
    if (showDatePicker && selectedDateCell != null) {
        val datePickerState = rememberDatePickerState(
            initialSelectedDateMillis = tempDate.time
        )
        
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    datePickerState.selectedDateMillis?.let { millis ->
                        val formatter = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
                        val dateString = formatter.format(Date(millis))
                        selectedDateCell?.let { (row, col) ->
                            gridData[row][col] = JsonPrimitive(dateString)
                            gridData = gridData.toMutableList()
                        }
                    }
                    showDatePicker = false
                }) {
                    Text("OK")
                }
            },
            dismissButton = {
                TextButton(onClick = { showDatePicker = false }) {
                    Text("Cancel")
                }
            }
        ) {
            DatePicker(state = datePickerState)
        }
    }
}

@Composable
private fun HeaderCell(
    column: DataGridColumn,
    sortColumn: String?,
    sortAscending: Boolean,
    onSort: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isSortable = column.isSortable != false
    
    Surface(
        onClick = { if (isSortable) onSort() },
        modifier = modifier
            .height(48.dp)
            .semantics {
                contentDescription = "${column.title} column header${if (isSortable) ", sortable" else ""}"
            }
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = column.title,
                style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold),
                maxLines = 1,
                modifier = Modifier.weight(1f)
            )
            
            if (isSortable) {
                Icon(
                    imageVector = when {
                        sortColumn != column.id -> Icons.Default.UnfoldMore
                        sortAscending -> Icons.Default.KeyboardArrowUp
                        else -> Icons.Default.KeyboardArrowDown
                    },
                    contentDescription = null,
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
}

@Composable
private fun DataRow(
    rowIndex: Int,
    row: List<JsonElement>,
    columns: List<DataGridColumn>,
    isTablet: Boolean,
    onCellChange: (colIndex: Int, newValue: JsonElement) -> Unit,
    onDateCellClick: (colIndex: Int) -> Unit,
    onDeleteRow: () -> Unit
) {
    Row(
        modifier = Modifier
            .horizontalScroll(rememberScrollState())
            .background(if (rowIndex % 2 == 0) Color.White else Color(0xFFF5F5F5))
    ) {
        columns.forEachIndexed { colIndex, column ->
            CellView(
                rowIndex = rowIndex,
                colIndex = colIndex,
                column = column,
                value = row.getOrNull(colIndex) ?: JsonNull,
                isTablet = isTablet,
                onValueChange = { newValue ->
                    onCellChange(colIndex, newValue)
                },
                onDateClick = {
                    onDateCellClick(colIndex)
                }
            )
        }
        
        // Delete button
        IconButton(
            onClick = onDeleteRow,
            modifier = Modifier
                .width(60.dp)
                .height(48.dp)
                .semantics {
                    contentDescription = "Delete row ${rowIndex + 1}"
                }
        ) {
            Icon(
                imageVector = Icons.Default.Delete,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.error
            )
        }
    }
}

@Composable
private fun CellView(
    rowIndex: Int,
    colIndex: Int,
    column: DataGridColumn,
    value: JsonElement,
    isTablet: Boolean,
    onValueChange: (JsonElement) -> Unit,
    onDateClick: () -> Unit
) {
    val isEditable = column.isEditable != false
    val cellDescription = "Row ${rowIndex + 1}, ${column.title}: ${jsonToString(value)}"
    
    Box(
        modifier = Modifier
            .width(columnWidth(column, isTablet))
            .height(48.dp)
            .border(0.5.dp, Color.Gray.copy(alpha = 0.3f))
            .padding(8.dp)
            .semantics {
                contentDescription = cellDescription
            }
    ) {
        when (column.type) {
            "text" -> TextCell(value, isEditable, onValueChange)
            "number" -> NumberCell(value, isEditable, onValueChange)
            "date" -> DateCell(value, isEditable, onDateClick)
            "toggle" -> ToggleCell(value, isEditable, onValueChange)
            else -> TextCell(value, isEditable, onValueChange)
        }
    }
}

@Composable
private fun TextCell(
    value: JsonElement,
    isEditable: Boolean,
    onValueChange: (JsonElement) -> Unit
) {
    var textValue by remember(value) { mutableStateOf(jsonToString(value)) }
    
    BasicTextField(
        value = textValue,
        onValueChange = { newValue ->
            textValue = newValue
            onValueChange(JsonPrimitive(newValue))
        },
        enabled = isEditable,
        textStyle = TextStyle(
            fontSize = 14.sp,
            color = if (isEditable) Color.Black else Color.Gray
        ),
        singleLine = true,
        modifier = Modifier.fillMaxSize()
    )
}

@Composable
private fun NumberCell(
    value: JsonElement,
    isEditable: Boolean,
    onValueChange: (JsonElement) -> Unit
) {
    var textValue by remember(value) { mutableStateOf(jsonToString(value)) }
    
    BasicTextField(
        value = textValue,
        onValueChange = { newValue ->
            textValue = newValue
            val numValue = newValue.toDoubleOrNull()
            if (numValue != null) {
                onValueChange(JsonPrimitive(numValue))
            } else if (newValue.isEmpty()) {
                onValueChange(JsonNull)
            }
        },
        enabled = isEditable,
        textStyle = TextStyle(
            fontSize = 14.sp,
            color = if (isEditable) Color.Black else Color.Gray
        ),
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
        singleLine = true,
        modifier = Modifier.fillMaxSize()
    )
}

@Composable
private fun DateCell(
    value: JsonElement,
    isEditable: Boolean,
    onDateClick: () -> Unit
) {
    TextButton(
        onClick = { if (isEditable) onDateClick() },
        enabled = isEditable,
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(0.dp)
    ) {
        Text(
            text = jsonToString(value),
            style = MaterialTheme.typography.bodyMedium,
            maxLines = 1
        )
    }
}

@Composable
private fun ToggleCell(
    value: JsonElement,
    isEditable: Boolean,
    onValueChange: (JsonElement) -> Unit
) {
    val boolValue = when {
        value is JsonPrimitive && value.isString -> value.content.equals("true", ignoreCase = true)
        value is JsonPrimitive && value.booleanOrNull != null -> value.boolean
        else -> false
    }
    
    Switch(
        checked = boolValue,
        onCheckedChange = { newValue ->
            onValueChange(JsonPrimitive(newValue))
        },
        enabled = isEditable,
        modifier = Modifier.fillMaxSize()
    )
}

private fun columnWidth(column: DataGridColumn, isTablet: Boolean): androidx.compose.ui.unit.Dp {
    column.width?.let { width ->
        when {
            width == "stretch" -> return if (isTablet) 250.dp else 200.dp
            width == "auto" -> return if (isTablet) 120.dp else 100.dp
            width.endsWith("px") -> {
                val pixels = width.removeSuffix("px").toIntOrNull() ?: 120
                return pixels.dp
            }
        }
    }
    return if (isTablet) 150.dp else 120.dp
}

private fun jsonToString(value: JsonElement): String {
    return when {
        value is JsonNull -> ""
        value is JsonPrimitive && value.isString -> value.content
        value is JsonPrimitive && value.booleanOrNull != null -> if (value.boolean) "Yes" else "No"
        value is JsonPrimitive -> value.content
        else -> ""
    }
}

private fun parseDateFromJson(value: JsonElement): Date? {
    if (value !is JsonPrimitive || !value.isString) return null
    return try {
        SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).parse(value.content)
    } catch (e: Exception) {
        null
    }
}

private fun sortGridData(
    gridData: MutableList<MutableList<JsonElement>>,
    colIndex: Int,
    ascending: Boolean
) {
    gridData.sortWith { row1, row2 ->
        val val1 = row1.getOrNull(colIndex) ?: JsonNull
        val val2 = row2.getOrNull(colIndex) ?: JsonNull
        
        val comparison = compareJsonValues(val1, val2)
        if (ascending) comparison else -comparison
    }
}

private fun compareJsonValues(val1: JsonElement, val2: JsonElement): Int {
    return when {
        val1 is JsonNull && val2 is JsonNull -> 0
        val1 is JsonNull -> -1
        val2 is JsonNull -> 1
        val1 is JsonPrimitive && val2 is JsonPrimitive -> {
            when {
                val1.booleanOrNull != null && val2.booleanOrNull != null ->
                    val1.boolean.compareTo(val2.boolean)
                val1.doubleOrNull != null && val2.doubleOrNull != null ->
                    val1.double.compareTo(val2.double)
                else -> val1.content.compareTo(val2.content)
            }
        }
        else -> 0
    }
}
