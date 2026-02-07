# ACMarkdown Module

## Overview

The ACMarkdown module provides markdown rendering capabilities for the AdaptiveCards-Mobile SDK. It supports a subset of markdown syntax commonly used in card text content, including text formatting, links, headers, and lists.

## Supported Markdown Syntax

### Text Formatting
- **Bold**: `**text**` - Renders text in bold font weight
- **Italic**: `*text*` - Renders text in italic font style
- **Inline Code**: `` `code` `` - Renders text in monospace font with background highlight

### Links
- **Hyperlinks**: `[text](url)` - Creates clickable links (e.g., `[Microsoft](https://microsoft.com)`)
- Links are styled with blue color and underline
- Accessibility: Links include proper content descriptions

### Headers
- **H1**: `# Header 1` - Largest header size
- **H2**: `## Header 2` - Medium header size
- **H3**: `### Header 3` - Small header size
- Headers are rendered in bold with appropriate font sizes

### Lists
- **Bullet Lists**: `- item` - Renders with bullet point (•)
- **Numbered Lists**: `1. item` - Renders with number prefix

## Architecture

### iOS Implementation

**Location**: `ios/Sources/ACMarkdown/`

#### Components

1. **MarkdownParser.swift**
   - Parses markdown text into structured tokens
   - Uses NSCache for performance optimization
   - Thread-safe caching of parsed results

2. **MarkdownRenderer.swift**
   - Converts tokens to SwiftUI AttributedString
   - Applies appropriate styling based on token type
   - Supports custom font and color configuration

3. **MarkdownTextView.swift**
   - SwiftUI view component for rendering markdown
   - Provides convenient String extension for markdown detection
   - Handles text display with proper formatting

#### Usage Example (iOS)

```swift
import ACMarkdown

// Using MarkdownTextView
MarkdownTextView("This is **bold** and *italic* text")

// Manual parsing and rendering
let tokens = MarkdownParser.parse("Hello **world**")
let attributed = MarkdownRenderer.render(tokens: tokens)

// Detect markdown
if text.containsMarkdown {
    // Render with markdown support
}
```

### Android Implementation

**Location**: `android/ac-markdown/`

#### Components

1. **MarkdownParser.kt**
   - Parses markdown text into sealed class tokens
   - Uses LruCache (max 100 entries) for performance
   - Graceful handling of malformed markdown

2. **MarkdownRenderer.kt**
   - Converts tokens to Jetpack Compose AnnotatedString
   - Applies span styles for formatting
   - Supports URL annotations for link handling

3. **MarkdownText.kt**
   - Composable function for markdown rendering
   - Implements clickable text with URI handling
   - Proper error handling for invalid URLs

#### Usage Example (Android)

```kotlin
import com.microsoft.adaptivecards.markdown.*

// Using MarkdownText composable
MarkdownText(
    text = "This is **bold** and *italic* text",
    fontSize = 14.sp,
    color = Color.Black
)

// Manual parsing and rendering
val tokens = MarkdownParser.parse("Hello **world**")
val annotated = MarkdownRenderer.render(tokens, 14.sp, Color.Black)

// Detect markdown
if (text.containsMarkdown()) {
    // Render with markdown support
}
```

## Integration with TextBlock

The markdown module is automatically integrated with the TextBlock rendering on both platforms:

### iOS
```swift
// TextBlockView automatically detects and renders markdown
if textBlock.text.containsMarkdown {
    let tokens = MarkdownParser.parse(textBlock.text)
    let attributed = MarkdownRenderer.render(tokens: tokens, font: font, color: color)
    Text(attributed)
}
```

### Android
```kotlin
// TextBlockView automatically detects and renders markdown
if (element.text.containsMarkdown()) {
    val tokens = MarkdownParser.parse(element.text)
    val annotated = MarkdownRenderer.render(tokens, textSize, textColor)
    ClickableText(text = annotated, onClick = { /* handle links */ })
}
```

## Performance Considerations

### Caching Strategy

**iOS**: 
- Uses `NSCache` for automatic memory management
- Cache eviction handled by system based on memory pressure
- Thread-safe implementation

