#include <stdio.h>
char* transf(unsigned char c) {
   static char s[200];
   int hi = c >> 4, lo = c & 15;
   sprintf(s, "%c%c", hi + 48, lo + 48);
   return s;
}
int main() {
   unsigned char b[2000];
   int n, i;
   const int L = 40;
   n = fread(b, 1, 2000, stdin);
   for (i = 0; i < n; i++) {
      if (i%L == 0) {
          if (i != 0) printf("\"\n");
          printf("%d DATA \"%s", i + 200, transf(b[i]));
      }
      else
          printf("%s", transf(b[i]));
   }
   for (n = i; n%L != 0; n++) printf("00");
   printf("\"\n");
   return 0;
}
