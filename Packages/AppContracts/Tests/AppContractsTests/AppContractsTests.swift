import Testing

@testable import AppContracts

@Suite struct AppDestinationTests {
  @Test func destinationsCarryInput() {
    let destination = AppDestination.contactDetails(contactID: "c-1")
    #expect(destination == .contactDetails(contactID: "c-1"))
    #expect(destination != .contactDetails(contactID: "c-2"))
  }

  @Test func destinationIsHashable() {
    let set: Set<AppDestination> = [.contactsList, .contactsList, .notesList]
    #expect(set.count == 2)
  }
}

/// A hand-written `Navigating` test double. Records every `open` call and
/// returns a configurable result. TCA-free - proves the contract stands on its
/// own as a plain protocol.
private actor RecordingNavigation: Navigating {
  private(set) var calls: [(AppDestination, PresentationStyle)] = []
  private let result: NavigationResult

  init(result: NavigationResult = .dismissed) {
    self.result = result
  }

  func open(_ destination: AppDestination, presentation: PresentationStyle) async -> NavigationResult {
    calls.append((destination, presentation))
    return result
  }
}

@Suite struct NavigatingTests {
  @Test func doubleReturnsConfiguredResultAndRecords() async {
    let navigation = RecordingNavigation(result: .contactSelected(contactID: "picked"))

    let result = await navigation.open(.contactDetails(contactID: "c-9"), presentation: .sheet)

    let calls = await navigation.calls
    #expect(result == .contactSelected(contactID: "picked"))
    #expect(calls.count == 1)
    #expect(calls.first?.0 == .contactDetails(contactID: "c-9"))
    #expect(calls.first?.1 == .sheet)
  }

  @Test func defaultDoubleReturnsDismissed() async {
    let navigation: any Navigating = RecordingNavigation()
    let result = await navigation.open(.contactsList, presentation: .push)
    #expect(result == .dismissed)
  }
}
