import AppContracts
import Contacts
import ContactsContracts
import NoteDetailsFeature
import NotesListFeature
import SwiftUI

// swiftformat:disable all
// -----------------------------------------------------------------------------
// AppShellComposition is the COMPOSITION ROOT's wiring layer and the ONLY file
// in the entire repo that imports BOTH Contacts and Notes* modules. It is the
// single place that knows which packages exist - but it no longer knows HOW each
// destination maps to a view: each module vends its own `resolver`, and the shell
// just `add`s them. Onboarding a new module = one more `registry.add(...)` line.
//
// It provides:
//   1. `makeRegistry` - collects each module's route resolver (additive; no
//      central switch that grows with every module).
//   2. `makeLiveNavigation` - the live `any Navigating` whose `open` delegates
//      to `AppNavigator` and bridges the Contact Details callback result back to
//      the awaiting caller (no reducer scoping involved).
//   3. `makeDataRegistry` - builds the `ContactsDataRegistry` from the Contacts
//      facade's live provider.
// -----------------------------------------------------------------------------

enum AppShellComposition {
  /// Assembles the registry by asking each module to register its own routes.
  /// This is a FIXED list of `add` calls - one per module - not a switch that
  /// grows with the module count.
  @MainActor
  static func makeRegistry(navigator: AppNavigator, navigation: any Navigating) -> NavigationRegistry {
    var registry = NavigationRegistry()

    // Contacts self-registers its own destinations. The shell only supplies the
    // navigation capability and a result sink; it never switches over Contacts'
    // cases. The result sink delivers the selection back to whoever awaited
    // `open` - WITHOUT scoping the ContactDetails reducer into any caller.
    registry.add(
      Contacts.resolver(navigation: navigation) { contactID, summary in
        // The delegate fires on the store's main-actor reducer run, so it is
        // safe to assume main-actor isolation here to deliver the result.
        MainActor.assumeIsolated {
          navigator.deliver(
            .contactSelected(contactID: summary.id),
            for: .contactDetails(contactID: contactID)
          )
        }
      }
    )

    // Notes has not been given a facade yet (deferred), so the shell hosts its
    // resolver as a stopgap. Migrating Notes to `Notes.resolver(...)` later would
    // delete this closure and leave a single `registry.add(Notes.resolver(...))`.
    registry.add(notesResolver(navigation: navigation))

    return registry
  }

  /// Stopgap resolver for the not-yet-faceted Notes module.
  @MainActor
  private static func notesResolver(navigation: any Navigating) -> RouteResolver {
    { destination in
      switch destination {
      case .notesList:
        return AnyView(makeNotesListView(navigation: navigation))
      case let .noteDetails(noteID):
        return AnyView(makeNoteDetailsView(noteID: noteID, navigation: navigation))
      default:
        return nil
      }
    }
  }

  /// Builds the LIVE navigation. Features call `open`; this delegates to the
  /// shared `AppNavigator`, and the async return value carries any result.
  @MainActor
  static func makeLiveNavigation(navigator: AppNavigator) -> any Navigating {
    ShellNavigation(navigator: navigator)
  }

  /// Builds the app's contacts Data registry from the facade's live provider.
  static func makeDataRegistry() -> ContactsDataRegistry {
    ContactsDataRegistry(provider: Contacts.Data.live())
  }
}
// swiftformat:enable all
