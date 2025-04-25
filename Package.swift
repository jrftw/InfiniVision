// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "InfiniVisionKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "InfiniVisionKit",
            targets: ["InfiniVisionKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "InfiniVisionKit",
            dependencies: [],
            path: "Shared"
        )
    ]
) 