// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

struct PackageName {
    let name: String
    let dependencies: [String]
    
    init(name: String, dependencies: [String] = []) {
        self.name = name
        self.dependencies = dependencies
    }
    
    var target: Target {
        .target(
            name: name,
            dependencies: dependencies
                .map{ .init(stringLiteral: $0) }
        )
    }
    
    var product: Product {
        .library(name: name, targets: [name])
    }
}

let names: [PackageName] = [
    .init(name: "SwiftUITools"),
    .init(name: "DataSources"),
    .init(name: "Components", dependencies: ["GeTools"]),
    .init(name: "WrapNavigationController"),
    .init(name: "GeTools")
]

let package = Package(
    name: "GeSwift",
    platforms: [.iOS(.v13)],
    products: names.map(\.product),
    targets: names.map(\.target)
)
