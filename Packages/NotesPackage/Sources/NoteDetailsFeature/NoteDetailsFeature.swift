import AppContracts
import ComposableArchitecture
import NotesModels

@Reducer
public struct NoteDetailsFeature {
  @ObservableState
  public struct State: Equatable {
    public var note: Note

    public init(noteID: String) {
      self.note = Note.find(id: noteID)
    }
  }

  public enum Action {
    case relatedContactTapped
  }

  @Dependency(\.navigation) var navigation

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .relatedContactTapped:
        // CROSS-FEATURE navigation. We open Contact Details using ONLY the
        // AppContracts contract and the primitive contact id carried on the
        // note. NotesPackage never imports ContactsPackage.
        let contactID = state.note.relatedContactID
        let navigation = self.navigation
        return .run { _ in
          _ = await navigation.open(.contactDetails(contactID: contactID), presentation: .push)
        }
      }
    }
  }
}
