/// A platform-neutral description of a place the app can navigate to.
///
/// This enum is the entire cross-feature navigation contract. It lives in
/// `AppContracts` (infrastructure) and references NO feature types - a
/// destination is described only by primitive input (e.g. an id `String`).
///
/// Because it holds no feature types, any feature can *request* a destination
/// (e.g. `.contactDetails`) without importing the package that *implements* it.
public enum AppDestination: Hashable, Sendable {
  case contactsList
  case contactDetails(contactID: String)
  case notesList
  case noteDetails(noteID: String)
}
