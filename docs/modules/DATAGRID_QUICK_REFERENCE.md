# DataGrid Input Quick Reference

## Overview
The DataGrid Input allows users to enter and edit data in a table format with support for different column types, sorting, and row management.

## JSON Schema

```json
{
  "type": "Input.DataGrid",
  "id": "myGrid",
  "label": "Data Entry",
  "isRequired": true,
  "errorMessage": "Please enter at least one row",
  "maxRows": 100,
  "columns": [
    {
      "id": "columnId",
      "title": "Column Title",
      "type": "text|number|date|toggle",
      "width": "auto|stretch|150px",
      "isEditable": true,
      "isSortable": true
    }
  ],
  "rows": [
    ["value1", 123, "2024-01-01", true],
    ["value2", 456, "2024-01-02", false]
  ]
}
```

## Column Types

### text
- Input: Free-form text
- iOS: TextField
- Android: BasicTextField
- Example: `["Name", "John Doe"]`

### number
- Input: Numeric values (integers or decimals)
- iOS: TextField with decimalPad
- Android: BasicTextField with KeyboardType.Number
- Example: `["Age", 25]`

### date
- Input: ISO8601 date strings
- iOS: DatePicker in sheet
- Android: DatePickerDialog
- Format: "YYYY-MM-DD"
- Example: `["StartDate", "2024-01-15"]`

### toggle
- Input: Boolean values
- iOS: Toggle control
- Android: Switch
- Example: `["Active", true]`

## Column Width Options

- `"auto"` - Minimal width based on content (100-120dp/pt)
- `"stretch"` - Flexible width that expands (200-250dp/pt)
- `"150px"` - Fixed pixel width (converted to dp/pt)

## Usage Examples

### Basic Text Grid
```json
{
  "type": "Input.DataGrid",
  "id": "notes",
  "columns": [
    {
      "id": "note",
      "title": "Note",
      "type": "text",
      "width": "stretch"
    }
  ],
  "rows": [
    ["First note"],
    ["Second note"]
  ]
}
```

### Mixed Column Types
```json
{
  "type": "Input.DataGrid",
  "id": "employees",
  "label": "Employee List",
  "maxRows": 50,
  "columns": [
    {
      "id": "name",
      "title": "Name",
      "type": "text",
      "width": "150px",
      "isSortable": true
    },
    {
      "id": "age",
      "title": "Age",
      "type": "number",
      "width": "80px",
      "isSortable": true
    },
    {
      "id": "startDate",
      "title": "Start Date",
      "type": "date",
      "width": "120px",
      "isSortable": true
    },
    {
      "id": "active",
      "title": "Active",
      "type": "toggle",
      "width": "auto",
      "isSortable": false
    }
  ],
  "rows": [
    ["Alice", 28, "2020-03-15", true],
    ["Bob", 35, "2018-06-22", true]
  ]
}
```

### Read-Only Grid
```json
{
  "type": "Input.DataGrid",
  "id": "readonly",
  "label": "Status Report",
  "columns": [
    {
      "id": "id",
      "title": "ID",
      "type": "number",
      "width": "60px",
      "isEditable": false
    },
    {
      "id": "status",
      "title": "Status",
      "type": "text",
      "width": "auto",
      "isEditable": false
    }
  ],
  "rows": [
    [1, "Pending"],
    [2, "Approved"]
  ]
}
```

### Empty Grid (User Adds Rows)
```json
{
  "type": "Input.DataGrid",
  "id": "userInput",
  "label": "Add Items",
  "maxRows": 20,
  "columns": [
    {
      "id": "item",
      "title": "Item",
      "type": "text"
    },
    {
      "id": "quantity",
      "title": "Qty",
      "type": "number"
    }
  ],
  "rows": []
}
```

## Programmatic Usage

### iOS (Swift)

