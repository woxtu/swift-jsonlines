// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "swift-ndjson",
  products: [
    .library(name: "NDJSON", targets: ["NDJSON"]),
  ],
  targets: [
    .target(name: "NDJSON"),
    .testTarget(name: "NDJSONTests", dependencies: ["NDJSON"]),
  ]
)
