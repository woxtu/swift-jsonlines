// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "swift-jsonlines",
  products: [
    .library(name: "JSONLines", targets: ["JSONLines"])
  ],
  targets: [
    .target(name: "JSONLines"),
    .testTarget(name: "JSONLinesTests", dependencies: ["JSONLines"]),
  ]
)
