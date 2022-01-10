;for vasm assembler, oldstyle syntax
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

;the fast 32/16-bit division was made by blackmirror/ivagor for z80
;litwr converted it to the 6801 and 6809
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped too

DIV8OPT equ 0      ;1 is slower for 1000 and more digits
OPT equ 5          ;5 is a constant for the pi-spigot
DIVNOMINUS equ 1   ;1 limits to 4704 digits, this may slightly shrink size and increase speed
IO equ 0

DIGI equ 100
N equ DIGI/2*7

OPCHR equ $f9c6    ;print char in AC

         org $4e00 + DIV8OPT*$400 + !DIVNOMINUS*$280
 
divisor = $ba  ;$bb
neg_divisor = $bc ;$bd
dividend = $be  ;..$c1
remainder = $c2 ;$c3
quotient = dividend ;save memory by reusing divident to store the quotient
dv = $c4  ;..$c7
k = $d6  ;$d7
c = $d8  ;$d9
t1 = $da  ;$db
tx = $dc  ;$dd
timer = $de  ;$df
     
      sei        ;init timer  ;@start@ of the execution
      ldd #0
      std <timer  ;@timer@
      lda #$7e   ;opcode JMP ext
      staa $4203
      ldd #tofirq
      std $4204
      lda #4
      staa <8
      lda <8
      lda <9
      cli

         ldd #N    ;fill r-array @N@
         asld
         std <k
         addd #r+2 ;@EOP@
         std m1+1
         ldx #r+2
         ldd #2000
lf0      std 0,x
         inx
         inx         
m1       cmpx #0
         bne lf0

         ldx #0
         stx <c   ;non direct mem may be used
loop     ldx #0
         stx <dv    ;d <- 0
         stx <dv+2

         ldd <k          ;i <- 2k
         std <t1
         addd #r
         std <tx
         ldx <tx
loop2    lda #10000%256   ;low(10000)
         ldb 1,x
         mul
         addd <dv+2
         std <dv+2
         stab <dividend+3
         bcc ll1

         inc dv+1
         bne ll1

         inc dv
ll1      lda #10000/256  ;high(10000)
         ldb 0,x
         mul
         addd <dv
         std <dv
         staa <dividend
         lda #10000%256
         ldb 0,x
         mul
         addd <dv+1
         std <dv+1
         bcc ll2

         inc dv
         inc dividend
ll2      lda #10000/256
         ldb 1,x
         mul
         addd <dv+1
         std <dv+1
         std <dividend+1
         bcc ll3

         inc dv
         inc dividend
ll3      ldd <t1
         subd #1           ;b <- b - 1
         std <divisor

       include "6803-div6.s"

         ;ldd <remainder
         std 0,x
         ldd <t1
         subd #2
         std <t1      ;i <- i - 1
         beq l4

         ldd <dv+2   ;d <- (d - r[i] - new_d)/2 = d*i
         ;subd <remainder
         subd 0,x
         dex
         dex
         bcc tl1

         staa >tl2+1
         lda <dv+1
         suba #1
         staa <dv+1
         bcc tl2

         lda <dv
         suba #1
         staa <dv
tl2      lda #0
tl1      sbcb <quotient+3
         sbca <quotient+2
         std <dv+2
         ldd <dv
         sbcb <quotient+1
         sbca <quotient
         lsrd
         std <dv
         ror dv+2
         ror dv+3
         jmp loop2

l4       ldd #10000
         std <divisor
         ldd <dividend    ;dividend = quotient
         bsr div32x16w    ;c + d/10000
         ldd <quotient+2
         addd <c
    if IO
         bsr pr0000
    endif
         ldd <remainder
         std <c             ;c <- d%10000
l8       ldd <k      ;k <- k - 14*2
         subd #28
         beq exit

         std <k
         jmp loop

exit     lda #$3b   ;RTI opcode, stop timer
         staa $4203
         lda #0
         staa <8
         rts

pr0000   ;prints D, uses dv,X
         std <dv+2
     ;ldx #10000
     ;bsr pr0
         ldx #1000
     ;bsr pr1
         bsr pr0
         ldx #100
         bsr pr1
         ldx #10
         bsr pr1
         ldx <dv+2
prd      stx <dv
         lda <dv+1
         eora #$30
         jmp OPCHR    ;@OUT@

pr1      ldd <dv+2
pr0      stx <dv
         ldx #$ffff
prn      inx
         subd <dv
         bcc prn

         addd <dv
         std <dv+2
         bra prd

tofirq
      ldd <timer
      addd #1
      std <timer
      lda <8
      lda <9
      rti

       include "6803-div7.s"
   if DIV8OPT
       include "6803-div8.s"
   endif

r = *-2

