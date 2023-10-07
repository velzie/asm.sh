#include <fcntl.h>
#include <sys/mman.h>
int main() {
  int fd = open("./a", 2, 0);

  void (*ptr)() = (void (*)())0xaaaaaaaaa0000000;
  read(fd, &ptr, 8);

  printf("%p", ptr);
  printf("%i", O_RDWR);
}
