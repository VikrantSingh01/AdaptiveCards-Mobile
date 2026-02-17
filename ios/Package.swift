// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdaptiveCards",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "ACCore",
            targets: ["ACCore"]),
        .library(
            name: "ACRendering",
            targets: ["ACRendering"]),
        .library(
            name: "ACInputs",
            targets: ["ACInputs"]),
        .library(
            name: "ACActions",
            targets: ["ACActions"]),
        .library(
            name: "ACAccessibility",
            targets: ["ACAccessibility"]),
        .library(
            name: "ACTemplating",
            targets: ["ACTemplating"]),
        .library(
            name: "ACMarkdown",
            targets: ["ACMarkdown"]),
        .library(
            name: "ACCharts",
            targets: ["ACCharts"]),
        .library(
            name: "ACFluentUI",
            targets: ["ACFluentUI"]),
        .library(
            name: "ACCopilotExtensions",
            targets: ["ACCopilotExtensions"]),
        .library(
            name: "ACTeams",
            targets: ["ACTeams"]),
    ],
    targets: [
        .target(
            name: "ACCore",
            dependencies: []),
        .target(
            name: "ACAccessibility",
            dependencies: ["ACCore"]),
        .target(
            name: "ACTemplating",
            dependencies: ["ACCore"]),
        .target(
            name: "ACMarkdown",
            dependencies: []),
        .target(
            name: "ACCharts",
            dependencies: ["ACCore", "ACFluentUI"]),
        .target(
            name: "ACFluentUI",
            dependencies: []),
        .target(
            name: "ACInputs",
            dependencies: ["ACCore", "ACAccessibility"]),
        .target(
            name: "ACActions",
            dependencies: ["ACCore", "ACAccessibility"]),
        .target(
            name: "ACRendering",
            dependencies: ["ACCore", "ACInputs", "ACActions", "ACAccessibility", "ACMarkdown", "ACCharts", "ACFluentUI"]),
        .target(
            name: "ACCopilotExtensions",
            dependencies: ["ACCore"]),
        .target(
            name: "ACTeams",
            dependencies: ["ACCore", "ACRendering"]),
        .testTarget(
            name: "ACCoreTests",
            dependencies: ["ACCore"],
            resources: [.copy("Resources")]),
        .testTarget(
            name: "ACRenderingTests",
            dependencies: ["ACRendering"]),
        .testTarget(
            name: "ACInputsTests",
            dependencies: ["ACInputs"]),
        .testTarget(
            name: "ACTemplatingTests",
            dependencies: ["ACTemplating"]),
        .testTarget(
            name: "ACMarkdownTests",
            dependencies: ["ACMarkdown"]),
        .testTarget(
            name: "ACChartsTests",
            dependencies: ["ACCharts"]),
        .testTarget(
            name: "IntegrationTests",
            dependencies: ["ACCore"],
            resources: [.copy("Resources")]),
        .testTarget(
            name: "VisualTests",
            dependencies: ["ACCore", "ACRendering", "ACInputs", "ACActions", "ACAccessibility", "ACTemplating", "ACMarkdown", "ACCharts", "ACFluentUI"]),
    ]
)
