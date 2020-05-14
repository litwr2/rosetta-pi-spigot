div0 macro
     local t1,t2
     ex de,hl
     add hl,hl
     ex de,hl
     ld a,l
     adc a,l
     ld l,a
     ld a,h
     adc a,h
     ld h,a
     jp c,t1

     LD    A,L
     ADD   A,C
     LD    A,H
     ADC   A,B
     jp nc,t2
t1
     ADD   HL,BC
     inc e
t2
endm

div1 macro
     local t1,t2
     ld a,l
     adc a,a
     ld l,a
     ld a,h
     adc a,a
     ld h,a
     jp c,t1

     LD    A,L
     ADD   A,C
     LD    A,H
     ADC   A,B
     jp    NC,t2
t1
     ADD   HL,BC
     scf
t2
endm

divz macro
    local l1,l2
    ADD HL,HL
    EX DE,HL
    ADD HL,HL
    EX DE,HL
    JP NC,l1

    INC L
l1  LD  A,L
    ADD A,C
    LD  A,H
    ADC A,B
    JP NC,l2

    ADD HL,BC
    INC E
l2
endm

divx macro
rept 16
     divz
endm
endm

div32x16 macro  ; BCDE = HLDE/BC, HL = HLDE%BC
     local DIV320,divminus ;may work wrong if HL>$7fff
     ;DEC   BC    ;assumes that BC is odd
     LD    A, B
     dec c
     or a         ;CF=0
     CPL
     LD    B, A
     LD    A, C
     CPL
     LD    C, A
     jp m,divminus

     ADD   A, L
     LD    A, B
     ADC   A, H
     JP    NC, DIV320

     PUSH DE    ;longdiv
	 EX DE,HL
	 LD HL,0
	 divx
	 EX DE,HL
	 EX (SP),HL
	 EX DE,HL
	 divx
	 POP BC
     jp enddivision

divminus
rept 8
     ld a,d
     rla
     ld d,a
     div1
endm
     ld a,d
     rla
     ld d,a
rept 8
     ld a,e
     rla
     ld e,a
     div1
endm
     ld a,e
     rla
     ld e,a
     jp enddivision1

DIV320
     divx
enddivision1
     LD    BC, 0
enddivision
     endm

