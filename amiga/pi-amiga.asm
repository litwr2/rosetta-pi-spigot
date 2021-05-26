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
;max number of digits is 9400 due to data types used

;So r[0] is never used.  The program for 680x0 uses r[0] and doesn't use r[N] - does it optimize the memory usage by 2 bytes?

;litwr has written this for 680x0
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped a lot
;a/b, saimo, and modrobert helped to optimize the 68k code
;Don_Adan found some useful tricks for the Amiga 

     mc68000
MULUopt = 0   ;1 is much slower for 68000, for 68020 it is the same for FS-UAE and slightly faster with the real 68020
IO = 1

OldOpenLibrary = -408
CloseLibrary = -414
Output = -60
Input = -54
Write = -48
Read = -42
Forbid = -132
Permit = -138
AddIntServer = -168
RemIntServer = -174
VBlankFrequency = 530
INTB_VERTB = 5     ;for vblank interrupt
NT_INTERRUPT = 2   ;node type

;N = 7*D/2 ;D digits, e.g., N = 350 for 100 digits

div32x16 macro    ;D7=D6/D4, D6=D6%D4
     ;clr.l d7
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

KV equr d6

start    lea.l libname(pc),a1         ;open the dos library
         move.l 4,a5
         move.l a5,a6
         jsr OldOpenLibrary(a6)
         move.l d0,a6
         jsr Output(a6)          ;get stdout
         move.l d0,cout
         move.l d0,d1                   ;call Write(stdout,buff,size)
         move.l #msg1,d2
         moveq #msg4-msg1,d3
         jsr Write(a6)
         move.l #start+$10000-ra,d7
         divu #7,d7
         ext.l d7
         and.b #$fc,d7                 ;d7=maxn

.l20     move.l cout(pc),d1
         move.l #msg4,d2
         moveq #msg5-msg4,d3
         jsr Write(a6)
         move.l d7,d5
         bsr PR0000
         move.l cout(pc),d1
         move.l #msg5,d2
         moveq #msg3-msg5,d3
         jsr Write(a6)
         bsr getnum
         cmp d7,d5
         bhi .l20

         move d5,d1
         beq .l20

         addq #3,d5
         and #$fffc,d5
         cmp.b #10,(a0)
         bne .l21

         move d5,d6
         cmp d1,d5
         beq .l7

.l21     bsr PR0000
         move.l cout(pc),d1
         move.l #msg3,d2
         moveq #msg2-msg3+1,d3
         jsr Write(a6)
.l7      mulu #7,d6          ;kv = d6
         move.l d6,d3
         lea.l ra(pc),a3

         exg.l a5,a6
         jsr Forbid(a6)
         moveq.l #INTB_VERTB,d0
         lea.l VBlankServer(pc),a1
         jsr AddIntServer(a6)
         exg.l a5,a6
         ;move.w #$4000,$dff096    ;DMA off

         lsr #2,d3
         subq #1,d3
         move.l #2000*65537,d0
         move.l a3,a0
.fill    move.l d0,(a0)+
         dbra d3,.fill

.l0      clr.l d5       ;d <- 0
         clr.l d7
         move.l d6,d4     ;i <- kv, i <- i*2
         adda.l d4,a3
         subq.l #1,d4     ;b <- 2*i-1
  ifeq MULUopt
         move #10000,d1
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

  if __VASM&28              ;68020/30?
         align 2
  endif
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
         mulu d1,d0       ;r[i]*10000
  endif
         add.l d0,d5       ;d += r[i]*10000
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
  if IO
         add cv(pc),d5    ;c + d/10000
         swap d5      ;c <- d%10000
         move d5,cv
         clr d5
         swap d5
         bsr PR0000
  endif
         sub.w #28,d6   ;kv, this limits to 9360 digits - #14 did not have this limit
         bne .l0

         move.l time(pc),d5
         ;move.w #$c000,$dff096    ;DMA on
         exg.l a5,a6
         moveq.l #INTB_VERTB,d0
         lea.l VBlankServer(pc),a1
         jsr RemIntServer(a6)
         jsr Permit(a6)
         exg.l a5,a6

         moveq.l #1,d3
         move.l cout(pc),d1
         move.l #msgx,d2
         jsr Write(a6)  ;space

         move.l d5,d3
         lsl.l d5
         cmp.b #50,VBlankFrequency(a5)
         beq .l8

         lsl.l d5      ;60 Hz
         add.l d3,d5
         divu #3,d5
         swap d5
         lsr #2,d5
         swap d5
         negx.l d5
         neg.l d5

.l8      lea string(pc),a3
         moveq.l #10,d4
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

.l11     add.b #'0',-(a3)
         moveq #1,d3
         move.l cout(pc),d1
         move.l a3,d2
         jsr Write(a6)
         cmp.l #string,a3
         bne .l11

         move.l cout(pc),d1
         move.l #msgx+1,d2
         jsr Write(a6)  ;newline

         move.l a6,a1
         move.l a5,a6
         jmp CloseLibrary(a6)

PR0000     ;prints d5, uses a0,a1(scratch),d0,d1,d2,d3
       lea.l buf(pc),a0
       move.l a0,d2
       bsr.s .l1
       moveq #4,d3
       move.l cout(pc),d1
       jmp Write(a6)             ;call Write(stdout,buff,size)

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

rasteri      addq.l #1,(a1)
;If you set your interrupt to priority 10 or higher then a0 must point at $dff000 on exit
      moveq #0,d0  ; must set Z flag on exit!
      rts

VBlankServer:
      dc.l  0,0                   ;ln_Succ,ln_Pred
      dc.b  NT_INTERRUPT,0        ;ln_Type,ln_Pri
      dc.l  0                     ;ln_Name
      dc.l  time,rasteri          ;is_Data,is_Code

cv  dc.w 0
time dc.l 0
cout dc.l 0
buf ds.b 4
msgx dc.b 32,10
        align 2
ra
getnum   jsr Input(a6)          ;get stdin
         move.l #string,d2     ;set by previous call
         move.l d0,d1
         moveq.l #5,d3     ;+ newline
         jsr Read(a6)
         subq #1,d0
         beq .err

         move.l d2,a0
         clr.l d5
.l1      clr d6
         move.b (a0)+,d6
         cmpi.b #'9',d6
         bhi .err

         subi.b #'0',d6
         bcs .err

         add d6,d5
         subq #1,d0
         beq .eos

         mulu #10,d5
         bra .l1

.err     clr d5
.eos     rts

string = msg1
libname  dc.b "dos.library",0
msg1  dc.b 'number pi calculator v12 [Beta 3]'
  if __VASM&28              ;68020/30?
      dc.b '(68020)'
  else
      dc.b '(68000)'
  endif
  dc.b 10
msg4 dc.b 'number of digits (up to '
msg5 dc.b ')? '
msg3 dc.b ' digits will be printed'
msg2 dc.b 10
     dcb.b 65536-(ra-start)
     end start

