;for TMPX assembler
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
;litwr converted it to 6502
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped too

;INT2STR = $A45F  ;print unsigned integer in AC:XR
BSOUT = $FFD2    ;print char in AC

CMOS6502 = 0
IO = 1
DIV8OPT = 1           ;1 is slower for 7532 or more digits but faster for 7528 or less
OPT = 5               ;it's a constant for the pi-spigot
DIV8ADJ = 8
DIV8SADJ = 0

N = 14
;N = 350   ;100 digits
;N = 700   ;200 digits
;N = 3500  ;1000 digits
;N = 7792*7/2
d = $d8   ;..$db
i = $d4 ;$d5
;b = $d6 ;$d7
k = $d2 ;$d3

divisor = $de     ;$df, $e0..$e1 used for hi-byte and product ($e1 is not used if DIV8OPT=0)
dividend = $e2	  ;..$e5 used for hi-bytes
remainder = $e6   ;$e7 used for hi-byte
quotient = dividend ;save memory by reusing divident to store the quotient
product = divisor
fac1 = dividend
fac2 = remainder
rbase = $dc ;$dd
;maddlo = $2b ;$2c
;maddhi = $2d ;$2e
;mdiflo = $2f ;$30
;mdifhi = $d2 ;$d3
;freez = $31 ;$32

osubr .macro
.if IO
     jsr pr0000        ;$20=32
.endif
.ifeq IO
     lda pr0000        ;$ad=173
.endif
.endm

         * = $1001
         .include "pi-plus4.inc"

.if DIV8OPT
MAINADJ = $b
DIV32ADJ = 9
DIVMIADJ = 16
.endif
.ifeq DIV8OPT
MAINADJ = 0
DIV32ADJ = 0
DIVMIADJ = $12
.endif
         * = $1210 + MAINADJ
         ldy #<irqh    ;@start@
         ldx #>irqh
         lda $ff07
         and #$40
         beq nontsc

         ldy #<intsc
         ldx #>intsc  ;maybe commented?
nontsc   sty $fffe
         stx $ffff
         lda #$b
         lda $ff06   ;screen @blank@
         lda #$48
         lda $ff07   ;@ntsc@ on
         ;sei         ;no interrupts
         ;lda #147    ;clear screen
         ;jsr BSOUT

;       ldx #7
;szpl
;       lda $2b,x
;       pha
;       dex
;       bpl szpl

.if 0   ;timings
.block
tdiv = 9
       lda #$b
       sta $ff06
       lda #$d3
       sta $ff13
       lda #10
       sta zzr
       lda #tdiv       ;@lowinstr@
       sta divisor
       lda #0
       sta divisor+1
       lda #0
       sta zzq
       sta zzq+1
       sta zzq+2
       sta zzq+3
loop   ldy #$28
       sty $ff07
       lda $ff02
       ldx $ff03
       ldy #$8
       sty $ff07
       sta zzs
       stx zzs+1

       and #3
       sta dividend+3
       stx dividend+2
       ldy $ff00
       ldx $ff04
       sty dividend+1
       stx dividend

       jsr div32x16x
       ldy #$28
       sty $ff07
       lda $ff02
       ldx $ff03
       ldy #$8
       sty $ff07
       sta fac1
       stx fac1+1
       lda zzs
       sec
       sbc fac1
       sta zzs
       lda zzs+1
       sbc fac1+1
       sta zzs+1
       lda zzq
       clc
       adc zzs
       sta zzq
       lda zzq+1
       adc zzs+1
       sta zzq+1
       lda zzq+2
       adc #0
       sta zzq+2
       lda zzq+3
       adc #0
       sta zzq+3
       dec zzr+1
       bne loop

       dec zzr
       bne loop

       lda #$d1
       sta $ff13
       lda #$1b
       sta $ff06
       jmp rzpl0
zzs .byte 0,0         ;@zzq@
zzq .byte 0,0,0,0
zzr .byte 0,0
.bend
.endif
.if 0    ;testing
.block
tdiv = 9
       lda #$28
       sta $ff07
       ldx #1
       stx d
       ldx #0
       stx d+1
       stx d+2
       stx d+3
xl1    lda #0
       sta divisor+1
       lda #tdiv
       sta divisor
       lda d
       sta dividend
       lda d+1
       sta dividend+1
       lda d+2
       sta dividend+2
       lda d+3
       sta dividend+3
       jsr div32x16x
       lda quotient
       sta zzq
       lda quotient+1
       sta zzq+1
       lda quotient+2
       sta zzq+2
       lda quotient+3
       sta zzq+3
       lda remainder
       sta zzr
       lda remainder+1
       sta zzr+1
       lda #0
       sta divisor+1
       lda #tdiv
       sta divisor
       lda d
       sta dividend
       lda d+1
       sta dividend+1
       lda d+2
       sta dividend+2
       lda d+3
       sta dividend+3

       ldy #0
       jsr div32x8f
       ;jsr div32x16
       lda quotient
       cmp zzq
       bne err
       lda quotient+1
       cmp zzq+1
       bne err
       lda quotient+2
       cmp zzq+2
       bne err
       lda quotient+3
       cmp zzq+3
       bne err
       lda remainder
       cmp zzr
       bne err
       lda remainder+1
       cmp zzr+1
       bne err
       inc d
       bne xl1j
       inc d+1
       bne xl1j
       inc d+2
       bne xl1j
       inc d+3
       lda d+3
       cmp #4
       bne xl1j
       lda #8
       sta $ff07
       jmp rzpl0
