div2 macro
    ;aslb
	;rola
    asld
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

div32x8e     ;dividend < divisor+1, divisor+1 > $7f 
        ldd <dividend

   if OPT==1
        div2
        div2
        div2
        div2
   endif
   if OPT==2
        ;aslb   ;OPT-1 times
        ;rola
        asld
        div2   ;9-OPT times
        div2
        div2
   endif
   if OPT==3
        ;aslb
        ;rola
        asld
        ;aslb
        ;rola
        asld
        div2
        div2
   endif
   if OPT==4
        ;aslb
        ;rola
        asld
        ;aslb
        ;rola
        asld
        ;aslb
        ;rola
        asld
        div2
   endif
   if OPT==5
        ;aslb
        ;rola
        asld
        ;aslb
        ;rola
        asld
        ;aslb
        ;rola
        asld
        ;aslb
        ;rola
        asld
   endif
        div2
        div2
        div2
        div2
        stab <quotient+1

        ldb <dividend+2
        div2
        div2
        div2
        div2
        div2
        div2
        div2
        div2
        stab <quotient+2

        ldb <dividend+3
        div2
        div2
        div2
        div2
        div2
        div2
        div2
        div2
        stab <quotient+3
        staa <remainder+1
        ;tfr a,b    ;slow!
        clra
        staa <quotient
        ldb <remainder+1
        jmp enddivision

div32x8f             ;divisor+1 < $80
        negb
        stab <neg_divisor+1
        ldd <dividend
        ;stu <neg_divisor+1   ;instead of slower clr <quotient
        clr dividend
        cmpa <divisor+1
        bcs div8z

        ;tfr a,b     ;slow
        tab
        clra
   if OPT==1
        aslb   ;OPT?
        div3   ;8-OPT?
        div3
        div3
        div3
   endif
   if OPT==2
        aslb
        aslb
        div3
        div3
        div3
   endif
   if OPT==3
        aslb
        aslb
        aslb
        div3
        div3
   endif
   if OPT==4
        aslb
        aslb
        aslb
        aslb
        div3
   endif
   if OPT==5
        aslb
        aslb
        aslb
        aslb
        aslb
   endif
        div3
        div3
        div3
        rolb
        stab <quotient
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
        stab <quotient+1

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
        stab <quotient+2

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
        stab <quotient+3
        staa <remainder+1
        clra
        ldb <remainder+1
        jmp enddivision

