# Mobile Architecture: Clean Layering + MVI

A default template for structuring native mobile apps (reference
implementation: Kotlin/Jetpack Compose) so they stay easy to reason about as
they grow, and stay easy to build correctly alongside an AI pair programmer.

## Philosophy

- **Clarity over cleverness.** No abstraction earns its place until there
  are at least two concrete call sites that need it. A thin pass-through
  class is fine if it's holding a seam open for real, foreseeable growth —
  it's not fine as decoration.
- **One direction of truth.** State flows down from a single owner; events
  flow up. Nothing outside that owner — not a Composable, not a sibling
  screen — holds its own copy of state the owner already manages.
- **Trust boundaries, not vibes.** The edges of the app (network responses,
  disk reads, user input) are validated defensively and fail closed per
  unit of work. The interior, once past that boundary, can assume its data
  is well-formed.
- **Verify, don't assume** — about the codebase and about AI-generated
  suggestions alike.

## Layering

```
View (Composable)
  ↓ observes UiState, emits Events
ViewModel
  ↓ calls
UseCase
  ↓ calls
Repository
  ↓ composed of
DataSource(s) — Remote / Local
```

- Composables never touch network or local storage directly, and hold no
  business logic — they render `UiState` and emit `Event`s.
- A ViewModel exposes exactly one state stream (`StateFlow<UiState>`), plus
  an effects channel if one-shot events (toasts, navigation) are needed —
  nothing else public. Any Flow that only feeds that one stream is
  `private`.
- Repositories are the only thing that know a network call and a database
  both exist for a given piece of data; nothing above them does.
- DataSources are thin wrappers around exactly one external concern (one
  API, one table) — no branching logic, just I/O.
- Dependency injection is constructor-based throughout, resolved by a
  container (Koin in the reference implementation). No service locators
  inside classes.

## State Management (MVI-flavored UDF)

- `UiState` is an immutable `data class`. Every field is something the
  screen can render directly — no partial/ambiguous states expressed as
  combinations of nullable fields.
- User → ViewModel actions are a sealed `Event` interface, handled through
  a single `onEvent(event: Event)` entry point. This scales better than ad
  hoc public functions once a screen passes ~5-6 distinct actions.
- Use cases are allowed to be thin pass-throughs to a Repository even when
  they add no logic *yet*. Their job is decoupling ViewModels from
  Repository interfaces — a seam to grow into, not premature abstraction.

## Data Layer: DTO → Entity → Domain

Three shapes, three jobs:

| Shape | Owns | Knows about |
|---|---|---|
| DTO | Wire format, exactly as the source returns it | The remote API only |
| Entity | Persistence shape + cache-only metadata (e.g. `lastUpdatedMillis`) | The local store only |
| Domain | The business-meaningful value + validity rules | Nothing external |

- Collapsing DTO → Entity directly (skipping an intermediate Domain
  object) is a reasonable simplification when there's exactly one remote
  source and one local sink, and nothing else consumes the Domain shape.
  The tradeoff: parsing/validation logic now lives keyed to persistence
  shape rather than a stable intermediate one — fine for a single pipeline,
  worth revisiting the moment a second source or write path appears.
- Boundary parsing fails **closed, per-record** — a malformed row is
  caught, logged, and dropped; it never throws past the mapping function
  and takes down an entire batch.
- **Cache-aside as the default read strategy:** a Repository checks local
  freshness (a `lastUpdatedMillis`-style column, queried with `LIMIT 1`)
  before deciding whether to hit the network, and exposes a
  `forceRefresh: Boolean` for explicit user-initiated refresh.

## Reactive, Parameterized State

The pattern for "the user can change which thing they're looking at" (a
filter, a selected id, a mode) while keeping one clean reactive pipeline,
instead of re-fetching imperatively on every change:

```kotlin
private val selectedId = MutableStateFlow(defaultId)

@OptIn(ExperimentalCoroutinesApi::class)
private val itemsFlow = selectedId.flatMapLatest { id -> observeItems(id) }

val state = combine(loadingState, selectedId, itemsFlow) { isLoading, id, items ->
    UiState(isLoading, id, items)
}.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), UiState(isLoading = true))
```

- `flatMapLatest` keyed off the selector cancels the stale collection
  automatically when the selector changes, rather than merging old and new
  results.
- The selector StateFlow does double duty: it drives `flatMapLatest`, *and*
  it's a direct `combine` input so `UiState` can reflect the current
  selection (e.g. a dropdown highlighting the active choice). Same
  StateFlow, two reasons to read it — not duplicated state.
- Route "user changed the selection" through the same private fetch
  function already used for init/refresh, rather than building a parallel
  path.

## UI Layer Rules (Compose)

- **A Composable never holds its own mutable copy of state its ViewModel
  already owns.** A `remember`ed value seeded once and then manually
  mutated in a callback is a fork of the source of truth — it silently
  diverges the moment anything else changes the underlying state. Derive
  display values fresh from `UiState` on every recomposition, or key
  `remember(upstreamValue) { ... }` so a change forces recreation.
- Formatting (dates, numbers, unit strings) belongs in the Composable —
  that's legitimately UI-layer work, and it keeps ViewModels free of
  `Context`/resource dependencies for testability.
- The one exception: when rendering requires an *undocumented decision
  about what a value means* (what to show for missing/null data), that
  decision doesn't belong inside a string template. Pull it into a small,
  named, testable function so the rule is explicit and reviewable, not
  implicit in `.toString()` behavior.
- Indicating selection state in a list/menu is manual, not automatic — add
  a visual indicator in a stable layout slot (present-but-empty when
  unselected, to avoid shifting other rows) *and* explicit accessibility
  semantics for it, separate from whatever already handles the tap.

## Working With an AI Pair Programmer

Treat AI-generated claims about a codebase or a library the same way you'd
treat an unverified PR comment: plausible, worth taking seriously, and not
yet trusted.

- **Compile-time and run-time dependency graphs are different questions.**
  A library can be present at runtime (pulled in transitively by something
  else's `implementation` dependency) without being exposed to your own
  module's compile classpath. Before trusting that a symbol will resolve,
  check the actual compile classpath for the module and variant you're
  building — don't infer availability from what merely exists somewhere in
  a dependency tree or a local cache.
- **API stability claims are version-specific, not universal.** Whether an
  API is experimental, deprecated, or stable can flip in either direction
  between library versions — a long-stable operator can still carry an
  experimental annotation for years, and a formerly-experimental API can
  ship stable. Check the actual resolved version (bytecode, changelog,
  official docs for that version) rather than general knowledge, training
  data, or a search result that may predate the version in use.
- **When a claim is checkable, check it before stating it as fact.** A
  quick dependency-tree query or a decompiled class file is cheap
  insurance against confidently propagating something that was true of a
  different version, a different platform, or a different assumption than
  the one actually in play.
- This discipline is bidirectional: it's how you should verify what an AI
  tool tells you, and it's the same rigor to hold your own claims to when
  reviewing an AI's generated code.

## Roadmap / Deliberately Not Covered Here

- Platform-specific equivalents (SwiftUI/iOS conventions — DI without a
  Koin/Hilt-shaped container, MVVM vs. MVI norms in that community) are a
  separate document once exercised on a real port.
- Testing conventions (unit tests for use cases/repositories/mappers,
  Compose UI tests).
- Multi-module structure — appropriate once a single module starts
  straining, not before.
