#!/usr/bin/expect -f

#run it with parameters for LCM+L: user password
set noeis 0
set eis 1
set c 0
#If it all goes pear shaped the script will timeout after 20 seconds.
set timeout 1
#First argument is assigned to the variable name
set name MissPiggy.LivingComputerMuseum.org
#Second argument is assigned to the variable user
set user [lindex $argv 0]
#Third argument is assigned to the variable password
set password [lindex $argv 1]
#This spawns the telnet program and connects it to the variable name
spawn telnet $name
#The script expects login
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
if $noeis {
  set fn pi-noeis
  exec awk -f sx.awk $fn.sx >$fn.s
  set f [open $fn.s r]
  send ">$fn.s\n"
  while {![eof $f]} {
    send "echo '"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s'>>$fn.s\n\n"
    expect timeout
  }
  send "as -o $fn.o $fn.s\n"
}
if $eis {
  set fn pi-eis
  set f [open $fn.s r]
  send ">$fn.s\n"
  while {![eof $f]} {
    send "echo '"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s'>>$fn.s\n\n"
    expect timeout
  }
  send "as -o $fn.o $fn.s\n"
}
if $c {
  set fn pi
  exec sed "s/#/\\\\#/" $fn.c >$fn.cx
  set f [open $fn.cx r]
  send ">$fn.c\n"
  while {![eof $f]} {
    send "echo '"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s\n"
    gets $f s
    send "$s'>>$fn.c\n\n"
    expect timeout
  }
  send "cc -c $fn.c\n"
}
if $c||$eis {
  send "cc -o pi-eis pi-eis.o pi.o\n"
}
if $c||$noeis {
  send "cc -o pi-noeis pi-noeis.o pi.o\n"
}
#This hands control of the keyboard over two you (Nice expect feature!)
interact
