__assemble(){
  asm -c amd64 -f hex
}

__asm(){
  run_shellcode "$(__assemble)"
}


__assemble_c(){
  file=$(mktemp /tmp/XXXXX.c)
cat>"$file"

exec {err}<> <(:)
asm=$(ragg2 "$file" 2>/dev/fd/$err | tail -n1)
if [ -z "$asm" ]; then
   echo "- ERROR PARSING C -" >&2
   cat </dev/fd/$err >&2
fi
rm -f "$file"


echo "$asm"
}

__c(){
  run_shellcode "$(__assemble_c)"
}
