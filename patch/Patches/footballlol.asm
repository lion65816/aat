
	!MiscTable = $1594
if read1($00ffd5) == $23
	sa1rom
	!MiscTable = $3360
endif

org $03800E  
db $B0,$C0,$D0,$D0	;data table for the bounce speed of footballs

org $03805C

autoclean JSL NewFootBall

freecode

NewFootBall:
LDA !MiscTable,x
BNE IsSet
LDA #$06
IsSet:
LSR
STA !MiscTable,x
RTL