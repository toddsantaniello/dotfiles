# iOS Architecture: SwiftUI + MV (Model-View)

A default template for structuring native iOS apps around the MV
(Model-View) pattern: SwiftUI views bind directly to `@Observable` Model
objects, with no ViewModel layer in between. SwiftData is one way a Model
can hold its state — not a requirement of the pattern. This file should
work equally well for an app backed by SwiftData, a plain REST client, or
in-memory state.

See also: `ai-collaboration.md` for how to work with an AI agent on any
codebase, regardless of platform.

This file covers architecture and tooling conventions that hold across
projects. Per-project specifics — bundle ID, deployment target, scheme
names, and a file structure with purpose annotations — belong in that
project's own CLAUDE.md, not here.

## Philosophy

- **The Model is the state — there's no ViewModel to keep in sync with it.**
  An `@Observable` Model object owns state and business logic; the view
  reads and calls it directly. Don't introduce a ViewModel whose only job
  is forwarding to a Model underneath it.
- **Don't build a layer you don't need yet.** A single Model object,
  reasonably scoped to a screen or a feature, is the starting point. Split
  it or add a Repository only once a concrete need shows up (see "When to
  Split Further" below), not as a starting posture.
- **Follow the platform's current idiom, not last year's training data.**
  SwiftUI's recommended shape changes yearly (ObservableObject → Observable,
  NavigationView → NavigationStack, manual Combine → Swift concurrency).
  When in doubt, check the current-generation source (WWDC session for the
  active OS version, current Apple documentation) rather than assuming the
  pattern that shows up most often in general training data.
- **One direction of truth.** State flows down from a single owner; events
  flow up. A view never holds its own mutable copy of state its Model
  already owns.
- **Trust boundaries, not vibes.** Data crossing in from the network is
  validated defensively and fails closed per unit of work. Once it's in the
  Model's state, the view can assume it's well-formed.

## Default Shape (Most Screens)

```
View (SwiftUI)
  ↓ binds directly to
@Observable Model — owns state, business logic, and whatever persistence
                     it uses (SwiftData, a network client, UserDefaults,
                     in-memory — the pattern doesn't care which)
```

```swift
@Observable
@MainActor
final class ItemListModel {
    var items: [Item] = []
    var isLoading = false

    func load() async {
        isLoading = true
        defer { isLoading = false }
        items = await api.fetchItems()
    }
}

struct ItemListView: View {
    @State private var model = ItemListModel()

    var body: some View {
        List(model.items) { item in
            ItemRow(item: item)
        }
        .task { await model.load() }
    }
}
```

There is no separate ViewModel type here — `ItemListModel` is not a
formality standing between the view and "the real logic," it *is* the
logic. Inject it with `@State` (owned by this view) or `@Environment`
(shared across a subtree).

**If you're using SwiftData specifically:** `@Query` is a property wrapper
that only works directly inside a `View`, not inside a Model class. Two
valid shapes, pick based on whether the query result needs mixing with
other model state:

- Simple list, nothing else to compute: use `@Query` directly in the view,
  skip the Model object entirely for that screen.
- Query results need to combine with other state/logic the Model owns:
  fetch inside the Model via `modelContext.fetch()`, not `@Query`.

## When to Split Further

Split a screen's single Model into more than one collaborator, or
introduce a dedicated persistence/data-access type, once one of these is
actually true — not preemptively:

- The Model needs data from more than one source for the same entity
  (e.g. a remote API *and* local persistence, where something needs to
  decide which to trust and when to sync).
- The same fetch/orchestration logic (e.g. "check freshness, fetch if
  stale") is needed by more than one screen — worth centralizing once
  duplicated, not before.
- A single Model class is accumulating unrelated responsibilities for one
  screen (e.g. both list state and an unrelated settings toggle) — split
  along those lines, not along a generic "layer" boundary.

Until one of these is true, one Model object per screen or cohesive
feature, with no intermediate wire-format/domain-format split — a decoded
network response can be mapped straight into the state your Model exposes.

## Concurrency

- Target current Swift concurrency (structured `async/await`, no completion
  handlers for new code).
- Mark `@Observable` Model classes `@MainActor` — this is what keeps
  UI-facing state safe without manual dispatch.
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
- NEVER introduce a ViewModel type whose only job is forwarding to a Model
  underneath it.
- NEVER use `@Query` inside a Model class — it only works directly inside
  a `View`. Use `modelContext.fetch()` in a Model instead.
- NEVER split a Model into more layers before the triggers in "When to
  Split Further" are actually met.
- ALWAYS mark `@Observable` Model classes `@MainActor`.
- ALWAYS prefer MCP tools over raw shell commands for build, test, and
  simulator operations when they're available (see Build & Test above).

## Not Covered Here

- Testing conventions (unit tests for Model logic, SwiftUI snapshot/UI
  testing).
- Multi-platform extensions (watchOS/tvOS companion targets) — worth a
  separate document once exercised on a real multi-target app.
- Per-project specifics (bundle ID, deployment target, scheme names, file
  structure with purpose annotations) — those belong in that project's own
  CLAUDE.md.
