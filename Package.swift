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
        .target(name: name, dependencies: dependencies.map(Target.Dependency.init(stringLiteral:)))
    }
    
    var product: Product {
        .library(name: name, targets: [name])
    }
}

let names: [PackageName] = [
    .init(name: "FoundationTools"),
    .init(name: "SwiftUITools"),
    .init(name: "UITools"),
    .init(name: "DataSources"),
    .init(name: "CustomViews"),
    .init(name: "CollectionViewLayouts"),
]

let package = Package(
    name: "GeSwift",
    platforms: [.iOS(.v13)],
    products: names.map(\.product),
    targets: names.map(\.target)
)
