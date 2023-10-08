
run(){
  source bin/asm.sh
  asm_init

__asm <<EOF
mov rax, 1
mov rdi, 1
mov rdx, 8
lea rsi, [rip+2]
movabs rbx, 0x0a6d736174736574
syscall
EOF

}

expect(){
  echo "testasm" | xxd -p
}
