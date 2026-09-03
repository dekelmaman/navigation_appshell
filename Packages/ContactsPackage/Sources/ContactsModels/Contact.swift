/// A fake contact model backed by a static in-memory list for the POC.
public struct Contact: Identifiable, Equatable, Sendable {
  public let id: String
  public let name: String

  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}

extension Contact {
  /// The in-memory contact catalog. Feature code looks contacts up by id here
  /// instead of talking to a real repository.
  public static let all: [Contact] = [
    Contact(id: "c-1", name: "Ada Lovelace"),
    Contact(id: "c-2", name: "Alan Turing"),
    Contact(id: "c-3", name: "Grace Hopper"),
    Contact(id: "c-4", name: "Katherine Johnson"),
  ]

  /// Looks up a contact by id, falling back to a placeholder so details views
  /// can render even for an unknown id.
  public static func find(id: String) -> Contact {
    all.first { $0.id == id } ?? Contact(id: id, name: "Unknown Contact")
  }
}
