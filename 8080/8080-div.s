;DE = 0 - BC, new algo
;blackmirror's algo is used for $ff<BC<$8000

div1x macro px,py
     local t1,t2
     adc a,a
     jp c,px

     add hl,hl
py   jp c,t1

     ld e,a
     LD    A,L
     ADD   A,C
     LD    A,H
     ADC   A,B
     ld a,e
     jp    NC,t2
t1
     ADD   HL,BC
     scf
t2
endm

div1xs macro px,py
px   add hl,hl
     inc l
     jp py
endm

divzssz macro px
     adc a,a
     add hl,hl
     add hl,de
     jp nc,px
endm

divzasz macro px
     adc a,a
     add hl,hl
     add HL,BC
     jp c,px
endm

divze macro t
    local S1,S2,S3,S4,S5,S6,S7,S8,A1,A2,A3,A4,A5,A6,A7,A8,l1
    add hl,hl
    add hl,bc
    jp c,S1

A1: divza##t S2
A2: divza##t S3
A3: divza##t S4
A4: divza##t S5
A5: divza##t S6
A6: divza##t S7
A7: divza##t S8
A8: adc a,a
    jp l1

S1: divzs##t A2
S2: divzs##t A3
S3: divzs##t A4
S4: divzs##t A5
S5: divzs##t A6
S6: divzs##t A7
S7: divzs##t A8
S8: adc a,a
    add hl,de
l1
    endm

divxxz macro pxh,pxl,pxr ;hlMM/bc = Ma, hlde%bc = hl, hl < bc, 253 < bc < 32769, de = 0-bc
    local l1,l2,l3
    add hl,de
    divze sz
    ld (pxr),a
    ld a,(pxh)   ;high
    add a,l
    ld l,a
    jp nc,l1

    inc h
    jp nz,l1

    add hl,de
    ld a,(pxr)
    inc a
    ld (pxr),a
l1  divze sz
    ld e,a
    ld a,(pxl)    ;low
    add a,l
    ld l,a
    jp nc,l3

    inc h
    jp nz,l3

    inc e
    jp l2

l3  add hl,bc
l2
endm

div32x16 macro  ;BCDE = HLDE/BC, HL = HLDE%BC  ;works wrong if BC>$7fff && HL >= BC
     local DIV320,divminus,mz1,mz2,mz3
     or a         ;CF=0
     jp z,div32x8

     LD    A, C
     cpl
     jp m,divminus

     LD e,a
     ADD   A, L
     LD    A, B
     CPL
     LD d,a
     ADC   A, H
     inc c  ;assumes that BC is odd
     JP    NC, DIV320

     ;longdiv

     ld hl,0
     divxxz svhl+2,svhl+1,mz2+2
     ld a,e
     ld (mz2+1),a
     xor a
     sub c
     ld e,a
     divxxz svde+2,svde+1,mz1+1
mz1  ld d,0
mz2  ld bc,0
     jp enddivision

div32x8 inc c
        jp m,div32x8e
include "8080-div8.s"

divminus      ;hl < bc
     LD c,a
     LD    A, B
     CPL
     LD b,a
;needs additional 16 iterations for hl >= bc
     ld a,d
     div1x lx0,ly0
     div1x lx1,ly1
     div1x lx2,ly2
     div1x lx3,ly3
     div1x lx4,ly4
     div1x lx5,ly5
     div1x lx6,ly6
     div1x lx7,ly7
     adc a,a
     ld d,a
     ld a,(svde+1)
     div1x lz0,lw0
     div1x lz1,lw1
     div1x lz2,lw2
     div1x lz3,lw3
     div1x lz4,lw4
     div1x lz5,lw5
     div1x lz6,lw6
     div1x lz7,lw7
     adc a,a
     ld e,a
     jp enddivision1

     div1xs lx0,ly0
     div1xs lx1,ly1
     div1xs lx2,ly2
     div1xs lx3,ly3
     div1xs lx4,ly4
     div1xs lx5,ly5
     div1xs lx6,ly6
     div1xs lx7,ly7
     div1xs lz0,lw0
     div1xs lz1,lw1
     div1xs lz2,lw2
     div1xs lz3,lw3
     div1xs lz4,lw4
     div1xs lz5,lw5
     div1xs lz6,lw6
     div1xs lz7,lw7

DIV320
     divxxz svde+2,svde+1,mz3+1
mz3  ld d,0
enddivision1
     LD    BC, 0
enddivision
     endm

