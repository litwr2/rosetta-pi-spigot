;for asm32 assembler under PanOS
;it calculates pi-number using the next C-algorithm
;https://crypto.stanford.edu/pbc/notes/pi/code.html

;#include <stdio.h>
;#define N 2800
;main() {
;   long r[N + 1], i, k, b, c;
;   c = 0;
;   for (i = 1; i <= N; i++)   ;it is the fixed line!, the original was (i = 0; i < N; ...
;      r[i] = 2000;
;   for (k = N; k > 0; k -= 14) {
;      d = 0;
;      i = k;
;      for(;;) {
;         d += r[i]*10000;
;         b = i*2 - 1;
;         r[i] = d%b;
;         d /= b;
;         i--;
;         if (i == 0) break;
;         d *= i;
;      }
;      printf("%.4d", (int)(c + d/10000));
;      c = d%10000;
;   }
;}

;the time of the calculation is quadratic, so if T is time to calculate N digits
;then 4*T is required to calculate 2*N digits

	MODULE	Pi
	IMPORTC	XBlockWrite = 'IO' . 'XBlockWrite'
	;IMPORTC	XReadByte  = 'IO' . 'XReadByte'
	IMPORTC	XWriteByte = 'IO' . 'XWriteByte'
	IMPORTC	XFindInput = 'IO' . 'XFindInput'
        IMPORTC	XFindOutput = 'IO' . 'XFindOutput'
        IMPORTC	XSReadByte = 'IO' . 'XSReadByte'
        IMPORTC	XSWriteByte = 'IO' . 'XSWriteByte'
	;IMPORTC	XStringToInteger = 'Convert' . 'XStringToInteger'
        IMPORTC XBinaryTime = 'TimeAndDate' . 'XBinaryTime'
        IMPORTC XAllocate = 'Store' . 'XAllocate'
        IMPORTC XDeallocate = 'Store' . 'XDeallocate'

;N       EQU 3500   ;1000 digits
;N       EQU 2800  ;800 digits

	 ENTRY
sop      EQU $
        ADDR @6,TOS
        ADDR inp,TOS
        CXP XFindInput
        MOVD R0,time
        ADDR @7,TOS
        ADDR out,TOS
        CXP XFindOutput
        MOVD R0,time+4

         ADDR msg1,TOS
         ADDR @msg1l,TOS
         CXP XBlockWrite

         MOVW =((65536-eop+sop)/7)&65532,R1
         MOVW R1,maxnum
         BSR PRDEC

         ADDR msg4,TOS
         ADDR @3,TOS
         CXP XBlockWrite
         
         BSR getnum
         MOVD R1,time+8

         ADDR @10,TOS
         CXP XWriteByte

         MOVD time+8,R1
         MOVD R1,R0
         ADDQD =3,R1
         BICD =3,R1
         CMPD R1,R0
         BEQ l7

         MOVD R1,TOS
         JSR PRDEC
         ADDR msg3,TOS
         ADDR @msg3l,TOS
         CXP XBlockWrite
         MOVD TOS,R1

l7       ;LSHD =-1,R1
         MULD =7,R1
         MOVD R1,time+8
                                    
         MOVD R1,TOS
         CXP XAllocate
         MOVD R0,ra

         ADDR time,TOS
         CXP XBinaryTime

         MOVD time+8,R2       ;fill r-array
         ADDQW =-2,R2
         MOVD =2000+2000*65536,R0
         MOVD ra,R5
lb0      MOVD R0,0(R5)
         ADDQD =4,R5
         ADDQW =-4,R2
         BCS lb0

         MOVW =0,cv
         MOVD time+8,R0
         MOVW R0,kv

l0       XORD R5,R5          ;d <- 0
         MOVZWD kv,R4       ;i <-k*2
         MOVD ra,R6
         ADDD R4,R6
         ADDQD =-1,R4       ;b <- 2*i-1
         MOVD =10000,R7
l2       MOVZWD -2(R6),R0    ;r[i]
         MULD R7,R0        ;r[i]*10000
         ADDD R0,R5
         MOVD R5,R0

         XORD R1,R1
         DEID R4,R0         ;R1:R0 is divided by R4, R0 - remainder, R1 - quotient
         MOVW R0,-2(R6)   ;r[i] <- d%b
         CMPQD =1,R4
         BEQ l4

         ADDQD =-2,R6
         ADDQD =-2,R4         ;i <- i - 1
         SUBD R1,R5
         SUBD R0,R5
         LSHD =-1,R5
         BR l2

l4       MOVD R5,R0
         XORD R1,R1
         DEID R7,R0
         ADDW cv,R1         ;c + d/10000
         MOVW R0,cv         ;c <- d%10000
         BSR PR0000
         SUBW =28,kv        ;k <- k - 14*2
         CMPQW =0,kv
         BNE l0
                       
         ADDR time+4,TOS
         CXP XBinaryTime
                   
         MOVD ra,TOS
         CXP XDeallocate

         ADDR @32,TOS
         CXP XWriteByte

         MOVD time+4,R1
         SUBD time,R1
         MOVD R1,TOS
         QUOD =100,R1
         BSR PRDEC

         ADDR @'.',TOS
         CXP XWriteByte

         MOVD TOS,R1
         REMD =100,R1
         MULW =100,R1
         BSR PR0000
                      
         ADDR @10,TOS
         CXP XWriteByte

	 MOVQD	=0, R0
	 RXP	8

PR0000    ;PRINTS R1W
       MOVW R1,PRBUF
       QUOW =1000,R1
       ADDR '0'(R1),TOS
       CXP XWriteByte
       MOVW PRBUF,R1
       REMW =1000,R1
       MOVW R1,PRBUF
       QUOW =100,R1
       ADDR '0'(R1),TOS
       CXP XWriteByte
       MOVW PRBUF,R1
       REMW =100,R1
       MOVB R1,PRBUF
       QUOB =10,R1
       ADDR '0'(R1),TOS
       CXP XWriteByte
       MOVB PRBUF,R1
       REMB =10,R1
       ADDR '0'(R1),TOS
       CXP XWriteByte
       RET 0

PRBUF   DCW 0
        DCW 0

PRDEC     ;prints and uses R1
        MOVQB =-1,PRQ
PRDEC0  MOVD R1,PRBUF
	REMD =10,R1
        ADDR '0'(R1),TOS
	ADDQB =1,PRQ
        MOVD PRBUF,R1
        QUOD =10,R1
        CMPQD =0,R1
        BNE PRDEC0

PRDEC1  CXP XWriteByte
        ADDQB =-1,PRQ
        BCS PRDEC1
        RET 0

PRQ     DCB 0

;        ALIGN 4
    ALLOCB 2   ;alignement
cv  DCW 0
kv  DCW 0
time DCD 0,0,0
;ra  ALLOCW  1402
ra DCD 0
maxnum DCW 0

getnum  XORD R2,R2    ;length
        XORD R1,R1    ;number
gl0     SAVE [R1,R2]
        MOVD time,TOS
        CXP XSReadByte
        RESTORE [R1,R2]
        CMPB =13,R0
        BEQ gl5

        CMPB =127,R0    ;backspace
        BEQ gl1

        CMPB R0,='0'
        BLT gl0

        CMPB R0,='9'
        BGT gl0

        CMPQB =4,R2
        BEQ gl0

        MOVD R1,TOS
        SAVE [R0,R1,R2]
        MOVD R0,TOS
        CXP XWriteByte
        RESTORE [R0,R1,R2]
        ADDQB =1,R2
        SUBB ='0',R0
        MULD =10,R1
        ADDD R0,R1
        BR gl0

gl1     CMPQB =0,R2
        BEQ gl0

        ADDQB =-1,R2
        MOVD R2,TOS
        ADDR @127,TOS
        MOVD time+4,TOS
        CXP XSWriteByte
        ;MOVD TOS,R2
        ;MOVD TOS,R1 
        RESTORE [R1,R2]
        BR gl0

gl5     CMPQB =0,R2
        BEQ gl0

        CMPW R1,maxnum
        BGE gl0

        CMPQW =0,R1
        BEQ gl0

gl8     MOVD TOS,R0
        ADDQB =-1,R2
        CMPQB =0,R2
        BNE gl8
        RET 0    ;returns inputted number in R1

;;string rb 6
msg1  DCS 'number ',240,' calculator v1 (PanOS/32016)',10
      DCS 'number of digits (up to '
msg1l EQU $-msg1
msg4  DCS ')? '
msg3  DCS ' digits will be printed',10
msg3l EQU $-msg3
inp   DCS 'rawkb:'
out   DCS 'rawvdu:'
eop   EQU $
       END
