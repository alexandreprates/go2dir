# Changelog

## 2.5.1 - 2026-11-10

### Fixed

- Treat completion candidates as literal data, preventing command execution from saved aliases and preserving spaces, quotes, wildcards, and punctuation.
- Preserve numeric aliases, backslashes, and pipes in directory mappings, including paths ending in a pipe.
- Coordinate concurrent writers and preserve existing mappings when reading, filtering, or replacing the data file fails.
- Preserve the last migration record without a newline, avoid stale temporary data, and handle empty mapping files correctly.
- Resolve directories independently of CDPATH, support leading-hyphen aliases with `--`, and reject line breaks before storing mappings.
- Import directories from a symbolic-link working directory, preserve trailing spaces, and report partial batch failures.
- Preserve version lookup after navigation and tolerate absent optional arguments with nounset enabled.
- Generate shell loaders that preserve a literal HOME expression.
- Fail test runs when selected suites are missing, unreadable, fail to load, or exit prematurely.

### Changed

- Standardize all first-party suites on teSHt, with isolated homes and installer fixtures built from the current working tree.
- Expand Bash and zsh regression coverage and run CI in unprivileged containers with read-only source mounts.
- Clarify CLI messages, usage examples, and test documentation.
- Add Serena project configuration and codebase navigation memories.
