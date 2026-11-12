// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacBookIsland",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "MacBookIsland", targets: ["MacBookIsland"])],
    targets: [
        .target(name: "IslandCore"),
        .executableTarget(name: "MacBookIsland", dependencies: ["IslandCore"]),
        .testTarget(name: "IslandCoreTests", dependencies: ["IslandCore"])
    ]
)
