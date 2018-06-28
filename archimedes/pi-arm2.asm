;for fasmarm assembler
;for Acorn Archimedes
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

;litwr has written this for ARM/RiscOS
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped too

;processor cpu32_v1

OPT = 5               ;it's a constant for the pi-spigot
useMLA = 1

macro div32f { ;R0 >= R1, R1 is 16 bits; R0 = R0/R1, R12 = R0%R1
        CMP R0,R1,lsl 16
        BLCS div32

   repeat 16
        ADCS R0,R0,R0
        CMPCC R0,R1,lsl 16
        SUBCS R0,R1,lsl 16
   end repeat
        MOV R12,R0,lsr 16
        ADC R0,R0,R0
        MOV R0,R0,lsl 16
        MOV R0,R0,lsr 16
}

macro div32q_2 {
        MOVS R12,0,2    ;clears R12 and CY
        RSB R1,R1,0     ;NEG
        MOV R0,R0,lsl OPT
   repeat 32-OPT
        ADCS R0,R0,R0
        ADCS R12,R1,R12,lsl 1
        SUBCC R12,R12,R1
   end repeat
        ADC R0,R0,R0
        ;RSB R1,R1,0    ;restores R1
        ADD PC,R14,#(16*3+4)*4      ;208
}


         ;org 10000
start:   ;r3 (D%) - digits, r0 (A%) - start
         ;STMFD r13!,{R14} ;Save return address
         str r14,[r13,-4]!
         mov r9,r3
         mov r3,r9       ;fill r-array
         mov r1,#2000
         orr r1,#2000*65536
         add r6,r0,#(ra + 4 - start) and $fffffc00
         add r6,r6,#(ra + 4 - start) and $3ff
         sub r2,r6,4
.l8:     str r1,[r6],#4
         subs r3,r3,#2
         bne .l8

         mov r8,#0    ;c
         mov r10,#10240
         sub r10,r10,#240   ;R10 <- 10000
.l0:     mov r6,#0    ;d = R6 <- 0
         mov r5,r9,lsl #1      ;i <-k*2
         add r7,r2,r5
         b .l2

.l4:     sub r6,r6,r12          ;main loop start
         sub r6,r6,r0
         mov r6,r6,lsr #1
.l2:     ldr r11,[r7]        ;r[i]
         mov r1,r11,lsl 16
         mov r1,r1,lsr 16
 if useMLA 
         mla r0,r10,r1,r6  ;d += r[i]*10000;
         mov r6,r0
 else
         add r0,r1,r1,lsl 9   ;r[i]*10000
         add r0,r0,r1,lsl 7
         sub r0,r0,r1,lsl 4
         add r6,r6,r0,lsl 4   ;d += r[i]*10000;
         mov r0,r6
 end if
         sub r1,r5,#1      ;b <- 2*i-1
         div32f

         sub r6,r6,r12
         sub r6,r6,r0
         mov r6,r6,lsr #1
         mov r1,r11,lsr 16
         mov r11,r12
 if useMLA
         mla r0,r10,r1,r6  ;d += r[i]*10000;
         mov r6,r0
 else
         add r0,r1,r1,lsl 9   ;r[i]*10000
         add r0,r0,r1,lsl 7
         sub r0,r0,r1,lsl 4
         add r6,r6,r0,lsl 4   ;d += r[i]*10000;
         mov r0,r6
 end if
         sub r1,r5,#3      ;b <- 2*i-1
         div32f

         orr r11,r12,lsl 16
         str r11,[r7],-4 ;r[i] <- d%b
         subs r5,r5,#4   ;i <- i - 1
         bne .l4         ;main loop end

         mov r0,r6
         mov r1,r10
         bl div32s
         add r1,r12,r8  ;c + d/10000
         mov r8,r0      ;c <- d%10000
         mov r3,r1
         bl PR0000
         subs r9,r9,#14    ;k <- k - 14
         bne .l0

         ;LDMFD r13!,{PC}   ;return to caller
         ldr pc,[r13],4

div32:   div32q_2

PR0000:     ;prints r3, uses r0,r6
        mov r6,#1000
        mov r0,#'0'-1
.l41:	add r0,r0,#1
	subs r3,r3,r6
	bcs .l41

    	add r3,r3,r6
        swi 0
        mov r6,#100
        mov r0,#'0'-1
.l42:	add r0,r0,#1
	subs r3,r3,r6
	bcs .l42

    	add r3,r3,r6
        swi 0
        mov r6,#10
        mov r0,#'0'-1
.l43:	add r0,r0,#1
	subs r3,r3,r6
	bcs .l43

    	add r3,r3,r6
        swi 0
.l2:   	add r0,r3,'0'
        swi 0
        mov pc,r14     ;return

div32s:   ;enter with numbers in R1 (divisor) and R0 (dividend)
        MOV R6,#1     ;bit to control the division
.div1:  CMP R1,R0
        MOVCC R1,R1,LSL #1
        MOVCC R6,R6,LSL #1
        BCC .div1

        MOV R12,#0
.div2:  CMP R0,R1       ;test for possible subtraction
        SUBCS R0,R0,R1  ;subtract if ok
        ADDCS R12,R12,R6  ;put relevant bit into result
        MOVS R6,R6,LSR #1 ;shift control bit
        MOVNE R1,R1,LSR #1  ;halve unless finished
        BNE .div2      ;divide result in R12, remainder in R0
        MOV PC,R14

ra = $
