// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "ContactsPackage",
  platforms: [.iOS(.v17), .macOS(.v13)],
  products: [
    .library(name: "Contacts", targets: ["Contacts"]),
    .library(name: "ContactsContracts", targets: ["ContactsContracts"]),
    .library(name: "ContactsData", targets: ["ContactsData"]),
  ],
  dependencies: [
    .package(path: "../AppContracts"),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.20.0"
    ),
  ],
  targets: [
    // MARK: External vanilla contract
    .target(name: "ContactsContracts"),

    // MARK: Internal models
    .target(name: "ContactsModels"),

    // MARK: Vanilla data provider
    .target(
      name: "ContactsData",
      dependencies: [
        "ContactsContracts",
        "ContactsModels",
      ]
    ),

    // MARK: TCA features
    .target(
      name: "ContactsListFeature",
      dependencies: [
        "ContactsModels",
        "AppContracts",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "ContactDetailsFeature",
      dependencies: [
        "ContactsModels",
        "AppContracts",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),

    // MARK: TCA-free facade
    .target(
      name: "Contacts",
      dependencies: [
        "ContactsContracts",
        "ContactsData",
        "ContactsModels",
        "ContactsListFeature",
        "ContactDetailsFeature",
        "AppContracts",
      ]
    ),

    // MARK: Tests
    .testTarget(
      name: "ContactsDataTests",
      dependencies: ["ContactsData"]
    ),
    .testTarget(
      name: "ContactsListFeatureTests",
      dependencies: [
        "ContactsListFeature",
        "AppContracts",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "ContactDetailsFeatureTests",
      dependencies: [
        "ContactDetailsFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
  ]
)
