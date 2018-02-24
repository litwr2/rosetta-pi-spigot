OPT = 2                 ;1 for N <= 14000, 6 for N=350, 5 - 2800 upto 3850, 4 - upto 7350, 3 - 10500

div3t
   .byte 0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5
   .byte 5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10
   .byte 10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15
   .byte 16,16,16,17,17,17,18,18,18,19,19,19,20,20,20,21
   .byte 21,21,22,22,22,23,23,23,24,24,24,25,25,25,26,26
   .byte 26,27,27,27,28,28,28,29,29,29,30,30,30,31,31,31
   .byte 32,32,32,33,33,33,34,34,34,35,35,35,36,36,36,37
   .byte 37,37,38,38,38,39,39,39,40,40,40,41,41,41,42,42
   .byte 42,43,43,43,44,44,44,45,45,45,46,46,46,47,47,47
   .byte 48,48,48,49,49,49,50,50,50,51,51,51,52,52,52,53
   .byte 53,53,54,54,54,55,55,55,56,56,56,57,57,57,58,58
   .byte 58,59,59,59,60,60,60,61,61,61,62,62,62,63,63,63
   .byte 64,64,64,65,65,65,66,66,66,67,67,67,68,68,68,69
   .byte 69,69,70,70,70,71,71,71,72,72,72,73,73,73,74,74
   .byte 74,75,75,75,76,76,76,77,77,77,78,78,78,79,79,79
   .byte 80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85

div5t ;*4, +remainders for div32_3
   .byte 0,1,2,0,1,6,4,5,6,4,9,10,8,9,10,12
   .byte 13,14,12,13,18,16,17,18,16,21,22,20,21,22,24,25
   .byte 26,24,25,30,28,29,30,28,33,34,32,33,34,36,37,38
   .byte 36,37,42,40,41,42,40,45,46,44,45,46,48,49,50,48
   .byte 49,54,52,53,54,52,57,58,56,57,58,60,61,62,60,61
   .byte 66,64,65,66,64,69,70,68,69,70,72,73,74,72,73,78
   .byte 76,77,78,76,81,82,80,81,82,84,85,86,84,85,90,88
   .byte 89,90,88,93,94,92,93,94,96,97,98,96,97,102,100,101
   .byte 102,100,105,106,104,105,106,108,109,110,108,109,114,112,113,114
   .byte 112,117,118,116,117,118,120,121,122,120,121,126,124,125,126,124
   .byte 129,130,128,129,130,132,133,134,132,133,138,136,137,138,136,141
   .byte 142,140,141,142,144,145,146,144,145,150,148,149,150,148,153,154
   .byte 152,153,154,156,157,158,156,157,162,160,161,162,160,165,166,164
   .byte 165,166,168,169,170,168,169,174,172,173,174,172,177,178,176,177
   .byte 178,180,181,182,180,181,186,184,185,186,184,189,190,188,189,190
   .byte 192,193,194,192,193,198,196,197,198,196,201,202,200,201,202,204

div7t
  .byte 0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2
  .byte 2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4
  .byte 4,4,4,5,5,5,5,5,5,5,6,6,6,6,6,6
  .byte 6,7,7,7,7,7,7,7,8,8,8,8,8,8,8,9
  .byte 9,9,9,9,9,9,10,10,10,10,10,10,10,11,11,11
  .byte 11,11,11,11,12,12,12,12,12,12,12,13,13,13,13,13
  .byte 13,13,14,14,14,14,14,14,14,15,15,15,15,15,15,15
  .byte 16,16,16,16,16,16,16,17,17,17,17,17,17,17,18,18
  .byte 18,18,18,18,18,19,19,19,19,19,19,19,20,20,20,20
  .byte 20,20,20,21,21,21,21,21,21,21,22,22,22,22,22,22
  .byte 22,23,23,23,23,23,23,23,24,24,24,24,24,24,24,25
  .byte 25,25,25,25,25,25,26,26,26,26,26,26,26,27,27,27
  .byte 27,27,27,27,28,28,28,28,28,28,28,29,29,29,29,29
  .byte 29,29,30,30,30,30,30,30,30,31,31,31,31,31,31,31
  .byte 32,32,32,32,32,32,32,33,33,33,33,33,33,33,34,34
  .byte 34,34,34,34,34,35,35,35,35,35,35,35,36,36,36,36

