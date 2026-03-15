// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import UIKit
import ACCore
import ACRendering
import ACActions

/// Logs action callbacks to ActionLogStore for visibility in the Action Log screen.
final class SampleActionDelegate: ActionDelegate {
    private let actionLog: ActionLogStore

    init(actionLog: ActionLogStore) {
        self.actionLog = actionLog
    }

    func onSubmit(data: [String: Any], actionId: String?) {
        actionLog.log("Action.Submit", data: data)
    }

    func onOpenUrl(url: URL, actionId: String?) {
        actionLog.log("Action.OpenUrl", data: ["url": url.absoluteString])
    }

    func onExecute(verb: String?, data: [String: Any], actionId: String?) {
        var logData = data
        logData["verb"] = verb ?? ""
        actionLog.log("Action.Execute", data: logData)
    }

    func onShowCard(actionId: String?, isExpanded: Bool) {
        actionLog.log("Action.ShowCard", data: ["actionId": actionId ?? "", "isExpanded": isExpanded])
    }

    func onToggleVisibility(targetElementIds: [String]) {
        actionLog.log("Action.ToggleVisibility", data: ["targets": targetElementIds.joined(separator: ",")])
    }
}

struct CardDetailView: View {
    let card: TestCard
    @State private var showJSON = false
    @State private var parseTime: TimeInterval = 0
    @State private var renderTime: TimeInterval = 0
    @EnvironmentObject var actionLog: ActionLogStore
    @EnvironmentObject var bookmarks: BookmarkStore
    @EnvironmentObject var editorState: EditorState
    @EnvironmentObject var perfStore: PerformanceStore
    @EnvironmentObject var deepLink: DeepLinkRouter

