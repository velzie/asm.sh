#include "restore.c"

int main() {
  int size = 0xaaaaaaaa;

  void *addr = mmap(0, 1000, 7, 34, -1, 0);

  // int fd2 = open("./obj/payload.bi", 2, 0);

  // // char b[100];
  // read(fd2, addr, 0x100);
  // write(1, addr, 0x100);
  //
  // // memcpy(addr, b, 100);
  // write(1, "a\n", 2);
  //
  // write(1, &fd2, 2);
  //
  // ((void (*)())addr)();

  char s[16];

  itoa((long)addr, s);

  write(1, s, 16);

  int fd = open("./a", 578, 0777);
  write(fd, &addr, 8);

  write(1, "\n", 1);
  read(fd, &addr, 8);

  itoa((long)addr, s);

  write(1, s, 16);

  ret();
}