div15t ;*8, +remainders for div32_7
  .byte 0,1,2,3,4,5,6,0,1,2,3,4,5,6,0,9
  .byte 10,11,12,13,14,8,9,10,11,12,13,14,8,9,18,19
  .byte 20,21,22,16,17,18,19,20,21,22,16,17,18,27,28,29
  .byte 30,24,25,26,27,28,29,30,24,25,26,27,36,37,38,32
  .byte 33,34,35,36,37,38,32,33,34,35,36,45,46,40,41,42
  .byte 43,44,45,46,40,41,42,43,44,45,54,48,49,50,51,52
  .byte 53,54,48,49,50,51,52,53,54,56,57,58,59,60,61,62
  .byte 56,57,58,59,60,61,62,56,65,66,67,68,69,70,64,65
  .byte 66,67,68,69,70,64,65,74,75,76,77,78,72,73,74,75
  .byte 76,77,78,72,73,74,83,84,85,86,80,81,82,83,84,85
  .byte 86,80,81,82,83,92,93,94,88,89,90,91,92,93,94,88
  .byte 89,90,91,92,101,102,96,97,98,99,100,101,102,96,97,98
  .byte 99,100,101,110,104,105,106,107,108,109,110,104,105,106,107,108
  .byte 109,110,112,113,114,115,116,117,118,112,113,114,115,116,117,118
  .byte 112,121,122,123,124,125,126,120,121,122,123,124,125,126,120,121
  .byte 130,131,132,133,134,128,129,130,131,132,133,134,128,129,130,139

div17t ;*8, +remainders for div32_5
   .byte 0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0
   .byte 1,10,11,12,8,9,10,11,12,8,9,10,11,12,8,9
   .byte 10,11,20,16,17,18,19,20,16,17,18,19,20,16,17,18
   .byte 19,20,16,25,26,27,28,24,25,26,27,28,24,25,26,27
   .byte 28,24,25,26,35,36,32,33,34,35,36,32,33,34,35,36
   .byte 32,33,34,35,36,40,41,42,43,44,40,41,42,43,44,40
   .byte 41,42,43,44,40,41,50,51,52,48,49,50,51,52,48,49
   .byte 50,51,52,48,49,50,51,60,56,57,58,59,60,56,57,58
   .byte 59,60,56,57,58,59,60,56,65,66,67,68,64,65,66,67
   .byte 68,64,65,66,67,68,64,65,66,75,76,72,73,74,75,76
   .byte 72,73,74,75,76,72,73,74,75,76,80,81,82,83,84,80
   .byte 81,82,83,84,80,81,82,83,84,80,81,90,91,92,88,89
   .byte 90,91,92,88,89,90,91,92,88,89,90,91,100,96,97,98
   .byte 99,100,96,97,98,99,100,96,97,98,99,100,96,105,106,107
   .byte 108,104,105,106,107,108,104,105,106,107,108,104,105,106,115,116
   .byte 112,113,114,115,116,112,113,114,115,116,112,113,114,115,116,120

divjmp
   .byte >div32_255
   .byte <div32_1,>div32_1,<div32_3,>div32_3,<div32_5,>div32_5,<div32_7,>div32_7  ;7
   .byte <div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32_15,>div32_15 ;15
   .byte <div32_17,>div32_17,<div32x8f,>div32x8f,<div32x8f,>div32x8f,<div32x8f,>div32x8f ;23
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

div_au3 .byte 0,85,170
div_au5 .byte 0,51,102,153,204
div_au7 .byte 0,36,73,109,146,182,219
div_ax7 .byte 0,4,1,5,2,6,3
div_au15 .byte 0,17,34,51,68,85,102,119,136,153,170,187,204,221,238
div_au17 .byte 0,15,30,45,60,75,90,105,120,135,150,165,180,195,210,225,240

    * = * + 6
