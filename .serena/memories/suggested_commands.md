# Suggested Commands

Run from the repository root.

## Setup

- `git status --short`
- `git submodule status`
- Initialize missing tesht with `git submodule update --init --recursive`.
- Use Serena symbol tools for runtime; use pattern search or bounded reads for extensionless source files.

## Isolated tests

- All Bash suites, hermetic installer fixture and regressions: `./tests/run.sh`.
- zsh integration and regressions through teSHt: `./tests/run.sh zsh`.
- Every suite on a machine with both interpreters: `./tests/run.sh all`.
- Do not invoke `tests/*.tsh` directly against the real HOME; the wrapper provides isolation and download fixtures.
- Bash compatibility example:
  `docker run --rm --user "$(id -u):$(id -g)" -v "$PWD:/workspace:ro" -w /workspace bash:3 ./tests/run.sh`
- Repeat for `bash:4` and `bash:latest`. Specific previously validated versions: 3.2, 4.4, 5.2, 5.3.
- zsh example:
  `docker run --rm --user "$(id -u):$(id -g)" -v "$PWD:/workspace:ro" -w /workspace zshusers/zsh:5.9 ./tests/run.sh zsh`
- Repeat for 5.8.1 and 5.8.
- Running unprivileged exercises unreadable-database protection that privileged root may bypass.
- Direct completion checks must set COMP_LINE/COMP_POINT; Bash callbacks also receive the exact current replacement fragment. COMPREPLY contains intentionally shell-quoted strings.

## Static checks

- `bash -n go2dir.sh`; `bash -n install`; `bash -n completion/complete`; check each Bash test script individually too.
- `zsh -n go2dir.sh`; `zsh -n completion/compdef/_go2`. Test suites themselves are Bash/teSHt `.tsh` files; zsh snippets execute through the selected interpreter.
- `git diff --check`.
- Optional ShellCheck: `shellcheck --shell=bash --severity=warning go2dir.sh install completion/complete`.
- Optional actionlint: `actionlint .github/workflows/test.yml`.
