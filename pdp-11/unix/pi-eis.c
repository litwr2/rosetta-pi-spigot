/for PDP-11 Unix 7 as
/it calculates pi-number using the next C-algorithm
/https://crypto.stanford.edu/pbc/notes/pi/code.html
/#include <stdio.h>
/#define N 2800
/main() {
/   long r[N + 1], i, k, b, c;
/   c = 0;
/   for (i = 1; i <= N; i++)   ;it is a fixed line, the original was (i = 0; i < N; ...
/      r[i] = 2000;
/   for (k = N; k > 0; k -= 14) {
/      d = 0;
/      i = k;
/      for(;;) {
/         d += r[i]*10000;
/         b = i*2 - 1;
/         r[i] = d%b;
/         d /= b;
/         i--;
/         if (i == 0) break;
/         d *= i;
/      }
/      printf("%.4d", (int)(c + d/10000));
/      c = d%10000;
/   }
/}

/the time of the calculation is quadratic, so if T is time to calculate N digits
/then 4*T is required to calculate 2*N digits
/main loop count is 7*(4+D)*D/16, D - number of digits

/litwr has written this for PDP-11/Unix
/bqt has made an adaptation for 2.11BSD and helped much with optimization
/tricky provided some help
/MMS gave some support
/Thorham and meynaf helped a lot

/#define BSD
#define IO
#define DIVOF

#ifdef BSD
.globl _pistart, _ra, _N, _ver, csv, _write
#else
.globl _pistart, _ra, _N, _ver
#endif

kv = kvs + 2

_pistart:
#ifdef BSD
         jsr r5,csv
#endif
         mov r5,-(sp)  /this is required for Unix system 7
         tst -(sp)       /create a location for temp
/piemu start
         mov *$_N,r0
         mov r0,*$kv
         mov *$_ra,r2
         dec r2
         mov r2,*$m6+2
         dec r2
         mov r2,*$m5+2
         inc r2
         inc r2
         mov $2000.,r1     /fill r-array
m1:      mov r1,(r2)+
         sob r0,m1

         ;clr *$cv
mloop:   clr r5       /d <- 0
         clr r0
kvs:     mov $0,r1
         asl r1       /i <- 2k
         br m4

m77:     add r3,r2       /d <- d/b*i
         adc r4
         sub r2,r5
         sbc r0
         sub r4,r0
         ror r0
         ror r5
m4:      mov $10000.,r2   /unsigned *10000
m5:      mul 2(r1),r2   /the result in r2 - high, r3 - low
         bpl m202

         add $10000.,r2
m202:    add r3,r5
         mov r5,r3
         adc r2
         add r0,r2   /sets CF=0
         mov r2,r0
         dec r1          /b <- 2*i-1, CF=0 for EIS!

     /tst r1            /R4:R2 = R2:R3/R1, R3 = R2:R3%R1, R1 must be odd
     bmi divm           /for R1 > 0x7fff

#ifndef DIVOF
     asl r3
     rol r2
     cmp r2,r1
     bcc div32b

     asr r2
     ror r3
#endif
     div r1,r2   /r2(hi):r3(lo)/r1 -> r2 - quotient, r3 - remainder
#ifdef DIVOF
     bvs div32b
#endif

     clr r4
exitdiv:
m6:      mov r3,1(r1)      /r[i] <- d%b
         sob r1,m77

#ifdef IO
         mov r2,r3
         mov r4,r2
         div $10000.,r2
         add *$cv,r2  /c + d/10000
         mov r3,*$cv     /c <- d%10000
         jsr pc,*$PR0000
#ifdef BSD
	 mov $4,-(sp)
	 mov $buf4,-(sp)
	 mov $1,-(sp)
	 jsr pc,*$_write
	 add $6,sp
#else
         mov $1,r0
         sys 4;buf4;4    /write=4
#endif
#endif
         sub $14.,*$kv      /k <- k - 14
         bne mloop
/piemu end
         tst (sp)+       /release the location for temp
         mov (sp)+,r5
         rts pc
/piemu start
divm:
     /clc          /check CF = 0!
     ror r1
     mov r2,r4
     asl r4
     inc r4     /this is actually required
     cmp r4,r1
     bcc div32n

     div r1,r2
     clr r4
     ror r2
     bcc l1

     add r1,r3
l1:  asl r1
     inc r1
     sub r2,r3
     bcc exitdiv

     dec r2
     add r1,r3
     br exitdiv

div32n:
     clr r4
     ror r2
     ror r3
     rol r4   /save CF
     div r1,r2
     asl r2
     asl r3
     add r4,r3
     cmp r3,r1
     bcs l2

     inc r2
     sub r1,r3
l2:  clr r4
     ror r2
     bcc l1x

     add r1,r3
l1x: asl r1
     inc r1
     sub r2,r3
     bcc exitdiv

     dec r2
     add r1,r3
     br exitdiv

div32b:
#ifdef DIVOF
     asl r3
     rol r2
#endif
     mov r0,*sp
     mov r3,r0
     mov r2,r3
     clr r2
     div r1,r2
     mov r2,r4
     mov r3,r2
     mov r0,r3
     asr r2
     ror r3
     div r1,r2
     clr r0
     asr r4
     ror r0
     add r0,r2
     adc r4
     mov *sp,r0
     br exitdiv

PR0000: mov $buf4,r1
        mov $1000.,r3   /prints r2
	jsr pc,*$PRZ
        mov $100.,r3
	jsr pc,*$PRZ
        mov $10.,r3
	jsr pc,*$PRZ
	mov r2,r0
PR:	add $48.,r0
  	movb r0,(r1)+
        rts pc

PRZ:	mov $65535.,r0
l0:	inc r0
	cmp r2,r3
	bcs PR

	sub r3,r2
	br l0
/piemu finish
.data   /rather not required
buf4:   .byte 0,0,0,0
cv:     .byte 0,0
_ver:   .byte "1","0","(","E","I","S"
#ifdef DIVOF
	.byte "-","o","f"
#endif
	.byte ")",0

