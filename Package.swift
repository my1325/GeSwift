// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GeSwift",
    products: [
        .library(name: "Tools", targets: ["Tools"]),
        .library(name: "DataSource", targets: ["DataSource"]),
        .library(name: "Custom", targets: ["Custom"])
    ],
    targets: [
        .target(name: "Tools"),
        .target(name: "DataSource"),
        .target(name: "Custom")
    ]
)
