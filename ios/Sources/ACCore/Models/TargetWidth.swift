import Foundation

/// Width categories for responsive targetWidth filtering per Adaptive Cards spec.
public enum WidthCategory: Int, Comparable {
    case veryNarrow = 0
    case narrow = 1
    case standard = 2
    case wide = 3

    public static func < (lhs: WidthCategory, rhs: WidthCategory) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Determine the width category from a point value using hostConfig breakpoints.
    public static func from(width: CGFloat, hostConfig: HostConfig) -> WidthCategory {
        let veryNarrow = CGFloat(hostConfig.hostWidth.veryNarrow)
        let narrow = CGFloat(hostConfig.hostWidth.narrow)
        let standard = CGFloat(hostConfig.hostWidth.standard)

        // Use hostConfig breakpoints if configured, otherwise use sensible defaults
        let effectiveNarrow = narrow > 0 ? narrow : 413
        let effectiveStandard = standard > 0 ? standard : 500

        if veryNarrow > 0 && width <= veryNarrow {
            return .veryNarrow
        } else if width <= effectiveNarrow {
            return .narrow
        } else if width <= effectiveStandard {
            return .standard
        } else {
            return .wide
        }
    }

    /// Parse a category name (case-insensitive).
    public static func fromName(_ name: String) -> WidthCategory? {
        switch name.lowercased() {
        case "verynarrow": return .veryNarrow
        case "narrow": return .narrow
        case "standard": return .standard
        case "wide": return .wide
        default: return nil
        }
    }
}

/// Evaluates whether an element's `targetWidth` constraint matches the current width category.
///
/// Supported formats:
/// - `"VeryNarrow"`, `"Narrow"`, `"Standard"`, `"Wide"` — exact match
/// - `"AtLeast:Narrow"` — matches Narrow, Standard, Wide
/// - `"AtMost:Narrow"` — matches VeryNarrow, Narrow
///
/// Returns `true` if targetWidth is nil/empty (element always visible).
public func shouldShowForTargetWidth(_ targetWidth: String?, currentCategory: WidthCategory) -> Bool {
    guard let targetWidth = targetWidth, !targetWidth.isEmpty else {
        return true
    }

    let trimmed = targetWidth.trimmingCharacters(in: .whitespaces)

    // "AtLeast:X" — current must be >= X
    if trimmed.lowercased().hasPrefix("atleast:") {
        let categoryName = String(trimmed.dropFirst("AtLeast:".count))
        guard let threshold = WidthCategory.fromName(categoryName) else { return true }
        return currentCategory >= threshold
    }

    // "AtMost:X" — current must be <= X
    if trimmed.lowercased().hasPrefix("atmost:") {
        let categoryName = String(trimmed.dropFirst("AtMost:".count))
        guard let threshold = WidthCategory.fromName(categoryName) else { return true }
        return currentCategory <= threshold
    }

    // Exact match
    guard let exact = WidthCategory.fromName(trimmed) else { return true }
    return currentCategory == exact
}
