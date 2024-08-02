div0s macro
    rol \1
       	rolb
	rola
	addd <neg_divisor
        bcc \2
     endm

div0a macro
    rol \1
       	rolb
	rola
	addd <divisor
        bcs \2
     endm

div0z macro
    div0s \1,1F
    div0s \1,12F
2  div0s \1,13F
3  div0s \1,14F
4  div0s \1,15F
5  div0s \1,16F
6  div0s \1,17F
7  div0s \1,18F 
8  rol \1
    jmp 9F
1  div0a \1,2B
12  div0a \1,3B
13  div0a \1,4B
14  div0a \1,5B
15  div0a \1,6B
16  div0a \1,7B
17  div0a \1,8B
18  rol \1
    addd <divisor
9
    endm

div32x16x     ;D=A:B - divisor (A - high!)
   if DIV8OPT
        tsta
        beq div8
   endif
        negb     ;assumed that D is odd
        coma
        std <neg_divisor
   if DIVNOMINUS==0
        bmi lplus
        jmp div16minus
        ;lbpl div16minus  ;slower!
   endif

lplus
        addd <dividend
        bcc div16
        jmp div32
        ;lbcc div32   ;slower!

   if DIV8OPT
div8
        sta remainder
        tstb
        bmi todiv8e
;;       lbmi div32x8e   ;slower!
        jmp div32x8f
todiv8e jmp div32x8e
   endif

div16
        ldd <dividend
        div0z dividend+2
        div0z dividend+3
enddivision3
        stu <dividend
enddivision2
enddivision
