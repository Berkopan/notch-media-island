// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NotchMediaIsland",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "NotchMediaIsland", targets: ["NotchMediaIsland"])],
    targets: [
        .target(name: "IslandCore"),
        .executableTarget(name: "NotchMediaIsland", dependencies: ["IslandCore"]),
        .testTarget(name: "IslandCoreTests", dependencies: ["IslandCore"])
    ]
)
