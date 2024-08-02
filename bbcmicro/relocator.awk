function auxout(z) {
    if (x == 0) o = "    .byte "
    f = "%d"
    if (z > 9) f = "$%x"
    o = o sprintf(f, z)
    x = (x + 1)%16
    if (x == 0) print o; else o = o ","
}
BEGIN {p = 0x200}
$0~/;##.1=[2H]/ && index($0,$2)<12 {
    if (index($0,";##+1=2")) s = 2; else s = 1
    t = strtonum("0x"$2) + s
    s = t - p
    p = t
    auxout(s > 255 ? 1 : s)
    if (s > 255) {
        auxout(s%256)
        auxout(int(s/256))
    }
}
$0~/;##.0=W[0-9]+/ && index($0,$2)<12 {
    s = index($0, ";##+0=W") + 7
    n = substr($0, s) + 0
    t = strtonum("0x"$2) + 1
    s = t - p
    p = t
    auxout(s > 255 ? 1 : s)
    if (s > 255) {
        auxout(s%256)
        auxout(int(s/256))
    }
    for (i = 1; i < n; i++) {
        auxout(2)
        p += 2
    }
}
END {
    if (x != 0) print substr(o, 1, length(o) - 1)
    print "    .byte 0"
}
