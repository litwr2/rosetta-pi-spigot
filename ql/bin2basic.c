#include <stdio.h>
#define BUFSZ 2000
char* transf(unsigned char c) {
   static char s[200];
   int hi = c >> 4, lo = c & 15;
   sprintf(s, "%c%c", hi + 'A', lo + 'A');
   return s;
}
int main() {
   unsigned char b[BUFSZ];
   int n, i;
   const int L = 40;
   n = fread(b, 1, BUFSZ, stdin);
   for (i = 0; i < n; i++) {
      if (i%L == 0) {
          if (i != 0) puts("\"");
          printf("%d data \"%s", i + 1000, transf(b[i]));
      }
      else
          printf("%s", transf(b[i]));
   }
   puts("z\"");
   return 0;
}
