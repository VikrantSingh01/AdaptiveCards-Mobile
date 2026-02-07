import Foundation

/// Represents a data context for template evaluation with support for nested contexts
public final class DataContext {
    /// The current data value
    public let data: Any?
    
    /// The root data value (top-level context)
    public let root: Any?
    
    /// The current index when iterating over arrays
    public let index: Int?
    
    /// Parent context for nested scopes
    public weak var parent: DataContext?
    
    /// Initialize a root data context
    /// - Parameter data: The root data object
    public init(data: Any?) {
        self.data = data
        self.root = data
        self.index = nil
        self.parent = nil
    }
    
    /// Initialize a nested data context
    /// - Parameters:
    ///   - data: The current scope data
    ///   - root: The root data object
    ///   - index: The current iteration index
    ///   - parent: The parent context
    public init(data: Any?, root: Any?, index: Int?, parent: DataContext?) {
        self.data = data
        self.root = root
        self.index = index
        self.parent = parent
    }
    
    /// Resolve a property path in the current context
    /// - Parameter path: Property path (e.g., "user.name", "$root.title", "$index")
    /// - Returns: The resolved value or nil if not found
    public func resolve(path: String) -> Any? {
        // Handle special variables
        if path == "$data" {
            return data
        } else if path == "$root" {
            return root
        } else if path == "$index" {
            return index
        }
        
        // Handle path starting with $root
        if path.hasPrefix("$root.") {
            let remainingPath = String(path.dropFirst(6)) // Remove "$root."
            return resolvePath(remainingPath, in: root)
        }
        
        // Handle path starting with $data
        if path.hasPrefix("$data.") {
            let remainingPath = String(path.dropFirst(6)) // Remove "$data."
            return resolvePath(remainingPath, in: data)
        }
        
        // Regular property path - resolve from current data
        return resolvePath(path, in: data)
    }
    
    /// Resolve a property path in a given object
    /// - Parameters:
    ///   - path: Property path (e.g., "user.name")
    ///   - object: The object to resolve from
    /// - Returns: The resolved value or nil
    private func resolvePath(_ path: String, in object: Any?) -> Any? {
        guard let object = object else { return nil }
        
        let components = path.split(separator: ".").map(String.init)
        var current: Any? = object
        
        for component in components {
            guard let currentValue = current else { return nil }
            
            if let dict = currentValue as? [String: Any] {
                current = dict[component]
            } else if let array = currentValue as? [Any], let index = Int(component) {
                guard index >= 0 && index < array.count else { return nil }
                current = array[index]
            } else {
                // Try to use reflection for custom objects
                let mirror = Mirror(reflecting: currentValue)
                current = mirror.children.first { $0.label == component }?.value
            }
        }
        
        return current
    }
    
    /// Create a child context for iteration
    /// - Parameters:
    ///   - data: The item data
    ///   - index: The iteration index
    /// - Returns: A new child context
    public func createChild(data: Any?, index: Int) -> DataContext {
        return DataContext(data: data, root: root, index: index, parent: self)
    }
}
