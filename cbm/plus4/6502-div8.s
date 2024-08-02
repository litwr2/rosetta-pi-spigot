.if CMOS6502
divjmp
   .byte >div32_255 ;for the NMOS 6502
   .byte <div32_1,>div32_1,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;7 ;##+0=W128
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f ;15
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f ;23
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;31
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;39
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;47
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;55
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;63
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;71
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;79
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;87
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;95
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;103
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;111
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;119
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f  ;127
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32x8e,>div32x8e
   .byte <div32x8e,>div32x8e,<div32x8e,>div32x8e,<div32_253,>div32_253,<div32_255
   .byte >div32_255 ;CMOS 6502 and 65816 compatibility byte
.endif

div1 .macro
        rol
        bcs l2

        cmp divisor
        bcc l1

l2      sbc divisor
        sec
l1
.endm

div2  .macro
        rol
        cmp divisor
        bcc l1

        sbc divisor
l1
.endm

    * = * + DIV8ADJ
div32x8e     ;dividend+3 < divisor
        ldx remainder
        stx dividend+2
        sty dividend+3   ;@div8loop@

.block
.if OPT-1
cnt  .var OPT-1
loop0 .lbl
        asl dividend+2
        rol
cnt  .var cnt-1
     .ifne cnt
     .goto loop0
     .endif
.endif

cnt  .var 9-OPT
loop .lbl
        rol dividend+2
        #div1
cnt  .var cnt-1
     .ifne cnt
     .goto loop
     .endif
.bend
        rol dividend+2

        rol dividend+1
        #div1
        rol dividend+1
        #div1
        rol dividend+1
        #div1
        rol dividend+1
        #div1
        rol dividend+1
        #div1
        rol dividend+1
        #div1
        rol dividend+1
        #div1
        rol dividend+1
        #div1
        rol dividend+1

        rol dividend
        #div1
        rol dividend
        #div1
        rol dividend
        #div1
        rol dividend
        #div1
        rol dividend
        #div1
        rol dividend
        #div1
        rol dividend
        #div1
        rol dividend
        #div1
        rol dividend
        sta remainder
        jmp enddivision      ;##+1=2

div32x8f
     ldx remainder
     stx dividend+2
     sty dividend+3
     cmp divisor
     bcc div8z
.block
cnt  .var OPT
loop .lbl
        asl
cnt  .var cnt-1
     .ifne cnt
     .goto loop
     .endif
        sta dividend+3
        tya

cnt  .var 8-OPT
loop2 .lbl
        rol dividend+3
        #div2
cnt  .var cnt-1
     .ifne cnt
     .goto loop2
     .endif
.bend
        rol dividend+3

div8z
        rol dividend+2
        #div2
        rol dividend+2
        #div2
        rol dividend+2
        #div2
        rol dividend+2
        #div2
        rol dividend+2
        #div2
        rol dividend+2
        #div2
        rol dividend+2
        #div2
        rol dividend+2
        #div2
        rol dividend+2

        rol dividend+1
        #div2
        rol dividend+1
        #div2
        rol dividend+1
        #div2
        rol dividend+1
        #div2
        rol dividend+1
        #div2
        rol dividend+1
        #div2
        rol dividend+1
        #div2
        rol dividend+1
        #div2
        rol dividend+1

        rol dividend
        #div2
        rol dividend
        #div2
        rol dividend
        #div2
        rol dividend
        #div2
        rol dividend
        #div2
        rol dividend
        #div2
        rol dividend
        #div2
        rol dividend
        #div2
        rol dividend
        sta remainder
        jmp enddivision       ;@div8loop@    ;##+1=2

.if CMOS6502
    * = * + DIV8SADJ
div32_1
      ldx remainder          ;@div8suploop@
      stx dividend+2
      sta dividend+3
      sty remainder
      tya
      jmp enddivision     ;##+1=2

div32_253
.block
tl = product+2
th = product+3
      sty th
      ;lda dividend+3
      tax
      sta tl
      asl
      rol th
      adc tl
.ifeq OPT-1
      bcc l12

      inc th
      clc
l12
.endif
      ;adc dividend+2
      adc remainder
      sta tl
      lda th
      adc #0
      sta th
      bne l3

      lda tl
      bcc l51

l3    txa
      clc
      adc th
      tax
      lda th
      asl
      adc th
      sta th
      adc tl
      sta tl
      bcs l50

l51   cmp #253
      bcc l4

l50   inx
      sbc #253
      sta tl
l4    sty dividend+3
      sty th
      stx dividend+2
      tax
      asl
      rol th
      adc tl
      sta tl
      bcc l14

      inc th
      clc
l14   adc dividend+1
      sta tl
      lda th
      adc #0
      sta th
      bne l23

      lda tl
      bcc l52

l23   txa
      clc
      adc th
      tax
      lda th
      asl
      adc th
      sta th
      adc tl
      sta tl
      bcs l53

l52   cmp #253
      bcc l24

l53   inx
      sbc #253
      sta tl
l24   sty th
      stx dividend+1
      tax
      asl
      rol th
      adc tl
      sta tl
      bcc l34

      inc th
      clc
l34   adc dividend
      sta tl
      lda th
      adc #0
      sta th
      bne l33

      lda tl
      bcc l54

l33   txa
      clc
      adc th
      tax
      lda th
      asl
      adc th
      adc tl
      bcs l55

l54   cmp #253
      bcc l32

l55   inx
      sbc #253
l32   stx dividend
.bend
      sta remainder
      jmp enddivision    ;##+1=2

div32_255
.block
      ;lda dividend+3
      tax
      clc
      ;adc dividend+2
      adc remainder
      bcs l3

      cmp #255
      bne l4

l3    inx
l4    sty dividend+3
      txa
      clc
      ;adc dividend+2
      adc remainder
      tay
      stx dividend+2
      clc
      adc dividend+1
      bcs l2

      cmp #255
      bne l1

l2    iny
l1    tya
      clc
      adc dividend+1
      tax
      sty dividend+1
      clc
      adc dividend
      bcs l5

      cmp #255
      bne l6

l5    inx
l6    txa
      clc
      adc dividend
      stx dividend
.bend
      sta remainder
      jmp enddivision   ;@div8suploop@     ;##+1=2
.endif

