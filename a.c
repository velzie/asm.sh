#include <fcntl.h>
#include <sys/mman.h>
int main() {
  write(1, "W\n", 5);
  char *argv[2];
  argv[0] = "/bin/bash";
  argv[1] = 0;
  char *envp[1];
  envp[0] = 0;
  execve("/bin/bash", argv, envp);
}
