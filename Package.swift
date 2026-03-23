// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "VroxalDesign",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Import as: import VroxalDesign
        .library(
            name: "VroxalDesign",
            targets: ["VroxalDesign"]
        ),
    ],
    targets: [
        .target(
            name: "VroxalDesign",
            path: "Sources/VroxalDesign",
            resources: [
                // Poppins font files (add to Sources/VroxalDesign/Resources/)
                .process("Resources")
            ]
        ),
//        .testTarget(
//            name: "VroxalDesignTests",
//            dependencies: ["VroxalDesign"],
//            path: "Tests/VroxalDesignTests"
//        ),
    ]
)
