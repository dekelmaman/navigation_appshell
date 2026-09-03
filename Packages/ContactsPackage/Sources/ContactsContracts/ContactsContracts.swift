/// The public, primitive view of a contact that crosses the package boundary.
///
/// This is the ONLY contact shape external consumers (the app shell, other
/// packages) ever see. The internal `Contact` model stays private to the
/// package; the facade maps `Contact -> ContactSummary` at the boundary.
public struct ContactSummary: Identifiable, Equatable, Sendable {
  public let id: String
  public let name: String

  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}

/// The EXTERNAL data contract for reading contacts. Vanilla Swift - no TCA, no
/// SwiftUI. The app shell resolves a concrete provider and hands it to whoever
/// needs contact data, without knowing the implementation.
public protocol ContactsDataProviding: Sendable {
  /// Returns every known contact as a primitive summary.
  func getAllItems() async -> [ContactSummary]
  /// Returns the summary for `id`, or `nil` if no such contact exists.
  func getItem(id: String) async -> ContactSummary?
}
