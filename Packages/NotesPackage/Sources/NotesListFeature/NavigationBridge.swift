import AppContracts
import ComposableArchitecture

/// Per-package TCA bridge that adapts the vanilla `Navigating` protocol into a
/// `@Dependency`. Independent copy of the bridge pattern - internal to
/// `NotesListFeature`, keeping the shared `AppContracts` protocol TCA-free.
enum NavigationDependencyKey: DependencyKey {
  static var liveValue: any Navigating { NoopNavigation() }
  static var testValue: any Navigating { NoopNavigation() }
}

extension DependencyValues {
  var navigation: any Navigating {
    get { self[NavigationDependencyKey.self] }
    set { self[NavigationDependencyKey.self] = newValue }
  }
}

/// A neutral default installed until the app shell overrides `navigation` at
/// store creation.
private struct NoopNavigation: Navigating {
  func open(_ destination: AppDestination, presentation: PresentationStyle) async -> NavigationResult {
    .dismissed
  }
}
