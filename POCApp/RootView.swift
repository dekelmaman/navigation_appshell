import AppContracts
import SwiftUI

/// Owns the app's ROOT `TabView`, each tab's `NavigationStack`, and BOTH modal
/// presentations (`sheet` + `fullScreenCover`), driven entirely by `AppNavigator`
/// state and resolved through the injected `NavigationRegistry`. This satisfies
/// success criteria 7 & 8: the app shell - not any feature - owns navigation.
///
/// There is one tab per feature entry point (Contacts, Notes). Crucially, EVERY
/// tab's stack resolves the FULL `AppDestination` set through the same registry,
/// so any destination can be pushed onto any tab. That is what lets the Notes
/// tab push Contact List / Contact Details into its own stack without importing
/// - or even knowing about - the Contacts package.
struct RootView: View {
  @Bindable var navigator: AppNavigator
  let registry: NavigationRegistry
  let dataRegistry: ContactsDataRegistry

  var body: some View {
    TabView(selection: $navigator.selectedTab) {
      // MARK: Contacts tab
      NavigationStack(path: $navigator.contactsPath) {
        registry.view(for: .contactsList)
          .navigationDestination(for: AppDestination.self) { destination in
            registry.view(for: destination)
          }
          .toolbar { presentationDemoMenu }
      }
      .tabItem { Label("Contacts", systemImage: "person.2") }
      .tag(AppNavigator.Tab.contacts)

      // MARK: Notes tab
      NavigationStack(path: $navigator.notesPath) {
        registry.view(for: .notesList)
          .navigationDestination(for: AppDestination.self) { destination in
            registry.view(for: destination)
          }
          .toolbar { presentationDemoMenu }
      }
      .tabItem { Label("Notes", systemImage: "note.text") }
      .tag(AppNavigator.Tab.notes)
    }
    .sheet(item: $navigator.sheet) { context in
      ModalStackView(context: context, registry: registry)
    }
    .fullScreenCover(item: $navigator.fullScreenCover) { context in
      ModalStackView(context: context, registry: registry)
        .overlay(alignment: .topTrailing) {
          Button {
            navigator.fullScreenCover = nil
          } label: {
            Image(systemName: "xmark.circle.fill")
              .font(.title2)
              .padding()
          }
        }
    }
    .task {
      // Demonstrate that the shell resolves contact data through the external
      // `ContactsDataProviding` contract via the injected `ContactsDataRegistry`
      // - no feature internals, no TCA. Done in `.task` to avoid async-in-init.
      let contacts = await dataRegistry.provider.getAllItems()
      print("Resolved \(contacts.count) contacts via ContactsDataRegistry")
    }
  }

  /// Demonstrates that the SAME destinations can be opened via DIFFERENT
  /// presentation mechanisms (success criterion 14). Presentation style is never
  /// baked into the destination - the caller picks it here.
  @ToolbarContentBuilder
  private var presentationDemoMenu: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Menu {
        Button("Contacts List (sheet)") {
          Task { _ = await navigator.open(.contactsList, presentation: .sheet) }
        }
        Button("Notes List (fullScreenCover)") {
          Task { _ = await navigator.open(.notesList, presentation: .fullScreenCover) }
        }
      } label: {
        Image(systemName: "rectangle.stack.badge.plus")
      }
    }
  }
}

/// A modal presentation's own `NavigationStack`, bound to that context's private
/// push path. Each modal owns an independent stack - the empirically-validated
/// resolution to Neo's risk #10 (one shared navigator, per-context sub-paths).
private struct ModalStackView: View {
  @Bindable var context: AppNavigator.ModalContext
  let registry: NavigationRegistry

  var body: some View {
    NavigationStack(path: $context.path) {
      registry.view(for: context.root)
        .navigationDestination(for: AppDestination.self) { destination in
          registry.view(for: destination)
        }
    }
  }
}
