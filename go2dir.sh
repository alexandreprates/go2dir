# GO 2 DIR
# by Alexandre Prates <ajfprates@gmail.com>
# 2.x - 08-25-2016

LOCATIONS2GO="$HOME/.local/share/go2dir/locations.txt"

function go2() {
  [ ! -d `dirname $LOCATIONS2GO` ] && mkdir -p `dirname $LOCATIONS2GO`
  [ ! -e $LOCATIONS2GO ] && touch $LOCATIONS2GO

  local CURRENTVERSION=$(cat $HOME/.go2dir/version.txt)

  function __echoerr() {
    echo $@ >&2
  }

  function __find_location() {
    local NAME LOCATION LINE
    cat $LOCATIONS2GO | while read LINE; do
      NAME=$(echo $LINE | cut -d '|' -f 1)
      LOCATION=$(echo $LINE | cut -d '|' -f 2)
      if [ "$1" = "$NAME" ]; then
        echo $LOCATION
        break
      fi
    done
  }

  function __not_mapped() {
    local LOCATION=$(__find_location $1)
    if [ -z "$LOCATION" ]; then
      return 0
    fi
    return 1
  }

  function __alias_for_dir() {
    local DIRNAME=$(echo $1 | sed 's/[ ]/\-/g')
    echo $(basename "$DIRNAME")
  }

  function __add_dir() {
    local NAME DIR

    if [ -z "$1" ]; then
      __echoerr "You must specify the dir to add"
      return 1
    else
      DIR=$(__dir_pwd $1)
    fi

    if [ ! -d "$1" ]; then
      __echoerr "Dir does not exist"
      return 1
    fi

    if [ ! $2 ]; then
      NAME=$(__alias_for_dir "$DIR")
    else
      NAME=$2
    fi

    if __not_mapped "$NAME" ; then
      echo "Mapping $NAME to $DIR"
      echo -e "$NAME|$DIR" >> $LOCATIONS2GO
    else
      __echoerr "$NAME is already mapped to $DIR"
      return 1
    fi
  }

  function __dir_pwd() {
    if [ ! -d $1 ]; then
      return 1
    else
      cd $1
      echo $(pwd)
    fi
  }

  function __list_dirs() {
    local NAME LOCATION LINE
    echo -e "Current Locations\n"
    cat $LOCATIONS2GO | sort | while read LINE
    do
      NAME=$(echo $LINE | cut -d '|' -f 1)
      LOCATION=$(echo $LINE | cut -d '|' -f 2)
      printf "%*s -> %s \n" 15  "$NAME" "$LOCATION"
    done
    echo ""
  }

  function __recursive_add_dir() {
    local LINE
    find $(pwd) -maxdepth 1 -type d | sort | while read LINE
    do
      __add_dir $LINE $(basename $(pwd))-$(basename $LINE)
    done
  }

  function __show_help() {
    echo -e "usage: go2 [options] [PATH] [NAME] \n\nCommand line options\n\t-a [PATH] [<NAME>]: Add the directory to list\n\t-r add all subdirs to list\n\t-l: Lists known directories\n\t-R <NAME>: Removes known directory by name\n\t-v: Show version\n\t-h: Show this message\n"
    return 0
  }

  function __remove_location() {
    if [ -z "$1" ]; then
      __echoerr "You must specify the named directory to remove\nrun 'go2 -h' to see a help message"
      return 2
    fi

    if __not_mapped "$1" ; then
      __echoerr "$1 is not mapped\nrun 'go2 -l' to list all mapped directories"
      return 3
    fi

    local TEMP="$LOCATIONS2GO.tmp"
    grep -vwE "${1}\|" $LOCATIONS2GO > $TEMP
    mv $TEMP $LOCATIONS2GO
    echo "$1 was successfully removed"
  }

  local OPTIND opt
  while getopts "alhrRv" opt; do
    case $opt in
      a)
        __add_dir $2 $3
        return $?
        ;;
      l)
        __list_dirs
        return 0
        ;;
      h)
        __show_help
        return 0
        ;;
      r)
        __recursive_add_dir
        return 0
        ;;
      R)
        __remove_location $2
        return $?
        ;;
      v)
        echo "go2dir version $CURRENTVERSION"
        return 0
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        return 1
        ;;
    esac
  done

  if [ -z "$1" ]; then
    __show_help
    return 0
  else
    local LOCATION=$(__find_location $1)

    if [ -z "$LOCATION" ]; then
      __echoerr " Sorry, i didn't find $1"
      return 1
    else
      echo "go to $1 at $LOCATION"
      cd "$LOCATION"
    fi
  fi
}

# Load autocomplete
if [[ -a $HOME/.go2dir/completion/complete ]] && type complete > /dev/null 2>&1; then
  source $HOME/.go2dir/completion/complete
elif [[ -d $HOME/.go2dir/completion/compdef ]] && type compinit > /dev/null 2>&1; then
  fpath=($HOME/.go2dir/completion/compdef $fpath)
  compinit
fi
