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
enddivision2
        rol dividend
        #stz_z dividend+2
enddivision
        sta remainder

