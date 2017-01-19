# GO 2 DIR
# by Alexandre Prates <ajfprates@gmail.com>
# 2.0 - 08-25-2016

FILEPATH="$HOME/.local/share/go2dir"
FILENAME="$FILEPATH/locations.txt"
[ ! -d $FILEPATH ] && mkdir -p $FILEPATH
[ ! -e $FILENAME ] && touch $FILENAME

go2() {
  __not_exist() {
    cat $FILENAME | while read line
    do
      if [ "$1" = "$line" ]; then
        return 1
      fi
    done
    return $?
  }

  __add_dir() {
    local dir=$(pwd)
    local name=$(basename $dir)

    if __not_exist "$dir" ; then
      echo "Adicionando $dir"
      echo -e "$dir" >> $FILENAME
    else
      echo "Dir already exist"
      return 1
    fi
  }

  __list_dirs() {
    echo -e "Maped dirs in $FILENAME\n"
    cat $FILENAME | sort | while read line
    do
      echo "  $line"
    done
  }

  __recursive_add_dir() {
    find $(pwd) -maxdepth 1 -type d >> $FILENAME
    echo "Added dirs"
    find $(pwd) -maxdepth 1 -type d
  }

  __show_help() {
    echo -e "usage: go2 [options] [DIRNAME]\n\nCommand line options\n\t-a: Add the current directory to list\n\t-r add all subdirs to list\n\t-l: Lists known directories\n\t-h: Show this message\n"
    return 0
  }

  while getopts "alhr" opt; do
    case $opt in
      a)
        __add_dir
        return
        ;;
      l)
        __list_dirs
        return
        ;;
      h)
        __show_help
        return
        ;;
      r)
        __recursive_add_dir
        return
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
  fi

  cat $FILENAME | while read line
  do
    name=$(basename $line)
    if [ "$1" = "$name" ]; then
      echo "go to $line"
      cd $line
      return 0
    fi
  done

  echo "$1 not found :("
  return 1
}
