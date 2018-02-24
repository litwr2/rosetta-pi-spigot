;for fasm assembler
;it calculates pi-number using the next C-algorithm
;https://crypto.stanford.edu/pbc/notes/pi/code.html

;#include <stdio.h>
;#define N 2800
;main() {
;   long r[N + 1], i, k, b, c;
;   c = 0;
;   for (i = 0; i < N; i++)
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


;N = 3500   ;1000 digits
N = 2800  ;800 digits

         use16
         org 100h

start:
         ;cli         ;no interrupts
         mov dx,msg1
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
         inc ax
         mov [.m100+1],ax

         xor ax,ax
         push ax
         pop es
         mov ax,[es:46ch]
         mov [time],ax
         mov ax,[es:46eh]
         mov [time+2],ax

         xor esi,esi
         xor ecx,ecx
         push ds
         pop es
.m100:   mov cx,N+1   ;fill r-array
         mov ax,2000
         mov di,ra
         rep stosw

         mov [cv],cx
.m101:   mov [kv],N

.l0:     xor edi,edi          ;d <- 0

         mov si,[kv]
         add si,si       ;i <-k*2
.l2:     movzx eax,[si+ra]     ; r[i]
         mov cx,10000    ;r[i]*10000, mul16x16
         mul ecx
         add eax,edi
         mov edi,eax

         dec si        ;b <- 2*i-1
         ;xor edx,edx
         div esi
         mov [si+ra+1],dx   ;r[i] <- d%b
         dec si      ;i <- i - 1
         je .l4

         sub edi,edx
         sub edi,eax
         shr edi,1
         jmp .l2

.l4:     mov eax,edi
         xor edx,edx
         mov si,10000
         div esi
         add ax,[cv]  ;c + d/10000
         mov [cv],dx     ;c <- d%10000
         mov cx,ax
         call PR0000
         sub [kv],14      ;k <- k - 14
         jne .l0

.l5:     mov dl,' '
         call PR0000.le

         xor ax,ax
         mov es,ax
         mov bx,[es:46ch]
         sub bx,[time]
         mov ax,[es:46eh]
         sbb ax,[time+2]
         mov di,10000
         mul di
         mov si,ax
         mov ax,bx
         mul di
         add dx,si
         rol eax,16
         mov ax,dx
         rol eax,16
         xor edx,edx
         mov si,1821
         div esi
         shl dx,1
         cmp si,dx
         adc ax,0
         xor edx,edx
         mov di,string
         mov si,10
         div esi
         mov [di],dl
         inc di
         mov edx,eax
         shr edx,16
         div si
         mov [di],dl
         inc di
         xor dx,dx
         mov byte [di],'.'-'0'
         inc di
.l12:    or ax,ax
         jz .l11

         div si
         mov [di],dl
         inc di
         xor dx,dx
         jmp .l12

.l11:    dec di
         mov dl,[di]
         call PR0000.l2
         cmp di,string
         jne .l11
         ;sti
         int 20h

PR0000:     ;prints cx
        mov bx,1000
	CALL .l0
        mov bx,100
	CALL .l0
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

getnum: xor cx,cx    ;length
        xor bp,bp    ;number
.l0:    xor ah,ah
        int 16h 
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

        cmp bp,9236+1
        jnc .l0

.l8:    pop ax
        loop .l8
        retn

string rb 6
msg1  db 'number ',227,' calculator v1',13,10
      db 'it may give 9000 digits in less than 5 minutes a PC 386DX @25MHz!'
      db 13,10,'number of digits (up to 9236)? $'
msg3  db ' digits will be printed'
msg2  db 13,10,'$'
del   db 8,' ',8,'$'

        align 2
cv  dw 0
kv  dw 0
time dw 0,0
ra  dw 0

