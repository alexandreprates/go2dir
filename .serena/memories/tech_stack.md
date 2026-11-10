# Tech Stack

- Shell project, not Go; no compilation/package manager/build step.
- Bash 3-compatible runtime plus zsh 5.8+ support.
- GitHub Actions matrix: `bash:latest`, `bash:4`, `bash:3`; `zshusers/zsh:5.9`, `5.8.1`, `5.8`. Containers use the host UID/GID and a read-only repository mount.
- teSHt is an unchanged pinned submodule in `tests/tesht`. All first-party suites are `.tsh`; the Bash runner owns every assertion and final failure status, including zsh cases that launch actual zsh subprocesses.
- `tests/run.sh [bash|zsh|all]` isolates HOME, packages current worktree runtime/version/completion, and supplies a curl fixture via PATH. zsh modes require both Bash and the target zsh executable. `tests/support/tesht-compat.sh` only fixes command argument capture, without duplicating framework assertions.
- `tests/support/tesht-runner.sh` loads the unchanged teSHt script with `builtin source`, guards its suite loading, and registers logs centrally. It uses native teSHt failure reporting, not a second assertion framework. Infrastructure cases live in `tests/runner.tsh`.
- Tests require standard shell utilities and tar; no apk or live downloads are needed. Runtime regressions independently exercise aliases, filesystem errors, concurrent writers, migration, completion, options and version fallback.
- Production installer needs curl/tar and standard Unix utilities. It downloads alpha=master, beta=dev, otherwise latest release metadata/archive. Source/completion/version install into `$HOME/.go2dir`; mappings stay in `$HOME/.local/share/go2dir`.
- Installer migration is self-contained and does not source the archive's runtime. It supports older downloaded releases and shares the runtime lock path/protocol.
- Loader blocks are added only to existing rc files and detected by marker. Generated loaders retain literal `$HOME` for expansion when the shell loads them.
- Version lookup prefers installed version.txt, then source-adjacent version.txt, then unknown. Source directory is captured when sourced using Bash source metadata or zsh defining-file metadata.
- Bash completion performs literal prefix matching and explicit quoting; zsh uses literal arrays/compadd. Installed completion loading still requires Bash complete or available zsh compinit, with fpath prepended.
- Writer locks are mkdir-based with bounded retries and EXIT/signal cleanup. An uncatchable termination can leave an empty lock directory; manual recovery requires confirming no active writer first.
- No dedicated repository formatter/linter config. ShellCheck warning/error checks and actionlint can supplement tests.
