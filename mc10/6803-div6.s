div0 macro
    rolb
	rola
	addd <neg_divisor
        bcs *+4

        subd <neg_divisor
     endm

div32x16x     ;D=A:B - divisor (A - high!)
   if DIV8OPT
        tsta
        beq div8
   endif
        negb     ;assumed that D is odd
        coma
        std <neg_divisor
   if DIVNOMINUS==0
        bmi lplus
        jmp div16minus
   endif

lplus
        addd <dividend
        bcc div16
        jmp div32

   if DIV8OPT
div8
        staa remainder
        tstb
        bmi todiv8e
        jmp div32x8f
todiv8e jmp div32x8e
   endif

div16            ;<dividend+2 < divisor
        ldd <dividend
        asl dividend+2
        div0
        rol dividend+2
        div0
        rol dividend+2
        div0
        rol dividend+2
        div0
        rol dividend+2
        div0
        rol dividend+2
        div0
        rol dividend+2
        div0
        rol dividend+2
        div0
	rol dividend+2
        rol dividend+3
        div0
        rol dividend+3
        div0
        rol dividend+3
        div0
        rol dividend+3
        div0
        rol dividend+3
        div0
        rol dividend+3
        div0
        rol dividend+3
        div0
        rol dividend+3
        div0
enddivision3
        rol dividend+3
        ;stx <tx
        ;ldx #0
        ;stx dividend
        ;ldx <tx
        clr dividend
        clr dividend+1
        ;std <remainder
enddivision

