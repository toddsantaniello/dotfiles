# Working With an AI Pair Programmer

Treat AI-generated claims about a codebase or a library the same way you'd
treat an unverified PR comment: plausible, worth taking seriously, and not
yet trusted.

- **Compile-time and run-time dependency graphs are different questions.**
  A library can be present at runtime (pulled in transitively by something
  else's dependency) without being exposed to your own module's compile
  classpath. Before trusting that a symbol will resolve, check the actual
  compile classpath for the module and variant you're building — don't
  infer availability from what merely exists somewhere in a dependency
  tree or a local cache.
- **API stability claims are version-specific, not universal.** Whether an
  API is experimental, deprecated, or stable can flip in either direction
  between library versions — a long-stable operator can still carry an
  experimental annotation for years, and a formerly-experimental API can
  ship stable. Check the actual resolved version (bytecode/binary,
  changelog, official docs for that version) rather than general
  knowledge, training data, or a search result that may predate the
  version in use.
- **When a claim is checkable, check it before stating it as fact.** A
  quick dependency-tree query or a decompiled/inspected artifact is cheap
  insurance against confidently propagating something that was true of a
  different version, a different platform, or a different assumption than
  the one actually in play.
- This discipline is bidirectional: it's how you should verify what an AI
  tool tells you, and it's the same rigor to hold your own claims to when
  reviewing an AI's generated code.
