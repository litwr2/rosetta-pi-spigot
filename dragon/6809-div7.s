div0 macro
       	rolb
	rola
	addd <neg_divisor
        bcs *+4

        subd <neg_divisor
     endm

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
        bcc 1F

        subd <divisor
        bra 2F

1        addd <neg_divisor
        bcs 2F

        subd <neg_divisor
2
     endm

   if DIVNOMINUS==0
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
   endif

   if DIV8OPT
div32          ;it may be wrong if divisor>$7fff
        ldb <dividend
        clra
        sta <quotient

        div0z dividend+1
        div0z dividend+2
        div0z dividend+3
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
        rol <dividend
        div0
        rol <dividend
        div0
   endif
   if OPT==3
        asl <dividend
        asl <dividend
        asl <dividend
        rol <dividend
        div0
        rol <dividend
        div0
   endif
   if OPT==4
        asl <dividend
        asl <dividend
        asl <dividend
        asl <dividend
        rol <dividend
        div0
   endif
   if OPT==5
        sta 1F+1
        lda <dividend
        asla
        asla
        asla
        asla
        asla
        sta <dividend
1       lda #0
   endif
        rol <dividend
        div0
        rol <dividend
        div0
        rol <dividend
        div0
        rol <dividend

        div0z dividend+1
        div0z dividend+2
        div0z dividend+3
	jmp enddivision2
   endif
