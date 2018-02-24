#for VAX Unix as
#it calculates pi-number using the next C-algorithm
#https://crypto.stanford.edu/pbc/notes/pi/code.html
##include <stdio.h>
##define N 2800
#main() {
#   long r[N + 1], i, k, b, c;
#   c = 0;
#   for (i = 1; i <= N; i++)   ;it is the fixed line!, the original was (i = 0; i < N; ...
#      r[i] = 2000;
#   for (k = N; k > 0; k -= 14) {
#      d = 0;
#      i = k;
#      for(;;) {
#         d += r[i]*10000;
#         b = i*2 - 1;
#         r[i] = d%b;
#         d /= b;
#         i--;
#         if (i == 0) break;
#         d *= i;
#      }
#      printf("%.4d", (int)(c + d/10000));
#      c = d%10000;
#   }
#}

#the time of the calculation is quadratic, so if T is time to calculate N digits
#then 4*T is required to calculate 2*N digits
#main loop count is 7*(4+D)*D/16, D - number of digits

#litwr has written this for VAX/Unix
#tricky provided some help
#MMS gave some support
#Thorham and meynaf helped a lot

#.set useEDIV,1            #use EDIV or DIVL and MULL

        .data
PRBUF:  .word 0,0
cv: .word 0

        .text
        .align  1    #?
        .globl  _ra
        .globl  _pistart
        .globl  _N

_pistart:
        .word   0

         movl _N,r7
         movl *$_ra,r9
         ashl $-1,r7,r0  #fill r-array
         movl $65537*2000,r1
         movl r9,r2
LL1:     movl r1,(r2)+
         sobgtr r0,LL1

         #clrw cv
         clrl r6         #high dword for ediv dividend
         movl $10000,r8
mloop:   clrl r5          #d <- 0
         addl3 r7,r7,r1   #i <- 2k
         addl3 r9,r1,r10
         brb LL4

LL77:    addl2 r3,r2       #d <- d/b*i
         subl2 r2,r5
         ashl $-1,r5,r5
LL4:     movzwl -(r10),r2
         mull2 r8,r2      #r[i]*10000
         addl2 r2,r5
         decl r1          #b <- 2*i-1
#   .if useEDIV
         ediv r1,r5,r2,r3
#   .endif
#   .if !useEDIV
#         divl3 r1,r5,r2
#         mull3 r1,r2,r3
#         subl3 r3,r5,r3
#   .endif
         movw r3,(r10)    #r[i] <- d%b
         decl r1            #i <- i - 1
         bneq LL77

         ediv r8,r5,r2,r3
         addw2 cv,r2    #c + d/10000
         movw r3,cv     #c <- d%10000
         bsbb PR0000
         subl2 $14,r7      #k <- k - 14
         bneq mloop
         ret

PR0000:   #prints R2
        movl $PRBUF,r4
        bsbb PRX
        pushl   $4
        pushl   $PRBUF
        pushl   $1
        calls   $3,_write
        rsb

PRX:    movw $1000,r3
	bsbb PRZ
        movw $100,r3
	bsbb PRZ
        movw $10,r3
	bsbb PRZ
	movb r2,r0
PR:	addb3 $48,r0,(r4)+
   	rsb

PRZ:	movb $255,r0
LL4P:	incb r0
	cmpw r2,r3
	bcs PR

	subw2 r3,r2
	brb LL4P

        .data

