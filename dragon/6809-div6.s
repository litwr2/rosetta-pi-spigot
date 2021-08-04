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
        ;lbpl div16minus  ;slower!
   endif

lplus
        addd <dividend
        bcc div16
        jmp div32
        ;lbcc div32   ;slower!

   if DIV8OPT
div8
        sta remainder
        tstb
        bmi todiv8e
;;       lbmi div32x8e   ;slower!
        jmp div32x8f
todiv8e jmp div32x8e
   endif

div16            ;<dividend+2 < divisor
        ldd <dividend
        asl <dividend+2
        div0
        rol <dividend+2
        div0
        rol <dividend+2
        div0
        rol <dividend+2
        div0
        rol <dividend+2
        div0
        rol <dividend+2
        div0
        rol <dividend+2
        div0
        rol <dividend+2
        div0
	rol <dividend+2
        rol <dividend+3
        div0
        rol <dividend+3
        div0
        rol <dividend+3
        div0
        rol <dividend+3
        div0
        rol <dividend+3
        div0
        rol <dividend+3
        div0
        rol <dividend+3
        div0
        rol <dividend+3
        div0
enddivision3
        stu <dividend
enddivision2
        rol <dividend+3
        ;std <remainder
enddivision

