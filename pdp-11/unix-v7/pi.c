#include <stdio.h>
#include <sys/types.h>
#include <sys/timeb.h>
struct timeb tps, tpf;
char *ra;
extern char ver;
unsigned digits, max, N;
unsigned getfree() {
    unsigned new, min = 0, max = 65000;
    char *p;
    while (max - min > 2) {
        new = max/2 + min/2;
        if (p = malloc(new)) {
            free(p);
            min = new;
        } else
            max = new;
    }
    return min + 1;
}
main() {
   printf("Number pi calculator v%s\n", &ver);
l1:
   max = (getfree()/7)&~3;
   do {
      char s[8];
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
