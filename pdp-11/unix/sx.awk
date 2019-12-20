#Unix v7 assembler doesn't support macros
#This script expands some macros

/\.endm/ {
   f = 0
   while (n--) printf "%s", sprintf(s, ++k)
   next
}
f==1 {
  if ($1 == "div0")
     s = "divp%d:asl r3\n  rol r2\n  bcs 1f\n  cmp r2,r1\n  bcs 0f\n1: sub r1,r2\n  inc r3\n0:\n";
  else
     s = $0 "\n"
}
/\.rept/ {
    s = ""
    n = $2
    f = 1
}
f==0
