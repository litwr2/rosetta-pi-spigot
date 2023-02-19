/*   the MPW commands used for building and running in directory {MPW}pi:
directory :pi
files
open pi.c
open pi.a
PPCAsm -sym off -lo pi.a.lst -o pi.a.o pi.a
MrC -sym off -opt off pi.c -o pi.c.o
PPCLink pi.c.o pi.a.o "{SharedLibraries}"InterfaceLib "{SharedLibraries}"MathLib "{SharedLibraries}"StdCLib "{PPCLibraries}"StdCRuntime.o "{PPCLibraries}"PPCCRuntime.o -sym off -o pi
pi
MrC -sym off -opt off -asm pi.c
*/

#include <Windows.h>
#include <Fonts.h>
#include <Quickdraw.h>
#include <Events.h>
#include <OSUtils.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
//#include <DEbugging.h>

unsigned char WindowName[] = "\027Number pi calculator v1";
WindowPtr WindPtr;
short Yoff = 23, Xoff = 1, WindowHEdge, WindowVEdge;
static struct QDGlobals qd;
Point penloc;
EventRecord event;
Rect rect;
char s[40];
char *gPimem;

void pr0000(int n) {
    MoveTo(Xoff, Yoff);
	sprintf(s, "\004%04d", n);
	DrawString((unsigned char const *)s);
	GetPen(&penloc);
	Xoff = penloc.h;
	if (Xoff > WindowHEdge) {
	    Yoff += 10;
		Xoff = 1;
		if (Yoff > WindowVEdge) {
		    rect = WindPtr->portRect;
		    ScrollRect(&rect, 0, -10, 0);
			Yoff -= 10;
		}
	}
}

unsigned int getnum(unsigned int maxn) {
    unsigned int d7 = 0; //lenghth
	unsigned int d5 = 0; //number
	unsigned int d0;
	short stack[4], stackv[4], stackh[4], sp = 0;

	GetPen(&penloc);
	DrawChar('_');
    MoveTo(penloc.h, penloc.v);
l0: SystemTask();
	if (GetNextEvent(everyEvent, &event) == 0 || event.what != keyDown) goto l0;
	d0 = event.message & charCodeMask;
    if (d0 == 13 || d0 == 3) goto l5;
	if (d0 == 8) goto l1;
	if (d0 < '0' || d0 > '9' || d7 == 4) goto l0;
	stackv[sp] = penloc.v;
	stackh[sp] = penloc.h;
	rect.top = 0;
	rect.left = penloc.h;
	rect.bottom = penloc.v + 1;
	rect.right = penloc.h + 8;
	EraseRect(&rect);
	DrawChar(d0);
	GetPen(&penloc);
	DrawChar('_');
    MoveTo(penloc.h, penloc.v);
	stack[sp++] = d5;
	d7++;
	d5 = d5*10 + d0 - '0';
	goto l0;
l1:
	if (d7 == 0) goto l0;
	d7--;
	d5 = stack[--sp];
	rect.top = 0;
	rect.left = stackh[sp];
	rect.bottom = stackv[sp] + 1;
	rect.right = rect.left + 16;
	EraseRect(&rect);
	MoveTo(penloc.h = rect.left, penloc.v = stackv[sp]);
	DrawChar('_');
    MoveTo(penloc.h, penloc.v);
	goto l0;
l5:
    if (d7 == 0 || d5 > maxn || d5 == 0) goto l0;
	return d5;
}

void main() {
	short maxn = 9172 /* code size is between 1305 and 1332 */, i;
    unsigned ts;

	InitGraf((Ptr) &qd.thePort);
	InitFonts();
	InitWindows();
	InitMenus();
	InitCursor();

    rect = qd.screenBits.bounds;
	rect.top = 42;
	rect.left = 6;
	rect.bottom -= 30;
	rect.right -= 8;
    WindPtr = NewWindow(0, &rect, WindowName, 1, 0, (WindowPtr)-1, 0, 0);
	SetPort(WindPtr);
	TextFont(4); //Monaco font (monospace)
	TextSize(10);
	WindowHEdge = rect.right - CharWidth('0')*4;
	WindowVEdge = rect.bottom - rect.top - 10;

    MoveTo(1, 10);
	sprintf(s, " number of digits (up to %d)? ", maxn);
	s[0] = strlen(s) - 1;
	DrawString((unsigned char const *)s);
	i = getnum(maxn);
	if (i%4 != 0) {
	    i = (i + 3) & 0xfffc;
		sprintf(s, " %d digits will be printed", i);
	    s[0] = strlen(s) - 1;
		MoveTo(1, Yoff);
	    DrawString((unsigned char const *)s);
		Yoff += 12;
	}
	gPimem = malloc(i*7);
	ts = TickCount();
        //Debugger();
	pix(i*7);
	MoveTo(0, Yoff + 10);
	sprintf(s, "  %.2f", (TickCount() - ts)/60.);
	s[0] = strlen(s) - 1;
	DrawString((unsigned char const *)s);
l0:     SystemTask();
	if (GetNextEvent(everyEvent, &event) == 0 || (event.what != keyDown && event.what != mouseDown)) goto l0;
	free(gPimem);
}
