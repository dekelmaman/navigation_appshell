# Offsite POC: Modular Navigation Architecture

A greenfield iOS POC proving that **independent feature packages can navigate to
each other's screens - including passing input and receiving results - without
ever depending on one another, and without composing each other's TCA
reducers.**

Two feature packages (`ContactsPackage`, `NotesPackage`) are built with TCA and
know nothing about each other. A tiny infrastructure package (`NavigationCore`)
defines an abstract navigation contract. The app target (`POCApp`) is the
composition root: it is the ONLY place that knows which package implements which
destination.

## Dependency direction

```
                 ┌─────────────────────────────┐
                 │           POCApp             │  ← composition root (app target)
                 │  (imports ALL three below)   │
                 └──────────────┬──────────────┘
          ┌────────────────────┼────────────────────┐
          ▼                    ▼                     ▼
 ┌────────────────┐   ┌────────────────┐   ┌────────────────┐
 │ ContactsPackage│   │  NotesPackage  │   │ NavigationCore │
 │  (TCA feature) │   │  (TCA feature) │   │ (infra: contract)
 └───────┬────────┘   └───────┬────────┘   └────────▲───────┘
         │                    │                     │
         └────────────────────┴─────────────────────┘
             both depend ONLY on NavigationCore
      (ContactsPackage and NotesPackage NEVER reference each other)
```

- `NavigationCore` depends on nothing feature-related (only TCA/Dependencies).
- `ContactsPackage` -> `NavigationCore` (never -> `NotesPackage`).
- `NotesPackage` -> `NavigationCore` (never -> `ContactsPackage`).
- `POCApp` -> all three.

## Why feature packages never import each other

Cross-feature coupling is the thing this POC exists to eliminate. If Notes
imported Contacts to open Contact Details, every feature would eventually depend
on every other feature - the classic mobile monolith. Instead:

- A feature that wants to navigate emits an **abstract request** against the
  `NavigationClient` capability: `navigation.open(destination: .contactDetails(contactID:), presentation: .push)`.
- `AppDestination` (in `NavigationCore`) describes destinations using only
  **primitive input** (e.g. a `contactID: String`). It holds no feature types.
- Because the request references no Contacts type, `NotesPackage` can request
  Contact Details while importing only `NavigationCore`. See
  `NotesPackage/Sources/NoteDetailsFeature/NoteDetailsFeature.swift` -
  `relatedContactTapped` opens `.contactDetails` with zero Contacts imports.

## Why TCA does not own app-level navigation

TCA is excellent for feature-local state/logic, but using it for *cross-feature*
navigation forces reducer composition: the caller must embed the destination's
`State`/`Action` and `Scope` its reducer in - which reintroduces the exact
package coupling we are removing.

So in this POC:

- Features use TCA **internally** (state, actions, effects, dependencies).
- App-level navigation state (the root stack + sheet + fullScreenCover) lives in
  a plain `@Observable` **`AppNavigator`** owned by the app shell
  (`POCApp/AppNavigator.swift`).
- No feature reducer contains another feature's state, action case, or `Scope`.
  Verify: `grep -rn "Scope(" Packages/*/Sources` returns nothing.

## Where `AppDestination` lives, and why

`AppDestination` lives in **`NavigationCore`** (infrastructure), not in any
feature package. That placement is what lets every feature *name* a destination
without importing the package that *implements* it. If it lived in
`ContactsPackage`, then `NotesPackage` would have to import `ContactsPackage`
just to reference `.contactDetails` - defeating the whole design.

## How the app shell maps contracts to implementations

`POCApp/AppShellComposition.swift` is the **single** file in the repo that
imports both `Contacts*` and `Notes*` modules. It does two things:

1. **Registry** (`makeRegistry`) - maps each `AppDestination` to a concrete
   feature view factory (`.contactsList -> makeContactsListView()`,
   `.contactDetails -> makeContactDetailsView(contactID:onDone:)`, etc).