```swift
import ACCore
import ACInputs

// Create grid input
let grid = DataGridInput(
    id: "myGrid",
    label: "Employee Data",
    columns: [
        DataGridColumn(
            id: "name",
            title: "Name",
            type: "text",
            width: "150px",
            isEditable: true,
            isSortable: true
        )
    ],
    rows: [
        [.string("John"), .number(30), .bool(true)]
    ],
    maxRows: 10,
    isRequired: true
)

// Use in SwiftUI view
@State var gridData: [[DataGridCellValue]] = grid.rows ?? []

DataGridInputView(
    input: grid,
    gridData: $gridData
)

// Access data
let exportedData = gridData
```

### Android (Kotlin)

```kotlin
import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.inputs.composables.DataGridInputView

// Create grid input
val grid = InputDataGrid(
    id = "myGrid",
    label = "Employee Data",
    columns = listOf(
        DataGridColumn(
            id = "name",
            title = "Name",
            type = "text",
            width = "150px",
            isEditable = true,
            isSortable = true
        )
    ),
    rows = listOf(
        listOf(JsonPrimitive("John"), JsonPrimitive(30), JsonPrimitive(true))
    ),
    maxRows = 10,
    isRequired = true
)

// Use in Compose
DataGridInputView(
    element = grid,
    viewModel = cardViewModel
)

// Access data from viewModel
val gridData = viewModel.getInputValue("myGrid")
```

## Data Format on Submit

When the form is submitted, the DataGrid data is returned as a 2D array:

```json
{
  "myGrid": [
    ["Alice", 28, "2020-03-15", true],
    ["Bob", 35, "2018-06-22", true],
    ["Carol", 42, "2015-09-10", false]
  ]
}
```

## Features

### User Actions
- **Add Row**: Click "Add Row" button (disabled when maxRows reached)
- **Delete Row**: Click trash icon on each row
- **Edit Cell**: Click/tap cell to edit (if editable)
- **Sort Column**: Click/tap column header (if sortable)
- **Scroll**: Horizontal and vertical scroll for large grids

### Sorting
- First click: Sort ascending (A-Z, 0-9, old-new)
- Second click: Sort descending (Z-A, 9-0, new-old)
- Visual indicator: Chevron up/down in column header
- Works with all column types

### Validation
- Required grids must have at least one row
- Number columns validate numeric input
- Date columns enforce date format
- Max rows limit prevents adding beyond capacity

## Accessibility

### Screen Readers
- **iOS VoiceOver**: "Row 1, Name: Alice"
- **Android TalkBack**: "Row 1, Name column, Alice"

### Keyboard Navigation
- Tab between cells
- Enter to edit cell
- Arrow keys for navigation (iOS/Android native)

### Touch Targets
- Minimum 44pt (iOS) / 48dp (Android)
- Generous spacing between interactive elements

## Best Practices

### Column Design
- Use descriptive column titles
- Limit columns to 5-7 for mobile
- Use "stretch" for main content column
- Use fixed widths for numeric/date columns

### Data Management
- Start with sensible maxRows (20-100)
- Provide initial data for templates
- Use read-only columns for computed values
- Sort by most important column by default

### UX Considerations
- Label required grids clearly
- Provide helpful error messages
- Consider alternative input for complex data
- Test on both phone and tablet

### Performance
- Limit initial rows to 50 for best performance
- Use pagination for 500+ row datasets
- Consider filtering/search for large datasets
- Test scrolling performance on older devices

## Troubleshooting

### Grid Not Appearing
- Check JSON syntax
- Verify columns array has at least one column
- Check isVisible property (default: true)

### Sorting Not Working
- Verify isSortable is true (default)
- Check column data types match
- Ensure rows have values at column index

### Cells Not Editable
- Check isEditable property (default: true)
- Verify user has interaction enabled
- Check for read-only mode on view

### Performance Issues
- Reduce initial row count
- Simplify column types
- Remove complex validation
- Test on target devices

## Related Components

- **Input.Text**: Single-line text input
- **Input.Number**: Single numeric input
- **Input.ChoiceSet**: Predefined options
- **Table**: Read-only data display

## Resources

- [Test Card](../shared/test-cards/datagrid.json)
- [Completion Report](./PHASE_2C_COMPLETION_REPORT.md)
- [API Documentation](./ios/Sources/ACCore/Models/AdvancedElements.swift)
