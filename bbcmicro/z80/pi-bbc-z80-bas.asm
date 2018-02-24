;for pasmo assembler
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

OSWRCH equ $FFEE    ;print char in A

N equ 3500   ;1000 digits
;N equ 2800  ;800 digits
SA equ $3e00 ;start address

div macro
     local t1,t2
     sla e
     rl d
     ADC   HL, HL
     jr c,t1

     LD    A,L
     ADD   A,C
     LD    A,H
     ADC   A,B
     JR    NC,t2
t1
     ADD   HL,BC
     INC   E
t2
endm

divz macro
	adc a,a
 adc hl,hl
 add hl,bc
 jr c, $+4
 sbc hl,bc
endm

divx macro
	ld a,d
	add a,a
 adc hl,hl
 add hl,bc
 jr c, $+4
 sbc hl,bc
rept 7
        divz
endm
	adc a,a
	ld d,a

	ld a,e
	add a,a
 adc hl,hl
 add hl,bc
 jr c, $+4
 sbc hl,bc
rept 7
	divz
endm
	adc a,a
	ld e,a
endm

div32x16 macro  ; BCDE = HLDE/BC, HL = HLDE%BC
     local OPT,DIV320,exitdiv,longdiv,longdiv0 ;may work wrong if BC>$7fff - fixed!
     ;DEC   BC
     dec c
     LD    A, B
     or a
;     jp z,div32x8
     jp m,longdiv0

     CPL
     LD    B, A
     LD    A, C
     CPL
     LD    C, A

     ADD   A, L
     LD    A, B
     ADC   A, H
     JP    NC, DIV320

longdiv
     PUSH  DE
OPT equ 2         ;3 limits HL to 0x1f'ff'ff'ff

rept OPT
     ADD HL,HL
endm
     EX    DE, HL
     LD    HL, 0

rept 16-OPT
     div
endm
     EX    DE, HL
     EX    (SP), HL
     EX    DE, HL

rept 16
     div
endm
     POP   BC
     jp exitdiv

longdiv0
     CPL
     LD    B, A
     LD    A, C
     CPL
     LD    C, A
     jp longdiv

;div32x8
;     jp exitdiv

DIV320
     divx
     LD    BC, 0
exitdiv
     endm

         org SA
start    proc
         local lf0,loop,l4,loop2,m1
         ;ld a,12     ;clear screen
         ;call OSWRCH

         ld bc,N        ;fill r-array
         ;di         ;no interrupts
         push bc
         ld de,2000
         ld hl,ra    ;@EOP@
         inc bc

lf0      ld (hl),e
         inc l
         ld (hl),d
         inc hl
         dec bc
         ld a,c
         or b
         jr nz,lf0

         ld (cv),bc
         pop hl          ;k <- N
         ld (kv),hl
loop     ld hl,0          ;d <- 0
         push hl
         push hl
         ld hl,(kv)          ;i <-k
         add hl,hl        ;keeps 2*i
         ld a,l
         ld iyl,a
         ld a,h
         ld iyh,a
loop2    ld c,iyl
         ld b,iyh
         ld hl,ra
         add hl,bc
         ld (m1+1),hl

         ld c,(hl)      ;r[i]
         inc l          ;r is at even addr
         ld b,(hl)
         ld h,high(m10000)
         ld l,c
         ld e,(hl)
         ld l,b
         ld a,(hl)
         ld l,c
         inc h
         add a,(hl)
         ld d,a
         ld l,b
         ld a,(hl)
         ld l,c
         inc h
         adc a,(hl)
         ld c,a
         ld l,b
         ld a,(hl)
         adc a,0
         ld b,a

         pop hl       ; d <- d + r[i]*10000
         add hl,de
         ex de,hl
         pop hl

         adc hl,bc
         dec iy    ;i <- i - 1
         ld b,iyh
         ld c,iyl
         dec iy

         push hl
         push de
         div32x16
m1       ld (0),hl      ;r[i] <- d%b, d <- d/b
         ld a,iyl
         or iyh
         jr z,l4

         add hl,de
         jr nc,lnc

         inc bc
lnc      ex de,hl
         pop hl
         xor a       ;sets CY=0
         sbc hl,de
         ex de,hl
         pop hl
         sbc hl,bc
         srl h
         rr l
         rr d
         rr e

         push hl
         push de
         jp loop2

l4       pop hl
         pop hl
         ld h,b
         ld l,c
         ld bc,10000
         call div32x16r
         ld bc,(cv)
         ld (cv),hl     ;c <- d%10000
         ld h,b
         ld l,c

         add hl,de   ;c + d/10000
         call PR0000
         ld hl,(kv)      ;k <- k - 14
         ld de,-14
         add hl,de
         ld a,h
         or l
         ret z

         ld (kv),hl
         jp loop
         endp

PR0000  proc
        local PRD,PR0
        ld de,-1000
	CALL PR0
	ld de,-100
	CALL PR0
	ld de,-10
	CALL PR0
	ld A,L
PRD	add a,$30
        ;push hl
        jp OSWRCH
        ;pop hl
        ;ret

PR0	ld A,$FF
	ld B,H
	ld C,L
	inc A
	add HL,DE
	jr C,$-4

	ld H,B
	ld L,C
	JR PRD
        endp

div32x16r proc
     local t,t0,t1,t2,t3
     call t
     ld bc,0
     ret
t
     DEC   BC
     LD    A, B
     CPL
     LD    B, A
     LD    A, C
     CPL
     LD    C, A
     call t0
t0
     call t1
t1
     call t2
t2
     call t3
t3
     div
     RET
     endp

cv dw 0
kv dw 0

         org ($ + 256) and $ff00
include "mul10000.s"
ra
  end start
