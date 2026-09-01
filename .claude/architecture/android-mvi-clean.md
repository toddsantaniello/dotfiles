# Android MVI + Clean Architecture — Working Principles

Derived from hands-on reps building a real feature (condish's wind/buoy
feature) and a structured `/architect` review pass. Philosophy: clarity
over cleverness, verify don't assume.

## Layering

- Flow: View (Composable) → ViewModel → UseCase → Repository → DataSource(s)
  (Remote / Local)
- Composables never touch network or local storage directly; no business
  logic in Composables
- One `StateFlow<UiState>` per screen. `UiState` is an immutable `data class`.
  A sealed `Event` interface represents user → ViewModel actions.
- A ViewModel exposes exactly one state stream (plus an effects `Channel` if
  needed for one-shot events like toasts/navigation) — nothing else public.
  Any Flow that only feeds into that one state stream should be `private`.
- DI via constructor injection, resolved by a container (Koin in this
  project). No service locators inside classes.

## Data flow / mapping patterns

- Three shapes, three jobs: DTO (raw wire format) → Entity (persistence
  shape, may add cache-only metadata like `lastUpdatedMillis`) → Domain
  (pure value object + business rules).
- It's fine to collapse DTO → Entity directly (skipping an intermediate
  Domain hop) when there's a single remote source and single local sink and
  nothing else consumes the intermediate Domain object. Know the tradeoff:
  the parsing/validation rule becomes expressed against the persistence
  shape instead of a stable intermediate shape — acceptable now, revisit if
  a second data source or write path appears.
- Validate defensively at the parsing boundary. Never let a raw, unchecked
  exception from a partially-malformed payload crash an entire batch —
  catch the specific expected failure (e.g. `NumberFormatException`), log,
  and discard just that record.
- Cache-aside pattern: Repository checks local freshness (a
  `lastUpdatedMillis`-style column, queried with `LIMIT 1`) before deciding
  whether to hit the network. Expose a `forceRefresh: Boolean` param for
  explicit user-initiated refresh (pull-to-refresh, station/filter change).
- Use cases are allowed to be thin pass-throughs even when they add zero
  logic yet. Their job is to keep ViewModels decoupled from Repository
  interfaces — a seam to grow into, not premature abstraction.

## MVI mechanics for reactive, parameterized state

Pattern for "the user can change which thing they're looking at" (a
station id, a filter, a selected entity) while keeping one clean reactive
pipeline:

- Hold the selector as its own `MutableStateFlow` in the ViewModel.
- Derive the dependent data flow via `flatMapLatest` keyed off the selector
  — this cancels the stale collection automatically when the selector
  changes, rather than merging old and new.
- `combine(loading, selector, derivedData) { ... }` into `UiState`. Include
  the selector's current value directly in `UiState` too if the UI needs to
  reflect the current selection (e.g. a dropdown highlighting the active
  choice) — same StateFlow read for two different reasons, not duplicated
  state.
- Route "user changed the selection" through the same private fetch
  function already used for init / pull-to-refresh, rather than building a
  parallel fetch path.
- Note: `flatMapLatest`/`mapLatest`/`transformLatest` still carry
  `@ExperimentalCoroutinesApi` in kotlinx.coroutines as of 1.9.0 despite
  being idiomatic and heavily used in production Android code. Scope
  `@OptIn(ExperimentalCoroutinesApi::class)` to the class/function using it.

## Compose UI rules

- Never let a Composable hold its own mutable copy of data the ViewModel
  already owns (e.g. a `remember`ed text field state seeded once, then
  manually mutated in a click handler). That's a fork of the source of
  truth — it'll silently diverge the moment anything else changes the
  underlying state. Prefer deriving display values fresh from `UiState` on
  every recomposition (e.g. the plain `value`/`onValueChange` `TextField`
  overload for read-only fields — no remembered object at all), or key
  `remember(upstreamValue) { ... }` so a change forces recreation.
- Formatting (dates, numbers, unit strings) belongs in the Composable — it's
  legitimately UI-layer work, and keeps ViewModels free of
  `Context`/resource dependencies for testability.
- Exception: when the Composable would have to make an *undocumented
  decision about what a value means* (e.g. what to render for a
  null/missing measurement), don't bury that decision in a string
  template. Pull it into a small, named, testable function (extension
  property/function on the domain model) so the "what do we show when data
  is missing" rule is explicit and reviewable.
- Indicating "selected" state in a list/menu isn't automatic — Material3's
  `DropdownMenuItem` has no `selected` parameter. Add a visual indicator
  (icon in a stable slot, present-but-empty for unselected rows to avoid
  layout shift) *and* accessibility semantics explicitly
  (`Modifier.semantics { selected = ... }` — not `Modifier.selectable`,
  which duplicates click handling `DropdownMenuItem` already provides).

## Dependency & API verification discipline

These are habits, demonstrated repeatedly in the session this doc came
from, not just described:

- Compile classpath and runtime classpath are different dependency graphs.
  A transitive `implementation` dependency can land on the runtime
  classpath (needed to run the app) without ever being exposed to your own
  module's compile classpath (needed for your code to reference it). Check
  with `./gradlew :module:dependencies --configuration <variant>CompileClasspath`
  before assuming a symbol will resolve — don't infer availability from
  what's sitting in the global Gradle cache or from a different
  configuration's dependency tree.
- Experimental-API annotations are version- and library-specific, and
  inconsistent over time: some genuinely stable, heavily-used operators
  (`flatMapLatest`) have carried `@ExperimentalCoroutinesApi` for years;
  other APIs that *used to* require an opt-in (`ExposedDropdownMenuBox`)
  had it removed in a later version (stable as of Material3 1.4.0). Check
  the actual resolved version's bytecode/release notes — general knowledge
  and old blog posts/StackOverflow answers reflect whatever version they
  were written against, not necessarily this project's.
- When unsure, inspect the actual resolved artifact (decompile a class,
  read a dependency tree) rather than asserting from training data or
  pattern-matching to "how this usually works." This generalizes past
  Android: verify a claim against the artifact you actually have, not the
  one you remember.

## Not yet covered (open for future reps)

- iOS/SwiftUI equivalent conventions — see `swiftui-mvvm-clean.md` once
  drafted from the condish-ios port.
- Testing conventions — unit tests for use cases/repositories/mappers,
  Compose UI tests — not yet exercised on this project.
- Multi-module structure at scale — not yet needed at condish's current
  size.
