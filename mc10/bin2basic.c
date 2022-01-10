#include <stdio.h>
#define BUFSZ 2000
char* transf(unsigned char c) {
   static char s[200];
   int hi = c >> 4, lo = c & 15;
   sprintf(s, "%c%c", hi + 'a', lo + 'a');
   return s;
}
int main() {
   unsigned char b[BUFSZ];
   int n, i;
   const int L = 40;
   n = fread(b, 1, BUFSZ, stdin);
//   puts("10 reada$:l=len(a$):i=1");
//   puts("20 ifi>=lgoto40");
//   puts("30 poke(i+s)/2+20480,asc(mid$(a$,i,1))*16-1105+asc(mid$(a$,i+1,1)):i=i+2:goto20");
//   puts("40 s=s+l:ifl<>80goto60");
//   puts("50 goto10");
//   printf("60 ifs<>%dthenprint\"err\":end\n", n*2 + 1);
   for (i = 0; i < n; i++) {
      if (i%L == 0) {
          if (i != 0) puts("");
          printf("%d data %s", i + 1000, transf(b[i]));
      }
      else
          printf("%s", transf(b[i]));
   }
   puts("z");
   return 0;
}
