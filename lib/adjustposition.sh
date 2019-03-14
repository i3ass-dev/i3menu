#!/usr/bin/env bash

adjustposition() {
  local newy newx opty

  opty="${1:-0}"

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

  xdotool windowmove "${__menu[WINDOW]}" "$newx" "$newy"
}
