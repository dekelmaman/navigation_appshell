/// The generic navigation capability injected into every feature.
///
/// Features depend ONLY on this vanilla protocol to request navigation; they
/// never know which package implements a destination, nor how it is presented.
/// The live implementation is supplied by the app shell (the composition root).
///
/// This is a plain Swift protocol - it carries NO ComposableArchitecture
/// coupling. Each TCA feature package adapts it into a `@Dependency` locally
/// via its own internal bridge.
public protocol Navigating: Sendable {
  /// Opens `destination` using `presentation`, returning a result the caller
  /// may observe (e.g. a selected contact id) without any reducer composition.
  func open(_ destination: AppDestination, presentation: PresentationStyle) async -> NavigationResult
}
