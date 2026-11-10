# go2dir
# by Alexandre Prates <ajfprates@gmail.com>
# 2.x - 08-25-2016

LOCATIONS2GO="$HOME/.local/share/go2dir/locations.txt"

# Resolve the source directory before navigation changes the working directory.
if [ -n "${ZSH_VERSION-}" ]; then
  # zsh prompt expansion provides the defining file, including when sourced.
  # shellcheck disable=SC2296
  GO2DIR_SOURCE_FILE="${(%):-%x}"
else
  GO2DIR_SOURCE_FILE="${BASH_SOURCE[0]}"
fi
GO2DIR_SOURCE_DIR=$(CDPATH='' builtin cd -- "$(dirname -- "$GO2DIR_SOURCE_FILE")" && builtin pwd)
unset GO2DIR_SOURCE_FILE

function go2() {
  function __echoerr() {
    printf "%s\n" "$*" >&2
  }

  function __current_version() {
    local VERSION_FILE="$HOME/.go2dir/version.txt"
    if [ ! -f "$VERSION_FILE" ]; then
      VERSION_FILE="$GO2DIR_SOURCE_DIR/version.txt"
    fi
    if [ -f "$VERSION_FILE" ]; then
      cat "$VERSION_FILE"
    else
      printf "%s\n" "unknown"
    fi
  }

  function __find_location() {
    local LINE='' NAME LOCATION
    while IFS= read -r LINE || [ -n "$LINE" ]; do
      [[ "$LINE" == *"|"* ]] || continue
      # Only the first pipe is a separator; the rest belong to the path.
      NAME="${LINE%%|*}"
      LOCATION="${LINE#*|}"
      if [ "$1" = "$NAME" ]; then
        printf "%s\n" "$LOCATION"
        return 0
      fi
    done < "$LOCATIONS2GO"
    return 1
  }

  function __not_mapped() {
    ! __find_location "$1" > /dev/null
  }

  function __alias_for_dir() {
    local DIRNAME
    DIRNAME=$(basename -- "$1") || return 1
    printf "%s\n" "${DIRNAME// /-}"
  }

  # Writers run in a subshell so cleanup cannot replace the caller's traps.
  function __with_locations_lock() (
    local LOCK_DIR="$LOCATIONS2GO.lock" ATTEMPTS=0 GO2DIR_TEMP=''
    until mkdir -- "$LOCK_DIR" 2>/dev/null; do
      if [ "$ATTEMPTS" -ge 100 ]; then
        __echoerr "Could not lock locations file: $LOCATIONS2GO"
        return 1
      fi
      sleep 0.1 || return 1
      ATTEMPTS=$((ATTEMPTS + 1))
    done
    trap 'if [ -n "$GO2DIR_TEMP" ]; then rm -f -- "$GO2DIR_TEMP"; fi; rmdir -- "$LOCK_DIR"' EXIT
    trap 'exit 1' HUP INT TERM
    "$@"
  )

  function __write_mapping() {
    if ! __not_mapped "$2"; then
      __echoerr "$2 is already mapped to $1"
      return 1
    fi

    GO2DIR_TEMP=$(mktemp "$LOCATIONS2GO.XXXXXX") || return 1
    # Normalize a final unterminated record before adding the next record.
    awk '1' "$LOCATIONS2GO" > "$GO2DIR_TEMP" || return 1
    printf "%s|%s\n" "$2" "$1" >> "$GO2DIR_TEMP" || return 1
    mv -f -- "$GO2DIR_TEMP" "$LOCATIONS2GO" || return 1
    printf "Mapping %s to %s\n" "$2" "$1"
  }

  function __add_dir() {
    local NAME DIR
    if [ -z "${1-}" ]; then
      __echoerr "You must specify the directory to add"
      return 1
    elif [[ "$1" == *$'\n'* || "$1" == *$'\r'* ]]; then
      __echoerr "Path cannot contain line breaks"
      return 1
    elif [ ! -d "$1" ]; then
      __echoerr "Directory does not exist"
      return 1
    fi

    # A sentinel preserves path-ending newlines until validation rejects them.
    DIR=$(__dir_pwd "$1" && printf '.') || return 1
    DIR=${DIR%.}
    DIR=${DIR%$'\n'}
    if [[ "$DIR" == *$'\n'* || "$DIR" == *$'\r'* ]]; then
      __echoerr "Path cannot contain line breaks"
      return 1
    fi

    if [ -z "${2-}" ]; then
      NAME=$(__alias_for_dir "$DIR") || return 1
    else
      NAME="$2"
    fi
    if [[ "$NAME" == *"|"* ]]; then
      __echoerr "Name cannot contain |"
      return 1
    elif [[ "$NAME" == *$'\n'* || "$NAME" == *$'\r'* ]]; then
      __echoerr "Name cannot contain line breaks"
      return 1
    fi

    __with_locations_lock __write_mapping "$DIR" "$NAME"
  }

  function __dir_pwd() (
    CDPATH=
    builtin cd -- "$1" || return 1
    builtin pwd
  )

  function __list_dirs() {
    local LINE='' NAME LOCATION SORTED_LOCATIONS
    SORTED_LOCATIONS=$(sort "$LOCATIONS2GO") || return 1
    printf "Current locations\n\n"
    if [ -n "$SORTED_LOCATIONS" ]; then
      while IFS= read -r LINE; do
        [[ "$LINE" == *"|"* ]] || continue
        NAME="${LINE%%|*}"
        LOCATION="${LINE#*|}"
        printf "%*s -> %s \n" 15 "$NAME" "$LOCATION"
      done <<EOF
$SORTED_LOCATIONS
EOF
    fi
    printf "\n"
  }

  function __recursive_add_dir() (
    local LINE ROOT LIST RESULT=0
    ROOT=$PWD
    LIST=$(mktemp "${TMPDIR:-/tmp}/go2dir-list.XXXXXX") || return 1
    trap 'rm -f -- "$LIST"' EXIT
    trap 'exit 1' HUP INT TERM
    find -H "$ROOT" -maxdepth 1 -type d -print0 > "$LIST" || return 1
    while IFS= read -r -d '' LINE; do
      __add_dir "$LINE" "$(basename -- "$ROOT")-$(basename -- "$LINE")" || RESULT=1
    done < "$LIST"
    return "$RESULT"
  )

  function __show_help() {
    printf "Usage: go2 [options] [PATH] [NAME]\n\nCommand-line options:\n\t-a PATH [NAME]: Add a directory to the list\n\t-r: Add the current directory and its immediate subdirectories to the list\n\t-l: List mapped directories\n\t-R NAME: Remove a mapped directory by name\n\t-v: Show the version\n\t-h: Show this help message\n\n"
  }

  function __remove_mapping() {
    if __not_mapped "$1"; then
      __echoerr "$1 is not mapped"
      __echoerr "Run 'go2 -l' to list all mapped directories"
      return 3
    fi

    GO2DIR_TEMP=$(mktemp "$LOCATIONS2GO.XXXXXX") || return 1
    GO2DIR_REMOVE_NAME="$1" awk -F '|' \
      '("x" $1) != ("x" ENVIRON["GO2DIR_REMOVE_NAME"])' \
      "$LOCATIONS2GO" > "$GO2DIR_TEMP" || return 1
    mv -f -- "$GO2DIR_TEMP" "$LOCATIONS2GO" || return 1
    printf "%s was successfully removed\n" "$1"
  }

  function __remove_location() {
    if [ -z "${1-}" ]; then
      __echoerr "You must specify the directory name to remove"
      __echoerr "Run 'go2 -h' for help"
      return 2
    fi
    __with_locations_lock __remove_mapping "$1"
  }

  mkdir -p -- "$(dirname -- "$LOCATIONS2GO")" || return 1
  if [ ! -e "$LOCATIONS2GO" ]; then
    touch -- "$LOCATIONS2GO" || return 1
  fi
  if [ ! -f "$LOCATIONS2GO" ]; then
    __echoerr "Locations file is not a regular file: $LOCATIONS2GO"
    return 1
  fi

  local OPTIND=1 opt=''
  while getopts ":alhrRv" opt; do
    case "$opt" in
      a)
        __add_dir "${2-}" "${3-}"
        return $?
        ;;
      l)
        __list_dirs
        return $?
        ;;
      h)
        __show_help
        return $?
        ;;
      r)
        __recursive_add_dir
        return $?
        ;;
      R)
        __remove_location "${2-}"
        return $?
        ;;
      v)
        printf "go2dir version %s\n" "$(__current_version)"
        return 0
        ;;
      \?)
        __echoerr "Invalid option: -${OPTARG-}"
        return 1
        ;;
    esac
  done
  shift "$((OPTIND - 1))"

  if [ -z "${1-}" ]; then
    __show_help
    return $?
  fi

  local LOCATION
  if ! LOCATION=$(__find_location "$1"); then
    __echoerr "Could not find a mapped directory named $1"
    return 1
  fi
  cd -- "$LOCATION" || return $?
  printf "Going to %s at %s\n" "$1" "$LOCATION"
}

# Load shell completion.
if [[ -a "$HOME/.go2dir/completion/complete" ]] && type complete > /dev/null 2>&1; then
  source "$HOME/.go2dir/completion/complete"
elif [[ -d "$HOME/.go2dir/completion/compdef" ]] && type compinit > /dev/null 2>&1; then
  fpath=("$HOME/.go2dir/completion/compdef" "${fpath[@]}")
  compinit
fi
