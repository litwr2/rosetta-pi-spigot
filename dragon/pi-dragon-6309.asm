;for asm6809 assembler (6309 mode)
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

;litwr had made this port for 6309 based on 6809 port
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped too
;thanks to zephyr

N equ 350    ;100 digits
;N equ 2800  ;800 digits
;N equ 3500    ;1000 digits

  if DRACO
OPCHR equ $800C    ;print char in AC
         org $2800
  else
OPCHR equ $A282    ;print char in AC
         org $2900
  endif
         setdp dpage/256
dpage
divisor fcb 0,0
dividend fcb 0,0
remainder fcb 0,0
quotient equ dividend ;save memory by reusing divident to store the quotient
dv fcb 0,0,0,0
k  fcb 0,0
c  fcb 0,0
timer fcb 0,0,0    ;@timer@

pr0000   ;prints D, uses dv,X
         std <dv+2
         ldx #1000
         jsr <pr0
         ldx #100
         jsr <pr1
         ldx #10
         jsr <pr1
         ldx <dv+2
prd      tfr x,d
         tfr b,a
         eora #$30
         exg dp,u
         jsr OPCHR    ;@OUT@
         exg dp,u
         rts

pr1      ldd <dv+2
pr0      stx <dv
         ldx #$ffff
prn      leax 1,x
         cmpd <dv
         bcs prd

         subd <dv
         std <dv+2
         jmp <prn

         lda #dpage/256    ;@start@ of the execution
         tfr a,dp
         ldmd #1     ;to native mode

         clr >$113    ;init timer
         clr >$112

         ldd #N    ;fill r-array @N@
         tfr d,w
         asld
         std <k
         ldx #r+2
         ldd #2000
lf0      std ,x++
         decw
         bne lf0

         tfr w,u    ;U always keeps 0
         stu <c
         stu <timer+1
         clr <timer
loop     stu <dv    ;d <- 0
         stu <dv+2

         ldx <k          ;i <- 2k
         leay r,x    ;@EOP@ - end of program
         jmp <loop2

l4       ldd <dv+2         ;d <- (d - r[i] - new_d)/2 = d*i
         subd ,y
         leay -2,y
         bcc tl1

         sta <tl2+1
         lda <dv+1
         suba #1
         sta <dv+1
         bcc tl2

         lda <dv
         suba #1
         sta <dv
tl2      lda #0
tl1      sbcr w,d
         tfr d,w
         ldd <dv
         sbcd <quotient
         lsrd
         std <dv
         rorw
         stw <dv+2
loop2    leax -1,x           ;b <- b - 1
         stx <divisor
         ldd ,y
         muld #10000
         addw <dv+2
         stw <dv+2
         adcd <dv
         std <dv
         cmpr x,d
         bcs div32

         tfr d,w
         clrd
         divq <divisor       ;signed division limits to 4704 digits
         stw <quotient
         ldw <dv+2
         jmp <exitdiv

div32    stu <quotient
exitdiv  divq <divisor
         std ,y
         leax -1,x         ;i <- i - 1
         bne l4

         ldd <quotient
         divq #10000
         addw <c          ;c + d/10000
         std <c           ;c <- d%10000
         tfr w,d
         jsr <pr0000
         ldd >$112
         stu >$112
         addd <timer+1
         std <timer+1
         bcc l8

         inc timer
l8       ldd <k      ;k <- k - 14*2
         subd #28
         beq exit

         std <k
         jmp <loop

exit     ldd <timer+1
         std >$112
         tfr 0,dp
         ldmd #0   ;to emulation mode
         rts

r equ *-2

