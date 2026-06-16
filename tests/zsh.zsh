#!/usr/bin/env zsh

set -e

function fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

function assert_eq() {
  local expected="$1"
  local actual="$2"
  [[ "$actual" == "$expected" ]] || fail "expected '$expected', got '$actual'"
}

function assert_contains() {
  local needle="$1"
  local haystack="$2"
  [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain '$needle', got '$haystack'"
}

TEST_HOME="$(mktemp -d)"
export HOME="$TEST_HOME"

mkdir -p "$HOME/.go2dir"
cp go2dir.sh version.txt "$HOME/.go2dir/"
cp -R completion "$HOME/.go2dir/completion"

autoload -Uz compinit
source "$HOME/.go2dir/go2dir.sh"

assert_eq "go2dir version 2.5.0" "$(go2 -v)"
assert_contains "usage: go2" "$(go2 -h)"

[[ "$fpath[1]" == "$HOME/.go2dir/completion/compdef" ]] || fail "zsh completion directory was not prepended to fpath"
whence -w _go2 > /dev/null || fail "_go2 completion function was not loaded"

TARGET="/tmp/go2dir zsh target"
mkdir -p "$TARGET"
STDOUT="$(mktemp)"

assert_eq "Mapping zsh-target to $TARGET" "$(go2 -a "$TARGET" zsh-target)"
assert_contains "zsh-target" "$(go2 -l)"

cd /
go2 zsh-target > "$STDOUT"
assert_eq "go to zsh-target at $TARGET" "$(< "$STDOUT")"
assert_eq "$TARGET" "$PWD"

assert_eq "zsh-target was successfully removed" "$(go2 -R zsh-target)"
