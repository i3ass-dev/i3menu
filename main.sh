#!/usr/bin/env bash

main(){

  declare -a listopts

  # globals
  __cmd="rofi -theme <(themefile) "

  # default includes
  : "${__o[include]:=pel}"

  # options to pass to i3list via --target optiob
  [[ -n "${__o[target]}" ]] \
    && mapfile -td $'\n\s' listopts <<< "${__o[target]}"

  declare -A i3list
  eval "$(i3list "${listopts[@]}")"

  [[ -n ${__o[options]} ]] && __opts+=" ${__o[options]}"
  [[ -n ${__o[filter]} ]] && __cmd+="-filter '${__o[filter]}' "
  
  [[ -n ${__o[show]} ]] \
    && __opts+=" -show '${__o[show]}'" && __nolist=1
  [[ -n ${__o[modi]} ]] \
    && __opts+=" -modi '${__o[modi]}'" && __nolist=1

  if ((__nolist!=1)); then
    __opts+=" -dmenu"
    [[ -n $__stdin ]] && __list="${__stdin}"
  else
    __list=nolist
  fi

  [[ ${__o[layout]} =~ A|B|C|D ]] \
    && __o[layout]=$(getvirtualpos "${__o[layout]}")

  setgeometry "${__o[layout]:-default}"
  setincludes

  if [[ -n $__list ]] && ((__nolist!=1));then
    printf '%s\n' "${__o[top]:-}" "__START" "${__list}" | awk '
    {
      if (start==1) {
        for (t in tops) {
          if ($0==tops[t]){tfnd[NR]=$0;topa[t]=$0} 
        }
        if (tfnd[NR]!=$0) {lst[NR]=$0}
      }
      if ($0=="__START") {start=1}
      if (start!=1) {tops[NR]=$0;nums++}
    }

    END {
      for (f in topa){if (topa[f]){print topa[f]}}
      for (l in lst){print lst[l]}
    }
    '
  fi | eval "${__cmd} ${__opts}"
}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud
main "${@}"                                     #bashbud
