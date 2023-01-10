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

*litwr has written this for the TI99/4A (+32KB RAM, +E/A or XB cartridge) and Geneve 9640
*tricky provided some help
*MMS gave some support
*Thorham and meynaf helped too

       DEF PI
mram   equ >F020

IO equ 1
D  equ 100
N  equ D*7/2
kv equ 8
cv equ 14

PI:    li 1,msg1
       li 0,>27     *write
       clr 2
       xop @six,0

       li 0,1      *allocate memory call
       li 1,7      *size
       li 2,1      *at
       seto 3      *fast
       xop @seven,0
       mov 0,0
       jeq !

err:   li 1,merr
       li 0,>27     *write
       clr 2
       xop @six,0
       blwp @0       *error
!      li 7,1
!      li 0,3        *memory mapper call
       mov 7,1       *virtual page #
       mov 7,2       *window #
       xop @seven,0
       mov 0,0
       jne err

       inc 7
       ci 7,8
       jne -!

       li 11,>f000
       li 10,ra
       s 10,11
       clr 10
       li 3,7
       div 3,10
       andi 10,>fffc
       mov 10,12   *maxnum
       bl @PR0000
       li 1,msg4
       li 0,>27     *write
       clr 2
       xop @six,0
       bl @getnum
       li 1,msg2
       li 0,>27     *write
       clr 2
       xop @six,0
       mov 14,8
       ai 8,3
       andi 8,>fffc
       c 8,14
       jeq !

       mov 8,10
       bl @PR0000
       li 1,msg3
       li 0,>27     *write
       clr 2
       xop @six,0
!      srl 8,1
       mpy @seven,8
       mov 9,@na+2   

       limi 0
       li 0,mram
       li 2,(efast-sfast)/2
       li 3,sfast
       li 5,savef
!      mov *0,*5+
       mov *3+,*0+
       dec 2
       jne -!

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
       mov @6,@tickn+2
       mov 2,@6
       limi 2

na:    li 1,N
       mov 1,kv
       li 2,2000
       li 3,ra+2
       li 15,10000
!      mov 2,*3+            *all this code is relocatable
       dec 1
       jne -!
       b @mram

slowcode:
       clr 9
       mov @tickn+2,@6

       li 0,mram
       li 2,(efast-sfast)/2
       li 5,savef
!      mov *5+,*0+
       dec 2
       jne -!

       li 1,space
       li 0,>27     *write
       li 2,1       *length
       xop @six,0

       mov @tihi,8
       mov @tilo,9
       a 8,8         *x4
       a 9,9
       jnc !

       inc 8
!      a 8,8
       a 9,9
       jnc !

       inc 8
!      clr 7
       li 3,1875      *1875=46875/25, 46875=3000000/64
       div 3,7
       div 3,8
       ci 9,1875/2
       jle !

       inc 8
!      li 10,-1
       li 3,100
!      inc 10
       s 3,8
       joc -!

       dec 7
       joc -!

       a 3,8
       bl @PR0000

       li 1,space+1
       li 0,>27     *write
       li 2,1       *length
       xop @six,0

       mov 8,10
       bl @PR00
       blwp @0

PR:    li 0,mram
       li 2,(efast-sfast)/2
       li 5,savef
!      mov *5+,*0+
       dec 2
       jne -!

       mov 11,@PR11
       bl @PR0000
       li 0,mram
       li 2,(efast-sfast)/2
       li 5,sfast
!      mov *5+,*0+
       dec 2
       jne -!

       mov @PR11,11
       b *11

PR11 equ PI

PR00: mov 11,@retsav
      b @PRE

PR0000: mov 11,@retsav    *prints R10; USE: R0,R1,R2,R5
       li 1,1000  *mov #1000,r3
	   bl @digit   *CALL @#0$
       li 1,100   *mov #100,r3
	   bl @digit  
PRE:   li 1,10
	   bl @digit
       mov 10,5    *mov r2,r0
       mov @retsav,11
l12:   mov 5,2
       swpb 2
       ai 2,>3000    *add #'0,r0
       li 1,string
       movb 2,*1
       li 0,>27     *write
       li 2,1       *length
       xop @six,0
       b *11

six    data 6
space  data >202e   *space,dot
retsav equ PI+2
string equ PI+4

digit: li 5,65535  *mov #65535,r0
!:	   inc 5       *inc r0
	   c 1,10      *cmp r10,r1
	   jgt l12

	   s 1,10       *sub r1,r10
	   jmp -!

tick:  mov 2,@tick2
       mov 12,@tick12
       clr 12      *USE: R2,R12
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
!      mov @tick12,12
       mov @tick2,2
tickn: b @0

prevti equ PI+6
tihi equ PI+8                  *@tihi@
tilo equ PI+10
tick2 equ PI+12
tick12 equ PI+14
savef equ PI+16               *its size is 0x60

sfast:
*       mov 2,*3+            *all this code is relocatable
*       dec 1
*       jne sfast

       mov 1,cv
!l0:   clr 6
       clr 7     *R7:R6 = d
       mov kv,9
       a 9,9     *i <-k*2
       jmp !l2

!l4:   s 12,7
       joc !

       dec 6
!:     s 11,7
       joc !

       dec 6
!:     s 10,6
       srl 7,1
       srl 6,1
       jnc !l2

       ai 7,>8000
!l2:   mov @ra(9),11
       mpy 15,11
       a 7,12
       mov 12,7
       jnc !

       inc 11
!:     a 6,11
       mov 11,6
       dec 9      *b <- 2*i-1
       clr 10
       div 9,11
       jno !l1

       div 9,10
       div 9,11
!l1:   mov 12,@ra+1(9)       *r[i] <- d%b
       dec 9            *i <- i - 1
       jne -!l4

  .ifeq IO,1
       div 15,10
       a cv,10
       mov 11,cv
       bl @PR
  .endif
       ai kv,-14
       jne -!l0
       b @slowcode
efast
ra
getnum: clr 13    *length
        clr 14    *number
        mov 14,@msg1+2
        li 10,msg1+4
l0:     li 1,prompt
        li 0,>27     *write
        li 2,2
        xop @six,0
        li 0,4
        li 1,>ff00
        xop @five,0
        jne l0

        andi 1,>ff00
        ci 1,>ff00
        jeq l0

        ci 1,>d00   *cr
        jeq l5

        ci 1,>8800   *bs
        jeq l1

        ci 1,>3000   *'0'
        jl l0

        ci 1,>3900   *'9'
        jh l0

        ci 13,4
        jeq l0

        movb 1,@msg1
        li 1,msg1
        li 0,>27     *write
        li 2,1
        xop @six,0
        inc 13
        clr 1
        movb @msg1,1
        ai 1,->3000  *'0'
        swpb 1
        li 2,10
        mpy 2,14
        mov 15,14
        a 1,14
        mov 14,*10+
        jmp l0

l1:     mov 13,13
        jeq l0

        dec 13
        li 1,del
        li 0,>27     *write
        li 2,5
        xop @six,0
        dect 10
        dect 10
        mov *10+,14
        jmp l0

l5:     mov 13,13
        jeq l0

        c 14,12
        jh l0

        mov 14,14
        jeq l0
        b *11

five data 5
seven data 7
msg1 text 'number pi calculator v1'
     byte 13,10
     text 'number of digits (up to '
     byte 0
msg4 text ')? '
     byte 0
msg3 text ' digits will be printed'
msg2 byte 13,10,0
del  byte 32,8,8,32,8
prompt byte >5f,8
merr text 'memory allocation error'
     byte 13,10,0
     END

