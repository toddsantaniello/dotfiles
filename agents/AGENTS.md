## global agent instructions
* Never use the em dash "—". Use plain dash "-" instead
* When writing commit messages, NEVER auto-add your agent name as co-author
* Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
* When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
* For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
* When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible. This makes sure you find the real problem so your fix will actually solve it.
* When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection. If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
* Apply that same high standard to engineering excellence: lint, test failures, and test flakiness. If you see one, even if it is not caused by what you are working on right now, still get it fixed.
* Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.
* No broken code. Never commit or PR code that doesn't compile
* Before adding complexity for a speculative or vanishingly unlikely race or security edge case, explain the concrete failure mode, likelihood, and complexity cost to the user and get their buy-in. Do not silently expand scope for theoretical robustness.
* Write for a human reader, in complete sentences with subjects, verbs and connecting words. This applies to plans, step lists, bullets and status updates too. Keep replies concise by cutting what the reader doesn't need, such as repetition, inventories and rejected options, never by dropping grammar or by omitting reasoning, risks or assumptions the reader needs to judge the work.

## generated output

Never write generated or bulky output (test results, `.xcresult` bundles, build products, logs, downloads) inside a checkout, not even in a git-ignored folder: dev tools such as Tailwind scan the working tree and ignore only the repo's own `.gitignore`. Use the session scratchpad, or `~/.agents/scratch/<project>/` when it must outlive the session.
