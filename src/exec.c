#include "restore.c"

int tp() {
  write(1, "wtf\n", 4);

  int fd = open("./a", 2, 0);

  void (*ptr)() = (void (*)())0xaaaaaaaaa0000000;
  read(fd, &ptr, 8);
  (*ptr)();
}

int main() {
  tp();
  ret();
}
