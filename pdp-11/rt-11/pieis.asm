;for macro-11 assembler
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

;litwr has written this for RT-11
;bqt helped much with optimization
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped a lot

      .radix 10

DEBUG = 0
IO = 1
DIVOF = 1  ;use overflow flag after division, it is faster but can have compatibility issues
           ;with some PDP-11, for example, 11/34 and 11/44
SOUZNEON = 0 ;This computer needs its timer to be corrected, 1.3 factor is used
             ;actually the 64Hz are used instead of 50Hz, so we need (!) 1.28

      .MCall .exit, .print, .gtim, .ttyin, .ttyout, .ttinr, .settop, .gval
      $JSW =: ^O44
      TTSPC$ =: ^O10000
      CONFIG = ^O300

MAXD = 9360  ;the hardware division implementation has a limit only 7792 digits
             ;however due to a nature of the pi-spigot algorithm all cases for errors will be missed

kv = kvs + 2

.macro div32x16
              ;R4:R2 = R2:R3/R1, R3 = R2:R3%R1
              ;R1 must be odd, this is not universal division but a particular procedure for pi-spigot
     ;tst r1
     bmi divm           ;for R1 > 0x7fff

.if eq DIVOF
     asl r3
     rol r2

     cmp r2,r1
     bcc div32b

     asr r2
     ror r3
.endc
     div r1,r2   ;r2(hi):r3(lo)/r1 -> r2 - quotient, r3 - remainder
.if ne DIVOF
     bvs div32b
.endc

     clr r4
    .endm div32x16

.macro adiv ?div32n ?l1 ?l1x ?l2
     ;clc          ;check CF = 0!
     ror r1
     mov r2,r4
     asl r4
     inc r4     ;this should be the highest bit of r3
     cmp r4,r1
     bcc div32n

     div r1,r2
     clr r4
     ror r2
     bcc l1

     add r1,r3
l1:  asl r1
     inc r1
     sub r2,r3
     bcc exit

     dec r2
     add r1,r3
     br exit

div32n:
     clr r4
     ror r2
     ror r3
     rol r4   ;save CF
     div r1,r2
     asl r2
     asl r3
     add r4,r3
     cmp r3,r1
     bcs l2

     inc r2
     sub r1,r3
l2:  clr r4
     ror r2
     bcc l1x

     add r1,r3
l1x: asl r1
     inc r1
     sub r2,r3
     bcc exit

     dec r2
     add r1,r3
     br exit
     .endm adiv

.macro bdiv
.if ne DIVOF
     asl r3
     rol r2
.endc
     mov r5,@sp
     mov r2,r5
     clr r4
     div r1,r4
     mov r5,r2
     asr r2
     ror r3
     div r1,r2
     clr r5
     asr r4
     ror r5
     add r5,r2
     adc r4
     mov @sp,r5
     br exit
     .endm bdiv

START:
         bis #TTSPC$,@#$JSW
         .settop #-2
         sub #ra-2,r0
         mov r0,r3
         clr r2
         div #7,r2
         bic #3,r2
         cmp #MAXD,r2
         bcc 205$

         mov #MAXD,r2
205$:    mov r2,@#maxnum
         .print #msg1
         ;mov @#maxnum,r2
         call PR0000
         .print #msg2
         call @#getnum
         .print #eol

         mov r2,r4
         add #3,r4
         bic #3,r4
         cmp r2,r4
         beq 7$

         mov r4,r2
         call @#PR0000
         .print #msg3

7$:      mov r4,r0
         asr r4
         add r0,r4
         asl r0
         add r0,r4   ;r4 <- r4/2*7
         mov r4,@#kv
         tst -(sp)       ;create a location for high(d)

         .gtim #area,#time
         mov r4,r0   ;fill r-array
         mov #2000,r1
         mov #ra+2,r2
1$:      mov r1,(r2)+
         sob r0,1$

mloop:   clr r5       ;d <- 0
         clr r0

kvs:     mov #0,r1
         asl r1       ;i <- 2k
         br l4x
divm:
         adiv
div32b:
         bdiv

l77:     add r3,r2       ;d <- d/b*i
         adc r4
         sub r2,r5
         sbc r0
         sub r4,r0
         ror r0
         ror r5
l4x:      mov #10000,r2
         mul ra(r1),r2   ;the result in r2 - high, r3 - low
         bpl 202$

         add #10000,r2
202$:    add r3,r5
         mov r5,r3
         adc r2
         add r0,r2   ;sets CF=0
         mov r2,r0
         dec r1          ;b <- 2*i-1, CF=0 for EIS!
         div32x16
exit:
         mov r3,ra+1(r1)      ;r[i] <- d%b
         sob r1,l77        ;i <- i - 1

.if ne IO
         mov r2,r3
         mov r4,r2
         div #10000,r2
         add @#cv,r2  ;c + d/10000
         mov r3,@#cv     ;c <- d%10000
         call @#PR0000
