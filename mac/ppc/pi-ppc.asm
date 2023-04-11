;for the MPW assembler, used as pi.a
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
;max number of digits is 9400 due to data types used

;litwr has written this for the PowerPC
;tricky provided some help
;MMS gave some support
;a/b, saimo, and modrobert helped to optimize the 68k code

IO: set 1
PPC601: set 0

; MakeFunction sets up everything you need to make an assembly function 
; callable from C and debuggable with a symbolic debugger. It does the following:
; - export the function's transition vector
; - export the function name
; - create a toc entry for the function's transition vector
; - create the transition vector, which must contain
;     - the function entry point (the name of the function)
;     - the TOC anchor (the predefined variable TOC[tc0])
; - tell PPCAsm to create a function entry point symbol for symbolic debuggers
; - create a csect for the function (one csect per function lets the
;	linker do dead code stripping, resulting in smaller executables)

	MACRO
	MakeFunction &fnName
		EXPORT &fnName[DS]
 		EXPORT .&fnName[PR]
		
		TC &fnName[TC], &fnName[DS]
			
		CSECT &fnName[DS]
			DC.L .&fnName[PR]
 			DC.L TOC[tc0]
		
		CSECT .&fnName[PR]
		FUNCTION .&fnName[PR]
		
	ENDM
	
linkageArea:		set 24	; constant comes from the PowerPC Runtime Architecture Document
CalleesParams:		set	32	; always leave space for GPR's 3-10
CalleesLocalVars:	set 0	; pix doesn't have any
numGPRs:			set 0	; num volitile GPR's (GPR's 13-31) used by pix
numFPRs:			set 0	; num volitile FPR's (FPR's 14-31) used by pix

spaceToSave:	set linkageArea + CalleesParams + CalleesLocalVars + 4*numGPRs + 8*numFPRs  

	  import .pr0000
	  import gPimem
	  
	  toc
	      tc gPimem[TC], gPimem
	  
; Call the MakeFunction macro, defined in MakeFunction.s to begin the function
	MakeFunction	pix
	
; PROLOGUE - called routine's responsibilities
		mflr	r0					; Get link register = 8
		stw		r0, 0x0008(SP)		; Store the link resgister on the stack
		stwu	SP, -spaceToSave(SP); skip over the stack space where the caller		
									; might have saved stuff
; FUNCTION BODY  ;r3 = 7*D, D - number of digits
         or r9,r3,r3             ;fill r-array, r3 = D*7
         addi r4,0,2000
         lwz r7,gPimem[TC](RTOC)
         oris r4,r4,2000
         lwz r7,0(r7)
         addic r6,r7,-4
.l8:     stwu r4,4(r6)
         addic. r3,r3,-4
         bne .l8

         addi r8,0,0               ;c
.l0:     addi r6,0,0               ;d = 0
         addi r10,0,10000
         or r5,r9,r9              ;i <-k*2
         b .l2

.l4:     subf r6,r3,r6        ;main loop start
         subf r6,r0,r6
         ;mullw r6,r0,r5
         rlwinm r6,r6,31,1,31
.l2:     lhzx r4,r5,r7       ;r[i]
         mullw r0,r10,r4      ;d += r[i]*10000
         add r0,r6,r0
         or r6,r0,r0

         addi r4,r5,-1     ;b <- 2i-1
   if PPC601
         dc.l 0x7c0022d6   ;divs r0,r0,r4
         dc.l 0x7c6002a6   ;mfmq r3
   else
         divw  r0,r0,r4    ;r0 <- r0/r1, r3 <- r0%r1; d/b  ;divwu??
         mullw r3,r4,r0    ;this instruction may execute faster on some implementations if r4 < r0
         subf r3,r3,r6    ;d%b
   endif

         sthx r3,r5,r7
         addic. r5,r5,-2    ;2i <- 2i - 2
         bne .l4         ;main loop end, jump is likely

         divw r3,r6,r10
         mullw r4,r10,r3
         add r3,r3,r8    ;c + d/10000
         subf r8,r4,r6   ;c <- d%10000
  if IO
         stw r7,40(sp)   ;24 for r3, 52 for r10
         stw r8,44(sp)
         stw r9,48(sp)
         bl .pr0000
         nop
         lwz r7,40(sp)
         lwz r8,44(sp)
         lwz r9,48(sp)
  endif		 
         addic. r9,r9,-28 ;k <- k - 14
         bne .l0

; EPILOGUE - return sequence		
		lwz		r0,0x8+spaceToSave(SP)	; Get the saved link register
		addic	SP,SP,spaceToSave		; Reset the stack pointer
		mtlr r0
		blr
	
	csect .pix[pr]
		;dc.b 'The number pi calculator'

