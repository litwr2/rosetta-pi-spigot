div32x16x
.block
        ldy divisor+1    ; AC =  dividend+3 !
        beq div32x8
        bpl lplus
        jmp div16minus   ;CY=0 !
lplus
        ;;lda dividend+3
        cmp divisor+1
        bcc div16
        bne lj

        ldx dividend+2
        cpx divisor
        bcc div16
lj      jmp div32
.bend

div32x8           ;dividend+3 < divisor
        ldx divisor
        sty remainder+1
        stx mjmp+1
mjmp    jmp (divjmp)


div16            ;dividend+2 < divisor, CY = 0
.block
cnt  .var 8
loop3 .lbl
.block
	rol dividend+1
       	rol dividend+2	;dividend lb & hb*2, msb -> Carry
	rol	
	cmp divisor+1
        bcc l1
        bne l2

        ldx dividend+2
        cpx divisor
        bcc l1

l2      tax
        lda dividend+2
        sbc divisor
        sta dividend+2
        txa
        sbc divisor+1
	;inc quotient	;and INCrement quotient cause divisor fit in 1 times
l1
.bend
cnt  .var cnt-1
     .ifne cnt
     .goto loop3
     .endif
.bend
        rol dividend+1
.block
cnt  .var 8
loop3 .lbl
.block
        rol dividend	;remainder lb & hb * 2 + msb from carry
       	rol dividend+2	;dividend lb & hb*2, msb -> Carry
	rol	
	cmp divisor+1
        bcc l1
        bne l2

        ldx dividend+2
        cpx divisor
        bcc l1

l2      tax
        lda dividend+2
        sbc divisor
        sta dividend+2
        txa
        sbc divisor+1
	;inc quotient	;and INCrement quotient cause divisor fit in 1 times
l1
.bend
cnt  .var cnt-1
     .ifne cnt
     .goto loop3
     .endif
.bend
enddivision3
        sta remainder+1
        lda dividend+2
        ldy #0
        sty dividend+2
	sty dividend+3
enddivision4
        rol dividend
enddivision2
        sta remainder
enddivision

