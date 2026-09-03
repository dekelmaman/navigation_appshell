import AppContracts
import Contacts
import SwiftUI

@main
struct POCAppApp: App {
  /// The single shared navigator that owns all app-level navigation state.
  @State private var navigator = AppNavigator()

  /// The live navigation capability handed to every feature factory.
  private let navigation: any Navigating

  /// The app's contacts Data registry, resolving the external data contract.
  private let dataRegistry: ContactsDataRegistry

  init() {
    let navigator = AppNavigator()
    _navigator = State(initialValue: navigator)
    self.navigation = AppShellComposition.makeLiveNavigation(navigator: navigator)

    let dataRegistry = AppShellComposition.makeDataRegistry()
    self.dataRegistry = dataRegistry

    // Resolve the Contacts data provider at startup with a plain assignment -
    // no dependency-preparation, no ComposableArchitecture.
    Contacts.Data.current = dataRegistry.provider
  }

  var body: some Scene {
    WindowGroup {
      RootView(
        navigator: navigator,
        registry: AppShellComposition.makeRegistry(navigator: navigator, navigation: navigation),
        dataRegistry: dataRegistry
      )
    }
  }
}
