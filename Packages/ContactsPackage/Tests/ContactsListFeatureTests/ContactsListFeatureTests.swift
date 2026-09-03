import AppContracts
import ComposableArchitecture
import Testing

@testable import ContactsListFeature

/// A vanilla `Navigating` test double recording every `open` call. Injected as a
/// WHOLE conforming type through the store's `withDependencies:` - the vanilla
/// protocol replaces the old `@DependencyClient` mutable-endpoint form.
private actor RecordingNavigation: Navigating {
  private(set) var calls: [(AppDestination, PresentationStyle)] = []

  func open(_ destination: AppDestination, presentation: PresentationStyle) async -> NavigationResult {
    calls.append((destination, presentation))
    return .dismissed
  }
}

@MainActor
@Suite struct ContactsListFeatureTests {
  @Test func tappingContactRequestsPushNavigationToDetails() async {
    let navigation = RecordingNavigation()

    let store = TestStore(initialState: ContactsListFeature.State()) {
      ContactsListFeature()
    } withDependencies: {
      $0.navigation = navigation
    }

    await store.send(.contactTapped("c-2"))
    await store.finish()

    let calls = await navigation.calls
    #expect(calls.count == 1)
    #expect(calls.first?.0 == .contactDetails(contactID: "c-2"))
    #expect(calls.first?.1 == .push)
  }
}
