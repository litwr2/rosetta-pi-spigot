;for pasmo assembler
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

;the fast 32/16-bit division was made by Ivagor for the z80
;litwr made the spigot for the ABC 800 series
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped too

CONWRITE equ $B    ;print a string (HL - ptr, BC - length)

NOD equ 100    ;NUMBER OF DIGITS
N equ 7*NOD/2
SA equ $8000  ;start address
OPT equ 5    ;it's a constant for the pi-spigot
DIV8 equ 0   ;8 bit divisor specialization, it makes faster 100 digits but slower 1000 and 3000

include "z80-div.s"

         org SA
start    proc
         local lf0,loop,l4,loop2,m1
    di
    ld hl,($fff2)
    ld de,($fff4)
    ei
    ld (time),hl
    ld (time+2),de
    push iy

         ld bc,N        ;fill r-array
         ld (kv),bc  ;k <- N
    dec bc
    ld a,c
    cpl
    ld c,a
    ld a,b
    cpl
    ld b,a
         ld de,2000
         ld hl,ra+2

lf0      ld (hl),e
         inc l
         ld (hl),d
         inc hl
         inc c
         jr nz,lf0

         inc b
         jr nz,lf0

         ld (cv),bc
loop     ld hl,0          ;d <- 0
         push hl
         push hl
         ld hl,(kv)          ;i <-k
         add hl,hl        ;keeps 2*i
         ld a,l
         ld iyl,a
         ld a,h
         ld iyh,a
         jp loop2

l4       add hl,de
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
         dec iyl

         push hl
         push de
         div32x16
m1       ld (0),hl      ;r[i] <- d%b, d <- d/b
         ld a,iyl
         or iyh
         jp nz,l4

         pop hl
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
         ld (kv),hl
         jp nz,loop

    di
    ld hl,($fff2)
    ld de,($fff4)
    ei
    ld (ra),hl
    ld (ra+2),de
    pop iy
         ret
         endp


PR0000  proc   ;prints HL, uses IY,DE,BC,HL,AF
        local PRD,PR0,PRX,buf
    ld iy,buf
    call PRX
    ld hl,buf
    ld bc,4
    jp CONWRITE

PRX ld de,-1000
	CALL PR0
	ld de,-100
	CALL PR0
	ld de,-10
	CALL PR0
	ld A,L
PRD	add a,$30
    ld (iy),a
    inc iy
        ret

PR0	ld A,$FF
	ld B,H
	ld C,L
	inc A
	add HL,DE
	jr C,$-4

	ld H,B
	ld L,C
	JR PRD

buf db 0,0,0,0
        endp

if DIV8
div32x8
        or c
        jp m,div32x8e
include "z80-div8.s"
endif

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
     div0
     RET
     endp

;div32x16e
;     div32x16
;     ret

cv dw 0
kv dw 0
time dw 0,0

         org ($ + 255) and $ff00
include "mul10000.s"

ra db 0
  end start
