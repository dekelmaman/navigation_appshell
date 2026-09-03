import AppContracts
import ComposableArchitecture

/// Per-package TCA bridge that adapts the vanilla `Navigating` protocol into a
/// `@Dependency`. The protocol itself (in `AppContracts`) carries NO TCA
/// coupling; this file is the only place that ties `Navigating` to TCA, and it
/// is internal to `ContactsListFeature`.
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
/// store creation. Records nothing and returns `.dismissed` so fire-and-forget
/// navigation effects never fail unrelated tests.
private struct NoopNavigation: Navigating {
  func open(_ destination: AppDestination, presentation: PresentationStyle) async -> NavigationResult {
    .dismissed
  }
}
