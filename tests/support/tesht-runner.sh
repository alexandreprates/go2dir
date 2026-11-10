#!/usr/bin/env bash

# Guard suite loading while retaining the pinned teSHt assertions and reporting.
if [ "$#" -eq 0 ]; then
  printf 'At least one test suite is required.\n' >&2
  exit 2
fi
for suite in "$@"; do
  if [ ! -f "$suite" ] || [ ! -r "$suite" ]; then
    printf 'Test suite is missing or unreadable: %s\n' "$suite" >&2
    exit 1
  fi
done

GO2DIR_ACTIVE_SUITE=''
trap 'if [ -n "$GO2DIR_ACTIVE_SUITE" ]; then
  printf "Test suite did not finish: %s\n" "$GO2DIR_ACTIVE_SUITE" >&2
  exit 1
fi' EXIT

function source() {
  if [ "$#" -eq 0 ] || [ "$1" != "${TESTFILE-}" ]; then
    builtin source "$@"
    return $?
  fi

  local suite_status
  if ! printf '%s\n' "$STDOUT" "$STDERR" "$FAILLOG" >> "$GO2DIR_TEST_ROOT/tesht-logs"; then
    __fail "Could not register test logs for $1"
    return 1
  fi
  GO2DIR_ACTIVE_SUITE="$1"
  builtin source "$@"
  suite_status=$?
  GO2DIR_ACTIVE_SUITE=''
  if [ "$suite_status" -ne 0 ]; then
    __fail "Could not load test suite $1 (exit $suite_status)"
  fi
  return "$suite_status"
}

# The original runner's source calls resolve to the guard above.
# shellcheck source=tests/tesht/tesht.sh
builtin source "$GO2DIR_TEST_REPO/tests/tesht/tesht.sh" "$@"
