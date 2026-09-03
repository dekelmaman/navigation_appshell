import ContactsContracts
import ContactsModels

/// The live `ContactsDataProviding` implementation. Maps the internal in-memory
/// `Contact` catalog to primitive `ContactSummary` values.
///
/// NOTE: unlike `Contact.find(id:)` (which fabricates a placeholder for unknown
/// ids so a details view can always render), `getItem(id:)` returns `nil` for an
/// unknown id. This divergence is intentional: the external data contract must
/// not invent data that doesn't exist.
public struct LiveContactsDataProvider: ContactsDataProviding {
  public init() {}

  public func getAllItems() async -> [ContactSummary] {
    Contact.all.map { ContactSummary(id: $0.id, name: $0.name) }
  }

  public func getItem(id: String) async -> ContactSummary? {
    Contact.all
      .first { $0.id == id }
      .map { ContactSummary(id: $0.id, name: $0.name) }
  }
}
