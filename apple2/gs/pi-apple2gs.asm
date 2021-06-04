;for TMPX assembler, it works on Apple IIgs
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

COUT = $FDED    ;print char in AC, the redirection is possible
;COUT1 = $FDF0   ;print char in AC, screen only
CROUT = $FD8E   ;print nl, corrupts AC
;RDKEY = $FD0C   ;wait and read a char to AC from the kbd
HOME = $FC58
IOSAVE = $FF4A
IOREST = $FF3F
SETMOUSE = $12
SERVEMOUSE = $13
INITMOUSE = $19

SEEKMOUSE = 1         ;seek mouse card, 0 means to use the $c400 address
IO = 1
DIV8OPT = 1           ;1 slightly slower for 7532 or more digits but faster for 7528 or less
OPT = 5               ;it's a constant for the pi-spigot
DIV8ADJ = 8
DIV8SADJ = 0

N = 350   ;100 digits
;N = 14  ;4 digits
;b = $8e   ;$8f
d = $fa   ;..$fd
i = $ec   ;$ed
k = $ee   ;$ef

divisor = $4a     ;$4b, $4c..$4d used for hi-byte and product ($4d is not used if DIV8OPT=0)
dividend = $4e	  ;..$51 used for hi-bytes
remainder = $ce   ;$cf used for hi-byte
quotient = dividend ;save memory by reusing divident to store the quotient
product = divisor
fac1 = dividend
fac2 = remainder

osubr .macro
.if IO
     jsr pr0000
.endif
.ifeq IO
     lda pr0000
.endif
.endm

MAINADJ = 0

         .include "scpu.mac"

         * = $a00
start    jmp init  ;@start@

.repeat MAINADJ,$ea

main     clc
         #xce
         #regs16
         #lda_i16 2000
         #ldx_i16 r+2
         ldy #<N           ;fill r-array @N2@
         .byte >N
         sty k
lf0      sta 0,x
         inx
         inx
         dey
         bne lf0

         sty c
         lda k
loop     #stz_z d    ;d <- 0
         #stz_z d+2

         lda k          ;i <- 2k
         asl           ;sets CY = 0
         tax
loop2    stx i        ;@mainloop@
         lda r,x      ;@EOP@
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
         ;sta dividend+2

         ldx i             ;b <- b - 1
         dex
         stx divisor
         ;jsr div32x16x  ;AC = remainder at the exit, div32x16x doesn't use XR
.include "65816-div6.s"
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
         jmp loop2   ;@mainloop@

l4       #lda_i16 10000
         sta divisor

         jsr div32x16m    ;c + d/10000, AC = dividend+3
         clc
         lda quotient
         adc c
         #osubr
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
         sei
mlo      lda #0
         sta $3fe
mhi      lda #0
         sta $3ff
         lda #0
         ldx #SETMOUSE
         jsr mousesub
exitprg  jmp IOREST

mousesub stx p6+1
p6       ldx $c400
         stx p2+1
         pha
         lda p6+2
         tax
         asl
         asl
         asl
         asl
         tay
         pla
p2       jmp 0

timeirq  
p3       jsr 0
         bcs nomouse

         inc time
         bne nomouse

         inc time+1
         bne nomouse

         inc time+2
nomouse
         rti

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
         eor #$b0
         jsr COUT
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

div32x16m       ;dividend+2 < divisor
        lda dividend+2
        clc
        ldy #16
        .byte 0
.block
l3      rol dividend
        rol
        cmp divisor
        bcc l1

        sbc divisor
l1      dey
        bne l3
.bend
        rol dividend
        sta remainder
        #stz_z dividend+2
	rts

c .byte 0,0
time .byte 0,0,0    ;@timer@

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

.include "65816-div7.s"

init     jsr IOSAVE
         ;jsr HOME  ;clear screen

mx       jsr setmouse

         ldx #2          ;clear timer
         lda #0
loopt    sta time,x
         dex
         bpl loopt

         sei
         ldx #INITMOUSE
         jsr mousesub
         lda #8
         ldx #SETMOUSE
         jsr mousesub
         lda $3fe
         sta mlo+1
         lda $3ff
         sta mhi+1
         lda #<timeirq
         sta $3fe
         lda #>timeirq
         sta $3ff
         cli
         jmp main

         r = * + 24

setmouse lda #$ad   ;opcode for LDA $xxxx
         sta mx
.if SEEKMOUSE
         ldx #$c1
         stx p4+2
loop3    ldx #4
loop4    ldy amagic,x
         lda vmagic,x
p4       cmp $c000,y
         beq match

         inc p4+2
         ldy p4+2
         cpy #$c8
         bne loop3

         jsr mouserr
         pla
         pla
         jmp exitprg

amagic .byte 5,7,$b,$c,$fb
vmagic .byte $38,$18,1,$20,$d6

match    dex
         bpl loop4

         lda p4+2
         sta p7+2
         sta p3+2
         sta p2+2
         sta p6+2
.endif
p7       lda $c400+SERVEMOUSE
         sta p3+1
         rts

mouserr  ldx #0
loop8    lda msg,x
         beq exiterr

         jsr COUT
         inx
         bne loop8
exiterr  rts

msg .text "can't find a mouse card"
    .byte 0
