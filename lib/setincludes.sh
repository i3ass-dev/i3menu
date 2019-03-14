#!/usr/bin/env bash

setincludes(){
  local entry_expand entry_width listview_layout 
  local window_content horibox_content listview_lines

  [[ -n ${__o[prompt]:-} ]] \
    && __cmd+="-p ${__o[prompt]} " \
    || __o[include]=${__o[include]/[p]/}

  if [[ -z ${__list:-} ]]; then
    __o[include]=${__o[include]/[l]/}

    entry_expand=true
    entry_width=0

  else
    [[ -n ${__o[orientation]:-} ]] && {
      __orientation=${__o[orientation]}
      [[ $__orientation = vertical ]] && [[ -z ${__o[height]} ]] \
        && __height=0
    }
    listview_layout="$__orientation"
    ((__nolist!=1)) \
      && listview_lines="$(($(echo "${__list}" | wc -l)-1))"
  fi

  [[ ${__o[include]} =~ [p] ]] && inc+=(prompt)
  [[ ${__o[include]} =~ [e] ]] && inc+=(entry)

  if [[ $__orientation = vertical ]]; then
   
    __o[include]=${inc[*]}
    window_content="[ mainbox ]"
    inputbar_content="[${__o[include]//' '/','}]"
  else
    [[ ${__o[include]} =~ [l] ]] && inc+=(listview)
    __o[include]=${inc[*]}
    horibox_content="[${__o[include]//' '/','}]"
    window_content="[ horibox ]"
  fi

  if [[ $__layout = mouse ]] || { [[ $__ypos -lt 0 || $__ypos = -0 ]] && ((__o[anchor]<7)) ;}; then

    notify-send "old y: $__ypos"
    opty="$__ypos"
    __ypos=9999999

    {
      declare -A __menu

      eval "$(xdotool search --sync --classname rofi getwindowgeometry --shell | \
        awk -v FS='=' '{
          printf("__menu[%s]=%s\n",$1,$2)
        }'
      )"

      if ((__menu[X]<i3list[WAX])); then
        newx="${i3list[WAX]}"
      elif (((__menu[X]+__menu[WIDTH])>i3list[WAW])); then
        newx="$((i3list[WAW]-__menu[WIDTH]))"
      else
        newx=${__menu[X]}
      fi


      if ((opty<=-0)); then
        opty=$((i3list[WAH]-((opty*-1)+__menu[HEIGHT])))
      fi

      if ((opty<i3list[WAY])); then
        newy="${i3list[WAY]}"
      elif (((opty+__menu[HEIGHT])>i3list[WAH])); then
        newy="$((i3list[WAH]-__menu[HEIGHT]))"
      else
        newy="$opty"
      fi

      notify-send "new y: $newy"
      xdotool windowmove "${__menu[WINDOW]}" "$newx" "$newy"
    } &
    
    
  fi 


  __themelayout="
  * {
    window-anchor:    ${__anchor:-north west};
    window-content:   ${window_content:-[horibox,listview]};
    horibox-content:  ${horibox_content:-[prompt, entry]};
    window-width:     ${__o[width]};
    window-height:    ${__height};
    window-x:         ${__xpos}px;
    window-y:         ${__ypos}px;
    listview-layout:  ${listview_layout:-horizontal};
    listview-lines:   ${listview_lines:-50};
    entry-expand:     ${entry_expand:-false};
    entry-width:      ${entry_width:-10em};
    inputbar-content: ${inputbar_content:-[prompt,entry]};
  }
  "
}
