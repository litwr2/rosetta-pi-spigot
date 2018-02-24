10 IF fre(0)<560 GOTO 50
20 f=fre(0):POKE&h88fe,f AND255:POKE&h88ff,f\256:CLEAR8,&h84ff:h=4*((PEEK(&h88fe)+PEEK(&h88ff)*256-fre(0)-&h6c0)\28)
30 BLOAD"calcpi.bin":POKE&h88fe,h AND 255:POKE&h88ff,h\256
50 CLS:PRINT" MSX Basic":PRINT"number Pi calculator v1":v%=60:IF PEEK(&h2b)>127 THEN v%=50
60 h=PEEK(&h88fe)+PEEK(&h88ff)*256
80 PRINT"number of digits (up to";STR$(h);")";:INPUT f:d=(f+3)AND-4:IF d<=0 OR d>h THEN80
100 IF f<>d THEN PRINT d;"digits will be printered"
110 f=d/2*7:POKE &h8501,f AND 255:POKE &h8502,f\256:DEFUSR=&h8500:TIME=0:f=USR(0):f=TIME:IF d>2200 AND PEEK(45)<3 THEN f=f+65536
140 PRINT f/v%:END

