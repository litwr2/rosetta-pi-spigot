;for pasmo assembler
;for 8080 CP/M
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

;the fast 32/16-bit division was made by Ivagor for z80
;litwr made the spigot for several the z80 and 8080 based computers
;bqt helped much with optimization
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped too

BIOS_OUTPUT equ 1   ;1 will not support redirection on, for instance, PCW or C128
CPM3TIMER equ 0
IO equ 1

GENERIC equ 0       ;for generic CP/M 2.2, it doesn't use timer - use stopwatch
KORVET equ 0
AMSTRADCPC equ 1

if GENERIC + KORVET + AMSTRADCPC != 1
show ERROR
endif
if CPM3TIMER > 1
show ERROR
endif
if BIOS_OUTPUT + GENERIC > 1
show ERROR
endif

BDOS equ 5

;Amstrad CPC
ENTER_FIRMWARE equ $BE9B
KL_TIME_PLEASE equ $BD0D

;N equ 3500   ;1000 digits
;N equ 2800  ;800 digits
N equ 8500/2*7   ;8500 digits

include "8080-div.s"

      ORG 0100h
start    proc
         local lf0,loop,l4,loop2,m1,l1

if BIOS_OUTPUT
   ld hl,(1) ;BIOS base table
   push hl    ;subtract 3?
   ld de,9   ;conout offset
   add hl,de
   ld (bios4+1),hl
endif
if KORVET
    ld de,-(ra+64)  ;64 bytes for stack
else
    ld de,-(ra+48)  ;48 bytes for stack
endif
if BIOS_OUTPUT
    pop hl
else
    ld hl,(6)
endif
    ld sp,hl
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
if KORVET
    pop bc
    ld hl,0
    push hl
    add hl,sp
    ld (ssp+1),hl
    ld (ssp2+1),hl
    ex de,hl
    ld hl,(0xf7f1)
    push hl
    ld hl,(KINTR+8)
    push hl
    ex de,hl
    push hl
    ex de,hl
    ld hl,(KINTR+4)
    push hl
    ex de,hl
    push hl
    ld hl,(KINTR)
    push hl
    ld hl,0
    add hl,sp
    ld (0xf7f1),hl
    push bc
endif
         pop hl      ;fill r-array
     ld (kv),hl  ;k <- N
         ld b,h
         ld c,l
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
         jp nz,lf0

         inc b
         jp nz,lf0

         ld a,b
         ld (cv),a
         ld (cv+1),a
loop     ld hl,(kv)          ;i <-k
         add hl,hl        ;keeps 2*i
         ld b,h
         ld c,l
         push hl
         ld hl,0          ;d <- 0
         push hl
         push hl
         jp loop2

l4       add hl,de
         jp nc,lnc

         inc bc
lnc      ex de,hl
         pop hl
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

         pop bc
         push bc
         push hl
         push de
loop2    ld hl,ra
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
         jp nc,noc

         inc hl
noc      add hl,bc

    pop bc
    dec bc     ;i <- i - 1
    dec c      ;bc is odd
    push bc
    ld a,c
    or b
         push hl
         push de
    push af
    inc c
         div32x16
m1       ld (0),hl      ;r[i] <- d%b, d <- d/b
    pop af
         jp nz,l4

         pop hl
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
if KORVET
         ld de,0
         di
ssp      ld hl,(0)
         ex de,hl
ssp2     ld (0),hl
         ei
         ld hl,(time)
         add hl,de
         ld (time),hl
         jp  nc,kl1

         ld hl,(time+2)
         inc hl
         ld (time+2),hl
kl1      
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
        LD  e,' '
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
if KORVET
    di
    pop hl
    pop hl
    pop hl
    pop hl
    pop hl
    pop hl
    ld (0xf7f1),hl
    pop hl
    ei
endif
if GENERIC = 0
     ld hl,(time+2)
     push hl
     ld hl,(time)
     push hl
endif 
if AMSTRADCPC
    call ENTER_FIRMWARE
    dw KL_TIME_PLEASE
endif
if KORVET
    pop hl
    pop de
    ld bc,0
    push bc
    push bc
endif
if GENERIC = 0
     pop bc
     ld a,l
     sub c
     ld l,a
     ld a,h
     sbc a,b
     ld h,a
     ex de,hl
     pop bc
     ld a,l
     sbc a,c
     ld l,a
     ld a,h
     sbc a,b
     ld h,a
endif
if AMSTRADCPC
     ld bc,300
endif
if KORVET
     ld bc,50
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
if KORVET
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
         org ($ + 256) and $ff00
include "../cpc6128/mul10000.s"

ra
msg1  db 'number '

if AMSTRADCPC
      db 165
endif
if GENERIC
      db 'Pi'
endif

      db ' calculator v3',13,10
      db 'for CP/M 2.2 (8080, '

if GENERIC
      db 'Generic'
endif
if AMSTRADCPC
      db 'Amstrad CPC'
endif
if KORVET
      db 'Korvet'
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
if KORVET
KINTR
     push hl
     ld hl,(KTI)
     inc hl
     ld (KTI),hl
     pop hl
KL   jp 0
KTI  ;dw 0
endif
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

if KORVET
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
if CPM3TIMER
days2  dw 0
hours2 db 0
mins2  db 0
secs2  db 0
endif
   end start

