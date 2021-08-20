#gawk
f == 0 {
    f = 1
    a = substr($0, 4, 4)
    cs = 256 - xor(strtonum("0x" substr(a, 1, 2)), strtonum("0x" substr(a, 3)), 1)
}
/^:00/ {
    print ":00" a "01" sprintf("%02X", cs)
    next
}
{
    print
}
