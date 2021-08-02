div4  .macro
        rol remainder
	rol	
        bcs l2

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
        sec
l1
.endm

   * = * + DIV32ADJ
div32          ;divisor<$8000
        ldy remainder     ;@div32loop@
        sty dividend+2
.ifeq DIV8OPT
        sta dividend+3
        lda #0
        sta remainder
.block
cnt  .var OPT
loop10 .lbl
cnt  .var cnt-1
        asl dividend+3
     .ifne cnt
     .goto loop10
     .endif
.bend
        asl dividend+3
	#div3
.block
cnt  .var 7-OPT
loop4 .lbl
        rol dividend+3
	#div3
cnt  .var cnt-1
     .ifne cnt
     .goto loop4
     .endif
.bend
        rol dividend+3
        rol dividend+2
.endif
.if DIV8OPT
        ldy #0
        sta remainder
        sty dividend+3   ;divisor+1 != 0
        tya
        asl dividend+2
.endif
        #div3
        rol dividend+2
	#div3
        rol dividend+2
	#div3
        rol dividend+2
	#div3
        rol dividend+2
	#div3
        rol dividend+2
	#div3
        rol dividend+2
	#div3
        rol dividend+2
	#div3
        rol dividend+2

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
        rol dividend
        sta remainder+1
	jmp enddivision7        ;@div32loop@    ;##+1=2
.endif

     * = * + DIVMIADJ
div16minus            ;dividend+2 < divisor, for 4708 or more digits
	asl dividend+1   ;@divmiloop@
       	#div4
.block
cnt  .var 7
loop3 .lbl
	rol dividend+1
        #div4
cnt  .var cnt-1
     .ifne cnt
     .goto loop3
     .endif
.bend
        rol dividend+1
.block
cnt  .var 8
loop3 .lbl
        rol dividend
       	#div4
cnt  .var cnt-1
     .ifne cnt
     .goto loop3
     .endif
.bend
        rol dividend
        sta remainder+1
        ldy #0
        sty dividend+2
	sty dividend+3
	jmp enddivision7   ;@divmiloop@    ;##+1=2

