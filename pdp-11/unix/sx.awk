#Unix v7 assembler doesn't support macros
#This script expands some macros
#use it 2 times!
{
    if ($1 == "div0s")
        printf "  rol r3\n  rol r2\n  add r0,r2\n  bcc %s\n", $2
    else if ($2 == "div0s")
        printf "%s  rol r3\n  rol r2\n  add r0,r2\n  bcc %s\n", $1, $3
    else if ($1 == "div0a")
        printf "  rol r3\n  rol r2\n  add r1,r2\n  bcs %s\n", $2
    else if ($2 == "div0a")
        printf "%s  rol r3\n  rol r2\n  add r1,r2\n  bcs %s\n", $1, $3
    else if ($1 == "div0")
        printf "divp%d: asl r3\n  rol r2\n  bcs 1f\n  cmp r2,r1\n  bcs 0f\n1: sub r1,r2\n  inc r3\n0:\n", k++;
    else if ($1 == "div0z") {
		printf "  div0s %sa01\n", $2
		printf "  div0s %sa02\n", $2
		printf "%ss02:  div0s %sa03\n", $2, $2
		printf "%ss03:  div0s %sa04\n", $2, $2
		printf "%ss04:  div0s %sa05\n", $2, $2
		printf "%ss05:  div0s %sa06\n", $2, $2
		printf "%ss06:  div0s %sa07\n", $2, $2
		printf "%ss07:  div0s %sa08\n", $2, $2
		printf "%ss08:  div0s %sa09\n", $2, $2
		printf "%ss09:  div0s %sa10\n", $2, $2
		printf "%ss10:  div0s %sa11\n", $2, $2
		printf "%ss11:  div0s %sa12\n", $2, $2
		printf "%ss12:  div0s %sa13\n", $2, $2
		printf "%ss13:  div0s %sa14\n", $2, $2
		printf "%ss14:  div0s %sa15\n", $2, $2
		printf "%ss15:  div0s %sa00\n", $2, $2
		printf "%ss00:  rol r3\n", $2
		printf "  br %sl80\n", $2
		printf "%sa01:  div0a %ss02\n", $2, $2
		printf "%sa02:  div0a %ss03\n", $2, $2
		printf "%sa03:  div0a %ss04\n", $2, $2
		printf "%sa04:  div0a %ss05\n", $2, $2
		printf "%sa05:  div0a %ss06\n", $2, $2
		printf "%sa06:  div0a %ss07\n", $2, $2
		printf "%sa07:  div0a %ss08\n", $2, $2
		printf "%sa08:  div0a %ss09\n", $2, $2
		printf "%sa09:  div0a %ss10\n", $2, $2
		printf "%sa10:  div0a %ss11\n", $2, $2
		printf "%sa11:  div0a %ss12\n", $2, $2
		printf "%sa12:  div0a %ss13\n", $2, $2
		printf "%sa13:  div0a %ss14\n", $2, $2
		printf "%sa14:  div0a %ss15\n", $2, $2
		printf "%sa15:  div0a %ss00\n", $2, $2
		printf "%sa00:  rol r3\n", $2
		printf "  add r1,r2\n"
		printf "%sl80:\n", $2
    }
    else
        print
}
