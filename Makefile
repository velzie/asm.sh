all: obj/payload.bin obj/malloc.bin obj/exec.bin

obj/%.bin: src/%.c src/restore.c
	ragg2 $< -o shellcode | tail -n1 | cat > $@

force: 
