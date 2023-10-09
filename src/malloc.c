#include "restore.c"
#include "sftypes/sftypes.h"

int main() {
  void **_start = (void *)0xcccccccccccccccc;

  int size = 0xaaaaaaaa;

  void *addr = mmap(0, size, 7, 34, -1, 0);

  writify(_start);
  *_start = addr;

  ret();
}
