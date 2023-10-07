all: obj/payload.bin obj/malloc.bin obj/exec.bin

obj/%.bin: src/%.c
	ragg2 $< -o shellcode | tail -n1 | cat > $@

force: 
