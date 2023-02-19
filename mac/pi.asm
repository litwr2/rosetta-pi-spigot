;for MPW assembler
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

;So r[0] is never used.  The program for the 680x0 uses r[0] and doesn't use r[N] - does it optimize the memory usage by 2 bytes?

;litwr has written this for the 680x0
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped a lot
;a/b, saimo, and modrobert helped to optimize the 68k code

MULUopt equ 0   ;1 is much slower for the 68000
                ;for the 68020, it is slightly faster with the real 68020/30
IO equ 1
M68020 equ 0
DynaMem equ 1

   if M68020 then
       machine mc68020
   endif
   if DynaMem = 0 then
maxsz equ 32760  ;it is the MPW linker limit
   endif

     macro
     div32x16  ;D7=D6/D4, D6=D6%D4
     moveq.l #0,d7
     divu d4,d6
     bvc.s @div32no

     swap d6
     move d6,d7
     divu d4,d7
     swap d7
     move d7,d6
     swap d6
     divu d4,d6
@div32no
     move d6,d7
     clr d6
     swap d6
     endm

         INCLUDE 'Traps.a'         ;define Toolbox traps
         INCLUDE 'SysEqu.a'        ;define ScrnBase
         INCLUDE 'QuickEqu.a'

vOff    equ 38
botOff  equ 30

         MAIN
start    PEA -4(A5)
         _InitGraf
         _InitFonts
         _InitWindows
         _InitCursor

         movea.l GrafGlobals(a5),a0
         move.l ScreenBits+bounds+4(a0),d0
         sub.l #botOff*$10000+1,d0
         lea WindowSize(pc),a0
         move.l d0,4(a0)
         clr d0
         swap d0
         sub #vOff,d0
         divu #10,d0
         addq #1,d0
         mulu #10,d0
         lea Ymax(pc),a1
         move d0,(a1)
         SUBQ #4,SP
         CLR.L -(SP)      ;allocate memory on heap
         move.l a0,-(sp)  ;bounding box
         PEA WindowName(pc)
         ST -(SP)      ;-1 - visible
         CLR -(SP)   ;0 - window type
         MOVE.L #-1,-(SP) ;-1 - in front
         SF -(SP)      ;0 - no close box
         CLR.L -(SP)   ;user parameters
         _NewWindow
         lea WindPtr(pc),a6
         move.l (sp),(a6)
         _SetPort
         move #4,-(sp)   ;Monaco font (monospace)
         _TextFont
   if DynaMem then
         bsr setmaxn    ;d4=maxn
         _NewPtr
         tst d0
         bne ExitErr

         movea.l a0,a2
   else
         bsr setmaxn    ;d4=maxn
   endif
         move.l #$a0000,-(sp)
         _MoveTo
         pea msg4
         _DrawString
         lea Yoff(pc),a6
         lea penloc(pc),a4
         move.l a4,-(sp)
         _GetPen
         move.l (a4),(a6)
         clr.l d5
         move d4,d5
         bsr PR0000
         pea msg5
         _DrawString
	 move.l #$170000,(a6)    ;$17 = 23 = initial Yoff

         ;MOVE.L #$FFFF,d0
         ;_FlushEvents
         bsr getnum
         move d5,d1

         addq #3,d5
         and #$fffc,d5
         move d5,d6
         cmp d1,d5
         beq.s l7

         bsr PR0000
         pea msg3
	     _DrawString
         addi #10,(a6)+
	 clr (a6)

l7       mulu #7,d6          ;kv = d6
         move.l d6,d3
    if DynaMem then
         movea.l a2,a3
    else
         lea.l ra(pc),a3
    endif

         lea stime(pc),a6
         move.l Ticks,(a6)

         lsr #2,d3
         subq #1,d3
         move.l #2000*65537,d0
         move.l a3,a0
lfill    move.l d0,(a0)+
         dbra d3,lfill

l0       clr.l d5       ;d <- 0
         clr.l d7
         move.l d6,d4     ;i <- kv, i <- i*2
         adda.l d4,a3
         subq.l #1,d4     ;b <- 2*i-1
  if MULUopt=0 then
         move #10000,d1
  endif
         bra.s l4

longdiv
  if M68020 then
         tdivu d4,d7:d3   ;divul
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
         bra.s enddiv

l2       sub.l d3,d5
         sub.l d7,d5
         lsr.l #1,d5
l4
  if MULUopt then
         moveq.l #0,d0  ;MULU optimization
  endif
         move -(a3),d0      ; r[i]
  if MULUopt then
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
         bvs.s longdiv

         move d3,d7
         clr d3
         swap d3
         move d3,(a3)     ;r[i] <- d%b
enddiv
         subq #2,d4    ;i <- i - 1
         bcc.s l2       ;the main loop
  if MULUopt then
         divu #10000,d5  ;MULU optimization
  else
         divu d1,d5      ;removed with MULU optimization
  endif
		 lea cv(pc),a6
         add (a6),d5    ;c + d/10000
         swap d5      ;c <- d%10000
         move d5,(a6)
         clr d5
         swap d5
		 ;_Debugger
  if IO then
         bsr PR0000
  endif
         sub #28,d6   ;kv, this limits to 9360 digits, #14 did not set this limit here
         bne.s l0

         lea stime(pc),a6
         move.l Ticks,d5
         sub.l (a6),d5
		 
         move.b #32,d1  ;space
         bsr print1
		 
         move.l d5,d3
         lsl.l #2,d5     ;60 Hz
         add.l d3,d5
         divu #3,d5
         swap d5
         lsr #2,d5
         swap d5
         negx.l d5
         neg.l d5

         lea msg4(pc),a3
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
l12      tst d7
         beq.s l11

         divu d4,d7
         swap d7
         move.b d7,(a3)+
         clr d7
         swap d7
         bra.s l12

