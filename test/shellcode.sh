source bin/asm.sh

asm_init

__asm <<EOF
mov rax, 1
mov rdi, 1
mov rdx, 10
lea rsi, [rip+1]
movabs rbx, 0x68732f2f6e69622f
syscall
EOF



echo "bash script"

__c <<EOF
int main() { 
  write(1, "test\n", 5);
}
EOF

echo "safely returned to bash"
