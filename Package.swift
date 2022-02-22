// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "ObservedObject",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13), .macCatalyst(.v13)],
    products: [
        .library(
            name: "ObservedObject",
            targets: ["ObservedObject"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ObservedObject",
            dependencies: []
        ),
        
        .testTarget(
            name: "ObservedObjectTests",
            dependencies: ["ObservedObject"]
        ),
    ]
)
