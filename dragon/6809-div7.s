div32x16w        ;<dividend < divisor, divisor < $8000
        ;ldd <dividend
        ldx #16
lz3     asl <dividend+3
        rol <dividend+2
        rolb
	rola
        ;bcs 2   ;for divisor>$7fff

	cmpd <divisor
        bcs lz1
;2
        subd <divisor
	inc quotient+3
lz1     leax -1,x
        bne lz3

        std <remainder
        ;stu <dividend
	rts

div1 macro
       	rolb
	rola	
        bcs *+6

        cmpd <divisor
        bcs *+4

        addd <neg_divisor
     endm

div16minus            ;dividend < divisor > $7fff, it used only if number of digits > 4704
        ldd <dividend
	asl <dividend+2
        div1
	rol <dividend+2
        div1
	rol <dividend+2
        div1
	rol <dividend+2
        div1
	rol <dividend+2
        div1
	rol <dividend+2
        div1
	rol <dividend+2
        div1
	rol <dividend+2
        div1
        rol <dividend+2
	rol <dividend+3
        div1
	rol <dividend+3
        div1
	rol <dividend+3
        div1
	rol <dividend+3
        div1
	rol <dividend+3
        div1
	rol <dividend+3
        div1
	rol <dividend+3
        div1
	rol <dividend+3
        div1
	jmp enddivision3

   if DIV8OPT
div32          ;it may be wrong if divisor>$7fff
        ldb <dividend
        clra
        sta <quotient

        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1

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
	jmp enddivision2
   else
div32          ;it may be wrong if divisor>$7fff
        ldd #0
   if OPT==1
        asl <dividend
        rol <dividend
        div0
        rol <dividend
        div0
   endif
   if OPT==2
        asl <dividend
        asl <dividend
        rol <dividend
        div0
   endif
   if OPT==3
        asl <dividend
        asl <dividend
        asl <dividend
   endif
        rol <dividend
        div0
        rol <dividend
        div0
        rol <dividend
        div0
        rol <dividend
        div0
        rol <dividend
        div0
        rol <dividend

        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1
        div0
        rol <dividend+1

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
	jmp enddivision2
   endif
