import Foundation

public indirect enum CardElement: Codable, Equatable {
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
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
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
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown element type: \(type)"
            )
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
        }
    }
    
    public var id: String? {
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
        }
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
        }
    }
}
