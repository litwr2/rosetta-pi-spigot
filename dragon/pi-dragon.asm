;for asm6809 assembler
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

;the fast 32/16-bit division was made by Ivagor for z80
;litwr converted it to 6502 and 6809
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped too

DIV8OPT equ 0      ;1 is slower
OPT equ 5          ;it's a constant for the pi-spigot
DIVNOMINUS equ 1   ;limits to 4704 digits, this may shrink size and slightly increase speed

N equ 350    ;100 digits
;N equ 2800   ;800 digits
;N equ 3500   ;1000 digits

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
neg_divisor fcb 0,0
dividend fcb 0,0,0,0
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
         bra prn

;         lda #12    ;clear screen
;         jsr OPCHR   ;check dp=0 and Basic relocation!!!

         lda #dpage/256    ;@start@ of the execution
         tfr a,dp

         clr >$113    ;init timer
         clr >$112

         ldd #N    ;fill r-array @N@
         aslb
         rola
         std <k
         addd #r+2
         std <m1+1
         ldx #r+2
         ldd #2000
lf0      std ,x++
m1       cmpx #0
         bne lf0

         ldu #0    ;U always keeps 0
         stu <c
         stu <timer+1
         clr <timer
loop     stu <dv    ;d <- 0
         stu <dv+2

         ldx <k          ;i <- 2k
         leay r,x    ;@EOP@ - end of program
loop2    lda #10000%256   ;low(10000)
         ldb 1,y
         mul
         addd <dv+2
         std <dv+2
         stb <dividend+3
         bcc ll1

         inc <dv+1
         bne ll1

         inc <dv
ll1      lda #10000/256  ;high(10000)
         ldb ,y
         mul
         addd <dv
         std <dv
         sta <dividend
         lda #10000%256
         ldb ,y
         mul
         addd <dv+1
         std <dv+1
         bcc ll2

         inc <dv
         inc <dividend
ll2      lda #10000/256
         ldb 1,y
         mul
         addd <dv+1
         std <dv+1
         std <dividend+1
         bcc ll3

         inc <dv
         inc <dividend
ll3      tfr x,d
         subd #1           ;b <- b - 1
         std <divisor

       include "6809-div6.s"

         ;ldd <remainder
         std ,y
         leax -2,x         ;i <- i - 1
         beq l4

         ldd <dv+2   ;d <- (d - r[i] - new_d)/2 = d*i
         ;subd <remainder
         subd ,y
         leay -2,y
         bcc tl1

         sta >tl2+1
         lda <dv+1
         suba #1
         sta <dv+1
         bcc tl2

         lda <dv
         suba #1
         sta <dv
tl2      lda #0
tl1      sbcb <quotient+3
         sbca <quotient+2
         std <dv+2
         ldd <dv
         sbcb <quotient+1
         sbca <quotient
         lsra
         rorb
         std <dv
         ror <dv+2
         ror <dv+3
         jmp <loop2

l4       ldd #10000
         std <divisor
         ldd <dividend    ;dividend = quotient
         jsr div32x16w    ;c + d/10000
         ldd <quotient+2
         addd <c
         jsr <pr0000
         ldd <remainder
         std <c             ;c <- d%10000
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
         jmp loop

exit     ldd <timer+1
         std >$112
         tfr u,dp
         rts

       include "6809-div7.s"
   if DIV8OPT
       include "6809-div8.s"
   endif

r equ *-2

