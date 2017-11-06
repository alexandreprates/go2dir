#!/usr/bin/env bash

# Autocomple for bash
function _go2_completion() {
  function __location_list() {
    cat $FILENAME | cut -d '|' -f 1
  }

  COMPREPLY=();
  local word="${COMP_WORDS[COMP_CWORD]}";
  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=($(compgen -W "$(__location_list)" -- "$word"));
  else
    COMPREPLY=
  fi
  return 0
}

function _load_zsh_completion() {
  echo Load zsh completion
}

# Set autocomplete
complete -o bashdefault -F _go2_completion go2
