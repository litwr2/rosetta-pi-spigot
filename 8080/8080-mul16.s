mul16    proc      ;HL*BC->DE
         local ll3,ll4
         xor a    ;clear CF
         ld d,a
         ld e,a
ll3      ld a,b
         rra
         ld b,a
         ld a,c
         rra
         ld c,a
         jp nc,ll4

         ex de,hl
         add hl,de
         ex de,hl

ll4      add hl,hl
         ld a,h
         or l
         ret z

         ld a,b
         or c      ;clear CF
         jp nz,ll3

         ret
         endp

