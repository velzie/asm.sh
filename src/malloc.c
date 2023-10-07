#include "restore.c"

int main() {
  void *addr = mmap(0, 999, 3, 33, -1, 0);

  char s[16];

  itoa((long)addr, s);

  write(1, s, 16);

  ret();
}
