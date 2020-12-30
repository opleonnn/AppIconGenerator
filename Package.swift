// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppIconGenerator",
    targets: [
        .target(
            name: "AppIconGenerator",
            dependencies: ["AppIconGeneratorCore"]),
        .target(
            name: "AppIconGeneratorCore"),
        .testTarget(
            name: "AppIconGeneratorTests",
            dependencies: ["AppIconGenerator"]),
    ]
)
