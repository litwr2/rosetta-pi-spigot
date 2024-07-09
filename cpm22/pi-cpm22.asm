;for pasmo assembler
;it is for the Tiki-100 KP/M, Amstrad CPC6128 CP/M 2.2, 
;Amstrad PCW8xxx/9xxx CP/M 3, MSX-DOS, Commodore 128 CP/M 3
;Acorn z80 2nd processor CP/M, Torch z80 2nd processor CPN
;it uses Tiki-100 timer, Amstrad CPC firmware, MSX timer,
;MSX (optionally) or Amstrad PCW timer interrupt,
;Commodore 128 Time of Day of CIA1
;TRS-80 Model II/12/16 Pickles and Trout CP/M, Aton CP/M
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

BIOS_OUTPUT equ 1   ;1 will not support redirection on MSX, PCW or C128
CPM3TIMER equ 0
IO equ 1
PSP equ $100   ;use DTA for the stack

TIKI100 equ 0
AMSTRADCPC equ 0
AMSTRADPCW equ 0
C128 equ 0
MSX equ 0
MSX_INTR equ 0         ;use v-sync interrupt, 0 means the use of timer directly
ACORNBBCZ80 equ 0
TORCHBBCZ80 equ 0
PICKLESANDTROUT equ 0   ;TRS-80 model II/12/16
ATON equ 0              ;TRS-80 model II/12/16
GENERIC equ 1       ;for generic CP/M 2.2, it doesn't use timer - use stopwatch

if TIKI100 + AMSTRADCPC + AMSTRADPCW + MSX + C128 + ACORNBBCZ80 + TORCHBBCZ80 + PICKLESANDTROUT + ATON + GENERIC != 1
show ERROR
endif
if AMSTRADCPC + CPM3TIMER > 1
show ERROR
endif
if BIOS_OUTPUT + TORCHBBCZ80 > 1
show ERROR
endif

;Tiki-100
TIKI100_TIMER_LO equ $FF8C
TIKI100_TIMER_HI equ $FF8E
;Amstrad CPC
ENTER_FIRMWARE equ $BE9B
KL_TIME_PLEASE equ $BD0D
;MSX
MSX_TIMER equ $FC9E
MSX_INTR_VECTOR equ $38
;Commodore-128
CIA1TOD equ $DC08
;Acorn BBC Micro z80
OSWORD equ $FFF1
;Torch BBC Micro z80
Cto6502 equ $FFC9
Nto6502 equ $FFC3
Afrom6502 equ $FFC6
;Pickles and Trout CP/M for the TRS-80 Model II
SSF equ $40

BDOS equ 5

;N equ 3500   ;1000 digits
;N equ 2800  ;800 digits
N equ 8500/2*7   ;8500 digits

include "z80-div.s"

      ORG 0100h
start    proc
         local lf0,loop,l4,loop2,m1,l1

if BIOS_OUTPUT
   ld hl,(1) ;BIOS base table
   ld de,-3
   add hl,de
   push hl
   ld de,9+3   ;9 - conout offset
   add hl,de
   ld (bios4+1),hl
endif

if MSX
      ld a,($fcc1)     ;Get main-ROM slot number
      ld hl,$2b       ;Read address #2b
      call $c         ;Call RDSLT
      ei
      bit 7,a
      ld a,60
      jr z,$+4
      ld a,50
      ld (msx_vsync),a
endif

    ld de,-ra
if BIOS_OUTPUT
    pop hl
else
    ld hl,(BDOS+1)
endif
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
    push hl

if CPM3TIMER
    ld c,69h
    ld de,days1
    call BDOS
    ld (secs1),a
endif
if PICKLESANDTROUT
    ld b,0eh   ;read real time clock
    call SSF
    ld (time),de
    ld (time+2),hl
endif
if ATON
    ld de,fcb
    rst 16
    ld hl,(fcb+3)
    ld de,3
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld (time),de
    inc hl
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld (time+2),de
endif
if TIKI100
    ld hl,(TIKI100_TIMER_LO)
    ld (time),hl
    ld hl,(TIKI100_TIMER_HI)
    ld (time+2),hl
