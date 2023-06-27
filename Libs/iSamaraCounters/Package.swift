// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iSamaraCounters",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "iSamaraCounters",
            targets: ["iSamaraCounters"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.0.0"),
         .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.9.1"),
         //.package(url: "https://github.com/ByteriX/BxInputController.git", from: "2.0.0")
         .package(url: "https://github.com/ByteriX/BxInputController.git", .branch("master")),
         .package(url: "https://github.com/cezheng/Fuzi.git", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "iSamaraCounters",
            dependencies: ["PromiseKit", "Alamofire", "BxInputController", "Fuzi"]),
        .testTarget(
            name: "iSamaraCountersTests",
            dependencies: ["iSamaraCounters"]),
    ]
)
