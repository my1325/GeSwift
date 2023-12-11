// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GeSwift",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "Tools", targets: ["Tools"]),
        .library(name: "UIAbout", targets: ["UIAbout"]),
        .library(name: "DataSource", targets: ["DataSource"]),
        .library(name: "Custom", targets: ["Custom"]),
        .library(name: "CycleScrollView", targets: ["CycleScrollView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/luoxiu/Schedule.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(name: "Tools", path: "Tools"),
        .target(name: "DataSource", path: "DataSource"),
        .target(name: "Custom", path: "Custom"),
        .target(name: "UIAbout", path: "UIAbout"),
        .target(name: "CycleScrollView", dependencies: [
        "Kingfisher",
        "SnapKit",
        "Schedule",
        "Tools",
        "UIAbout"
        ], path: "Other/CycleScrollView"),
    ]
)
