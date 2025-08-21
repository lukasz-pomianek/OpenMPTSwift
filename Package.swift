// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenMPTSwift",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "OpenMPTSwift", 
            type: .static,
            targets: ["OpenMPTSwift", "LibOpenMPT"]
        ),
    ],
    dependencies: [],
    targets: [
        // Native Swift API layer
        .target(
            name: "OpenMPTSwift",
            dependencies: ["CLibOpenMPT"],
            path: "Sources/OpenMPTSwift"
        ),
        
        // C bridge layer - minimal implementation
        .target(
            name: "CLibOpenMPT",
            dependencies: ["LibOpenMPT"],
            path: "Sources/CLibOpenMPT",
            sources: ["CLibOpenMPT.c"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
                .define("LIBOPENMPT_STATIC")
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedLibrary("z")
            ]
        ),
        
        // XCFramework binary target
        .binaryTarget(
            name: "LibOpenMPT",
            path: "Frameworks/LibOpenMPT.xcframework"
        ),
        
        // Test target
        .testTarget(
            name: "OpenMPTSwiftTests",
            dependencies: ["OpenMPTSwift"],
            path: "Tests/OpenMPTSwiftTests"
        ),
    ]
)