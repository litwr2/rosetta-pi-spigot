#include <stdio.h>
#include <sys/types.h>
#include <sys/timeb.h>
struct timeb tps, tpf;
char *ra;
extern char ver;
unsigned digits, max, N;
unsigned getfree() {
    unsigned max = 0, step = 512;
    do {
        while (sbrk(step) != -1)
            max += step;
        step /= 2;
    } while (step > 8);
    return max;
}
main() {
   printf("Number pi calculator v%s\n", &ver);
   ra = sbrk(0);
   max = (getfree()/7)&~3;
   do {
      char s[8], *p;
      do {
         printf("Enter number of digits (up to %d): ", max);
         p = gets(s);
      }
      while (!p || strlen(s) > 4);
      digits = atoi(s);
   } while (digits > max || digits == 0);
   if ((digits & 3) != 0) {
      digits = (digits + 3) & 0xfffc;
      printf("%u digits will be printed\n", digits);
   }
   N = digits/2*7;
   ftime(&tps);
   pistart();
   ftime(&tpf);
   printf(" %.3f\n", ((tpf.time - tps.time)*1000. + tpf.millitm - tps.millitm)/1000.);
}
