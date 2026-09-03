import ComposableArchitecture
import ContactsModels
import Testing

@testable import ContactDetailsFeature

@MainActor
@Suite struct ContactDetailsFeatureTests {
  @Test func selectButtonEmitsContactSelectedDelegate() async {
    let store = TestStore(initialState: ContactDetailsFeature.State(contactID: "c-1")) {
      ContactDetailsFeature()
    }

    await store.send(.selectButtonTapped)
    await store.receive(\.delegate.contactSelected)
  }

  @Test func stateLooksUpContactByID() {
    let state = ContactDetailsFeature.State(contactID: "c-3")
    #expect(state.contact == Contact(id: "c-3", name: "Grace Hopper"))
  }
}
