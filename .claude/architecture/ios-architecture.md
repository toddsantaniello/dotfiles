# iOS Architecture: SwiftUI + Observation

A default template for structuring native iOS apps (reference implementation:
SwiftUI + the Observation framework + SwiftData) so they stay easy to reason
about as they grow, and stay easy to build correctly alongside an AI pair
programmer.

See also: `ai-collaboration.md` for how to work with an AI agent on any
codebase, regardless of platform.

This file covers architecture and tooling conventions that hold across
projects. Per-project specifics — bundle ID, deployment target, scheme
names, and a file structure with purpose annotations — belong in that
project's own CLAUDE.md, not here.

## Philosophy

- **Don't build a layer you don't need yet.** A `@Model` class is already
  observable, already persisted, and already reactive via `@Query`. Adding
  a Repository/UseCase/DataSource stack on top of that by default is
  importing complexity that SwiftData already solved — introduce those
  layers only once a concrete need shows up (see "When to Add an
  `@Observable` Object" and "When to Add a Repository" below), not as a
  starting posture.
- **Follow the platform's current idiom, not last year's training data.**
  SwiftUI's recommended shape changes yearly (ObservableObject → Observable,
  NavigationView → NavigationStack, manual Combine → Swift concurrency).
  When in doubt, check the current-generation source (WWDC session for the
  active OS version, current Apple documentation) rather than assuming the
  pattern that shows up most often in general training data.
- **One direction of truth.** State flows down from a single owner; events
  flow up. A view never holds its own mutable copy of state something else
  already owns.
- **Trust boundaries, not vibes.** Data crossing in from the network is
  validated defensively and fails closed per unit of work. Once persisted
  as a `@Model`, the interior of the app can assume it's well-formed.

## Default Shape (Most Screens)

```
View (SwiftUI)
  ↓ @Query (reactive fetch) or @Bindable (form binding)
@Model (SwiftData) — persistence, domain meaning, and observability in one type
```

For a straightforward CRUD screen, the view queries the model directly and
mutates it through the environment's `modelContext`:

```swift
struct ItemListView: View {
    @Query(sort: \Item.name) private var items: [Item]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List(items) { item in
            ItemRow(item: item)
        }
    }
}
```

## When to Add an `@Observable` Object

Introduce a screen-level `@Observable` class only once the screen's logic
exceeds simple binding to a model — e.g. multi-step async orchestration,
state that isn't directly representable by a `@Query`, or logic shared
across more than one view. Signs you've crossed that line:

- The view needs to coordinate more than one async operation before
  rendering (e.g. a network fetch that populates SwiftData, with loading/
  error states the view itself shouldn't own).
- Derived state that isn't just a filtered/sorted `@Query` — computed from
  multiple sources, or requiring logic more complex than a predicate.
- The same orchestration logic is needed from more than one view.

When you do add one:

```swift
@Observable
@MainActor
final class ItemListModel {
    var isLoading = false
    var errorMessage: String?

    func refresh(context: ModelContext) async {
        isLoading = true
        defer { isLoading = false }
        // fetch, then write results into SwiftData via context
    }
}
```

One `@Observable` object owns its slice of state; nothing outside it (not a
child view, not a sibling) holds a second copy.

## When to Add a Repository

Add a Repository abstraction only when there's a real reason a view
shouldn't talk to SwiftData directly — most commonly, more than one data
source for the same entity (e.g. a remote API *and* local persistence,
where something needs to decide which one to trust and when to sync), or a
backend that's genuinely swappable. Signs you've crossed that line:

- A screen needs data that comes from a network call, not just what's
  already in the local store.
- More than one screen needs the same "check freshness, fetch if stale"
  logic — worth centralizing once duplicated, not before.

Until then, treat the `@Model` itself as the domain layer. Don't introduce
a separate intermediate type to sit between a decoded network response and
the `@Model` you persist it as — with a single local store, nothing else
consumes that intermediate shape long enough to justify carrying it
forward as its own type. Decode network responses straight onto (or
directly into) your `@Model` types.

## SwiftData Rules

- Use `@Bindable` for two-way form bindings to a model's properties.
- Use `@Query` in views for reactive fetches; use `modelContext.fetch()` in
  non-view code (e.g. inside an `@Observable` orchestration object).
- Relationship delete rules are explicit at the model level: `.cascade`,
  `.nullify`, or `.deny` — pick deliberately, don't leave the default.
- `#Predicate` has real limitations. When a filter can't be expressed in
  the predicate DSL, fetch and filter in memory rather than fighting the
  predicate — but note that as a known tradeoff, not a silent workaround.

## Concurrency

- Target current Swift concurrency (structured `async/await`, no completion
  handlers for new code).
- Mark `@Observable` orchestration classes `@MainActor` — this is what
  keeps UI-facing state safe without manual dispatch.
- Cross-actor value types are `Sendable`.
- Use `nonisolated` only when there's a measured performance need, not by
  default.

## Build & Test — Prefer MCP Tools

If XcodeBuildMCP (or an equivalent MCP-based build server) is available in
the session, prefer it over raw shell commands. It returns structured JSON;
shell commands return unstructured text that costs more tokens to parse and
makes error diagnosis less reliable.

- **Build:** `build_sim` / `build_device` — not `xcodebuild` via Bash.
- **Test:** `test_sim` / `test_device` — not `xcodebuild test` via Bash.
- **Simulators:** `list_sims`, `boot_sim`, `open_sim` — not `xcrun simctl`
  via Bash.
- **Debug:** `debug_attach_sim`, `debug_stack`, `debug_variables` — not a
  manually attached LLDB session.
- **Apple docs:** `DocumentationSearch` — not a general web search for
  Apple API questions.
- **Swift verification:** `ExecuteSnippet` — not `swift` via Bash.
- **Previews:** `RenderPreview` for headless SwiftUI preview verification.

A project's own CLAUDE.md should still spell out the concrete scheme name(s)
and simulator destination(s) to build against — those are per-project facts,
not something this shared file can supply.

## Rules

- NEVER modify `.pbxproj` files or `.xcodeproj`/`.xcworkspace` contents
  directly — create Swift files and add them to the Xcode project
  manually (or gate this with a PreToolUse hook).
- NEVER use `NavigationView` — always `NavigationStack` with type-safe
  `navigationDestination(for:)`.
- NEVER use `ObservableObject`, `@StateObject`, `@ObservedObject`, or
  `@Published` — always `@Observable` with `@State`.
- NEVER add the `@Observable` macro to a `@Model` class — it's already
  Observable.
- NEVER introduce a Repository or a screen-level `@Observable` object
  before the triggers in "When to Add an `@Observable` Object" or "When
  to Add a Repository" are actually met.
- ALWAYS use `@Bindable` for two-way form bindings to a model's properties.
- ALWAYS mark `@Observable` orchestration classes `@MainActor`.
- ALWAYS prefer MCP tools over raw shell commands for build, test, and
  simulator operations when they're available (see Build & Test above).

## Not Covered Here

- Testing conventions (unit tests for `@Observable` orchestration logic,
  SwiftUI snapshot/UI testing).
- Multi-platform extensions (watchOS/tvOS companion targets) — worth a
  separate document once exercised on a real multi-target app.
- Per-project specifics (bundle ID, deployment target, scheme names, file
  structure with purpose annotations) — those belong in that project's own
  CLAUDE.md.
