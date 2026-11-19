// swift-tools-version: 5.9

import PackageDescription

// The iOS side of cynopta_flutter for Swift Package Manager hosts (Flutter's default). CocoaPods hosts use
// ../cynopta_flutter.podspec; both take the same vendored Cynopta iOS SDK frameworks.
let sdkFrameworks = ["CynoptaKit", "CynoptaConfigKit", "CynoptaMetricsKit", "CynoptaReportKit", "CynoptaAppKit"]

let package = Package(
    name: "cynopta_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "cynopta-flutter", targets: ["cynopta_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "cynopta_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ] + sdkFrameworks.map { .target(name: $0) }
        )
    ] + sdkFrameworks.map { .binaryTarget(name: $0, path: "Frameworks/\($0).xcframework") }
)
