run(){
  source bin/asm.sh
  asm_init

  malloc 5 "$(echo "test" | xxd -p)"
  syscall 1 1 "$ptr" 5
}

expect(){
  echo "test" | xxd -p 
}
