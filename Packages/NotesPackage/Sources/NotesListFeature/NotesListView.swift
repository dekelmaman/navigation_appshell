import AppContracts
import ComposableArchitecture
import NotesModels
import SwiftUI

public struct NotesListView: View {
  let store: StoreOf<NotesListFeature>

  public init(store: StoreOf<NotesListFeature>) {
    self.store = store
  }

  public var body: some View {
    List(store.notes) { note in
      Button {
        store.send(.noteTapped(note.id))
      } label: {
        VStack(alignment: .leading, spacing: 4) {
          Text(note.title)
          Text(note.text)
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
      }
      .buttonStyle(.plain)
    }
    .navigationTitle("Notes")
  }
}

/// Factory: the app shell builds the notes list, injecting the vanilla
/// `Navigating` implementation into the store for its entire lifetime.
@MainActor
public func makeNotesListView(navigation: any Navigating) -> some View {
  NotesListView(
    store: Store(initialState: NotesListFeature.State()) {
      NotesListFeature()
    } withDependencies: {
      $0.navigation = navigation
    }
  )
}

#Preview {
  NavigationStack {
    makeNotesListView(navigation: PreviewNavigation())
  }
}

/// A no-op `Navigating` used only for the preview above.
private struct PreviewNavigation: Navigating {
  func open(_ destination: AppDestination, presentation: PresentationStyle) async -> NavigationResult {
    .dismissed
  }
}
