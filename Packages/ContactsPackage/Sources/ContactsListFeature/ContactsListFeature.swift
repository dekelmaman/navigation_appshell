import AppContracts
import ComposableArchitecture
import ContactsModels

@Reducer
public struct ContactsListFeature {
  @ObservableState
  public struct State: Equatable {
    public var contacts: IdentifiedArrayOf<Contact>

    public init(contacts: IdentifiedArrayOf<Contact> = IdentifiedArray(uniqueElements: Contact.all)) {
      self.contacts = contacts
    }
  }

  public enum Action {
    case contactTapped(Contact.ID)
  }

  @Dependency(\.navigation) var navigation

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .contactTapped(id):
        // Request navigation via the injected capability. The list feature does
        // NOT own Contact Details state, does NOT have a `contactDetails` action
        // case, and does NOT `Scope` Contact Details into itself.
        let navigation = self.navigation
        return .run { _ in
          _ = await navigation.open(.contactDetails(contactID: id), presentation: .push)
        }
      }
    }
  }
}