l11      add.b #'0',-(a3)
         moveq #0,d0
         move.b (a3),d1
		 bsr.s print1
		 lea msg4(pc),a6
         cmpa.l a6,a3
         bne.s l11

         MOVE.L #$FFFF,d0
         _FlushEvents
Wait    _SystemTask
        subq #2,sp
        move #$ffff,-(sp)
		pea EventRecord(pc)
        _GetNextEvent
        btst #0,(sp)+
        beq.s Wait

        move EventRecord(pc),d0
        cmpi #keyDwnEvt,d0
        beq.s @g0

        cmpi #mButDwnEvt,d0
        bne.s Wait
@g0
    if DynaMem then
         movea.l a2,a0
         _DisposPtr
ExitErr
    endif
         _ExitToShell          ;return to Desktop/Shell

PR0000     ;prints d5, uses d1
       ;_SystemTask
       divu #1000,d5
       bsr.s @p0
       clr d5
       swap d5

       divu #100,d5
       bsr.s @p0
       clr d5
       swap d5

       divu #10,d5
       bsr.s @p0
       swap d5

@p0    eori.b #'0',d5
       moveq #0,d1
       move.b d5,d1

print1 move.l Yoff(pc),-(sp)   ;prints D1, uses D0, D1, D2, A6
       _MoveTo
       move d1,-(sp)
       _DrawChar
       clr -(sp)
       move d1,-(sp)
       _CharWidth

       move Yoff(pc),d0
       move Xoff(pc),d1
       add (sp)+,d1
       move WindowSize+6(pc),d2
       subq #8,d2
       cmp d2,d1
       bcs.s @skip

       move #0,d1
       add #10,d0
       move Ymax(pc),d2
       cmp d2,d0
       bcs.s @skip

       move d0,-(sp)
       clr.l -(sp)
       _NewRgn  ;this is an extra for the later OS
       move.l (sp)+,a6
       move.l WindPtr(pc),a0
       pea PortRect(a0)
       move #0,-(sp)
       move #-10,-(sp)
       move.l a6,-(sp)
       _ScrollRect
       move.l a6,-(sp)
       _DisposRgn
       moveq #0,d1
       move (sp)+,d0
       subi #10,d0
@skip  lea.l Yoff(pc),a0
       move d0,(a0)+
       move d1,(a0)
       rts

cv     dc.w 0
stime  dc.l 0
WindPtr    DS.L 1
Yoff       DC.W 23
Xoff       DC.W 0
Ymax       DC.W 0
WindowSize DC.W vOff,1,342-botOff,511
   if DynaMem = 0 then
ra         ds.l 0
   endif
drawund  lea penloc(pc),a4
		 move.l a4,-(sp)
		 _GetPen
         move #'_',-(sp)
         _DrawChar
         move.l (a4),-(sp)
         _MoveTo
         rts

getnum  clr.l d7    ;length
        clr.l d5    ;number
        bsr.s drawund
@g0     _SystemTask
        subq #2,sp
        move #$ffff,-(sp)
		pea EventRecord(pc)
        _GetNextEvent
        btst #0,(sp)+
        beq.s @g0

        move EventRecord(pc),d0
        cmpi #keyDwnEvt,d0
        bne.s @g0

        move.l EventRecord+evtMessage(pc),d0
        cmpi.b #13,d0   ;cr
        beq.s @g5

        cmpi.b #8,d0    ;bs
        beq.s @g1

        cmpi.b #'0',d0   ;'0'
        bcs.s @g0

        cmpi.b #'9',d0   ;'9'
        bhi.s @g0

        cmpi.b #4,d7
        beq.s @g0

        clr d3
        move.b d0,d3
        move.l (a4),d0
        addq #8,d0
        move.l d0,4(a4)
        clr (a4)
        move.l a4,-(sp)
        _EraseRect
        move.l a4,-(sp)
        _GetPen
        move d3,-(sp)
        _DrawChar
        move.l (a4),-(sp)
        bsr.s drawund
        move d5,-(sp)
        addq.l #1,d7
        sub #'0',d3
        mulu #10,d5
        add d3,d5 
        bra.s @g0

@g1     tst d7
        beq.s @g0

        subq.l #1,d7   ;backspace
        move (sp)+,d5
        move.l (sp),d3
        move.l d3,(a4)
        clr (a4)
        addi #16,d3
        move.l d3,4(a4)
        move.l a4,-(sp)
        _EraseRect
        _MoveTo
        bsr drawund
        bra @g0

@g5     tst d7
        beq @g0

        cmp d4,d5    ;maxn = D4
        bhi @g0

        tst d5
        beq @g0

        add d7,d7
        adda.l d7,sp
        adda.l d7,sp
        adda.l d7,sp
        rts

EventRecord ds.b 16
penLoc     ds.l 0
   if M68020 then
WindowName DC.B 'number pi calculator v6 (68020)'
   else
WindowName DC.B 'number pi calculator v6'
   endif
msg4 dc.b 'number of digits (up to '
msg5 dc.b ')? '
msg3 dc.b ' digits will be printed'
   if DynaMem then
setmaxn move #($10000-12-(*-start))/7**$fffc,d4
        move.l #$10000-12-(setmaxn-start),d0
        rts
    else
setmaxn move #(maxsz-(ra-start))/7**$fffc,d4
        rts

     ds.b maxsz-(*-start)
   endif

         END

