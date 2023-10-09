#ifndef LIBC_H
#define LIBC_H
// **************************************
//      Ghetto libc from the hood
//   Has all the functions a libc needs
// **************************************

void memcpy(void *dest, void *src, unsigned long n) {
  char *csrc = (char *)src;
  char *cdest = (char *)dest;

  for (int i = 0; i < n; i++)
    cdest[i] = csrc[i];
}

unsigned long strlen(const char *s) {
  unsigned long i = 0;
  while (s[i] != 0)
    i++;
  return i;
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

#endif
