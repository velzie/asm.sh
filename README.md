# asm.sh
This is a zero-dependency framework for embedding (somewhat) portable inline assembly directly inside bash.

At a basic level, it works by spraying shellcode inside /proc/$$/mem. From there, you can do things that you normally can't. Here are a few examples:

### Print "hello"
```bash
run_shellcode "48b801010101010101015048b869646d6d6e0b0101483104244889e66a015f6a065a6a01580f05"
```

### Run inline assembly (intel)
```bash
__asm <<EOF
pop rdi
pop rsi
pop rbp
pop rbx
pop rbx
pop rdx
pop rcx
pop rax
xor rsp, rsp
jmp rsp
EOF
```

### Run inline C
```bash
__c <<EOF
int main(){
    write(1,"test\n",5);
}
EOF
```
Using `mkpage`, you can pass data from C directly to bash variables

Note: inline asm and inline C require pwntools asm and ragg2/clang to be installed, respectively. The `asmpp` preprocessor is provided to have those dependencies not required at runtime

### Run any linux system call
```bash
malloc 5 "$(echo "test" | xxd -p)"
syscall $__NR_write $STDOUT_FILENO $ptr 5
```

In all these examples, the injected code runs as the main process, meaning you can do things much faster and access the shell's memory directly. It also means your entire shell will crash if you mess up


## Is this a joke?
No.

# Installation
```bash
git clone https://github.com/CoolElectronics/asm.sh
cd asm.sh
make install
```

# Usage
Once installed, in any shell you can run `source asm.sh`. Make sure to run `asm_init` before running any commands


Alternatively, you can grab the entire [asm.sh] from releases and include it inside your bash script if you don't want to manage dependencies.


Only amd64 is supported currently. ksh is supported but can be buggy sometimes. It may segfault instantly on your machine. I'm not entirely sure why
