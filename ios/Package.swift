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
    ],
    targets: [
        .target(
            name: "ACCore",
            dependencies: []),
        .target(
            name: "ACAccessibility",
            dependencies: ["ACCore"]),
        .target(
            name: "ACInputs",
            dependencies: ["ACCore", "ACAccessibility"]),
        .target(
            name: "ACActions",
            dependencies: ["ACCore", "ACAccessibility"]),
        .target(
            name: "ACRendering",
            dependencies: ["ACCore", "ACInputs", "ACActions", "ACAccessibility"]),
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
    ]
)
