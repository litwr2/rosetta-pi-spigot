10 IF HIMEM<40000 GOTO 60
20 H=HIMEM-FRE(0):F=4*INT((H-2048)/28):POKE36094,F-INT(F/256)*256:POKE36095,F/256
30 CLEAR0,H:LOADM"calcpi.co"
60 PRINT"number pi calculator v1":H=PEEK(36094)+PEEK(36095)*256
80 PRINT"number of digits (up to"H")";
90 INPUTF:D=4*INT((F+3)/4):IFD<=0ORD>HTHEN 80
100 IFF<>DTHEN PRINT D;"digits will be printed"
110 F=D/2*7:POKE36117,F-INT(F/256)*256:POKE36118,F/256
130 CALL36096:F=0:FORD=0TO3:F=F*256+PEEK(37332-D):NEXT
150 PRINT F/256
