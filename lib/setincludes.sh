#!/usr/bin/env bash

setincludes(){
  local entry_expand entry_width listview_layout 
  local window_content horibox_content listview_lines

  [[ -n ${__o[prompt]} ]] || __o[include]=${__o[include]/[p]/}

  if [[ -f $_tmp_list_file ]]; then

    [[ -n ${__o[orientation]:-} ]] && {
      __orientation=${__o[orientation]}
      [[ $__orientation = vertical ]] && [[ -z ${__o[height]} ]] \
        && __height=0
    }
    listview_layout="$__orientation"
    listview_lines=$(wc -l < "$_tmp_list_file")


  else
    __o[include]=${__o[include]/[l]/}
    entry_expand=true
    entry_width=0
  fi

  [[ ${__o[include]} =~ [p] ]] && inc+=(prompt)
  [[ ${__o[include]} =~ [e] ]] && inc+=(entry)

  if [[ $__orientation = vertical ]]; then
   
    __o[include]=${inc[*]}
    window_content="[ mainbox ]"
    inputbar_content="[${__o[include]//' '/','}]"
  else
    # limit number of lines in horizontal menu, 
    # it gets slow otherwise...
    ((listview_lines > 500)) && listview_lines=500
    [[ ${__o[include]} =~ [l] ]] && inc+=(listview)
    __o[include]=${inc[*]}
    horibox_content="[${__o[include]//' '/','}]"
    window_content="[ horibox ]"
  fi


  # TODO: why this test for negative zero???
  if [[ $__layout = mouse ]] || { [[ $__ypos -lt 0 || $__ypos = -0 ]] && ((__o[anchor]<7)) ;}; then

    ERM "$__ypos ${__o[width]}"
    adjustposition "$__ypos" &
    
    # move window offscreen if:
    { 
      # negative ypos or xpos is outside of screen
      { [[ $__ypos -lt 0 || $__ypos = -0 ]] && ((__o[anchor]<7)) ;} || \
      ((__xpos+${__o[width]%px}>i3list[WAW]))

    } && __ypos=9999999

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
