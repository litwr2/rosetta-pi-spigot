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

;litwr had made this port for 6309 based on 6809 port
;thanks to zephyr

OPCHR equ $800C    ;print char in AC

;N equ 350    ;100 digits
;N equ 2800  ;800 digits
N equ 3500    ;1000 digits

         org $2800
         setdp dpage/256
dpage
divisor fcb 0,0
const10000 fcb 10000/256,10000%256
dividend fcb 0,0
remainder fcb 0,0
quotient equ dividend ;save memory by reusing divident to store the quotient
dv fcb 0,0,0,0
i  fcb 0,0
k  fcb 0,0
c  fcb 0,0
timer fcb 0,0,0    ;@timer@

pr0000   ;prints D, uses dv,X
         std <dv+2
         ldd #1000
         std <dv
         jsr <pr0
         ldd #100
         std <dv
         jsr <pr0
         ldd #10
         std <dv
         jsr <pr0
         ldx <dv+2
prd      tfr x,d
         tfr b,a
         eora #$30
         pshs dp
         clrb
         tfr b,dp
         jsr OPCHR    ;@OUT@
         puls dp
         rts

pr0      ldx #$ffff
prn      leax 1,x
         ldd <dv+2
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

         ldy #N    ;fill r-array @N@
         sty <k
         ldx #r+2
         ldd #2000
lf0      std ,x++
         leay -1,y
         bne lf0

         leau ,y    ;U always keeps 0
         stu <c
         stu <timer+1
         clr <timer
loop     stu <dv    ;d <- 0
         stu <dv+2

         ldd <k          ;i <- 2k
         addd <k
         tfr d,x
         leay r,x    ;@EOP@ - end of program
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
         beq l4

         ldd <dv+2         ;d <- (d - r[i] - new_d)/2 = d*i
         subd ,y
         leay -2,y
         std <dv+2
         bcc tl1

         ldd <dv
         subd #1
         std <dv
tl1      ldd <dv+2
         sbcr w,d
         tfr d,w
         ldd <dv
         sbcd <quotient
         lsrd
         std <dv
         rorw
         stw <dv+2
         jmp <loop2

l4       divq <const10000
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
l8       ldd <k      ;k <- k - 14
         subd #14
         beq exit

         std <k
         jmp <loop

exit     ldd <timer+1
         std >$112
         clra
         tfr a,dp
         ldmd #0   ;to emulation mode
         rts

r equ *-2

