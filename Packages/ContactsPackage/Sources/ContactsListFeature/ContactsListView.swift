import AppContracts
import ComposableArchitecture
import ContactsModels
import SwiftUI

public struct ContactsListView: View {
  let store: StoreOf<ContactsListFeature>

  public init(store: StoreOf<ContactsListFeature>) {
    self.store = store
  }

  public var body: some View {
    List(store.contacts) { contact in
      Button {
        store.send(.contactTapped(contact.id))
      } label: {
        HStack {
          Text(contact.name)
          Spacer()
          Image(systemName: "chevron.right")
            .foregroundStyle(.secondary)
            .font(.footnote)
        }
      }
      .buttonStyle(.plain)
    }
    .navigationTitle("Contacts")
  }
}

/// Factory: the app shell builds the view from primitive input, wiring up its
/// own store. Callers never construct `ContactsListFeature.State` directly.
///
/// The vanilla `Navigating` implementation is injected into the store for its
/// entire lifetime via the native `Store(initialState:reducer:withDependencies:)`
/// initializer, resolved through this package's internal `NavigationBridge`.
@MainActor
public func makeContactsListView(navigation: any Navigating) -> some View {
  ContactsListView(
    store: Store(initialState: ContactsListFeature.State()) {
      ContactsListFeature()
    } withDependencies: {
      $0.navigation = navigation
    }
  )
}

#Preview {
  NavigationStack {
    makeContactsListView(navigation: PreviewNavigation())
  }
}

/// A no-op `Navigating` used only for the preview above.
private struct PreviewNavigation: Navigating {
  func open(_ destination: AppDestination, presentation: PresentationStyle) async -> NavigationResult {
    .dismissed
  }
}
