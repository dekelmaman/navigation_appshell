// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "NotesPackage",
  platforms: [.iOS(.v17), .macOS(.v13)],
  products: [
    .library(name: "NotesListFeature", targets: ["NotesListFeature"]),
    .library(name: "NoteDetailsFeature", targets: ["NoteDetailsFeature"]),
  ],
  dependencies: [
    .package(path: "../AppContracts"),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.20.0"
    ),
  ],
  targets: [
    .target(name: "NotesModels"),
    .target(
      name: "NotesListFeature",
      dependencies: [
        "NotesModels",
        "AppContracts",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "NoteDetailsFeature",
      dependencies: [
        "NotesModels",
        "AppContracts",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "NotesListFeatureTests",
      dependencies: [
        "NotesListFeature",
        "AppContracts",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "NoteDetailsFeatureTests",
      dependencies: [
        "NoteDetailsFeature",
        "AppContracts",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
  ]
)
