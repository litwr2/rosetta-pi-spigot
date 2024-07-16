;for macro-11 assembler
;for the BK0011 using the BK0010 ROM emulation
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

;litwr has written this for the BK
;bqt helped much with optimization
;Manwe helped with development
;Thorham and meynaf helped too

      .radix 10
      .dsabl gbl

HMUL = 0  ;hardware multiplication, 0 - no
IO = 1

;N = 10500   ;3000 digits
;N = 3500   ;1000 digits
N = 350   ;100 digits

kv = kvs + 2

pageport   = ^O177716            ;$ffce
timerport1 = ^O177706            ;$ffc6
timerport2 = ^O177710            ;$ffc8
timerport3 = ^O177712            ;$ffca
todata     = ^B010101100000000   ;open pages 2 and 3
toandos    = ^B001110000000000   ;open pages 1 (soft 5) and 4 (AnDOS)

.macro div0s l0
     rol r2
     rol r3
     add r5,r3
     bcc l0
     .endm

.macro div0a l0
     rol r2
     rol r3
     add r1,r3
     bcs l0
     .endm

.macro div0z ?S2 ?S3 ?S4 ?S5 ?S6 ?S7 ?S8 ?S9 ?SA ?SB ?SC ?SD ?SE ?SF ?S0 ?A1 ?A2 ?A3 ?A4 ?A5 ?A6 ?A7 ?A8 ?A9 ?AA ?AB ?AC ?AD ?AE ?AF ?A0 ?ll
     div0s A1
     div0s A2
S2:  div0s A3
S3:  div0s A4
S4:  div0s A5
S5:  div0s A6
S6:  div0s A7
S7:  div0s A8
S8:  div0s A9
S9:  div0s AA
SA:  div0s AB
SB:  div0s AC
SC:  div0s AD
SD:  div0s AE
SE:  div0s AF
SF:  div0s A0
S0:  rol r2
     br ll

A1:  div0a S2
A2:  div0a S3
A3:  div0a S4
A4:  div0a S5
A5:  div0a S6
A6:  div0a S7
A7:  div0a S8
A8:  div0a S9
A9:  div0a SA
AA:  div0a SB
AB:  div0a SC
AC:  div0a SD
AD:  div0a SE
AE:  div0a SF
AF:  div0a S0
A0:  rol r2
     add r1,r3
ll:
     .endm

.macro div32x16 ?div32 ?exit ?S7 ?S8 ?S9 ?SA ?SB ?SC ?SD ?SE ?SF ?S0 ?A6 ?A7 ?A8 ?A9 ?AA ?AB ?AC ?AD ?AE ?AF ?A0 ?ll
                    ;R4:R2 = R3:R2/R1, R3 = R3:R2%R1, used: R0, R1 not changed
                    ;may work wrong if R1>$7fff
     cmp r3,r1
     ;bcc div32
     bcs .+6
     jmp @#div32

     div0z
     clr r4
     jmp @#exit

div32:
     mov r2,r0
     mov r3,r2
     clr r3
;OPT = 5         ;It's a constant for the pi-spigot
     asl r2
     asl r2
     asl r2
     asl r2
     asl r2

    div0s A6
    div0s A7
S7: div0s A8
S8:  div0s A9
S9:  div0s AA
SA:  div0s AB
SB:  div0s AC
SC:  div0s AD
SD:  div0s AE
SE:  div0s AF
SF:  div0s A0
S0:  rol r2
     br ll

A6: div0a S7
A7: div0a S8
A8:  div0a S9
A9:  div0a SA
AA:  div0a SB
AB:  div0a SC
AC:  div0a SD
AD:  div0a SE
AE:  div0a SF
AF:  div0a S0
A0:  rol r2
     add r1,r3
ll:

     ;div0z   ;OPT=0

     mov r2,r4
     mov r0,r2

     div0z
exit:
     .endm

         .asect
         .=1536
start:   emt 0
    	 mov #27,r0
         emt ^O63
         mov #49,r0
         emt ^O63    ;64 columns
         mov #msg1,r0
         emt ^O64

         mov #32768-ra,r2   ;$8000
         clr r3
         mov #7,r1
         call @#div32x16s
         bic #3,r2
         mov r2,@#maxnum
restart: mov #msg4,r0
         emt ^O64
         mov @#maxnum,r2
         call @#PR0000
         mov #msg5,r0
         emt ^O64
         call @#getnum
         mov #eol,r0
         emt ^O64

         mov r2,r4
         add #3,r4
         bic #3,r4
         cmp r2,r4
         beq 7$

         mov r4,r2
         call @#PR0000
         mov #msg3,r0
         emt ^O64

7$:      mov r4,r0
         asr r4
         add r0,r4
         asl r0
         add r0,r4   ;r4 <- r4/2*7
         mov r4,@#kv
         mov r4,@#100$+2

         mov #todata,@#pageport
         clr @#time
         clr @#time+2
         mov #^B110010,@#timerport3    ;sets timer, /16
         mov @#timerport2,@#prevtime
         mtps #128
100$:    mov #N,r0   ;fill r-array
         mov #2000,r1
         mov #ra+2,r2
1$:      mov r1,(r2)+
         sob r0,1$

         clr @#cv
mloop:   clr r5       ;d <- 0
         clr sp
kvs:     mov #0,r1
         asl r1       ;i <- 2k
ivs:

