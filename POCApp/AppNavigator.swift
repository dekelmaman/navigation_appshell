import AppContracts
import Observation
import SwiftUI

/// Owns ALL app-level navigation state. This is the object the app shell uses
/// to satisfy `NavigationClient.open`. Features never see it - they only see the
/// `NavigationClient` contract.
///
/// State is split into three independent contexts, each with its own push path:
///  - the root NavigationStack,
///  - a sheet presentation (its own NavigationStack),
///  - a fullScreenCover presentation (its own NavigationStack).
///
/// Splitting the push paths per context is the empirically-validated shape for
/// Neo's risk #10: SwiftUI modal `NavigationStack`s each own their own path, so
/// a single shared object can drive them all as long as each modal binds to its
/// own sub-path (rather than everyone sharing one path).
@MainActor
@Observable
final class AppNavigator {
  /// The root-level tabs. Each tab hosts one feature's entry point in its own
  /// `NavigationStack`. The shell owns this - features never know they live in a
  /// tab, they only ever request destinations through the `NavigationClient`.
  enum Tab: Hashable {
    case contacts
    case notes
  }

  /// Which tab is currently shown.
  var selectedTab: Tab = .contacts

  /// Push destinations on the Contacts tab's stack.
  var contactsPath: [AppDestination] = []

  /// Push destinations on the Notes tab's stack.
  var notesPath: [AppDestination] = []

  /// The sheet context: the destination that opened it plus its own push path.
  var sheet: ModalContext?

  /// The fullScreenCover context.
  var fullScreenCover: ModalContext?

  /// A pending result continuation keyed by the destination that must fulfill
  /// it. Lets `open` return a value once a destination reports "done".
  private var pendingResults: [AppDestination: CheckedContinuation<NavigationResult, Never>] = [:]

  /// One modal presentation: its root destination and its internal push path.
  @Observable
  final class ModalContext: Identifiable {
    let id = UUID()
    let root: AppDestination
    var path: [AppDestination] = []

    init(root: AppDestination) {
      self.root = root
    }
  }

  // MARK: - Opening

  /// Realizes a navigation request. Returns immediately for pushes/modals whose
  /// result the caller doesn't await, or suspends until a result is delivered
  /// via `deliver(_:for:)` for destinations that produce one.
  func open(
    _ destination: AppDestination,
    presentation: PresentationStyle
  ) async -> NavigationResult {
    switch presentation {
    case .push:
      pushOntoActiveContext(destination)
    case .sheet:
      sheet = ModalContext(root: destination)
    case .fullScreenCover:
      fullScreenCover = ModalContext(root: destination)
    }

    // Only contact-details destinations can return a selection result; for
    // everything else we resolve immediately so callers never hang.
    guard case .contactDetails = destination else {
      return .dismissed
    }
    return await withCheckedContinuation { continuation in
      pendingResults[destination] = continuation
    }
  }

  /// Pushes onto whichever context is frontmost (cover > sheet > active tab).
  /// When no modal is up, the push lands on the currently selected tab's stack,
  /// so e.g. tapping a related contact inside the Notes tab keeps the user in
  /// that tab.
  private func pushOntoActiveContext(_ destination: AppDestination) {
    if let fullScreenCover {
      fullScreenCover.path.append(destination)
    } else if let sheet {
      sheet.path.append(destination)
    } else {
      switch selectedTab {
      case .contacts:
        contactsPath.append(destination)
      case .notes:
        notesPath.append(destination)
      }
    }
  }

  // MARK: - Results

  /// Delivers a result for a previously opened destination, resuming any caller
  /// awaiting `open`. This is how a plain SwiftUI callback flows back to the
  /// caller WITHOUT reducer scoping.
  func deliver(_ result: NavigationResult, for destination: AppDestination) {
    guard let continuation = pendingResults.removeValue(forKey: destination) else { return }
    continuation.resume(returning: result)
  }
}

/// The live `Navigating` implementation. A thin, `Sendable` wrapper that holds
/// the `@MainActor` `AppNavigator` and forwards `open` to it.
///
/// This wrapper (rather than conforming `AppNavigator` to `Navigating` directly)
/// keeps the actor-isolation clean: `Navigating.open` is nonisolated `async`,
/// and hopping to the main actor happens inside the awaited `navigator.open`.
struct ShellNavigation: Navigating {
  let navigator: AppNavigator

  func open(_ destination: AppDestination, presentation: PresentationStyle) async -> NavigationResult {
    await navigator.open(destination, presentation: presentation)
  }
}
