// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GeSwift",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "Tools", targets: ["Tools"]),
        .library(name: "DataSource", targets: ["DataSource"]),
        .library(name: "Custom", targets: ["Custom"]),
        .library(name: "CycleScrollView", targets: ["CycleScrollView"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/luoxiu/Schedule.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(name: "Tools"),
        .target(name: "DataSource"),
        .target(name: "Custom"),
        .target(name: "CycleScrollView", dependencies: [
        "Kingfisher",
        "SnapKit",
        "Schedule",
        "Tools"
        ])
    ]
)