.endc
         sub #14,@#kv      ;k <- k - 14
         bne mloop

         mov #time2,r1
         .gtim #area,r1
         mov #32,r0
         .ttyout
         sub @#time+2,@#time2+2
         sbc @#time2
         sub @#time,@#time2

         mov @#time2,r2
         mov @#time2+2,r3
         asl r3
         rol r2
.if eq SOUZNEON
         .gval #area,#CONFIG
         mov r0,r4
.iftf
         mov r3,r1
         mov r2,r0
.ift
         bit #32,r4    ;50 or 60 Hz?
         bne l206

         asl r1     ;*5
         rol r0
         add @#time2+2,r1
         adc r0
         add @#time2,r0
         asl r1    ;quotient is limited to 15 bits!
         rol r0
         mov r0,r3
         clr r2
         div #3,r2
         mov r3,r0
         asr r0
         ror r1
         div #3,r0
         asr r1
         add r0,r1
         clr r0
         asr r2
         ror r0
         add r0,r1
         adc r2
         mov r2,r0
l206:
.iff
         mov r0,-(sp)
         mov r1,-(sp)
         asl r1         ;*3
         rol r0
         add (sp),r1
         adc r0
         add 2(sp),r0
         asl r1    ;quotient is limited to 15 bits!
         rol r0
         mov r0,r3
         clr r2
         div #10,r2
         mov r3,r0
         asr r0
         ror r1
         div #10,r0
         cmp #4,r1
         adc r0
         mov r0,r1
         clr r0
         asr r2
         ror r0
         add r0,r1
         adc r2
         mov r2,r0
         add (sp)+,r1
         adc r0
         add (sp)+,r0
.endc
         call @#printsec   ;prints r0:r1
         tst (sp)+       ;clear the location for high(d)
         .ttinr

         bic #TTSPC$,@#$JSW
         .exit

.if ne DEBUG
PRX:mov r0,-(sp)   ;prints pdata, doesn't save flags
    mov r2,-(sp)
    mov r3,-(sp)
    mov @#pdata,r2
   call PRALL
   mov (sp)+,r3
   mov (sp)+,r2
   mov (sp)+,r0
      return

PRC:  mov r0,-(sp)
   mov @#pdata,r0
   .ttyout
   mov (sp)+,r0
      return

pdata: .word 0

PRALL:    ;prints r2, used: r0,r2,r3
        mov #10000,r3
	CALL @#PRZ
.endc

PR0000:
        mov #1000,r3
	CALL @#PRZ
        mov #100,r3
	CALL @#PRZ
        mov #10,r3
	CALL @#PRZ
	mov r2,r0
PR:	add #48,r0
   	.ttyout
        return

PRZ:	mov #65535,r0
4$:	inc r0
	cmp r2,r3
	bcs PR

	sub r3,r2
	br 4$

printsec:  ;prints R0:R1/100
        mov r1,r2
        mov r0,r1
        clr r4
        mov #1,r5 
        mov #34464,r3  ;100000-65536
        call @#20$
        clr r5 
        mov #10000,r3
        call @#20$
        mov #1000,r3
        call @#20$
        inc r4
        mov #100,r3
        call @#20$
        movb #'.,r0
        .ttyout
        mov #10,r3
        call @#20$
        mov r2,r0
2$:     add #48,r0
        .ttyout
        inc r4
5$:     return

7$:     tst r4
        bne 2$

        tst r0
        beq 5$

        inc r4
        br 2$

20$:    mov #65535,r0
4$:	inc r0
        cmp r1,r5
        bcs 7$
        bne 8$

	cmp r2,r3
	bcs 7$

8$:     sub r3,r2
        sbc r1
        sub r5,r1
	br 4$

cv: .word 0
time: .word 0,0   ;high, low!
ra:
time2: .word 0,0
maxnum: .word 0
area: .word 0,0

getnum: clr r1    ;length
        clr r2    ;number
20$:     .ttyin
        cmp #13,r0
        beq 5$

        cmp #127,r0   ;backspace
        beq 1$

        cmp #47,r0
        bcc 20$

        cmp #48+9,r0
        bcs 20$

        cmp #4,r1
        beq 20$

        mov r2,-(sp)
        .ttyout
        inc r1
        sub #48,r0
        mov r2,r3
        asl r3
        asl r3
        add r3,r2
        asl r2
        add r0,r2
        br 20$

1$:     tst r1
        beq 20$

        dec r1
        .print #delstr
        mov (sp)+,r2
        br 20$

5$:     tst r1
        beq 20$

        cmp @#maxnum,r2
        bcs 20$

        tst r2
        beq 20$

8$:     mov (sp)+,r0
        sob r1,8$
        return

msg1: .ascii "number pi"
      ;.byte 160 ;Greek pi
      .ascii " calculator v13 (EIS"
.if ne DIVOF
      .ascii "-of"
.endc
.if ne SOUZNEON
      .ascii ", SOUZ-NEON"
.endc
      .ascii ")" <13> <10>
      .ascii "number of digits (up to " <128>
msg2: .ascii ")? " <128>
msg3: .ascii " digits will be printed"
eol: .byte 0
delstr: .byte 8,32,8,128
;    .even

.End	START

