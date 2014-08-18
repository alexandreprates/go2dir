# GO to directories
# by Alexandre Prates
#
# How to use:
#   in .bash_profile set directories to search
#     export GOSEARCH=/home/myuser:~/workprojects:~/whatever
#     [[ -s "$HOME/.go2dir/go2dir.sh" ]] && source "$HOME/.go2dir/go2dir.sh" 
#   in bash
#     # go whatever (...and the magic happens)

echoerr() { printf "\a"; echo "$@" 1>&2; }

go() {
  if [ $GOSEARCH ]; then
    search_path=$GOSEARCH
  else
    echo "GOSEARCH not found using $HOME instead."
    search_path=$HOME
  fi

  search_array=(${=search_path//:/ })

  for index in $search_array
  do
    goto=$(find $index/. -maxdepth 1 -type d -name $1 -print -quit)
    if [ $goto ]; then
      cd $goto
      return;
    fi
  done

  echoerr "Sorry can't go to $1"
  exit 1
}
