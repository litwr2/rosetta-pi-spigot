;for fasm assembler
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
;main loop count is 7*(4+D)*D/16, D - number of digits

;litwr has written this for 80x86
;tricky provided some help
;MMS gave some support
;Thorham and meynaf helped too

IO = 1

macro div32x16 { ;BX:AX = DX:AX/SI, DX = DX:AX%SI
local .div32, .exitdiv
     cmp dx,si   ;T3/3/2/2
     jc .div32   ;T16/13/9/9  - T4/4/3/3

     mov bx,ax   ;T2/2/2/2
     mov ax,dx   ;T2/2/2/2
     xor dx,dx   ;T3/3/2/2
     div si      ;T144-162/38/22/22
     xchg ax,bx  ;T4/4/3/3
     jmp .exitdiv  ;T15/14/8/8

.div32:
     xor BX,BX   ;T3/3/2/2
.exitdiv:
     div si      ;T144-162/38/22/22
}

         use16
         org 100h

start:
         ;cli         ;no interrupts
         mov dx,msg1
         mov ah,9
         int 21h

         xor ax,ax
         sub ax,ra
         mov bx,7
         xor dx,dx
         div bx
         and al,0fch
         mov cx,ax
         inc ax
         mov [maxnum],ax
         call PR0000
         mov dx,msg4
         mov ah,9
         int 21h

         call getnum
         mov dx,msg2
         mov ah,9
         int 21h

         mov ax,bp
         add ax,3
         and ax,0xfffc
         cmp ax,bp
         je .l7

         push ax
         mov cx,ax
         call PR0000
         mov dx,msg3
         mov ah,9
         int 21h
         pop ax

.l7:     shr ax,1
         mov bx,7
         mul bx
         mov [.m101+4],ax
         mov [.m100+1],ax

         mov ah,2ch
         int 21h
         mov [time+2],cx
         mov [time],dx

         push ds
         pop es
.m100:   mov cx,0        ;fill r-array
         mov ax,2000
         mov di,ra+2
         rep stosw

         mov [cv],cx
.m101:   mov [kv],0

.l0:     xor bp,bp
         mov di,bp          ;d = BP:DI <- 0

         mov si,[kv]
         add si,si       ;i <-k*2
         mov cx,10000      ;T4/4/2/2
         jmp .l2

.div32long:
     mov bx,ax   ;T2/2/2/2
     mov ax,dx   ;T2/2/2/2
     xor dx,dx   ;T3/3/2/2
     div si      ;T144-162/38/22/22
     xchg ax,bx  ;T4/4/3/3
     jmp .exitdiv  ;T15/14/8/8

                     ;T - timing, 8088/80186/80286/80386
.l4:     sub di,dx         ;T3/3/2/2
         sbb bp,0          ;T4/4/3/2
         sub di,ax         ;T3/3/2/2
         sbb bp,bx         ;T3/3/2/2
         shr bp,1          ;T2/2/2/3
         rcr di,1          ;T2/2/2/9
.l2:     mov ax,[si+ra]  ;r[i]   ;T21/9/5/4
         mul cx          ;r[i]*10000  ;T118-133/35-37/21/9-22, Ta125/a36/21/20
         add ax,di         ;T3/3/2/2
         mov di,ax         ;T2/2/2/2
         adc dx,bp         ;T3/3/2/2
         mov bp,dx         ;T2/2/2/2
         dec si        ;b <- 2*i-1  ;T3/3/2/2
         ;BX:AX = DX:AX/SI, DX = DX:AX%SI ;Ta163/a48/a29/a29
     cmp dx,si   ;T3/3/2/2
     jnc .div32long   ;T16/13/9/9  - T4/4/3/3

     xor BX,BX   ;T3/3/2/2
.exitdiv:
     div si      ;T144-162/38/22/22

         mov [si+ra+1],dx   ;r[i] <- d%b  ;T22/12/3/2
         dec si      ;i <- i - 1   ;T3/3/2/2
         jne .l4                   ;T16/14/9/9
                           ;Toa380/a152/a92/a97
