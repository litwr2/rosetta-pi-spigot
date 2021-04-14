* for xas99 assembler
* it calculates pi-number using the next C-algorithm
* https://crypto.stanford.edu/pbc/notes/pi/code.html

*#include <stdio.h>
*#define N 2800
*main() {
*   long r[N + 1], i, k, b, c;
*   c = 0;
*   for (i = 1; i <= N; i++)   ;it is the fixed line!, the original was (i = 0; i < N; ...
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

*the time of the calculation is quadratic, so if T is time to calculate N digits
*then 4*T is required to calculate 2*N digits
*main loop count is 7*(4+D)*D/16, D - number of digits

*litwr has written this for the TI99/4A (+32KB RAM, +E/A or XB cartridge)
*tricky provided some help
*MMS gave some support
*Thorham and meynaf helped too

       DEF PI
STATUS EQU >837C
vdpwd  EQU >8C00
vdprd  EQU >8800
vdpwa  EQU >8C02
rows   equ 24
cols   equ 32
ra     equ >9FFE

IO equ 1
D  equ 100
N  equ D*7/2
kv equ 8
cv equ 14
start equ >2800

       aorg start
PI:    MOV 11,@save11
       STWP 11
       MOV 11,@EWP+2
       li 0,>8380
       li 1,SAVEWP
       li 2,16
!      mov *0+,*1+
       dec 2
       jne -!

*       mov @8228,4      *E/A only
*       dect 4
*       mov 4,@l2+2
*       inc 4
*       mov 4,@l1+2

       li 0,>7778
*       mov 0,@>9d00
       mov 0,@>9e00
       mov 0,@>9f00
       li 0,>8300
       li 1,SAVEWP+32
       li 2,(efast-sfast)/2
       li 3,sfast
!      mov *0,*1+
       mov *3+,*0+
       dec 2
       jne -!

       lwpi >8380
       li 0,cols*(rows-1)    *teletype :)
       li 15,10000

       limi 2
       clr 2
       mov 2,@tihi
       mov 2,@tilo
       clr 12
       sbo 0
       li 2,>3fff
       mov 2,@prevti
       inct 12
       ldcr 2,14
       dect 12
       sbz 0
       li 2,tick
       mov 2,@>83c4  *timer user proc

*       li 1,N        *@N@
       mov @start-2,1
       mov 1,kv
       li 2,2000
       li 3,ra+2
*       mov @8228,3    *E/A only
       b @>8300

slowcode:
       clr 9
       mov 9,@>83c4    *timer user proc

       li 0,cols*rows
       li 1,>8000      *space
       bl @sout

EWP    LWPI 0
       li 0,>8300
       li 1,SAVEWP+32
       li 2,(efast-sfast)/2
!      mov *1+,*0+
       dec 2
       jne -!

       li 0,>8380
       li 1,SAVEWP
       li 2,16
!      mov *1+,*0+
       dec 2
       jne -!

       MOVB 2,@STATUS
       mov @save11,11
       B *11           *rt

save11 data 0

PR0000:     ;prints R2; USE: R3,R5
       mov 11,@retsav
       li 3,1000  *mov #1000,r3
	   bl @digit  *CALL @#0$
       li 3,100   *mov #100,r3
	   bl @digit  
       li 3,10
	   bl @digit
       mov 2,5    *mov r2,r0
       mov @retsav,11
l12:   mov 5,1
       swpb 1
       ai 1,>9000    *add #48,r0
       jmp sout

retsav bss 2

digit: li 5,65535  *mov #65535,r0
!:	   inc 5       *inc r0
	   c 3,2       *cmp r2,r3
	   jgt l12

	   s 3,2       *sub r3,r2
	   jmp -!

sout:  ci 0,rows*cols      *IN: R1 - symbol,  R0 - pos; USE: R3,R4,R5
       jne !cont

       li 0,>E081     *refresh video mode, suppress screen blank
       movb 0,@vdpwa
       swpb 0
       movb 0,@vdpwa

       li 5,>4000      *scroll
       li 3,cols
!loop: swpb 3
       limi 0
       movb 3,@vdpwa
       swpb 3
       movb 3,@vdpwa
       movb @vdprd,0
       swpb 5
       movb 5,@vdpwa
       swpb 5
       movb 5,@vdpwa
       movb 0,@vdpwd
       limi 2
       inc 3
       inc 5
       ci 3,cols*rows
       jne -!loop

       li 0,cols*(rows-1)
       li 3,>8000      *space
       li 4,cols
       mov 0,5
       ori 5,>4000
!loop: swpb 5
       limi 0
       movb 5,@vdpwa
       swpb 5
       movb 5,@vdpwa
       movb 3,@vdpwd
       limi 2
       inc 5
       dec 4
       jne -!loop

!cont: mov 0,3
       ori  3,>4000    *write a single byte to VDP at pos R0
       swpb 3
       limi 0
       movb 3,@vdpwa
       swpb 3
       movb 3,@vdpwa
       movb 1,@vdpwd
       limi 2
       inc 0
       b *11           *rt

tick:  clr 12
       sbo 0
       stcr 2,15
       sbz 0
       srl 2,1
       mov @prevti,12
       mov 2,@prevti
       s 2,12
       andi 12,>3fff
       a 12,@tilo
       jnc !

       inc @tihi
!      b *11

prevti bss 2
tihi bss 2                  *@tihi@
tilo bss 2

sfast: mov 2,*3+            *all this code is relocatable
       dec 1
       jne sfast

       mov 1,cv
!l0:   clr 6
       clr 7     *R7:R6 = d
       mov kv,9
       a 9,9     *i <-k*2
       jmp l2

!l4:   s 12,7
       joc !

       dec 6
!:     s 11,7
       joc !

       dec 6
!:     s 10,6
       srl 7,1
       srl 6,1
       jnc l2

       ai 7,>8000
l2:    mov @ra(9),11
       mpy 15,11
       a 7,12
       mov 12,7
       jnc !

       inc 11
!:     a 6,11
       mov 11,6
       dec 9    *b <- 2*i-1
       clr 10
       div 9,11
       jno l1

       div 9,10
       div 9,11
l1:    mov 12,@ra+1(9)   *r[i] <- d%b
       dec 9             *i <- i - 1
       jne -!l4

  .ifeq IO,1
       div 15,10
       a cv,10
       mov 11,cv
       mov 10,2
       bl @PR0000
  .endif
       ai kv,-14
       jne -!l0
       b @slowcode
efast
SAVEWP BSS 32+efast-sfast
       END PI

