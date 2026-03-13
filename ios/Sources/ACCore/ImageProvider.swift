// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Protocol for custom image loading.
/// Implement this to route images through authenticated CDN, custom cache, or local resources.
///
/// ```swift
/// class TeamsImageProvider: ImageProvider {
///     func loadImage(from url: URL) async throws -> UIImage {
///         var request = URLRequest(url: url)
///         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
///         let (data, _) = try await URLSession.shared.data(for: request)
///         guard let image = UIImage(data: data) else {
///             throw ImageProviderError.invalidData
///         }
///         return image
///     }
/// }
/// ```
public protocol ImageProvider: Sendable {
    #if canImport(UIKit)
    /// Load an image from the given URL.
    /// The SDK wraps this with caching — implementations only need to handle fetching.
    func loadImage(from url: URL) async throws -> UIImage
    #endif
}

/// Errors that an ImageProvider may throw
public enum ImageProviderError: Error, Sendable {
    case invalidURL
    case invalidData
    case networkError(Error)
    case timeout
}
