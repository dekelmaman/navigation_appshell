import ComposableArchitecture
import ContactsModels

@Reducer
public struct ContactDetailsFeature {
  @ObservableState
  public struct State: Equatable {
    public var contact: Contact

    public init(contactID: String) {
      self.contact = Contact.find(id: contactID)
    }
  }

  public enum Action {
    /// The user tapped the "Select Contact" button. The reducer merely emits a
    /// delegate; it does NOT know who opened it or what happens next. This keeps
    /// the destination caller-agnostic.
    case selectButtonTapped
    case delegate(Delegate)

    @CasePathable
    public enum Delegate {
      case contactSelected(Contact)
    }
  }

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .selectButtonTapped:
        return .send(.delegate(.contactSelected(state.contact)))
      case .delegate:
        return .none
      }
    }
  }
}