div32x8e     ;dividend+3 < divisor   @auxloop@
     sty dividend+3

.block
cnt  .var OPT
loop0 .lbl
        asl dividend+2
        rol
cnt  .var cnt-1
     .ifne cnt
     .goto loop0
     .endif

cnt  .var 8-OPT
loop .lbl
        rol dividend+2
        rol
        bcs *+6

        cmp divisor
        bcc *+5

        sbc divisor
        sec
cnt  .var cnt-1
     .ifne cnt
     .goto loop
     .endif
        rol dividend+2

cnt  .var 8
loop2 .lbl
        rol dividend+1
        rol
        bcs *+6

        cmp divisor
        bcc *+5

        sbc divisor
        sec
cnt  .var cnt-1
     .ifne cnt
     .goto loop2
     .endif
        rol dividend+1

cnt  .var 8
loop3 .lbl
        rol dividend
        rol
        bcs *+6

        cmp divisor
        bcc *+5

        sbc divisor
        sec
cnt  .var cnt-1
     .ifne cnt
     .goto loop3
     .endif
        ;rol dividend
        ;sta remainder
        jmp enddivision4
        .bend

div32x8f
.block
     sty dividend+3
     cmp divisor
     bcc div8z

div8zx
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
        rol
        cmp divisor
        bcc *+4

        sbc divisor
cnt  .var cnt-1
     .ifne cnt
     .goto loop2
     .endif
        rol dividend+3
.bend

div8z
.block
cnt  .var 8
loop .lbl
        rol dividend+2
        rol
        cmp divisor
        bcc *+4

        sbc divisor
cnt  .var cnt-1
     .ifne cnt
     .goto loop
     .endif
        rol dividend+2

cnt  .var 8
loop2 .lbl
        rol dividend+1
        rol
        cmp divisor
        bcc *+4

        sbc divisor
cnt  .var cnt-1
     .ifne cnt
     .goto loop2
     .endif
        rol dividend+1

cnt  .var 8
loop3 .lbl
        rol dividend
        rol
        cmp divisor
        bcc *+4

        sbc divisor
cnt  .var cnt-1
     .ifne cnt
     .goto loop3
     .endif
        ;rol dividend
        ;sta remainder
        jmp enddivision4       ;@auxloop@
        .bend


div32_1
      sta dividend+3
      sty remainder
      jmp enddivision

;    * = * + 0
div32_3               ;@aux2loop@
.block
t = product+2
      ;ldx dividend+3
      tax
      lda div3t,x
      sta dividend+3
      lda div5t,x
      and #3
      tay
      clc
      adc dividend+2
      bcc l2

      tax
      inx
      lda #85
      clc
      bne l3

l2    tax
      lda div3t,x
l3    adc div_au3,y
      sta dividend+2
      lda div5t,x
      and #3
      tay
      clc
      adc dividend+1
      bcc l5

      tax
      inx
      lda #85
      clc
      bne l6

l5    tax
      lda div3t,x
l6    adc div_au3,y
      sta dividend+1
      lda div5t,x
      and #3
      tay
      clc
      adc dividend
      bcc l8

      tax
      inx
      lda #85
      clc
      bne l9

l8    tax
      lda div3t,x
l9    adc div_au3,y
      sta dividend
      lda div5t,x
      and #3
.bend
      ;sta remainder
      jmp enddivision2


div32_5
.block
t = product+2
      ;ldx dividend+3
      tax
      lda div5t,x
      lsr
      lsr
      sta dividend+3
      lda div17t,x
      and #7
      tay
      clc
      adc dividend+2
      bcc l2

      tax
      inx
      lda #51
      bne l3

l2    tax
      lda div5t,x
      lsr
      lsr
l3    clc
      adc div_au5,y
      sta dividend+2
      lda div17t,x
      and #7
      tay
      clc
      adc dividend+1
      bcc l5

      tax
      inx
      lda #51
      clc
      bne l6

l5    tax
      lda div5t,x
      lsr
      lsr
