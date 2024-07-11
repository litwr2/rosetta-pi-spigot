AMSTRADPCW equ 1
CPM3 equ 0
CPM22 equ 0
CORVETTE equ 0

org &100
if AMSTRADPCW
  ld de,cls
  ld c,9
  jp 5
cls db 27,'E',27,'H$'
endif
if CPM3
  ld e,26   ;for cp/m 3
endif
if CPM22
  ld e,12   ;for cp/m 2.2
endif
if CORVETTE
  ld e,1fh  ;for Korvet cp/m 2.2
  ld c,2
endif
  jp 5
