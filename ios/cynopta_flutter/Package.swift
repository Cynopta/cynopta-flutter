// swift-tools-version: 5.9

import PackageDescription

// The iOS side of cynopta_flutter. iOS is supported through Swift Package Manager only (Flutter's default). The Cynopta
// iOS SDK comes from https://github.com/Cynopta/ios-sdk-dist at an exact version, as the Android side takes
// com.github.Cynopta:android-sdk-dist.
let package = Package(
    name: "cynopta_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "cynopta-flutter", targets: ["cynopta_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/Cynopta/ios-sdk-dist", exact: "1.0.24")
    ],
    targets: [
        .target(
            name: "cynopta_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Cynopta", package: "ios-sdk-dist")
            ]
        )
    ]
)
