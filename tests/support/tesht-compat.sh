# teSHt consumes RETURNCODE and COMMAND when this file is sourced.
# shellcheck disable=SC2034
# Keep the pinned teSHt runner and assertions, preserving command arguments.
# Its original test() expands $@ unquoted and splits spaces and metacharacters.
function test() {
  "$@" > "$STDOUT" 2> "$STDERR"
  RETURNCODE=$?
  printf -v COMMAND '%q ' "$@"
}
