;for asm32 assembler under PanOS
;it calculates pi-number using the next C-algorithm
;https://crypto.stanford.edu/pbc/notes/pi/code.html

;#include <stdio.h>
;#define N 2800
;main() {
;   long r[N + 1], i, k, b, c;
;   c = 0;
;   for (i = 1; i <= N; i++)   ;it is the fixed line!, the original was (i = 0; i < N; ...
;      r[i] = 2000;
;   for (k = N; k > 0; k -= 14) {
;      d = 0;
;      i = k;
;      for(;;) {
;         d += r[i]*10000;
;         b = i*2 - 1;
;         r[i] = d%b;
;         d /= b;
;         i--;
;         if (i == 0) break;
;         d *= i;
;      }
;      printf("%.4d", (int)(c + d/10000));
;      c = d%10000;
;   }
;}

;the time of the calculation is quadratic, so if T is time to calculate N digits
;then 4*T is required to calculate 2*N digits
;main loop count is 7*(4+D)*D/16, D - number of digits

;litwr has written this for 32016
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped too

	ABSORG	32768
        ;RELORG	32768

D       EQU 100   ;digits
;N       EQU 2800  ;800 digits

	 ENTRY
         MOVZWD =D,R1
         ;LSHD =-1,R1
         MULD =7,R1
         MOVW R1,cv
                                    
         MOVD R1,R2       ;fill r-array
         ADDQW =-2,R2
         MOVD =2000+2000*65536,R0
         ADDR @ra,R5
lb0      MOVD R0,0(R5)
         ADDQD =4,R5
         ADDQW =-4,R2
         BCS lb0

         MOVW cv,kv
         MOVW =0,cv

l0       XORD R5,R5          ;d <- 0
         MOVZWD kv,R4       ;i <-k*2
         ADDR @ra,R6
         ADDD R4,R6
         ADDQD =-1,R4       ;b <- 2*i-1
         MOVD =10000,R7
         BR l2

l4       ADDQD =-2,R6
         ADDQD =-2,R4         ;i <- i - 1
         SUBD R1,R5
         SUBD R0,R5
         LSHD =-1,R5
l2       MOVZWD -2(R6),R0    ;r[i]
         MULD R7,R0        ;r[i]*10000
         ADDD R0,R5
         MOVD R5,R0

         XORD R1,R1
         DEID R4,R0         ;R1:R0 is divided by R4, R0 - remainder, R1 - quotient
         MOVW R0,-2(R6)   ;r[i] <- d%b
         CMPQD =1,R4
         BNE l4

         MOVD R5,R0
         XORD R1,R1
         DEID R7,R0
         ADDW cv,R1         ;c + d/10000
         MOVW R0,cv         ;c <- d%10000
         BSR PR0000
         SUBW =28,kv        ;k <- k - 14*2
         CMPQW =0,kv
         BNE l0
                       
         RET 0

PR0000    ;PRINTS R1W
       MOVW R1,PRBUF
       QUOW =1000,R1
       ADDB ='0',R1
       SVC
       DCB 1
       MOVW PRBUF,R1
       REMW =1000,R1
       MOVW R1,PRBUF
       QUOW =100,R1
       ADDB ='0',R1
       SVC
       DCB 1
       MOVW PRBUF,R1
       REMW =100,R1
       MOVB R1,PRBUF
       QUOB =10,R1
       ADDB ='0',R1
       SVC
       DCB 1
       MOVB PRBUF,R1
       REMB =10,R1
       ADDB ='0',R1
       SVC
       DCB 1
       RET 0

;        ALIGN 4
       ;ALLOCB 1
PRBUF   DCW 0
cv  DCW 0
kv  DCW 0
       ;ALLOCB 2
ra  EQU $
       END

