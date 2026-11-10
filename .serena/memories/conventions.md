# Conventions

- Preserve Bash 3 and zsh 5.8+ support. No Bash 4-only arrays/mapfile or recent completion flags.
- Existing runtime uses one public `go2` function with nested `__*` helpers. Keep globals project-specific and use local variables; avoid special zsh variables such as `LINES`, `status`, or `path`.
- Use `printf '%s\n'` for names and paths, not `echo`; default zsh echo interprets escapes. Quote all record values.
- Alias identity is literal text, including numeric-looking names and backslashes. Removal passes the name through an environment variable and forces textual awk comparison with a nonnumeric prefix. Do not reintroduce awk `-v` escape decoding or numeric comparisons.
- All mutations, including duplicate checks and migration, must acquire the same `$LOCATIONS2GO.lock`. Atomic rename alone cannot prevent lost updates.
- Runtime `__with_locations_lock` and installer `with_locations_lock` run in subshells to preserve caller traps. Their local `GO2DIR_TEMP` is dynamically scoped into writer helpers, which assign a checked exclusive temporary; EXIT cleanup removes it and releases the lock.
- Preserve the original database if reading, filtering, writing, or renaming fails. Emit success only after successful replacement. Never reuse the old fixed `locations.txt.tmp`.
- Mapping path readers use `IFS= read -r` on the full record and split only the first pipe; `IFS='|' read NAME LOCATION` can drop terminal pipes in Bash. Readers preserve whitespace/backslashes and final records without LF. Reject CR/LF in aliases/paths before serialization. Directory resolution uses a sentinel so command substitution cannot hide trailing newlines before validation.
- Resolve paths with CDPATH cleared, checked `builtin cd --`, and literal output. Default aliases replace spaces in the basename with hyphens.
- Batch enumeration uses `find -H` with NUL-delimited output: follow the starting directory symlink, preserve logical paths, and do not follow symlinked children. Explicit batch names preserve spaces and partial failures return nonzero.
- `getopts` state is local/reset. Existing add/remove positional semantics remain guarded `$2`/`$3`; only post-option navigation shifts OPTIND. zsh and Bash expose different in-loop OPTIND values.
- Guard optional positional expansions for nounset. Completion candidates are data, never shell input; Bash quoting depends on the typed quote/word-break context and callback fragment.
- Execute teSHt through `tests/run.sh` and its guarded `tests/support/tesht-runner.sh`; the pinned runner alone ignores suite source failures. Suite readability is checked up front, source failures mark native BROKEN state, and active-suite early exits fail the process. Only selected-suite source calls are intercepted.
- All first-party tests must be `.tsh` suites using native teSHt assertions/reporting. Fixture helpers may capture commands; do not introduce standalone assertion frameworks/counters.
- Source `tests/support/tesht-compat.sh` in each suite to preserve quoted arguments. For literal equality, use `test [ "$expected" = "$actual" ]` followed by `assert_success`; the pinned `assert_equal` interprets its RHS as a pattern. Assert stdout/stderr before another captured command overwrites those files.
- User messages/artifacts in repository are English. Communicate with the user in Brazilian Portuguese. New commits must follow Conventional Commits.
