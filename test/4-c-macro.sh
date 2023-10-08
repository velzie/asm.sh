run(){
  source bin/asm.sh
  asm_init

  __c <<EOF
int main() { 
  write(1, "test\n", 5);
}
EOF
}

expect(){
  echo "test" | xxd -p
}