**Android**:
- Uses `LruCache` with fixed capacity (100 entries)
- Least-recently-used eviction policy
- Thread-safe implementation

### Optimization Tips

1. **Cache Hit Rate**: Reusing the same markdown strings improves performance
2. **Complex Markdown**: Parsing overhead is minimal but cached results are faster
3. **Memory Usage**: Both implementations use bounded caches to prevent memory issues

## Error Handling

The markdown parser is designed to handle malformed input gracefully:

- **Unclosed delimiters**: Treated as plain text
- **Invalid links**: Text is rendered without link formatting
- **Invalid headers**: Rendered as plain text if not properly formatted
- **Empty strings**: Returns empty token list
- **URL errors**: Caught and handled without crashing (links won't open)

## Testing

### iOS Tests
Location: `ios/Tests/ACMarkdownTests/MarkdownParserTests.swift`

```bash
cd ios
swift test
```

### Android Tests
Location: `android/ac-markdown/src/test/kotlin/.../MarkdownParserTest.kt`

```bash
cd android
./gradlew :ac-markdown:test
```

### Test Card
A comprehensive test card is available at `shared/test-cards/markdown.json` demonstrating all supported markdown features.

## Accessibility

### iOS
- Links include `.accessibilityLabel` with "Link: {text}" description
- Text formatting preserved in VoiceOver

### Android
- URL annotations enable proper link identification
- Content descriptions automatically generated for screen readers

## Cross-Platform Consistency

Both implementations maintain identical:
- **Class Names**: MarkdownParser, MarkdownRenderer, MarkdownText/MarkdownTextView
- **Method Names**: `parse()`, `render()`
- **Token Structure**: Same logical token types across platforms
- **Markdown Support**: Identical syntax recognition
- **Behavior**: Same rendering output for equivalent input

## Dependencies

### iOS
- Foundation (for NSCache, String utilities, NSRegularExpression)
- SwiftUI (for AttributedString, Text, Color, Font)

### Android
- androidx.collection (for LruCache)
- androidx.compose.ui (for AnnotatedString, composables)
- androidx.compose.material3 (for Text styling)
- androidx.core (for core Android utilities)

## Future Enhancements

Potential future additions (not currently implemented):
- Strikethrough text (`~~text~~`)
- Block quotes (`> quote`)
- Horizontal rules (`---`)
- Nested lists
- Mixed formatting in list items
- Image embeds
- Table rendering

## API Documentation

### MarkdownParser

**iOS**
```swift
class MarkdownParser {
    static func parse(_ text: String) -> [MarkdownToken]
}
```

**Android**
```kotlin
class MarkdownParser {
    companion object {
        fun parse(text: String): List<MarkdownToken>
    }
}
```

### MarkdownRenderer

**iOS**
```swift
class MarkdownRenderer {
    static func render(
        tokens: [MarkdownToken],
        font: Font = .body,
        color: Color = .primary
    ) -> AttributedString
}
```

**Android**
```kotlin
class MarkdownRenderer {
    companion object {
        fun render(
            tokens: List<MarkdownToken>,
            fontSize: TextUnit = 14.sp,
            color: Color = Color.Black
        ): AnnotatedString
    }
}
```

### Token Types

**iOS**
```swift
enum MarkdownToken {
    case text(String)
    case bold(String)
    case italic(String)
    case code(String)
    case link(text: String, url: String)
    case header(level: Int, text: String)
    case bulletItem(String)
    case numberedItem(number: Int, text: String)
    case lineBreak
}
```

**Android**
```kotlin
sealed class MarkdownToken {
    data class Text(val text: String) : MarkdownToken()
    data class Bold(val text: String) : MarkdownToken()
    data class Italic(val text: String) : MarkdownToken()
    data class Code(val text: String) : MarkdownToken()
    data class Link(val text: String, val url: String) : MarkdownToken()
    data class Header(val level: Int, val text: String) : MarkdownToken()
    data class BulletItem(val text: String) : MarkdownToken()
    data class NumberedItem(val number: Int, val text: String) : MarkdownToken()
    object LineBreak : MarkdownToken()
}
```

## License

Copyright (c) Microsoft Corporation. All rights reserved.
Licensed under the MIT License.
