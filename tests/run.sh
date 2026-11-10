#!/usr/bin/env bash

set -eu

case ${1:-bash} in
  bash) TEST_SUITES=(./tests/go2dir.tsh ./tests/install.tsh ./tests/regressions.tsh ./tests/runner.tsh) ;;
  zsh) TEST_SUITES=(./tests/zsh.tsh) ;;
  all) TEST_SUITES=(./tests/go2dir.tsh ./tests/install.tsh ./tests/regressions.tsh ./tests/runner.tsh ./tests/zsh.tsh) ;;
  *) printf 'Usage: %s [bash|zsh|all]\n' "$0" >&2; exit 2 ;;
esac
if [ "$#" -gt 1 ]; then
  printf 'Usage: %s [bash|zsh|all]\n' "$0" >&2
  exit 2
fi
if [ "${1:-bash}" != bash ] && ! command -v zsh > /dev/null 2>&1; then
  printf 'The zsh test suite requires zsh to be installed.\n' >&2
  exit 1
fi

TEST_REPO=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/go2dir-tests.XXXXXX")
function cleanup() {
  if [ -f "$TEST_ROOT/tesht-logs" ]; then
    while IFS= read -r log_file; do
      rm -f -- "$log_file"
    done < "$TEST_ROOT/tesht-logs"
  fi
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

mkdir -p "$TEST_ROOT/home" "$TEST_ROOT/package/go2dir"
cp "$TEST_REPO/go2dir.sh" "$TEST_REPO/version.txt" "$TEST_ROOT/package/go2dir/"
cp -R "$TEST_REPO/completion" "$TEST_ROOT/package/go2dir/"
tar -czf "$TEST_ROOT/source.tar.gz" -C "$TEST_ROOT/package" go2dir

export GO2DIR_TEST_ROOT="$TEST_ROOT"
export GO2DIR_TEST_REPO="$TEST_REPO"
export GO2DIR_TEST_ARCHIVE="$TEST_ROOT/source.tar.gz"
export PATH="$TEST_REPO/tests/support/bin:$PATH"

cd "$TEST_REPO"
env HOME="$TEST_ROOT/home" bash ./tests/support/tesht-runner.sh "${TEST_SUITES[@]}"
