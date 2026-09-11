// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PraxiaChild",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(name: "PraxiaChild", targets: ["PraxiaChild"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.27.0"),
    ],
    targets: [
        .target(
            name: "PraxiaChild",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "PraxiaChildTests",
            dependencies: ["PraxiaChild"]
        ),
    ]
)
