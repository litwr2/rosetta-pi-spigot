;for vasm assembler
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

;So r[0] is never used.  The program for 680x0 uses r[0] and doesn't use r[N] - so it optimizes the memory usage by 2 bytes

;litwr has written this for 680x0
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped a lot
;a/b helped to optimize the 68000 code

     mc68000
     ;mc68030

timer = $4ba

MULUopt = 0   ;1 is much slower for 68000, for 68020 it is the same for FS-UAE and maybe a bit faster with the real iron
IO = 1

D = 1000
N = 7*D/2 ;D digits, e.g., N = 350 for 100 digits

div32x16 macro    ;D7=D6/D4, D6=D6%D4
     moveq.l #0,d7
     divu d4,d6
     bvc .div32no\@

     swap d6
     move d6,d7
     divu d4,d7
     swap d7
     move d7,d6
     swap d6
     divu d4,d6
.div32no\@
     move d6,d7
     clr d6
     swap d6
endm

start    move.l #msg1,-(sp)
         move #9,-(sp)    ;print line
         trap #1
         addq.l #6,sp

         move.l #start+$10000-ra,d4
         divu #7,d4
         ext.l d4
         and.b #$fc,d4
         move d4,d5
         bsr PR0000
         move.l #msg5,-(sp)
         move #9,-(sp)    ;print line
         trap #1
         addq.l #6,sp
         bsr getnum
         ;move.l #D,d5

         move d5,d1
         addq #3,d5
         and #$fffc,d5
         cmp d1,d5
         beq .l7

         move d5,a4
         bsr PR0000
         move a4,d5
         move.l #msg3,-(sp)
         move #9,-(sp)    ;print line
         trap #1
         addq.l #6,sp
.l7      lsr d5
         mulu #7,d5
         movea.l d5,a4

         clr.l -(sp)
	     move #32,-(sp)    ;super
	     trap #1
	     addq.l #6,sp
	     move.l d0,ssp
         move.l timer,time

         move.l a4,d2
         lsr #1,d2
         subq #1,d2
         move.l #2000*65537,d0
         move.l #ra,a0
.fill    move.l d0,(a0)+
         dbra d2,.fill

         clr cv
         move a4,kv

.l0      clr.l d5       ;d <- 0
         clr.l d4
         move kv(pc),d4
         add.l d4,d4     ;i <-k*2
         lea.l ra(pc),a3
         adda.l d4,a3
         subq.l #1,d4     ;b <- 2*i-1
  ifeq MULUopt
         move #10000,d1   ;removed with MULU optimization
  endif
         bra .l4

.longdiv
  if __VASM&28              ;68030?
         divul d4,d7:d6
         move d7,(a3)     ;r[i] <- d%b
  else
         moveq.l #0,d7
         swap d6
         move d6,d7
         divu d4,d7
         swap d7
         move d7,d6
         swap d6
         divu d4,d6
         move d6,d7
         clr d6
         swap d6
         move d6,(a3)
  endif
         bra.s .enddiv

.l2      sub.l d6,d5
         sub.l d7,d5
         lsr.l d5
.l4
  if MULUopt
         moveq.l #0,d0  ;MULU optimization
  endif
         move -(a3),d0      ; r[i]
  if MULUopt
         move.l d0,d1   ;MULU optimization
         lsl.l #3,d0
         sub.l d0,d1
         add.l d0,d0
         sub.l d0,d1
         sub.l d0,d1
         lsl.l #8,d1
         sub.l d1,d0
  else
         mulu d1,d0       ;r[i]*10000, removed with MULU optimization
  endif
         add.l d0,d5       ;d += d + r[i]*10000
         move.l d5,d6
         divu d4,d6
         bvs.s .longdiv

         moveq.l #0,d7
         move d6,d7
         clr d6
         swap d6
         move d6,(a3)     ;r[i] <- d%b
