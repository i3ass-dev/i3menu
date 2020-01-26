#!/usr/bin/env bash

__=""
__stdin=""

sleep .05
read -rN1 -t0.01 __  && {
  (( $? <= 128 ))  && {
    IFS= read -rd '' __stdin
    __stdin="$__$__stdin"
  }
}
