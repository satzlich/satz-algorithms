// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "satz-algorithms",
  platforms: [
    .macOS(.v14),
    .iOS(.v12),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "SatzAlgorithms",
      targets: ["SatzAlgorithms"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "SatzAlgorithms",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Numerics", package: "swift-numerics"),
      ]
    ),
    .testTarget(
      name: "SatzAlgorithmsTests",
      dependencies: ["SatzAlgorithms"]
    ),
  ]
)
