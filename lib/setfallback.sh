#!/bin/bash

setfallback(){

 __o[fallback]=""

 declare -a opts
 # using eval here to silence shellcheck
 # $* (__o[fallback]) can look like this: 
 # __o[fallback]='--layout D --fallback "--layout A"'
 eval "opts=($*)"

 eval set -- "$(getopt --name "i3menu" \
   --options "a:i:t:x:y:w:o:p:f:" \
   --longoptions "theme:,layout:,include:,top:,xpos:,xoffset:,ypos:,yoffset:,width:,options:,prompt:,filter:,show:,modi:,target:,orientation:,anchor:,height:,fallback:" \
   -- "${opts[@]}"
 )"

 while true; do
   case "$1" in
     --theme      ) __o[theme]="${2:-}" ; shift ;;
     --layout     | -a ) __o[layout]="${2:-}" ; shift ;;
     --include    | -i ) __o[include]="${2:-}" ; shift ;;
     --top        | -t ) __o[top]="${2:-}" ; shift ;;
     --xpos       | -x ) __o[xpos]="${2:-}" ; shift ;;
     --xoffset    ) __o[xoffset]="${2:-}" ; shift ;;
     --ypos       | -y ) __o[ypos]="${2:-}" ; shift ;;
     --yoffset    ) __o[yoffset]="${2:-}" ; shift ;;
     --width      | -w ) __o[width]="${2:-}" ; shift ;;
     --options    | -o ) __o[options]="${2:-}" ; shift ;;
     --prompt     | -p ) __o[prompt]="${2:-}" ; shift ;;
     --filter     | -f ) __o[filter]="${2:-}" ; shift ;;
     --show       ) __o[show]="${2:-}" ; shift ;;
     --modi       ) __o[modi]="${2:-}" ; shift ;;
     --target     ) __o[target]="${2:-}" ; shift ;;
     --orientation ) __o[orientation]="${2:-}" ; shift ;;
     --anchor     ) __o[anchor]="${2:-}" ; shift ;;
     --height     | -h ) __o[height]="${2:-}" ; shift ;;
     --fallback   ) __o[fallback]="${2:-}" ; shift ;;
     -- ) shift ; break ;;
     *  ) break ;;
   esac
   shift
 done

 [[ ${__o[layout]} =~ A|B|C|D ]] \
   && __o[layout]=$(getvirtualpos "${__o[layout]}")
}
