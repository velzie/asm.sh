#include "page.c"
#include "sftypes/sftypes.h"

int main() {
  unsigned long *page = getpage();

  unsigned long rax = page[0];
  unsigned long rdi = page[1];
  unsigned long rsi = page[2];
  unsigned long rdx = page[3];
  unsigned long r10 = page[4];
  unsigned long r8 = page[5];
  unsigned long r9 = page[6];

  unsigned long ret;
  asm volatile("mov %2, %%rdi\n\t"
               "mov %3, %%rsi\n\t"
               "mov %4, %%rdx\n\t"
               "mov %5, %%r10\n\t"
               "mov %6, %%r8\n\t"
               "mov %7, %%r9\n\t"
               "syscall\n\t"
               : "=a"(ret)
               : "0"(rax), "g"(rdi), "g"(rsi), "g"(rdx), "g"(r10), "g"(r8),
                 "g"(r9));
  *page = ret;
}
