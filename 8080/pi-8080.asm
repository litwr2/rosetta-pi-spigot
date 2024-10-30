;for pasmo assembler
;for the 8080 under CP/M  version 2.2 or maybe other versions
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
;the idea of fast 32/16 division for the 8080 was discovered by blackmirror
;litwr made the spigot for several the z80 and 8080 based computers
;tricky and BigEd provided some help

;ivagor made a bit faster (2-3%) pi-spigot implementation for the Vector 06C
;but this version doesn't use the standard function for the char output
;and doesn't even support text scrolling
;https://zx-pk.ru/threads/25783-vychislenie-chisla-pi-na-assemblere.html?p=1201523&viewfull=1#post1201523

BIOS_OUTPUT equ 1   ;1 is faster but it does not support redirection on CP/M+
CPM3TIMER equ 0     ;don't use 1, the supported systems can't use this timer
IO equ 1
PSP equ $100        ;use DTA for the stack
MINUS equ 1  ;0 - if dividers are positive, this is ok up to 4680 digits

GENERIC equ 0       ;for generic CP/M, it doesn't use timer - use stopwatch
CORVETTE equ 0
AMSTRADCPC equ 0
VECTOR06 equ 1

if GENERIC + CORVETTE + AMSTRADCPC + VECTOR06 != 1
show ERROR
endif
if CPM3TIMER > 0
show ERROR
endif

BDOS equ 5

if AMSTRADCPC
ENTER_FIRMWARE equ $BE9B
KL_TIME_PLEASE equ $BD0D
endif

;N equ 1000/2*7   ;1000 digits

include "8080-div.s"

      ORG 0100h
start proc
    local lf0,loop,l1,l4,loop2,m1
if BIOS_OUTPUT
   ld hl,(1) ;BIOS base table
   ex de,hl
   ld hl,9   ;conout offset
   add hl,de
   ld (bios4+1),hl
endif
if BIOS_OUTPUT and VECTOR06=0
    ex de,hl  ;subtract 3?
else
    ld hl,(BDOS+1)
endif
    ld de,-ra
    ld sp,PSP
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
    jp z,l1

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
    ld a,h
    rra
    ld h,a
    ld a,l
    rra
    ld l,a
    push hl

if VECTOR06
    ld hl,($39)  ;start timer
    ld de,irqe
    ld a,(hl)
    ld (de),a
    di
    ld (hl),$c3   ;the JP instruction
    inc hl
    inc de
    ld a,(hl)
    ld (hl),low(irqp)
    ld (de),a
    inc hl
    inc de
    ld a,(hl)
    ld (hl),high(irqp)
    ld (de),a
    inc hl
    inc de
    inc de
    ex de,hl
    ld (hl),e
    inc hl
    ld (hl),d
    ei
endif
if CPM3TIMER
    ld c,69h
    ld de,days1
    call BDOS
    ld (secs1),a
endif
if AMSTRADCPC
    call ENTER_FIRMWARE
    dw KL_TIME_PLEASE
    ld (time),hl
    ld (time+2),de
endif
if CORVETTE
    ld hl,($f7d0)
    ld (KL+1),hl
    ld hl,KINTR
    ld ($f7d0),hl
endif
         pop hl      ;fill r-array
    ld (kv),hl  ;k <- N
     dec hl
     ld a,l
     cpl
     ld c,a
     ld a,h
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
         jp nz,lf0

         ld l,b
         ld h,b
         ld (cv),hl
loop     ld hl,(kv)          ;i <-k
         add hl,hl        ;keeps 2*i
         push hl
         ld bc,ra
         add hl,bc
         ld bc,0          ;d <- 0
         push bc
         push bc
         jp loop2

l4       add hl,de
         jp nc,$+4
         inc bc
         ex de,hl
svde     ld hl,0
         ld a,l
         sub e
         ld l,a
         ld a,h
         sbc a,d
         ld h,a
         ex de,hl
         pop hl
         ld a,l
         sbc a,c
         ld l,a
         ld a,h
         sbc a,b
         rra            ;it assumes no carry
         ld h,a
         ld a,l
         rra
         ld l,a
         ld a,d
         rra
         ld d,a
         ld a,e
         rra
         ld e,a

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
         ld (svde+1),hl
         ex de,hl
         pop hl
         jp nc,$+4
         inc hl
         add hl,bc
         pop bc
         dec bc     ;i <- i - 1
         dec c      ;bc is odd
         push bc
         ld a,b
         push hl
         push af
         div32x16
