// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "AppContracts",
  platforms: [.iOS(.v17), .macOS(.v13)],
  products: [
    .library(name: "AppContracts", targets: ["AppContracts"])
  ],
  targets: [
    .target(name: "AppContracts"),
    .testTarget(
      name: "AppContractsTests",
      dependencies: ["AppContracts"]
    ),
  ]
)
