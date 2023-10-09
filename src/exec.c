#include "restore.c"
#include "sftypes/sftypes.h"

int main() {
  void (*ptr)() = (void (*)())0xaaaaaaaaaaaaaaaa;
  (*ptr)();
  ret();
}
