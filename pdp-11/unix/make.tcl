#!/usr/bin/expect -f

#run it with parameters for LCM+L: user password
set noeis 0
set eis 1
set c 0
set v 8
#If it all goes pear shaped the script will timeout after 20 seconds.
set timeout 16
#Second argument is assigned to the variable user
set user [lindex $argv 0]
#Third argument is assigned to the variable password
set password [lindex $argv 1]
#This spawns the telnet program and connects it to the variable name
spawn ssh misspiggy@tty.livingcomputers.org
#The script expects login
expect timeout
set timeout 1
send "\n"
expect "Password"
expect timeout
expect "login: "
#The script sends the user variable
send "$user\n"
#The script expects Password
expect timeout
expect "Password:"
#The script sends the password variable
send "$password\n"
expect timeout
send "ls\n"
send "who\n"
expect timeout

if $noeis {
  set fn pi-noeis
  exec awk -f sx.awk $fn.sx >$fn.c
  exec cc -E $fn.c >$fn.x
  exec sed /^#/d $fn.x >$fn.s
  set f [open $fn.s r]
  send "rm ${fn}$v.s\n"
  send "touch ${fn}$v.s\n"
  expect timeout
  while {![eof $f]} {
    send "echo '"
    gets $f s; regsub "#" $s "\\#" s
    send "$s\n"
    gets $f s; regsub "#" $s "\\#" s
    send "$s\n"
    gets $f s; regsub "#" $s "\\#" s
    expect timeout
    send "$s\n"
    gets $f s; regsub "#" $s "\\#" s
    send "$s\n"
    gets $f s; regsub "#" $s "\\#" s
    send "$s'>>${fn}$v.s\n\n"
    expect timeout
  }
  exec rm $fn.x $fn.c $fn.s
  send "cc -c ${fn}$v.s\n"
  expect timeout
}
if $eis {
  set fn pi-eis
  exec cc -E $fn.c >$fn.x
  exec sed /^#/d $fn.x >$fn.s
  set f [open $fn.s r]
  send "rm ${fn}$v.s\n"
  send "touch ${fn}$v.s\n"
  expect timeout
  while {![eof $f]} {
    send "echo '"
    gets $f s; regsub "#" $s "\\#" s
    send "$s\n"
    gets $f s; regsub "#" $s "\\#" s
    send "$s\n"
    expect timeout
    gets $f s; regsub "#" $s "\\#" s
    send "$s\n"
    gets $f s; regsub "#" $s "\\#" s
    send "$s\n"
    gets $f s; regsub "#" $s "\\#" s
    send "$s'>>${fn}$v.s\n\n"
    expect timeout
  }
  exec rm $fn.x $fn.s
  send "cc -c ${fn}$v.s\n"
  expect timeout
}
if $c {
  set fn pi
  set f [open $fn.c r]
  expect timeout
  send "rm ${fn}.c\n"
  send "touch ${fn}.c\n"
  expect timeout
  while {![eof $f]} {
    send "echo '"
    gets $f s; regsub "#" $s "\\#" s
    send "$s\n"
    gets $f s; regsub "#" $s "\\#" s
    send "$s\n"
    expect timeout
    gets $f s; regsub "#" $s "\\#" s
    send "$s\n"
    gets $f s; regsub "#" $s "\\#" s
    send "$s\n"
    gets $f s; regsub "#" $s "\\#" s
    send "$s'>>${fn}.c\n\n"
    expect timeout
  }
  send "cc -c ${fn}.c\n"
  expect timeout
}
if $c&&$eis {
  send "cc -o pi-eis$v pi-eis$v.o pi.o\n"
  expect timeout
}
if $c&&$noeis {
  send "cc -o pi-noeis$v pi-noeis$v.o pi.o\n"
}

#This hands control of the keyboard over two you (Nice expect feature!)
interact
