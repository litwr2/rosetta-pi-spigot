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
MULOPT = 0   ;1 is slower for the 80386 but must be faster for the 80486

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
         call PR0000
         mov dx,msg3
         mov ah,9
         int 21h
         pop ax

.l7:     mov bx,7
         mul bx
         mov bp,ax
         shr ax,2
         push ax

         mov ah,2ch
         int 21h
         mov [time+2],cx
         mov [time],dx

         xor esi,esi
         push ds
         pop es
         pop cx       ;fill r-array
         mov eax,2000*65537
         mov di,ra+2
         rep stosd

         mov bx,cx
.l0:     xor edi,edi          ;d <- 0
         mov si,bp
         ;add si,si       ;i <-k*2
if MULOPT = 0
         mov ecx,10000
else
         xor edx,edx
         xor ecx,ecx
end if
         jmp .l2

.longdiv:
         rol eax,16
if MULOPT
         xor edx,edx
end if
         div esi
         jmp .lxc

         align 4
.l4:     sub edi,edx      ;T2
         sub edi,eax      ;T2
         shr edi,1        ;T3
.l2:     movzx eax,word [si+ra]     ;r[i]   ;T6
if MULOPT = 0
     mul ecx          ;T9-38/13-42, sets EDX=0
else
     mov ecx,eax      ;T2/1
     shl eax,3        ;T3/2
     sub ecx,eax      ;T2/1
     add eax,eax      ;T2/1
     sub ecx,eax      ;T2/1
     sub ecx,eax      ;T2/1
     shl ecx,8        ;T3/2
     sub eax,ecx      ;T2/1
                      ;=T18/10
end if
         add eax,edi      ;T2/1
         mov edi,eax      ;T2/1
         dec si        ;b <- 2*i-1   ;T2
         rol eax,16     ;T3/2
         cmp ax,si      ;T2/1
         jnc .longdiv   ;T3/1

         mov dx,ax      ;T2/1
         shr eax,16     ;T3/2
         div si         ;T22/24
.lxc:    mov [si+ra+1],dx   ;r[i] <- d%b  ;T2
         dec si      ;i <- i - 1   ;T2
         jne .l4          ;T10
                          ;To91
         mov eax,edi
         xor edx,edx
if MULOPT
         mov ecx,10000
end if
         div ecx
         add ax,bx  ;c + d/10000
         mov bx,dx     ;c <- d%10000
if IO = 1
         call PR0000
end if
         sub bp,28      ;k <- k - 14
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
         mov ax,cx
         call PR00000
         mov dl,'.'
         call PR00.le
         pop ax
         xor ah,ah
         call PR00
.l11:    int 20h

PR00000:    ;prints ax
        mov si,10000
	CALL PR00.l0
PR0000:     ;prints ax
        mov si,1000
	CALL PR00.l0
        mov si,100
	CALL PR00.l0
PR00:
        mov si,10
	CALL .l0
	mov dl,al
.l2:	add dl,'0'
.le:    mov ah,2
   	int 21h
	mov ax,cx
        retn

.l0:    mov dl,0ffh
.l4:	inc dl
        mov cx,ax
	sub ax,si
	jnc .l4
	mov ax,cx
	jmp .l2

        align 2
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
        ja .l0

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
