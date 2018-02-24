div8i macro p
    local l1
    rla
    cp c
    jr c,l1

    sub c
    inc p
l1
endm

div8j macro p
      local l1,l2
      rla
      jr c,l1

      cp c
      jr c,l2
l1
      sub c
      inc p
l2
endm

div32x8f proc
    local div8z

    ld a,h
    ld h,b      ;b=0
    cp c
    jr c,div8z

rept OPT
    add a,a
endm
    ld b,a
    xor a

rept 8-OPT
    sla b
    div8i b
endm

div8z
rept 8
    sla l
    div8i l
endm
rept 8
        sla d
        div8i d
endm
rept 8
        sla e
        div8i e
endm
        ld c,l
        ld l,a
        jp enddivision
endp

div32x8e proc
rept OPT
     add hl,hl
endm
     ld a,h
rept 8-OPT
      sla l
      div8j l
endm
rept 8
      sla d
      div8j d
endm
rept 8
      sla e
      div8j e
endm
      ld c,l
      ld l,a
      ld h,b   ;b=0
      jp enddivision
endp
