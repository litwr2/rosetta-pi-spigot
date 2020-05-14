div0 macro
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
     inc e
t2
endm

div1 macro
     local t1,t2
     adc hl,hl
     jr c,t1

     LD    A,L
     ADD   A,C
     LD    A,H
     ADC   A,B
     JR    NC,t2
t1
     ADD   HL,BC
     scf
t2
endm

div2 macro
     local t2
     adc hl,hl
     add hl,bc
     JR    C,t2

     sbc HL,BC
t2
endm

divz macro
   adc a,a
   div2
endm

divx macro
   ld a,d
   add a,a
   div2
rept 7
   divz
endm
   adc a,a
   ld d,a
   ld a,e
   add a,a
   div2
rept 7
   divz
endm
   adc a,a
   ld e,a
endm

div32x16 macro  ; BCDE = HLDE/BC, HL = HLDE%BC
     local DIV320,divminus ;may work wrong if HL>$7fff
     ;DEC   BC    ;assumes that BC is odd
     LD    A, B
     or a         ;CF=0
if DIV8
     jp z,div32x8
endif
     jp m,divminus

     dec c
     CPL
     LD    B, A
     LD    A, C
     CPL
     LD    C, A

     ADD   A, L
     LD    A, B
     ADC   A, H
     JP    NC, DIV320

     PUSH  DE  ;longdiv

if OPT=0
     xor a  ;sets CF=0
else if OPT < 3
rept OPT
     sla h
endm
else
     ld a,h
rept OPT
     rlca   ;sets CF=0
endm
     ld h,a
endif
     EX    DE, HL
     LD    HL, 0
rept 8-OPT
     rl d
     div2
endm
     rl d
rept 8
     rl e
     div2
endm
     rl e
     EX    DE, HL
     EX    (SP), HL
     EX    DE, HL

rept 8
     rl d
     div2
endm
     rl d
rept 8
     rl e
     div2
endm
     rl e
     POP   BC
     jp enddivision

divminus
     dec c
     CPL
     LD    B, A
     LD    A, C
     CPL
     LD    C, A

rept 8
     rl d
     div1
endm
     rl d
rept 8
     rl e
     div1
endm
     rl e
     jp enddivision1

DIV320
     divx
enddivision1
     LD    BC, 0
enddivision
     endm

