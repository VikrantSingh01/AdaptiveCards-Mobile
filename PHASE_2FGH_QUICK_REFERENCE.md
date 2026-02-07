# Phase 2F/G/H Quick Reference

## Fluent UI Theming

### iOS Usage
```swift
import ACFluentUI

// Access theme in view
@Environment(\.fluentTheme) var theme

// Apply colors
Text("Hello").foregroundColor(theme.colors.brand)

// Apply typography
Text("Title").font(theme.typography.title1.font)

// Apply spacing
VStack(spacing: theme.spacing.m) { ... }

// Apply corner radii
RoundedRectangle(cornerRadius: theme.cornerRadii.medium)
```

### Android Usage
```kotlin
import com.microsoft.adaptivecards.fluentui.*

// Access theme in composable
val theme = LocalFluentTheme.current

// Apply colors
Text("Hello", color = theme.colors.brand)

// Apply typography
Text("Title", fontSize = theme.typography.title1.size)

// Apply spacing
Column(verticalArrangement = Arrangement.spacedBy(theme.spacing.m))

// Apply corner radii
RoundedCornerShape(theme.cornerRadii.medium)
```

## Schema Validation

### iOS
```swift
import ACCore

let validator = SchemaValidator()
let errors = validator.validate(json: jsonString)

if errors.isEmpty {
    print("Valid card")
} else {
    errors.forEach { 
        print("\($0.path): \($0.message)")
    }
}
```

### Android
```kotlin
import com.microsoft.adaptivecards.core.SchemaValidator

val validator = SchemaValidator()
val errors = validator.validate(jsonString)

if (errors.isEmpty()) {
    println("Valid card")
} else {
    errors.forEach {
        println("${it.path}: ${it.message}")
    }
}
```

## Model Updates

### targetWidth in JSON
```json
{
  "type": "Container",
  "targetWidth": "wide",
  "items": [...]
}
```

Values: `"compact"` | `"standard"` | `"wide"` | `null`

### themedUrls in JSON
```json
{
  "type": "Image",
  "url": "default.png",
  "themedUrls": {
    "light": "light.png",
    "dark": "dark.png",
    "highContrast": "hc.png"
  }
}
```

## Color Tokens

| Token | Light | Dark | Hex |
|-------|-------|------|-----|
| brand | Purple | Purple | #6264A7 |
| surface | White | Dark Gray | #FFF / #292929 |
| foreground | Black | White | #242424 / #FFF |

## Typography Scale

| Level | Size | Weight | Line Height |
|-------|------|--------|-------------|
| caption2 | 10sp | Regular | 12sp |
| caption1 | 12sp | Regular | 16sp |
| body1 | 14sp | Regular | 20sp |
| body2 | 14sp | Semibold | 20sp |
| subtitle2 | 16sp | Regular | 22sp |
| subtitle1 | 16sp | Semibold | 22sp |
| title3 | 20sp | Semibold | 26sp |
| title2 | 24sp | Semibold | 32sp |
| title1 | 28sp | Semibold | 36sp |
| largeTitle | 32sp | Semibold | 40sp |
| display | 40sp | Semibold | 52sp |

## Spacing Scale

| Token | Value |
|-------|-------|
| xxs | 2pt |
| xs | 4pt |
| s | 8pt |
| sPlus | 12pt |
| m | 16pt |
| mPlus | 20pt |
| l | 24pt |
| xl | 32pt |
| xxl | 40pt |
| xxxl | 48pt |

## Valid Element Types

TextBlock, Image, Media, RichTextBlock, Container, ColumnSet, ImageSet, FactSet, ActionSet, Table, Input.Text, Input.Number, Input.Date, Input.Time, Input.Toggle, Input.ChoiceSet, Carousel, Accordion, CodeBlock, Rating, Input.Rating, ProgressBar, Spinner, TabSet, List, CompoundButton, DonutChart, BarChart, LineChart, PieChart

## Breakpoints

| Name | Width | Device |
|------|-------|--------|
| compact | < 480px | Phone portrait |
| standard | 480-720px | Tablet portrait |
| wide | > 720px | Tablet landscape |
