# GO 2 DIR
# by Alexandre Prates <ajfprates@gmail.com>
# 2.x - 08-25-2016

FILEPATH="$HOME/.local/share/go2dir"
FILENAME="$FILEPATH/locations.txt"
[ ! -d $FILEPATH ] && mkdir -p $FILEPATH
[ ! -e $FILENAME ] && touch $FILENAME

function go2() {
  function __find_location() {
    cat $FILENAME | while read line; do
      local NAME=$(echo $line | cut -d '|' -f 1)
      local LOCATION=$(echo $line | cut -d '|' -f 2)
      if [ "$1" = "$NAME" ]; then
        echo $LOCATION
        break
      fi
    done
  }
  function __not_mapped() {
    local location=$(__find_location $1)
    if [ -z "$location" ]; then
      return 0
    fi
    return 1
  }
  function __add_dir() {
    if [ -z "$1" ]; then
      echo "You must specify the dir to add"
      return 1
    else
      local dir=$(__dir_pwd $1)
    fi
    
    if [ -d "$1" ]; then
      local dirname=$(echo $dir | sed 's/\s/\-/g')
      local name=${2-`basename $dirname`}
    else
      echo "Dir does not exist"
      return 1
    fi
    
    if __not_mapped "$name" ; then
      echo "Mapping $name to $dir"
      echo -e "$name|$dir" >> $FILENAME
    else
      echo "$name is already mapped to $dir"
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
    local line
    echo -e "Mapped dirs in $FILENAME\n"
    cat $FILENAME | sort | while read line
    do
      echo "  $line"
    done
    echo ""
  }
  
  function __recursive_add_dir() {
    find $(pwd) -maxdepth 1 -type d | sort | while read line
    do
      __add_dir $line $(basename $(pwd))-$(basename $line)
    done
  }
  
  function __show_help() {
    echo -e "usage: go2 [options] [PATH] [NAME] \n\nCommand line options\n\t-a [PATH] [<NAME>]: Add the directory to list\n\t-r add all subdirs to list\n\t-l: Lists known directories\n\t-h: Show this message\n"
    return 0
  }
  
  local OPTIND opt
  while getopts "alhr" opt; do
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
    local location=$(__find_location $1)

    if [ -z "$location" ]; then
      echo " Sorry, i didn't find $1"
      return 1
    else
      echo "go to $1 at $location"
      cd "$location"
    fi
  fi
}