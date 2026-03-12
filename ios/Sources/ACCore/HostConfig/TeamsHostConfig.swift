// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import Foundation

/// Pre-configured Microsoft Teams host config loaded from bundled JSON files.
/// JSON source of truth lives in shared/host-configs/ios/.
public class TeamsHostConfig {
    private static var lightConfig: HostConfig?
    private static var darkConfig: HostConfig?

    /// Returns the default (light) Teams host config.
    public static func create() -> HostConfig { createLight() }

    /// Returns the light Teams host config, cached after first load.
    public static func createLight() -> HostConfig {
        if let cached = lightConfig { return cached }
        let config = loadBundledConfig("microsoft-teams-light")
        lightConfig = config
        return config
    }

    /// Returns the dark Teams host config, cached after first load.
    public static func createDark() -> HostConfig {
        if let cached = darkConfig { return cached }
        let config = loadBundledConfig("microsoft-teams-dark")
        darkConfig = config
        return config
    }

    private static func loadBundledConfig(_ name: String) -> HostConfig {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Resources") else {
            print("TeamsHostConfig: Missing bundled config \(name).json, using defaults")
            return HostConfig()
        }
        do {
            let data = try Data(contentsOf: url)
            return try HostConfigParser.parse(data)
        } catch {
            print("TeamsHostConfig: Failed to parse \(name).json — \(error)")
            return HostConfig()
        }
    }
}
