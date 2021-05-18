#!/bin/bash

verbose_outro() {
  declare -i delta=$(( ($(date +%s%N)-_stamp) /1000 ))
  declare -i time=$(((delta / 1000) % 1000))

  ERM $'\n'"------ theme start ------"
  themefile >&2
  ERM "------ theme end ------"
  ERM $'\n'"cmd: $_menu_command"
  ERM  $'\n'"---i3menu done: ${time}ms---"$'\n'
}