m1       ld (0),hl      ;r[i] <- d%b, d <- d/b
         pop af
         jp nz,l4

         or a
         jp nz,l4

         pop hl
         pop hl
if IO
         ld h,b
         ld l,c
         ld bc,10000
         call div32x16r
         ld a,(cv)
         ld c,a
         ld a,(cv+1)
         ld (cv),hl     ;c <- d%10000
         ld h,a
         ld l,c

         add hl,de   ;c + d/10000
         call PR0000
endif
         ld hl,(kv)      ;k <- k - 14
         ld de,-14
         add hl,de
         ld a,h
         or l
         jp z,showtimer

         ld (kv),hl
         jp loop
showtimer
if BIOS_OUTPUT
        ld c,' '
        call bios4
else
        LD e,' '
        ld c,2
        call BDOS
endif
if CPM3TIMER
      ld c,69h
      ld de,days2
      call BDOS
      ld hl,secs1
      ld b,a
      ld a,9ah
      sub (hl)
      add a,b
      daa
      jp c,lct7

      sub 40h
lct7  ld (hl),a
      dec hl
      ld a,(mins2)
      ld b,a
      ld a,99h
      adc a,0
      sub (hl)
      add a,b
      daa
      jp c,lct8

      sub 40h
lct8  ld (hl),a
      dec hl
      ld a,(hours2)
      ld b,a
      ld a,99h
      adc a,0
      sub (hl)
      add a,b
      daa
      jp c,lct9

      sub 76h
lct9  ld (hl),a
endif
if CORVETTE
         ld hl,(KL+1)
         ld ($f7d0),hl
endif
if VECTOR06
    ld hl,($39)  ;stop timer
    ld de,irqe
    di
    ld a,(de)
    ld (hl),a
    inc de
    inc hl
    ld a,(de)
    ld (hl),a
    inc hl
    inc de
    ld a,(de)
    ld (hl),a
    ei
endif
if CORVETTE or VECTOR06
         ld hl,(time)
         ex de,hl
         ld hl,(time+2)
     ld bc,50
endif
if AMSTRADCPC
    call ENTER_FIRMWARE
    dw KL_TIME_PLEASE
     ld bc,(time)
     xor a
     sbc hl,bc
     ex de,hl
     ld bc,(time+2)
     sbc hl,bc
     ld bc,300
endif
if GENERIC = 0
     call div32x16r
	PUSH HL
	EX DE,HL
	call PR00000
if BIOS_OUTPUT
        ld c,'.'
        call bios4
else
	LD  e,'.'
        ld c,2
        call BDOS
endif
	POP hl
endif
if AMSTRADCPC
        ld bc,100   ;10000/300 = 100/3
        call mul16
        ld hl,0
        ld bc,3
        call div32x16r
        ld a,l
        cp 2
        jp c,$+3
        inc de
endif
if CORVETTE or VECTOR06
	        ld bc,200    ;10000/50 = 200
        call mul16
endif
                    ;*10000/freq
if GENERIC = 0
             ex de,hl
	call PR0000
endif
if CPM3TIMER
      ld e,' '
      ld c,2
      call BDOS

      ld hl,0
      ld (ra),hl
      ld (ra+2),hl
      ld hl,hours1
      ld a,(hl)
      ld bc,ra+1
lct2  or a
      jp z,lct1

      ld a,(bc)
      add a,36h
      daa
      ld (bc),a
      inc bc
      ld a,(bc)
      adc a,0
      daa
      ld (bc),a
      ld a,(hl)
      sub 1
      daa
      ld (hl),a
      dec bc
      jp lct2

lct1  inc hl
      dec bc
      ld a,(hl)
lct3  or a
      jp z,lct4

      ld a,(bc)
      add a,60h
      daa
      ld (bc),a
      inc bc
      ld a,(bc)
      adc a,0
      daa
      ld (bc),a
      inc bc
      ld a,(bc)
      adc a,0
      daa
      ld (bc),a
      ld a,(hl)
      sub 1
      daa
      ld (hl),a
      dec bc
      dec bc 
      jp lct3

lct4  inc hl
      ld a,(bc)
      add a,(hl)
      daa
      ld (bc),a
      inc bc
      ld a,(bc)
      adc a,0
      daa
      ld (bc),a
      inc bc
      ld a,(bc)
      adc a,0
      daa
      ld (bc),a
      or a
      jp z,lct5

      call print_bcd
lct5  ld a,(ra+1)
      push af
      rrca
      rrca
      rrca
      rrca
      call print_bcd
      pop af
      call print_bcd
      ld a,(ra)
      push af
      rrca
      rrca
      rrca
      rrca
      call print_bcd
      pop af
      call print_bcd
