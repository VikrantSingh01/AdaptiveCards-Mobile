// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

public indirect enum CardElement: Codable, Equatable, Identifiable {
    case textBlock(TextBlock)
    case image(Image)
    case media(Media)
    case richTextBlock(RichTextBlock)
    case container(Container)
    case columnSet(ColumnSet)
    case imageSet(ImageSet)
    case factSet(FactSet)
    case actionSet(ActionSet)
    case table(Table)
    case textInput(TextInput)
    case numberInput(NumberInput)
    case dateInput(DateInput)
    case timeInput(TimeInput)
    case toggleInput(ToggleInput)
    case choiceSetInput(ChoiceSetInput)
    case dataGridInput(DataGridInput)
    case carousel(Carousel)
    case accordion(Accordion)
    case codeBlock(CodeBlock)
    case ratingDisplay(RatingDisplay)
    case ratingInput(RatingInput)
    case progressBar(ProgressBar)
    case progressRing(ProgressRing)
    case spinner(Spinner)
    case tabSet(TabSet)
    case list(ListElement)
    case compoundButton(CompoundButton)
    case donutChart(DonutChart)
    case barChart(BarChart)
    case lineChart(LineChart)
    case pieChart(PieChart)
    case icon(IconElement)
    case badge(Badge)
    case unknown(type: String, fallback: CardElement? = nil)

    enum CodingKeys: String, CodingKey {
        case type, fallback
    }

    public init(from decoder: Decoder) throws {
        // Handle fallback shorthand: "drop" is a valid string value per AC spec
        if let singleContainer = try? decoder.singleValueContainer(),
           let stringValue = try? singleContainer.decode(String.self),
           stringValue.lowercased() == "drop" {
            self = .unknown(type: "drop", fallback: nil)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle elements without a "type" key gracefully (#9)
        guard let type = try container.decodeIfPresent(String.self, forKey: .type) else {
            self = .unknown(type: "_missing_type", fallback: nil)
            return
        }

        switch type {
        case "TextBlock":
            self = .textBlock(try TextBlock(from: decoder))
        case "Image":
            self = .image(try Image(from: decoder))
        case "Media":
            self = .media(try Media(from: decoder))
        case "RichTextBlock":
            self = .richTextBlock(try RichTextBlock(from: decoder))
        case "Container":
            self = .container(try Container(from: decoder))
        case "ColumnSet":
            self = .columnSet(try ColumnSet(from: decoder))
        case "ImageSet":
            self = .imageSet(try ImageSet(from: decoder))
        case "FactSet":
            self = .factSet(try FactSet(from: decoder))
        case "ActionSet":
            self = .actionSet(try ActionSet(from: decoder))
        case "Table":
            self = .table(try Table(from: decoder))
        case "Input.Text":
            self = .textInput(try TextInput(from: decoder))
        case "Input.Number":
            self = .numberInput(try NumberInput(from: decoder))
        case "Input.Date":
            self = .dateInput(try DateInput(from: decoder))
        case "Input.Time":
            self = .timeInput(try TimeInput(from: decoder))
        case "Input.Toggle":
            self = .toggleInput(try ToggleInput(from: decoder))
        case "Input.ChoiceSet":
            self = .choiceSetInput(try ChoiceSetInput(from: decoder))
        case "Input.DataGrid":
            self = .dataGridInput(try DataGridInput(from: decoder))
        case "Carousel":
            self = .carousel(try Carousel(from: decoder))
        case "Accordion":
            self = .accordion(try Accordion(from: decoder))
        case "CodeBlock":
            self = .codeBlock(try CodeBlock(from: decoder))
        case "Rating":
            self = .ratingDisplay(try RatingDisplay(from: decoder))
        case "Input.Rating":
            self = .ratingInput(try RatingInput(from: decoder))
        case "ProgressBar":
            self = .progressBar(try ProgressBar(from: decoder))
        case "ProgressRing":
            self = .progressRing(try ProgressRing(from: decoder))
        case "Spinner":
            self = .spinner(try Spinner(from: decoder))
        case "TabSet":
            self = .tabSet(try TabSet(from: decoder))
        case "List":
            self = .list(try ListElement(from: decoder))
        case "CompoundButton":
            self = .compoundButton(try CompoundButton(from: decoder))
        case "DonutChart":
            self = .donutChart(try DonutChart(from: decoder))
        case "BarChart":
            self = .barChart(try BarChart(from: decoder))
        case "LineChart":
            self = .lineChart(try LineChart(from: decoder))
        case "PieChart":
            self = .pieChart(try PieChart(from: decoder))
        case "Icon":
            self = .icon(try IconElement(from: decoder))
        case "Badge":
            self = .badge(try Badge(from: decoder))
        default:
            // Gracefully handle unknown element types per Adaptive Cards spec.
            // Extract the fallback element so the rendering pipeline can use it.
            let fallbackElement = try container.decodeIfPresent(CardElement.self, forKey: .fallback)
            self = .unknown(type: type, fallback: fallbackElement)
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .textBlock(let element):
            try element.encode(to: encoder)
        case .image(let element):
            try element.encode(to: encoder)
        case .media(let element):
            try element.encode(to: encoder)
        case .richTextBlock(let element):
            try element.encode(to: encoder)
        case .container(let element):
            try element.encode(to: encoder)
        case .columnSet(let element):
            try element.encode(to: encoder)
        case .imageSet(let element):
            try element.encode(to: encoder)
        case .factSet(let element):
            try element.encode(to: encoder)
        case .actionSet(let element):
            try element.encode(to: encoder)
        case .table(let element):
            try element.encode(to: encoder)
        case .textInput(let element):
            try element.encode(to: encoder)
        case .numberInput(let element):
            try element.encode(to: encoder)
        case .dateInput(let element):
            try element.encode(to: encoder)
        case .timeInput(let element):
            try element.encode(to: encoder)
        case .toggleInput(let element):
            try element.encode(to: encoder)
        case .choiceSetInput(let element):
            try element.encode(to: encoder)
        case .dataGridInput(let element):
            try element.encode(to: encoder)
        case .carousel(let element):
            try element.encode(to: encoder)
        case .accordion(let element):
            try element.encode(to: encoder)
        case .codeBlock(let element):
            try element.encode(to: encoder)
        case .ratingDisplay(let element):
            try element.encode(to: encoder)
        case .ratingInput(let element):
            try element.encode(to: encoder)
        case .progressBar(let element):
            try element.encode(to: encoder)
        case .progressRing(let element):
            try element.encode(to: encoder)
        case .spinner(let element):
            try element.encode(to: encoder)
        case .tabSet(let element):
            try element.encode(to: encoder)
        case .list(let element):
            try element.encode(to: encoder)
        case .compoundButton(let element):
            try element.encode(to: encoder)
        case .donutChart(let element):
            try element.encode(to: encoder)
        case .barChart(let element):
            try element.encode(to: encoder)
        case .lineChart(let element):
            try element.encode(to: encoder)
        case .pieChart(let element):
            try element.encode(to: encoder)
        case .icon(let element):
            try element.encode(to: encoder)
        case .badge(let element):
            try element.encode(to: encoder)
        case .unknown(let type, _):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
        }
    }

    /// The optional ID from the card element JSON
    public var elementId: String? {
        switch self {
        case .textBlock(let element): return element.id
        case .image(let element): return element.id
        case .media(let element): return element.id
        case .richTextBlock(let element): return element.id
        case .container(let element): return element.id
        case .columnSet(let element): return element.id
        case .imageSet(let element): return element.id
        case .factSet(let element): return element.id
        case .actionSet(let element): return element.id
        case .table(let element): return element.id
        case .textInput(let element): return element.id
        case .numberInput(let element): return element.id
        case .dateInput(let element): return element.id
        case .timeInput(let element): return element.id
        case .toggleInput(let element): return element.id
        case .choiceSetInput(let element): return element.id
        case .dataGridInput(let element): return element.id
        case .carousel(let element): return element.id
        case .accordion(let element): return element.id
        case .codeBlock(let element): return element.id
        case .ratingDisplay(let element): return element.id
        case .ratingInput(let element): return element.id
        case .progressBar(let element): return element.id
        case .progressRing(let element): return element.id
        case .spinner(let element): return element.id
        case .tabSet(let element): return element.id
        case .list(let element): return element.id
        case .compoundButton(let element): return element.id
        case .donutChart(let element): return element.id
        case .barChart(let element): return element.id
        case .lineChart(let element): return element.id
        case .pieChart(let element): return element.id
        case .icon(let element): return element.id
        case .badge(let element): return element.id
        case .unknown: return nil  // unknown elements have no ID
        }
    }

    /// Stable identifier conforming to Identifiable protocol.
    /// Uses the element's explicit ID if available, otherwise generates
    /// a deterministic identifier based on the element's description
    /// so SwiftUI view diffing works correctly.
    public var id: String {
        if let elementId = self.elementId {
            return elementId
        }
        // Deterministic: same content always produces the same ID.
        // Use a hash of the element's string description.
        let description = String(describing: self)
        return "\(typeString)_\(abs(description.hashValue))"
    }

    public var isVisible: Bool {
        switch self {
        case .textBlock(let element): return element.isVisible ?? true
        case .image(let element): return element.isVisible ?? true
        case .media(let element): return element.isVisible ?? true
        case .richTextBlock(let element): return element.isVisible ?? true
        case .container(let element): return element.isVisible ?? true
        case .columnSet(let element): return element.isVisible ?? true
        case .imageSet(let element): return element.isVisible ?? true
        case .factSet(let element): return element.isVisible ?? true
        case .actionSet(let element): return element.isVisible ?? true
        case .table(let element): return element.isVisible ?? true
        case .textInput(let element): return element.isVisible ?? true
        case .numberInput(let element): return element.isVisible ?? true
        case .dateInput(let element): return element.isVisible ?? true
        case .timeInput(let element): return element.isVisible ?? true
        case .toggleInput(let element): return element.isVisible ?? true
        case .choiceSetInput(let element): return element.isVisible ?? true
        case .dataGridInput(let element): return element.isVisible ?? true
        case .carousel(let element): return element.isVisible ?? true
        case .accordion(let element): return element.isVisible ?? true
        case .codeBlock(let element): return element.isVisible ?? true
        case .ratingDisplay(let element): return element.isVisible ?? true
        case .ratingInput(let element): return element.isVisible ?? true
        case .progressBar(let element): return element.isVisible ?? true
        case .progressRing(let element): return element.isVisible ?? true
        case .spinner(let element): return element.isVisible ?? true
        case .tabSet(let element): return element.isVisible ?? true
        case .list(let element): return element.isVisible ?? true
        case .compoundButton(let element): return element.isVisible ?? true
        case .donutChart(let element): return element.isVisible ?? true
        case .barChart(let element): return element.isVisible ?? true
        case .lineChart(let element): return element.isVisible ?? true
        case .pieChart(let element): return element.isVisible ?? true
        case .icon(let element): return element.isVisible ?? true
        case .badge(let element): return element.isVisible ?? true
        case .unknown: return true  // unknown elements should be visible (fallback handles them)
        }
    }

    /// The requires property from the underlying element, if any
    public var requires: [String: String]? {
        switch self {
        case .textBlock(let e): return e.requires
        case .image(let e): return e.requires
        case .media(let e): return e.requires
        case .richTextBlock(let e): return e.requires
        case .container(let e): return e.requires
        case .columnSet(let e): return e.requires
        case .imageSet(let e): return e.requires
        case .factSet(let e): return e.requires
        case .actionSet(let e): return e.requires
        case .table(let e): return e.requires
        case .textInput: return nil
        case .numberInput: return nil
        case .dateInput: return nil
        case .timeInput: return nil
        case .toggleInput: return nil
        case .choiceSetInput: return nil
        case .dataGridInput: return nil
        case .carousel(let e): return e.requires
        case .accordion(let e): return e.requires
        case .codeBlock(let e): return e.requires
        case .ratingDisplay(let e): return e.requires
        case .ratingInput: return nil
        case .progressBar(let e): return e.requires
        case .progressRing(let e): return e.requires
        case .spinner(let e): return e.requires
        case .tabSet(let e): return e.requires
        case .list(let e): return e.requires
        case .compoundButton(let e): return e.requires
        case .donutChart(let e): return e.requires
        case .barChart(let e): return e.requires
        case .lineChart(let e): return e.requires
        case .pieChart(let e): return e.requires
        case .icon: return nil
        case .badge: return nil
        case .unknown: return nil
        }
    }

    /// The fallback element from the underlying element, if any
    public var fallbackElement: CardElement? {
        switch self {
        case .textBlock(let e): return e.fallback
        case .image(let e): return e.fallback
        case .media(let e): return e.fallback
        case .richTextBlock(let e): return e.fallback
        case .container(let e): return e.fallback
        case .columnSet(let e): return e.fallback
        case .imageSet(let e): return e.fallback
        case .factSet(let e): return e.fallback
        case .actionSet(let e): return e.fallback
        case .table(let e): return e.fallback
        case .textInput(let e): return e.fallback
        case .numberInput(let e): return e.fallback
        case .dateInput(let e): return e.fallback
        case .timeInput(let e): return e.fallback
        case .toggleInput(let e): return e.fallback
        case .choiceSetInput(let e): return e.fallback
        case .dataGridInput: return nil  // DataGridInput doesn't have fallback
        case .carousel: return nil
        case .accordion: return nil
        case .codeBlock: return nil
        case .ratingDisplay: return nil
        case .ratingInput: return nil
        case .progressBar: return nil
        case .progressRing: return nil
        case .spinner: return nil
        case .tabSet: return nil
        case .list: return nil
        case .compoundButton: return nil
        case .donutChart: return nil
        case .barChart: return nil
        case .lineChart: return nil
        case .pieChart: return nil
        case .icon: return nil
        case .badge: return nil
        case .unknown(_, let fallback): return fallback
        }
    }

    /// The spacing property from the underlying element, if any
    public var spacing: Spacing? {
        switch self {
        case .textBlock(let e): return e.spacing
        case .image(let e): return e.spacing
        case .media(let e): return e.spacing
        case .richTextBlock(let e): return e.spacing
        case .container(let e): return e.spacing
        case .columnSet(let e): return e.spacing
        case .imageSet(let e): return e.spacing
        case .factSet(let e): return e.spacing
        case .actionSet(let e): return e.spacing
        case .table(let e): return e.spacing
        case .textInput(let e): return e.spacing
        case .numberInput(let e): return e.spacing
        case .dateInput(let e): return e.spacing
        case .timeInput(let e): return e.spacing
        case .toggleInput(let e): return e.spacing
        case .choiceSetInput(let e): return e.spacing
        case .dataGridInput(let e): return e.spacing
        case .carousel(let e): return e.spacing
        case .accordion(let e): return e.spacing
        case .codeBlock(let e): return e.spacing
        case .ratingDisplay(let e): return e.spacing
        case .ratingInput(let e): return e.spacing
        case .progressBar(let e): return e.spacing
        case .progressRing(let e): return e.spacing
        case .spinner(let e): return e.spacing
        case .tabSet(let e): return e.spacing
        case .list(let e): return e.spacing
        case .compoundButton(let e): return e.spacing
        case .donutChart(let e): return e.spacing
        case .barChart(let e): return e.spacing
        case .lineChart(let e): return e.spacing
        case .pieChart(let e): return e.spacing
        case .icon(let e): return e.spacing
        case .badge(let e): return e.spacing
        case .unknown: return nil
        }
    }

    /// The targetWidth property from the underlying element, if any.
    /// Used for responsive filtering — elements with targetWidth are only
    /// shown when the card width matches the specified constraint.
    public var targetWidth: String? {
        switch self {
        case .textBlock(let e): return e.targetWidth
        case .image(let e): return e.targetWidth
        case .container(let e): return e.targetWidth
        case .columnSet(let e): return e.targetWidth
        case .actionSet(let e): return e.targetWidth
        case .table(let e): return e.targetWidth
        case .icon(let e): return e.targetWidth
        case .badge(let e): return e.targetWidth
        default: return nil
        }
    }

    /// Returns the type string for this element
    public var typeString: String {
        switch self {
        case .textBlock: return "TextBlock"
        case .image: return "Image"
        case .media: return "Media"
        case .richTextBlock: return "RichTextBlock"
        case .container: return "Container"
        case .columnSet: return "ColumnSet"
        case .imageSet: return "ImageSet"
        case .factSet: return "FactSet"
        case .actionSet: return "ActionSet"
        case .table: return "Table"
        case .textInput: return "Input.Text"
        case .numberInput: return "Input.Number"
        case .dateInput: return "Input.Date"
        case .timeInput: return "Input.Time"
        case .toggleInput: return "Input.Toggle"
        case .choiceSetInput: return "Input.ChoiceSet"
        case .dataGridInput: return "Input.DataGrid"
        case .carousel: return "Carousel"
        case .accordion: return "Accordion"
        case .codeBlock: return "CodeBlock"
        case .ratingDisplay: return "Rating"
        case .ratingInput: return "Input.Rating"
        case .progressBar: return "ProgressBar"
        case .progressRing: return "ProgressRing"
        case .spinner: return "Spinner"
        case .tabSet: return "TabSet"
        case .list: return "List"
        case .compoundButton: return "CompoundButton"
        case .donutChart: return "DonutChart"
        case .barChart: return "BarChart"
        case .lineChart: return "LineChart"
        case .pieChart: return "PieChart"
        case .icon: return "Icon"
        case .badge: return "Badge"
        case .unknown(let type, _): return type
        }
    }
}
