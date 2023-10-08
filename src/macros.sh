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
  cat>"$file"

  asm=$(ragg2 "$file" 2>$err | tail -n1)
  if [ -z "$asm" ]; then
   echo "- ERROR PARSING C -" >&2
   cat <$err >&2
  fi
  rm -f "$file"

  echo "$asm"
}

__c(){
  run_shellcode "$(__assemble_c)"
}