2. **Live client** (`makeLiveNavigationClient`) - builds the `NavigationClient`
   whose `open` delegates to `AppNavigator`, and for `.contactDetails` bridges
   the destination's plain SwiftUI `onDone` callback back into the async result
   returned to the caller.

`NavigationRegistry` itself (`POCApp/NavigationRegistry.swift`) is pure infra:
it imports only `NavigationCore` + SwiftUI and renders a visible
"Unsupported destination" placeholder for anything unregistered (never crashes).

## Returning a result to the caller without reducer scoping

`ContactDetailsFeature` exposes a `delegate(.contactSelected(Contact))` action.
Its **factory** `makeContactDetailsView(contactID:onDone:)` bridges that delegate
to a plain SwiftUI callback. The app shell's registry hands that callback to
`AppNavigator.deliver(_:for:)`, which resumes the `await navigation.open(...)`
continuation. The caller thus observes a `NavigationResult.contactSelected` -
with **no reducer of the caller ever scoping ContactDetails**.

## How a hypothetical THIRD feature would open Contact Details

Say a future `TasksPackage` wants to open Contact Details. It would:

1. Depend only on `NavigationCore` (add `.package(path: "../NavigationCore")`).
2. Call `navigation.open(destination: .contactDetails(contactID: someID), presentation: .push)`.

That's it. No dependency on `ContactsPackage`, no import of any Contacts type, no
reducer composition. The app shell already knows how to build `.contactDetails`,
so it just works. If a brand-new destination were needed, you'd add one case to
`AppDestination` (infra) and one line to the registry (shell) - the requesting
feature still never imports the implementing package.

## Project layout

```
Offsite_POC_DUB/
├── project.yml                 # XcodeGen spec (do not hand-edit the .xcodeproj)
├── POCApp.xcodeproj            # generated by `xcodegen generate`
├── POCApp/                     # app target = composition root (L0)
│   ├── POCAppApp.swift         # @main; injects live NavigationClient
│   ├── AppNavigator.swift      # @Observable owner of ALL nav state
│   ├── NavigationRegistry.swift# infra: destination -> view, safe fallback
│   ├── AppShellComposition.swift # ONLY file importing both feature families
│   ├── RootView.swift          # root NavigationStack + sheet + fullScreenCover
│   └── HomeView.swift          # root content + sheet/cover demo buttons
└── Packages/
    ├── NavigationCore/         # AppDestination, PresentationStyle,
    │                           #   NavigationResult, NavigationClient
    ├── ContactsPackage/        # ContactsListFeature, ContactDetailsFeature,
    │                           #   ContactsModels
    └── NotesPackage/           # NotesListFeature, NoteDetailsFeature,
                                #   NotesModels
```

## Verify it yourself

Run each feature/infra package in isolation (proves criterion 16):

```sh
cd Packages/NavigationCore   && swift build && swift test && cd -
cd Packages/ContactsPackage  && swift build && swift test && cd -
cd Packages/NotesPackage     && swift build && swift test && cd -
```

Generate and build the app:

```sh
xcodegen generate
xcodebuild -project POCApp.xcodeproj -scheme POCApp \
  -destination 'generic/platform=iOS Simulator' build
```

Isolation greps (all must return no import matches):

```sh
# Contacts must not import Notes, and vice-versa:
grep -rEn "import (Notes|NoteDetails|NotesList|NotesModels)"   Packages/ContactsPackage
grep -rEn "import (Contacts|ContactDetails|ContactsList|ContactsModels)" Packages/NotesPackage

# No reducer composition anywhere in feature packages:
grep -rn "Scope(" Packages/*/Sources

# Exactly ONE file imports both feature families (AppShellComposition.swift):
for f in $(grep -rlE "import (ContactsListFeature|ContactDetailsFeature|ContactsModels)" --include="*.swift" .); do
  grep -qE "import (NotesListFeature|NoteDetailsFeature|NotesModels)" "$f" && echo "$f"
done
```
# navigation_appshell
