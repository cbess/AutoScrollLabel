// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "AutoScrollLabel",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "AutoScrollLabel",
            targets: ["AutoScrollLabel"]
        ),
    ],
    targets: [
        .target(
            name: "AutoScrollLabel",
            path: "CBAutoScrollLabel",
            publicHeadersPath: "."
        ),
    ]
)
