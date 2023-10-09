#ifndef RET_H
#define RET_H
#include "lib.c"
void writify(void *addr) {
  mprotect((void *)(((unsigned long)addr & ~(4096 - 1))), 4096,
           0x1 | 0x2 | 0x4);
}

int ret() {

  void **_start = (void *)0xcccccccccccccccc;

  // it crashes if i don't do this
  // i have no idea why
  int fd = open("/", 0, 0);

  void *addr = (void *)0xffffffffffff;

  writify(addr);

  const char *a = "placetoputtheoriginalshhh";

  memcpy(addr, a, 25);
}
#endif
