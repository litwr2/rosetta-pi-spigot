.if 0
div32x16z
        ldy #0	        ;preset remainder to 0
	sty remainder
	sty remainder+1
        tya
        ldy #32
.block
l3      asl dividend
        rol dividend+1
        rol dividend+2
        rol dividend+3
	rol remainder
	rol
        ;bcs l2   ;for divisor>$7fff

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
	inc quotient
l1      dey
        bne l3
.bend
        sta remainder+1
	rts
.endif

div32x16w        ;dividend+2 < divisor, divisor < $8000
        ;;lda dividend+3
        ldy #16
.block
l3      asl dividend
        rol dividend+1
        rol dividend+2
	rol
        ;bcs l2   ;for divisor>$7fff

        cmp divisor+1
        bcc l1
        bne l2

        ldx dividend+2
        cpx divisor
        bcc l1

l2      tax
        lda dividend+2
        sbc divisor
        sta dividend+2
        txa
        sbc divisor+1
	inc quotient
l1      dey
        bne l3
.bend
        sta remainder+1
        lda dividend+2
        sta remainder
        ;lda #0
        ;sta dividend+2
	;sta dividend+3
	rts

.if 0
div32x16s            ;dividend+2 < divisor, divisor < $8000, CY=0
        ;;lda dividend+3
        clc
        ldy #8
.block
l3	rol dividend+1
       	rol dividend+2
	rol	
	cmp divisor+1
        bcc l1
        bne l2

        ldx dividend+2
        cpx divisor
        bcc l1

l2      tax
        lda dividend+2
        sbc divisor
        sta dividend+2
        txa
        sbc divisor+1
        sec
l1      dey
        bne l3
.bend
        rol dividend+1
        ldy #8
.block
l3      rol dividend
       	rol dividend+2
	rol	
	cmp divisor+1
        bcc l1
        bne l2

        ldx dividend+2
        cpx divisor
        bcc l1

l2      tax
        lda dividend+2
        sbc divisor
        sta dividend+2
        txa
        sbc divisor+1
        sec
l1      dey
        bne l3
.bend
        rol dividend
        sta remainder+1
        lda dividend+2
        sta remainder
        lda #0
        sta dividend+2
	sta dividend+3
	rts
.endif
