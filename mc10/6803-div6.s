div0s macro
    rol \1
       	rolb
	rola
	addd <neg_divisor
        bcc \2
     endm

div0a macro
    rol \1
       	rolb
	rola
	addd <divisor
        bcs \2
     endm

div0z macro
\@  div0s \1,.A1
    div0s \1,.A2
.S2  div0s \1,.A3
.S3  div0s \1,.A4
.S4  div0s \1,.A5
.S5  div0s \1,.A6
.S6  div0s \1,.A7
.S7  div0s \1,.A8 
.S8  rol \1
    jmp .L
.A1  div0a \1,.S2
.A2  div0a \1,.S3
.A3  div0a \1,.S4
.A4  div0a \1,.S5
.A5  div0a \1,.S6
.A6  div0a \1,.S7
.A7  div0a \1,.S8
.A8  rol \1
    addd <divisor
.L
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
        div0z dividend+2
        div0z dividend+3
enddivision3
        clr dividend
        clr dividend+1
        ;std <remainder
enddivision2
enddivision

