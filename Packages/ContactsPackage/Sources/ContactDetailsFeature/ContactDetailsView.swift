import ComposableArchitecture
import ContactsModels
import SwiftUI

public struct ContactDetailsView: View {
  let store: StoreOf<ContactDetailsFeature>

  public init(store: StoreOf<ContactDetailsFeature>) {
    self.store = store
  }

  public var body: some View {
    Form {
      Section("Contact") {
        LabeledContent("Name", value: store.contact.name)
        LabeledContent("ID", value: store.contact.id)
      }
      Section {
        Button("Select Contact") {
          store.send(.selectButtonTapped)
        }
      }
    }
    .navigationTitle("Contact Details")
  }
}

/// Factory: builds a Contact Details view for a primitive `contactID` and hands
/// the result back through a plain SwiftUI callback (`onDone`). No reducer
/// scoping is used to surface the result - the callback bridges the feature's
/// `delegate` action to the caller.
public func makeContactDetailsView(
  contactID: String,
  onDone: @escaping @Sendable (Contact) -> Void
) -> some View {
  ContactDetailsView(
    store: Store(initialState: ContactDetailsFeature.State(contactID: contactID)) {
      ContactDetailsFeature()
      Reduce { _, action in
        if case let .delegate(.contactSelected(contact)) = action {
          onDone(contact)
        }
        return .none
      }
    }
  )
}

#Preview {
  NavigationStack {
    makeContactDetailsView(contactID: "c-1") { _ in }
  }
}
