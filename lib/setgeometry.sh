#!/usr/bin/env bash

defaultoffset(){
  __xpos=0
  __ypos=0
  __o[xoffset]=0
  __o[yoffset]=0
  __o[width]=${i3list[WAW]}
  __height=20
  __o[layout]=default
  __orientation=horizontal
  __anchor=1
}

setgeometry(){

  __layout="$1"

  # default geometry
  : "${__xpos:=${__o[xpos]:-0}}"
  : "${__ypos:=${__o[ypos]:-0}}"
  : "${__o[xoffset]:=0}"
  : "${__o[yoffset]:=0}"
  : "${__o[width]:=${i3list[WAW]}}"
  : "${__height:=${__o[height]:-${i3list[TWB]:-20}}}"
  : "${__o[anchor]:=1}"
  : "${__orientation:=horizontal}"

  # if layout is window or container, but no list -> titlebar
  [[ $__layout =~ A|B|C|D|window && ! -f $_tmp_list_file ]] && {
    defaultoffset
    if [[ -n ${__o[fallback]:-} ]]; then
      __layout=fallback
      setfallback "${__o[fallback]}"
      setgeometry "${__o[layout]:-default}"
      return
    else
      __layout=titlebar
    fi
  }

  # if layout is container but container is not visible -> default
  [[ $__layout =~ A|B|C|D ]] && [[ ! ${i3list[LVI]} =~ [${__layout}] ]] && {
    defaultoffset
    if [[ -n ${__o[fallback]:-} ]]; then
      __layout=fallback
      setfallback "${__o[fallback]}"
      setgeometry "${__o[layout]:-default}"
      return
    else
      __layout=default
    fi
  }

  # if layout is window, tab or titlebar but no target window -> default
  [[ $__layout =~ window|tab|titlebar ]] && [[ -z ${i3list[TWC]} ]] && {
    defaultoffset
    if [[ -n ${__o[fallback]:-} ]]; then
      __layout=fallback
      setfallback "${__o[fallback]}"
      setgeometry "${__o[layout]:-default}"
      return
    else
      __layout=default
    fi
  }

  case "$__layout" in

    titlebar  ) 
      __ypos=$((i3list[TWY]+i3list[WAY]))
      __xpos=$((i3list[TWX]+i3list[WAX]))
      __o[width]=${i3list[TWW]}
      __height=${i3list[TWB]}
      __orientation=horizontal
    ;;

    window    )
        __xpos=$((i3list[TWX]+i3list[WAX]))
        __ypos=$((i3list[TWY]+i3list[WAY]))
        __o[width]=${i3list[TWW]}
        __height=${i3list[TWH]}
        __orientation=vertical
        __o[orientation]=""
    ;;

    bottom )
      __ypos=$((i3list[WAH]-i3list[AWB]))
    ;;

    tab       ) 
      if ((i3list[TTW]==i3list[TWW])); then
        __xpos=$((i3list[TWX]+i3list[WAX]))
        __o[width]=${i3list[TWW]}
      else
        __xpos=$((i3list[TTX]+i3list[TWX]))
        __o[width]=${i3list[TTW]}
      fi
      __ypos=$((i3list[TWY]+i3list[WAY]))
      __height=${i3list[TWB]}
      __orientation=horizontal
    ;;

    A|B|C|D ) 
      case "$__layout" in
        A) 
          __xpos=0
          __ypos=0
          __o[width]=${i3list[SAB]:-${i3list[WAW]}}
          __height=${i3list[SAC]:-${i3list[WAH]}}
        ;;

        B) 
          __xpos=${i3list[SAB]:-0}
          __ypos=0
          __o[width]=$((i3list[WAW]-__xpos))
          __height=${i3list[SBD]:-${i3list[SAC]:-${i3list[WAH]}}}
        ;;

        C) 
          __xpos=0
          __ypos=${i3list[SAC]:-0}
          __o[width]=${i3list[SCD]:-${i3list[SAB]:-${i3list[WAW]}}}
          __height=$((i3list[WAH]-__ypos))
        ;;

        D) 
          __xpos=${i3list[SCD]:-${i3list[SAB]:-0}}
          __ypos=${i3list[SBD]:-0}
          __o[width]=$((i3list[WAW]-__xpos))
          __height=$((i3list[WAH]-__ypos))
        ;;
      esac

      ((__height))   || __height="${i3list[WAH]}"
      ((__o[width])) || __o[width]="${i3list[WAW]}"
      __orientation=vertical
      __o[orientation]=""
    ;;

    mouse )

      # xdotool getmouselocation --shell ; example:
      # X=667
      # Y=175
      # SCREEN=0
      # WINDOW=6291526
      #
      # AWK turns the output from: WINDOW=.. -> xdo_geo[WINDOW]=...
      # before it's evaluated

      declare -A xdo_geo

      eval "$(xdotool getmouselocation --shell | \
        awk '{ printf("xdo_geo[%s]=%s\n",$1,$2) }' FS='='
      )"

      __xpos="$((xdo_geo[X]))"
      __ypos="$((xdo_geo[Y]))"
    ;;

  esac

  case ${__o[anchor]:=1} in
    1   ) __anchor="north west" ;;
    2   ) __anchor="north" ;;
    3   ) __anchor="north east" ;;
    4   ) __anchor="west" ;;
    5   ) __anchor="center" ;;
    6   ) __anchor="east" ;;
    7   ) __anchor="south west" ;;
    8   ) __anchor="south" ;;
    9   ) __anchor="south east" ;;
    *   ) __anchor="north west" ;;
  esac

  [[ -n ${__o[xpos]:-} ]] && {
    if ((__o[xpos]<0)) || ((__o[xpos]==-0)); then
      __xpos=$((i3list[WAW]-((__o[xpos]*-1)+__o[width])))
    else
      __xpos=${__o[xpos]}
    fi
  }

  ((${__height%px}<20)) && __height=20
  [[ -n ${__o[height]} ]] && __height="${__o[height]}"

  [[ -n ${__o[ypos]:-} ]] && __ypos=${__o[ypos]}

  [[ ${__o[xoffset]} =~ ^[0-9-]+$ ]] && __xpos=$((__xpos+__o[xoffset]))
  [[ ${__o[yoffset]} =~ ^[0-9-]+$ ]] && __ypos=$((__ypos+__o[yoffset]))

  [[ ${__o[width]} =~ [%]$ ]] || __o[width]=${__o[width]}px
  __height+="px"
}
