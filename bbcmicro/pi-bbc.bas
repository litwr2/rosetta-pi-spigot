10 cls:m%=&1000:if himem=m% goto 30
15 p."input video mode # (7 - default)";:f%=inkey(m%):f%=f%-48:iff%<0orf%>7thenf%=7
20 modef%:n%=((himem-m%-&1800)div7)and-4:himem=m%:*load "pi"
30 p.spc(7)"number pi calculator v1":p."   it may give 3200 digits less than":p.spc(12)"in half an hour!":p.
50 p."number of digits (up to ";n%")";:inputf%:d%=(f%+3)and-4:ifd%<=0ord%>n%goto50
70 iff%<>d%thenp.;d%" digits will be printed"
80 f%=(d%div2)*7:?(m%+1)=(f%+127)div128:?(m%+&24)=f%and255:?(m%+&28)=f%div256:time=0:callm%:p.time/100
