run(){
  source bin/asm.sh
  asm_init

  shellcode <<<"90"
  echo "test"
}

expect(){
  echo "test" | xxd -p
}
