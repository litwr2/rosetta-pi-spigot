div8i macro
    local l1
    add hl,hl
    ld a,h
    sub c
    jp c,l1

    ld h,a
    inc l
l1
endm

div8j macro
      local l1,l2
      add hl,hl
      ld a,h
      jp c,l1

      cp c
      jp c,l2
l1
      sub c
      ld h,a
      inc l
l2
endm

div32x8f proc   ;b = 0, c < $80; must be the first in this file!
    local lx

    ld a,h
    cp c
    jp c,lx

    ld b,l
    ld l,h
    ld h,0
rept 8
    div8i
endm
    ld a,l
    ld l,b
    ld b,a
lx
rept 8
    div8i
endm
    ld a,l
    ld l,d
    ld d,a
rept 8
    div8i
endm
      ld a,l
      ld l,e
      ld e,a
rept 8
    div8i
endm
    ld c,d
    ld d,e
    ld e,l
    ld l,h
    ld h,0
        jp enddivision
endp

div32x8e proc   ;b = 0, c > $7f
     local l1
     ld a,h
     cp c
     jp c,l1

     sub c
     ld h,a
     inc b
l1
rept 8
      div8j
endm
      ld a,l
      ld l,d
      ld d,a
rept 8
      div8j
endm
      ld a,l
      ld l,e
      ld e,a
rept 8
      div8j
endm
      ld c,d
      ld d,e
      ld e,l
      ld l,h
      ld h,0
      jp enddivision
endp

