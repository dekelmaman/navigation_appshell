import AppContracts
import ComposableArchitecture
import NotesModels
import SwiftUI

public struct NoteDetailsView: View {
  let store: StoreOf<NoteDetailsFeature>

  public init(store: StoreOf<NoteDetailsFeature>) {
    self.store = store
  }

  public var body: some View {
    Form {
      Section("Note") {
        LabeledContent("Title", value: store.note.title)
        Text(store.note.text)
      }
      Section {
        Button("Open Related Contact") {
          store.send(.relatedContactTapped)
        }
      }
    }
    .navigationTitle("Note Details")
  }
}

/// Factory: builds a Note Details view from a primitive `noteID`, injecting the
/// vanilla `Navigating` implementation into the store for its entire lifetime.
@MainActor
public func makeNoteDetailsView(noteID: String, navigation: any Navigating) -> some View {
  NoteDetailsView(
    store: Store(initialState: NoteDetailsFeature.State(noteID: noteID)) {
      NoteDetailsFeature()
    } withDependencies: {
      $0.navigation = navigation
    }
  )
}

#Preview {
  NavigationStack {
    makeNoteDetailsView(noteID: "n-1", navigation: PreviewNavigation())
  }
}

/// A no-op `Navigating` used only for the preview above.
private struct PreviewNavigation: Navigating {
  func open(_ destination: AppDestination, presentation: PresentationStyle) async -> NavigationResult {
    .dismissed
  }
}
