;zp locations
zp1 = $e2   ;+$e3
zp2 = $e4   ;+$e5
zp3 = $d7   ;+$d8

     * = $200
        pla
        pla   ;hi(copyto/main start)
        sta zp2+1
        tax
        pla   ;lo(-)
        sta zp2
        pla   ;hi(main size)
        sta zp3+1
        pla   ;lo(-)
        sta zp3
        pla    ;hi(reloc start/load addr)
        sta zp1+1
        pla    ;lo(-)
        tay
        txa
        pha
        lda zp1+1
        pha
        tya
        pha
        clc
        adc #<code
        sta zp1
        lda zp1+1
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
        adc #<data-1   ;CY=1, >data != 0
        sta zp1
        pla
        adc #>data-$200
        sta zp1+1

        pla
        sta zp2+1
        sbc #1    ;CY=0
        sta zp3+1

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