endif
      rst 0
	endp

if CPM3TIMER
print_bcd
      and 0fh
      or 30h
      ld e,a
      ld c,2
      jp BDOS
endif

if VECTOR06
irqp
    push hl
    push af
    ld hl,time
    inc (hl)
    jp nz,irqf
    inc hl
    inc (hl)
    jp nz,irqf
    inc hl
    inc (hl)
irqf
    pop af
    pop hl
irqe
    nop
    nop
    nop
    jp 0
endif

PR00000 ld de,-10000
	CALL PR0
PR0000  ld de,-1000
	CALL PR0
	ld de,-100
	CALL PR0
	ld de,-10
	CALL PR0
	ld A,L
PRD	add a,$30
        push hl
if BIOS_OUTPUT
        ld c,a
        call bios4
else
        ld e,a
        ld c,2
        call BDOS
endif
        pop hl
        ret

PR0	ld A,$FF
	ld B,H
	ld C,L
	inc A
	add HL,DE
	jp C,$-4

	ld H,B
	ld L,C
	Jp PRD

if BIOS_OUTPUT
bios4   JP 0
endif

div32x16r proc  ;00de = hlde/bc, hl = hlde%bc
     local t,t0,t1,t2,t3,t4,l1,l2
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
t3   ex de,hl
     add hl,hl
     ex de,hl
     jp c,l1

     ADD   HL, HL
l2   jp c,t4

     LD    A,L
     ADD   A,C
     LD    A,H
     ADC   A,B
     ret    NC
t4
     ADD   HL,BC
     inc e
     RET
l1   add hl,hl
     inc l
     jp l2
     endp

if CORVETTE
KINTR
     push af
     push hl
     ld hl,(time)
     inc hl
     ld (time),hl
     ld a,l
     or h
     jp nz,KIE

     ld hl,(time+2)
     inc hl
     ld (time+2),hl
KIE  pop hl
     pop af
KL   jp 0
endif

if GENERIC = 0
include "8080-mul16.s"
time dw 0,0
endif
cv dw 0
kv dw 0

if CPM3TIMER
days1  dw 0
hours1 db 0
mins1  db 0
secs1  db 0
endif

         org ($ + 255) and $ff00
;include "../amstrad/cpc6128/mul10000.s"
;include "../cpc6128/mul10000.s"
include "mul10000.s"

ra
msg1  
if VECTOR06
      db $f,$d,$a
endif
      db 'number Pi calculator v7',13,10
      db 'for CP/M 2.2 (8080, '
if GENERIC
      db 'Generic'
endif
if AMSTRADCPC
      db 'Amstrad CPC'
endif
if CORVETTE
      db 'Corvette'
endif
if VECTOR06
      db 'Vector-06C'
endif
if CPM3TIMER
      db ', CP/M+ timer'
endif
if BIOS_OUTPUT
      db ', BIOS'
else
      db ', BDOS'
endif
      db ')',13,10,'number of digits (up to $'
msg2  db ')? $'
msg3  db ' digits will be printed'
msg4  db 13,10,'$'
del   db 8,' ',8,'$'
maxnum dw 0

getnum proc
local l0,l1,l5,l8
        ld b,0
        ld hl,0
l0      push hl
        push bc
l00     ld c,6   ;direct console i/o
        ld e,0ffh
        call BDOS
        or a
        jp z, l00

        pop bc
        pop hl

        cp 13
        jp z,l5

if CORVETTE
        cp 8    ;backspace, check the system for this value
else
        cp 07fh    ;backspace
endif
        jp z,l1

        cp '0'
        jp c,l0

        cp '9'+1
        jp nc,l0

        ld c,a
        ld a,b
        cp 4
        ld a,c
        jp z,l0

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
        jp l0

l1      ld a,b
        or a
        jp z,l0

        dec b
        push bc
        ld c,9
        ld de,del
        call BDOS
        pop bc
        pop hl
        jp l0

l5      ld a,b
        or a    ;sets CF=0
        jp z,l0

        ld a,h
        or l
        jp z,l0

        push hl
        ld a,(maxnum)
        sub l
        ld a,(maxnum+1)
        sbc a,h
        pop hl
        jp c,l0

l8      pop de
        dec b
        jp nz,l8
        ret
endp
     org ($ + 1) and $fffe
if CPM3TIMER
days2  dw 0
hours2 db 0
mins2  db 0
secs2  db 0
endif
    end start

