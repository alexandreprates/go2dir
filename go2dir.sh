# GO 2 DIR
# by Alexandre Prates <ajfprates@gmail.com>
# 2.x - 08-25-2016

FILEPATH="$HOME/.local/share/go2dir"
FILENAME="$FILEPATH/locations.txt"
[ ! -d $FILEPATH ] && mkdir -p $FILEPATH
[ ! -e $FILENAME ] && touch $FILENAME

function go2() {

  function __not_mapped() {
    local line
    cat $FILENAME | while read line
    do
      if [ "$1" = "$line" ]; then
        return 1
      fi
    done
    return $?
  }

  function __add_dir() {
    if [ -z "$1" ]; then
      echo "You must specify the dir to add"
      return 1
    else
      local dir=$(readlink -f $1)
    fi

    if [ -d "$1" ]; then
      local name=$(basename $dir)
    else
      echo "Dir not exists"
      return 1
    fi

    if __not_mapped "$dir" ; then
      echo "Mapping $name for $dir"
      echo -e "$dir" >> $FILENAME
    else
      echo "$1 already mapped"
      return 1
    fi
  }

  function __list_dirs() {
    local line
    echo -e "Maped dirs in $FILENAME\n"
    cat $FILENAME | sort | while read line
    do
      echo "  $line"
    done
    echo ""
  }

  function __recursive_add_dir() {
    find $(pwd) -maxdepth 1 -type d >> $FILENAME
    echo "Added dirs"
    find $(pwd) -maxdepth 1 -type d
  }

  function __show_help() {
    echo -e "usage: go2 [options] [DIRNAME]\n\nCommand line options\n\t-a <DIRNAME>: Add the directory to list\n\t-r add all subdirs to list\n\t-l: Lists known directories\n\t-h: Show this message\n"
    return 0
  }

  function  __searh_for() {
    local line;
    cat $FILENAME | while read line
    do
      name=$(basename $line)
      if [ "$1" = "$name" ]; then
        echo $line
        break
      fi
    done
  }

  local OPTIND opt
  while getopts "alhr" opt; do
    case $opt in
      a)
        __add_dir $2
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
    local location=$(__searh_for $1)

    if [ -z "$location" ]; then
      echo " Sorry, i didn't find $1"
      return 1
    else
      echo "go to $location"
      cd $location
    fi
  fi
}
