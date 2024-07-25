;for pasmo assembler
;it is for CP/M 3 of the Amstrad CPC6128, it uses the Amstrad CPC6128 firmware
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

;ivagor supplied very valuable information
;the idea of fast Z80 division was discovered by blackmirror
;litwr made the spigot for the Amstrad CPC
;tricky and BigEd provided some help
;MMS gave some support

kl_time_please equ &bd0d
BDOS equ 5
IO equ 1
PSP equ $140   ;64 bytes for the stack/interrupts
MINUS equ 1  ;0 - if dividers are positive, this is ok up to 4680 digits

;DIG equ 100
;N equ DIG/2*7   ;8500 digits

include "z80-div.s"

      ORG 0100h
start    proc
         local lf0,loop,l4,loop2,m1,l1
;; get address of routine to call to execute a firmware function
  ld hl,(1)   ;setup firmware services: timer, ...
  ld de,&57
  add hl,de
  ld (firm_jump+1),hl

    ld de,-ra
    ld hl,(BDOS+1)
    add hl,de
    ld de,0
    ex de,hl
    ld bc,7
    call div32x16r
    ld a,e
    and 0fch
    ld l,a
    ld h,d
    push hl
    ld (maxnum),hl
    ld de,msg1
    ld c,9
    call BDOS

    pop hl
    call PR0000

    ld de,msg2
    ld c,9
    call BDOS

    call getnum
    push hl
    ld de,msg4
    ld c,9
    call BDOS
    pop hl

    ld a,l
    and 0fch
    cp l
    jr z,l1

    add a,4
    ld l,a
    push hl
    call PR0000
    ld de,msg3
    ld c,9
    call BDOS
    pop hl

l1  ld d,h
    ld e,l
    add hl,hl
    add hl,de
    add hl,hl
    add hl,de
    srl h
    rr l
    ld sp,PSP
    push hl

    call firm_jump
    dw kl_time_please
    ld (time),hl
    ld (time+2),de

        ;ld e,12  ;clear screen
        ;ld c,2
        ;call BDOS

     pop bc      ;fill r-array
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

         ;ld (cv),bc
loop     ld hl,0          ;d <- 0
         push hl
         push hl
         ld hl,(kv)          ;i <-k
         add hl,hl        ;keeps 2*i
         ld a,l
         ld iyl,a
         ld a,h
         ld iyh,a
         ld bc,ra
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
         ld h,b
         ld l,c
         ld bc,10000
         call div32x16r
         ld bc,(cv)
         ld (cv),hl     ;c <- d%10000
         ld h,b
         ld l,c

         add hl,de   ;c + d/10000
if IO
         call PR0000
endif
         ld hl,(kv)      ;k <- k - 14
         ld de,-14
         add hl,de
         ld a,h
         or l
         jr z,showtimer

         ld (kv),hl
         jp loop
showtimer
        LD  e,' '
        ld c,2
        call BDOS

        call firm_jump
    dw kl_time_please
    ld bc,(time)
    xor a
    sbc hl,bc
    ex de,hl
    ld bc,(time+2)
    sbc hl,bc
    ld bc,300
    call div32x16r
	PUSH HL
	EX DE,HL
	call PR00000
	LD  e,'.'
        ld c,2
        call BDOS
	POP hl
        push hl     ;*100/3
        add hl,hl
        add hl,hl
        pop de
        add hl,de
        push hl
        add hl,hl
        add hl,hl
        pop de
        add hl,de
        add hl,hl
        add hl,hl
        ex de,hl
        ld hl,0
        ld bc,3
        call div32x16r
        ld a,l
        cp 2
        jr c,$+3
        inc de
        ex de,hl
	call PR0000
        rst 0
         endp

PR00000 proc
        local PRD,PR0
        ld de,-10000
	CALL PR0
PR0000  ld de,-1000
	CALL PR0
	ld de,-100
	CALL PR0
	ld de,-10
	CALL PR0
	ld A,L
PRD	add a,$30
        ld e,a
        ld c,2
        push hl
        call BDOS
        pop hl
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
        endp

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

firm_jump
  jp 0

cv dw 0
kv dw 0
time dw 0,0

         org ($ + 255) and $ff00
include "mul10000.s"

ra
msg1  db 'number ',165,' calculator v14',13,10
      db 'it may give 4000 digits in less than an hour!'
      db 13,10,'number of digits (up to $'
msg2  db ')? $'
msg3  db ' digits will be printed'
msg4  db 13,10,'$'
del   db 8,' ',8,'$'
maxnum dw 0
getnum proc
local l0,l1,l5,l8
        ld b,0  ;length
        ld hl,0 ;number
l0      push hl
        push bc
        ld c,6   ;direct console i/o
        ld e,0fdh
        call BDOS
        pop bc
        pop hl

        cp 13
        jr z,l5

        cp 07fh    ;backspace
        jr z,l1

        cp '0'
        jr c,l0

        cp '9'+1
        jr nc,l0

        ld c,a
        ld a,b
        cp 4
        ld a,c
        jr z,l0

        push hl
        inc b

        ld e,a
        sub '0'
        ld c,a
        push bc
        ld c,2   ;conout
        call BDOS
        pop bc
        pop hl
        push hl
        push hl
        add hl,hl
        add hl,hl
        pop de
        add hl,de
        add hl,hl   ;*10
        ld e,c
        ld d,0
        add hl,de
        jr l0

l1      ld a,b
        or a
        jr z,l0

        dec b
        push bc
        ld c,9
        ld de,del
        call BDOS
        pop bc
        pop hl
        jr l0

l5      ld a,b
        or a    ;sets CF=0
        jr z,l0

        ld a,h
        or l
        jr z,l0

        push hl
        ld de,(maxnum)
        inc de
        sbc hl,de
        pop hl
        jr nc,l0

l8      pop de
        djnz l8
        ret
endp
  end start
