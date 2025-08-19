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
                .linkedFramework("AudioToolbox", .when(platforms: [.iOS])),
                .unsafeFlags([
                    "-Wl,-U,_ZN7OpenMPT10CSoundFile13ReadMP3SampleEtRN7OpenMPT6detail10FileReaderIN3mpt15mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_23FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEEbb",
                    "-Wl,-U,_ZN7OpenMPT10CSoundFile15ReadOpusSampleEtRN7OpenMPT6detail10FileReaderIN3mpt15mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_23FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEE",
                    "-Wl,-U,_ZN7OpenMPT10CSoundFile17ReadVorbisSampleEtRN7OpenMPT6detail10FileReaderIN3mpt15mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_23FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEE",
                    "-Wl,-undefined,dynamic_lookup"
                ], .when(platforms: [.iOS, .macOS]))
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
            ],
            cxxSettings: [
                .headerSearchPath("include")
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