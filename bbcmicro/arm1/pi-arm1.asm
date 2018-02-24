;for fasmarm assembler
;for Acorn ARM Evaluation System
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

;litwr has written this for ARM
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped too

processor cpu32_v1

OPT = 5               ;it's a constant for the pi-spigot

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

macro div32f_2 {
        MOVS R12,0,2    ;clears R12 and CY
        MOV R0,R0,lsl OPT
   repeat 32-OPT
        ADCS R0,R0,R0
        ADC R12,R12,R12
        CMP R12,R1
        SUBCS R12,R1
   end repeat
        ADC R0,R0,R0
        ADD PC,R14,208   ;length of div32f - 8
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
        ADD PC,R14,208
}

macro div32o { ;R0 >= R1, R1 is 16 bits; R12 = R0/R1, R0 = R0%R1, used: R13, its results differs from div32q/f!
local .exitdiv,.l1,.l4,.l5,.l7,.l0,.l8,.l6,.l3
        MOV R13,1     ;bit to control the division
        CMP R0,R1,lsl 16  ;limit to 16 bits of R1 is used
        bcc .l4

        MOV R1,R1,LSL 16
        MOV R13,R13,LSL 16
        tst r1,$ff000000
        bne .l3

.l4:    CMP R0,R1,lsl 8
        bcc .l1

        MOV R1,R1,LSL 8
        MOV R13,R13,LSL 8
.l3:    tst r1,$f0000000
        bne .l6

.l1:    CMP R0,R1,lsl 4
        bcc .l5

        MOV R1,R1,LSL 4
        MOV R13,R13,LSL 4
.l6:    tst r1,$c0000000
        bne .l8

.l5:    CMP R0,R1,lsl 2
        bcc .l7

        MOV R13,R13,LSL 2
        MOVS R1,R1,LSL 2
.l8:    bmi .l0

.l7:    CMP R0,R1,lsl 1
        bcc .l0

        MOV R1,R1,LSL 1
        MOV R13,R13,LSL 1
.l0:    SUB R0,R0,R1       ;R0 >= R1 is used
        MOV R12,R13        ;R13 = right_1_bit_pos(dividend)-right_1_bit_pos(divisor)
        MOVS R13,R13,LSR 1 ;shift control bit
        BEQ .exitdiv       ;divide result in R12, remainder in R0

   repeat 23               ;must be 30 for the general case, for pi-spigot R13 is always below or equal 2^24!
                           ;  This is tested up to 10000 digits.
        MOV R1,R1,LSR 1    ;halve unless finished
        CMP R0,R1          ;test for possible subtraction
        SUBCS R0,R0,R1     ;subtract if ok
        ADDCS R12,R12,R13  ;put relevant bit into result
        MOVS R13,R13,LSR 1 ;shift control bit
        BEQ .exitdiv       ;divide result in R12, remainder in R0
   end repeat

        MOV R1,R1,LSR 1    ;halve unless finished
        CMP R0,R1       ;2
        SUBCS R0,R0,R1
        ADDCS R12,R12,R13
.exitdiv:
}

         org $1000
start:   ;adr r0,msg1
         mov r0,msg1 and $fffffc00
         add r0,msg1 and $3ff
         swi 2
         swi 1
         db 'number of digits (up to ',0
         align 4

         mov r0,($10000-msg1+start) and $fffffc00
         add r0,($10000-msg1+start) and $3ff
         mov r1,7
         bl div32s
         and r3,r12,#$fffffffc
         mov r8,r3
         bl PR0000
         swi 1
         db ')? ',0
         align 4

         bl getnum
         ;mov r7,#1000

         swi 1
.msg2  db 13,10,0
         align 4

         add r1,r7,#3
         and r1,r1,#$fffffffc
         cmp r1,r7
         beq .l7

         mov r3,r1
         bl PR0000
         swi 1
.msg3  db ' digits will be printed',13,10,0
         align 4

.l7:     mov r1,r1,lsr #1
         rsb r9,r1,r1,lsl 3 ;*7, k = r9
         bl gettime

         mov r3,r9       ;fill r-array
         mov r1,#2000
         orr r1,#2000*65536
         mov r6,(ra+4) and $fffffc00
         add r6,(ra+4) and $3ff
         sub r2,r6,4
.l8:     str r1,[r6],#4
         subs r3,r3,#2
         bne .l8

         mov r8,#0    ;c
.l0:     mov r6,#0    ;d = R6 <- 0
         mov r5,r9,lsl 1      ;i <-k*2
         add r7,r2,r5
         b .l2

.l4:     sub r6,r6,r12          ;main loop start
         sub r6,r6,r0
         mov r6,r6,lsr #1
