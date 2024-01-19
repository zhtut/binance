// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var pDependencies = [PackageDescription.Package.Dependency]()
var tDependencies = [PackageDescription.Target.Dependency]()

pDependencies += [
    .package(url: "https://github.com/zhtut/Networking.git", branch: "main"),
    .package(url: "https://github.com/zhtut/UtilCore.git", branch: "main"),
//    .package(path: "../UtilCore"),
    .package(url: "https://github.com/zhtut/SSEncrypt.git", branch: "main"),
]
tDependencies += [
    "Networking",
    "UtilCore",
    "SSEncrypt",
]

#if os(macOS) || os(iOS)
// ios 和 macos不需要这个，系统自带了
#else
let latestVersion: Range<Version> = "0.0.1"..<"99.99.99"
pDependencies += [
    .package(url: "https://github.com/zhtut/CombineX.git", latestVersion),
]
tDependencies += [
    "CombineX"
]
#endif

let package = Package(
    name: "Binance",
    platforms: [
        // combine的flatMap和switchToLatest都要求ios14加才能使用
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "Binance", targets: ["Binance"]),
    ],
    dependencies: pDependencies,
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "Binance", dependencies: tDependencies),
        .testTarget(name: "BinanceTests", dependencies: ["Binance"]),
    ]
)
