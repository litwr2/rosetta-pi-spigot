#include <stdio.h>
#include <sys/types.h>
#include <sys/timeb.h>
struct timeb tps, tpf;
char s[60], *ra;
extern unsigned ver;
unsigned digits, max = 8000, N;
main() {
   printf("Number pi calculator v%u\n", ver);
l1:
   do {
      do {
         printf("Enter number of digits (up to %d): ", max);
         ra = gets(s);
      }
      while (!ra || strlen(ra) > 4);
      digits = atoi(s);
   }
   while (digits > max || digits == 0);
   if ((digits & 3) != 0) {
      digits = (digits + 3) & 0xfffc;
      printf("%u digits will be printed\n", digits);
   }
   N = digits/2*7;
   if (ra = (char*)malloc(digits*7)) {
      ftime(&tps);
      pistart();
      ftime(&tpf);
      printf(" %.3f\n", ((tpf.time - tps.time)*1000. + tpf.millitm - tps.millitm)/1000.);
      free(ra);
   }
   else {
      fprintf(stderr, "cannot allocate memory, use less digits\n");
      goto l1;
   }
}
