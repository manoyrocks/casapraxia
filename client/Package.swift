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
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.21.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0"),
    ],
    targets: [
        .target(
            name: "PraxiaChild",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
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
