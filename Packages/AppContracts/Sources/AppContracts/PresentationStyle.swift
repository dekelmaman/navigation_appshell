/// How a destination should be presented on screen.
///
/// The same `AppDestination` can be presented via any of these mechanisms;
/// the requesting feature picks the style, and the app shell owns the actual
/// SwiftUI machinery that realizes it.
public enum PresentationStyle: Hashable, Sendable {
  case push
  case sheet
  case fullScreenCover
}
