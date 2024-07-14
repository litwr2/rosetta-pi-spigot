#include <stdio.h>
#define MAXSZ 2200
char* transf(unsigned char c) {
   static char s[200];
   int hi = c >> 4, lo = c & 15;
   sprintf(s, "%c%c", hi + 65, lo + 65);
   return s;
}
int main() {
   unsigned char b[MAXSZ];
   int n, i;
   const int L = 40;
   n = fread(b, 1, MAXSZ, stdin);
   for (i = 0; i < n; i++) {
      if (i%L == 0) {
          if (i != 0) puts("");
          printf("%d DATA %s", i + 1000, transf(b[i]));
      }
      else
          printf("%s", transf(b[i]));
   }
   //for (n = i; n%L != 0; n++) printf("AA");
   puts("");
   return 0;
}