endif
if AMSTRADCPC
    call ENTER_FIRMWARE
    dw KL_TIME_PLEASE
    ld (time),hl
    ld (time+2),de
endif
if ACORNBBCZ80
    ld a,2
    ld hl,time
    call OSWORD
endif
if TORCHBBCZ80
    call gettimer
endif
if MSX and MSX_INTR=0
    ld hl,(MSX_TIMER)
    ld (prevtime),hl
endif
if MSX and MSX_INTR=1 or AMSTRADPCW
	LD	HL,(MSX_INTR_VECTOR + 1)    ;interrupt mode 1
	LD	(msx_intr_save + 1),hl
	LD	HL,msx_timer_intr
	LD	(MSX_INTR_VECTOR + 1),HL
endif
if C128
    ld bc,$d011    ;VIC-II off
    in a,(c)
    ld (vicsave+1),a
    ld a,$b
    out (c),a

    ld bc,CIA1TOD+3
    ld hl,time+3
    in a,(c)
    and $7f
    ld (hl),a
    dec hl
    dec bc
    in a,(c)
    ld (hl),a
    dec hl
    dec bc
    in a,(c)
    ld (hl),a
    dec hl
    dec bc
    in a,(c)
    ld (hl),a
    di
endif
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
         jp nz,lf0

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
         jp nc,$+4
         inc bc
         ex de,hl
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
if MSX and MSX_INTR=0
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
      sub (hl)
      daa
      jr nc,lct7

      add a,0c0h
lct7  ld (hl),a
      dec hl
      ld a,(mins2)
      sbc a,(hl)
      daa
      jr nc,lct8

      add a,0c0h
lct8  ld (hl),a
      dec hl
      ld a,(hours2)
      sbc a,(hl)
      daa
      jr nc,lct9

      sub 76h
lct9  ld (hl),a
endif
if PICKLESANDTROUT
    ld b,0eh
    call SSF
    ex de,hl
endif
if ATON
    ld de,fcb
    rst 16
    ld hl,(fcb+3)
    ld de,3
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ex de,hl
endif
if TIKI100
    ld hl,(TIKI100_TIMER_LO)
    ld de,(TIKI100_TIMER_HI)
endif
if AMSTRADCPC
    call ENTER_FIRMWARE
    dw KL_TIME_PLEASE
endif
if ACORNBBCZ80
    ld a,1
    ld hl,time
    call OSWORD
    ld hl,(time)
    ld de,(time+2)
    ld bc,0
    ld (time),bc
    ld (time+2),bc
endif
if TORCHBBCZ80
    ld hl,(time)
    push hl
    ld hl,(time+2)
    push hl
    call gettimer
    ld de,(time+2)
    ld bc,(time)
    pop hl
    ld (time+2),hl
    pop hl
    ld (time),hl
    ld h,b
    ld l,c
endif
if MSX and MSX_INTR=1 or AMSTRADPCW
	LD	hl,(msx_intr_save + 1)
	LD	(MSX_INTR_VECTOR + 1),HL
endif
if MSX or AMSTRADPCW
     ld bc,0
     ld hl,(time)
     ld de,(time+2)
     ld (time+2),bc
     ld (time),bc