if IO = 1
         mov dx,bx
         div cx
         add ax,[cv]  ;c + d/10000
         mov [cv],dx     ;c <- d%10000
         mov cx,ax
         call PR0000
end if
         sub [kv],14      ;k <- k - 14
         jne .l0

.l5:     mov dl,' '
         call PR00.le

         mov ah,2ch
         int 21h
         sub dl,byte [time]
         sub dh,byte [time+1]
         sub cl,byte [time+2]
         sub ch,byte [time+3]
         jns .l12

         add ch,24
.l12:    xor ax,ax    ;ch*3600
         xor bx,bx
         mov al,ch
         add al,al
         add al,ch    ;*3
         cbw
         mov bp,ax
         add ax,ax
         add ax,bp    ;*3
         mov bp,ax
         add ax,ax
         add ax,ax
         add ax,bp    ;*5
         mov bp,ax
         add ax,ax
         add ax,ax
         add ax,bp    ;*5
         add ax,ax
         rol bx,1
         add ax,ax
         rol bx,1
         add ax,ax
         rol bx,1
         add ax,ax
         rol bx,1     ;*16 = bx:ax
         push bx
         push ax
         mov al,cl    ;cl*60
         cbw
         mov bp,ax
         add ax,ax
         add ax,bp    ;*3
         mov bp,ax
         add ax,ax
         add ax,ax
         add ax,bp    ;*5
         add ax,ax
         add ax,ax    ;*4 = ax
         pop cx
         pop bx
         push dx
         cwd
         add cx,ax
         adc bx,dx
         pop dx
         push dx
         mov al,dh
         cbw
         cwd
         add cx,ax
         adc bx,dx
         pop dx
         jne .l11

         or dl,dl
         jns .l14

         dec cx
         add dl,100
.l14:    push dx
         call PR00000
         mov dl,'.'
         call PR00.le
         pop cx
         xor ch,ch
         call PR00
.l11:    int 20h

PR00000:    ;prints cx
        mov bx,10000
	CALL PR00.l0
PR0000:     ;prints cx
        mov bx,1000
	CALL PR00.l0
        mov bx,100
	CALL PR00.l0
PR00:
        mov bx,10
	CALL .l0
	mov dl,cl
.l2:	add dl,'0'
.le:    mov ah,2
   	int 21h
        retn

.l0:    mov dl,0ffh
.l4:	inc dl
        mov bp,cx
	sub cx,bx
	jnc .l4

	mov cx,bp
	jmp .l2

        align 2
cv  dw 0
kv  dw 0
time dw 0,0
ra = $ - 2
maxnum dw 0

getnum: xor cx,cx    ;length
        xor bp,bp    ;number
.l0:    mov ah,7
        int 21h
        or al,al
        jz .l0
 
        cmp al,13
        je .l5

        cmp al,8
        je .l1

        cmp al,'0'
        jc .l0

        cmp al,'9'+1
        jnc .l0

        cmp cl,4
        je .l0

        push bp
        mov dl,al
        mov ah,2
        int 21h
        inc cx
        xor dh,dh
        sub dl,'0'
        mov bx,dx
        mov ax,10
        mul bp
        mov bp,ax
        add bp,bx
        jmp .l0

.l1:    jcxz .l0
        dec cx
        mov dx,del
        mov ah,9
        int 21h

        pop bp
        jmp .l0

.l5:    jcxz .l0

        cmp bp,[maxnum]
        jnc .l0

        or bp,bp
        jz .l0

.l8:    pop ax
        loop .l8
        retn

string rb 6
msg1  db 'number pi calculator v8 for DOS',13,10
      db 'number of digits (up to $'
msg4  db ')? $'
msg3  db ' digits will be printed'
msg2  db 13,10,'$'
del   db 8,' ',8,'$'
