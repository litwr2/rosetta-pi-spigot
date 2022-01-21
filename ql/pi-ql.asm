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

;So r[0] is never used.  The program for 680x0 uses r[0] and doesn't use r[N] - - does it optimize the memory usage by 2 bytes?

;litwr has written this for 680x0
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped a lot
;a/b, saimo and modrobert helped to optimize the 68000 code

     mc68000
MULUopt = 0   ;1 is much slower for 68000, for 68020 slightly faster with the 68020
IO = 1

;timer = $4ba

D = 100
N = 7*D ;D digits, e.g., we need N = 700 bytes for 100 digits

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

start    ;move.l #N,d1
         move.l d1,d6
         move.l d6,d3   ;kv = d6
         lea.l ra(pc),a3

         lea.l serve_flag(pc),a0
         moveq.l #$1c,d0   ;MT.LPOLL
         move.w d0,(a0)+
         lea.l updtimer(pc),a1
         move.l a1,4(a0)
         clr.l 8(a0)     ;clear timer
         trap #1

         lea.l cv(pc),a4
         clr.w (a4)

         lsr #2,d3
         subq #1,d3
         move.l #2000*65537,d0
         movea.l a3,a0
.fill    move.l d0,(a0)+
         dbra d3,.fill

.l0      clr.l d5       ;d <- 0
         clr.l d7
         move.l d6,d4      ;i <- kv, i <- i*2
         adda.l d4,a3
         subq.l #1,d4     ;b <- 2*i-1
  ifeq MULUopt
         move #10000,d1   ;removed with MULU optimization
  endif
         bra .l4

.longdiv
  if __VASM&28              ;68020/30?
         divul d4,d7:d3
  else
         swap d3
         move d3,d7
         divu d4,d7
         swap d7
         move d7,d3
         swap d3
         divu d4,d3

         move d3,d7
         exg.l d3,d7
         clr d7
         swap d7
  endif
         move d7,(a3)     ;r[i] <- d%b
         bra.s .enddiv

;  if __VASM&28              ;68020/30?
;         align 2      ;it seems that this doesn't accelerate
;  endif

.l2      sub.l d3,d5
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
         move.l d5,d3
         divu d4,d3
         bvs.s .longdiv

         move d3,d7
         clr d3
         swap d3
         move d3,(a3)     ;r[i] <- d%b
.enddiv
         subq #2,d4    ;i <- i - 1
         bcc .l2       ;the main loop
  if MULUopt
         divu #10000,d5  ;MULU optimization
  else
         divu d1,d5      ;removed with MULU optimization
  endif
         add (a4),d5    ;c + d/10000
         swap d5      ;c <- d%10000
         move d5,(a4)
         clr d5
         swap d5
  if IO
         bsr PR0000
  endif
         sub.w #28,d6
         bne .l0


         lea.l serve_flag(pc),a0
         moveq.l #$1d,d0   ;MT.RPOLL
         clr.w (a0)+
         trap #1

         move #0,d0
         rts

PR0000     ;prints d5
       lea string(pc),a0
       movea.l a0,a1
       bsr.s .l1
       moveq #7,d0    ;print line
       moveq #4,d2    ;length
       moveq #0,d3
       move.l d3,a0   ;channel
       trap   #3
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

updtimer
       lea.l timer(pc),a0
       addq.l #1,(a0)
       rts

serve_flag dc.w     0	    ;Set if server is on
serve_link dc.l     0       ;Points to server list
serve_ptr  dc.l     0       ;Points to server code
timer dc.l 0     ;@timer@
cv ds.w 1
string ds.b 4

       ;even
ra
      end     start

