import AppContracts
import SwiftUI

/// A single module's contribution to routing: given a destination, return a
/// view for the destinations it owns, or `nil` for everything else.
///
/// This is the entire coupling surface between the shell and a feature module.
/// A module vends one of these (see e.g. `Contacts.resolver(...)`); it imports
/// only AppContracts + SwiftUI + its own views - never another feature.
typealias RouteResolver = @MainActor @Sendable (AppDestination) -> AnyView?

/// Resolves an `AppDestination` to a concrete SwiftUI view by asking each
/// registered module resolver in turn (first non-nil wins).
///
/// This type is pure infrastructure: it imports ONLY AppContracts + SwiftUI and
/// has zero knowledge of which package implements a destination. Crucially it is
/// ADDITIVE - the shell `add`s one resolver per module instead of maintaining a
/// central switch, so onboarding a new module is O(1) (one `add` call) rather
/// than an edit to a growing switch.
///
/// An unregistered/unsupported destination renders a visible placeholder rather
/// than crashing.
@MainActor
struct NavigationRegistry {
  private var resolvers: [RouteResolver] = []

  init() {}

  /// Registers one module's resolver. Order = precedence (first match wins).
  mutating func add(_ resolver: @escaping RouteResolver) {
    resolvers.append(resolver)
  }

  /// Always returns a view: the first module that claims the destination, or a
  /// placeholder if none do.
  @ViewBuilder
  func view(for destination: AppDestination) -> some View {
    if let view = resolve(destination) {
      view
    } else {
      UnsupportedDestinationView(destination: destination)
    }
  }

  private func resolve(_ destination: AppDestination) -> AnyView? {
    for resolver in resolvers {
      if let view = resolver(destination) {
        return view
      }
    }
    return nil
  }
}

/// The safe fallback shown when no implementation is registered for a
/// destination. Never crashes.
struct UnsupportedDestinationView: View {
  let destination: AppDestination

  var body: some View {
    ContentUnavailableView {
      Label("Unsupported destination", systemImage: "questionmark.diamond")
    } description: {
      Text(String(describing: destination))
    }
  }
}
