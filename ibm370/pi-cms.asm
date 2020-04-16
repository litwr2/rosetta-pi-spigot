*for IBM/370
*it calculates pi-number using the next C-algorithm
*https://crypto.stanford.edu/pbc/notes/pi/code.html
*
*#include <stdio.h>
*#define N 2800
*main() {
*   long r[N + 1], i, k, b, c;
*   c = 0;
*   for (i = 1; i <= N; i++)  //the original was (i = 0; i < N; ...
*      r[i] = 2000;
*   for (k = N; k > 0; k -= 14) {
*      d = 0;
*      i = k;
*      for(;;) {
*         d += r[i]*10000;
*         b = i*2 - 1;
*         r[i] = d%b;
*         d /= b;
*         i--;
*         if (i == 0) break;
*         d *= i;
*      }
*      printf("%.4d", (int)(c + d/10000));
*      c = d%10000;
*   }
*}
*
*the time of the calculation is quadratic
*so if T is time to calculate N digits
*then 4*T is required to calculate 2*N digits
*main loop count is 7*(4+D)*D/16, D - number of digits
*
*litwr has written this in IBM/370 BAL
*bqt helped much with optimization
*tricky provided some help
*MMS gave some support
*Thorham and meynaf helped too
*
         TITLE 'PI'
*
         MACRO
         PRINTREG &REG
         GBLB  &DEBUGMO
         AIF   (&DEBUGMO EQ 0).DONE
         STM   15,1,DBRSAV
         AIF   (&REG GT 9).LETTER
         MVI   DBGAREA+4+1,C'0'+&REG
         AGO   .OK
.LETTER  MVI   DBGAREA+4+1,C'A'+&REG-10
.OK      CVD   &REG,M3
         UNPK  DBGAREA+4+3(10),M3+2(6)
         MVZ   DBGAREA+4+12(1),DBGAREA+4+11
         LA    1,DBGAREA
         SVC   35
         LM    15,1,DBRSAV
.DONE    MEND
*
LINELEN  EQU   80
*
         GBLB  &IO
         GBLB  &STCK
         GBLB  &STPT
         GBLB  &DEBUGMO
&DEBUGMO SETB  0
&IO      SETB  1
*select STCK or STPT instruction or the interval timer at 80h
&STCK    SETB  0
*STPT is a privileged instruction!
&STPT    SETB  0
*
BALPI    CSECT
*
         USING BALPI,12
         STM   14,12,0(13)
         LR    12,15