.if eq HMUL
         mov ra(r1),r0     ;r[i]
         clr r4            ;r[i]*10000
         clr r2
         mov r0,r3         ;the result in r2 - high, r3 - low
         asl r3
         rol r2
         asl r3
         rol r2
         asl r3
         rol r2
         sub r3,r0
         sbc r4
         sub r2,r4
         asl r3
         rol r2
         sub r3,r0
         sbc r4
         sub r2,r4
         sub r3,r0
         sbc r4
         sub r2,r4
         swab r0
         swab r4
         clrb r4
         bisb r0,r4
         clrb r0
         sub r0,r3
         sbc r2
         sub r4,r2
.iff
         mov #10000,r2
         mul ra(r1),r2
.endc
         add r3,r5
         mov r2,r3
         mov r5,r2
         adc r3
         add r3,sp
         mov sp,r3

         dec r1          ;b <- 2*i-1
         mov r5,@#17$+2
         mov r1,r5
         neg r5
         div32x16
17$:     mov #0,r5
         mov r3,ra+1(r1)      ;r[i] <- d%b
         dec r1        ;i <- i - 1
         beq 4$

         add r3,r2       ;d <- d/b*i
         adc r4
         sub r2,r5
         sbc sp
         sub r4,sp
         ror sp
         ror r5
         jmp @#ivs
4$:
.if ne IO
         mov #512,sp
         mov r4,r3
         mov #10000,r1
         call @#div32x16s
         add @#cv,r2     ;c + d/10000
         mov r3,@#cv     ;c <- d%10000
         mov #toandos,@#pageport
         call @#PR0000
         mov #todata,@#pageport
.endc
         mov @#timerport2,r1
         mov @#prevtime,r3
         sub r1,r3
         mov r1,@#prevtime
         add r3,@#time
         adc @#time+2
         sub #14,@#kv      ;k <- k - 14
         beq .+6
         jmp @#mloop

         mov #toandos,@#pageport
         mov #32,r0
         emt ^O63
         mov @#time,r2
         mov @#time+2,r3
         asl r2     ;*100
         rol r3
         asl r2
         rol r3
         add @#time,r2
         adc r3
         add @#time+2,r3
         mov r3,-(sp)
         mov r2,-(sp)
         asl r2
         rol r3
         asl r2
         rol r3
         add (sp)+,r2
         adc r3
         add (sp)+,r3
         asl r2
         rol r3
         asl r2
         rol r3

         mov #1953,r1             ;4 MHz,4000000/16/128
         call @#div32x16s
         call @#printsec
         mtps #0
         jmp @#restart

div32x16s: ;R1:R2 = R3:R2/R1, R3 = R3:R2%R1, used: R0,R4
           ;compact form - 64 bytes
                             ;may work wrong if R1>$7fff
     cmp r3,r1
     bcc 32$

     call @#3$
     clr r1
     return

32$: mov r2,r0
     mov r3,r2
     clr r3
     call @#3$
     mov r2,r4
     mov r0,r2
     call @#3$
     mov r4,r1
     return

3$:  call @#.+4
     call @#.+4
     call @#.+4
     call @#.+4
     asl r2
     rol r3
     cmp r3,r1
     bcs 0$

     sub r1,r3
     inc r2
0$:  return

PR0000:     ;prints r2
        mov #1000,r3
	CALL @#0$
        mov #100,r3
	CALL @#0$
        mov #10,r3
	CALL @#0$
	mov r2,r0
2$:	add #48,r0
   	emt ^O63
        return

0$:	mov #65535,r0
4$:	inc r0
	cmp r2,r3
	bcs 2$

	sub r3,r2
	br 4$

printsec:  ;prints R1:R2/100
        clr r4
        mov #1,r5 
        mov #34464,r3  ;100000-65536
        call @#0$
        clr r5 
        mov #10000,r3
        call @#0$
        mov #1000,r3
        call @#0$
        inc r4
        mov #100,r3
        call @#0$
        movb #'.,r0
        emt ^O63
        mov #10,r3
        call @#0$
        mov r2,r0
2$:     add #48,r0
        emt ^O63
        inc r4
5$:     return

7$:     tst r4
        bne 2$

        tst r0
        beq 5$

        inc r4
        br 2$

0$:     mov #65535,r0
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

getnum: clr r1    ;length
        clr r2    ;number
0$:     emt ^O33
        cmp #10,r0
        beq 5$

        cmp #24,r0
        beq 1$

        cmp #47,r0
        bcc 0$

        cmp #48+9,r0
        bcs 0$

        cmp #4,r1
        beq 0$

        mov r2,-(sp)
        emt ^O63
        inc r1
        sub #48,r0
        mov r2,r3
        asl r3
        asl r3
        add r3,r2
        asl r2
        add r0,r2
        br 0$

1$:     tst r1
        beq 0$

        dec r1
        mov #del,r0
        emt ^O64

        mov (sp)+,r2
        br 0$

5$:     tst r1
        beq 0$

        cmp @#maxnum,r2   ;(end of memory minus end of program)/7 and down to the multiple of 4
        bcs 0$

        tst r2
        beq 0$

        mov r1,r3
8$:     mov (sp)+,r0
        sob r3,8$
        return

cv: .word 0
time: .word 0,0
prevtime: .word 0
maxnum: .word 0
msg4: .byte 10,13
      .ascii "number of digits (up to "<128>
msg5:  .ascii ")? "<128>
msg3: .ascii " digits will be printed"
eol:  .byte 0
del:  .byte 8,32,8,128
      .even
ra:   .word 0
msg1: .ascii "number "<180>" calculator v8 ("<226>"K0011, BOS"
.if ne HMUL
      .ascii ", K1801BM1"<231>
.endc
      .ascii ")"<128>
msg2: .asciz "not "<226>"K0011"

