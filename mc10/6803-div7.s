div32x16w        ;<dividend < divisor, divisor < $8000
        ;ldd <dividend
        ldx #16
lz3     asl dividend+3
        rol dividend+2
        rolb
	rola
        ;bcs 2   ;for divisor>$7fff

	subd <divisor
        bcc lz1
;2
        addd <divisor
	dec quotient+3
lz1     inc quotient+3
        dex
        bne lz3

        std <remainder
        ;stu <dividend
	rts

div1 macro
       	rolb
	    rola
        bcc .l1\@

        subd <divisor
        bra .l2\@

.l1\@   addd <neg_divisor
        bcs .l2\@

        subd <neg_divisor
.l2\@
     endm

   if DIVNOMINUS==0
div16minus            ;dividend < divisor > $7fff, it used only if number of digits > 4704
        ldd <dividend
	asl dividend+2
        div1
	rol dividend+2
        div1
	rol dividend+2
        div1
	rol dividend+2
        div1
	rol dividend+2
        div1
	rol dividend+2
        div1
	rol dividend+2
        div1
	rol dividend+2
        div1
        rol dividend+2
	rol dividend+3
        div1
	rol dividend+3
        div1
	rol dividend+3
        div1
	rol dividend+3
        div1
	rol dividend+3
        div1
	rol dividend+3
        div1
	rol dividend+3
        div1
	rol dividend+3
        div1
	jmp enddivision3
   endif

   if DIV8OPT
div32          ;it may be wrong if divisor>$7fff
        ldb <dividend
        clra
        staa <quotient

        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1

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
        rol dividend+3
	jmp enddivision
   else
div32          ;it may be wrong if divisor>$7fff
        ldd #0
   if OPT==1
        asl dividend
        rol dividend
        div0
        rol dividend
        div0
        rol dividend
        div0
        rol dividend
        div0
   endif
   if OPT==2
        asl dividend
        asl dividend
        rol dividend
        div0
        rol dividend
        div0
        rol dividend
        div0
   endif
   if OPT==3
        asl dividend
        asl dividend
        asl dividend
        rol dividend
        div0
        rol dividend
        div0
   endif
   if OPT==4
        asl dividend
        asl dividend
        asl dividend
        asl dividend
        rol dividend
        div0
   endif
   if OPT==5
        asl dividend
        asl dividend
        asl dividend
        asl dividend
        asl dividend
   endif
        rol dividend
        div0
        rol dividend
        div0
        rol dividend
        div0
        rol dividend

        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1
        div0
        rol dividend+1

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
        rol dividend+3
	jmp enddivision
   endif