l6    clc
      adc div_au5,y
      sta dividend+1
      lda div17t,x
      and #7
      tay
      clc
      adc dividend
      bcc l8

      tax
      inx
      lda #51
      bne l9

l8    tax
      lda div5t,x
      lsr
      lsr
l9    clc
      adc div_au5,y
      sta dividend
      lda div17t,x
      and #7
.bend
      ;sta remainder
      jmp enddivision2


div32_7
.block
t = product+2
      ;ldx dividend+3
      tax
      lda div7t,x
      sta dividend+3
      lda div15t,x
      and #7
      tay
      lda div_ax7,y
      clc
      adc dividend+2
      bcc l2

      adc #3
      tax
      adc #249
      lda #36
      adc #0
      bne l3

l2    tax
      lda div7t,x
l3    adc div_au7,y
      sta dividend+2
      lda div15t,x
      and #7
      tay
      lda div_ax7,y
      clc
      adc dividend+1
      bcc l5

      adc #3
      tax
      adc #249
      lda #36
      adc #0
      bne l6

l5    tax
      lda div7t,x
l6    adc div_au7,y
      sta dividend+1
      lda div15t,x
      and #7
      tay
      lda div_ax7,y
      clc
      adc dividend
      bcc l8

      adc #3
      tax
      adc #249
      lda #36
      adc #0
      bne l9

l8    tax
      lda div7t,x
l9    adc div_au7,y
      sta dividend
      lda div15t,x
      and #7
.bend
      ;sta remainder
      jmp enddivision2

div32_15
.block
t = product+2
      ;ldx dividend+3
      tax
      lda div15t,x
      lsr
      lsr
      lsr
      sta dividend+3
      asl
      asl
      asl
      asl
      sec
      sbc dividend+3
      sta t
      sec
      txa
      sbc t
      tay
      clc
      adc dividend+2
      bcc l2

      lda #17
      bne l3

l2    tax
      lda div15t,x
      lsr
      lsr
      lsr
l3    clc
      adc div_au15,y
      ldx dividend+2
      sta dividend+2
      asl
      asl
      asl
      asl
      sec
      sbc dividend+2
      sta t
      txa
      sec
      sbc t
      tay
      clc
      adc dividend+1
      bcc l5

      lda #17
      bne l6

l5    tax
      lda div15t,x
      lsr
      lsr
      lsr
l6    clc
      adc div_au15,y
      ldx dividend+1
      sta dividend+1
      asl
      asl
      asl
      asl
      sec
      sbc dividend+1
      sta t
      txa
      sec
      sbc t
      tay
      clc
      adc dividend
      bcc l8

      lda #17
      bne l9

l8    tax
      lda div15t,x
      lsr
      lsr
      lsr
l9    clc
      adc div_au15,y
      ldx dividend
      sta dividend
      asl
      asl
      asl
      asl
      sec
      sbc dividend
      sta t
      txa
      sec
      sbc t
.bend
      ;sta remainder
      jmp enddivision2

div32_17
.block
t = product+2
      ;ldx dividend+3
      tax
      lda div17t,x
      lsr
      lsr
      lsr
      sta dividend+3
      asl
      asl
      asl
      asl
      clc
      adc dividend+3
      sta t
      sec
      txa
      sbc t
      tay
      clc
      adc dividend+2
      bcc l2

      lda #15
      bne l3

l2    tax
      lda div17t,x
      lsr
      lsr
      lsr
l3    clc
      adc div_au17,y
      ldx dividend+2
      sta dividend+2
      asl
      asl
      asl
      asl
      clc
      adc dividend+2
      sta t
      txa
      sec
      sbc t
      tay
      clc
      adc dividend+1
      bcc l5

      lda #15
      bne l6

l5    tax
      lda div17t,x
      lsr
      lsr
      lsr
l6    clc
      adc div_au17,y
      ldx dividend+1
      sta dividend+1
      asl
      asl
      asl
      asl
      clc
      adc dividend+1
      sta t
      txa
      sec
      sbc t
      tay
      clc
      adc dividend
      bcc l8

      lda #15
      bne l9

