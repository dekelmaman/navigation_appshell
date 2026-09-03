import AppContracts
import ComposableArchitecture
import NotesModels

@Reducer
public struct NotesListFeature {
  @ObservableState
  public struct State: Equatable {
    public var notes: IdentifiedArrayOf<Note>

    public init(notes: IdentifiedArrayOf<Note> = IdentifiedArray(uniqueElements: Note.all)) {
      self.notes = notes
    }
  }

  public enum Action {
    case noteTapped(Note.ID)
  }

  @Dependency(\.navigation) var navigation

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .noteTapped(id):
        let navigation = self.navigation
        return .run { _ in
          _ = await navigation.open(.noteDetails(noteID: id), presentation: .push)
        }
      }
    }
  }
}
