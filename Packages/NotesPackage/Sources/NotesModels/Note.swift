/// A fake note model backed by a static in-memory list for the POC.
///
/// `relatedContactID` is a raw contact id string - NotesPackage knows nothing
/// about the Contacts feature types; it only carries the primitive id that the
/// navigation contract needs.
public struct Note: Identifiable, Equatable, Sendable {
  public let id: String
  public let title: String
  public let text: String
  public let relatedContactID: String

  public init(id: String, title: String, text: String, relatedContactID: String) {
    self.id = id
    self.title = title
    self.text = text
    self.relatedContactID = relatedContactID
  }
}

extension Note {
  public static let all: [Note] = [
    Note(
      id: "n-1",
      title: "Kickoff meeting",
      text: "Discussed the analytical engine roadmap.",
      relatedContactID: "c-1"
    ),
    Note(
      id: "n-2",
      title: "Code review",
      text: "Reviewed the decidability proof draft.",
      relatedContactID: "c-2"
    ),
    Note(
      id: "n-3",
      title: "Compiler design",
      text: "Notes on the first compiler prototype.",
      relatedContactID: "c-3"
    ),
  ]

  public static func find(id: String) -> Note {
    all.first { $0.id == id }
      ?? Note(id: id, title: "Unknown Note", text: "", relatedContactID: "")
  }
}
