;for fasm assembler
;run it as 'time ./pi-linux32' to get time of the execution
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

;version 2, use `time pi-linux32' to get time

D=9360  ;digits, 9360 is the limit for 64 KB ra-array
N=D*7/2

format ELF executable 3

segment readable executable

entry $
         xor esi,esi
         xor ecx,ecx
         mov cx,N   ;fill r-array
         mov ax,2000
         mov edi,ra+2
         rep stosw

         mov [cv],cx
         mov [kv],N
.l0:     xor edi,edi          ;d <- 0
         mov si,[kv]
         add si,si       ;i <-k*2
.l2:     movzx eax,[esi+ra]     ; r[i]
         mov cx,10000    ;r[i]*10000, mul16x16
         mul ecx
         add eax,edi
         mov edi,eax

         dec si        ;b <- 2*i-1
         ;xor edx,edx
         div esi
         mov [esi+ra+1],dx   ;r[i] <- d%b
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
	 mov	edx,4
         mov	ecx,wb
         mov	ebx,1		;STDOUT
         mov	eax,4		;sys_write
	 int     0x80

         xor ecx,ecx
         sub [kv],14      ;k <- k - 14
         jne .l0

.l5:     xor	ebx,ebx 	;exit code 0
	 mov	eax,1		;sys_exit
	 int     0x80

PR0000:     ;prints cx
        mov edi,wb
        mov bx,1000
	CALL .l0
        mov bx,100
	CALL .l0
        mov bx,10
	CALL .l0
	mov al,cl
.l2:	add al,'0'
        stosb 
        retn

.l0:    mov al,0ffh
.l4:	inc al
        mov bp,cx
	sub cx,bx
	jnc .l4

	mov cx,bp
	jmp .l2

segment readable writeable
cv  dw 0
kv  dw 0
wb  dw 0,0
ra  rw N

