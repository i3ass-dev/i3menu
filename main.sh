#!/usr/bin/env bash



main(){

  
  # __o[verbose]=1

  ((__o[verbose])) && {
    declare -gi _stamp
    _stamp=$(date +%s%N)
    ERM $'\n'"---i3menu start---"
  }

  _menu_command="
    rofi -theme <(themefile)
    ${__o[options]:+${__o[options]}}
    ${__o[filter]:+-filter \"${__o[filter]}\"}
    ${__o[show]:+-show \"${__o[show]}\"}
    ${__o[modi]:+-modi \"${__o[modi]}\"}
    ${__o[prompt]:+-p \"${__o[prompt]} \"}
  "

  _menu_command=${_menu_command//$'\n'/ }

  [[ -n ${__o[modi]}${__o[show]} ]] || {

    _menu_command+="-dmenu "

    # if we have stuff on stdin, put
    # that in a tempfile that way we can do stuff ( wc in setincludes() )
    # without worrying that we close and lose whats in stdin
    [[ ! -t 0 ]] && {
      _tmp_list_file=$(mktemp)
      trap 'rm "$_tmp_list_file"' EXIT INT
      cp /dev/stdin "$_tmp_list_file"
    }
  }

  # default includes
  : "${__o[include]:=pel}"

  declare -A i3list
  eval "$(eval i3list "${__o[target]}")"

  [[ ${__o[layout]} =~ ^[ABCD]$ ]] \
    && __o[layout]=$(getvirtualpos "${__o[layout]}")

  setgeometry "${__o[layout]:-default}"
  setincludes

  if [[ -f $_tmp_list_file && ${__o[top]} ]];then
    awk -f <(topsort) "$_tmp_list_file"
  elif [[ -f $_tmp_list_file ]]; then
    cat "$_tmp_list_file"
  fi | {
    ((__o[verbose])) && verbose_outro
    ((__o[dryrun]))  || eval "$_menu_command"
  }
}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud
main "${@}"                                     #bashbud

