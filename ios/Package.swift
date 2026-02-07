// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdaptiveCards",
    platforms: [
        .iOS(.v16)
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
            name: "ACInputs",
            dependencies: ["ACCore", "ACAccessibility"]),
        .target(
            name: "ACActions",
            dependencies: ["ACCore", "ACAccessibility"]),
        .target(
            name: "ACRendering",
            dependencies: ["ACCore", "ACInputs", "ACActions", "ACAccessibility", "ACMarkdown"]),
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
    ]
)
