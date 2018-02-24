10 cls:m%=&921:f%=inkey(0):n%=8264:himem=m%:*load pi3
30 p."number pi calculator for co-pro"
50 p."number of digits (up to ";n%;:input")? "f%:d%=(f%+3)and-4:ifd%<=0ord%>n%goto50
70 iff%<>d%thenp.;d%" digits will be printed"
80 f%=d%div2*7:?&935=f%/128:?&962=f%and255:?&966=f%/256:?&94a=f%*2and255:callm%
