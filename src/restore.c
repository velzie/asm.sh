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

int ret() {
  write(1, "<function called from inline assembly>\n", 39);

  int fd = open("/tmp/x", 0, 0);
  void *addr = (void *)0xffffffffffff;

  char buf[100];
  read(fd, buf, 50);
  int eno = mprotect((void *)(((unsigned long)addr & ~(4096 - 1))), 4096,
                     0x1 | 0x2 | 0x4);

  memcpy(addr, buf, 50);
}