endif
if C128
vicsave
    ld a,0   ;VIC-II on
    ld bc,$d011
    out (c),a

    ld bc,CIA1TOD+3
    ld hl,ra+3
    in a,(c)
    and $7f
    ld (hl),a
    dec hl
    dec bc
    in a,(c)
    ld (hl),a
    dec hl
    dec bc
    in a,(c)
    ld (hl),a
    dec bc
    in a,(c)

    ld bc,ra
    ld hl,time
    sub (hl)
    daa
    push af
    and $f
    ld (bc),a
    pop af

    inc hl
    inc bc
    ld a,(bc)
    sbc a,(hl)
    daa
    push af
    jr nc,$+4
    sub $40
    ld (bc),a
    pop af

    inc hl
    inc bc
    ld a,(bc)
    sbc a,(hl)
    daa
    push af
    jr nc,$+4
    sub $40
    ld (bc),a
    pop af

    inc hl
    inc bc
    ld a,(bc)
    sbc a,(hl)
    daa
    jr nc,$+5
    add a,$12
    daa
    ;ld (bc),a
    ld h,0
    ld l,a
    push bc
    ld bc,4500       ;36000/8
    call mul16
    ex de,hl
    pop bc
    dec bc

    push hl
    ld a,(bc)
    push bc
    ld bc,375        ;6000/16
    and $f0
    rrca
    rrca
    rrca
    ld h,0
    ld l,a
    call mul16
    pop bc
    pop hl
    add hl,de

    push hl
    ld a,(bc)
    push bc
    ld bc,75       ;600/8
    and $f
    ld h,0
    ld l,a
    call mul16
    pop bc
    pop hl
    add hl,de
    dec bc

    push hl
    ld a,(bc)
    push bc
    ld bc,25        ;100/4
    and $f0
    rrca
    rrca
    ld h,0
    ld l,a
    call mul16
    pop bc

    push de
    ld a,(bc)
    push bc
    ld bc,10
    and $f
    ld h,0
    ld l,a
    call mul16
    pop bc
    pop hl
    add hl,de
    dec bc

    ld a,(bc)
    ld d,0
    ld e,a
    add hl,de
    ld de,0
    ld (time),de
    ld (time+2),de
    ld b,h
    ld c,l
    pop hl
    add hl,hl
    rl e
    add hl,hl
    rl e
    add hl,hl
    rl e
    add hl,bc
    jr nc,$+3
    inc de
    ei
endif
if GENERIC = 0
     ld bc,(time)
     xor a
     sbc hl,bc
     ex de,hl
     ld bc,(time+2)
     sbc hl,bc
endif
if MSX
     ld bc,(msx_vsync)
endif
if C128
     ld bc,10
endif
if TIKI100
     ld bc,125              ;timer freq, Hz
endif
if AMSTRADCPC or AMSTRADPCW
     ld bc,300
endif
if ACORNBBCZ80 or TORCHBBCZ80 or PICKLESANDTROUT or ATON
     ld bc,100
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
                      ;*10000/freq
if TIKI100
        ld bc,80      ;10000/125 = 80
        call mul16
endif
if ACORNBBCZ80 or TORCHBBCZ80 or PICKLESANDTROUT or ATON
        ld bc,100     ;10000/100 = 100
        call mul16
endif
if AMSTRADCPC or AMSTRADPCW
        ld bc,100   ;10000/300 = 100/3
        call mul16
        ld hl,0
        ld bc,3
        call div32x16r
        ld a,l
        cp 2
        jr c,$+3
        inc de
endif
if C128
        ld bc,1000   ;10000/10
        call mul16
endif
if MSX
        ld a,(msx_vsync)
        cp 60
        jr nz,vsync50

        ld bc,500    ;10000/60 =  500/3
        call mul16
        ld hl,0
        ld bc,3
        call div32x16r
        ld a,l
        cp 2
        jr c,$+3
        inc de
        jr vsync0

vsync50 ld bc,200    ;10000/50 =  200
        call mul16
vsync0
endif
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
      jr z,lct1

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
      jr lct2

lct1  inc hl
      dec bc
      ld a,(hl)
lct3  or a
      jr z,lct4

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
      jr lct3

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
      jr z,lct5

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
if C128
     ld c,0
     jp BDOS
else
        rst 0
endif
         endp

if CPM3TIMER
print_bcd
      and 0fh
      or 30h
      ld e,a
      ld c,2
      jp BDOS
endif

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
	jr C,$-4

	ld H,B
	ld L,C
	JR PRD
        endp

if BIOS_OUTPUT
bios4   JP 0
endif

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