l8    tax
      lda div17t,x
      lsr
      lsr
      lsr
l9    clc
      adc div_au17,y
      ldx dividend
      sta dividend
      asl
      asl
      asl
      asl
      clc
      adc dividend
      sta t
      txa
      sec
      sbc t
.bend
      ;sta remainder
      jmp enddivision2

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
.ifeq OPT
      bcc l12

      inc th
      clc
l12
.endif
      adc dividend+2
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
      ;sta remainder
      jmp enddivision2

div32_255
.block
      ;lda dividend+3
      tax
      clc
      adc dividend+2
      bcs l3

      cmp #255
      bne l4

l3    inx
l4    sty dividend+3
      txa
      clc
      adc dividend+2
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
      ;sta remainder
      jmp enddivision2   ;@aux2loop@

    * = * + 8
div32          ;it may be wrong if divisor>$7fff, @aux3loop@
        ldy #0
.block
        sta remainder
        sty dividend+3   ;divisor+1 != 0
        tya

.block
        asl dividend+2
	rol remainder	;remainder lb & hb * 2 + msb from carry
	rol

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
l1
.bend
cnt  .var 7
loop4 .lbl
.block
        rol dividend+2
	rol remainder	;remainder lb & hb * 2 + msb from carry
	rol

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
l1
.bend
cnt  .var cnt-1
     .ifne cnt
     .goto loop4
     .endif
        rol dividend+2
cnt  .var 8
loop5 .lbl
.block
        rol dividend+1
	rol remainder	;remainder lb & hb * 2 + msb from carry
	rol

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
l1
.bend
cnt  .var cnt-1
     .ifne cnt
     .goto loop5
     .endif
        rol dividend+1
cnt  .var 8
loop6 .lbl
.block
        rol dividend
	rol remainder	;remainder lb & hb * 2 + msb from carry
	rol

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
l1
.bend
cnt  .var cnt-1
     .ifne cnt
     .goto loop6
     .endif
        rol dividend
        sta remainder+1
	jmp enddivision        ;@aux3loop@
        .bend

;     * = * + 5
div16minus            ;dividend+2 < divisor    @aux4loop@
.block
.block
	asl dividend+1
       	rol dividend+2	;dividend lb & hb*2, msb -> Carry
	rol	
        bcs l2

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
	;inc quotient	;and INCrement quotient cause divisor fit in 1 times
l1
.bend
cnt  .var 7
loop3 .lbl
.block
	rol dividend+1
       	rol dividend+2	;dividend lb & hb*2, msb -> Carry
	rol	
        bcs l2

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
	;inc quotient	;and INCrement quotient cause divisor fit in 1 times
l1
.bend
cnt  .var cnt-1
     .ifne cnt
     .goto loop3
     .endif
.bend
        rol dividend+1
.block
cnt  .var 8
loop3 .lbl
.block
        rol dividend	;remainder lb & hb * 2 + msb from carry
       	rol dividend+2	;dividend lb & hb*2, msb -> Carry
	rol	
        bcs l2

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
	;inc quotient	;and INCrement quotient cause divisor fit in 1 times
l1
.bend
cnt  .var cnt-1
     .ifne cnt
     .goto loop3
     .endif
.bend
        ;rol dividend
        ;sta remainder+1
        ;lda #0
        ;sta dividend+2
	;sta dividend+3
        ;lda dividend+2
        ;sta remainder
	jmp enddivision3   ;@aux4loop@


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

;.if 0
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

;.endif

.if 0
div32x16m
.block
        ;;lda dividend+3
        cmp divisor+1
        bcc div16minus
        bne div32x16z

        ldx dividend+2
        cpx divisor
        bcs div32x16z
.bend

div16minus            ;dividend+2 < divisor, CY=0
        ldy #8
.block
l3	rol dividend+1
       	rol dividend+2	;dividend lb & hb*2, msb -> Carry
	rol	
        bcs l2

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
l3      rol dividend	;remainder lb & hb * 2 + msb from carry
       	rol dividend+2	;dividend lb & hb*2, msb -> Carry
	rol	
        bcs l2

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

