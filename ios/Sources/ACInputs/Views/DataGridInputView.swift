import SwiftUI
import ACCore

public struct DataGridInputView: View {
    let input: DataGridInput
    @Binding var gridData: [[DataGridCellValue]]
    
    @State private var sortColumn: String?
    @State private var sortAscending: Bool = true
    @State private var showDatePicker: Bool = false
    @State private var selectedDateCell: (row: Int, col: Int)?
    @State private var tempDate: Date = Date()
    
    @Environment(\.sizeCategory) var sizeCategory
    
    public init(
        input: DataGridInput,
        gridData: Binding<[[DataGridCellValue]]>
    ) {
        self.input = input
        self._gridData = gridData
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label = input.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("\(label)\(input.isRequired == true ? ", required" : "")")
            }
            
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    headerRow
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 0) {
                            ForEach(0..<gridData.count, id: \.self) { rowIndex in
                                dataRow(rowIndex: rowIndex)
                            }
                        }
                    }
                    .frame(maxHeight: 400)
                }
            }
            
            HStack {
                Button(action: addRow) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Row")
                    }
                }
                .disabled(isMaxRowsReached)
                .frame(minHeight: 44)
                
                Spacer()
                
                Text("\(gridData.count)\(maxRowsText)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
    }
    
    private var headerRow: some View {
        HStack(spacing: 1) {
            ForEach(input.columns.indices, id: \.self) { colIndex in
                let column = input.columns[colIndex]
                
                Button(action: {
                    if column.isSortable ?? true {
                        toggleSort(columnId: column.id)
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(column.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        if column.isSortable ?? true {
                            Image(systemName: sortIcon(for: column.id))
                                .font(.caption)
                        }
                    }
                    .padding(8)
                    .frame(width: columnWidth(column), minHeight: 44)
                }
                .disabled(!(column.isSortable ?? true))
                .background(Color.gray.opacity(0.2))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(column.title) column header\(column.isSortable ?? true ? ", sortable" : "")")
                .accessibilityHint(column.isSortable ?? true ? "Double tap to sort" : "")
            }
            
            // Delete column header
            Color.clear
                .frame(width: 60, minHeight: 44)
                .background(Color.gray.opacity(0.2))
        }
    }
    
    private func dataRow(rowIndex: Int) -> some View {
        HStack(spacing: 1) {
            ForEach(input.columns.indices, id: \.self) { colIndex in
                let column = input.columns[colIndex]
                cellView(row: rowIndex, col: colIndex, column: column)
                    .frame(width: columnWidth(column), minHeight: 44)
                    .background(Color.white)
                    .border(Color.gray.opacity(0.3), width: 0.5)
            }
            
            // Delete button
            Button(action: { deleteRow(at: rowIndex) }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .frame(width: 60, minHeight: 44)
            }
            .accessibilityLabel("Delete row \(rowIndex + 1)")
        }
    }
    
    private func cellView(row: Int, col: Int, column: DataGridColumn) -> some View {
        let isEditable = column.isEditable ?? true
        let cellValue = gridData[row][col]
        
        return Group {
            switch column.type {
            case "text":
                textCell(row: row, col: col, value: cellValue, isEditable: isEditable)
            case "number":
                numberCell(row: row, col: col, value: cellValue, isEditable: isEditable)
            case "date":
                dateCell(row: row, col: col, value: cellValue, isEditable: isEditable)
            case "toggle":
                toggleCell(row: row, col: col, value: cellValue, isEditable: isEditable)
            default:
                textCell(row: row, col: col, value: cellValue, isEditable: isEditable)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Row \(row + 1), \(column.title): \(cellValueDescription(cellValue))")
    }
    
    private func textCell(row: Int, col: Int, value: DataGridCellValue, isEditable: Bool) -> some View {
        let textValue = cellValueToString(value)
        
        return TextField("", text: Binding(
            get: { textValue },
            set: { newValue in
                gridData[row][col] = .string(newValue)
            }
        ))
        .disabled(!isEditable)
        .textFieldStyle(.plain)
        .padding(8)
        .frame(minHeight: 44)
    }
    
    private func numberCell(row: Int, col: Int, value: DataGridCellValue, isEditable: Bool) -> some View {
        let numberValue = cellValueToString(value)
        
        return TextField("", text: Binding(
            get: { numberValue },
            set: { newValue in
                if let doubleValue = Double(newValue) {
                    gridData[row][col] = .number(doubleValue)
                } else if newValue.isEmpty {
                    gridData[row][col] = .null
                }
            }
        ))
        .disabled(!isEditable)
        .keyboardType(.decimalPad)
        .textFieldStyle(.plain)
        .padding(8)
        .frame(minHeight: 44)
    }
    
    private func dateCell(row: Int, col: Int, value: DataGridCellValue, isEditable: Bool) -> some View {
        Button(action: {
            if isEditable {
                selectedDateCell = (row, col)
                if case .string(let dateStr) = value,
                   let date = ISO8601DateFormatter().date(from: dateStr) {
                    tempDate = date
                } else {
                    tempDate = Date()
                }
                showDatePicker = true
            }
        }) {
            Text(cellValueToString(value))
                .padding(8)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        }
        .disabled(!isEditable)
    }
    
    private func toggleCell(row: Int, col: Int, value: DataGridCellValue, isEditable: Bool) -> some View {
        let boolValue = cellValueToBool(value)
        
        return Toggle("", isOn: Binding(
            get: { boolValue },
            set: { newValue in
                gridData[row][col] = .bool(newValue)
            }
        ))
        .disabled(!isEditable)
        .labelsHidden()
        .padding(8)
        .frame(minHeight: 44)
    }
    
    private var datePickerSheet: some View {
        NavigationView {
            DatePicker("Select Date", selection: $tempDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showDatePicker = false
                    },
                    trailing: Button("Done") {
                        if let cell = selectedDateCell {
                            let formatter = ISO8601DateFormatter()
                            formatter.formatOptions = [.withFullDate]
                            let dateString = formatter.string(from: tempDate)
                            gridData[cell.row][cell.col] = .string(dateString)
                        }
                        showDatePicker = false
                    }
                )
        }
    }
    
    private func columnWidth(_ column: DataGridColumn) -> CGFloat {
        if let width = column.width {
            if width == "stretch" {
                return 200
            } else if width == "auto" {
                return 100
            } else if width.hasSuffix("px") {
                let numberPart = width.dropLast(2)
                return CGFloat(Double(numberPart) ?? 100)
            }
        }
        return 120
    }
    
    private func sortIcon(for columnId: String) -> String {
        if sortColumn == columnId {
            return sortAscending ? "chevron.up" : "chevron.down"
        }
        return "chevron.up.chevron.down"
    }
    
    private func toggleSort(columnId: String) {
        if sortColumn == columnId {
            sortAscending.toggle()
        } else {
            sortColumn = columnId
            sortAscending = true
        }
        
        if let colIndex = input.columns.firstIndex(where: { $0.id == columnId }) {
            sortData(by: colIndex, ascending: sortAscending)
        }
    }
    
    private func sortData(by colIndex: Int, ascending: Bool) {
        gridData.sort { row1, row2 in
            let val1 = row1[colIndex]
            let val2 = row2[colIndex]
            
            let comparison = compareCellValues(val1, val2)
            return ascending ? comparison : !comparison
        }
    }
    
    private func compareCellValues(_ val1: DataGridCellValue, _ val2: DataGridCellValue) -> Bool {
        switch (val1, val2) {
        case (.string(let s1), .string(let s2)):
            return s1 < s2
        case (.number(let n1), .number(let n2)):
            return n1 < n2
        case (.bool(let b1), .bool(let b2)):
            return !b1 && b2
        case (.null, _):
            return true
        case (_, .null):
            return false
        default:
            return false
        }
    }
    
    private func addRow() {
        guard !isMaxRowsReached else { return }
        
        let newRow = input.columns.map { column -> DataGridCellValue in
            switch column.type {
            case "toggle":
                return .bool(false)
            case "number":
                return .number(0)
            default:
                return .string("")
            }
        }
        gridData.append(newRow)
    }
    
    private func deleteRow(at index: Int) {
        gridData.remove(at: index)
    }
    
    private var isMaxRowsReached: Bool {
        if let maxRows = input.maxRows {
            return gridData.count >= maxRows
        }
        return false
    }
    
    private var maxRowsText: String {
        if let maxRows = input.maxRows {
            return " / \(maxRows)"
        }
        return ""
    }
    
    private func cellValueToString(_ value: DataGridCellValue) -> String {
        switch value {
        case .string(let str):
            return str
        case .number(let num):
            return String(format: "%.2f", num)
        case .bool(let bool):
            return bool ? "Yes" : "No"
        case .null:
            return ""
        }
    }
    
    private func cellValueToBool(_ value: DataGridCellValue) -> Bool {
        switch value {
        case .bool(let bool):
            return bool
        case .string(let str):
            return str.lowercased() == "true" || str == "1"
        case .number(let num):
            return num != 0
        case .null:
            return false
        }
    }
    
    private func cellValueDescription(_ value: DataGridCellValue) -> String {
        switch value {
        case .string(let str):
            return str.isEmpty ? "empty" : str
        case .number(let num):
            return String(format: "%.2f", num)
        case .bool(let bool):
            return bool ? "checked" : "unchecked"
        case .null:
            return "empty"
        }
    }
}
