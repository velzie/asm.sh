run(){
  source bin/asm.sh
  asm_init

  syscall 60 41
  echo "failed"
}

expect(){
  :
}