    var body: some View {
        VStack(spacing: 0) {
            // Card Preview — fills remaining space
            AdaptiveCardView(
                cardJson: card.jsonString,
                templateData: card.dataJsonString.flatMap { parseTemplateData($0) },
                hostConfig: TeamsHostConfig.create(),
                actionDelegate: SampleActionDelegate(actionLog: actionLog),
                pendingActionTitle: $deepLink.pendingActionTitle
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom bar — single row: JSON | Parse | Render | Copy
            VStack(spacing: 0) {
                Divider()

                HStack(spacing: 0) {
                    // JSON toggle
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { showJSON.toggle() }
                    } label: {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .padding(.leading, 12)
                    .help("Show JSON")

                    Spacer()

                    // Parse metric
                    HStack(spacing: 3) {
                        Text("PARSE")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.1f", parseTime * 1000))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(perfColor(ms: parseTime * 1000))
                        Text("ms")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }

                    Divider().frame(height: 20).padding(.horizontal, 10)

                    // Render metric
                    HStack(spacing: 3) {
                        Text("RENDER")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.1f", renderTime * 1000))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(perfColor(ms: renderTime * 1000))
                        Text("ms")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Copy button
                    Button(action: copyJSON) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .padding(.trailing, 12)
                    .help("Copy JSON")
                }
                .padding(.vertical, 10)

                if showJSON {
                    ScrollView {
                        Text(card.jsonString)
                            .font(.system(.caption2, design: .monospaced))
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 200)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .background(.ultraThinMaterial)
        }
        .navigationTitle(card.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        editorState.openInEditor(json: card.jsonString)
                    } label: {
                        Image(systemName: "pencil.and.outline")
                    }
                    .help("Edit in Editor")
                    Button {
                        bookmarks.toggle(card.filename)
                    } label: {
                        Image(systemName: bookmarks.isBookmarked(card.filename) ? "bookmark.fill" : "bookmark")
                    }
                    Button(action: reloadCard) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .task {
            measurePerformance()
        }
    }

    /// Maps a performance metric (ms) to a color: green < 10, blue < 20, orange < 40, red >= 40.
    private func perfColor(ms: Double) -> Color {
        switch ms {
        case ..<10: return Color(red: 0.204, green: 0.780, blue: 0.349) // #34C759 green
        case ..<20: return Color(red: 0.0,   green: 0.471, blue: 0.831) // #0078D4 blue
        case ..<40: return Color(red: 1.0,   green: 0.584, blue: 0.0)   // #FF9500 orange
        default:    return Color(red: 1.0,   green: 0.231, blue: 0.188) // #FF3B30 red
        }
    }

    private func measurePerformance() {
        // Clear ViewModel parse cache so measurements reflect real work
        CardViewModel.clearParseCache()

        // Parse: synchronous JSON → AdaptiveCard model deserialization
        let parseStart = CFAbsoluteTimeGetCurrent()
        let parser = CardParser()
        _ = try? parser.parse(card.jsonString)
        parseTime = CFAbsoluteTimeGetCurrent() - parseStart

        // Render: SwiftUI view creation + forced synchronous layout.
        CardViewModel.clearParseCache()
        let renderStart = CFAbsoluteTimeGetCurrent()
        let view = AdaptiveCardView(cardJson: card.jsonString, hostConfig: TeamsHostConfig.create())
        let host = UIHostingController(rootView: view)
        host.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        host.view.layoutIfNeeded()
        _ = host.view.intrinsicContentSize
        renderTime = CFAbsoluteTimeGetCurrent() - renderStart

        // Persist to store (accumulates across sessions)
        perfStore.recordParse(parseTime)
        perfStore.recordRender(renderTime)
    }

    private func parseTemplateData(_ json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return obj
    }

    private func reloadCard() {
        measurePerformance()
    }

    private func copyJSON() {
        #if os(iOS)
        UIPasteboard.general.string = card.jsonString
        #endif
    }
}

/// Parses the Adaptive Card JSON and renders a live preview of its actual content.
/// This replaces the former static placeholder so that each card type displays
/// its unique body elements, actions, and structure.
struct CardPreviewPlaceholder: View {
    let json: String

    private var parsed: ParsedCard? {
        CardJSONParser.parse(json)
    }

    var body: some View {
        if let card = parsed {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(card.body.enumerated()), id: \.offset) { _, element in
                    CardElementPreview(element: element)
                }

                if !card.actions.isEmpty {
                    Divider().padding(.vertical, 4)
                    HStack(spacing: 8) {
                        ForEach(Array(card.actions.enumerated()), id: \.offset) { _, action in
                            Button(action: {}) {
                                Text(action.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        } else {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Unable to parse card JSON")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

// MARK: - Lightweight JSON-based Card Parsing (SampleApp-local)

/// Minimal model representing a parsed Adaptive Card for preview rendering.
struct ParsedCard {
    let version: String
    let body: [ParsedElement]
    let actions: [ParsedAction]
}

struct ParsedAction {
    let type: String
    let title: String
    let url: String?
}

/// Represents a single element parsed from the card body JSON.
indirect enum ParsedElement {
    case textBlock(text: String, size: String?, weight: String?, wrap: Bool, color: String?, isSubtle: Bool)
    case image(url: String, size: String?, altText: String?, style: String?)
    case container(items: [ParsedElement], style: String?)
    case columnSet(columns: [ParsedColumn])
    case factSet(facts: [ParsedFact])
    case imageSet(images: [ParsedElement], imageSize: String?)
    case actionSet(actions: [ParsedAction])
    case inputText(id: String, label: String?, placeholder: String?, isMultiline: Bool)
    case inputNumber(id: String, label: String?, placeholder: String?)
    case inputDate(id: String, label: String?)
    case inputTime(id: String, label: String?)
    case inputToggle(id: String, title: String)
    case inputChoiceSet(id: String, label: String?, choices: [String])
    case inputRating(id: String, label: String?, max: Int)
    case ratingDisplay(value: Double, max: Int, size: String?)
    case table(columns: [String], rows: [[String]])
    case codeBlock(language: String?, code: String)
    case media(title: String?)
    case progressBar(label: String?, value: Double?)
    case spinner(label: String?)
    case carousel(pages: [[ParsedElement]])
    case accordion(panels: [(title: String, items: [ParsedElement])])
    case tabSet(tabs: [(title: String, items: [ParsedElement])])
    case list(items: [ParsedElement])
    case compoundButton(title: String, description: String?, icon: String?)
    case richTextBlock(inlines: [String])
    case unknown(type: String)
}

struct ParsedColumn {
    let width: String
    let items: [ParsedElement]
}

struct ParsedFact {
    let title: String
    let value: String
}

/// Parses raw JSON dictionaries into the lightweight preview model.
enum CardJSONParser {
    static func parse(_ jsonString: String) -> ParsedCard? {
        guard let data = jsonString.data(using: .utf8),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              (root["type"] as? String) == "AdaptiveCard" else {
            return nil
        }

        let version = root["version"] as? String ?? "1.0"
        let bodyArray = root["body"] as? [[String: Any]] ?? []
        let actionsArray = root["actions"] as? [[String: Any]] ?? []

        let body = bodyArray.compactMap { parseElementIfVisible($0) }
        let actions = actionsArray.map { parseAction($0) }

        return ParsedCard(version: version, body: body, actions: actions)
    }

    /// Device width category name for targetWidth filtering.
    /// iPhone = "narrow" (width 216-413pt per hostConfig breakpoints).
    private static var deviceWidthCategory: String {
        let w = UIScreen.main.bounds.width
        if w <= 216 { return "verynarrow" }
        if w <= 413 { return "narrow" }
        if w <= 500 { return "standard" }
        return "wide"
    }

    private static let categoryOrder = ["verynarrow": 0, "narrow": 1, "standard": 2, "wide": 3]

    /// Returns nil if the element's targetWidth doesn't match the current device.
    static func parseElementIfVisible(_ dict: [String: Any]) -> ParsedElement? {
        guard matchesTargetWidth(dict["targetWidth"] as? String) else { return nil }
        return parseElement(dict)
    }

    private static func matchesTargetWidth(_ tw: String?) -> Bool {
        guard let tw = tw, !tw.isEmpty else { return true }
        let trimmed = tw.trimmingCharacters(in: .whitespaces).lowercased()
        let current = categoryOrder[deviceWidthCategory] ?? 1
        if trimmed.hasPrefix("atleast:") {
            let name = String(trimmed.dropFirst("atleast:".count))
            guard let threshold = categoryOrder[name] else { return true }
            return current >= threshold
        }
        if trimmed.hasPrefix("atmost:") {
            let name = String(trimmed.dropFirst("atmost:".count))
            guard let threshold = categoryOrder[name] else { return true }
            return current <= threshold
        }
        guard let exact = categoryOrder[trimmed] else { return true }
        return current == exact
    }

    static func parseElement(_ dict: [String: Any]) -> ParsedElement {
        let type = dict["type"] as? String ?? ""

        switch type {
        case "TextBlock":
            return .textBlock(
                text: dict["text"] as? String ?? "",
                size: dict["size"] as? String,
                weight: dict["weight"] as? String,
                wrap: dict["wrap"] as? Bool ?? false,
                color: dict["color"] as? String,
                isSubtle: dict["isSubtle"] as? Bool ?? false
            )
        case "Image":
            return .image(
                url: dict["url"] as? String ?? "",
                size: dict["size"] as? String,
                altText: dict["altText"] as? String,
                style: dict["style"] as? String
            )
        case "Container":
            let items = (dict["items"] as? [[String: Any]] ?? []).compactMap { parseElementIfVisible($0) }
            return .container(items: items, style: dict["style"] as? String)
        case "ColumnSet":
            let columns = (dict["columns"] as? [[String: Any]] ?? []).compactMap { colDict -> ParsedColumn? in
                guard matchesTargetWidth(colDict["targetWidth"] as? String) else { return nil }
                let items = (colDict["items"] as? [[String: Any]] ?? []).compactMap { parseElementIfVisible($0) }
                let width = colDict["width"] as? String ?? "stretch"
                return ParsedColumn(width: width, items: items)
            }
            return .columnSet(columns: columns)
        case "FactSet":
            let facts = (dict["facts"] as? [[String: Any]] ?? []).map { f in
                ParsedFact(title: f["title"] as? String ?? "", value: f["value"] as? String ?? "")
            }
            return .factSet(facts: facts)
        case "ImageSet":
            let images = (dict["images"] as? [[String: Any]] ?? []).map { parseElement($0) }
            return .imageSet(images: images, imageSize: dict["imageSize"] as? String)
        case "ActionSet":
            let actions = (dict["actions"] as? [[String: Any]] ?? []).map { parseAction($0) }
            return .actionSet(actions: actions)
        case "Input.Text":
            return .inputText(
                id: dict["id"] as? String ?? "",
                label: dict["label"] as? String,
                placeholder: dict["placeholder"] as? String,
                isMultiline: dict["isMultiline"] as? Bool ?? false
            )
        case "Input.Number":
            return .inputNumber(
                id: dict["id"] as? String ?? "",
                label: dict["label"] as? String,
                placeholder: dict["placeholder"] as? String
            )
        case "Input.Date":
            return .inputDate(id: dict["id"] as? String ?? "", label: dict["label"] as? String)
        case "Input.Time":
            return .inputTime(id: dict["id"] as? String ?? "", label: dict["label"] as? String)
        case "Input.Toggle":
            return .inputToggle(id: dict["id"] as? String ?? "", title: dict["title"] as? String ?? "Toggle")
        case "Input.ChoiceSet":
            let choices = (dict["choices"] as? [[String: Any]] ?? []).map { $0["title"] as? String ?? "" }
            return .inputChoiceSet(id: dict["id"] as? String ?? "", label: dict["label"] as? String, choices: choices)
        case "Input.Rating":
            return .inputRating(
                id: dict["id"] as? String ?? "",
                label: dict["label"] as? String,
                max: dict["max"] as? Int ?? 5
            )
        case "Rating":
            return .ratingDisplay(
                value: dict["value"] as? Double ?? 0,
                max: dict["max"] as? Int ?? 5,
                size: dict["size"] as? String
            )
        case "Table":
            let cols = (dict["columns"] as? [[String: Any]] ?? []).map { $0["title"] as? String ?? "" }
            let rows = (dict["rows"] as? [[String: Any]] ?? []).map { row in
                (row["cells"] as? [[String: Any]] ?? []).map { cell in
                    // Cells may contain items array with TextBlocks, or have inline text
                    if let items = cell["items"] as? [[String: Any]], let first = items.first {
                        return first["text"] as? String ?? ""
                    }
                    return cell["text"] as? String ?? ""
                }
            }
            return .table(columns: cols, rows: rows)
        case "CodeBlock":
            return .codeBlock(
                language: dict["language"] as? String,
                code: dict["code"] as? String ?? ""
            )
        case "Media":
            return .media(title: dict["title"] as? String)
        case "ProgressBar":
            return .progressBar(label: dict["label"] as? String, value: dict["value"] as? Double)
        case "Spinner":
            return .spinner(label: dict["label"] as? String)
        case "Carousel":
            let pages = (dict["pages"] as? [[String: Any]] ?? []).map { page in
                (page["items"] as? [[String: Any]] ?? []).map { parseElement($0) }
            }
            return .carousel(pages: pages)
        case "Accordion":
            let panels = (dict["panels"] as? [[String: Any]] ?? []).map { panel -> (String, [ParsedElement]) in
                let title = panel["title"] as? String ?? "Panel"
                let items = (panel["items"] as? [[String: Any]] ?? []).map { parseElement($0) }
                return (title, items)
            }
            return .accordion(panels: panels)
        case "TabSet":
            let tabs = (dict["tabs"] as? [[String: Any]] ?? []).map { tab -> (String, [ParsedElement]) in
                let title = tab["title"] as? String ?? "Tab"
                let items = (tab["items"] as? [[String: Any]] ?? []).map { parseElement($0) }
                return (title, items)
            }
            return .tabSet(tabs: tabs)
        case "List":
            let items = (dict["items"] as? [[String: Any]] ?? []).map { parseElement($0) }
            return .list(items: items)
        case "CompoundButton":
            return .compoundButton(
                title: dict["title"] as? String ?? "Button",
                description: dict["description"] as? String,
                icon: dict["icon"] as? String
            )
        case "RichTextBlock":
            let inlines = (dict["inlines"] as? [Any] ?? []).compactMap { inline -> String? in
                if let str = inline as? String { return str }
                if let dict = inline as? [String: Any] { return dict["text"] as? String }
                return nil
            }
            return .richTextBlock(inlines: inlines)
        default:
            return .unknown(type: type)
        }
    }

    static func parseAction(_ dict: [String: Any]) -> ParsedAction {
        ParsedAction(
            type: dict["type"] as? String ?? "",
            title: dict["title"] as? String ?? "Action",
            url: dict["url"] as? String
        )
    }
}

// MARK: - Element Preview Views

/// Renders a single parsed element as a SwiftUI view.
struct CardElementPreview: View {
    let element: ParsedElement

    var body: some View {
        switch element {
        case .textBlock(let text, let size, let weight, _, let color, let isSubtle):
            Text(text)
                .font(fontForSize(size))
                .fontWeight(weight?.lowercased() == "bolder" ? .bold : .regular)
                .foregroundColor(textColor(color: color, isSubtle: isSubtle))
                .frame(maxWidth: .infinity, alignment: .leading)

        case .image(let url, let size, let altText, let style):
            imagePreview(url: url, size: size, altText: altText, style: style)

        case .container(let items, let style):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    CardElementPreview(element: item)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(style?.lowercased() == "emphasis" ? Color.gray.opacity(0.08) : Color.clear)
            .cornerRadius(4)

        case .columnSet(let columns):
            HStack(alignment: .top, spacing: 8) {
                ForEach(Array(columns.enumerated()), id: \.offset) { _, column in
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(column.items.enumerated()), id: \.offset) { _, item in
                            CardElementPreview(element: item)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

        case .factSet(let facts):
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(facts.enumerated()), id: \.offset) { _, fact in
                    HStack(alignment: .top) {
                        Text(fact.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 100, alignment: .leading)
                        Text(fact.value)
                            .font(.subheadline)
                    }
                }
            }

        case .imageSet(let images, _):
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(images.enumerated()), id: \.offset) { _, img in
                        CardElementPreview(element: img)
                    }
                }
            }

        case .actionSet(let actions):
            HStack(spacing: 8) {
                ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                    Button(action: {}) {
                        Text(action.title)
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

        case .inputText(_, let label, let placeholder, let isMultiline):
            VStack(alignment: .leading, spacing: 4) {
                if let label = label { Text(label).font(.caption).fontWeight(.medium) }
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .overlay(
                        Text(placeholder ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.horizontal, 8),
                        alignment: .leading
                    )
                    .frame(height: isMultiline ? 60 : 34)
            }

        case .inputNumber(_, let label, let placeholder):
            VStack(alignment: .leading, spacing: 4) {
                if let label = label { Text(label).font(.caption).fontWeight(.medium) }
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .overlay(
                        Text(placeholder ?? "0")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.horizontal, 8),
                        alignment: .leading
                    )
                    .frame(height: 34)
            }

        case .inputDate(_, let label):
            VStack(alignment: .leading, spacing: 4) {
                if let label = label { Text(label).font(.caption).fontWeight(.medium) }
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text("Select date")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.6))
                }
                .padding(.horizontal, 8)
                .frame(height: 34)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.4), lineWidth: 1))
            }

        case .inputTime(_, let label):
            VStack(alignment: .leading, spacing: 4) {
                if let label = label { Text(label).font(.caption).fontWeight(.medium) }
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text("Select time")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.6))
                }
                .padding(.horizontal, 8)
                .frame(height: 34)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.4), lineWidth: 1))
            }

        case .inputToggle(_, let title):
            Toggle(title, isOn: .constant(false))
                .font(.subheadline)

        case .inputChoiceSet(_, let label, let choices):
            VStack(alignment: .leading, spacing: 4) {
                if let label = label { Text(label).font(.caption).fontWeight(.medium) }
                ForEach(Array(choices.prefix(4).enumerated()), id: \.offset) { _, choice in
                    HStack(spacing: 6) {
                        Image(systemName: "circle")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(choice)
                            .font(.subheadline)
                    }
                }
                if choices.count > 4 {
                    Text("+ \(choices.count - 4) more...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

        case .inputRating(_, let label, let max):
            VStack(alignment: .leading, spacing: 4) {
                if let label = label { Text(label).font(.caption).fontWeight(.medium) }
                HStack(spacing: 2) {
                    ForEach(0..<max, id: \.self) { _ in
                        Image(systemName: "star")
                            .font(.subheadline)
                            .foregroundColor(.orange.opacity(0.5))
                    }
                }
            }

        case .ratingDisplay(let value, let max, _):
            HStack(spacing: 2) {
                ForEach(0..<max, id: \.self) { index in
                    Image(systemName: Double(index) + 0.5 <= value ? "star.fill" :
                            (Double(index) < value ? "star.leadinghalf.filled" : "star"))
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                Text(String(format: "%.1f", value))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

        case .table(let columns, let rows):
            VStack(alignment: .leading, spacing: 0) {
                if !columns.isEmpty {
                    HStack {
                        ForEach(Array(columns.enumerated()), id: \.offset) { _, col in
                            Text(col)
                                .font(.caption)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.gray.opacity(0.15))
                }
                ForEach(Array(rows.prefix(5).enumerated()), id: \.offset) { _, row in
                    HStack {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                            Text(cell)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, 8)
                    Divider()
                }
                if rows.count > 5 {
                    Text("+ \(rows.count - 5) more rows")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3), lineWidth: 1))

        case .codeBlock(let language, let code):
            VStack(alignment: .leading, spacing: 4) {
                if let lang = language {
                    Text(lang)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(3)
                }
                Text(code.prefix(200) + (code.count > 200 ? "..." : ""))
                    .font(.system(.caption, design: .monospaced))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }

        case .media(let title):
            VStack(spacing: 8) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue.opacity(0.7))
                if let title = title {
                    Text(title).font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.black.opacity(0.05))
            .cornerRadius(8)

        case .progressBar(let label, let value):
            VStack(alignment: .leading, spacing: 4) {
                if let label = label { Text(label).font(.caption) }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(width: geo.size.width * CGFloat(value ?? 0))
                    }
                }
                .frame(height: 8)
            }

        case .spinner(let label):
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                if let label = label {
                    Text(label).font(.caption).foregroundColor(.secondary)
                }
            }

        case .carousel(let pages):
            VStack(spacing: 4) {
                if let firstPage = pages.first {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(firstPage.enumerated()), id: \.offset) { _, item in
                            CardElementPreview(element: item)
                        }
                    }
                }
                HStack(spacing: 4) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == 0 ? Color.blue : Color.gray.opacity(0.4))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 4)
            }

        case .accordion(let panels):
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(panels.enumerated()), id: \.offset) { index, panel in
                    HStack {
                        Image(systemName: index == 0 ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(panel.0)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    if index == 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(Array(panel.1.enumerated()), id: \.offset) { _, item in
                                CardElementPreview(element: item)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 6)
                    }
                    if index < panels.count - 1 { Divider() }
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3), lineWidth: 1))

        case .tabSet(let tabs):
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        Text(tab.0)
                            .font(.caption)
                            .fontWeight(index == 0 ? .bold : .regular)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(index == 0 ? Color.blue.opacity(0.1) : Color.clear)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(index == 0 ? .blue : .clear),
                                alignment: .bottom
                            )
                    }
                    Spacer()
                }
                .background(Color.gray.opacity(0.05))

                if let firstTab = tabs.first {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(firstTab.1.enumerated()), id: \.offset) { _, item in
                            CardElementPreview(element: item)
                        }
                    }
                    .padding(8)
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3), lineWidth: 1))

        case .list(let items):
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(items.prefix(6).enumerated()), id: \.offset) { _, item in
                    CardElementPreview(element: item)
                    Divider()
                }
                if items.count > 6 {
                    Text("+ \(items.count - 6) more items")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

        case .compoundButton(let title, let description, _):
            HStack(spacing: 10) {
                Image(systemName: "square.fill")
                    .foregroundColor(.blue.opacity(0.3))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline).fontWeight(.medium)
                    if let desc = description {
                        Text(desc).font(.caption).foregroundColor(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))

        case .richTextBlock(let inlines):
            Text(inlines.joined())
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .unknown(let type, _):
            HStack(spacing: 4) {
                Image(systemName: "questionmark.square.dashed")
                    .foregroundColor(.gray)
                Text(type)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(4)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(4)
        }
    }

    // MARK: - Helpers

    private func fontForSize(_ size: String?) -> Font {
        switch size?.lowercased() {
        case "extralarge": return .title
        case "large":      return .title3
        case "medium":     return .body
        case "small":      return .footnote
        default:           return .body
        }
    }

    private func textColor(color: String?, isSubtle: Bool) -> Color {
        if isSubtle { return .secondary }
        switch color?.lowercased() {
        case "accent":    return .blue
        case "good":      return .green
        case "warning":   return .orange
        case "attention": return .red
        case "light":     return .gray
        default:          return .primary
        }
    }

    /// Maps Adaptive Card icon: URLs to SF Symbol names.
    private static let iconToSFSymbol: [String: String] = [
        "calendar": "calendar", "clock": "clock", "people": "person.2",
        "person": "person", "mail": "envelope", "chat": "bubble.left",
        "call": "phone", "video": "video", "location": "mappin",
        "link": "link", "attach": "paperclip", "image": "photo",
        "document": "doc", "folder": "folder", "star": "star",
        "heart": "heart", "flag": "flag", "bookmark": "bookmark",
        "checkmark": "checkmark.circle", "alert": "exclamationmark.triangle",
        "info": "info.circle", "settings": "gearshape", "search": "magnifyingglass",
        "add": "plus.circle", "edit": "pencil", "delete": "trash",
        "share": "square.and.arrow.up", "download": "arrow.down.circle",
        "upload": "arrow.up.circle", "refresh": "arrow.clockwise",
        "home": "house", "list": "list.bullet", "grid": "square.grid.2x2",
        "notification": "bell", "lock": "lock", "unlock": "lock.open",
        "eye": "eye", "gift": "gift", "airplane": "airplane",
        "flashlight": "flashlight.on.fill", "approve": "checkmark.circle.fill",
        "forward": "arrowshape.turn.up.right", "reply": "arrowshape.turn.up.left"
    ]

    @ViewBuilder
    private func imagePreview(url: String, size: String?, altText: String?, style: String?) -> some View {
        let dimension: CGFloat = {
            switch size?.lowercased() {
            case "small":  return 40
            case "medium": return 80
            case "large":  return 120
            default:       return 60
            }
        }()

        if url.lowercased().hasPrefix("icon:") {
            let iconName = String(url.dropFirst("icon:".count)).trimmingCharacters(in: .whitespaces)
            let sfSymbol = Self.iconToSFSymbol[iconName.lowercased()] ?? "questionmark.square"
            Image(systemName: sfSymbol)
                .font(.system(size: dimension * 0.4))
                .foregroundColor(.accentColor)
                .frame(width: dimension, height: dimension)
        } else {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: dimension, height: dimension)
                        .clipShape(style?.lowercased() == "person" ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 4)))
                case .failure:
                    imagePlaceholder(dimension: dimension, altText: altText)
                case .empty:
                    ProgressView()
                        .frame(width: dimension, height: dimension)
                @unknown default:
                    imagePlaceholder(dimension: dimension, altText: altText)
                }
            }
        }
    }

    private func imagePlaceholder(dimension: CGFloat, altText: String?) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "photo")
                .font(.caption)
                .foregroundColor(.gray)
            if let alt = altText {
                Text(alt)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .frame(width: dimension, height: dimension)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(4)
    }
}

/// Type-erased shape to allow conditional clipShape usage.
struct AnyShape: Shape {
    private let pathBuilder: @Sendable (CGRect) -> Path
    init<S: Shape>(_ shape: S) {
        pathBuilder = { rect in shape.path(in: rect) }
    }
    func path(in rect: CGRect) -> Path { pathBuilder(rect) }
}

struct MetricView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}

struct PerformanceMetricPill: View {
    let icon: String
    let label: String
    let value: String
    let unit: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                    Text(unit)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ActionRowView: View {
    let action: ActionLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(action.actionType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(formatTime(action.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            if !action.data.isEmpty {
                Text(formatData(action.data))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

    private func formatData(_ data: [String: Any]) -> String {
        data.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
    }
}
