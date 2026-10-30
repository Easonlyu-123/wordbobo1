// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WordBoBo",
    platforms: [.iOS(.v17)],
    products: [
        .executable(name: "WordBoBo", targets: ["WordBoBo"])
    ],
    targets: [
        .target(
            name: "WordBoBo",
            path: "WordBoBo",
            exclude: ["SceneDelegate.swift"],
            swiftSettings: [.unsafeFlags(["-I", "."])]
        )
    ]
)
