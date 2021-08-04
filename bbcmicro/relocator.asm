;zp locations
zp1 = $70   ;+$71
zp2 = $72   ;+$73
zp3 = $74   ;+$75

     * = $200
        lda $424   ;lo(i%)
        ;pha
        sta zp2
        lda $425   ;hi(i%)
        pha
        sta zp2+1
        lda $439   ;hi(n%)
        sta zp3+1
        lda $438   ;lo(n%)
        sta zp3
        lda $410   ;lo(d%)
        pha
        clc
        adc #<code
        sta zp1
        lda $411   ;hi(d%)
        pha
        adc #>code-$200
        sta zp1+1

        ldy #0
loop0   lda (zp1),y
        sta (zp2),y
        iny
        bne loop0

        inc zp1+1
        inc zp2+1
        dec zp3+1
        bne loop0

loop2   cpy zp3
        beq cont3

        lda (zp1),y
        sta (zp2),y
        iny
        bne loop2

cont3   pla
        tay
        pla
        adc #<data-1   ;CY=1, >data != 0
        sta zp1
        tya
        adc #>data-$200
        sta zp1+1

        pla
        sta zp2+1
        sbc #1    ;CY=0
        sta zp3+1
        ;pla
        ;sta zp2
        ;sta zp3

        ldx #0
        stx zp2
loop    txa
        tay
        lda (zp1),y
        beq exit

        cmp #1
        clc
        bne cont

        inx
        inx
        iny
        lda (zp1),y
        adc zp2
        sta zp2
        iny
        lda (zp1),y
        bne cont2   ;always

cont    adc zp2
        sta zp2
        lda #0
cont2   adc zp2+1
        sta zp2+1
        ldy #0
        lda (zp2),y
        adc zp3+1    ;CY=0
        sta (zp2),y
        inx
        bne loop  ;always
exit    rts
data
        .include "reloc-data.s"
code
