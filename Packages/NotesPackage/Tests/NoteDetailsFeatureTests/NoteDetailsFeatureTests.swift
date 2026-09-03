import AppContracts
import ComposableArchitecture
import Testing

@testable import NoteDetailsFeature

// NOTE: this test imports ZERO Contacts* modules yet still proves the note
// details feature can navigate to Contact Details - because navigation goes
// entirely through the AppContracts contract.

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
@Suite struct NoteDetailsFeatureTests {
  @Test func relatedContactTappedOpensContactDetailsViaContract() async {
    let navigation = RecordingNavigation()

    // n-1 is related to contact c-1 in the in-memory catalog.
    let store = TestStore(initialState: NoteDetailsFeature.State(noteID: "n-1")) {
      NoteDetailsFeature()
    } withDependencies: {
      $0.navigation = navigation
    }

    await store.send(.relatedContactTapped)
    await store.finish()

    let calls = await navigation.calls
    #expect(calls.count == 1)
    #expect(calls.first?.0 == .contactDetails(contactID: "c-1"))
    #expect(calls.first?.1 == .push)
  }
}