*
         MVC   M2(L'MSG1),MSG1
         LA    1,L'MSG1+4
EL5      STH   1,MSGAREA
         LA    1,MSGAREA
         SVC   35
*
         LA    1,MAXDV-1
         SR    1,12
         LCR   1,1
         A     1,VFFFF
         XR    0,0
         D     0,V7
         N     1,VFFFC
         STH   1,MAXDV
*
         CVD   1,M3
         UNPK  MSG2N(4),M3+5(3)
         MVZ   MSG2N+3(1),MSG2N+2
         XR    8,8
         ST    8,M3
         LA    1,INPAREA
         SVC   35
*
         LA    1,M3
         LA    6,4
         XR    5,5
EL4      CLI   0(1),0
         BC    6,EL2
*
         CH    6,V4
         BC    6,EL6
*
EL1      MVC   M2(L'MSG4),MSG4
         LA    1,L'MSG4+4
         B     EL5
*
EL2      CLI   0(1),C'0'
         BC    4,EL1
*
         CLI   0(1),C'9'
         BC    2,EL1
*
EL3      MH    5,V10
         NI    0(1),15
         IC    8,0(1,0)
         AR    5,8
         LA    1,1(1,0)
         BCT   6,EL4
*
EL6      LTR   5,5
         BC    12,EL1
*
         CH    5,MAXDV
         BC    2,EL1
*
         LA    8,3
         NR    8,5
         BC    8,EL7
*
         LA    5,4(5,0)
         N     5,VFFFC
         CVD   5,M3
         UNPK  MSG3(4),M3+5(3)
         MVZ   MSG3+3(1),MSG3+2
         MVC   M2(L'MSG3),MSG3
         MVI   MSGAREA+1,L'MSG3+4
         LA    1,MSGAREA
         SVC   35
*
EL7      LA    0,LINELEN
         MVI   MSGAREA+1,LINELEN+4
         AIF   (&STCK).STCK1
         AIF   (&STPT).STPT1
         L     1,80
         ST    1,STIME
         AGO   .EXIT1
.STPT1   STPT  T2
         AGO   .EXIT1
.STCK1   STCK  T1
         BC    3,EL8
.EXIT1   ANOP
*
         LR    8,5           fill r-array
         MH    8,V7+2
         LR    11,8
         SRL   8,2
         L     9,V2000
         LA    10,RA+2
CLOOP1   ST    9,0(10)
         AH    10,V4
         BCT   8,CLOOP1
*
         STH   8,CV
         SRL   11,1
         L     7,VFFFF
*
PLOOP2   LA    3,M2
         SR    5,0
         BC    10,PLOOP1
*
         AR    0,5
         LR    5,0
         LA    5,4(5,0)
         STH   5,MSGAREA
         XR    5,5
PLOOP1   XR    10,10         d <- 0
         LR    6,11
         AR    6,6           i <-k*2
         B     CL2
*
CL4      SR    10,8
         SR    10,9
         SRL   10,1(0)
CL2      LH    9,RA(6)       r[i]
         NR    9,7           *
         MH    9,V10000+2    r[i]*10000, mul32x16
         AR    9,10
         LR    10,9
*
         BCTR  6,0           b <- 2*i-1
         XR    8,8
         DR    8,6
         STH   8,RA+1(6)     r[i] <- d%b
         BCT   6,CL4         i <- i - 1
*
         LR    9,10
         XR    8,8
         D     8,V10000
         AIF   (NOT &IO).NOIO2
         AH    9,CV          c + d/10000
         STH   8,CV          c <- d%10000
*print 9
         CVD   9,M3
         UNPK  0(4,3),M3+5(3)
         MVZ   3(1,3),2(3)
         LA    3,4(3,0)
.NOIO2   ANOP
         SH    0,V4
         BC    2,PLOOP1
*
         AIF   (NOT &IO).NOIO1
         LA    1,MSGAREA
         SVC   35
.NOIO1   ANOP
         LA    0,LINELEN
         LTR   5,5
         BC    2,PLOOP2
*
         AIF   (&STCK).STCK2
         AIF   (&STPT).STPT2
         L     2,80
         L     3,STIME
         SR    3,2
         BC    5,EL8
*
         SRL   3,8
         XR    2,2
         D     2,V3
         CH    2,V1
*
         AGO   .EXIT2
.STCK2   STCK  T2
         BC    3,EL8
         AGO   .CONT1
.STPT2   STPT  T1
.CONT1   L     3,T2+4
         SL    3,T1+4
         L     2,T2
         BC    3,L7
*
         BCTR  2,0
L7       S     2,T1
         SRDL  2,12
         D     2,V10000
         SLL   2,1
         CH    2,V10000+2
.EXIT2   ANOP
         BC    12,OL3
*
         LA    3,1(3)
OL3      CVD   3,M3
         MVC   M2,FMT
         ED    M2,M3+4
         MVI   MSGAREA+1,L'FMT+4
EXIT1    LA    1,MSGAREA
         SVC   35
         LM    14,12,0(13)
         BR    14
*
EL8      MVC   M2(L'MSG5),MSG5
         MVI   MSGAREA+1,L'MSG5+4
         B     EXIT1
*
         AIF   (&DEBUGMO EQ 0).LSKIP 
DBRSAV   DS    3F
DBGAREA  DC    AL2(17)
         DC    XL2'00'
         DC    C' X XXXXXXXXXX'
.LSKIP   ANOP
*
FMT      DC    X'4020202021204B2020'
MSG1     DC    C'NUMBER PI CALCULATOR V1'
MSG3     DC    C'XXXX DIGITS WILL BE PRINTED'
MSG4     DC    C'WRONG NUMBER'
MSG5     DC    C'TIMER ERROR'
*
M3       DS    D
INPAREA  DC    AL1(4)
         DC    AL3(M3)
         DC    AL4(0)
         DC    AL2(L'MSG2+L'MSG2N+4)   LENGTH OF PROMPT + 4
         DC    AL2(0)
MSG2     DC    C'NUMBER OF DIGITS (UP TO '
MSG2N    DC    C'XXXX)?'
MSGAREA  DC    AL2(LINELEN+4)
         DC    XL2'00'
M2       DS    CL(LINELEN)
*
         AIF   (&STCK OR &STPT).NO80
STIME    DS    F
         AGO   .EXIT3
.NO80    ANOP
T1       DS    D
T2       DS    D
.EXIT3   ANOP
V3       DC    F'3'
V7       DC    F'7'
V10000   DC    F'10000'
VFFFF    DC    X'0000FFFF'
VFFFC    DC    X'FFFFFFFC'
V2000    DC    AL4(2000*65537)
CV       DC    H'0'
V1       DC    H'1'
V4       DC    H'4'
V10      DC    H'10'
RA       DS    0H
MAXDV    DS    H
         END   BALPI

