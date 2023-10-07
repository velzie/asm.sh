// ghetto libc from the hood
void memcpy(void *dest, void *src, unsigned long n) {
  char *csrc = (char *)src;
  char *cdest = (char *)dest;

  for (int i = 0; i < n; i++)
    cdest[i] = csrc[i];
}

void itoa(unsigned long n, char s[]) {
  int i, sign;

  if ((sign = n) < 0) /* record sign */
    n = -n;           /* make n positive */
  i = 0;
  do {                     /* generate digits in reverse order */
    s[i++] = n % 10 + '0'; /* get next digit */
  } while ((n /= 10) > 0); /* delete it */
  if (sign < 0)
    s[i++] = '-';
  s[i] = '\0';
}

void writify(void *addr) {
  mprotect((void *)(((unsigned long)addr & ~(4096 - 1))), 4096,
           0x1 | 0x2 | 0x4);
}

int ret() {

  // it crashes if i don't do this
  // i have no idea why
  asm volatile("nop");
  asm volatile("nop");
  asm volatile("nop");
  asm volatile("nop");
  asm volatile("nop");
  asm volatile("nop");
  asm volatile("nop");
  asm volatile("nop");

  // write(1, "<function called from inline assembly>\n", 39);

  void **_start = (void *)0xcccccccccccccccc;

  int fd = open("/tmp/x", 0, 0);
  void *addr = (void *)0xffffffffffff;

  // char buf[24];
  writify(addr);
  // read(fd, addr, 20);

  const char *a = "placetoputtheoriginalshhh";
  // write(1, a, 24);

  memcpy(addr, a, 25);
}