xl1j   jmp xl1
err    ldx #0
rzpl
       pla
       sta $2b,x
       inx
       cpx #8
       bne rzpl
       stx $ff07
       brk
zzq .byte 0,0,0,0
zzr .byte 0,0
.bend
.endif
         sta $ff3f   ;selects RAM

         ldy #0
         lda #2
         sta d
         lda #>r            ;@EOP@ - end of program
         sta d+1
         ldx #N/128   ;fill r-array @high2N@
         beq lf3

lf0      lda #<2000
         sta (d),y
         iny
         lda #>2000
         sta (d),y
         iny
         bne lf0

         inc d+1
         dex
         bne lf0

lf3      ldy #(2*N)&255   ;fill r-array @low2N@
         beq lf2

lf1      lda #>2000
         dey
         sta (d),y
         lda #<2000
         dey
         sta (d),y
         bne lf1

lf2      stx c
         stx c+1
         stx rbase

         lda #<N        ;k <- N   @lowN@
         sta k
         lda #>N                  ;@highN@
         sta k+1

loop     lda #0          ;d <- 0
         sta d
         sta d+1
         sta d+2
         sta d+3

         lda k          ;i <- 2k
         asl          ;shoud be moved upper, k can keep 2*N
         sta i
         lda k+1
         rol       ;sets CY=0
         sta i+1
         bcc loop2

l8       stx i      ;@mainloop@
         lda d      ;d <- (d - r[i] - new_d)/2 = d*i
         sec
         sbc remainder
         sta d
         lda d+1
         sbc remainder+1
         sta d+1
         bcs tl1

         sec
         lda d+2
         bne tl2

         dec d+3
tl2      dec d+2
tl1      lda d
         sbc quotient
         sta d
         lda d+1
         sbc quotient+1
         sta d+1
         lda d+2
         sbc quotient+2
         sta d+2
         lda d+3
         sbc quotient+3
         lsr
         sta d+3
         ror d+2
         ror d+1
         ror d
loop2    ldy i
         lda i+1    ; b <- 2*i
         adc #>r    ;sets CY=0
         sta rbase+1     ; r[i]
         ;sei
         ;sta $ff3f    ;c264 to RAM, if number of digits about > 3140
         lda (rbase),y
         tax
         iny
         lda (rbase),y
         ;sta $ff3e    ;c264 to ROM
         ;cli
         tay
         lda m10000+256,x
         adc m10000,y
         sta product+1
         lda m10000+512,x
         adc m10000+256,y
         sta product+2
         lda m10000+512,y
         adc #0
         tay            ;sta product+3
         lda m10000,x     ;r[i]*10000
         ;sta product
         ;lda product      ;d <- d + r[i]*10000
         ;clc
         adc d
         sta d
         sta dividend
         lda product+1
         adc d+1
         sta d+1
         sta dividend+1
         lda product+2
         adc d+2
         sta d+2
         ;sta dividend+2
         sta remainder
         tya            ;lda product+3
         adc d+3
         sta d+3
         ;sta dividend+3

         ldy i+1
         ldx i             ;b <- b - 1
         bne l1

         dey
         sty i+1
l1       dex
         stx divisor
         sty divisor+1
         ;IN: AC = dividend+3, YR = divisor+1; OUT: AC = remainder
.include "6502-div6.s"
         ldy i            ;r[i] <- d%b
         sta (rbase),y
         lda remainder+1
         iny
         sta (rbase),y
         ldx divisor    ;i <- i - 1
         dex
         beq l8n
         jmp l8

l8n      lda i+1
         beq l4
         jmp l8     ;@mainloop@

l4       lda #>10000
         sta divisor+1
         lda #<10000
         sta divisor

         lda dividend+3   ;dividend = quotient
         jsr div32x16w    ;c + d/10000, AC = dividend+3
         clc
         lda quotient
         adc c
         tax
         lda quotient+1
         adc c+1
         sta $ff3e
         #osubr
         sta $ff3f
         lda remainder
         sta c             ;c <- d%10000
         lda remainder+1
         sta c+1

         lda k      ;k <- k - 14
         sec
         sbc #14
         sta k
         bcs l11

         dec k+1
l11      ora k+1
         beq exit
         jmp loop

exit     sta $ff3e   ;selects ROM
         lda #$1b
         sta $ff06   ;screen on
         lda #8
         sta $ff07   ;@ntsc-off@
         ;cli         ;interrupts enabled
rzpl0
;       ldx #0
;rzpl
;       pla
;       sta $2b,x
;       inx
;       cpx #8
;       bne rzpl
         rts
irqh
       dec $7fd
       bpl intsc

       pha
       lda #4
       sta $7fd
       pla
       jsr uptime
intsc  jsr uptime
       inc $ff09
       rti

uptime inc $a5
.block
       bne l1

       inc $a4
       bne l1

       inc $a3
l1     rts
.bend

pr0000 .block
         sta d+2
         lda #<1000
         sta d
         lda #>1000
         sta d+1
         jsr pr0
         lda #100
         sta d
         lda #0
         sta d+1
         jsr pr0
         lda #10
         sta d
         jsr pr0
         txa
         tay
prd      tya
         eor #$30
         jmp BSOUT

pr0      ldy #255
prn      iny
         lda d+2
         cmp d+1
         bcc prd
         bne prc

         cpx d
         bcc prd

prc      txa
         sbc d
         tax
         lda d+2
         sbc d+1
         sta d+2
         bcs prn
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

.if DIV8OPT
.include "6502-div8.s"
.endif
.include "6502-div7.s"

c .byte 0,0

r = (* + 24 + 256) & $ff00

