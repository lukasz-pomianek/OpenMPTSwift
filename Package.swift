// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenMPTSwift",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "OpenMPTSwift",
            targets: ["OpenMPTSwift"]
        ),
    ],
    dependencies: [],
    targets: [
        // Native Swift API layer
        .target(
            name: "OpenMPTSwift",
            dependencies: ["CLibOpenMPT"],
            path: "Sources/OpenMPTSwift",
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedLibrary("z"),
                .linkedFramework("AudioToolbox", .when(platforms: [.iOS]))
            ]
        ),
        
        // C bridge layer - minimal implementation
        .target(
            name: "CLibOpenMPT",
            dependencies: ["LibOpenMPT"],
            path: "Sources/CLibOpenMPT",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
                .define("LIBOPENMPT_STATIC")
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