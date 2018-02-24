#include <stdio.h>
main() {
   signed short b[2000], n, i;
   n = fread(b, 2, 1000, stdin);
   for (i = 0; i < n; i++) {
      if (i%10 == 0)
          printf("\n%d DATA %d", i + 200, b[i]);
      else
          printf(",%d", b[i]);
   }
}

