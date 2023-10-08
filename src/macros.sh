__assemble(){
  asm -c amd64 -f hex
}

__asm(){
  run_shellcode "$(__assemble)"
}
shellcode(){
  run_shellcode "$(cat)"
}


__assemble_c(){
  file=$(mktemp /tmp/XXXXX.c)
  err=$(mktemp /tmp/XXXXX.err)
  
  cat <<EOF >"$file"
#include "page.c"
EOF
  cat>>"$file"

  asm=$(ragg2 "$file" 2>$err | tail -n1)
  if [ -z "$asm" ]; then
   echo "- ERROR PARSING C -" >&2
   cat <$err >&2
  fi
  rm -f "$file"
  echo "$asm"
}

__run_c(){
  asm=$1
  if [ -n "$__last_page" ]; then
    hex=$(printf "%08x" "$__last_page" | swaps)
    asm=${asm//bbbbbbbbbbbbbbbb/${hex}0000}
  fi

  run_shellcode "$asm"

  if [ -n "$__last_page" ]; then
    page=$(readmem "$__last_page" "$__last_page_size" | xxd -p)
  fi
}

__c(){
  __run_c "$(__assemble_c)"
}
