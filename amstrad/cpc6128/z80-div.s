;DE = 0 - BC, IX is used
OPT equ 5    ;a max number of leading zeros in the dividend for the long division, it is always 5 for the RW-spigot
DIV8 equ 0   ;1 is faster for 100 digits but slower for 1000 and more

divzss macro px
     adc a,a
     adc hl,hl
     add hl,de
     jr nc,px
endm

divzas macro px
     adc a,a
     adc hl,hl
     add HL,BC
     jr c,px
endm

divze macro t
    local S2,S3,S4,S5,S6,S7,S8,A1,A2,A3,A4,A5,A6,A7,A8,l1
    divzs##t A1
    divzs##t A2
S2: divzs##t A3
S3: divzs##t A4
S4: divzs##t A5
S5: divzs##t A6
S6: divzs##t A7
S7: divzs##t A8
S8: adc a,a
    jp l1

A1: divza##t S2
A2: divza##t S3
A3: divza##t S4
A4: divza##t S5
A5: divza##t S6
A6: divza##t S7
A7: divza##t S8
A8: adc a,a
    add hl,bc
l1
    endm

divxx macro t
    ld a,ixh
    divze t
    ld ixh,a
    ld a,ixl
    divze t
    ld e,a
    ld d,ixh
endm

divzsx macro px
    local l1,l2
    adc a,a
    adc hl,hl
    jr c,l1

    add hl,de
    jr nc,px
    jp l2
l1
    add hl,de
    scf
l2
endm

divzax macro px
    local l1,l2
    adc a,a
    adc hl,hl
    jr nc,l1

    add hl,bc
    jr c,px
    jp l2
l1
    add hl,bc
    or a
l2
endm

div32x16 macro  ;BCDE = HLDE/BC, HL = HLDE%BC
     local DIV320,divminus,mz1,mz2  ;works wrong if BC>$7fff && HL >= BC
     LD    A, B
if DIV8=1 or MINUS=1
     or a
endif
if DIV8
     jp z,div32x8
endif
     ld ixl,e
     ld ixh,d
     CPL
     LD d,a
     LD    A, C
     cpl
if MINUS
     jp m,divminus
endif
     inc a
     LD e,a

     ADD   A, L
     LD    A, D
     ADC   A, H
     JP    NC, DIV320

     ;longdiv

     ld a,l
     ld (mz1+1),a
if OPT < 3
rept OPT
     sla h
endm
     ld a,h
     ld hl,0
endif
if OPT > 2 && OPT < 8
     xor a  ;sets CF=0
     ld l,a
     ld a,h
rept OPT
     rlca   ;sets CF=0
endm
     ld h,l
endif
if OPT=8
     xor a
     ld l,a
     ld h,a
endif
if OPT=0
     divze s
endif
if OPT=1
     proc
    local S3,S4,S5,S6,S7,S8,A2,A3,A4,A5,A6,A7,A8,l1
    divzss A2
    divzss A3
S3: divzss A4
S4: divzss A5
S5: divzss A6
S6: divzss A7
S7: divzss A8
S8: adc a,a
    jp l1

A2: divzas S3
A3: divzas S4
A4: divzas S5
A5: divzas S6
A6: divzas S7
A7: divzas S8
A8: adc a,a
    add hl,bc
l1: endp
endif
if OPT=2
     proc
    local S4,S5,S6,S7,S8,A3,A4,A5,A6,A7,A8,l1
    divzss A3
    divzss A4
S4: divzss A5
S5: divzss A6
S6: divzss A7
S7: divzss A8
S8: adc a,a
    jp l1

A3: divzas S4
A4: divzas S5
A5: divzas S6
A6: divzas S7
A7: divzas S8
A8: adc a,a
    add hl,bc
l1: endp
endif
if OPT=3
     proc
    local S5,S6,S7,S8,A4,A5,A6,A7,A8,l1
    divzss A4
    divzss A5
S5: divzss A6
S6: divzss A7
S7: divzss A8
S8: adc a,a
    jp l1

A4: divzas S5
A5: divzas S6
A6: divzas S7
A7: divzas S8
A8: adc a,a
    add hl,bc
l1: endp
endif
if OPT=4
     proc
    local S6,S7,S8,A5,A6,A7,A8,l1
    divzss A5
    divzss A6
S6: divzss A7
S7: divzss A8
S8: adc a,a
    jp l1

A5: divzas S6
A6: divzas S7
A7: divzas S8
A8: adc a,a
    add hl,bc
l1: endp
endif
if OPT=5
     proc
    local S7,S8,A6,A7,A8,l1
    divzss A6
    divzss A7
S7: divzss A8
S8: adc a,a
    jp l1

A6: divzas S7
A7: divzas S8
A8: adc a,a
    add hl,bc
l1: endp
endif
if OPT=6
     proc
    local S8,A7,A8,l1
    divzss A7
    divzss A8
S8: adc a,a
    jp l1

A7: divzas S8
A8: adc a,a
    add hl,bc
l1: endp
endif
if OPT=7
     proc
    local A8,l1
    divzss A8
    adc a,a
    jp l1

A8: adc a,a
    add hl,bc
l1: endp
endif
if OPT=8
    adc a,a
endif
     ld (mz2+2),a
mz1  ld a,0
     divze s
     ld (mz2+1),a

     divxx s
mz2  ld bc,0
     jp enddivision

if DIV8
div32x8 or c
        jp m,div32x8e
include "z80-div8.s"
endif

if MINUS
divminus      ;hl < bc
     inc a
     LD e,a
;needs additional 16 iterations for hl >= bc
     divxx x
     jp enddivision1
endif

DIV320
     divxx s
enddivision1
     LD    BC, 0
enddivision
     endm

