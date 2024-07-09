;the DE complement is not used, IX is not used
OPT equ 5    ;a max number of leading zeros in the dividend: 0 = min, 8 - max
DIV8 equ 0   ;1 is faster for 100 digits but slower for 1000 and more
FASTLARGE equ 1

;OPT=5 for maxD<=9360
;OPT=6 for maxD<=7792
;OPT=7 for maxD<=4072

divzss macro px
     adc a,a
     adc hl,hl
     sbc HL,BC
     ccf
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
    ld a,d
    divze t
    ld d,a
    ld a,e
    divze t
    ld e,a
endm

divzsx macro px
    local l1,l2
    adc a,a
    adc hl,hl
    jr c,l1

    sbc hl,bc
    ccf
    jp nc,px
    jp l2
l1
    or a
    sbc hl,bc
    ;scf
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

divzap1 macro px,py,pz,pj
    pz a,a
    adc hl,hl
    pj nc,py

    add hl,bc
    jp c,px
endm

divzsp1 macro px,py,pj
    adc a,a
    adc hl,hl
    pj c,py

    sbc hl,bc
    ccf
    jp nc,px
endm

divzap2 macro px,py,pj
    add hl,bc
    divzap1 px,py,add,pj
endm

divzsp2 macro px,py,pj
    or a
    sbc hl,bc
    divzsp1 px,py,pj
endm

divzsp3 macro
    adc a,a
    jp lx
endm

divzap3 macro
    adc a,a
    add hl,bc
    jp lx
endm

divzp macro
    local S2,S3,S4,S5,S6,S7,S8,A1,A2,A3,A4,A5,A6,A7,A8,lx
    local L1,L2,L3,L4,L5,L6,L7,L9,L10,L11,L12,L13,L14,L15,L16
    divzsp1 A1,L9,jr
    divzsp1 A2,L10,jp
S2: divzsp1 A3,L11,jp
S3: divzsp1 A4,L12,jp
S4: divzsp1 A5,L13,jp
S5: divzsp1 A6,L14,jp
S6: divzsp1 A7,L15,jp
S7: divzsp1 A8,L16,jp
S8: divzsp3
L9: divzsp2 A2,L10,jr
    divzsp1 A3,L11,jp
    divzsp1 A4,L12,jp
    divzsp1 A5,L13,jp
    divzsp1 A6,L14,jp
    divzsp1 A7,L15,jp
    divzsp1 A8,L16,jp
    divzsp3
L10:divzsp2 A3,L11,jr
    divzsp1 A4,L12,jr
    divzsp1 A5,L13,jp
    divzsp1 A6,L14,jp
    divzsp1 A7,L15,jp
    divzsp1 A8,L16,jp
    divzsp3
L11:divzsp2 A4,L12,jr
    divzsp1 A5,L13,jr
    divzsp1 A6,L14,jr
    divzsp1 A7,L15,jp
    divzsp1 A8,L16,jp
    divzsp3
L12:divzsp2 A5,L13,jr
    divzsp1 A6,L14,jr
    divzsp1 A7,L15,jr
    divzsp1 A8,L16,jr
    divzsp3
L13:divzsp2 A6,L14,jr
    divzsp1 A7,L15,jr
    divzsp1 A8,L16,jr
    divzsp3
L14:divzsp2 A7,L15,jr
    divzsp1 A8,L16,jr
    divzsp3
L15:divzsp2 A8,L16,jr
    divzsp3
L16:or a
    sbc hl,bc
    adc a,a
    jp lx

A1: divzap1 S2,L1,adc,jr
A2: divzap1 S3,L2,adc,jr
A3: divzap1 S4,L3,adc,jp
A4: divzap1 S5,L4,adc,jp
A5: divzap1 S6,L5,adc,jp
A6: divzap1 S7,L6,adc,jp
A7: divzap1 S8,L7,adc,jp
A8: divzap3
L1: divzap2 S3,L2,jr
    divzap1 S4,L3,adc,jr
    divzap1 S5,L4,adc,jp
    divzap1 S6,L5,adc,jp
    divzap1 S7,L6,adc,jp
    divzap1 S8,L7,adc,jp
    divzap3
L2: divzap2 S4,L3,jr
    divzap1 S5,L4,adc,jr
    divzap1 S6,L5,adc,jr
    divzap1 S7,L6,adc,jp
    divzap1 S8,L7,adc,jp
    divzap3
L3: divzap2 S5,L4,jr
    divzap1 S6,L5,adc,jr
    divzap1 S7,L6,adc,jr
    divzap1 S8,L7,adc,jr
    divzap3
L4: divzap2 S6,L5,jr
    divzap1 S7,L6,adc,jr
    divzap1 S8,L7,adc,jr
    divzap3
L5: divzap2 S7,L6,jr
    divzap1 S8,L7,adc,jr
    divzap3
L6: divzap2 S8,L7,jr
    divzap3
L7: add hl,bc
    add a,a
    add hl,bc
lx:
endm

divxxp macro
    ld a,d
    divzp
    ld d,a
    ld a,e
    divzp
    ld e,a
endm

div32x16 macro  ;BCDE = HLDE/BC, HL = HLDE%BC
     local DIV320,divminus ;works wrong if BC>$7fff && HL >= BC
     LD    A, B
     or a         ;CF=0
if DIV8
     jp z,div32x8
endif
     jp m,divminus

if 0
     ld a,l
     sub c
     LD    A, h
     sbc   A, b
     JP    C, DIV320
else
     proc
     local l2
     sub h
     jr c,l2
     jp nz,DIV320

     ld a,l
     sub c
     JP    C, DIV320
l2:  endp
endif
     PUSH  DE  ;longdiv

if OPT < 3
rept OPT
     sla h
     LD de,0
endm
endif
if OPT > 2 && OPT < 8
     xor a  ;sets CF=0
     ld d,a
     ld e,a
     ld a,h
rept OPT
     rlca   ;sets CF=0
endm
     ld h,a
endif
if OPT=8
     ld de,0
endif

     EX    DE, HL
     ld a,d    ;assert C = 0

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
     ld d,a
     ld a,e
     divze s
     ld e,a
     EX    DE, HL
     EX    (SP), HL
     EX    DE, HL

     divxx s
     POP   BC
     jp enddivision

if DIV8
div32x8 or c
        jp m,div32x8e
include "z80-div8.s"
endif

divminus      ;hl < bc
if FASTLARGE
     divxxp
else
     divxx x
endif
;needs additional 16 iterations for hl >= bc
     jp enddivision1

DIV320
     divxx s
enddivision1
     LD    BC, 0
enddivision
     endm

