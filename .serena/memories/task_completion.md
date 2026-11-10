# Task Completion

- Use `./tests/run.sh` for Bash runtime/installer/completion changes, not the bare tesht glob. The wrapper packages the current worktree, mocks curl, isolates HOME, and cleans fixtures/logs.
- Run `./tests/run.sh zsh` for shared-runtime and completion changes, or `./tests/run.sh all` to include every suite.
- Keep all first-party cases in `.tsh` files with native teSHt assertions. Preserve command arguments through the capture adapter, use literal comparisons for arbitrary names, and confirm intentional assertion/child-process failures produce a nonzero final teSHt exit status when changing test infrastructure.
- Storage/path changes require terminal-pipe and symlink-cwd round trips in addition to failure-injection, literal-alias, EOF migration and concurrent-writer regressions. Preserve data and propagate failures; check locks/temporaries and caller traps.
- Completion changes require inert metacharacters, spaces/quotes/backslashes, glob characters and word-break prefixes (: = @). Candidate arrays alone do not prove correct insertion; use interactive Tab validation when changing quoting.
- Compatibility-sensitive changes require Bash 3/4/latest and zsh 5.8/5.8.1/5.9 checks, ideally unprivileged with read-only mounted source. See `mem:suggested_commands`.
- The local fixture tests installation logic without testing live download/release metadata behavior. Report these limits accurately.
- Verify source-relative version lookup after navigation and optional arguments under nounset for shared runtime changes.
- Test infrastructure changes require negative controls for missing/unreadable/disappearing suites, nonzero load returns followed by passing suites, assertion failures and premature exits. Use the guarded project runner, not the bare pinned script, to evaluate final status.
- No formatter/linter is configured; avoid unrelated formatting churn. Optional ShellCheck/actionlint supplement behavior tests.
- Finish with `git diff --check` and `git status --short`. Preserve the tesht submodule and existing local/untracked .serena directory.
- Keep review findings/implementation history in Basic Memory; Serena stores stable navigation/implementation invariants.
