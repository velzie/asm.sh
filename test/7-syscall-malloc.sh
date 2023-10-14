run(){
  source bin/asm.sh
  asm_init

  malloc 5 "$(echo "test" | xxd -p)"
  syscall $__NR_write $STDOUT_FILENO "$ptr" 5
}

expect(){
  echo "test" | xxd -p 
}
