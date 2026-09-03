import AppContracts
import ContactDetailsFeature
import ContactsData
import ContactsListFeature
import ContactsModels
import SwiftUI

@_exported import ContactsContracts

/// The public facade for the Contacts package. Consumers `import Contacts` and
/// reach everything through this namespace:
///
///   - `Contacts.View.list(navigation:)`
///   - `Contacts.View.details(contactID:onDone:)`
///   - `Contacts.Data.getAllItems()` / `.getItem(id:)` / `.live()`
///
/// The facade is TCA-FREE. It erases the two internal feature view types to
/// `AnyView` and maps the internal `Contact` model to the external
/// `ContactSummary` at this boundary. Because `ContactsContracts` is
/// `@_exported`, `import Contacts` also surfaces `ContactSummary` and
/// `ContactsDataProviding`.
public enum Contacts {
  public enum View {
    /// The contacts list, wired to the given navigation capability.
    @MainActor
    public static func list(navigation: any Navigating) -> AnyView {
      AnyView(makeContactsListView(navigation: navigation))
    }

    /// A contact details view for a primitive `contactID`. On selection, hands
    /// back a `ContactSummary` (mapped from the internal `Contact`).
    @MainActor
    public static func details(
      contactID: String,
      onDone: @escaping @Sendable (ContactSummary) -> Void
    ) -> AnyView {
      AnyView(
        makeContactDetailsView(contactID: contactID) { contact in
          onDone(ContactSummary(id: contact.id, name: contact.name))
        }
      )
    }
  }

  /// The Contacts module's self-registration: it claims its own destinations and
  /// returns `nil` for everything else. The app shell adds this to its registry
  /// with a single call - the shell never switches over Contacts' cases itself.
  ///
  /// - Parameter onContactSelected: invoked when the user selects a contact in
  ///   Contact Details, carrying the originating `contactID` and the selected
  ///   `ContactSummary`, so the shell can deliver the result to the caller.
  @MainActor
  public static func resolver(
    navigation: any Navigating,
    onContactSelected: @escaping @Sendable (_ contactID: String, _ summary: ContactSummary) -> Void
  ) -> @MainActor @Sendable (AppDestination) -> AnyView? {
    { destination in
      switch destination {
      case .contactsList:
        return View.list(navigation: navigation)
      case let .contactDetails(contactID):
        return View.details(contactID: contactID) { summary in
          onContactSelected(contactID, summary)
        }
      default:
        return nil
      }
    }
  }

  public enum Data {
    /// The resolved data provider. Defaults to the live provider; the app shell
    /// may replace it at startup with a plain assignment.
    ///
    /// `nonisolated(unsafe)`: this is set once at app startup before any read,
    /// matching the POC's single-assignment lifecycle.
    public nonisolated(unsafe) static var current: any ContactsDataProviding =
      LiveContactsDataProvider()

    public static func getAllItems() async -> [ContactSummary] {
      await current.getAllItems()
    }

    public static func getItem(id: String) async -> ContactSummary? {
      await current.getItem(id: id)
    }

    /// Builds a fresh live provider (e.g. for the app shell's data registry).
    public static func live() -> any ContactsDataProviding {
      LiveContactsDataProvider()
    }
  }
}
