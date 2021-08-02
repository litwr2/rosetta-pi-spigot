div3   .macro
	rol remainder
	rol

        cmp divisor+1
        bcc l1
        bne l2

        ldx remainder
        cpx divisor
        bcc l1

l2      tax
        lda remainder
        sbc divisor
        sta remainder
        txa
        sbc divisor+1
l1
.endm

div32x16x
.block
        cpy #0          ;AC =  dividend+3, YR = divisor + 1, XR = divisor, remainder = dividend+2
        bmi lminus
.if DIV8OPT
        beq div32x8
.endif
        ;;lda dividend+3
        cmp divisor+1
        bcc div16
        bne lj

        ;ldx dividend+2
        ldx remainder
        cpx divisor
        bcc div16
lj      jmp div32           ;##+1=2
lminus  jmp div16minus      ;##+1=2
.bend

.if DIV8OPT
div32x8           ;dividend+3 < divisor
        ;ldx divisor
        sty remainder+1
.if CMOS6502
        ;jmp (divjmp,X) ;for CMOS 6502 or 65816, 3 ticks faster,  0.5% faster for 100 digits, 0.01% faster for 3000 - recalculate branches offset!
        .byte $7c           ;##+1=2
        .word divjmp
.endif
.ifeq CMOS6502
         cpx #0
         bmi *+5
         jmp div32x8f      ;##+1=2
         jmp div32x8e      ;##+1=2
.endif
.endif

div16            ;dividend+2 < divisor, CY = 0
        rol dividend+1
        #div3
        rol dividend+1
        #div3
        rol dividend+1
        #div3
        rol dividend+1
        #div3
        rol dividend+1
        #div3
        rol dividend+1
        #div3
        rol dividend+1
        #div3
        rol dividend+1
        #div3
        rol dividend+1

        rol dividend
        #div3
        rol dividend
        #div3
        rol dividend
        #div3
        rol dividend
        #div3
        rol dividend
        #div3
        rol dividend
        #div3
        rol dividend
        #div3
        rol dividend
        #div3
        ;rol dividend

        sta remainder+1
        ;lda dividend+2
        ldy #0
        sty dividend+2
	sty dividend+3
        rol dividend
        ;sta remainder
enddivision7
        lda remainder
enddivision

