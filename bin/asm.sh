#!/bin/bash
__assemble(){
  asm -c amd64 -f hex
}

__asm(){
  run_shellcode "$(__assemble)"
}
shellcode(){
  run_shellcode "$(cat)"
}


__assemble_c(){
  file=$(mktemp /tmp/XXXXX.c)
  err=$(mktemp /tmp/XXXXX.err)
  cat>"$file"

  asm=$(ragg2 "$file" 2>$err | tail -n1)
  if [ -z "$asm" ]; then
   echo "- ERROR PARSING C -" >&2
   cat <$err >&2
  fi
  rm -f "$file"

  echo "$asm"
}

__c(){
  run_shellcode "$(__assemble_c)"
}

asm_init() {
   PID=$$

   mkfifo /tmp/z 2>/dev/null
   # fork off
   (
      # /proc/pid/syscall contains the registers of the process (note: the parent, not the child)
      # since this is happening while the parent is spinning trying to read the FIFO
      # the program counter will always reliably land in the middle of libc write()
      # which means we have a stable and minimal error-prone way of getting back to the RIP
      cat /proc/$PID/syscall >/tmp/regs

      # unhang parent
      : </tmp/z
   ) &

   # begin to write to FIFO. this will hang
   : >/tmp/z

   # after the return of the above line we can know the address of libc write()
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
   : >/tmp/x
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

run_shellcode() {
   # allocate RWX memory for the shellcode
   inject_rip \
e94b020000662e0f1f8400000000009048897c24f848897424f048895424e8488b4424f048894424e0488b4424f848894424d8c74424d40000000048634424d4483b4424e87327488b4424e048634c24d48a1408488b4424d848634c24d48814088b4424d483c001894424d4ebcdc39048897c24f848897424f0488b4424f8894424e883f8007d0c31c0482b4424f848894424f8c74424ec00000000488b4424f8b90a00000031d248f7f14883c230488b4424f08b4c24ec89ce83c601897424ec4863c9881408488b4424f8b90a00000031d248f7f148894424f84883f80077bb837c24e8007d19488b4424f08b4c24ec89ca83c201895424ec4863c9c604082d488b4424f048634c24ecc6040800c35048893c24488b3c244881e700f0ffffbe00100000ba07000000e81100000058c3662e0f1f8400000000000f1f44000048897c24f8897424f4895424f0488b4424f848894424e08b4424f4894424dc8b4424f0894424d8488b7c24e08b7424dc8b5424d8b80a0000000f0548894424e8488b4424e8894424d48b4424d4c366904883ec28909090909090909048b8cccccccccccccccc4889442418488d3d9301000031d289d6e8450000008944241448b8ffffffffffff00004889442408488b7c2408e838ffffff488d056d01000048890424488b7c2408488b3424ba19000000e81afeffff8b4424244883c428c39048897c24f8897424f4895424f0488b4424f848894424e08b4424f4894424dc8b4424f0894424d8488b7c24e08b7424dc8b5424d8b8020000000f0548894424e8488b4424e8894424d48b4424d4c366904883ec1848b8cccccccccccccccc4889442410c744240caaaaaaaa8b74240c31c089c7ba07000000b92200000041b8ffffffff4531c9e83500000048890424488b7c2410e877feffff488b0c24488b442410488908e8e6feffff31c04883c418c3662e0f1f8400000000000f1f44000048897c24f8897424f4895424f0894c24ec44894424e844894c24e4488b4424f848894424d08b4424f4894424cc8b4424f0894424c88b4424ec894424c48b4424e8894424c08b4424e4894424bc488b7c24d08b7424cc8b5424c8448b5424c4448b4424c0448b4c24bcb8090000000f0548894424d8488b4424d848894424b0488b4424b0c32f746d702f7800706c616365746f7075747468656f726967696e616c7368686800

   # make bash call libc write(), triggering malloc
   : >/

   # find the pointer to the memory we just allocated
   rawptr=$(readmem "$((0x$base))" 8 | xxd -p | swaps)
   ptr=$(printf "%08x" "$((0x$rawptr))")

   # write the payload into the RWX allocation
   echo "${1}c3" | xxd -p -r | writemem "0x$ptr"

   # shellcode to execute the payload with the call instruction
   shellexec=\
e94b020000662e0f1f8400000000009048897c24f848897424f048895424e8488b4424f048894424e0488b4424f848894424d8c74424d40000000048634424d4483b4424e87327488b4424e048634c24d48a1408488b4424d848634c24d48814088b4424d483c001894424d4ebcdc39048897c24f848897424f0488b4424f8894424e883f8007d0c31c0482b4424f848894424f8c74424ec00000000488b4424f8b90a00000031d248f7f14883c230488b4424f08b4c24ec89ce83c601897424ec4863c9881408488b4424f8b90a00000031d248f7f148894424f84883f80077bb837c24e8007d19488b4424f08b4c24ec89ca83c201895424ec4863c9c604082d488b4424f048634c24ecc6040800c35048893c24488b3c244881e700f0ffffbe00100000ba07000000e81100000058c3662e0f1f8400000000000f1f44000048897c24f8897424f4895424f0488b4424f848894424e08b4424f4894424dc8b4424f0894424d8488b7c24e08b7424dc8b5424d8b80a0000000f0548894424e8488b4424e8894424d48b4424d4c366904883ec28909090909090909048b8cccccccccccccccc4889442418488d3dbb00000031d289d6e8450000008944241448b8ffffffffffff00004889442408488b7c2408e838ffffff488d059500000048890424488b7c2408488b3424ba19000000e81afeffff8b4424244883c428c39048897c24f8897424f4895424f0488b4424f848894424e08b4424f4894424dc8b4424f0894424d8488b7c24e08b7424dc8b5424d8b8020000000f0548894424e8488b4424e8894424d48b4424d4c366905048b8aaaaaaaaaaaaaaaa48890424b000ff1424e827ffffff31c059c32f746d702f7800706c616365746f7075747468656f726967696e616c7368686800
   inject_rip "$(echo "$shellexec" | sed "s/aaaaaaaaaaaaaaaa/$(echo "$ptr" | swaps)0000/g")"

   # another libc write(), triggering the payload inside $1
   : >/
}
