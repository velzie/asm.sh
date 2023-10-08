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

  void **_start = (void *)0xcccccccccccccccc;

  // it crashes if i don't do this
  // i have no idea why
  int fd = open("/", 0, 0);

  void *addr = (void *)0xffffffffffff;

  writify(addr);

  const char *a = "placetoputtheoriginalshhh";

  memcpy(addr, a, 25);
}