.l2:     ldr r11,[r7,0]        ;r[i]
         mov r1,r11,lsl 16
         mov r1,r1,lsr 16
         add r0,r1,r1,lsl 9   ;r[i]*10000
         add r0,r0,r1,lsl 7
         sub r0,r0,r1,lsl 4
         add r6,r6,r0,lsl 4   ;d += r[i]*10000;
         sub r1,r5,#1      ;b <- 2*i-1
         mov r0,r6
         div32f

         sub r6,r6,r12
         sub r6,r6,r0
         mov r6,r6,lsr #1
         mov r1,r11,lsr 16
         mov r11,r12
         add r0,r1,r1,lsl 9   ;r[i]*10000
         add r0,r0,r1,lsl 7
         sub r0,r0,r1,lsl 4
         add r6,r6,r0,lsl 4   ;d += r[i]*10000;
         sub r1,r5,#3      ;b <- 2*i-1
         mov r0,r6
         div32f
         orr r11,r12,lsl 16   ;change R12 to R0 with DIV32O
         str r11,[r7],-4 ;r[i] <- d%b
         subs r5,r5,#4   ;i <- i - 1
         bne .l4         ;main loop end

         mov r0,r6
         mov r1,#10240
         sub r1,r1,240
         bl div32s
         add r1,r12,r8  ;c + d/10000
         mov r8,r0      ;c <- d%10000
         mov r3,r1
         bl PR0000
         subs r9,r9,14    ;k <- k - 14
         bne .l0

.l5:     mov r0,' '
         swi 0
         adr r7,time
         ldr r2,[r7,0]
         bl gettime
         ldr r3,[r7,0]
         sub r1,r3,r2
         add r3,r1,r1,lsl 2
         mov r0,r3,lsl 1   ;*10 = 1000/100

         adr r6,string
         mov r8,r6
         mov r1,#10
         bl div32s
         strb r0,[r6],#1
         mov r0,r12
         mov r1,#10
         bl div32s
         strb r0,[r6],#1
         mov r0,r12
         mov r1,#10
         bl div32s
         strb r0,[r6],#1
         mov r0,#'.'-'0'
         strb r0,[r6],#1
.l12:    cmp r12,#0
         beq .l11

         mov r0,r12
         mov r1,#10
         bl div32s
         strb r0,[r6],#1
         b .l12

.l11:    ldrb r3,[r6,-1]!
         bl PR0000.l2
         cmp r6,r8
         bne .l11

         swi 17

div32:   div32q_2

PR0000:     ;prints r3, uses r0,r6
        mov r6,#1000
        mov r0,'0'-1
.l41:	add r0,r0,#1
	subs r3,r3,r6
	bcs .l41

    	add r3,r3,r6
        swi 0
        mov r6,#100
        mov r0,'0'-1
.l42:	add r0,r0,#1
	subs r3,r3,r6
	bcs .l42

    	add r3,r3,r6
        swi 0
        mov r6,#10
        mov r0,'0'-1
.l43:	add r0,r0,#1
	subs r3,r3,r6
	bcs .l43

    	add r3,r3,r6
        swi 0
.l2:   	add r0,r3,'0'
        swi 0
        mov pc,r14     ;return

gettime:
        mov r0,#1
        adr r1,time
        swi 7
        mov pc,r14

mul32:    ;enter with numbers in R1, R0, R3 - result register
        MOV R3,#0
.loop:  MOVS R1,R1,LSR #1
        ADDCS R3,R3,R0
        ADD R0,R0,R0
        BNE .loop      ;stops when R1 becomes zero
        MOV PC,R14    ;R3 contains R1*R0, (R1 set to 0, R0 junk)

div32s:   ;enter with numbers in R1 (divisor) and R0 (dividend)
        MOV R13,#1     ;bit to control the division
.div1:  CMP R1,R0
        MOVCC R1,R1,LSL #1
        MOVCC R13,R13,LSL #1
        BCC .div1

        MOV R12,#0
.div2:  CMP R0,R1       ;test for possible subtraction
        SUBCS R0,R0,R1  ;subtract if ok
        ADDCS R12,R12,R13  ;put relevant bit into result
        MOVS R13,R13,LSR #1 ;shift control bit
        MOVNE R1,R1,LSR #1  ;halve unless finished
        BNE .div2      ;divide result in R12, remainder in R0
        mov pc,r14

time  db 0,0,0,0,0

      align 4
string rb 6

      align 4
ra = $ - 4
msg1  db 'number Pi calculator v4 for ARM Evaluation System'
      db 13,10,0

      align 4
getnum: mov r3,0    ;length
        mov r7,0    ;number, r8 - limit
        adr r6,ra
.l0:    swi 4
        cmp r0,13
        beq .l5

        cmp r0,$7f ;backspace
        beq .l1

        cmp r0,'0'
        bcc .l0

        cmp r0,'9'+1
        bcs .l0

        cmp r3,4
        beq .l0

        str r7,[r6],4    ;push r7
        swi 0
        add r3,r3,#1
        sub r4,r0,'0'
        add r7,r7,r7,lsl 2  ;*10
        add r7,r4,r7,lsl 1
        b .l0

.l1:    cmp r3,0
        beq .l0

        sub r3,r3,1
        swi 1
.msg2  db 8,' ',8,0
        ;align 4

        ldr r7,[r6,-4]!   ;pop r7
        b .l0

.l5:    cmp r3,0
        beq .l0

        cmp r7,r8
        bhi .l0

        tst r7,r7
        beq .l0
        mov pc,r14    ;return
