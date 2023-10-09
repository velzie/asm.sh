#!/bin/bash
#include "macros.sh"

asm_init() {
   PID=$$


   pipe=$(mktemp -ut pipe.XXX)
   mkfifo "$pipe"
   # fork off
   (
      # /proc/pid/syscall contains the registers of the process (note: the parent, not the child)
      # since this is happening while the parent is spinning trying to read the FIFO
      # the program counter will always reliably land in the middle of libc write()
      # which means we have a stable and minimal error-prone way of getting back to the RIP
      cat /proc/$PID/syscall >/tmp/regs

      # unhang parent
      :<"$pipe"
   ) &

   # begin to write to FIFO. this will hang
   :>"$pipe"

   # after the return of the above line we can know the address of libc write()
   rm -f "$pipe"
   regs=$(</tmp/regs)
   rip=${regs##* }

   # parse maps for the address of the ELF header. we write to the header because its location will always be known
   # and during runtime it will never be used
   maps=$(cat /proc/$$/maps | grep r-xp | head -n1)
   base=${maps%%-*}

}

# big endian <-> little endian
swaps() {
   fold -w2 | tac | tr -d "\n"
}

writemem() {
   dd of=/proc/$$/mem conv=notrunc seek=$(($1)) bs=1 status=none
}

readmem() {
   dd if=/proc/$$/mem skip=$(($1)) count=$(($2)) bs=1 status=none
}

fromhex(){
   xxd -p -r
}

tohex(){
   xxd -p
}

inject_rip() {
   # back up original libc write() to a specific spot inside the ELF header
   orig=$(readmem "$rip" 25 | tohex)

   # inject magic pointers into the shellcode, write it to a spot inside the ELF header
   echo "$1" |
      sed "s/ffffffffffff/$(echo "$rip" | swaps)/g" |
      sed "s/cccccccccccccccc/$(echo "$base" | swaps)0000/g" |
      sed "s/706c616365746f7075747468656f726967696e616c73686868/$orig/g" |
      fromhex |
      writemem "0x$base"

   # mov r10, 0x$base
   asm="48b8$(echo "$base" | swaps)0000"
   # call r10
   asm+="ffd0"

   # replace libc write() with a call to the function we just wrote inside the ELF header
   echo -en "$asm" |
      fromhex |
      writemem "$rip"
}

_malloc(){
   size=$(printf "%08x" "$1")
   asm=\
#include "../obj/malloc.bin"
   asm=${asm//aaaaaaaa/$size}
   inject_rip "$asm"

   # make bash call libc write(), triggering malloc
   :>/

   # find the pointer to the memory we just allocated
   rawptr=$(readmem "$((0x$base))" 8 | xxd -p | swaps)
   ptr=$((0x$rawptr))
   # write the payload into the RWX allocation
   echo "$2" | xxd -p -r | writemem "$ptr"
}
malloc(){
   _malloc "$1" "$2" <<<""
}

mkpage(){
   malloc "$1" "$2"

   __last_page=$ptr
   __last_page_size=$1
}

_run_shellcode() {
   # allocate RWX memory for the shellcode
   malloc "$(( ${#1} / 2 ))" "${1}c3" # (c3 is ret)
   hexptr=$(printf "%08x" "$ptr")

   # shellcode to execute the payload with the call instruction
   shellexec=\
#include "../obj/exec.bin"
   addr=$(echo "$hexptr" | swaps)0000
   shellexec=${shellexec//aaaaaaaaaaaaaaaa/$addr}
   inject_rip "$shellexec"
   # another libc write(), triggering the payload inside $1
   :>/
}
run_shellcode(){
   _run_shellcode "$1" <<<""
}
