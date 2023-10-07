#include "restore.c"

int main() {
  void (*ptr)() = (void (*)())0xaaaaaaaaaaaaaaaa;
  (*ptr)();
  ret();
}