.enddiv
         subq #2,d4    ;i <- i - 1
         bcc .l2       ;the main loop
  if MULUopt
         divu #10000,d5  ;MULU optimization
  else
         divu d1,d5      ;removed with MULU optimization
  endif
  if IO
         add cv(pc),d5    ;c + d/10000
         swap d5      ;c <- d%10000
         move d5,cv
         clr d5
         swap d5
         bsr PR0000
  endif
         sub.w #14,kv
         bne .l0

         move.l timer,d5
         move.l	ssp,-(sp)
         move.w	#32,-(sp)     ;super
	     trap #1
	     addq.l #6,sp

         move   #' ',-(sp)
         move  #2,-(sp)    ;conout
         trap #1
         addq.l #4,sp

         sub.l time,d5
         lsr.l d5        ;200 MHz

.l8      lea string(pc),a3
         move #10,d4
         move.l d5,d6
         div32x16
         move.b d6,(a3)+
         divu d4,d7
         swap d7
         move.b d7,(a3)+
         clr d7
         swap d7
         move.b #'.'-'0',(a3)+
.l12     tst d7
         beq .l11

         divu d4,d7
         swap d7
         move.b d7,(a3)+
         clr d7
         swap d7
         bra .l12

.l11     move #'0',d0
         add.b -(a3),d0
         move d0,-(sp)
         move #2,-(sp)    ;conout
         trap #1
         addq.l #4,sp
         cmp.l #string,a3
         bne .l11

         move   #13,-(sp)
         move  #2,-(sp)    ;conout
         trap #1
         move   #10,-(sp)
         move  #2,-(sp)    ;conout
         trap #1
         addq.l #8,sp

         move #7,-(sp)    ;conin without echo
         trap #1          ;wait a key
         addq.l #2,sp

         move #0,-(sp)     ;term
         trap #1

PR0000     ;prints d5
       lea string(pc),a0
       ;movea.l a0,-(sp)
       bsr .l1
       move.l #string,-(sp)
       move   #9,-(sp)    ;print line
       trap   #1
       addq.l #6,sp
       rts

.l1    divu #1000,d5
       bsr .l0
       clr d5
       swap d5

       divu #100,d5
       bsr .l0
       clr d5
       swap d5

       divu #10,d5
       bsr .l0
       swap d5

.l0    eori.b #'0',d5
       move.b d5,(a0)+
       rts

cv  dc.w 0
kv  dc.w 0
time dc.l 0
ssp dc.l 0

string dc.b 0,0,0,0,0
      even
ra

getnum  clr.l d7    ;length
        clr.l d5    ;number
.l0:    move #7,-(sp)    ;conin without echo
        trap #1
        addq.l #2,sp
        tst.b d0
        beq .l0

        cmpi.b #13,d0   ;cr
        beq .l5

        cmpi.b #8,d0    ;bs
        beq .l1

        cmpi.b #'0',d0   ;'0'
        bcs .l0

        cmpi.b #'9',d0   ;'9'
        bhi .l0

        cmpi.b #4,d7
        beq .l0

        move d0,d3
        move d0,-(sp)
        move #2,-(sp)    ;conout
        trap #1
        addq.l #4,sp
        move d5,-(sp)
        addq.l #1,d7
        sub #'0',d3
        mulu #10,d5
        add d3,d5 
        jmp .l0

.l1     tst d7
        beq .l0

        subq.l #1,d7
        move.l #del,-(sp)
        move #9,-(sp)    ;print line
        trap #1
        addq.l #6,sp
        move (sp)+,d5
        bra .l0

.l5     tst d7
        beq .l0

        cmp d4,d5    ;maxn = D4
        bhi .l0

        tst d5
        beq .l0

        move.l #msg2,-(sp)
        move #9,-(sp)    ;print line
        trap #1
        addq.l #6,sp

        lsl #1,d7
        add.l d7,sp
        rts

msg1  dc.b 27,'vnumber pi calculator v5 '
  if __VASM&28              ;68030?
      dc.b '(68030)'
  else
      dc.b '(68000)'
  endif
     dc.b 13,10,'number of digits (up to ',0
msg5 dc.b ')? ',0
del  dc.b 8,32,8,0
msg3  dc.b ' digits will be printed'
msg2  dc.b 13,10,0
      end     start

