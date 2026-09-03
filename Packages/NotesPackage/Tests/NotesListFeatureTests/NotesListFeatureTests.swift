import AppContracts
import ComposableArchitecture
import Testing

@testable import NotesListFeature

/// A vanilla `Navigating` test double recording every `open` call, injected as a
/// WHOLE conforming type through the store's `withDependencies:`.
private actor RecordingNavigation: Navigating {
  private(set) var calls: [(AppDestination, PresentationStyle)] = []

  func open(_ destination: AppDestination, presentation: PresentationStyle) async -> NavigationResult {
    calls.append((destination, presentation))
    return .dismissed
  }
}

@MainActor
@Suite struct NotesListFeatureTests {
  @Test func tappingNoteRequestsPushNavigationToNoteDetails() async {
    let navigation = RecordingNavigation()

    let store = TestStore(initialState: NotesListFeature.State()) {
      NotesListFeature()
    } withDependencies: {
      $0.navigation = navigation
    }

    await store.send(.noteTapped("n-1"))
    await store.finish()

    let calls = await navigation.calls
    #expect(calls.count == 1)
    #expect(calls.first?.0 == .noteDetails(noteID: "n-1"))
    #expect(calls.first?.1 == .push)
  }
}
