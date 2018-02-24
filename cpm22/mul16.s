mul16    proc      ;HL*BC->DE
         local ll3,ll4
         ld de,0
ll3      srl b
         rr c
         jr nc,ll4

         ex de,hl
         add hl,de
         ex de,hl

ll4      add hl,hl
         ld a,h
         or l
         ret z

         ld a,b
         or c
         jr nz,ll3

         ret
         endp

