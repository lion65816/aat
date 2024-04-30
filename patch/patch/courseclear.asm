if read1($00FFD5) == $23
sa1rom
endif

table ascii-28.txt

;Edit the $38s if you want to change the palette of the tiles
;Format: YXPCCCTT. Y = vertical flip, X = horizontal flip, P = priority flag, CCC = palette number, TT = tile page.

;This is the "COURSE " text shown when you finish the level
org $05CC28
db " ",$38
db "V",$38
db "I",$38
db "C",$38
db "T",$38
db "O",$38
db "R",$38 ; space

;This is the "CLEAR!" text shown when you finish the level
org $05CC36
db "Y",$38
db " ",$38
db " ",$38
db "!",$38
db "!",$38
db " ",$38 ; Exclamation

;This is the (time symbol) shown when you finish the level
org $05CC46
db $76,$38

;This is the (multiplying symbol), 50 and = shown when you finish the level
org $05CC4E
db $26,$38 ; x sign
db "5",$38
db "0",$38
db $77,$38 ; = sign

;This is the "BONUS! " text shown when you get bonus stars
org $05CD43
db "B",$38
db "O",$38
db "N",$38
db "U",$38
db "S",$38
db "!",$38 ; Exclamation
db " ",$38 ; space

;This is the "(Star)(multiplying symbol) and (Empty space)" text shown after the "BONUS! " text
org $05CD51
db $64,$28
db $26,$38
db $FC,$38