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
         mov [maxnum],ax
         call pr0000
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
         call pr0000
         mov dx,msg3
         mov ah,9
         int 21h
         pop ax

.l7:     shr ax,1
         mov bx,7
         mul bx
         mov bp,ax
         shr ax,1
         push ax

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
         pop cx       ;fill r-array
         mov eax,2000*65537
         mov di,ra+2
         rep stosd

         mov bx,cx
.l0:     xor edi,edi          ;d <- 0
         mov si,bp
         add si,si       ;i <-k*2
         mov cx,10000
         jmp .l2

.l4:     sub edi,edx      ;T2
         sub edi,eax      ;T2
         shr edi,1        ;T3
.l2:     movzx eax,word [si+ra]     ;r[i]   ;T6
         mul ecx         ;r[i]*10000   ;T20
         add eax,edi      ;T2
         mov edi,eax      ;T2
         dec si        ;b <- 2*i-1   ;T2
         ;xor edx,edx
         div esi          ;T38
         mov [si+ra+1],dx   ;r[i] <- d%b  ;T2
         dec si      ;i <- i - 1   ;T2
         jne .l4          ;T10
                          ;To91
         mov eax,edi
         xor edx,edx
         div ecx
         add ax,bx  ;c + d/10000
         mov bx,dx     ;c <- d%10000
         call pr0000
         sub bp,14      ;k <- k - 14
         jne .l0

.l5:     mov dl,' '
         mov ah,2
   	 int 21h

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
         add dl,'0'
         mov ah,2
   	 int 21h

         cmp di,string
         jne .l11
         ;sti
         int 20h

pr0000:     ;prints ax
         mov si,prbuf+4
         mov cx,4
         mov di,10
.pr:     xor dx,dx
         div di
         add dl,'0'
         dec si
         mov [si],dl
         loop .pr

         mov dx,si
         mov ah,9
	 int 21h
         retn

prbuf rb 4
	db '$'

        align 2
time dw 0,0
ra = $ - 2
maxnum dw 0

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

        cmp bp,[maxnum]
        ja .l0

        or bp,bp
        jz .l0

.l8:    pop ax
        loop .l8
        retn

string rb 6
msg1  db 'number ',227,' calculator v5',13,10
      db 'it may give 9000 digits in less than 5 minutes with a PC 386DX @25MHz!'
      db 13,10,'number of digits (up to $'
msg4  db ')? $'
msg3  db ' digits will be printed'
msg2  db 13,10,'$'
del   db 8,' ',8,'$'
