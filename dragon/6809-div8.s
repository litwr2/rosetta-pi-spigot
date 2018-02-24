div2 macro
       	aslb
	rola
        bcs *+6

	cmpa <divisor+1
        bcs *+5

        suba <divisor+1
        incb
     endm

div3 macro
       	rolb
	rola
	adda <neg_divisor+1
        bcs *+4

        suba <neg_divisor+1
     endm

div32x8e     ;dividend < divisor+1
        ldd <dividend

   if OPT==1
        div2
        div2
   endif
   if OPT==2
        aslb   ;OPT-1 times
        rola
        div2   ;9-OPT times
   endif
   if OPT==3
        aslb
        rola
        aslb
        rola
   endif
        div2
        div2
        div2
        div2
        div2
        div2
        stb <quotient+1

        ldb <dividend+2
        div2
        div2
        div2
        div2
        div2
        div2
        div2
        div2
        stb <quotient+2

        ldb <dividend+3
        div2
        div2
        div2
        div2
        div2
        div2
        div2
        div2
        stb <quotient+3
        sta <remainder+1
        ;tfr a,b    ;slow!
        clra
        sta <quotient
        ldb <remainder+1
        jmp enddivision

div32x8f
        negb
        stb <neg_divisor+1
        ldd <dividend
        stu <remainder+1   ;instead of slower clr <quotient
        cmpa <divisor+1
        bcs div8z

        tfr a,b     ;slow
        clra
   if OPT==1
        aslb   ;OPT?
        div3   ;8-OPT?
        div3
   endif
   if OPT==2
        aslb
        aslb
        div3
   endif
   if OPT==3
        aslb
        aslb
        aslb
   endif
        div3
        div3
        div3
        div3
        div3
        rolb
        stb <quotient
        ldb <dividend+1
div8z
        ;div3
        aslb
	rola
	adda <neg_divisor+1
        bcs *+4

        suba <neg_divisor+1

        div3
        div3
        div3
        div3
        div3
        div3
        div3
        rolb
        stb <quotient+1

        ldb <dividend+2
        div3
        div3
        div3
        div3
        div3
        div3
        div3
        div3
        rolb
        stb <quotient+2

        ldb <dividend+3
        div3
        div3
        div3
        div3
        div3
        div3
        div3
        div3
        rolb
        stb <quotient+3
        sta <remainder+1
        clra
        ldb <remainder+1
        jmp enddivision

