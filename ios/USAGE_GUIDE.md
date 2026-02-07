# Advanced Card Elements - Usage Guide

## Overview

This guide provides comprehensive examples and best practices for using the advanced card elements in the iOS Adaptive Cards SDK.

## Table of Contents

- [Carousel](#carousel)
- [Accordion](#accordion)
- [CodeBlock](#codeblock)
- [Rating Display](#rating-display)
- [Rating Input](#rating-input)
- [ProgressBar](#progressbar)
- [Spinner](#spinner)
- [TabSet](#tabset)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Carousel

### Basic Usage

A Carousel displays multiple pages that users can swipe through.

```json
{
  "type": "Carousel",
  "id": "photoCarousel",
  "pages": [
    {
      "items": [
        {
          "type": "Image",
          "url": "https://example.com/image1.jpg",
          "size": "Stretch"
        },
        {
          "type": "TextBlock",
          "text": "Caption for image 1",
          "wrap": true
        }
      ]
    },
    {
      "items": [
        {
          "type": "Image",
          "url": "https://example.com/image2.jpg",
          "size": "Stretch"
        }
      ]
    }
  ]
}
```

### Auto-Advance Timer

Add automatic page transitions:

```json
{
  "type": "Carousel",
  "timer": 5000,
  "initialPage": 0,
  "pages": [...]
}
```

- `timer`: Milliseconds between auto-advance (e.g., 5000 = 5 seconds)
- `initialPage`: Zero-based index of the starting page

### Page Actions

Add tap actions to individual pages:

```json
{
  "type": "Carousel",
  "pages": [
    {
      "items": [...],
      "selectAction": {
        "type": "Action.OpenUrl",
        "url": "https://example.com/details"
      }
    }
  ]
}
```

### Accessibility Features

- VoiceOver announces: "Page 2 of 3. Swipe left or right to navigate"
- Supports adjustable actions for page navigation
- Each page properly grouped for screen readers

---

## Accordion

### Basic Usage

An Accordion displays collapsible panels of content.

```json
{
  "type": "Accordion",
  "id": "faq",
  "expandMode": "Single",
  "panels": [
    {
      "title": "What is Adaptive Cards?",
      "isExpanded": true,
      "content": [
        {
          "type": "TextBlock",
          "text": "Adaptive Cards are platform-agnostic UI snippets...",
          "wrap": true
        }
      ]
    },
    {
      "title": "Where can I use them?",
      "isExpanded": false,
      "content": [
        {
          "type": "TextBlock",
          "text": "Microsoft Teams, Outlook, Bot Framework...",
          "wrap": true
        }
      ]
    }
  ]
}
```

### Expand Modes

#### Single Expand (Default)

Only one panel can be open at a time:

```json
{
  "type": "Accordion",
  "expandMode": "Single",
  "panels": [...]
}
```

#### Multi Expand

Multiple panels can be open simultaneously:

```json
{
  "type": "Accordion",
  "expandMode": "Multiple",
  "panels": [...]
}
```

### Complex Content

Panels can contain any card elements:

```json
{
  "type": "Accordion",
  "panels": [
    {
      "title": "Product Details",
      "content": [
        {
          "type": "FactSet",
          "facts": [
            {"title": "Price", "value": "$99.99"},
            {"title": "Stock", "value": "In Stock"}
          ]
        },
        {
          "type": "ActionSet",
          "actions": [
            {
              "type": "Action.OpenUrl",
              "title": "Learn More",
              "url": "https://example.com"
            }
          ]
        }
      ]
    }
  ]
}
```

### Accessibility Features

- VoiceOver announces: "Panel 1 of 4. Expanded. Double tap to collapse"
- 44×44pt touch targets for panel headers
- Smooth animations with VoiceOver announcements

---

## CodeBlock

### Basic Usage

Display code with proper formatting:

```json
{
  "type": "CodeBlock",
  "id": "sampleCode",
  "language": "swift",
  "code": "func hello() {\n    print(\"Hello, World!\")\n}"
}
```

### Line Numbers

Add line numbers starting from a specific line:

```json
{
  "type": "CodeBlock",
  "language": "python",
  "startLineNumber": 10,
  "code": "def calculate(x, y):\n    return x + y"
}
```

### Code Wrapping

Enable line wrapping for long lines:

```json
{
  "type": "CodeBlock",
  "language": "javascript",
  "wrap": true,
  "code": "const veryLongVariableName = someFunction(parameter1, parameter2, parameter3);"
}
```

### Supported Features

- **Copy to Clipboard**: Built-in copy button
- **Horizontal Scrolling**: For unwrapped code
- **Monospace Font**: Scales with Dynamic Type
- **Language Labels**: Displays programming language

### Accessibility Features

- VoiceOver reads entire code block
- Copy button announces "Code copied to clipboard"
- Font size adapts to accessibility text sizes
- Line numbers hidden from screen readers

---

## Rating Display

### Basic Usage

Show read-only star ratings:

```json
{
  "type": "Rating",
  "id": "productRating",
  "value": 4.5,
  "max": 5,
  "count": 128
}
```

### Size Options

Control star size:

```json
{
  "type": "Rating",
  "value": 4.5,
  "size": "Small"
}
```

Available sizes: `Small`, `Medium` (default), `Large`

### Without Review Count

```json
{
  "type": "Rating",
  "value": 3.5,
  "max": 5
}
```

### Accessibility Features

- VoiceOver announces: "Rating: 4.5 out of 5 stars, based on 128 reviews"
- Half-star values supported
- Scales with Dynamic Type

---

## Rating Input

### Basic Usage

Interactive star picker for user input:

```json
{
  "type": "Input.Rating",
  "id": "userRating",
  "label": "Rate this product",
  "max": 5
}
```

### With Validation

Require rating before submission:

```json
{
  "type": "Input.Rating",
  "id": "requiredRating",
  "label": "How would you rate this?",
  "max": 5,
  "isRequired": true,
  "errorMessage": "Please provide a rating"
}
```

### With Default Value

Pre-select a rating:

```json
{
  "type": "Input.Rating",
  "id": "editRating",
  "value": 3,
  "max": 5
}
```

### In Forms

Combine with other inputs:

```json
{
  "type": "AdaptiveCard",
  "version": "1.6",
  "body": [
    {
      "type": "TextBlock",
      "text": "Product Review",
      "weight": "Bolder",
      "size": "Large"
    },
    {
      "type": "Input.Rating",
      "id": "rating",
      "label": "Overall Rating",
      "isRequired": true,
      "max": 5
    },
    {
      "type": "Input.Text",
      "id": "comment",
      "label": "Comments (optional)",
      "isMultiline": true,
      "placeholder": "Share your experience..."
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "Submit Review"
    }
  ]
}
```

### Accessibility Features

- Each star individually accessible
- VoiceOver announces: "3 stars. Selected."
- State changes announced
- 44×44pt touch targets
- Scales with Dynamic Type

---

## ProgressBar

### Basic Usage

Show linear progress:

```json
{
  "type": "ProgressBar",
  "id": "downloadProgress",
  "value": 0.75,
  "label": "Download Progress"
}
```

- `value`: 0.0 to 1.0 (0% to 100%)

### Custom Colors

Use hex or named colors:

```json
{
  "type": "ProgressBar",
  "value": 0.85,
  "label": "Upload",
  "color": "#0078D4"
}
```

```json
{
  "type": "ProgressBar",
  "value": 1.0,
  "label": "Complete",
  "color": "green"
}
```

Supported named colors: `blue`, `green`, `red`, `yellow`, `orange`, `purple`

### Progress Steps

Show multiple progress bars:

```json
{
  "type": "Container",
  "items": [
    {
      "type": "ProgressBar",
      "label": "Step 1: Personal Info",
      "value": 1.0,
      "color": "green"
    },
    {
      "type": "ProgressBar",
      "label": "Step 2: Address",
      "value": 1.0,
      "color": "green"
    },
    {
      "type": "ProgressBar",
      "label": "Step 3: Payment",
      "value": 0.5,
      "color": "blue"
    },
    {
      "type": "ProgressBar",
      "label": "Step 4: Review",
      "value": 0.0
    }
  ]
}
```

### Accessibility Features

- VoiceOver announces: "Upload progress. 75 percent"
- Updates frequently trait for live progress
- Label provides context

---

## Spinner

### Basic Usage

Show loading state:

```json
{
  "type": "Spinner",
  "id": "loadingSpinner",
  "label": "Loading..."
}
```

### Size Options

```json
{
  "type": "Spinner",
  "size": "Small",
  "label": "Processing..."
}
```

Available sizes: `Small`, `Medium` (default), `Large`

### Loading States

Different contexts:

```json
{
  "type": "Container",
  "items": [
    {
      "type": "TextBlock",
      "text": "Fetching data",
      "weight": "Bolder"
    },
    {
      "type": "Spinner",
      "size": "Medium",
      "label": "Please wait..."
    }
  ]
}
```

### Accessibility Features

- VoiceOver announces: "Loading. Please wait..."
- Updates frequently trait
- Scales with accessibility sizes

---

## TabSet

### Basic Usage

Create tabbed content:

```json
{
  "type": "TabSet",
  "id": "contentTabs",
  "tabs": [
    {
      "id": "tab1",
      "title": "Overview",
      "items": [
        {
          "type": "TextBlock",
          "text": "Overview content here"
        }
      ]
    },
    {
      "id": "tab2",
      "title": "Details",
      "items": [
        {
          "type": "TextBlock",
          "text": "Detailed information"
        }
      ]
    }
  ]
}
```

### With Icons

Add SF Symbol icons to tabs:

```json
{
  "type": "TabSet",
  "tabs": [
    {
      "id": "home",
      "title": "Home",
      "icon": "house.fill",
      "items": [...]
    },
    {
      "id": "settings",
      "title": "Settings",
      "icon": "gear",
      "items": [...]
    }
  ]
}
```

### Pre-Selected Tab

```json
{
  "type": "TabSet",
  "selectedTabId": "details",
  "tabs": [...]
}
```

### Complex Tab Content

Tabs can contain any elements:

```json
{
  "type": "TabSet",
  "tabs": [
    {
      "id": "dashboard",
      "title": "Dashboard",
      "items": [
        {
          "type": "ColumnSet",
          "columns": [
            {
              "width": "stretch",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "Metrics",
                  "weight": "Bolder"
                },
                {
                  "type": "ProgressBar",
                  "value": 0.85,
                  "label": "Completion"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

### Accessibility Features

- Tab trait for buttons
- VoiceOver announces: "Overview. Selected tab"
- Scrollable tab bar for many tabs
- 44×44pt touch targets
- Tab selection announced

---

## Best Practices

### Responsive Design

1. **Test on Multiple Devices**
   - iPhone SE (small screen)
   - Standard iPhone
   - iPhone Plus/Max
   - iPad
   - iPad Pro

2. **Consider Orientation**
   - Portrait and landscape
   - All elements adapt automatically

3. **Dynamic Type**
   - Test with largest accessibility text sizes
   - All elements scale properly

### Accessibility

1. **Always Provide Labels**
   - Use descriptive `label` properties
   - Rating inputs need clear labels

2. **Test with VoiceOver**
   - Enable VoiceOver and navigate
   - Verify all elements are accessible

3. **Touch Targets**
   - All interactive elements are 44×44pt minimum
   - Automatically handled by views

### Performance

1. **Carousel Auto-Advance**
   - Keep timer values reasonable (3-10 seconds)
   - Consider user preference for motion

2. **Complex Tab Content**
   - Content loads only when tab is selected
   - Keep individual tabs focused

3. **Code Blocks**
   - Limit code length for performance
   - Use horizontal scrolling for long lines

### Content

1. **Carousel Pages**
   - Keep page count reasonable (3-7 pages)
   - Use clear navigation indicators

2. **Accordion Panels**
   - Use descriptive titles
   - Keep content focused

3. **Code Blocks**
   - Specify programming language
   - Add helpful comments in code

---

## Troubleshooting

### Carousel Not Auto-Advancing

**Problem**: Carousel pages don't change automatically.

**Solutions**:
- Verify `timer` value is set and > 0
- Timer is in milliseconds (5000 = 5 seconds)
- Check that carousel has multiple pages

### Accordion Panels Not Expanding

**Problem**: Tapping accordion header doesn't expand/collapse.

**Solutions**:
- Verify panel has `content` array
- Check `expandMode` is set correctly
- Ensure accordion is visible

### Rating Input Not Validating

**Problem**: Required rating shows no error.

**Solutions**:
- Set `isRequired: true`
- Provide `errorMessage` text
- Validation triggers on submit

### Code Not Copying

**Problem**: Copy button doesn't work.

**Solutions**:
- iOS clipboard permissions automatic
- Verify button is interactive
- Check for UIKit import

### TabSet Tabs Not Scrolling

**Problem**: Can't see all tabs.

**Solutions**:
- Tab bar automatically scrolls with many tabs
- Swipe horizontally on tab bar
- Works best with 2-6 tabs

### Progress Bar Wrong Color

**Problem**: Custom color not showing.

**Solutions**:
- Use hex format: `"#0078D4"`
- Or named colors: `"blue"`, `"green"`, `"red"`
- Verify hex includes `#` prefix

---

## Known Limitations

1. **Carousel**
   - Auto-advance pauses when app backgrounds
   - No gesture customization

2. **CodeBlock**
   - Basic syntax highlighting only
   - No language-specific features

3. **TabSet**
   - Icons use SF Symbols only
   - No custom tab styling

---

## Additional Resources

- [ACCESSIBILITY.md](ACCESSIBILITY.md) - Accessibility compliance guide
- [Test Cards](../../shared/test-cards/) - Example JSON files
- [iOS README](README.md) - SDK documentation

---

## Support

For issues or questions:
1. Check test cards for working examples
2. Review accessibility guide for VoiceOver
3. Verify JSON schema matches examples
4. Test on actual devices, not just simulator
