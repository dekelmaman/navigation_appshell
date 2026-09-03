/// The outcome a caller may observe after opening a destination.
///
/// This is the minimal demo of returning information from a presented
/// destination back to the caller WITHOUT composing the destination's reducer
/// into the caller. A caller `await`s `NavigationClient.open` and inspects the
/// result; the app shell bridges a plain SwiftUI callback into this value.
public enum NavigationResult: Hashable, Sendable {
  /// The destination finished without producing a value (dismissed/cancelled).
  case dismissed
  /// A contact-selection destination returned the chosen contact's id.
  case contactSelected(contactID: String)
}
