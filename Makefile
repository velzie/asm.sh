bin/asm.sh: src/main.sh src/macros.sh obj/payload.bin obj/malloc.bin obj/exec.bin
	bin/bashpp src/main.sh -o $@

test: bin/asm.sh test/*.sh
	$(SHELL) test/test.sh

install: bin/asm.sh bin/asmpp
	sudo cp bin/asm.sh /usr/local/bin/asm.sh
	sudo cp bin/asmpp /usr/local/bin/asmpp
	sudo chmod +x /usr/local/bin/asmpp


obj/%.bin: src/%.c src/restore.c
	ragg2 $< -o shellcode | tail -n1 | cat > $@

force: 
