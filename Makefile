bin/asm.sh: src/main.sh src/macros.sh obj/malloc.bin obj/exec.bin obj/syscall.bin obj/consts.sh 
	bin/bashpp src/main.sh -o $@

obj/consts.sh:
	pwn constgrep -c amd64 -m "(NR|FILENO)" | sed "s/#define //g" | sed "s/ /=/" | sed "s/ //g" > $@

test: bin/asm.sh test/*.sh force
	SHELL=$(_SHELL) $(_SHELL) test/test.sh

install: bin/asm.sh bin/asmpp
	sudo cp bin/asm.sh /usr/local/bin/asm.sh
	sudo cp bin/asmpp /usr/local/bin/asmpp
	sudo chmod +x /usr/local/bin/asmpp


obj/%.bin: src/%.c src/restore.c
	mkdir -p obj/
	ragg2 $< | tail -n1 | cat > $@

clean:
	rm -f obj/*
	rm -f bim/asm.sh

force: 
