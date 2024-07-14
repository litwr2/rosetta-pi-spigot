s/[sS][uU][bB]\s+[hH][lL]\s*,\s*[bB][cC]/db 8  ;sub hl,bc/;                         #dsub
s/[sS][rR][aA]\s+[hH][lL]/db 10h  ;sra hl/;                                         #arhl
s/[rR][lL]\s+[dD][eE]/db 18h  ;rl de/;                                              #rdel
s/[lL][dD]\s+[dD][eE]\s*,\s*[hH][lL]\s*\+\s*([^\s]+)/db 28h, \1  ;ld de,hl+byte/;   #ldhi
s/[lL][dD]\s+[dD][eE]\s*,\s*[sS][pP]\s*\+\s*([^\s]+)/db 38h, \1  ;ld de,sp+byte/;   #ldsi
s/[lL][dD]\s+\(\s*[dD][eE]\s*\)\s*,\s*[hH][lL]/db 0d9h  ;ld (de),hl/;               #shlx
s/[lL][dD]\s+[hH][lL]\s*,\(\s*[dD][eE]\s*\)/db 0edh  ;ld hl,(de)/;                  #lhlx
s/[rR][sS][tT][vV]/db 0c8h  ;rstv/;                                                 #rstv
s/[jJ][pP]\s+[nN][xX]5\s*,\s*([^\s]+)/db 0ddh, low(\1), high(\1)  ;jp nx5,word/;    #jnx5 word
s/[jJ][pP]\s+[xX]5\s*,\s*([^\s]+)/db 0fdh, low(\1), high(\1)  ;jp x5,word/;         #jx5 word