if GENERIC = 0
include "mul16.s"
time dw 0,0
endif

if MSX
msx_vsync db 0,0
endif

if MSX and MSX_INTR=1 or AMSTRADPCW
msx_timer_intr
      push af
      ld a,(time)
      inc a
      ld (time),a
      jp nz,exit_intr

      ld a,(time+1)
      inc a
      ld (time+1),a
      jp nz,exit_intr

      ld a,(time+2)
      inc a
      ld (time+2),a
exit_intr
      pop af
msx_intr_save
      jp 0
endif

if MSX and MSX_INTR=0
prevtime dw 0
endif

if TORCHBBCZ80
gettimer
    call Nto6502
    db 15           ;user command
    call Nto6502
    db 12           ;OSWORD
    call Nto6502
    db 1            ;get timer
    call Nto6502
    db 15
    call Nto6502
    db 13           ;read scratchpad
    call Nto6502
    db 0            ;byte #
    call Afrom6502
    ld l,a
    call Nto6502
    db 15
    call Nto6502
    db 13           ;read scratchpad
    call Nto6502
    db 1            ;byte #
    call Afrom6502
    ld h,a
    ld (time),hl
    call Nto6502
    db 15
    call Nto6502
    db 13           ;read scratchpad
    call Nto6502
    db 2            ;byte #
    call Afrom6502
    ld l,a
    call Nto6502
    db 15
    call Nto6502
    db 13           ;read scratchpad
    call Nto6502
    db 3            ;byte #
    call Afrom6502
    ld h,a
    ld (time+2),hl
    ret
endif
cv dw 0
kv dw 0
if ACORNBBCZ80
   db 0
endif
if ATON
fcb db 7  ;clock
    db 1  ;read
    ds 1  ;any
    dw opstat
    dw timebuf
opstat ds 7
timebuf ds 7
endif
if CPM3TIMER
days1  dw 0
hours1 db 0
mins1  db 0
secs1  db 0
endif
         org ($ + 255) and $ff00
include "../cpc6128/mul10000.s"

ra
msg1  db 'number '

if TIKI100
      db 240
endif
if AMSTRADCPC
      db 184
endif
if C128 or MSX or AMSTRADPCW or ACORNBBCZ80 or TORCHBBCZ80 or PICKLESANDTROUT or GENERIC
      db 'Pi'
endif

      db ' calculator v16',13,10
      db 'for CP/M'
if CPM3TIMER=0
      db ' 2.2'
endif
if CPM3TIMER=0 and AMSTRADCPC=0
     db ' and'
endif
if AMSTRADCPC=0
      db ' 3'
endif
      db ' ('
if GENERIC
      db 'Generic'
endif
if PICKLESANDTROUT
      db 'TRS-80 Model II - Pickles and Trout CP/M'
endif
if ATON
      db 'TRS-80 Model II - Aton CP/M'
endif
if TIKI100
      db 'Tiki-100'
endif
if AMSTRADCPC
      db 'Amstrad CPC'
endif
if AMSTRADPCW
      db 'Amstrad PCW'
endif
if ACORNBBCZ80
      db 'Acorn z80 2nd Co-Pro'
endif
if TORCHBBCZ80
      db 'Torch z80 2nd Co-Pro'
endif
if MSX
      db 'MSX'
endif
if C128
      db 'Commodore 128'
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
        ld b,0  ;length
        ld hl,0 ;number
l0      push hl
        push bc
l00     ld c,6   ;direct console i/o
        ld e,0ffh
        call BDOS
        or a
        jr z,l00

        pop bc
        pop hl

        cp 13
        jr z,l5

if MSX or PICKLESANDTROUT
        cp 8
else ;AMSTRADCPC or AMSTRADPCW or C128 or ACORNBBCZ80 or TORCHBBCZ80 or TIKI100 or ATON
        cp 07fh    ;backspace
endif
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
if CPM3TIMER
days2  dw 0
hours2 db 0
mins2  db 0
secs2  db 0
endif
   end start

