10 IF PEEK(&C01)=16 AND PEEK(&C02)=32 GOTO 50
20 h%=4*INT((HIMEM-&F00)/28)
30 MEMORY &27FF:LOAD"calcpi.bin"
40 MEMORY &7FF:CALL &2F00:POKE &BFE,h% AND 255:POKE &BFF,h%\256
50 CLS:PRINT SPC(7)"number "CHR$(184)" calculator v2"
60 h%=PEEK(&BFE)+PEEK(&BFF)*256
70 PRINT"   it may give 4000 digits less than":PRINT SPC(12)"in an hour!":PRINT
80 PRINT"number of digits (up to"+STR$(h%)+")";:INPUT f:d=(f+3)AND-4
90 IF d<0 OR d>h% THEN 80
100 IF f<>d THEN PRINT d;"digits will be printered":CALL &BB18
110 f=d/2*7:POKE &806,f AND 255:POKE &807,f\256
120 m=1:IF d>1000 THEN m=2
130 MODE m:f=TIME:CALL &800:f=(TIME-f)/300
140 IF m=1 AND d>868 OR m=2 AND d>1868 THEN CALL &BB18
150 PRINT f
