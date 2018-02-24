OPT = 2                 ;1 for N <= 14000, 6 for N=350, 5 - 2800 upto 3850, 4 - upto 7350, 3 - 10500

div32x16x
.block
        bpl lplus    ;N-flag must be set by the divisor! CY = 0 for divisor < 0!

        lda dividend+2
        ;clc
        jmp div16minus
lplus
        lda dividend+2
        cmp divisor
        bcc div16
        jmp div32
.bend

div16            ;dividend+2 < divisor, CY = 0
.block
cnt  .var 16
loop3 .lbl
.block
        rol dividend
        rol
        cmp divisor
        bcc l1

        sbc divisor
l1
.bend
cnt  .var cnt-1
     .ifne cnt
     .goto loop3
     .endif
.bend
        rol dividend
        sta remainder
        #stz_z dividend+2
	rts

div16minus            ;dividend+2 < divisor
.block
cnt  .var 16
loop3 .lbl
.block
	rol dividend
	rol	
        bcs l2

	cmp divisor
        bcc l1
l2
        sbc divisor
        sec
l1
.bend
cnt  .var cnt-1
     .ifne cnt
     .goto loop3
     .endif
.bend
        rol dividend
        sta remainder
        #stz_z dividend+2
	rts

div32          ;it may be wrong if divisor>$7fff
	#stz_z remainder  ;preset remainder to 0
.block
cnt  .var OPT
loop .lbl
        asl
cnt  .var cnt-1
     .ifne cnt
     .goto loop
     .endif
        sta dividend+2

        #lda_i16 0 
cnt  .var 16-OPT
loop2 .lbl
.block
        asl dividend+2
	rol

        cmp divisor
        bcc l1

        sbc divisor
	inc quotient+2	;and INCrement quotient cause divisor fit in 1 times
l1
.bend
cnt  .var cnt-1
     .ifne cnt
     .goto loop2
     .endif

cnt  .var 16
loop4 .lbl
.block
        asl dividend
	rol
        cmp divisor
        bcc l1

        sbc divisor
	inc quotient	;and INCrement quotient cause divisor fit in 1 times
l1
.bend
cnt  .var cnt-1
     .ifne cnt
     .goto loop4
     .endif
        sta remainder
	rts
        .bend

