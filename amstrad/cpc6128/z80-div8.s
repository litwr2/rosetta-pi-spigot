div8i macro px
    local l1
    rl px
    rla
    add a,c
    jr c,l1

    sub c
l1
endm

div8j macro px
      local l1,l2
      sla px
      rla
      jr c,l1

      cp c
      jr c,l2
l1
      sub c
      inc px
l2
endm

div32x8f proc   ;b = 0, c < $80; must be the first in this file!
    local shortdiv

    ld a,h
    cp c
    ld a,c
    dec a
    cpl
    ld c,a
    ld a,h
    ld h,b      ;b=0
    jr c,shortdiv

rept OPT
    add a,a
endm
    ld b,a
    xor a

rept 8-OPT
    div8i b
endm
    rl b

shortdiv
rept 8
    div8i l
endm
    rl l
rept 8
        div8i d
endm
    rl d
rept 8
        div8i e
endm
    rl e
        ld c,l
        ld l,a
        jp enddivision
endp

div32x8e proc   ;b = 0, c > $7f
if OPT=0
     local l1x
     ld a,h
     cp c
     jr c,l1x

     sub c
     inc b
l1x
rept 8
      div8j l
endm
else
rept OPT-1
     add hl,hl
endm
     ld a,h
rept 9-OPT
      div8j l
endm
endif
rept 8
      div8j d
endm
rept 8
      div8j e
endm
      ld c,l
      ld l,a
if OPT=0
      ld h,0   ;b=0
else
      ld h,b   ;b=0
endif
      jp enddivision
endp

