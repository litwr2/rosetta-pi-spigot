;for TMPX assembler
;it calculates pi-number using the next C-algorithm
;https://crypto.stanford.edu/pbc/notes/pi/code.html

;#include <stdio.h>
;#define N 2800
;main() {
;   long r[N + 1], i, k, b, c;
;   c = 0;
;   for (i = 0; i < N; i++)
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

;INT2STR = $BDCD  ;print unsigned integer in AC:XR
BSOUT = $FFD2    ;print char in AC

N = 350   ;100 digits
;N = 2800  ;800 digits
b = $8e   ;$8f
d = $61   ;..$64
i = $65   ;$66
k = $8c   ;$8d

divisor = $19     ;$1a, $1b..$1c used for hi-byte
dividend = $1d	  ;..$1e used for hi-bytes
remainder = $41   ;..$42 used for hi-byte
quotient = dividend ;save memory by reusing divident to store the quotient
product = divisor
fac1 = dividend
fac2 = remainder

         .include "scpu.mac"
         * = $801
         .include "pi-scpu64.inc"

         * = $a50
         .block
         lda #$36 ;@start@
         sta 1    ;disable Basic ROM, add 12KB to RAM
         ;lda #$b
         ;sta $d011   ;screen @blank@
         ;sei         ;no interrupts
         lda #147    ;clear screen
         jsr BSOUT

         sta $d07e       ; scpu-registers on
         sta $d076       ; optimization mode
                         ; mirror only $0400-$0800 (only standard screen ram)
         sta $d07f       ; scpu-registers off
         clc
         #xce
         #regs16
         #lda_i16 2000
         #ldx_i16 r
         ldy #0              ;fill r-array @N@
         .byte ((N+1)/128+1)/2
lf0      sta 0,x
         inx
         inx
         dey
         bne lf0

         ;sta 0,x
         sty c

         lda #<N        ;k <- N   @N16@
         .byte >N
         sta k

loop     #stz_z d    ;d <- 0
         #stz_z d+2

         lda k          ;i <- 2k
         asl           ;sets CY = 0
         tax
loop2    stx i
         lda r,x
         #regs8
         tax            ;50 cycles, *10000
         #xba
         tay
         lda m10000+256,x
         ;clc
         adc m10000,y
         ;sta product+1
         #xba
         lda m10000+512,x
         adc m10000+256,y
         sta product+2
         lda m10000+512,y
         adc #0           ;sets CY = 0
         sta product+3
         lda m10000,x     ;r[i]*10000
         ;sta product
         ;lda product      ;d <- d + r[i]*10000
         #regs16
         adc d
         sta d
         sta dividend
         lda product+2
         adc d+2
         sta d+2
         sta dividend+2

         ldx i             ;b <- b - 1
         dex
         stx divisor
         jsr div32x16x  ;AC = remainder at the exit, div32x16x doesn't use XR
         sta r+1,x     ;r[i] <- d%b
         dex      ;i <- i - 1
         beq l4

         ;stx i
         lda d      ;d <- (d - r[i] - new_d)/2 = d*i
         sec
         sbc remainder
         sta d
         bcs tl1

         sec
         dec d+2
tl1      ;lda d
         sbc quotient
         sta d
         lda d+2
         sbc quotient+2
         lsr
         sta d+2
         ror d       ;sets CY = 0
         bcc loop2   ;bra?

l4       #lda_i16 10000
         sta divisor
         jsr div32x16x    ;c + d/10000, AC = dividend+3
         clc
         lda quotient
         adc c
         jsr pr0000
         lda remainder
         sta c             ;c <- d%10000
         lda k      ;k <- k - 14
         sec
         sbc #14
         .byte 0
         sta k
         beq exit
         jmp loop

exit     sec
         #xce
         ;lda #$1b
         ;sta $d011   ;screen on
         ;cli         ;interrupts enabled

         lda #$37
         sta 1    ;restores Basic ROM
         rts
.bend


    * = (* + 256) & $ff00
m10000
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
 .byte 0,39,78,117,156,195,234,17,56,95,134,173,212,251,34,73
 .byte 113,152,191,230,13,52,91,130,169,208,247,30,69,108,147,186
 .byte 226,9,48,87,126,165,204,243,26,65,104,143,182,221,4,43
 .byte 83,122,161,200,239,22,61,100,139,178,217,0,39,78,117,156
 .byte 196,235,18,57,96,135,174,213,252,35,74,113,152,191,230,13
 .byte 53,92,131,170,209,248,31,70,109,148,187,226,9,48,87,126
 .byte 166,205,244,27,66,105,144,183,222,5,44,83,122,161,200,239
 .byte 23,62,101,140,179,218,1,40,79,118,157,196,235,18,57,96
 .byte 136,175,214,253,36,75,114,153,192,231,14,53,92,131,170,209
 .byte 249,32,71,110,149,188,227,10,49,88,127,166,205,244,27,66
 .byte 106,145,184,223,6,45,84,123,162,201,240,23,62,101,140,179
 .byte 219,2,41,80,119,158,197,236,19,58,97,136,175,214,253,36
 .byte 76,115,154,193,232,15,54,93,132,171,210,249,32,71,110,149
 .byte 189,228,11,50,89,128,167,206,245,28,67,106,145,184,223,6
 .byte 46,85,124,163,202,241,24,63,102,141,180,219,2,41,80,119
 .byte 159,198,237,20,59,98,137,176,215,254,37,76,115,154,193,232
 .byte 0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2
 .byte 2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4
 .byte 4,5,5,5,5,5,5,5,6,6,6,6,6,6,7,7
 .byte 7,7,7,7,7,8,8,8,8,8,8,9,9,9,9,9
 .byte 9,9,10,10,10,10,10,10,10,11,11,11,11,11,11,12
 .byte 12,12,12,12,12,12,13,13,13,13,13,13,14,14,14,14
 .byte 14,14,14,15,15,15,15,15,15,16,16,16,16,16,16,16
 .byte 17,17,17,17,17,17,18,18,18,18,18,18,18,19,19,19
 .byte 19,19,19,19,20,20,20,20,20,20,21,21,21,21,21,21
 .byte 21,22,22,22,22,22,22,23,23,23,23,23,23,23,24,24
 .byte 24,24,24,24,25,25,25,25,25,25,25,26,26,26,26,26
 .byte 26,27,27,27,27,27,27,27,28,28,28,28,28,28,28,29
 .byte 29,29,29,29,29,30,30,30,30,30,30,30,31,31,31,31
 .byte 31,31,32,32,32,32,32,32,32,33,33,33,33,33,33,34
 .byte 34,34,34,34,34,34,35,35,35,35,35,35,36,36,36,36
 .byte 36,36,36,37,37,37,37,37,37,37,38,38,38,38,38,38

.include "65816-div5.s"

pr0000 .block  ;prints C = B:A
         sta d+2
         #lda_i16 1000
         sta d
         jsr pr0
         #lda_i16 100
         sta d
         jsr pr0
         #lda_i16 10
         sta d
         jsr pr0
         ldx d+2
prd      txa
         ;#regs8
         sec
         #xce
         eor #$30
         jsr BSOUT
         clc
         #xce
         #regs16
         rts

pr0      #ldx_i16 65535
prn      inx
         lda d+2
         cmp d
         bcc prd

         sbc d
         sta d+2
         bcs prn
.bend

c .byte 0,0
         r = * + 16
;r = (* + 16 + 256) & $ff00

