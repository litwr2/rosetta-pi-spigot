;for pasmo assembler
;for MSX ROM Basic
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

;the time of the calculation is quadratic, so if T is the time to calculate N digits
;then 4*T is required to calculate 2*N digits
;main loop count is 7*(4+D)*D/16, D - number of digits

;ivagor supplied very valuable information
;the idea of fast Z80 division was discovered by blackmirror
;litwr made the spigot for the Amstrad CPC
;tricky and BigEd provided some help
;MMS gave some support

CHPUT equ $A2    ;print char in A

N equ 3500   ;1000 digits
;N equ 2800  ;800 digits
SA equ $8500  ;start address
R800 equ 0   ;R800 MULUW is 6/10 (8 on average) t-states slower than the table multiplication but it saves 781 bytes

MSX_TIMER equ $FC9E
IO equ 1
MINUS equ 0  ;0 - if dividers are positive, this is ok up to 4680 digits

include "z80-div.s"

         org SA-7
db $fe,low(SA),high(SA),low(ra-1),high(ra-1),low(SA),high(SA)
start    proc
         local lf0,loop,l4,loop2,m1
         ;ld a,12     ;clear screen
         ;call CHPUT

         ld bc,N        ;fill r-array
         ld (kv),bc     ;k <- N
         dec bc
    ld hl,0
    ld (time),hl
    ld (time+2),hl

    ld hl,(MSX_TIMER)
    ld (prevtime),hl
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
         jp nz,lf0

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
         ld bc,ra   ;@EOP@
         add hl,bc
         jp loop2

l4       add hl,de
         jp nc,$+5
         inc bc
         xor a       ;sets CY=0
         ex de,hl
         pop hl
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
         ld hl,(m1+1)
         dec hl
         dec l
loop2    ld (m1+1),hl
if R800
         ld a,(hl)
         inc l
         ld h,(hl)
         ld l,a
         ld bc,10000
         db $ed,$c3           ;MULUW hl,bc
         pop bc
         add hl,bc
         ex de,hl
         pop bc
else
         ld d,(hl)      ;r[i]
         inc l          ;r is at even addr
         ld l,(hl)
         ld h,2+(high(m10000))
         ld b,(hl)
         dec h
         ld c,(hl)
         dec h
         ld a,(hl)
         ld l,d
         ld e,(hl)
         inc h
         add a,(hl)
         ld d,a
         inc h
         ld a,(hl)
         adc a,c
         ld c,a
         jp nc,$+4
         inc b

         pop hl       ; d <- d + r[i]*10000
         add hl,de
         ex de,hl
         pop hl
endif
         adc hl,bc
         dec iy    ;i <- i - 1
         ld b,iyh
         ld c,iyl

         push hl
         push de
         div32x16
m1       ld (0),hl      ;r[i] <- d%b, d <- d/b
         dec iyl
         jp nz,l4

         ld a,iyh
         or a
         jp nz,l4

         pop hl
         pop hl
if IO
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
endif
     ld de,(prevtime)
     ld hl,(MSX_TIMER)
     ld (prevtime),hl
     xor a
     sbc hl,de
     ld de,(time)
     add hl,de
     ld (time),hl
     jr nc,$+9
     ld hl,(time+2)
     inc hl
     ld (time+2),hl

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
        jp CHPUT
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


if IO
div32x16r proc   ;bcde = hlde/bc, hl = hlde%bc
     local t,t0,t1,t2,t3,t4
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
t0   call t1
t1   call t2
t2   call t3
t3   sla e
     rl d
     ADC   HL, HL
     jr c,t4

     LD    A,L
     ADD   A,C
     LD    A,H
     ADC   A,B
     ret nc
t4
     ADD   HL,BC
     inc e
     RET
     endp
endif

cv dw 0
kv dw 0
prevtime dw 0
time dw 0,0   ;@ti0@, @ti1@, @ti2@
dw 0   ;reserved for Basic h, @varh@

         org ($ + 255) and $ff00
if R800=0
include "mul10000.s"
endif
ra
  end start

